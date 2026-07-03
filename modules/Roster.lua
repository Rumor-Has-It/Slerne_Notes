local addonName, SlerneNotes = ...

local attTab = SlerneNotes.rosterTab

-- Initialize a local table to hold our new flags
SlerneNotes.RaiderFlags = SlerneNotes.RaiderFlags or { guaranteed = {}, inactive = {} }

-- BACKGROUND PANEL (Now dynamically scales to fill the parent tab)
-- Transparent container (no middle canvas): content stands on the main frame.
local bg = CreateFrame("Frame", nil, attTab, "BackdropTemplate")
bg:SetPoint("TOPLEFT", 0, 0)
bg:SetPoint("BOTTOMRIGHT", 0, 0)

-- (No title; Add Cutoff / Reset List buttons live in the footer, see below.)

-- SCROLL FRAME FOR LIST
local scrollFrame = CreateFrame("ScrollFrame", "SlerneNotesAttendanceScroll", bg, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 20, -20)
scrollFrame:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -600, 50)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(660, 10)
scrollFrame:SetScrollChild(scrollChild)

-- Hide the scrollbar (unnecessary visually); keep mouse-wheel scrolling so
-- long lists are still reachable.
local attScrollBar = scrollFrame.ScrollBar or _G["SlerneNotesAttendanceScrollScrollBar"]
if attScrollBar then
    attScrollBar:Hide()
    attScrollBar:SetScript("OnShow", attScrollBar.Hide)
end
scrollFrame:EnableMouseWheel(true)
scrollFrame:SetScript("OnMouseWheel", function(self, delta)
    local new = self:GetVerticalScroll() - delta * 25
    new = math.max(0, math.min(new, self:GetVerticalScrollRange()))
    self:SetVerticalScroll(new)
end)

-- BUFFS PANEL
local buffPanel = CreateFrame("Frame", nil, bg, "BackdropTemplate")
buffPanel:SetSize(350, 500)
buffPanel:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 20, 0)

local buffTitle = buffPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
buffTitle:SetPoint("TOPLEFT", 0, 0)
buffTitle:SetText("Raid Buffs / Debuffs")
SlerneNotes.Skin.Title(buffTitle)

local buffDefinitions = {
    {class="DEATHKNIGHT", text="Death Knight - Death Grip (0)"},
    {class="MAGE", text="Mage - Arcane Intellect"},
    {class="WARRIOR", text="Warrior - Battle Shout"},
    {class="PRIEST", text="Priest - Power Word: Fortitude"},
    {class="MONK", text="Monk - Mystic Touch"},
    {class="DEMONHUNTER", text="Demon Hunter - Chaos Brand"},
    {class="PALADIN", text="Paladin - Devotion Aura"},
    {class="DRUID", text="Druid - Mark of the Wild"},
    {class="ROGUE", text="Rogue - Atrophic Poison"},
    {class="HUNTER", text="Hunter - Hunter's Mark (0)"}, -- Hunter Counter Added
    {class="SHAMAN", text="Shaman - Skyfury Totem"},
    {class="WARLOCK", text="Warlock - Healthstone"},
    {class="EVOKER", text="Evoker - Blessing of the Bronze"},
}

local buffFrames = {}
SlerneNotes.activeRows = {}

for i, def in ipairs(buffDefinitions) do
    local bf = CreateFrame("Frame", nil, buffPanel)
    bf:SetSize(350, 25)
    bf:SetPoint("TOPLEFT", 0, -30 - (i-1)*30)
    bf.bg = bf:CreateTexture(nil, "BACKGROUND")
    bf.bg:SetAllPoints(); bf.bg:SetColorTexture(1, 1, 1, 0)
    bf.text = bf:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bf.text:SetPoint("LEFT", 5, 0); bf.text:SetText(def.text)
    bf.classToken = def.class
    buffFrames[def.class] = bf
    bf:SetScript("OnEnter", function(self)
        self.bg:SetColorTexture(1, 1, 1, 0.15)
        for _, row in ipairs(SlerneNotes.activeRows) do
            if row.classToken == self.classToken then row.bg:SetColorTexture(1, 1, 1, 0.1) end
        end
    end)
    bf:SetScript("OnLeave", function(self)
        self.bg:SetColorTexture(1, 1, 1, 0)
        for _, row in ipairs(SlerneNotes.activeRows) do row.bg:SetColorTexture(1, 1, 1, 0) end
    end)
