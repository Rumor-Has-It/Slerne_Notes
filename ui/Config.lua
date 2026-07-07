local addonName, SlerneNotes = ...

local function GetThemeCfg()
    SlerneNotesDB.theme = SlerneNotesDB.theme or { font = "Default", button = "Default" }
    return SlerneNotesDB.theme
end

local built, fontDD, buttonDD, mmCheck = false
local verPanel, verCount, verRowPool = nil, nil, {}
local pluginChecks = {}

local function VersionNewer(a, b)
    local a1, a2, a3 = strsplit(".", a or "0")
    local b1, b2, b3 = strsplit(".", b or "0")
    a1, a2, a3 = tonumber(a1) or 0, tonumber(a2) or 0, tonumber(a3) or 0
    b1, b2, b3 = tonumber(b1) or 0, tonumber(b2) or 0, tonumber(b3) or 0
    if a1 ~= b1 then return a1 > b1 end
    if a2 ~= b2 then return a2 > b2 end
    return a3 > b3
end

local function MakeColorDropdown(parent, getKey, setKey)
    local dd = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
    dd:SetWidth(180)
    SlerneNotes.Skin.Dropdown(dd)
    dd:SetupMenu(function(dropdown, root)
        for _, c in ipairs(SlerneNotes.ThemeColorChoices) do
            root:CreateRadio(c.label,
                function() return getKey() == c.key end,
                function()
                    setKey(c.key)
                    SlerneNotes.Skin.RefreshTheme()
                    if dropdown.GenerateMenu then dropdown:GenerateMenu() end
                end)
        end
    end)
    return dd
end

local function Build()
    local tab = SlerneNotes.configTab
    if not tab or built then return end
    built = true

    local panel = CreateFrame("Frame", nil, tab, "BackdropTemplate")
    panel:SetSize(440, 220)
    panel:SetPoint("TOPLEFT", 20, -20)
    SlerneNotes.Skin.Panel(panel)

    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -14)
    title:SetText("Theme")
    SlerneNotes.Skin.Title(title)

    local fontLbl = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fontLbl:SetPoint("TOPLEFT", 24, -56)
    fontLbl:SetText("Font color (titles, button text, X's)")
    SlerneNotes.Skin.Title(fontLbl)
    fontDD = MakeColorDropdown(panel,
        function() return GetThemeCfg().font end,
        function(k) GetThemeCfg().font = k end)
    fontDD:SetPoint("TOPLEFT", 22, -76)

    local btnLbl = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btnLbl:SetPoint("TOPLEFT", 24, -122)
    btnLbl:SetText("Button background color")
    SlerneNotes.Skin.Title(btnLbl)
    buttonDD = MakeColorDropdown(panel,
        function() return GetThemeCfg().button end,
        function(k) GetThemeCfg().button = k end)
    buttonDD:SetPoint("TOPLEFT", 22, -142)

    local previewLbl = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    previewLbl:SetPoint("TOPLEFT", 252, -56)
    previewLbl:SetText("Preview")
    SlerneNotes.Skin.Title(previewLbl)

    local sample = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    sample:SetSize(170, 30)
    sample:SetPoint("TOPLEFT", 250, -80)
    sample:SetText("Sample Button")
    SlerneNotes.Skin.Button(sample)

    local sampleTitle = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    sampleTitle:SetPoint("TOP", sample, "BOTTOM", 0, -14)
    sampleTitle:SetText("Sample Title")
    SlerneNotes.Skin.Title(sampleTitle)

    local mm = CreateFrame("Frame", nil, tab, "BackdropTemplate")
    mm:SetSize(300, 220)
    mm:SetPoint("TOPLEFT", panel, "TOPRIGHT", 20, 0)
    SlerneNotes.Skin.Panel(mm)

    local mmTitle = mm:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mmTitle:SetPoint("TOP", 0, -14)
    mmTitle:SetText("Minimap")
    SlerneNotes.Skin.Title(mmTitle)

    mmCheck = CreateFrame("CheckButton", nil, mm, "UICheckButtonTemplate")
    mmCheck:SetSize(24, 24)
    mmCheck:SetPoint("TOPLEFT", 24, -56)
    if mmCheck.GetCheckedTexture then SlerneNotes.Skin.TintTexture(mmCheck:GetCheckedTexture()) end
    mmCheck.text = mmCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mmCheck.text:SetPoint("LEFT", mmCheck, "RIGHT", 4, 0)
    mmCheck.text:SetText("Hidden")
    mmCheck.text:SetTextColor(1, 1, 1)
    mmCheck:SetScript("OnClick", function(self)
        if SlerneNotes.SetMinimapHidden then SlerneNotes.SetMinimapHidden(self:GetChecked()) end
    end)

    local plug = CreateFrame("Frame", nil, tab, "BackdropTemplate")
    plug:SetSize(300, 220)
    plug:SetPoint("TOPLEFT", mm, "TOPRIGHT", 20, 0)
    SlerneNotes.Skin.Panel(plug)

    local plugTitle = plug:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    plugTitle:SetPoint("TOP", 0, -14)
    plugTitle:SetText("Plugins")
    SlerneNotes.Skin.Title(plugTitle)

    local plugDefs = {
        { key = "roster",     label = "Roster" },
        { key = "registries", label = "Registries" },
        { key = "loot",       label = "Loot" },
    }
    local py = -46
    for _, def in ipairs(plugDefs) do
        local cb = CreateFrame("CheckButton", nil, plug, "UICheckButtonTemplate")
        cb:SetSize(24, 24)
        cb:SetPoint("TOPLEFT", 24, py)
        if cb.GetCheckedTexture then SlerneNotes.Skin.TintTexture(cb:GetCheckedTexture()) end
        cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cb.text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        cb.text:SetText(def.label)
        cb.text:SetTextColor(1, 1, 1)
        cb:SetChecked(true)
        cb:SetScript("OnClick", function(self)
            Data_SetPluginHidden(def.key, not self:GetChecked())
            if SlerneNotes.ApplyPluginVisibility then SlerneNotes.ApplyPluginVisibility() end
        end)
        pluginChecks[def.key] = cb
        py = py - 32
    end

    local plugHint = plug:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    plugHint:SetPoint("BOTTOMLEFT", 24, 14)
    plugHint:SetPoint("BOTTOMRIGHT", -14, 14)
    plugHint:SetJustifyH("LEFT")
    plugHint:SetText("Unchecked plugins are hidden from the tab bar. They keep collecting data in the background.")
    plugHint:SetTextColor(0.6, 0.6, 0.6)

    verPanel = CreateFrame("Frame", nil, tab, "BackdropTemplate")
    verPanel:SetSize(760, 470)
    verPanel:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 0, -20)
    SlerneNotes.Skin.Panel(verPanel)

    local verTitle = verPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    verTitle:SetPoint("TOP", 0, -14)
    verTitle:SetText("Group Viewer Versions")
    SlerneNotes.Skin.Title(verTitle)

    verCount = verPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    verCount:SetPoint("TOPLEFT", 24, -44)
    verCount:SetTextColor(1, 1, 1)

    local verHint = verPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    verHint:SetPoint("BOTTOMLEFT", 24, 12)
    verHint:SetText("Group members running Slerne Notes Viewer report their version automatically.")
    verHint:SetTextColor(0.6, 0.6, 0.6)
