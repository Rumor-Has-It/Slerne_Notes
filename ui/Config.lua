local addonName, SlerneNotes = ...

-- =====================================================================
-- CONFIG TAB -- per-addon colour theme (Font + Button background).
-- Choices are saved and applied on the next UI load (Skin.ApplyThemeConfig).
-- =====================================================================

local function GetThemeCfg()
    SlerneNotesDB.theme = SlerneNotesDB.theme or { font = "Default", button = "Default" }
    return SlerneNotesDB.theme
end

local built, fontDD, buttonDD, mmCheck = false

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
                    SlerneNotes.Skin.RefreshTheme() -- live, no reload
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

    -- THEME panel
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

    -- Live preview: a sample button + title text. Skin.Button/Skin.Title register
    -- theme refreshers, so these recolor instantly as the dropdowns change.
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

    -- MINIMAP panel (its own square, like Theme)
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

end

function SlerneNotes.RefreshConfigUI()
    Build()
    if fontDD and fontDD.GenerateMenu then fontDD:GenerateMenu() end
    if buttonDD and buttonDD.GenerateMenu then buttonDD:GenerateMenu() end
    if mmCheck and SlerneNotes.IsMinimapHidden then mmCheck:SetChecked(SlerneNotes.IsMinimapHidden()) end
end

Build()
