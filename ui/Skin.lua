local addonName, SlerneNotes = ...

local Theme = {

    windowTop    = {0.14, 0.07, 0.10, 0.96},
    windowBot    = {0.07, 0.05, 0.08, 0.96},

    panelBG      = {0.07, 0.05, 0.10, 0.90},
    moduleBG     = {0.06, 0.04, 0.09, 0.92},
    slotBG       = {0.11, 0.07, 0.13, 0.95},

    border       = {0.42, 0.34, 0.58, 0.90},
    borderLight  = {0.60, 0.50, 0.78, 1.00},

    title        = {0.97, 0.66, 0.22, 1.00},
    text         = {0.88, 0.85, 0.92, 1.00},

    btnTop       = {0.34, 0.08, 0.07, 1.00},
    btnBot       = {0.16, 0.04, 0.04, 1.00},
    btnHover     = {0.48, 0.12, 0.11, 1.00},
    btnText      = {0.98, 0.72, 0.28, 1.00},

    tabTop       = {0.22, 0.15, 0.22, 1.00},
    tabBot       = {0.12, 0.08, 0.13, 1.00},
    tabHover     = {0.46, 0.35, 0.60, 1.00},
}
SlerneNotes.Theme = Theme

local Skin = {}
SlerneNotes.Skin = Skin

SlerneNotes.ThemeColorChoices = {
    { key = "Default",  label = "Default" },
    { key = "Cyan",     label = "Cyan",      rgb = { 0.012, 0.561, 0.561 } },
    { key = "DarkBlue", label = "Dark Blue", rgb = { 0.035, 0.012, 0.176 } },
    { key = "Green",    label = "Green",     rgb = { 0.016, 0.471, 0.008 } },
    { key = "DeepTeal", label = "Deep Teal", rgb = { 0.000, 0.133, 0.133 } },
    { key = "Purple",   label = "Purple",    rgb = { 0.478, 0.212, 0.690 } },
    { key = "Brown",    label = "Brown",     rgb = { 0.420, 0.271, 0.145 } },
    { key = "Olive",    label = "Olive",     rgb = { 0.435, 0.416, 0.110 } },
    { key = "Lime",     label = "Lime",      rgb = { 0.667, 0.796, 0.227 } },
}
local ThemeColorByKey = {}
for _, c in ipairs(SlerneNotes.ThemeColorChoices) do ThemeColorByKey[c.key] = c end

local DEFAULTS = {
    title = { unpack(Theme.title) }, btnText = { unpack(Theme.btnText) },
    btnTop = { unpack(Theme.btnTop) }, btnBot = { unpack(Theme.btnBot) },
    btnHover = { unpack(Theme.btnHover) },
}

local function ApplyThemeConfig()
    Theme.title    = { unpack(DEFAULTS.title) }
    Theme.btnText  = { unpack(DEFAULTS.btnText) }
    Theme.btnTop   = { unpack(DEFAULTS.btnTop) }
    Theme.btnBot   = { unpack(DEFAULTS.btnBot) }
    Theme.btnHover = { unpack(DEFAULTS.btnHover) }

    local cfg = _G.SlerneNotesDB and _G.SlerneNotesDB.theme
    if not cfg then return end
    local fc = cfg.font and ThemeColorByKey[cfg.font]
    if fc and fc.rgb then
        Theme.title   = { fc.rgb[1], fc.rgb[2], fc.rgb[3], 1 }
        Theme.btnText = { fc.rgb[1], fc.rgb[2], fc.rgb[3], 1 }
    end
    local bc = cfg.button and ThemeColorByKey[cfg.button]
    if bc and bc.rgb then
        local r, g, b = bc.rgb[1], bc.rgb[2], bc.rgb[3]
        Theme.btnTop   = { r, g, b, 1 }
        Theme.btnBot   = { r * 0.5, g * 0.5, b * 0.5, 1 }
        Theme.btnHover = { math.min(1, r * 1.6 + 0.05), math.min(1, g * 1.6 + 0.05), math.min(1, b * 1.6 + 0.05), 1 }
    end