end

function SlerneNotes.RefreshViewerVersions()
    if not verPanel or not (SlerneNotes.configTab and SlerneNotes.configTab:IsShown()) then return end
    local roster = SlerneNotes:GetRoster() or {}
    local versions = SlerneNotes.viewerVersions or {}

    local names = {}
    for name in pairs(roster) do names[#names + 1] = name end
    table.sort(names)

    local newest
    for _, v in pairs(versions) do
        if not newest or VersionNewer(v, newest) then newest = v end
    end

    local running = 0
    for i, name in ipairs(names) do
        local row = verRowPool[i]
        if not row then
            row = verPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            row:SetJustifyH("LEFT")
            row:SetWidth(340)
            verRowPool[i] = row
        end
        local col = (i - 1) % 2
        local rowIdx = math.floor((i - 1) / 2)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", 24 + col * 370, -72 - rowIdx * 18)

        local hex = SlerneNotes.GetClassHex(roster[name] and roster[name].class)
        local ver = versions[name]
        if ver then
            running = running + 1
            local vcol = (newest and ver ~= newest) and "|cffff9933" or "|cff33ff66"
            row:SetText("|cff" .. hex .. name .. "|r  " .. vcol .. "v" .. ver .. "|r")
        else
            row:SetText("|cff" .. hex .. name .. "|r  |cff777777not detected|r")
        end
        row:Show()
    end
    for i = #names + 1, #verRowPool do verRowPool[i]:Hide() end
    verCount:SetText(string.format("Running the Viewer: %d of %d group members", running, #names))
end

function SlerneNotes.RefreshConfigUI()
    Build()
    if fontDD and fontDD.GenerateMenu then fontDD:GenerateMenu() end
    if buttonDD and buttonDD.GenerateMenu then buttonDD:GenerateMenu() end
    if mmCheck and SlerneNotes.IsMinimapHidden then mmCheck:SetChecked(SlerneNotes.IsMinimapHidden()) end
    if Data_GetHiddenPlugins then
        local hidden = Data_GetHiddenPlugins()
        for key, cb in pairs(pluginChecks) do cb:SetChecked(not hidden[key]) end
    end
    if SlerneNotes.RequestViewerVersions then SlerneNotes.RequestViewerVersions() end
    SlerneNotes.RefreshViewerVersions()
end

Build()
