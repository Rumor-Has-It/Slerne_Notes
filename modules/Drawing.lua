local addonName, SlerneNotes = ...

local COLORS = {
    {1.00, 1.00, 1.00}, {1.00, 0.20, 0.20}, {1.00, 0.55, 0.10}, {1.00, 0.90, 0.20},
    {0.30, 1.00, 0.35}, {0.30, 0.60, 1.00}, {0.75, 0.40, 1.00}, {0.05, 0.05, 0.05},
}
local SAMPLE_DIST2  = 4 * 4
local LINE_THICKNESS = 3
local MARKER_SIZE   = 26
local TEXT_FONT_SIZE = 22
local CIRCLE_DEFAULT = 80
local CIRCLE_MASK   = "Interface\\Masks\\CircleMaskScalable"
local FONT_FILE     = select(1, GameFontNormal:GetFont())

local ROLE_ICONS   = { "tank", "healer", "melee", "ranged" }
local CLASS_TOKENS = { "WARRIOR", "PALADIN", "DEATHKNIGHT", "HUNTER", "SHAMAN",
                       "ROGUE", "DRUID", "MONK", "DEMONHUNTER", "MAGE",
                       "WARLOCK", "PRIEST", "EVOKER" }
local ROLE_ICON_PATH = "Interface\\AddOns\\SlerneNotes\\img\\icons\\"

local function applyIconTexture(tex, kind, icon)
    if kind == "role" then
        tex:SetTexture(ROLE_ICON_PATH .. tostring(icon) .. ".tga")
        tex:SetTexCoord(0, 1, 0, 1)
    elseif kind == "class" then
        tex:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        local t = CLASS_ICON_TCOORDS[icon]
        if t then tex:SetTexCoord(t[1], t[2], t[3], t[4]) else tex:SetTexCoord(0, 1, 0, 1) end
    elseif kind == "flag" then
        tex:SetTexture(ROLE_ICON_PATH .. "flag.tga")
        tex:SetTexCoord(0, 1, 0, 1)
    elseif kind == "fight" then
        if not icon or icon == "?" then
            tex:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        else
            tex:SetTexture("Interface\\AddOns\\SlerneNotes\\img\\fights\\" .. tostring(icon) .. ".tga")
        end
        tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    elseif kind == "bossicon" then

        tex:SetTexture("Interface\\AddOns\\SlerneNotes\\img\\maps\\base\\" .. tostring(icon))
        tex:SetTexCoord(0, 1, 0, 1)
    else
        tex:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. tostring(icon))
        tex:SetTexCoord(0, 1, 0, 1)
    end
end

local canvas = SlerneNotes.rightPanel

local mode = "off"
local currentColor = { 1, 1, 1 }
local drawing = false
local currentStroke = nil
local setMode

local linePool = {}
local previewPool = {}
local markerPool = {}
local textPool = {}
local shapePool = {}
local lineObjPool = {}

local drawLayer = CreateFrame("Frame", nil, canvas)
drawLayer:SetAllPoints(canvas)
drawLayer:SetFrameLevel(canvas:GetFrameLevel() + 50)
drawLayer:EnableMouse(false)

local function cursorLocal()
    local scale = drawLayer:GetEffectiveScale()
    local cx, cy = GetCursorPosition()
    cx, cy = cx / scale, cy / scale
    local x = cx - drawLayer:GetLeft()
    local y = cy - drawLayer:GetTop()
    local w, h = drawLayer:GetWidth(), drawLayer:GetHeight()
    x = math.max(0, math.min(w, x))
    y = math.max(-h, math.min(0, y))
    return x, y
end

local function previewSeg(i, x1, y1, x2, y2, c)
    local l = previewPool[i]
    if not l then
        l = drawLayer:CreateLine(nil, "OVERLAY")
        previewPool[i] = l
    end
    l:SetThickness(LINE_THICKNESS)
    l:SetColorTexture(c[1], c[2], c[3], 1)
    l:SetStartPoint("TOPLEFT", drawLayer, x1, y1)
    l:SetEndPoint("TOPLEFT", drawLayer, x2, y2)
    l:Show()
end

local function clearPreview()
    for _, l in ipairs(previewPool) do l:Hide() end
end