end
SlerneNotes.ApplyThemeConfig = ApplyThemeConfig

Skin._refreshers = {}
local function addRefresher(fn) Skin._refreshers[#Skin._refreshers + 1] = fn end

function Skin.RefreshTheme()
    ApplyThemeConfig()
    for _, fn in ipairs(Skin._refreshers) do pcall(fn) end
end

Skin.AddRefresher = addRefresher

function Skin.TintTexture(tex)
    if not tex then return tex end
    local function apply()
        if tex.SetDesaturated then tex:SetDesaturated(true) end
        local c = Theme.btnText
        tex:SetVertexColor(c[1], c[2], c[3])
    end
    apply()
    addRefresher(apply)
    return tex
end

local function unpackC(t) return t[1], t[2], t[3], t[4] or 1 end
local function color(t) return CreateColor(t[1], t[2], t[3], t[4] or 1) end

local PANEL_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 14,
    insets = { left = 3, right = 3, top = 3, bottom = 3 },
}
local THIN_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 10,
    insets = { left = 2, right = 2, top = 2, bottom = 2 },
}
local BORDER_ONLY = {
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 12,
}

local OUTER_BACKDROP = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    edgeSize = 20,
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
}

local OUTER_FILL = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    insets = { left = 11, right = 11, top = 9, bottom = 9 },
}

local UI_PATH     = "Interface\\AddOns\\SlerneNotes\\img\\theme\\"
local TAB_BORDER  = UI_PATH .. "Tab-ext.tga"
local DIAMOND     = UI_PATH .. "Diamond.tga"

local BORDER_UP   = UI_PATH .. "border-upper.tga"
local BORDER_LO   = UI_PATH .. "border-lower.tga"
local BORDER_LE   = UI_PATH .. "border-left.tga"
local BORDER_RI   = UI_PATH .. "border-right.tga"
local BORDER_DIA  = UI_PATH .. "border-diamond.tga"
local PAGE_ACTIVE   = UI_PATH .. "PageActive.tga"
local PAGE_INACTIVE = UI_PATH .. "PageInactive.tga"
local LOCK_ART    = UI_PATH .. "lock.tga"
SlerneNotes.LockArt = LOCK_ART
local EDGE_T      = 13
local EDGE_S      = 15