end

-- SUMMARY PANEL
local summaryPanel = CreateFrame("Frame", nil, bg, "BackdropTemplate")
summaryPanel:SetSize(200, 300)
summaryPanel:SetPoint("TOPLEFT", buffPanel, "TOPRIGHT", 20, 0)

local summaryTitle = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
summaryTitle:SetPoint("TOPLEFT", 0, 0)
summaryTitle:SetText("Raid Summary")
SlerneNotes.Skin.Title(summaryTitle)

local summaryTotal = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
summaryTotal:SetPoint("TOPLEFT", 0, -30)

local summaryTanks = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
summaryTanks:SetPoint("TOPLEFT", 0, -55)

local summaryHealers = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
summaryHealers:SetPoint("TOPLEFT", 0, -80)

local summaryMelee = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
summaryMelee:SetPoint("TOPLEFT", 0, -105)

local summaryRanged = summaryPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
summaryRanged:SetPoint("TOPLEFT", 0, -130)


-- FIXED FOOTER & EXIT BUTTON
local footer = CreateFrame("Frame", nil, bg, "BackdropTemplate")
footer:SetHeight(50)
footer:SetPoint("BOTTOMLEFT", bg, "BOTTOMLEFT", 0, 0)
footer:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", 0, 0)
SlerneNotes.Skin.Panel(footer)

local btnCutoff = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
btnCutoff:SetSize(120, 30); btnCutoff:SetPoint("LEFT", 15, 0); btnCutoff:SetText("Add Cutoff")
btnCutoff:SetScript("OnClick", function()
    Data_AddRosterLog(nil, nil, "Cutoff")
end)
SlerneNotes.Skin.Button(btnCutoff)

local btnReset = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
btnReset:SetSize(120, 30); btnReset:SetPoint("LEFT", btnCutoff, "RIGHT", 10, 0); btnReset:SetText("Reset List")
btnReset:SetScript("OnClick", function()
    Data_ClearRosterLog()
end)
SlerneNotes.Skin.Button(btnReset)

local btnExit = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
btnExit:SetSize(100, 30); btnExit:SetPoint("RIGHT", -15, 0); btnExit:SetText("Exit")
btnExit:SetScript("OnClick", function() SlerneNotes.frame:Hide() end)
SlerneNotes.Skin.Button(btnExit)

function SlerneNotes.GetESTTimeString(epoch)
    return date("!%I:%M %p", epoch - 14400) 
end

local rowPool = {}