local function createMarker(idx)
    local m = CreateFrame("Button", nil, drawLayer)
    m:SetSize(MARKER_SIZE, MARKER_SIZE)
    m:SetMovable(true)
    m:EnableMouseWheel(true)
    m:RegisterForDrag("LeftButton")
    m:RegisterForClicks("RightButtonUp")
    m.tex = m:CreateTexture(nil, "OVERLAY")
    m.tex:SetAllPoints()

    if m.tex.SetSnapToPixelGrid then m.tex:SetSnapToPixelGrid(false) end
    if m.tex.SetTexelSnappingBias then m.tex:SetTexelSnappingBias(0) end

    m:SetScript("OnMouseWheel", function(self, delta)
        if mode ~= "off" then return end
        local d = Data_GetDrawings()
        local mk = d.markers[self.index]
        if mk then
            mk.size = math.max(12, math.min(128, (mk.size or MARKER_SIZE) + delta * 3))
            self:SetSize(mk.size, mk.size)
        end
    end)

    m:SetScript("OnDragStart", function(self)
        if mode == "off" then self:StartMoving() end
    end)
    m:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local nx = self:GetLeft() + self:GetWidth() / 2 - drawLayer:GetLeft()
        local ny = self:GetTop() - self:GetHeight() / 2 - drawLayer:GetTop()
        Data_SetMarkerPos(self.index, nx, ny)
        self:ClearAllPoints()
        self:SetPoint("CENTER", drawLayer, "TOPLEFT", nx, ny)
    end)
    m:SetScript("OnClick", function(self, button)
        if button == "RightButton" and mode == "off" then
            Data_RemoveMarker(self.index)
            SlerneNotes.UpdateDrawings()
        end
    end)
    markerPool[idx] = m
    return m
end

local function createTextItem(idx)
    local eb = CreateFrame("EditBox", nil, drawLayer)
    eb:SetAutoFocus(false)
    eb:SetMultiLine(false)
    eb:SetFont(FONT_FILE, TEXT_FONT_SIZE, "OUTLINE")
    eb:SetWidth(180)
    eb:SetHeight(TEXT_FONT_SIZE + 8)
    eb:SetMovable(true)
    eb:EnableMouseWheel(true)
    eb:RegisterForDrag("LeftButton")

    eb:SetScript("OnMouseWheel", function(self, delta)
        if mode ~= "off" then return end
        local d = Data_GetDrawings()
        local t = d.texts[self.index]
        if t then
            t.size = math.max(10, math.min(48, (t.size or TEXT_FONT_SIZE) + delta * 2))
            self:SetFont(FONT_FILE, t.size, "OUTLINE")
            self:SetHeight(t.size + 8)
        end
    end)

    eb:SetScript("OnDragStart", function(self) if mode == "off" then self:StartMoving() end end)
    eb:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local nx = self:GetLeft() - drawLayer:GetLeft()
        local ny = self:GetTop() - drawLayer:GetTop()
        Data_SetTextPos(self.index, nx, ny)
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", drawLayer, "TOPLEFT", nx, ny)
    end)
    eb:SetScript("OnTextChanged", function(self) Data_SetTextValue(self.index, self:GetText()) end)
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    eb:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)

    eb:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            Data_RemoveText(self.index)
            SlerneNotes.UpdateDrawings()
        end
    end)
    eb:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" and mode == "off" then
            Data_RemoveText(self.index)
            SlerneNotes.UpdateDrawings()
        end
    end)
    textPool[idx] = eb
    return eb
end

local function createShape(idx)
    local f = CreateFrame("Frame", nil, drawLayer)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:EnableMouseWheel(true)

    f.fill = f:CreateTexture(nil, "ARTWORK")
    f.fill:SetAllPoints()
    f.fill:SetColorTexture(1, 1, 1, 0.30)
    local mask = f:CreateMaskTexture()
    mask:SetAllPoints(f.fill)
    mask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    f.fill:AddMaskTexture(mask)

    f:SetScript("OnDragStart", function(self) if mode == "off" then self:StartMoving() end end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local nx = self:GetLeft() + self:GetWidth() / 2 - drawLayer:GetLeft()
        local ny = self:GetTop() - self:GetHeight() / 2 - drawLayer:GetTop()
        Data_SetShapePos(self.index, nx, ny)
        self:ClearAllPoints()
        self:SetPoint("CENTER", drawLayer, "TOPLEFT", nx, ny)
    end)
    f:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" and mode == "off" then
            Data_RemoveShape(self.index)
            SlerneNotes.UpdateDrawings()
        end
    end)

    f:SetScript("OnMouseWheel", function(self, delta)
        if mode ~= "off" then return end
        local d = Data_GetDrawings()
        local s = d.shapes[self.index]
        if s then
            s.size = math.max(24, math.min(400, (s.size or CIRCLE_DEFAULT) + delta * 8))
            self:SetSize(s.size, s.size)
        end
    end)
    shapePool[idx] = f
    return f
