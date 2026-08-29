local addonName, SlerneNotes = ...
SlerneNotesDB = SlerneNotesDB or {}

function Data_Initialize()
    if SlerneNotesDB.profiles then
        SlerneNotesDB.canvases = SlerneNotesDB.profiles
        SlerneNotesDB.profiles = nil
    end
    if SlerneNotesDB.activeProfile then
        SlerneNotesDB.activeCanvas = SlerneNotesDB.activeProfile
        SlerneNotesDB.activeProfile = nil
    end

    if not SlerneNotesDB.canvases then
        SlerneNotesDB.canvases = {}
    end
    if not SlerneNotesDB.activeCanvas then
        SlerneNotesDB.activeCanvas = "Canvas 1"
    end
    if not SlerneNotesDB.canvases[SlerneNotesDB.activeCanvas] then
        SlerneNotesDB.canvases[SlerneNotesDB.activeCanvas] = {}
    end

    if SlerneNotesDB.attendanceLog then
        SlerneNotesDB.rosterLog = SlerneNotesDB.attendanceLog
        SlerneNotesDB.attendanceLog = nil
    end
    if not SlerneNotesDB.rosterLog then SlerneNotesDB.rosterLog = {} end
    if not SlerneNotesDB.playerRoles then SlerneNotesDB.playerRoles = {} end

    if not SlerneNotesDB.dummyPlayers then SlerneNotesDB.dummyPlayers = {} end

    if not SlerneNotesDB.drawings then SlerneNotesDB.drawings = {} end
    if not SlerneNotesDB.activePage then SlerneNotesDB.activePage = 1 end

    if SlerneNotesDB.reminderCanvases then
        SlerneNotesDB.registryCanvases = SlerneNotesDB.reminderCanvases
        SlerneNotesDB.reminderCanvases = nil
    end
    if SlerneNotesDB.activeReminderCanvas then
        SlerneNotesDB.activeRegistryCanvas = SlerneNotesDB.activeReminderCanvas
        SlerneNotesDB.activeReminderCanvas = nil
    end

    if not SlerneNotesDB.registryCanvases then SlerneNotesDB.registryCanvases = {} end
    if not SlerneNotesDB.activeRegistryCanvas then SlerneNotesDB.activeRegistryCanvas = "Registries 1" end
    if not SlerneNotesDB.registryCanvases[SlerneNotesDB.activeRegistryCanvas] then
        SlerneNotesDB.registryCanvases[SlerneNotesDB.activeRegistryCanvas] = {}
    end
    for _, layout in pairs(SlerneNotesDB.registryCanvases) do
        for _, mod in pairs(layout) do
            if mod.type == "Stopwatch" then mod.type = "Manual" end
        end
    end

    if not SlerneNotesDB.hiddenPlugins then SlerneNotesDB.hiddenPlugins = {} end
end

function Data_GetHiddenPlugins()
    if not SlerneNotesDB.hiddenPlugins then SlerneNotesDB.hiddenPlugins = {} end
    return SlerneNotesDB.hiddenPlugins
end

function Data_SetPluginHidden(key, hidden)
    Data_GetHiddenPlugins()[key] = hidden and true or nil
end

local MAX_PAGES = 8

local function ensurePages(c)
    if not c.pages then
        local old = {}
        for k, v in pairs(c) do old[k] = v end
        wipe(c)
        c.pages = { [1] = old }
    end
    if not c.pages[1] then c.pages[1] = {} end
    return c.pages
end

local function ensureDrawingPages(d)
    if not d.pages then
        local old = { strokes = d.strokes, markers = d.markers, texts = d.texts, shapes = d.shapes }
        wipe(d)
        d.pages = { [1] = old }
    end
    if not d.pages[1] then d.pages[1] = {} end
    return d.pages
end

local sanitizedLayouts = setmetatable({}, { __mode = "k" })