function Skin.ArtEdges(frame, sides)
    sides = sides or { top = true, bottom = true, left = true, right = true }
    local r = { edges = {}, diamonds = {} }
    local function strip(file)
        local t = frame:CreateTexture(nil, "BORDER")
        t:SetTexture(file)
        return t
    end
    if sides.top then
        local t = strip(BORDER_UP); t:SetHeight(EDGE_T)
        t:SetPoint("TOPLEFT", 0, 0); t:SetPoint("TOPRIGHT", 0, 0); r.edges.top = t
    end
    if sides.bottom then
        local t = strip(BORDER_LO); t:SetHeight(EDGE_T)
        t:SetPoint("BOTTOMLEFT", 0, 0); t:SetPoint("BOTTOMRIGHT", 0, 0); r.edges.bottom = t
    end
    if sides.left then
        local t = strip(BORDER_LE); t:SetWidth(EDGE_S)
        t:SetPoint("TOPLEFT", 0, 0); t:SetPoint("BOTTOMLEFT", 0, 0); r.edges.left = t
    end
    if sides.right then
        local t = strip(BORDER_RI); t:SetWidth(EDGE_S)
        t:SetPoint("TOPRIGHT", 0, 0); t:SetPoint("BOTTOMRIGHT", 0, 0); r.edges.right = t
    end
    local hx, hy = EDGE_S / 2, EDGE_T / 2
    local OFF = {
        TOPLEFT     = { hx, -hy }, TOPRIGHT    = { -hx, -hy },
        BOTTOMLEFT  = { hx,  hy }, BOTTOMRIGHT = { -hx,  hy },
    }
    local function dia(corner)
        local o = OFF[corner]
        local d = frame:CreateTexture(nil, "OVERLAY")
        d:SetTexture(BORDER_DIA)
        d:SetSize(18, 18)
        d:SetPoint("CENTER", frame, corner, o[1], o[2])
        r.diamonds[#r.diamonds + 1] = d
    end

    if sides.gems then
        for _, c in ipairs(sides.gems) do dia(c) end
    else
        if sides.top and sides.left then dia("TOPLEFT") end
        if sides.top and sides.right then dia("TOPRIGHT") end
        if sides.bottom and sides.left then dia("BOTTOMLEFT") end
        if sides.bottom and sides.right then dia("BOTTOMRIGHT") end
    end
    return r
end

function Skin.SetArtEdgesShade(r, v)
    if not r then return end
    for _, t in pairs(r.edges) do t:SetVertexColor(v, v, v) end
    for _, d in ipairs(r.diamonds) do d:SetVertexColor(v, v, v) end
end

local function setGradient(tex, botC, topC)

    if tex.SetGradient then
        tex:SetGradient("VERTICAL", color(botC), color(topC))
    else
        tex:SetColorTexture(unpackC(topC))
    end
end

function Skin.Panel(frame, bgColor, borderColor)
    if not frame or not frame.SetBackdrop then return frame end
    frame:SetBackdrop(PANEL_BACKDROP)
    frame:SetBackdropColor(unpackC(bgColor or Theme.panelBG))
    frame:SetBackdropBorderColor(unpackC(borderColor or Theme.border))
    return frame
end

function Skin.Module(frame)
    return Skin.Panel(frame, Theme.moduleBG, Theme.border)
end

function Skin.Slot(frame)
    if not frame or not frame.SetBackdrop then return frame end
    frame:SetBackdrop(THIN_BACKDROP)
    frame:SetBackdropColor(unpackC(Theme.slotBG))
    frame:SetBackdropBorderColor(unpackC(Theme.border))
    return frame
end

function Skin.Window(frame)
    if not frame then return frame end
    if frame.SetBackdrop then
        frame:SetBackdrop(PANEL_BACKDROP)
        frame:SetBackdropColor(unpackC(Theme.windowBot))
        frame:SetBackdropBorderColor(unpackC(Theme.borderLight))
    end
    if not frame._snGrad then
        local g = frame:CreateTexture(nil, "BACKGROUND")
        g:SetPoint("TOPLEFT", 4, -4)
        g:SetPoint("BOTTOMRIGHT", -4, 4)

        g:SetColorTexture(unpackC(Theme.windowBot))
        frame._snGrad = g
    end
    return frame
end

function Skin.OuterFrame(frame)
    if not frame then return frame end

    if frame.SetBackdrop then
        frame:SetBackdrop(OUTER_FILL)
        frame:SetBackdropColor(unpackC(Theme.windowBot))
    end
    if not frame._snGrad then
        local g = frame:CreateTexture(nil, "BACKGROUND")

        g:SetPoint("TOPLEFT", 11, -9)
        g:SetPoint("BOTTOMRIGHT", -11, 9)

        g:SetColorTexture(unpackC(Theme.windowBot))
        frame._snGrad = g
    end
    if not frame._snArtBorder then
        frame._snArtBorder = Skin.ArtEdges(frame, { top = true, bottom = true, left = true, right = true })
    end
    return frame
end

function Skin.Title(fs)
    if fs then
        fs:SetTextColor(unpackC(Theme.title))
        addRefresher(function() fs:SetTextColor(unpackC(Theme.title)) end)
    end
    return fs
end

local function clearTex(t)
    if t then
        t:SetTexture(nil)
        if t.SetAtlas then t:SetAtlas(nil) end
        t:SetAlpha(0)
    end
end

function Skin.Button(b, isTab)
    if not b or b._snSkinned then return b end
    b._snSkinned = true

    if b.GetNormalTexture then clearTex(b:GetNormalTexture()) end
    if b.GetPushedTexture then clearTex(b:GetPushedTexture()) end
    if b.GetDisabledTexture then clearTex(b:GetDisabledTexture()) end
    if b.GetHighlightTexture then clearTex(b:GetHighlightTexture()) end
    for _, k in ipairs({ "Left", "Right", "Middle", "LeftSeparator", "RightSeparator",
                         "TopLeft", "TopRight", "BottomLeft", "BottomRight", "TopMiddle",
                         "BottomMiddle", "MiddleLeft", "MiddleRight", "MiddleMiddle" }) do
        if b[k] and b[k].SetAlpha then b[k]:SetAlpha(0) end
    end

    local topC = isTab and Theme.tabTop or Theme.btnTop
    local botC = isTab and Theme.tabBot or Theme.btnBot

    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", 1, -1)
    bg:SetPoint("BOTTOMRIGHT", -1, 1)
    bg:SetColorTexture(1, 1, 1, 1)
    setGradient(bg, botC, topC)
    b._snBG = bg
    b._snTop = topC
    b._snBot = botC

    local brd = CreateFrame("Frame", nil, b, "BackdropTemplate")
    brd:SetPoint("TOPLEFT", b, "TOPLEFT", -2, 2)
    brd:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 2, -2)
    brd:SetBackdrop(BORDER_ONLY)
    brd:SetBackdropBorderColor(unpackC(Theme.border))
    b._snBorder = brd

    b:HookScript("OnEnter", function(self)
        if self._snBG then setGradient(self._snBG, self._snTop, Theme.btnHover) end
        if self._snBorder then self._snBorder:SetBackdropBorderColor(unpackC(Theme.borderLight)) end
    end)
    b:HookScript("OnLeave", function(self)
        if self._snBG then setGradient(self._snBG, self._snBot, self._snTop) end
        if self._snBorder then self._snBorder:SetBackdropBorderColor(unpackC(Theme.border)) end
    end)

    local fs = b.GetFontString and b:GetFontString()
    if fs and not isTab then fs:SetTextColor(unpackC(Theme.btnText)) end

    addRefresher(function()
        local topC = isTab and Theme.tabTop or Theme.btnTop
        local botC = isTab and Theme.tabBot or Theme.btnBot
        b._snTop, b._snBot = topC, botC
        if b._snBG then setGradient(b._snBG, botC, topC) end
        if b._snBorder then b._snBorder:SetBackdropBorderColor(unpackC(Theme.border)) end
        local f = b.GetFontString and b:GetFontString()
        if f and not isTab then f:SetTextColor(unpackC(Theme.btnText)) end
    end)
    return b