end

local function arrowBarbs(x1, y1, x2, y2, size)
    local dx, dy = x2 - x1, y2 - y1
    local len = math.sqrt(dx * dx + dy * dy)
    if len < 1 then return x2, y2, x2, y2 end
    local rx, ry = -dx / len, -dy / len
    local ang = math.rad(28)
    local ca, sa = math.cos(ang), math.sin(ang)
    local b1x = x2 + size * (rx * ca - ry * sa)
    local b1y = y2 + size * (rx * sa + ry * ca)
    local b2x = x2 + size * (rx * ca + ry * sa)
    local b2y = y2 + size * (-rx * sa + ry * ca)
    return b1x, b1y, b2x, b2y
end

local function createLineObj(idx)
    local f = CreateFrame("Frame", nil, drawLayer)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:EnableMouseWheel(true)
    f.seg = f:CreateLine(nil, "ARTWORK")
    f.head = f:CreateTexture(nil, "ARTWORK")
    f.head:SetTexture("Interface\\Buttons\\WHITE8x8")
    f.head:SetSize(1, 1)
    f.head:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)

    f:SetScript("OnDragStart", function(self) if mode == "off" then self:StartMoving() end end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local nl = self:GetLeft() - drawLayer:GetLeft()
        local nt = self:GetTop() - drawLayer:GetTop()
        local dx, dy = nl - (self._fl or nl), nt - (self._ft or nt)
        local d = Data_GetDrawings()
        local ln = d.lines[self.index]
        if ln then
            ln.x1 = (ln.x1 or 0) + dx; ln.y1 = (ln.y1 or 0) + dy
            ln.x2 = (ln.x2 or 0) + dx; ln.y2 = (ln.y2 or 0) + dy
        end
        SlerneNotes.UpdateDrawings()
    end)
    f:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" and mode == "off" then
            Data_RemoveLine(self.index)
            SlerneNotes.UpdateDrawings()
        end
    end)

    f:SetScript("OnMouseWheel", function(self, delta)
        if mode ~= "off" then return end
        local d = Data_GetDrawings()
        local ln = d.lines[self.index]
        if ln then
            ln.thickness = math.max(2, math.min(40, (ln.thickness or LINE_THICKNESS) + delta))
            SlerneNotes.UpdateDrawings()
        end
    end)
    lineObjPool[idx] = f
    return f
end

