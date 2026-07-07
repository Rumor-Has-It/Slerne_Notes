local addonName, SlerneNotes = ...

local LOOT_PREFIX = "SlerneLoot"
C_ChatInfo.RegisterAddonMessagePrefix(LOOT_PREFIX)

local SLOTS = {
    { key = "head",     label = "Head",      slots = { 1 } },
    { key = "neck",     label = "Neck",      slots = { 2 } },
    { key = "shoulder", label = "Shoulder",  slots = { 3 } },
    { key = "back",     label = "Back",      slots = { 15 } },
    { key = "chest",    label = "Chest",     slots = { 5 } },
    { key = "wrist",    label = "Wrist",     slots = { 9 } },
    { key = "hands",    label = "Hands",     slots = { 10 } },
    { key = "waist",    label = "Waist",     slots = { 6 } },
    { key = "legs",     label = "Legs",      slots = { 7 } },
    { key = "feet",     label = "Feet",      slots = { 8 } },
    { key = "finger",   label = "Finger",    slots = { 11, 12 } },
    { key = "trinket",  label = "Trinket",   slots = { 13, 14 } },
    { key = "mainhand", label = "Main Hand", slots = { 16 } },
    { key = "offhand",  label = "Off Hand",  slots = { 17 } },
}
local SLOT_BY_KEY = {}
for _, def in ipairs(SLOTS) do SLOT_BY_KEY[def.key] = def end

local INVTYPE_TO_KEY = {
    INVTYPE_HEAD = "head", INVTYPE_NECK = "neck", INVTYPE_SHOULDER = "shoulder",
    INVTYPE_CLOAK = "back", INVTYPE_CHEST = "chest", INVTYPE_ROBE = "chest",
    INVTYPE_WRIST = "wrist", INVTYPE_HAND = "hands", INVTYPE_WAIST = "waist",
    INVTYPE_LEGS = "legs", INVTYPE_FEET = "feet", INVTYPE_FINGER = "finger",
    INVTYPE_TRINKET = "trinket",
    INVTYPE_WEAPON = "mainhand", INVTYPE_2HWEAPON = "mainhand",
    INVTYPE_WEAPONMAINHAND = "mainhand", INVTYPE_RANGED = "mainhand",
    INVTYPE_RANGEDRIGHT = "mainhand",
    INVTYPE_WEAPONOFFHAND = "offhand", INVTYPE_SHIELD = "offhand", INVTYPE_HOLDABLE = "offhand",
}

SlerneNotes.lootGear = {}

SlerneNotes.lootDropMap = {}

local function GetTracked()
    if not SlerneNotesDB.lootTrackedSlots then
        SlerneNotesDB.lootTrackedSlots = {}
        for _, def in ipairs(SLOTS) do SlerneNotesDB.lootTrackedSlots[def.key] = true end
    end
    return SlerneNotesDB.lootTrackedSlots
end

local function GetLog()
    SlerneNotesDB.lootLog = SlerneNotesDB.lootLog or {}
    return SlerneNotesDB.lootLog
end

local function ShortName(name)
    if not name then return nil end
    return (strsplit("-", name))
end

