local addonName, SlerneNotes = ...
_G.SlerneNotes = SlerneNotes
local raidRoster = {}
local previousRoster = nil

SlerneNotes.ClassColors = {
    ["DEATHKNIGHT"] = {r=0.77, g=0.12, b=0.23},
    ["DEMONHUNTER"] = {r=0.64, g=0.19, b=0.79},
    ["DRUID"]       = {r=1.00, g=0.49, b=0.04},
    ["EVOKER"]      = {r=0.20, g=0.58, b=0.50},
    ["HUNTER"]      = {r=0.67, g=0.83, b=0.45},
    ["MAGE"]        = {r=0.25, g=0.78, b=0.92},
    ["MONK"]        = {r=0.00, g=1.00, b=0.60},
    ["PALADIN"]     = {r=0.96, g=0.55, b=0.73},
    ["PRIEST"]      = {r=1.00, g=1.00, b=1.00},
    ["ROGUE"]       = {r=1.00, g=0.96, b=0.41},
    ["SHAMAN"]      = {r=0.00, g=0.44, b=0.87},
    ["WARLOCK"]     = {r=0.53, g=0.53, b=0.93},
    ["WARRIOR"]     = {r=0.78, g=0.61, b=0.43},
}

function SlerneNotes.GetClassHex(classToken)
    local c = classToken and SlerneNotes.ClassColors[classToken]
    if c then
        return string.format("%02x%02x%02x", math.floor(c.r*255), math.floor(c.g*255), math.floor(c.b*255))
    end
    return "ffffff"
end

SlerneNotes.frame = CreateFrame("Frame", "SlerneNotesFrame", UIParent)
local frame = SlerneNotes.frame

C_ChatInfo.RegisterAddonMessagePrefix("SlerneNotes")

local VER_PREFIX = "SlerneVer"
C_ChatInfo.RegisterAddonMessagePrefix(VER_PREFIX)
SlerneNotes.viewerVersions = {}

local verReqPending
function SlerneNotes.RequestViewerVersions(delay)
    if verReqPending then verReqPending:Cancel() end
    verReqPending = C_Timer.NewTimer(delay or 1.5, function()
        verReqPending = nil
        local ch, tgt
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then ch = "INSTANCE_CHAT"
        elseif IsInRaid() then ch = "RAID"
        elseif IsInGroup() then ch = "PARTY"
        else ch, tgt = "WHISPER", UnitName("player") end
        C_ChatInfo.SendAddonMessage(VER_PREFIX, "REQ", ch, tgt)
    end)
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("CHAT_MSG_ADDON")

function SlerneNotes:UpdateRaidRoster()
    wipe(raidRoster)

    local numGroup = GetNumGroupMembers()

    if numGroup == 0 then
        local name = UnitName("player")
        if name then
            local shortName = strsplit("-", name)
            local _, classToken = UnitClass("player")
            raidRoster[shortName] = { class = classToken, subgroup = 1 }
        end
    else
        for i = 1, numGroup do
            local name, _, subgroup, _, _, classToken = GetRaidRosterInfo(i)
            if name then
                local shortName = strsplit("-", name)
                raidRoster[shortName] = { class = classToken, subgroup = subgroup }
            end
        end
    end

    if previousRoster == nil then
        previousRoster = {}
        for k, v in pairs(raidRoster) do previousRoster[k] = v end

        local log = Data_GetRosterLog()
        if #log == 0 then
            local pName = UnitName("player")
            if pName then
                local shortName = strsplit("-", pName)
                local _, classToken = UnitClass("player")
                Data_AddRosterLog(shortName, classToken)
            end
        end
    else
        for shortName, data in pairs(raidRoster) do
            if not previousRoster[shortName] then
                Data_AddRosterLog(shortName, data.class)
            end
        end
        wipe(previousRoster)
        for k, v in pairs(raidRoster) do previousRoster[k] = v end
    end

    for name in pairs(SlerneNotes.viewerVersions) do
        if not raidRoster[name] then SlerneNotes.viewerVersions[name] = nil end
    end
    SlerneNotes.RequestViewerVersions()
    if SlerneNotes.RefreshViewerVersions then SlerneNotes.RefreshViewerVersions() end

    if frame:IsShown() then
        if SlerneNotes.UpdateRaidList then SlerneNotes.UpdateRaidList(raidRoster) end
        if SlerneNotes.UpdateModules then SlerneNotes.UpdateModules() end
    end
end