function SlerneNotes.UpdateDrawings()
    if not Data_GetDrawings then return end
    local d = Data_GetDrawings()

    drawLayer:Show()

    if SlerneNotes.RefreshFightPalette then SlerneNotes.RefreshFightPalette() end

    for _, l in ipairs(linePool) do l:Hide() end
    for _, m in ipairs(markerPool) do m:Hide() end
    for _, t in ipairs(textPool) do t:Hide() end
    for _, s in ipairs(shapePool) do s:Hide() end
    for _, l in ipairs(lineObjPool) do l:Hide() end

    local used = 0
    for _, stroke in ipairs(d.strokes) do
        local pts = stroke.points
        local c = stroke.color or { 1, 1, 1 }
        for i = 2, #pts do
            used = used + 1
            local l = linePool[used]
            if not l then
                l = drawLayer:CreateLine(nil, "ARTWORK")
                linePool[used] = l
            end
            l:SetThickness(LINE_THICKNESS)
            l:SetColorTexture(c[1], c[2], c[3], 1)
            l:SetStartPoint("TOPLEFT", drawLayer, pts[i - 1][1], pts[i - 1][2])
            l:SetEndPoint("TOPLEFT", drawLayer, pts[i][1], pts[i][2])
            l:Show()
        end
    end

    for idx, mk in ipairs(d.markers) do
        local m = markerPool[idx] or createMarker(idx)
        m.index = idx
        applyIconTexture(m.tex, mk.kind, mk.icon)
        m:SetSize(mk.size or MARKER_SIZE, mk.size or MARKER_SIZE)
        m:EnableMouse(mode == "off")
        m:EnableMouseWheel(mode == "off")
        m:ClearAllPoints()
        m:SetPoint("CENTER", drawLayer, "TOPLEFT", mk.x or 0, mk.y or 0)
        m:Show()
    end

    for idx, sh in ipairs(d.shapes or {}) do
        local f = shapePool[idx] or createShape(idx)
        f.index = idx
        local c = sh.color or { 1, 1, 1 }
        f.fill:SetColorTexture(c[1], c[2], c[3], 0.30)
        f:SetSize(sh.size or CIRCLE_DEFAULT, sh.size or CIRCLE_DEFAULT)
        f:EnableMouse(mode == "off")
        f:EnableMouseWheel(mode == "off")
        f:ClearAllPoints()
        f:SetPoint("CENTER", drawLayer, "TOPLEFT", sh.x or 0, sh.y or 0)
        f:Show()
    end

    for idx, ln in ipairs(d.lines or {}) do
        local f = lineObjPool[idx] or createLineObj(idx)
        f.index = idx
        local x1, y1, x2, y2 = ln.x1 or 0, ln.y1 or 0, ln.x2 or 0, ln.y2 or 0
        local c = ln.color or { 1, 1, 1 }
        local th = ln.thickness or LINE_THICKNESS
        local hw = math.max(7, th * 1.6)
        local pad = ln.arrow and math.max(8, th, hw) or math.max(8, th)
        local minX, maxX = math.min(x1, x2), math.max(x1, x2)
        local topY, botY = math.max(y1, y2), math.min(y1, y2)
        local fl, ft = minX - pad, topY + pad
        f._fl, f._ft = fl, ft
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", drawLayer, "TOPLEFT", fl, ft)
        f:SetSize((maxX - minX) + 2 * pad, (topY - botY) + 2 * pad)
        f.seg:SetThickness(th)
        f.seg:SetColorTexture(c[1], c[2], c[3], 1)
        f.seg:ClearAllPoints()
        f.seg:SetStartPoint("TOPLEFT", f, x1 - fl, y1 - ft)
        if ln.arrow then
            local dx, dy = x2 - x1, y2 - y1
            local len = math.sqrt(dx * dx + dy * dy)
            if len < 1 then len = 1 end
            local ux, uy = dx / len, dy / len
            local hl = math.min(len * 0.5, math.max(14, th * 3.2))
            local bx, by = x2 - ux * hl, y2 - uy * hl
            local px, py = -uy, ux
            f.seg:SetEndPoint("TOPLEFT", f, bx - fl + ux, by - ft + uy)
            local tipx, tipy = x2 - fl, y2 - ft
            local c1x, c1y = bx + px * hw - fl, by + py * hw - ft
            local c2x, c2y = bx - px * hw - fl, by - py * hw - ft
            f.head:SetVertexColor(c[1], c[2], c[3], 1)
            f.head:SetVertexOffset(1, c1x, c1y)
            f.head:SetVertexOffset(2, c2x, c2y + 1)
            f.head:SetVertexOffset(3, tipx - 1, tipy)
            f.head:SetVertexOffset(4, tipx - 1, tipy + 1)
            f.head:Show()
        else
            f.seg:SetEndPoint("TOPLEFT", f, x2 - fl, y2 - ft)
            f.head:Hide()
        end
        f:EnableMouse(mode == "off")
        f:EnableMouseWheel(mode == "off")
        f:Show()
    end

    for idx, t in ipairs(d.texts or {}) do
        local eb = textPool[idx] or createTextItem(idx)
        eb.index = idx
        eb:SetFont(FONT_FILE, t.size or TEXT_FONT_SIZE, "OUTLINE")
        eb:SetHeight((t.size or TEXT_FONT_SIZE) + 8)
        eb:SetText(t.text or "")
        local c = t.color or { 1, 1, 1 }
        eb:SetTextColor(c[1], c[2], c[3], 1)
        eb:EnableMouse(mode == "off")
        eb:EnableMouseWheel(mode == "off")
        eb:ClearAllPoints()
        eb:SetPoint("TOPLEFT", drawLayer, "TOPLEFT", t.x or 0, t.y or 0)
        eb:Show()
    end