end

function Skin.FolderTab(b)
    if not b or b._snTabbed then return b end
    b._snTabbed = true

    if b.GetNormalTexture then clearTex(b:GetNormalTexture()) end
    if b.GetPushedTexture then clearTex(b:GetPushedTexture()) end
    if b.GetDisabledTexture then clearTex(b:GetDisabledTexture()) end
    if b.GetHighlightTexture then clearTex(b:GetHighlightTexture()) end
    for _, k in ipairs({ "Left", "Right", "Middle", "LeftSeparator", "RightSeparator" }) do
        if b[k] and b[k].SetAlpha then b[k]:SetAlpha(0) end
    end

    local fill = b:CreateTexture(nil, "BACKGROUND")
    fill:SetPoint("TOPLEFT", 7, -7)
    fill:SetPoint("BOTTOMRIGHT", -7, 7)
    fill:SetColorTexture(1, 1, 1, 1)
    b._snFill = fill

    b._snArtBorder = Skin.ArtEdges(b, { top = true, bottom = true, left = true,
        gems = { "TOPLEFT", "BOTTOMLEFT", "TOPRIGHT", "BOTTOMRIGHT" } })

    local shadow = b:CreateTexture(nil, "ARTWORK")
    shadow:SetPoint("TOPRIGHT", 0, 0)
    shadow:SetPoint("BOTTOMRIGHT", 0, 0)
    shadow:SetWidth(30)
    shadow:SetColorTexture(1, 1, 1, 1)
    if shadow.SetGradient then
        shadow:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, 0), CreateColor(0, 0, 0, 0.65))
    end
    b._snShadow = shadow

    local parent = b:GetParent()
    b._snBaseLevel = parent and parent:GetFrameLevel() or b:GetFrameLevel()

    b:HookScript("OnEnter", function(self)
        if not self._snActive and self._snFill then
            setGradient(self._snFill, Theme.tabBot, Theme.tabHover)
        end
    end)
    b:HookScript("OnLeave", function(self)
        if not self._snActive and self._snFill then
            setGradient(self._snFill, Theme.tabBot, Theme.tabTop)
        end
    end)

    addRefresher(function() Skin.SetFolderTabActive(b, b._snActive) end)
    Skin.SetFolderTabActive(b, false)
    return b