frame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4)
    if event == "ADDON_LOADED" then
        if arg1 == "SlerneNotes" then
            Data_Initialize()

            if SlerneNotes.Skin and SlerneNotes.Skin.RefreshTheme then
                SlerneNotes.Skin.RefreshTheme()
            end
            if SlerneNotes.ApplyPluginVisibility then SlerneNotes.ApplyPluginVisibility() end
            print("Slerne Notes loaded")
        end
    elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        SlerneNotes:UpdateRaidRoster()
    elseif event == "CHAT_MSG_ADDON" then
        if arg1 == VER_PREFIX then
            local tag, ver = strsplit("\t", arg2 or "", 2)
            if tag == "VER" and arg4 then
                local short = strsplit("-", arg4)
                SlerneNotes.viewerVersions[short] = ver or "?"
                if SlerneNotes.RefreshViewerVersions then SlerneNotes.RefreshViewerVersions() end
            end
        end
    end
end)

SLASH_SLERNENOTES1 = "/sn"
SlashCmdList["SLERNENOTES"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        SlerneNotes:UpdateRaidRoster()
        if SlerneNotes.UpdateModules then SlerneNotes.UpdateModules() end
    end
end

function SlerneNotes:GetRoster()
    return raidRoster
end

function SlerneNotes:GetCombinedRoster()
    local combined = {}
    for name, data in pairs(raidRoster) do combined[name] = data end
    local dummies = (Data_GetDummies and Data_GetDummies()) or {}
    for _, d in ipairs(dummies) do
        if d.name and not combined[d.name] then
            combined[d.name] = { class = d.class, subgroup = 0, isDummy = true }
        end
    end
    return combined
end

local function Escape(str)
    if not str then return "" end
    str = tostring(str)
    str = string.gsub(str, "%%", "%%p")
    str = string.gsub(str, ";", "%%s")
    str = string.gsub(str, ":", "%%c")
    str = string.gsub(str, "=", "%%e")
    str = string.gsub(str, "\n", "%%n")
    return str
end

function SlerneNotes.GetExportString()
    local layout = Data_GetCurrentLayout()
    local roster = SlerneNotes:GetRoster()
    local parts = {}

    for modName, modData in pairs(layout) do
        local meta = modData.meta
        local m = {
            Escape(modName), Escape(meta.type), Escape(meta.length),
            Escape(meta.image), Escape(meta.imgW), Escape(meta.imgH),
            Escape(meta.text)
        }

        local labels = {}
        for k, v in pairs(meta.labels or {}) do table.insert(labels, Escape(k).."="..Escape(v)) end
        table.insert(m, table.concat(labels, ","))

        local players = {}
        local classes = {}
        local roles = {}

        for k, v in pairs(modData.players or {}) do
            table.insert(players, Escape(k).."="..Escape(v))
            local pName = (v == true) and k or v

            if roster[pName] and roster[pName].class then
                table.insert(classes, Escape(pName).."="..Escape(roster[pName].class))
            end

            local pRole = Data_GetRole(pName)
            if pRole then
                table.insert(roles, Escape(pName).."="..Escape(pRole))
            end
        end
        table.insert(m, table.concat(players, ","))
        table.insert(m, table.concat(classes, ","))
        table.insert(m, table.concat(roles, ","))

        table.insert(m, Escape(meta.posX))
        table.insert(m, Escape(meta.posY))

        table.insert(m, Escape(meta.fbRows))
        table.insert(m, Escape(meta.fbCols))
        table.insert(m, Escape(meta.fbFrames))
        table.insert(m, Escape(meta.fbFps))

        table.insert(parts, table.concat(m, ":"))
    end
    return table.concat(parts, ";")
end

local function EscDraw(s)
    s = tostring(s or "")
    s = s:gsub("%%", "%%P"):gsub("#", "%%H"):gsub(";", "%%S"):gsub(",", "%%C")
    return s
end

local function ColHex(c)
    c = c or { 1, 1, 1 }
    return string.format("%02x%02x%02x", math.floor(c[1] * 255), math.floor(c[2] * 255), math.floor(c[3] * 255))
end

function SlerneNotes.GetDrawingsExportString()
    if not Data_GetDrawings then return "###" end
    local d = Data_GetDrawings()

    local strokeParts = {}
    for _, stroke in ipairs(d.strokes or {}) do
        local hex = ColHex(stroke.color)
        local a = stroke.alpha or 1
        if a < 0.995 then hex = string.format("%02x", math.floor(a * 255 + 0.5)) .. hex end
        local th = math.floor((stroke.thickness or 3) + 0.5)
        if th ~= 3 then hex = hex .. "," .. th end
        local pts = {}
        for _, p in ipairs(stroke.points or {}) do
            pts[#pts + 1] = math.floor((p[1] or 0) + 0.5) .. "," .. math.floor((p[2] or 0) + 0.5)
        end
        strokeParts[#strokeParts + 1] = hex .. ":" .. table.concat(pts, ":")
    end

    local markerParts = {}
    for _, m in ipairs(d.markers or {}) do
        local s = (m.kind or "marker") .. "," .. tostring(m.icon or 8) .. "," ..
            math.floor((m.x or 0) + 0.5) .. "," .. math.floor((m.y or 0) + 0.5) .. "," ..
            math.floor((m.size or 26) + 0.5)
        local a = m.alpha or 1
        if a < 0.995 then s = s .. "," .. math.floor(a * 100 + 0.5) end
        markerParts[#markerParts + 1] = s
    end

    local textParts = {}
    for _, t in ipairs(d.texts or {}) do
        local hex = ColHex(t.color)
        local a = t.alpha or 1
        if a < 0.995 then hex = string.format("%02x", math.floor(a * 255 + 0.5)) .. hex end
        textParts[#textParts + 1] = hex .. "," ..
            math.floor((t.x or 0) + 0.5) .. "," .. math.floor((t.y or 0) + 0.5) .. "," ..
            math.floor((t.size or 22) + 0.5) .. "," .. EscDraw(t.text)
    end

    local shapeParts = {}
    for _, s in ipairs(d.shapes or {}) do
        shapeParts[#shapeParts + 1] = ColHex(s.color) .. "," ..
            math.floor((s.x or 0) + 0.5) .. "," .. math.floor((s.y or 0) + 0.5) .. "," ..
            math.floor((s.size or 80) + 0.5) .. "," .. math.floor((s.alpha or 1) * 100 + 0.5)
    end

    local lineParts = {}
    for _, ln in ipairs(d.lines or {}) do
        lineParts[#lineParts + 1] = ColHex(ln.color) .. "," ..
            math.floor((ln.x1 or 0) + 0.5) .. "," .. math.floor((ln.y1 or 0) + 0.5) .. "," ..
            math.floor((ln.x2 or 0) + 0.5) .. "," .. math.floor((ln.y2 or 0) + 0.5) .. "," ..
            math.floor((ln.thickness or 3) + 0.5) .. "," .. (ln.arrow and "1" or "0") .. "," ..
            math.floor((ln.alpha or 1) * 100 + 0.5)
    end

    return table.concat(strokeParts, ";") .. "#" .. table.concat(markerParts, ";") .. "#"
        .. table.concat(textParts, ";") .. "#" .. table.concat(shapeParts, ";") .. "#"
        .. table.concat(lineParts, ";")
end

local sendQueue = {}
local sendTicker = nil
local THROTTLE = Enum and Enum.SendAddonMessageResult and Enum.SendAddonMessageResult.AddonMessageThrottle

local BATCH = THROTTLE and 4 or 1

local function drainSendQueue()
    local attempts = 0
    while sendQueue[1] and attempts < BATCH do
        attempts = attempts + 1
        local item = sendQueue[1]
        local res = C_ChatInfo.SendAddonMessage("SlerneNotes", item.msg, item.chatType, item.target)
        if THROTTLE and res == THROTTLE then
            break
        else
            table.remove(sendQueue, 1)
        end
    end
    if not sendQueue[1] then
        if sendTicker then sendTicker:Cancel(); sendTicker = nil end
        print("Slerne Notes: Canvas broadcasted successfully.")
    end
end

function SlerneNotes._QueueBroadcast(list, chatType, target)
    for _, msg in ipairs(list) do
        sendQueue[#sendQueue + 1] = { msg = msg, chatType = chatType, target = target }
    end
    if not sendTicker then
        drainSendQueue()
        if sendQueue[1] then
            sendTicker = C_Timer.NewTicker(0.1, drainSendQueue)
        end
    end
end

function SlerneNotes.BroadcastCanvas()
    local canvasName = Data_GetActiveCanvas() or "Canvas 1"
    local savedPage = Data_GetActivePage()
    local pageCount = math.max(1, Data_GetPageCount())

    local parts = { canvasName, tostring(pageCount) }
    for p = 1, pageCount do
        Data_SetActivePage(p)
        parts[#parts + 1] = SlerneNotes.GetExportString()
        parts[#parts + 1] = SlerneNotes.GetDrawingsExportString()
    end
    Data_SetActivePage(savedPage)
    local fullStr = table.concat(parts, "|")

    local chatType, target
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        chatType = "INSTANCE_CHAT"
    elseif IsInRaid() then
        chatType = "RAID"
    elseif IsInGroup() then
        chatType = "PARTY"
    else
        chatType = "WHISPER"
        target = UnitName("player")
    end

    local maxLen = 240
    local totalChunks = math.ceil(#fullStr / maxLen)
    local msgID = math.random(1000, 9999)

    local list = {}
    for i = 1, totalChunks do
        local chunk = string.sub(fullStr, (i-1)*maxLen + 1, i*maxLen)
        list[i] = string.format("%d:%d:%d:%s", msgID, i, totalChunks, chunk)
    end
    SlerneNotes._QueueBroadcast(list, chatType, target)
    if totalChunks > 8 then
        print(string.format("Slerne Notes: broadcasting canvas (%d parts)...", totalChunks))
    end
end