end

local function onDrawUpdate()
    if not drawing or not currentStroke then return end
    local px, py = cursorLocal()
    local pts = currentStroke.points
    if mode == "pencil" then
        local last = pts[#pts]
        local dx, dy = px - last[1], py - last[2]
        if dx * dx + dy * dy >= SAMPLE_DIST2 then
            table.insert(pts, { px, py })
            previewSeg(#pts - 1, last[1], last[2], px, py, currentStroke.color)
        end
    elseif mode == "line" or mode == "arrow" then
        previewSeg(1, pts[1][1], pts[1][2], px, py, currentStroke.color)
    end
end

drawLayer:SetScript("OnMouseDown", function(self, button)
    if button ~= "LeftButton" or mode == "off" then return end
    local px, py = cursorLocal()

    if mode == "text" then
        local idx = Data_AddText(px, py, currentColor)
        setMode("off")
        SlerneNotes.UpdateDrawings()
        local eb = textPool[idx]
        if eb then eb:SetFocus() end
        return
    elseif mode == "circle" then
        Data_AddShape(px, py, CIRCLE_DEFAULT, currentColor)
        setMode("off")
        SlerneNotes.UpdateDrawings()
        return
    end

    drawing = true
    currentStroke = { color = { currentColor[1], currentColor[2], currentColor[3] }, points = { { px, py } } }
    self:SetScript("OnUpdate", onDrawUpdate)
end)
drawLayer:SetScript("OnMouseUp", function(self, button)
    if button ~= "LeftButton" or not drawing then return end
    drawing = false
    self:SetScript("OnUpdate", nil)
    local px, py = cursorLocal()
    if mode == "line" or mode == "arrow" then

        local p1 = currentStroke and currentStroke.points[1]
        local isArrow = (mode == "arrow")
        currentStroke = nil
        clearPreview()
        if p1 and (px ~= p1[1] or py ~= p1[2]) then
            Data_AddLine(p1[1], p1[2], px, py, currentColor, LINE_THICKNESS, isArrow)
        end
        setMode("off")
        SlerneNotes.UpdateDrawings()
        return
    end

    if #currentStroke.points >= 2 then Data_AddStroke(currentStroke) end
    currentStroke = nil
    clearPreview()
    SlerneNotes.UpdateDrawings()
end)

local toolbar = CreateFrame("Frame", nil, SlerneNotes.footer, "BackdropTemplate")
toolbar:SetHeight(34)
toolbar:SetPoint("LEFT", SlerneNotes.footerBossDropdown or SlerneNotes.delPageBtn, "RIGHT", 12, 0)
toolbar:SetFrameLevel(SlerneNotes.footer:GetFrameLevel() + 5)

SlerneNotes.Skin.Panel(toolbar)

local toolButtons = {}
local function refreshToolHighlight()
    for m, b in pairs(toolButtons) do
        if b._activeMark then b._activeMark:SetShown(m == mode) end
    end
end

setMode = function(m)
    mode = m
    drawing = false
    drawLayer:Show()
    drawLayer:SetScript("OnUpdate", nil)
    clearPreview()
    drawLayer:EnableMouse(m ~= "off")
    for _, mk in ipairs(markerPool) do mk:EnableMouse(m == "off"); mk:EnableMouseWheel(m == "off") end
    for _, t in ipairs(textPool) do t:EnableMouse(m == "off"); t:EnableMouseWheel(m == "off") end
    for _, s in ipairs(shapePool) do s:EnableMouse(m == "off"); s:EnableMouseWheel(m == "off") end
    for _, l in ipairs(lineObjPool) do l:EnableMouse(m == "off"); l:EnableMouseWheel(m == "off") end

    if m == "off" then
        SlerneNotes.frame:RegisterForDrag("LeftButton")
    else
        SlerneNotes.frame:RegisterForDrag()
    end
    refreshToolHighlight()
end

local colorSel
local function setColor(c, swatch)
    currentColor = { c[1], c[2], c[3] }
    if colorSel and swatch then
        colorSel:ClearAllPoints()
        colorSel:SetPoint("CENTER", swatch, "CENTER", 0, 0)
        colorSel:Show()
    end
end

local function markActive(b, m)
    local mark = CreateFrame("Frame", nil, b, "BackdropTemplate")
    mark:SetPoint("TOPLEFT", -1, 1)
    mark:SetPoint("BOTTOMRIGHT", 1, -1)
    mark:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 12 })
    mark:SetBackdropBorderColor(1, 0.82, 0.30, 1)
    mark:SetFrameLevel(b:GetFrameLevel() + 4)
    mark:Hide()
    b._activeMark = mark
    toolButtons[m] = b