function Data_GetCurrentLayout()
    local c = SlerneNotesDB.canvases[SlerneNotesDB.activeCanvas]
    if not c then return nil end
    local pages = ensurePages(c)
    local p = SlerneNotesDB.activePage or 1
    if not pages[p] then p = 1; SlerneNotesDB.activePage = 1 end
    if not pages[p] then pages[p] = {} end
    local layout = pages[p]
    if sanitizedLayouts[layout] then return layout end
    do
        local cascadeX = 20
        local cascadeY = -20

        for k, v in pairs(layout) do
            if not v.meta then
                local oldPlayers = v
                layout[k] = {
                    meta = { type = "Assignment", length = 0, labels = {}, image = "", imgW = 400, imgH = 300, text = "", posX = cascadeX, posY = cascadeY },
                    players = oldPlayers
                }
                v = layout[k]
                cascadeX = cascadeX + 30
                cascadeY = cascadeY - 30
            end
            if not v.meta.imgW then
                v.meta.imgW = 400
                v.meta.imgH = 300
            end
            if not v.meta.text then
                v.meta.text = ""
            end

            if not v.meta.posX then
                v.meta.posX = cascadeX
                v.meta.posY = cascadeY
                cascadeX = cascadeX + 40
                cascadeY = cascadeY - 40
            end

            if v.players then
                local sanitizedPlayers = {}
                for pKey, pVal in pairs(v.players) do
                    if type(pKey) == "string" then
                        local shortKey = strsplit("-", pKey)
                        sanitizedPlayers[shortKey] = pVal
                    elseif type(pKey) == "number" and type(pVal) == "string" then
                        local shortVal = strsplit("-", pVal)
                        sanitizedPlayers[pKey] = shortVal
                    else
                        sanitizedPlayers[pKey] = pVal
                    end
                end
                v.players = sanitizedPlayers
            end
        end
    end
    sanitizedLayouts[layout] = true
    return layout
end

function Data_GetCanvases() return SlerneNotesDB.canvases end
function Data_GetActiveCanvas() return SlerneNotesDB.activeCanvas end

function Data_SetCanvas(canvasName)
    if not canvasName or canvasName == "" then return end
    SlerneNotesDB.activeCanvas = canvasName
    if not SlerneNotesDB.canvases[canvasName] then
        SlerneNotesDB.canvases[canvasName] = { pages = { [1] = {} } }
    end
    SlerneNotesDB.activePage = 1
end

function Data_SetCanvasBoss(name, bossFile)
    if not SlerneNotesDB.canvases then return end
    name = name or SlerneNotesDB.activeCanvas
    local c = name and SlerneNotesDB.canvases[name]
    if not c then return end
    ensurePages(c)
    c.boss = bossFile
end

function Data_GetCanvasBoss(name)
    if not SlerneNotesDB.canvases then return nil end
    name = name or SlerneNotesDB.activeCanvas
    local c = name and SlerneNotesDB.canvases[name]
    return c and c.boss or nil
end

function Data_DeleteCanvas(canvasName)
    if not canvasName then return end
    SlerneNotesDB.canvases[canvasName] = nil
    if SlerneNotesDB.drawings then SlerneNotesDB.drawings[canvasName] = nil end
    if SlerneNotesDB.activeCanvas == canvasName then
        local nextCanvas = next(SlerneNotesDB.canvases)
        if not nextCanvas then
            nextCanvas = "Canvas 1"
            SlerneNotesDB.canvases[nextCanvas] = { pages = { [1] = {} } }
        end
        SlerneNotesDB.activeCanvas = nextCanvas
    end
    SlerneNotesDB.activePage = 1
end

function Data_IsCanvasArchived(name)
    name = name or SlerneNotesDB.activeCanvas
    local c = name and SlerneNotesDB.canvases and SlerneNotesDB.canvases[name]
    return (c and c.archived) and true or false
end

function Data_SetCanvasArchived(name, flag)
    if not (name and SlerneNotesDB.canvases) then return end
    local c = SlerneNotesDB.canvases[name]
    if not c then return end
    c.archived = flag and true or nil
end

function Data_GetActivePage() return SlerneNotesDB.activePage or 1 end

function Data_GetPageCount(name)
    name = name or SlerneNotesDB.activeCanvas
    local c = name and SlerneNotesDB.canvases[name]
    if not c then return 0 end
    return #ensurePages(c)
end

function Data_SetActivePage(n)
    local count = Data_GetPageCount()
    if count == 0 then return end
    SlerneNotesDB.activePage = math.max(1, math.min(count, n or 1))
end