function SlerneNotes.UpdateRosterList()
    local log = Data_GetRosterLog()
    for _, r in ipairs(rowPool) do r:Hide() end
    wipe(SlerneNotes.activeRows)
    local activeClasses = {}
    local totalHeight = 0
    
    -- Variables for the Summary Panel and Buff trackers
    local totalChecked = 0
    local dkCount = 0
    local hunterCount = 0
    local roleCounts = {tank = 0, healer = 0, melee = 0, ranged = 0}
    
    for i, entry in ipairs(log) do
        local row = rowPool[i]
        if not row then
            row = CreateFrame("Frame", nil, scrollChild)
            row:SetSize(660, 25)
            row.bg = row:CreateTexture(nil, "BACKGROUND")
            row.bg:SetAllPoints(); row.bg:SetColorTexture(1, 1, 1, 0)
            
            -- Checkbox
            row.cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
            row.cb:SetSize(24, 24); row.cb:SetPoint("LEFT", 0, 0); row.cb.rowRef = row
            row.cb:SetScript("OnClick", function(self)
                Data_SetRosterCheck(self.rowRef.index, self:GetChecked())
                SlerneNotes.UpdateRosterList()
            end)
            
            -- Role Button
            row.roleBtn = CreateFrame("Button", nil, row)
            row.roleBtn:SetSize(24, 24); row.roleBtn:SetPoint("LEFT", row.cb, "RIGHT", 5, 0)
            row.roleBtn:RegisterForClicks("RightButtonUp")
            row.roleBtn.icon = row.roleBtn:CreateTexture(nil, "ARTWORK"); row.roleBtn.icon:SetAllPoints()
            row.roleBtn:SetScript("OnClick", function(self, btn)
                if btn == "RightButton" then
                    local roles = {"tank", "healer", "melee", "ranged", "flag", nil}
                    local current = Data_GetRole and Data_GetRole(self.pName) or nil
                    local nextRole = "tank"
                    for idx, r in ipairs(roles) do
                        if r == current then nextRole = roles[idx + 1]; break end
                    end
                    if Data_SetRole then Data_SetRole(self.pName, nextRole) end
                    SlerneNotes.UpdateRosterList()
                end
            end)
            
            -- Guaranteed Spot Button
            row.guaranteeBtn = CreateFrame("Button", nil, row)
            row.guaranteeBtn:SetSize(16, 16)
            row.guaranteeBtn:SetPoint("LEFT", row.roleBtn, "RIGHT", 5, 0)
            row.guaranteeBtn.icon = row.guaranteeBtn:CreateTexture(nil, "ARTWORK")
            row.guaranteeBtn.icon:SetAllPoints()
            row.guaranteeBtn.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_1") -- Yellow Star
            row.guaranteeBtn:SetScript("OnClick", function(self)
                local name = self:GetParent().pName
                SlerneNotes.RaiderFlags.guaranteed[name] = not SlerneNotes.RaiderFlags.guaranteed[name]
                SlerneNotes.UpdateRosterList()
            end)

            -- Inactive Raider Button
            row.inactiveBtn = CreateFrame("Button", nil, row)
            row.inactiveBtn:SetSize(16, 16)
            row.inactiveBtn:SetPoint("LEFT", row.guaranteeBtn, "RIGHT", 5, 0)
            row.inactiveBtn.icon = row.inactiveBtn:CreateTexture(nil, "ARTWORK")
            row.inactiveBtn.icon:SetAllPoints()
            row.inactiveBtn.icon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_7") -- Red X
            row.inactiveBtn:SetScript("OnClick", function(self)
                local name = self:GetParent().pName
                SlerneNotes.RaiderFlags.inactive[name] = not SlerneNotes.RaiderFlags.inactive[name]
                SlerneNotes.UpdateRosterList()
            end)

            -- Text 
            row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            row.text:SetPoint("LEFT", row.inactiveBtn, "RIGHT", 8, 0)
            
            -- Hover Highlight
            row.hover = CreateFrame("Button", nil, row)
            row.hover:SetPoint("TOPLEFT", row.text, "TOPLEFT", -5, 5); row.hover:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", 0, 0)
            row.hover:SetScript("OnEnter", function(self)
                local p = self:GetParent(); p.bg:SetColorTexture(1, 1, 1, 0.1)
                if p.classToken and buffFrames[p.classToken] then buffFrames[p.classToken].bg:SetColorTexture(1, 1, 1, 0.15) end
            end)
            row.hover:SetScript("OnLeave", function(self)
                local p = self:GetParent(); p.bg:SetColorTexture(1, 1, 1, 0)
                if p.classToken and buffFrames[p.classToken] then buffFrames[p.classToken].bg:SetColorTexture(1, 1, 1, 0) end
            end)
            
            rowPool[i] = row
        end
        
        row.index = i; row.classToken = entry.class; row.pName = entry.name
        
        if entry.customText then
            row.cb:Hide(); row.roleBtn:Hide(); row.guaranteeBtn:Hide(); row.inactiveBtn:Hide(); row.hover:Hide(); row.text:SetPoint("LEFT", 0, 0)
            local timeStr = SlerneNotes.GetESTTimeString(entry.time)
            row.text:SetText("|cffaaaaaa---------------------- " .. entry.customText .. " --- [" .. timeStr .. "] ----------------------|r")
        else
            row.cb:Show(); row.roleBtn:Show(); row.guaranteeBtn:Show(); row.inactiveBtn:Show(); row.hover:Show(); row.text:SetPoint("LEFT", row.inactiveBtn, "RIGHT", 8, 0)
            row.cb:SetChecked(entry.checked); row.roleBtn.pName = entry.name
            
            row.roleBtn.icon:SetVertexColor(1, 1, 1, 1); row.roleBtn.icon:SetTexCoord(0, 1, 0, 1)
            
            local role = Data_GetRole and Data_GetRole(entry.name) or nil
            local iconPath = "Interface\\AddOns\\SlerneNotes\\img\\icons\\"
            if role == "tank" then row.roleBtn.icon:SetTexture(iconPath .. "tank.tga")
            elseif role == "healer" then row.roleBtn.icon:SetTexture(iconPath .. "healer.tga")
            elseif role == "melee" then row.roleBtn.icon:SetTexture(iconPath .. "melee.tga")
            elseif role == "ranged" then row.roleBtn.icon:SetTexture(iconPath .. "ranged.tga")
            elseif role == "flag" then row.roleBtn.icon:SetTexture(iconPath .. "flag.tga")
            else row.roleBtn.icon:SetTexture("Interface\\Minimap\\Tracking\\None"); row.roleBtn.icon:SetVertexColor(0.5, 0.5, 0.5, 0.5) end
            
            if SlerneNotes.RaiderFlags.guaranteed[entry.name] then
                row.guaranteeBtn.icon:SetVertexColor(1, 1, 1, 1)
            else
                row.guaranteeBtn.icon:SetVertexColor(0.3, 0.3, 0.3, 0.3)
            end

            local isInactive = SlerneNotes.RaiderFlags.inactive[entry.name]
            if isInactive then
                row.inactiveBtn.icon:SetVertexColor(1, 1, 1, 1)
            else
                row.inactiveBtn.icon:SetVertexColor(0.3, 0.3, 0.3, 0.3)
            end

            if entry.checked and entry.class then activeClasses[entry.class] = true end
            
            -- Count metrics for checked players
            if entry.checked then
                totalChecked = totalChecked + 1
                if entry.class == "DEATHKNIGHT" then
                    dkCount = dkCount + 1
                end
                if entry.class == "HUNTER" then
                    hunterCount = hunterCount + 1
                end
                if role and roleCounts[role] then
                    roleCounts[role] = roleCounts[role] + 1
                end
            end

            local hex = SlerneNotes.GetClassHex(entry.class) or "ffffff"
            if not entry.checked or isInactive then hex = "666666" end 
            
            local timeStr = SlerneNotes.GetESTTimeString(entry.time)
            row.text:SetText(i .. ". |cff" .. hex .. entry.name .. "|r joined at [" .. timeStr .. "]")
            table.insert(SlerneNotes.activeRows, row)
        end
        row:SetPoint("TOPLEFT", 0, -totalHeight); row:Show()
        totalHeight = totalHeight + 25
    end
    
    scrollChild:SetHeight(math.max(totalHeight, 10))
    
    -- Update Counters
    if buffFrames["DEATHKNIGHT"] then
        buffFrames["DEATHKNIGHT"].text:SetText("Death Knight - Death Grip (" .. dkCount .. ")")
    end
    if buffFrames["HUNTER"] then
        buffFrames["HUNTER"].text:SetText("Hunter - Hunter's Mark (" .. hunterCount .. ")")
    end

    -- Update Summary Readout
    summaryTotal:SetText("Total Players: " .. totalChecked)
    summaryTanks:SetText("Tanks: " .. roleCounts.tank)
    summaryHealers:SetText("Healers: " .. roleCounts.healer)
    summaryMelee:SetText("Melee DPS: " .. roleCounts.melee)
    summaryRanged:SetText("Ranged DPS: " .. roleCounts.ranged)

    for class, bf in pairs(buffFrames) do
        if activeClasses[class] then
            local c = SlerneNotes.ClassColors[class]
            if c then bf.text:SetTextColor(c.r, c.g, c.b, 1) else bf.text:SetTextColor(1, 1, 1, 1) end
        else bf.text:SetTextColor(0.3, 0.3, 0.3, 1) end
    end
end