end

function Skin.SetFolderTabActive(b, active)
    if not b or not b._snFill then return end
    b._snActive = active

    b._snFill:ClearAllPoints()
    if active then
        b._snFill:SetPoint("TOPLEFT", 11, -9)
        b._snFill:SetPoint("BOTTOMRIGHT", 9, 9)
    else
        b._snFill:SetPoint("TOPLEFT", 11, -9)
        b._snFill:SetPoint("BOTTOMRIGHT", -3, 9)
    end

    if active then

        local wb = Theme.windowBot
        setGradient(b._snFill, { wb[1], wb[2], wb[3], 1 }, { wb[1], wb[2], wb[3], 1 })
        Skin.SetArtEdgesShade(b._snArtBorder, 1)
        if b._snShadow then b._snShadow:Hide() end
        b:SetFrameLevel(b._snBaseLevel + 20)
        local fs = b.GetFontString and b:GetFontString()
        if fs then fs:SetTextColor(unpackC(Theme.title)) end
    else
        setGradient(b._snFill, Theme.tabBot, Theme.tabTop)
        Skin.SetArtEdgesShade(b._snArtBorder, 0.6)
        if b._snShadow then b._snShadow:Show() end
        b:SetFrameLevel(b._snBaseLevel)
        local fs = b.GetFontString and b:GetFontString()
        if fs then fs:SetTextColor(unpackC(Theme.text)) end
    end
end

function Skin.PageTab(b)
    if not b or b._snPageTab then return b end
    b._snPageTab = true

    if b.GetNormalTexture then clearTex(b:GetNormalTexture()) end
    if b.GetPushedTexture then clearTex(b:GetPushedTexture()) end
    if b.GetDisabledTexture then clearTex(b:GetDisabledTexture()) end
    if b.GetHighlightTexture then clearTex(b:GetHighlightTexture()) end
    for _, k in ipairs({ "Left", "Right", "Middle", "LeftSeparator", "RightSeparator" }) do
        if b[k] and b[k].SetAlpha then b[k]:SetAlpha(0) end
    end

    local art = b:CreateTexture(nil, "BORDER")
    art:SetTexture(PAGE_INACTIVE)
    art:SetAllPoints()
    b._snArt = art

    local bridge = b:CreateTexture(nil, "ARTWORK")
    bridge:SetPoint("TOPLEFT", b, "BOTTOMLEFT", 5, 4)
    bridge:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -5, -3)
    bridge:Hide()
    b._snBridge = bridge

    local fs = b.GetFontString and b:GetFontString()
    if fs then
        fs:SetFontObject("GameFontNormal")
        fs:ClearAllPoints()
        fs:SetPoint("CENTER", b, "CENTER", -1, 4)
    end

    local parent = b:GetParent()
    b._snBaseLevel = (parent and parent:GetFrameLevel() or b:GetFrameLevel()) + 10

    b:HookScript("OnEnter", function(self)
        if not self._snActive and self._snArt then self._snArt:SetVertexColor(0.85, 0.85, 0.85) end
    end)
    b:HookScript("OnLeave", function(self)
        if not self._snActive and self._snArt then self._snArt:SetVertexColor(0.55, 0.55, 0.55) end
    end)

    addRefresher(function() Skin.SetPageTabActive(b, b._snActive) end)
    Skin.SetPageTabActive(b, false)
    return b
end