function Data_AddPage()
    local c = SlerneNotesDB.canvases[SlerneNotesDB.activeCanvas]
    if not c then return end
    local pages = ensurePages(c)
    if #pages >= MAX_PAGES then return #pages end
    pages[#pages + 1] = {}

    local d = SlerneNotesDB.drawings[SlerneNotesDB.activeCanvas]
    if not d then d = {}; SlerneNotesDB.drawings[SlerneNotesDB.activeCanvas] = d end
    local dpages = ensureDrawingPages(d)
    dpages[#pages] = dpages[#pages] or { strokes = {}, markers = {}, texts = {}, shapes = {} }
    SlerneNotesDB.activePage = #pages
    return #pages
end

function Data_DeletePage(n)
    local c = SlerneNotesDB.canvases[SlerneNotesDB.activeCanvas]
    if not c then return end
    local pages = ensurePages(c)
    if #pages <= 1 then return end
    n = n or SlerneNotesDB.activePage or 1
    if n < 1 or n > #pages then return end
    table.remove(pages, n)
    local d = SlerneNotesDB.drawings[SlerneNotesDB.activeCanvas]
    if d then
        local dpages = ensureDrawingPages(d)
        if n <= #dpages then table.remove(dpages, n) end
    end
    SlerneNotesDB.activePage = math.max(1, math.min(#pages, SlerneNotesDB.activePage or 1))
end

function Data_AddModule(name, modType, length, imagePath, imgW, imgH)
    local layout = Data_GetCurrentLayout()
    if layout then
        layout[name] = {
            meta = {
                type = modType or "Assignment",
                length = tonumber(length) or 0,
                labels = {},
                image = imagePath or "",
                imgW = tonumber(imgW) or 400,
                imgH = tonumber(imgH) or 300,
                text = "",
                posX = 1000,
                posY = -600
            },
            players = {}
        }
    end
end

function Data_SetModulePosition(name, x, y)
    local layout = Data_GetCurrentLayout()
    if layout and layout[name] then
        layout[name].meta.posX = x
        layout[name].meta.posY = y
    end
end

function Data_SetImagePath(module, path)
    local layout = Data_GetCurrentLayout()
    if layout and layout[module] then layout[module].meta.image = path end
end

function Data_SetModuleImage(module, path, w, h)
    local layout = Data_GetCurrentLayout()
    if layout and layout[module] then
        local m = layout[module].meta
        m.image = path or ""
        if w and w > 0 then m.imgW = w end
        if h and h > 0 then m.imgH = h end
    end
end

function Data_SetModuleFlipbook(module, path, w, h, rows, cols, frames, fps)
    local layout = Data_GetCurrentLayout()
    if not (layout and layout[module]) then return end
    local m = layout[module].meta
    m.image = path or ""
    if w and w > 0 then m.imgW = w end
    if h and h > 0 then m.imgH = h end
    m.fbRows = tonumber(rows) or nil
    m.fbCols = tonumber(cols) or nil
    m.fbFrames = tonumber(frames) or nil
    m.fbFps = tonumber(fps) or nil
end

function Data_SetReminderText(module, text)
    local layout = Data_GetCurrentLayout()
    if layout and layout[module] then layout[module].meta.text = text end
end

function Data_RemoveModule(name)
    local layout = Data_GetCurrentLayout()
    if layout and layout[name] then layout[name] = nil end
end

function Data_RenameModule(oldName, newName)
    if not oldName or not newName then return end
    newName = strtrim(newName)
    if newName == "" or newName == oldName then return end
    local layout = Data_GetCurrentLayout()
    if not layout or not layout[oldName] or layout[newName] then return end
    layout[newName] = layout[oldName]
    layout[oldName] = nil
end

function Data_SetModuleLength(name, length)
    local layout = Data_GetCurrentLayout()
    if layout and layout[name] then
        layout[name].meta.length = math.max(0, tonumber(length) or 0)
    end
end

function Data_SetModuleAllowDup(name, allow)
    local layout = Data_GetCurrentLayout()
    if layout and layout[name] then
        layout[name].meta.allowDup = allow and true or false
    end
end

function Data_Assign(player, module, slotIndex)
    local layout = Data_GetCurrentLayout()
    if layout and layout[module] then
        local modData = layout[module]
        local t = modData.meta.type
        if t == "Action List" or t == "List" or t == "Image List" then

            if not modData.meta.allowDup then
                for k, v in pairs(modData.players) do
                    if v == player then modData.players[k] = nil end
                end
            end
            if slotIndex then modData.players[slotIndex] = player end
        else
            modData.players[player] = true
        end
    end
end

function Data_RemoveSlot(module, slotKey)
    local layout = Data_GetCurrentLayout()
    if layout and layout[module] and slotKey ~= nil then
        layout[module].players[slotKey] = nil
    end
end

function Data_Remove(player, module)
    local layout = Data_GetCurrentLayout()
    if layout and layout[module] then
        local modData = layout[module]
        if modData.meta.type == "List" or modData.meta.type == "Image List" or modData.meta.type == "Action List" then
            for k, v in pairs(modData.players) do
                if v == player then modData.players[k] = nil end
            end
        else
            modData.players[player] = nil
        end
    end
end

function Data_SetLabel(module, slotIndex, text)
    local layout = Data_GetCurrentLayout()
    if layout and layout[module] then layout[module].meta.labels[slotIndex] = text end
end

function Data_AddRosterLog(name, classToken, customText)
    if not SlerneNotesDB.rosterLog then SlerneNotesDB.rosterLog = {} end

    if name and not customText then
        for _, entry in ipairs(SlerneNotesDB.rosterLog) do
            if entry.name == name then return end
        end
    end

    table.insert(SlerneNotesDB.rosterLog, {
        name = name,
        class = classToken,
        customText = customText,
        time = GetServerTime(),
        checked = true
    })

    if #SlerneNotesDB.rosterLog >= 100 then
        Data_ClearRosterLog()
        return
    end

    if SlerneNotes.UpdateRosterList then SlerneNotes.UpdateRosterList() end
end

function Data_GetRosterLog()
    local log = SlerneNotesDB.rosterLog or {}
    for _, entry in ipairs(log) do
        if entry.checked == nil then entry.checked = true end
    end
    return log
end

function Data_SetRosterCheck(index, isChecked)
    if SlerneNotesDB.rosterLog and SlerneNotesDB.rosterLog[index] then
        SlerneNotesDB.rosterLog[index].checked = isChecked
    end
end

function Data_ClearRosterLog()
    SlerneNotesDB.rosterLog = {}

    local pName = UnitName("player")
    if pName then
        local shortName = strsplit("-", pName)
        local _, classToken = UnitClass("player")
        Data_AddRosterLog(shortName, classToken)
    end

    if SlerneNotes.UpdateRosterList then SlerneNotes.UpdateRosterList() end
end

function Data_SetRole(player, role)
    if not SlerneNotesDB.playerRoles then SlerneNotesDB.playerRoles = {} end
    SlerneNotesDB.playerRoles[player] = role
end

function Data_GetRole(player)
    if not SlerneNotesDB.playerRoles then return nil end
    return SlerneNotesDB.playerRoles[player]
end

function Data_GetDummies()
    if not SlerneNotesDB.dummyPlayers then SlerneNotesDB.dummyPlayers = {} end
    return SlerneNotesDB.dummyPlayers
end

function Data_AddDummy(name, classToken)
    if not name or strtrim(name) == "" then return end
    name = strtrim(name)
    local list = Data_GetDummies()
    for _, d in ipairs(list) do
        if d.name == name then return end
    end
    table.insert(list, { name = name, class = classToken })
end

function Data_RemoveDummy(name)
    local list = Data_GetDummies()
    for i, d in ipairs(list) do
        if d.name == name then
            table.remove(list, i)
            return
        end
    end
end

function Data_GetDrawings()
    if not SlerneNotesDB.drawings then SlerneNotesDB.drawings = {} end
    local cname = SlerneNotesDB.activeCanvas or "Canvas 1"
    local d = SlerneNotesDB.drawings[cname]
    if not d then d = {}; SlerneNotesDB.drawings[cname] = d end
    local pages = ensureDrawingPages(d)
    local p = SlerneNotesDB.activePage or 1
    if not pages[p] then pages[p] = {} end
    local dd = pages[p]
    if not dd.strokes then dd.strokes = {} end
    if not dd.markers then dd.markers = {} end
    if not dd.texts then dd.texts = {} end
    if not dd.shapes then dd.shapes = {} end
    if not dd.lines then dd.lines = {} end
    return dd
end

function Data_AddStroke(stroke)
    if stroke then table.insert(Data_GetDrawings().strokes, stroke) end
end

function Data_RemoveStroke(index)
    local d = Data_GetDrawings()
    if d.strokes[index] then table.remove(d.strokes, index) end
end

function Data_AddMarker(kind, icon, x, y, size)
    local d = Data_GetDrawings()
    table.insert(d.markers, { kind = kind or "marker", icon = icon, x = x, y = y, size = size or 26 })
    return #d.markers
end

function Data_SetMarkerPos(index, x, y)
    local d = Data_GetDrawings()
    if d.markers[index] then
        d.markers[index].x = x
        d.markers[index].y = y
    end
end

function Data_SetMarkerSize(index, size)
    local d = Data_GetDrawings()
    if d.markers[index] then d.markers[index].size = size end
end

function Data_RemoveMarker(index)
    local d = Data_GetDrawings()
    if d.markers[index] then table.remove(d.markers, index) end
end

function Data_AddText(x, y, color, size)
    local d = Data_GetDrawings()
    table.insert(d.texts, { text = "", x = x, y = y, size = size or 22, color = { color[1], color[2], color[3] } })
    return #d.texts
end

function Data_SetTextValue(index, text)
    local d = Data_GetDrawings()
    if d.texts[index] then d.texts[index].text = text end
end

function Data_SetTextSize(index, size)
    local d = Data_GetDrawings()
    if d.texts[index] then d.texts[index].size = size end
end

function Data_SetTextPos(index, x, y)
    local d = Data_GetDrawings()
    if d.texts[index] then d.texts[index].x = x; d.texts[index].y = y end
end

function Data_RemoveText(index)
    local d = Data_GetDrawings()
    if d.texts[index] then table.remove(d.texts, index) end
end

function Data_AddShape(x, y, size, color)
    local d = Data_GetDrawings()
    table.insert(d.shapes, { x = x, y = y, size = size or 80, color = { color[1], color[2], color[3] } })
    return #d.shapes
end

function Data_SetShapePos(index, x, y)
    local d = Data_GetDrawings()
    if d.shapes[index] then d.shapes[index].x = x; d.shapes[index].y = y end
end

function Data_SetShapeSize(index, size)
    local d = Data_GetDrawings()
    if d.shapes[index] then d.shapes[index].size = size end
end

function Data_RemoveShape(index)
    local d = Data_GetDrawings()
    if d.shapes[index] then table.remove(d.shapes, index) end
end

function Data_AddLine(x1, y1, x2, y2, color, thickness, arrow)
    local d = Data_GetDrawings()
    table.insert(d.lines, { x1 = x1, y1 = y1, x2 = x2, y2 = y2,
        thickness = thickness or 3, color = { color[1], color[2], color[3] }, arrow = arrow or false })
    return #d.lines
end

function Data_SetLineThickness(index, t)
    local d = Data_GetDrawings()
    if d.lines[index] then d.lines[index].thickness = t end
end

function Data_RemoveLine(index)
    local d = Data_GetDrawings()
    if d.lines[index] then table.remove(d.lines, index) end
end

function Data_GetRegistryLayout()
    return SlerneNotesDB.registryCanvases[SlerneNotesDB.activeRegistryCanvas]
end

function Data_GetRegistryCanvases() return SlerneNotesDB.registryCanvases end
function Data_GetActiveRegistryCanvas() return SlerneNotesDB.activeRegistryCanvas end

function Data_SetRegistryCanvas(name)
    if not name or name == "" then return end
    SlerneNotesDB.activeRegistryCanvas = name
    if not SlerneNotesDB.registryCanvases[name] then
        SlerneNotesDB.registryCanvases[name] = {}
    end
end

function Data_DeleteRegistryCanvas(name)
    if not name then return end
    SlerneNotesDB.registryCanvases[name] = nil
    if SlerneNotesDB.activeRegistryCanvas == name then
        local nextC = next(SlerneNotesDB.registryCanvases)
        if not nextC then
            nextC = "Registries 1"
            SlerneNotesDB.registryCanvases[nextC] = {}
        end
        SlerneNotesDB.activeRegistryCanvas = nextC
    end
end

function Data_AddRegistryModule(name, regType)
    local layout = Data_GetRegistryLayout()
    if layout then

        layout[name] = { text = "", posX = 1400, posY = -650, type = regType or "Manual" }
    end
end

function Data_RemoveRegistryModule(name)
    local layout = Data_GetRegistryLayout()
    if layout and layout[name] then layout[name] = nil end
end

function Data_SetRegistryModuleText(name, text)
    local layout = Data_GetRegistryLayout()
    if layout and layout[name] then layout[name].text = text end
end

function Data_SetRegistryModulePos(name, x, y)
    local layout = Data_GetRegistryLayout()
    if layout and layout[name] then
        layout[name].posX = x
        layout[name].posY = y
    end
end

_G.Data_Initialize = Data_Initialize
_G.Data_GetHiddenPlugins = Data_GetHiddenPlugins
_G.Data_SetPluginHidden = Data_SetPluginHidden
_G.Data_AddModule = Data_AddModule
_G.Data_RemoveModule = Data_RemoveModule
_G.Data_RenameModule = Data_RenameModule
_G.Data_SetModuleLength = Data_SetModuleLength
_G.Data_SetModuleAllowDup = Data_SetModuleAllowDup
_G.Data_Assign = Data_Assign
_G.Data_Remove = Data_Remove
_G.Data_RemoveSlot = Data_RemoveSlot
_G.Data_SetLabel = Data_SetLabel
_G.Data_GetCurrentLayout = Data_GetCurrentLayout
_G.Data_SetCanvas = Data_SetCanvas
_G.Data_GetCanvases = Data_GetCanvases
_G.Data_GetActiveCanvas = Data_GetActiveCanvas
_G.Data_DeleteCanvas = Data_DeleteCanvas
_G.Data_SetCanvasBoss = Data_SetCanvasBoss
_G.Data_GetCanvasBoss = Data_GetCanvasBoss
_G.Data_GetActivePage = Data_GetActivePage
_G.Data_GetPageCount = Data_GetPageCount
_G.Data_SetActivePage = Data_SetActivePage
_G.Data_AddPage = Data_AddPage
_G.Data_DeletePage = Data_DeletePage
_G.Data_SetImagePath = Data_SetImagePath
_G.Data_SetModuleImage = Data_SetModuleImage
_G.Data_SetReminderText = Data_SetReminderText
_G.Data_AddRosterLog = Data_AddRosterLog
_G.Data_GetRosterLog = Data_GetRosterLog
_G.Data_SetRosterCheck = Data_SetRosterCheck
_G.Data_ClearRosterLog = Data_ClearRosterLog
_G.Data_SetModulePosition = Data_SetModulePosition
_G.Data_SetRole = Data_SetRole
_G.Data_GetRole = Data_GetRole
_G.Data_GetDummies = Data_GetDummies
_G.Data_AddDummy = Data_AddDummy
_G.Data_RemoveDummy = Data_RemoveDummy
_G.Data_GetDrawings = Data_GetDrawings
_G.Data_AddStroke = Data_AddStroke
_G.Data_RemoveStroke = Data_RemoveStroke
_G.Data_AddMarker = Data_AddMarker
_G.Data_SetMarkerPos = Data_SetMarkerPos
_G.Data_SetMarkerSize = Data_SetMarkerSize
_G.Data_RemoveMarker = Data_RemoveMarker
_G.Data_AddText = Data_AddText
_G.Data_SetTextValue = Data_SetTextValue
_G.Data_SetTextSize = Data_SetTextSize
_G.Data_SetTextPos = Data_SetTextPos
_G.Data_RemoveText = Data_RemoveText
_G.Data_AddLine = Data_AddLine
_G.Data_SetLineThickness = Data_SetLineThickness
_G.Data_RemoveLine = Data_RemoveLine
_G.Data_AddShape = Data_AddShape
_G.Data_SetShapePos = Data_SetShapePos
_G.Data_SetShapeSize = Data_SetShapeSize
_G.Data_RemoveShape = Data_RemoveShape
_G.Data_GetRegistryLayout = Data_GetRegistryLayout
_G.Data_GetRegistryCanvases = Data_GetRegistryCanvases
_G.Data_GetActiveRegistryCanvas = Data_GetActiveRegistryCanvas
_G.Data_SetRegistryCanvas = Data_SetRegistryCanvas
_G.Data_DeleteRegistryCanvas = Data_DeleteRegistryCanvas
_G.Data_AddRegistryModule = Data_AddRegistryModule
_G.Data_RemoveRegistryModule = Data_RemoveRegistryModule
_G.Data_SetRegistryModuleText = Data_SetRegistryModuleText
_G.Data_SetRegistryModulePos = Data_SetRegistryModulePos