local function GetPlayerSlotItems(name, slotKey)
    local def = SLOT_BY_KEY[slotKey]
    if not def then return {} end
    local out = {}
    local myName = ShortName(UnitName("player"))
    if name == myName then
        for _, slotID in ipairs(def.slots) do
            local id = GetInventoryItemID("player", slotID)
            if id then
                local loc = ItemLocation:CreateFromEquipmentSlot(slotID)
                local ilvl = (loc and C_Item.DoesItemExist(loc)) and C_Item.GetCurrentItemLevel(loc) or 0
                out[#out + 1] = { id = id, ilvl = ilvl }
            end
        end
    else
        local g = SlerneNotes.lootGear[name]
        if g then
            for _, slotID in ipairs(def.slots) do
                if g[slotID] then out[#out + 1] = { id = g[slotID].id, ilvl = g[slotID].ilvl } end
            end
        end
    end
    return out
end

local function RollStateLabel(state)
    local E = Enum and Enum.EncounterLootDropRollState
    if not state or not E then return "" end
    if state == E.NeedMainSpec then return "Need"
    elseif E.NeedOffSpec and state == E.NeedOffSpec then return "Need(OS)"
    elseif E.NeedForTransmog and state == E.NeedForTransmog then return "Transmog"
    elseif E.Transmog and state == E.Transmog then return "Transmog"
    elseif E.Greed and state == E.Greed then return "Greed"
    elseif E.Pass and state == E.Pass then return "Pass"
    elseif E.NoRoll and state == E.NoRoll then return "-"
    end
    return "Roll"
end

local function ItemSlotKey(itemLink)
    local _, _, _, equipLoc = C_Item.GetItemInfoInstant(itemLink)
    return equipLoc and INVTYPE_TO_KEY[equipLoc]
end

local function ProcessDrop(encounterID, lootListID)
    if not (C_LootHistory and C_LootHistory.GetSortedInfoForDrop) then return end
    local di = C_LootHistory.GetSortedInfoForDrop(encounterID, lootListID)
    if not di or not di.itemHyperlink then return end

    local slotKey = ItemSlotKey(di.itemHyperlink)
    if not slotKey or not GetTracked()[slotKey] then return end

    local dropKey = (encounterID or 0) .. "-" .. (lootListID or 0)
    local log = GetLog()
    local idx = SlerneNotes.lootDropMap[dropKey]
    local entry = idx and log[idx]
    if not entry then

        if #log >= 50 then
            wipe(log)
            wipe(SlerneNotes.lootDropMap)
        end
        entry = { time = time(), dropKey = dropKey }
        log[#log + 1] = entry
        SlerneNotes.lootDropMap[dropKey] = #log
    end
    entry.itemLink = di.itemHyperlink
    entry.slotKey = slotKey

    entry.rolls = {}
    local infos = di.rollInfos or di.players or {}
    for _, ri in ipairs(infos) do
        if ri.playerName then
            entry.rolls[#entry.rolls + 1] = {
                name = ShortName(ri.playerName),
                class = ri.playerClass,
                label = RollStateLabel(ri.state),
                roll = ri.roll,
                winner = ri.isWinner,
            }
        end
    end

    if di.winner and di.winner.playerName then
        entry.winner = ShortName(di.winner.playerName)
        entry.winnerClass = di.winner.playerClass
        if not entry.had then
            entry.had = GetPlayerSlotItems(entry.winner, slotKey)
        end
    end

    if SlerneNotes.UpdateLootList then SlerneNotes.UpdateLootList() end
end

local function ProcessEncounter(encounterID)
    if not (C_LootHistory and C_LootHistory.GetSortedDropsForEncounter) then return end
    local drops = C_LootHistory.GetSortedDropsForEncounter(encounterID)
    if not drops then return end
    for _, drop in ipairs(drops) do
        ProcessDrop(encounterID, drop.lootListID)
    end
end

local function OnGear(sender, dataStr)
    local name = ShortName(sender)
    if not name then return end
    local g = {}
    for _, p in ipairs({ strsplit(";", dataStr or "") }) do
        if p ~= "" then
            local slot, id, ilvl = strsplit(",", p)
            slot, id = tonumber(slot), tonumber(id)
            if slot and id then g[slot] = { id = id, ilvl = tonumber(ilvl) or 0 } end
        end
    end
    SlerneNotes.lootGear[name] = g
end

local function SendGearRequest()
    local ch, tgt
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then ch = "INSTANCE_CHAT"
    elseif IsInRaid() then ch = "RAID"
    elseif IsInGroup() then ch = "PARTY"
    else ch, tgt = "WHISPER", UnitName("player") end
    C_ChatInfo.SendAddonMessage(LOOT_PREFIX, "REQ", ch, tgt)
end

local lootFrame = CreateFrame("Frame")
lootFrame:RegisterEvent("PLAYER_LOGIN")
lootFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
lootFrame:RegisterEvent("CHAT_MSG_ADDON")
lootFrame:RegisterEvent("LOOT_HISTORY_UPDATE_DROP")
lootFrame:RegisterEvent("LOOT_HISTORY_UPDATE_ENCOUNTER")

local reqPending
lootFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, msg, _, sender = ...
        if prefix == LOOT_PREFIX then
            local tag, data = strsplit("\t", msg, 2)
            if tag == "GEAR" then OnGear(sender, data) end
        end
    elseif event == "LOOT_HISTORY_UPDATE_DROP" then
        local encounterID, lootListID = ...
        ProcessDrop(encounterID, lootListID)
    elseif event == "LOOT_HISTORY_UPDATE_ENCOUNTER" then
        ProcessEncounter(...)
    elseif event == "PLAYER_LOGIN" or event == "GROUP_ROSTER_UPDATE" then
        if reqPending then reqPending:Cancel() end
        reqPending = C_Timer.NewTimer(3, function() reqPending = nil; SendGearRequest() end)
    end
end)

local rowPool = {}
local CONTENT_W = 1380

local function ClassColored(name, class)
    if not name then return "?" end
    local c = class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
    if c then
        return string.format("|cff%02x%02x%02x%s|r",
            math.floor(c.r * 255), math.floor(c.g * 255), math.floor(c.b * 255), name)
    end
    return name
end

local function ItemName(id)
    local n = id and C_Item.GetItemInfo(id)
    return n or (id and ("item:" .. id) or "?")
end

local function BuildLootUI()
    local tab = SlerneNotes.lootTab
    if not tab or tab._snBuilt then return end
    tab._snBuilt = true

    local left = CreateFrame("Frame", nil, tab, "BackdropTemplate")
    left:SetWidth(220)
    left:SetPoint("TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMLEFT", 0, 0)
    SlerneNotes.Skin.Panel(left)

    local title = left:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Track Slots")
    SlerneNotes.Skin.Title(title)

    local tracked = GetTracked()
    local checks = {}
    local y = -44
    for _, def in ipairs(SLOTS) do
        local cb = CreateFrame("CheckButton", nil, left, "UICheckButtonTemplate")
        cb:SetSize(24, 24)
        cb:SetPoint("TOPLEFT", 16, y)
        cb:SetChecked(tracked[def.key])

        if cb.GetCheckedTexture then SlerneNotes.Skin.TintTexture(cb:GetCheckedTexture()) end
        cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cb.text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        cb.text:SetText(def.label)
        cb.text:SetTextColor(1, 1, 1)
        cb:SetScript("OnClick", function(self)
            GetTracked()[def.key] = self:GetChecked() and true or nil
        end)
        checks[def.key] = cb
        y = y - 30
    end
    tab._checks = checks

    local clearBtn = CreateFrame("Button", nil, left, "UIPanelButtonTemplate")
    clearBtn:SetSize(160, 28)
    clearBtn:SetPoint("BOTTOM", 0, 16)
    clearBtn:SetText("Clear Log")
    clearBtn:SetScript("OnClick", function()
        wipe(GetLog())
        wipe(SlerneNotes.lootDropMap)
        SlerneNotes.UpdateLootList()
    end)
    SlerneNotes.Skin.Button(clearBtn)

    local scroll = CreateFrame("ScrollFrame", nil, tab, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", left, "TOPRIGHT", 14, 0)
    scroll:SetPoint("BOTTOMRIGHT", -28, 0)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(CONTENT_W, 10)
    scroll:SetScrollChild(child)
    SlerneNotes.lootScroll = scroll
    SlerneNotes.lootScrollChild = child

    local empty = child:CreateFontString(nil, "OVERLAY", "GameFontDisableLarge")
    empty:SetPoint("TOPLEFT", 10, -10)
    empty:SetText("No tracked loot yet. Drops you track will appear here.")
    SlerneNotes.lootEmptyText = empty
end

local function CreateRow(i)
    local child = SlerneNotes.lootScrollChild
    local row = CreateFrame("Frame", nil, child, "BackdropTemplate")
    row:SetWidth(CONTENT_W - 10)
    SlerneNotes.Skin.Module(row)

    row.item = row:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    row.item:SetPoint("TOPLEFT", 10, -8)
    row.item:SetJustifyH("LEFT")

    row.winner = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    row.winner:SetPoint("TOPLEFT", row.item, "BOTTOMLEFT", 0, -4)
    row.winner:SetJustifyH("LEFT")

    row.had = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.had:SetPoint("TOPLEFT", row.winner, "BOTTOMLEFT", 0, -3)
    row.had:SetJustifyH("LEFT")
    row.had:SetTextColor(0.78, 0.78, 0.85)

    row.rolls = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.rolls:SetPoint("TOPLEFT", row.had, "BOTTOMLEFT", 0, -3)
    row.rolls:SetWidth(CONTENT_W - 40)
    row.rolls:SetJustifyH("LEFT")

    rowPool[i] = row
    return row
end

function SlerneNotes.UpdateLootList()
    local child = SlerneNotes.lootScrollChild
    if not child then return end
    local log = GetLog()

    for _, r in ipairs(rowPool) do r:Hide() end
    if SlerneNotes.lootEmptyText then SlerneNotes.lootEmptyText:SetShown(#log == 0) end

    local y, shown = -8, 0
    for i = #log, 1, -1 do
        shown = shown + 1
        if shown > 80 then break end
        local e = log[i]
        local row = rowPool[shown] or CreateRow(shown)

        row.item:SetText(e.itemLink or "?")
        row.winner:SetText("Won by: " .. (e.winner and ClassColored(e.winner, e.winnerClass) or "|cff999999(pending)|r"))

        local hadStr = "—"
        if e.had and #e.had > 0 then
            local parts = {}
            for _, h in ipairs(e.had) do
                parts[#parts + 1] = ItemName(h.id) .. " (" .. (h.ilvl or 0) .. ")"
            end
            hadStr = table.concat(parts, ", ")
        end
        row.had:SetText("Had: " .. hadStr)

        local rparts = {}
        for _, r in ipairs(e.rolls or {}) do
            local s = (r.name or "?")
            if r.roll then s = s .. " " .. r.roll end
            if r.label and r.label ~= "" then s = s .. " [" .. r.label .. "]" end
            if r.winner then s = "|cffffd200" .. s .. "|r" end
            rparts[#rparts + 1] = s
        end
        row.rolls:SetText(#rparts > 0 and ("Rolls: " .. table.concat(rparts, ",  ")) or "Rolls: —")

        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 5, y)
        local h = 56 + (row.rolls:GetStringHeight() or 12)
        row:SetHeight(h)
        row:Show()
        y = y - h - 6
    end

    local minH = SlerneNotes.lootScroll and SlerneNotes.lootScroll:GetHeight() or 10
    child:SetHeight(math.max(minH, -y + 10))
end

function SlerneNotes.RefreshLootUI()
    BuildLootUI()
    local tracked = GetTracked()
    if SlerneNotes.lootTab._checks then
        for key, cb in pairs(SlerneNotes.lootTab._checks) do
            cb:SetChecked(tracked[key])
        end
    end
    SendGearRequest()
    SlerneNotes.UpdateLootList()
end

BuildLootUI()

SLASH_SNLOOT1 = "/snloot"
SlashCmdList["SNLOOT"] = function(msg)
    msg = (msg or ""):lower()
    if msg == "gear" then
        print("|cff7fd5ffSlerne Loot gear cache:|r")
        for name, g in pairs(SlerneNotes.lootGear) do
            local n = 0; for _ in pairs(g) do n = n + 1 end
            print("  ", name, n .. " slots")
        end
    elseif msg == "sim" then

        local link = GetInventoryItemLink("player", 16) or "|cffa335ee|Hitem:0|h[Test Item]|h|r"
        local log = GetLog()
        log[#log + 1] = {
            time = time(), itemLink = link, slotKey = "mainhand",
            winner = ShortName(UnitName("player")), winnerClass = select(2, UnitClass("player")),
            had = GetPlayerSlotItems(ShortName(UnitName("player")), "mainhand"),
            rolls = {
                { name = ShortName(UnitName("player")), label = "Need", roll = 100, winner = true },
                { name = "Tankguy", label = "Greed", roll = 42 },
            },
        }
        SlerneNotes.RefreshLootUI()
        print("Slerne Loot: simulated entry added.")
    else
        print("|cff7fd5ffSlerne Loot:|r /snloot sim | gear")
    end
end