end

local x = 6
local function toolButton(label, w, m, onClick)
    local b = CreateFrame("Button", nil, toolbar, "UIPanelButtonTemplate")
    b:SetSize(w, 24)
    b:SetPoint("LEFT", x, 0)
    b:SetText(label)
    b:SetScript("OnClick", onClick)
    SlerneNotes.Skin.Button(b)
    if m then markActive(b, m) end
    x = x + w + 3
    return b
end

local function lineToolButton(modeName, withArrow)
    local b = CreateFrame("Button", nil, toolbar, "UIPanelButtonTemplate")
    b:SetSize(26, 24); b:SetPoint("LEFT", x, 0); b:SetText("")
    b:SetScript("OnClick", function() setMode(modeName) end)
    SlerneNotes.Skin.Button(b)
    local seg = b:CreateLine(nil, "OVERLAY")
    seg:SetThickness(2.5)
    seg:SetColorTexture(1, 1, 1, 1)
    seg:SetStartPoint("CENTER", b, -8, -5)
    seg:SetEndPoint("CENTER", b, 8, 5)
    SlerneNotes.Skin.TintTexture(seg)
    if withArrow then
        local b1x, b1y, b2x, b2y = arrowBarbs(-8, -5, 8, 5, 6)
        local h1 = b:CreateLine(nil, "OVERLAY"); h1:SetThickness(2.5); h1:SetColorTexture(1, 1, 1, 1)
        h1:SetStartPoint("CENTER", b, 8, 5); h1:SetEndPoint("CENTER", b, b1x, b1y)
        local h2 = b:CreateLine(nil, "OVERLAY"); h2:SetThickness(2.5); h2:SetColorTexture(1, 1, 1, 1)
        h2:SetStartPoint("CENTER", b, 8, 5); h2:SetEndPoint("CENTER", b, b2x, b2y)
        SlerneNotes.Skin.TintTexture(h1); SlerneNotes.Skin.TintTexture(h2)
    end
    markActive(b, modeName)
    x = x + 26 + 3
    return b
end

local openFlyouts = {}
local function hideFlyouts(except)
    for _, f in ipairs(openFlyouts) do if f ~= except then f:Hide() end end
end

local function placeIcon(kind, icon)
    local cw = drawLayer:GetWidth() or 400
    local ch = drawLayer:GetHeight() or 300
    Data_AddMarker(kind, icon, cw / 2, -ch / 2, MARKER_SIZE)
    setMode("off")
    SlerneNotes.UpdateDrawings()
end