function Skin.SetPageTabActive(b, active)
    if not b or not b._snArt then return end
    b._snActive = active

    b._snArt:ClearAllPoints()
    if active then
        b._snArt:SetTexture(PAGE_ACTIVE)
        b._snArt:SetPoint("TOPLEFT", 0, 0)
        b._snArt:SetPoint("BOTTOMRIGHT", 0, 0)
        b._snArt:SetVertexColor(1, 1, 1)
        local wb = Theme.windowBot
        b._snBridge:SetColorTexture(wb[1], wb[2], wb[3], 1)
        b._snBridge:Show()
        b:SetFrameLevel(b._snBaseLevel + 20)
        local fs = b.GetFontString and b:GetFontString()
        if fs then fs:SetTextColor(unpackC(Theme.title)) end
    else
        b._snArt:SetTexture(PAGE_INACTIVE)
        b._snArt:SetPoint("TOPLEFT", 0, 0)
        b._snArt:SetPoint("BOTTOMRIGHT", 0, 0)
        b._snArt:SetVertexColor(0.55, 0.55, 0.55)
        b._snBridge:Hide()
        b:SetFrameLevel(b._snBaseLevel)
        local fs = b.GetFontString and b:GetFontString()
        if fs then fs:SetTextColor(unpackC(Theme.text)) end
    end
end

function Skin.CloseButton(b)
    if not b or b._snSkinned then return b end
    b._snSkinned = true

    if b.GetNormalTexture then clearTex(b:GetNormalTexture()) end
    if b.GetPushedTexture then clearTex(b:GetPushedTexture()) end
    if b.GetHighlightTexture then clearTex(b:GetHighlightTexture()) end
    if b.GetDisabledTexture then clearTex(b:GetDisabledTexture()) end

    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", 2, -2)
    bg:SetPoint("BOTTOMRIGHT", -2, 2)
    bg:SetColorTexture(1, 1, 1, 1)
    setGradient(bg, Theme.btnBot, Theme.btnTop)
    b._snBG = bg

    local brd = CreateFrame("Frame", nil, b, "BackdropTemplate")
    brd:SetAllPoints()
    brd:SetBackdrop(BORDER_ONLY)
    brd:SetBackdropBorderColor(unpackC(Theme.btnText))

    local x = b:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    x:SetPoint("CENTER", 0, 0)
    x:SetText("X")
    x:SetTextColor(unpackC(Theme.btnText))

    b:HookScript("OnEnter", function() setGradient(bg, Theme.btnTop, Theme.btnHover) end)
    b:HookScript("OnLeave", function() setGradient(bg, Theme.btnBot, Theme.btnTop) end)

    addRefresher(function()
        setGradient(bg, Theme.btnBot, Theme.btnTop)
        brd:SetBackdropBorderColor(unpackC(Theme.btnText))
        x:SetTextColor(unpackC(Theme.btnText))
    end)
    return b
end

function Skin.IconBox(b)
    if not b or b._snIconBox then return b end
    b._snIconBox = true

    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", 2, -2)
    bg:SetPoint("BOTTOMRIGHT", -2, 2)
    bg:SetColorTexture(1, 1, 1, 1)
    setGradient(bg, Theme.btnBot, Theme.btnTop)

    local brd = CreateFrame("Frame", nil, b, "BackdropTemplate")
    brd:SetAllPoints()
    brd:SetBackdrop(BORDER_ONLY)
    brd:SetBackdropBorderColor(unpackC(Theme.btnText))

    b:HookScript("OnEnter", function() setGradient(bg, Theme.btnTop, Theme.btnHover) end)
    b:HookScript("OnLeave", function() setGradient(bg, Theme.btnBot, Theme.btnTop) end)
    addRefresher(function()
        setGradient(bg, Theme.btnBot, Theme.btnTop)
        brd:SetBackdropBorderColor(unpackC(Theme.btnText))
    end)
    return b
end