local function makePalette(repKind, repIcon, items, kind, cols)
    local btn = CreateFrame("Button", nil, toolbar)
    btn:SetSize(26, 24)
    btn:SetPoint("LEFT", x, 0)
    btn:EnableMouse(true)
    btn:RegisterForClicks("LeftButtonUp")
    SlerneNotes.Skin.IconBox(btn)
    btn.tex = btn:CreateTexture(nil, "OVERLAY")
    btn.tex:SetSize(18, 18)
    btn.tex:SetPoint("CENTER")
    applyIconTexture(btn.tex, repKind, repIcon)
    x = x + 26 + 3

    local isz, pad = 30, 4
    cols = cols or 4
    local rows = math.ceil(#items / cols)
    local fly = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    fly:SetSize(pad + cols * (isz + pad), pad + rows * (isz + pad))
    fly:SetPoint("BOTTOMLEFT", btn, "TOPLEFT", 0, 6)
    fly:SetFrameStrata("FULLSCREEN_DIALOG")
    fly:SetFrameLevel(toolbar:GetFrameLevel() + 200)
    SlerneNotes.Skin.Panel(fly)
    if fly.SetBackdropColor then fly:SetBackdropColor(0.06, 0.04, 0.08, 1) end
    fly:Hide()
    openFlyouts[#openFlyouts + 1] = fly

    for i, item in ipairs(items) do

        local ikind, iicon = kind, item
        if type(item) == "table" then ikind, iicon = item.kind, item.icon end
        local ib = CreateFrame("Button", nil, fly)
        ib:SetSize(isz, isz)
        local col, row = (i - 1) % cols, math.floor((i - 1) / cols)
        ib:SetPoint("TOPLEFT", pad + col * (isz + pad), -(pad + row * (isz + pad)))
        ib:EnableMouse(true)
        ib:RegisterForClicks("LeftButtonUp")
        local t = ib:CreateTexture(nil, "ARTWORK")
        t:SetAllPoints()
        applyIconTexture(t, ikind, iicon)
        SlerneNotes.Skin.HoverHighlight(ib)
        ib:SetScript("OnClick", function() placeIcon(ikind, iicon); fly:Hide() end)
    end

    btn:SetScript("OnClick", function()
        if fly:IsShown() then fly:Hide() else hideFlyouts(fly); fly:Show() end
    end)
    return btn
end

toolButton("Select", 42, "off", function() setMode("off") end)
toolButton("Pencil", 42, "pencil", function() setMode("pencil") end)
toolButton("Undo", 40, nil, function() Data_RemoveLastStroke(); SlerneNotes.UpdateDrawings() end)

toolButton("Clear", 40, nil, function() SlerneNotes.ShowConfirmClearDrawings() end)

x = x + 5
for _, c in ipairs(COLORS) do
    local sw = CreateFrame("Button", nil, toolbar, "BackdropTemplate")
    sw:SetSize(17, 17)
    sw:SetPoint("LEFT", x, 0)
    sw:EnableMouse(true)
    sw:RegisterForClicks("LeftButtonUp")
    sw:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    sw:SetBackdropColor(c[1], c[2], c[3], 1)
    sw:SetBackdropBorderColor(0, 0, 0, 1)
    sw:SetScript("OnClick", function(self) setColor(c, self) end)
    x = x + 16
end

colorSel = CreateFrame("Frame", nil, toolbar, "BackdropTemplate")
colorSel:SetSize(21, 21)
colorSel:SetBackdrop({ edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 10 })
colorSel:SetBackdropBorderColor(1, 0.82, 0.30, 1)
colorSel:SetFrameLevel(toolbar:GetFrameLevel() + 5)
colorSel:Hide()

x = x + 5
lineToolButton("line", false)
lineToolButton("arrow", true)

local textBtn = CreateFrame("Button", nil, toolbar, "UIPanelButtonTemplate")
textBtn:SetSize(26, 24); textBtn:SetPoint("LEFT", x, 0); textBtn:SetText("")
textBtn:SetScript("OnClick", function() setMode("text") end)
SlerneNotes.Skin.Button(textBtn)
local tGlyph = textBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
tGlyph:SetPoint("CENTER"); tGlyph:SetText("T"); tGlyph:SetTextColor(1, 1, 1, 1)
SlerneNotes.Skin.TintTexture(tGlyph)
markActive(textBtn, "text")
x = x + 28 + 4

local circBtn = CreateFrame("Button", nil, toolbar, "UIPanelButtonTemplate")
circBtn:SetSize(26, 24); circBtn:SetPoint("LEFT", x, 0); circBtn:SetText("")
circBtn:SetScript("OnClick", function() setMode("circle") end)
SlerneNotes.Skin.Button(circBtn)
local cIco = circBtn:CreateTexture(nil, "OVERLAY")
cIco:SetSize(14, 14); cIco:SetPoint("CENTER")
cIco:SetColorTexture(1, 1, 1, 0.95)
SlerneNotes.Skin.TintTexture(cIco)
local cMask = circBtn:CreateMaskTexture()
cMask:SetAllPoints(cIco)
cMask:SetTexture(CIRCLE_MASK, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
cIco:AddMaskTexture(cMask)
markActive(circBtn, "circle")
x = x + 28 + 4

x = x + 5

local fightBtn, fightFly
local fightItemPool = {}
do
    fightBtn = CreateFrame("Button", nil, toolbar)
    fightBtn:SetSize(26, 24)
    fightBtn:SetPoint("LEFT", x, 0)
    fightBtn:EnableMouse(true)
    fightBtn:RegisterForClicks("LeftButtonUp")
    SlerneNotes.Skin.IconBox(fightBtn)
    fightBtn.tex = fightBtn:CreateTexture(nil, "OVERLAY")
    fightBtn.tex:SetSize(18, 18)
    fightBtn.tex:SetPoint("CENTER")
    applyIconTexture(fightBtn.tex, "fight", "?")
    x = x + 26 + 3

    fightFly = CreateFrame("Frame", nil, fightBtn, "BackdropTemplate")
    fightFly:SetFrameStrata("FULLSCREEN_DIALOG")
    fightFly:SetFrameLevel(toolbar:GetFrameLevel() + 200)
    fightFly:SetPoint("BOTTOMLEFT", fightBtn, "TOPLEFT", 0, 6)
    SlerneNotes.Skin.Panel(fightFly)
    if fightFly.SetBackdropColor then fightFly:SetBackdropColor(0.06, 0.04, 0.08, 1) end
    fightFly:Hide()
    openFlyouts[#openFlyouts + 1] = fightFly

    fightBtn:SetScript("OnClick", function()
        if fightFly:IsShown() then fightFly:Hide() else hideFlyouts(fightFly); fightFly:Show() end
    end)
end

local lastFightBoss = "\0"
function SlerneNotes.RefreshFightPalette(force)
    if not fightBtn then return end
    local boss = (Data_GetCanvasBoss and Data_GetCanvasBoss()) or nil
    if not force and boss == lastFightBoss then return end
    lastFightBoss = boss

    local info = boss and SlerneNotes.GetBossIcons and SlerneNotes.GetBossIcons(boss) or nil

    local items = {}
    if info then
        for _, rel in ipairs(info.list) do items[#items + 1] = { kind = "bossicon", icon = rel } end
        applyIconTexture(fightBtn.tex, "bossicon", info.preview)
    else
        for _, ic in ipairs(SlerneNotes.FightIcons or {}) do items[#items + 1] = { kind = "fight", icon = ic } end
        applyIconTexture(fightBtn.tex, "fight", "?")
    end

    for _, ib in ipairs(fightItemPool) do ib:Hide() end

    local isz, pad, cols = 30, 4, 4
    local n = #items
    local rows = math.max(1, math.ceil((n > 0 and n or 1) / cols))
    fightFly:SetSize(pad + cols * (isz + pad), pad + rows * (isz + pad))

    for i, item in ipairs(items) do
        local ib = fightItemPool[i]
        if not ib then
            ib = CreateFrame("Button", nil, fightFly)
            ib:SetSize(isz, isz)
            ib:EnableMouse(true)
            ib:RegisterForClicks("LeftButtonUp")
            ib.tex = ib:CreateTexture(nil, "ARTWORK")
            ib.tex:SetAllPoints()
            SlerneNotes.Skin.HoverHighlight(ib)
            fightItemPool[i] = ib
        end
        local col, row = (i - 1) % cols, math.floor((i - 1) / cols)
        ib:ClearAllPoints()
        ib:SetPoint("TOPLEFT", pad + col * (isz + pad), -(pad + row * (isz + pad)))
        applyIconTexture(ib.tex, item.kind, item.icon)
        ib:SetScript("OnClick", function() placeIcon(item.kind, item.icon); fightFly:Hide() end)
        ib:Show()
    end
end

makePalette("marker", 8, { 1, 2, 3, 4, 5, 6, 7, 8 }, "marker", 4)

makePalette("role", "tank", { "tank", "healer", "melee", "ranged", { kind = "flag", icon = "flag" } }, "role", 5)

local classItems = {}
for _, t in ipairs(CLASS_TOKENS) do classItems[#classItems + 1] = t end
classItems[#classItems + 1] = { kind = "role", icon = "GateGreen" }
classItems[#classItems + 1] = { kind = "role", icon = "GatePurple" }
makePalette("class", "WARRIOR", classItems, "class", 5)

toolbar:SetWidth(x + 6)

setColor(COLORS[1])
setMode("off")

SlerneNotes.RefreshFightPalette(true)