function Skin.LockButton(b)
    if not b or b._snLock then return b end
    b._snLock = true

    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", 2, -2)
    bg:SetPoint("BOTTOMRIGHT", -2, 2)
    bg:SetColorTexture(1, 1, 1, 1)
    setGradient(bg, Theme.btnBot, Theme.btnTop)

    local brd = CreateFrame("Frame", nil, b, "BackdropTemplate")
    brd:SetAllPoints()
    brd:SetBackdrop(BORDER_ONLY)
    brd:SetBackdropBorderColor(unpackC(Theme.btnText))

    local tex = b:CreateTexture(nil, "ARTWORK")
    tex:SetPoint("TOPLEFT", 4, -4)
    tex:SetPoint("BOTTOMRIGHT", -4, 4)
    tex:SetTexture(LOCK_ART)
    b._snLockTex = tex

    local function applyTint()
        local c = Theme.btnText
        local f = b._snLocked and 1.0 or 0.45
        if b._snHover then f = 1.0 end
        tex:SetVertexColor(c[1] * f, c[2] * f, c[3] * f, 1)
    end
    b.SetLockedState = function(self, locked) self._snLocked = locked and true or false; applyTint() end

    b:HookScript("OnEnter", function(self)
        self._snHover = true; setGradient(bg, Theme.btnTop, Theme.btnHover); applyTint()
    end)
    b:HookScript("OnLeave", function(self)
        self._snHover = false; setGradient(bg, Theme.btnBot, Theme.btnTop); applyTint()
    end)
    addRefresher(function()
        setGradient(bg, Theme.btnBot, Theme.btnTop)
        brd:SetBackdropBorderColor(unpackC(Theme.btnText))
        applyTint()
    end)
    applyTint()
    return b
end

function Skin.HoverHighlight(b)
    if not b or not b.SetHighlightTexture then return b end
    b:SetHighlightTexture("Interface\\Buttons\\WHITE8x8")
    local ht = b:GetHighlightTexture()
    if ht then
        ht:SetVertexColor(0.70, 0.60, 0.85, 0.18)
    end
    return b
end

function Skin.Input(e)
    if not e or e._snSkinned then return e end
    e._snSkinned = true

    for _, r in ipairs({ e:GetRegions() }) do
        if r.GetObjectType and r:GetObjectType() == "Texture" then r:SetAlpha(0) end
    end

    local parent = e:GetParent()
    local bg = CreateFrame("Frame", nil, parent, "BackdropTemplate")

    bg:SetPoint("TOPLEFT", e, "TOPLEFT", -4, 0)
    bg:SetPoint("BOTTOMRIGHT", e, "BOTTOMRIGHT", 0, 0)
    bg:SetFrameLevel(math.max(0, e:GetFrameLevel() - 1))
    bg:SetBackdrop(THIN_BACKDROP)
    bg:SetBackdropColor(unpackC(Theme.slotBG))
    bg:SetBackdropBorderColor(unpackC(Theme.border))
    e._snBG = bg

    e:HookScript("OnShow", function() bg:Show() end)
    e:HookScript("OnHide", function() bg:Hide() end)
    if not e:IsShown() then bg:Hide() end

    local fs = e.GetFontString and e:GetFontString()
    if fs then fs:SetTextColor(unpackC(Theme.text)) end
    return e
end

function Skin.Dropdown(dd)
    if not dd or dd._snSkinned then return dd end
    dd._snSkinned = true

    local bg = CreateFrame("Frame", nil, dd, "BackdropTemplate")
    bg:SetPoint("TOPLEFT", 1, -1)
    bg:SetPoint("BOTTOMRIGHT", -1, 1)
    bg:SetFrameLevel(math.max(0, dd:GetFrameLevel() - 1))
    bg:SetBackdrop(THIN_BACKDROP)
    bg:SetBackdropColor(unpackC(Theme.slotBG))
    bg:SetBackdropBorderColor(0, 0, 0, 0)

    local function whiteText()
        if dd.Text and dd.Text.SetTextColor then dd.Text:SetTextColor(1, 1, 1) end
    end
    whiteText()
    dd:HookScript("OnEnter", whiteText)
    dd:HookScript("OnLeave", whiteText)
    if dd.Arrow and dd.Arrow.SetVertexColor then dd.Arrow:SetVertexColor(unpackC(Theme.btnText)) end
    addRefresher(function()
        if dd.Arrow and dd.Arrow.SetVertexColor then dd.Arrow:SetVertexColor(unpackC(Theme.btnText)) end
    end)
    return dd
end
