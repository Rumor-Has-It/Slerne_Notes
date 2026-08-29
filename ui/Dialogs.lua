local addonName, SlerneNotes = ...
local frame = SlerneNotes.frame

local newModDialog = CreateFrame("Frame", "SlerneNotesNewModDialog", frame, "BackdropTemplate")
newModDialog:SetSize(280, 200)
newModDialog:SetPoint("CENTER")

newModDialog:SetFrameStrata("FULLSCREEN_DIALOG")
newModDialog:SetFrameLevel(500)
SlerneNotes.Skin.Panel(newModDialog, SlerneNotes.Theme.windowBot, SlerneNotes.Theme.borderLight)
newModDialog:Hide()

local newModTitle = newModDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
newModTitle:SetPoint("TOP", 0, -15)
newModTitle:SetText("Create Module")
SlerneNotes.Skin.Title(newModTitle)

local newModEditBox = CreateFrame("EditBox", nil, newModDialog, "InputBoxTemplate")
newModEditBox:SetSize(160, 20)
newModEditBox:SetPoint("TOP", newModTitle, "BOTTOM", 0, -15)
SlerneNotes.Skin.Input(newModEditBox)

local typeDropdown = CreateFrame("DropdownButton", "SlerneNotesModTypeDropdown", newModDialog, "WowStyle1DropdownTemplate")
typeDropdown:SetPoint("TOP", newModEditBox, "BOTTOM", 0, -20)
typeDropdown:SetWidth(150)
SlerneNotes.Skin.Dropdown(typeDropdown)

local lengthEditBox = CreateFrame("EditBox", nil, newModDialog, "InputBoxTemplate")
lengthEditBox:SetSize(50, 20)
lengthEditBox:SetPoint("TOP", typeDropdown, "BOTTOM", 0, -25)
lengthEditBox:SetNumeric(true)
SlerneNotes.Skin.Input(lengthEditBox)

local dupCheckNew = CreateFrame("CheckButton", nil, newModDialog, "UICheckButtonTemplate")
dupCheckNew:SetSize(22, 22)
dupCheckNew:SetPoint("TOP", lengthEditBox, "BOTTOM", -66, -12)
local dupNewLabel = dupCheckNew:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
dupNewLabel:SetPoint("LEFT", dupCheckNew, "RIGHT", 4, 0)
dupNewLabel:SetText("Allow duplicate players")
dupNewLabel:SetTextColor(1, 1, 1)
dupCheckNew:Hide()

local imageDropdown = CreateFrame("DropdownButton", "SlerneNotesImageDropdown", newModDialog, "WowStyle1DropdownTemplate")
imageDropdown:SetWidth(220)
imageDropdown:SetPoint("TOP", lengthEditBox, "BOTTOM", 0, -25)
imageDropdown:Hide()
SlerneNotes.Skin.Dropdown(imageDropdown)
imageDropdown.selectedFile = nil

local imgPathLabel = imageDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
imgPathLabel:SetPoint("BOTTOM", imageDropdown, "TOP", 0, 5)
imgPathLabel:SetText("Image")

local imageNameEdit = CreateFrame("EditBox", nil, newModDialog, "InputBoxTemplate")
imageNameEdit:SetSize(220, 20)
imageNameEdit:SetPoint("TOP", imageDropdown, "BOTTOM", 0, -24)
imageNameEdit:SetAutoFocus(false)
imageNameEdit:Hide()
SlerneNotes.Skin.Input(imageNameEdit)

local imageNameLabel = imageNameEdit:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
imageNameLabel:SetPoint("BOTTOM", imageNameEdit, "TOP", 0, 3)
imageNameLabel:SetText("or type a custom filename (e.g. Alleriap3)")

local imgWEditBox = CreateFrame("EditBox", nil, newModDialog, "InputBoxTemplate")
imgWEditBox:SetSize(50, 20)
imgWEditBox:SetPoint("TOPLEFT", imageNameEdit, "BOTTOMLEFT", 30, -25)
imgWEditBox:SetNumeric(true)
imgWEditBox:Hide()
SlerneNotes.Skin.Input(imgWEditBox)

local imgWLabel = imgWEditBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
imgWLabel:SetPoint("BOTTOM", imgWEditBox, "TOP", 0, 5)
imgWLabel:SetText("Width")

local imgHEditBox = CreateFrame("EditBox", nil, newModDialog, "InputBoxTemplate")
imgHEditBox:SetSize(50, 20)
imgHEditBox:SetPoint("TOPLEFT", imgWEditBox, "TOPRIGHT", 40, 0)
imgHEditBox:SetNumeric(true)
imgHEditBox:Hide()
SlerneNotes.Skin.Input(imgHEditBox)

local imgHLabel = imgHEditBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
imgHLabel:SetPoint("BOTTOM", imgHEditBox, "TOP", 0, 5)
imgHLabel:SetText("Height")

local function SelectImage(img)
    imageDropdown.selectedFile = img and img.file or nil
    if img then
        imgWEditBox:SetNumber(img.w or 400)
        imgHEditBox:SetNumber(img.h or 300)
        imgPathLabel:SetText("Image: " .. (img.label or img.file))
    else
        imgPathLabel:SetText("Image")
    end
    if imageDropdown.GenerateMenu then imageDropdown:GenerateMenu() end
end

local fbDropdown = CreateFrame("DropdownButton", "SlerneNotesFlipbookDropdown", newModDialog, "WowStyle1DropdownTemplate")
fbDropdown:SetWidth(220)
fbDropdown:SetPoint("TOP", lengthEditBox, "BOTTOM", 0, -25)
fbDropdown:Hide()
SlerneNotes.Skin.Dropdown(fbDropdown)
fbDropdown.selectedFile = nil

local fbPathLabel = fbDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
fbPathLabel:SetPoint("BOTTOM", fbDropdown, "TOP", 0, 5)
fbPathLabel:SetText("Flipbook")

local fbNameEdit = CreateFrame("EditBox", nil, newModDialog, "InputBoxTemplate")
fbNameEdit:SetSize(220, 20)
fbNameEdit:SetPoint("TOP", fbDropdown, "BOTTOM", 0, -24)
fbNameEdit:SetAutoFocus(false)
fbNameEdit:Hide()
SlerneNotes.Skin.Input(fbNameEdit)

local fbNameLabel = fbNameEdit:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
fbNameLabel:SetPoint("BOTTOM", fbNameEdit, "TOP", 0, 3)
fbNameLabel:SetText("or type a custom sheet in img/flipbooks/custom")

local function makeNumBox(parent, label, width)
    local eb = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    eb:SetSize(width or 44, 20)
    eb:SetAutoFocus(false)
    eb:Hide()
    SlerneNotes.Skin.Input(eb)
    eb.lbl = eb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    eb.lbl:SetPoint("BOTTOM", eb, "TOP", 0, 4)
    eb.lbl:SetText(label)
    return eb
end

local fbRowsEdit   = makeNumBox(newModDialog, "Rows")
local fbColsEdit   = makeNumBox(newModDialog, "Cols")
local fbFramesEdit = makeNumBox(newModDialog, "Frames", 50)
local fbFpsEdit    = makeNumBox(newModDialog, "FPS")

local fbGrid = { fbRowsEdit, fbColsEdit, fbFramesEdit, fbFpsEdit }
local function layoutFbGrid()
    local total, gap = 0, 10
    for _, eb in ipairs(fbGrid) do total = total + eb:GetWidth() end
    total = total + gap * (#fbGrid - 1)
    local x = -total / 2
    for _, eb in ipairs(fbGrid) do
        eb:ClearAllPoints()
        eb:SetPoint("TOPLEFT", newModDialog, "TOP", x, -270)
        x = x + eb:GetWidth() + gap
    end
end

local function SelectFlipbook(fb)
    fbDropdown.selectedFile = fb and fb.file or nil
    if fb then
        fbNameEdit:SetText("")
        imgWEditBox:SetNumber(fb.w or 128)
        imgHEditBox:SetNumber(fb.h or 128)
        fbRowsEdit:SetText(tostring(fb.rows or 1))
        fbColsEdit:SetText(tostring(fb.cols or 1))
        fbFramesEdit:SetText(tostring(fb.frames or 1))
        fbFpsEdit:SetText(tostring(fb.fps or 10))
        fbPathLabel:SetText("Flipbook: " .. (fb.label or fb.file))
    else
        fbPathLabel:SetText("Flipbook")
    end
    if fbDropdown.GenerateMenu then fbDropdown:GenerateMenu() end
end

fbDropdown:SetupMenu(function(dropdown, root)
    local list = SlerneNotes.Flipbooks or {}
    if #list == 0 then
        root:CreateButton("(no built-in flipbooks)", function() end)
        return
    end
    for _, season in ipairs(list) do
        local sMenu = root:CreateButton(season.season)
        for _, clip in ipairs(season.clips or {}) do
            sMenu:CreateRadio(clip.label or clip.file,
                function() return fbDropdown.selectedFile == clip.file end,
                function() SelectFlipbook(clip) end)
        end
    end
end)

local function FirstFight()
    local s = SlerneNotes.Arenas and SlerneNotes.Arenas[1]
    local r = s and s.raids and s.raids[1]
    return r and r.fights and r.fights[1]
end

imageDropdown:SetupMenu(function(dropdown, root)
    local list = SlerneNotes.Arenas or {}
    if #list == 0 then
        root:CreateButton("(no base images)", function() end)
        return
    end
    for _, season in ipairs(list) do
        local sMenu = root:CreateButton(season.season)
        for _, raid in ipairs(season.raids or {}) do
            local rMenu = sMenu:CreateButton(raid.raid)
            for _, fight in ipairs(raid.fights or {}) do
                rMenu:CreateRadio(fight.label,
                    function() return imageDropdown.selectedFile == fight.file end,
                    function() SelectImage(fight) end)
            end
        end
    end
end)

typeDropdown.selectedType = "Assignment"
typeDropdown:SetupMenu(function(dropdown, rootDescription)
    local options = {"Assignment", "List", "Action List", "Image", "Flipbook", "Text Block"}
    for _, opt in ipairs(options) do
        rootDescription:CreateRadio(opt, function() return typeDropdown.selectedType == opt end, function()
            typeDropdown.selectedType = opt

            local slot = (opt == "List" or opt == "Action List")
            lengthEditBox:SetShown(slot)
            dupCheckNew:SetShown(slot)
            if not slot then dupCheckNew:SetChecked(false) end

            for _, eb in ipairs(fbGrid) do eb:Hide() end

            if opt == "Image" then
                newModDialog:SetHeight(380)
                imageDropdown:Show()
                imageNameEdit:Show()
                fbDropdown:Hide()
                fbNameEdit:Hide()
                imgWEditBox:ClearAllPoints()
                imgWEditBox:SetPoint("TOPLEFT", imageNameEdit, "BOTTOMLEFT", 30, -25)
                imgHEditBox:ClearAllPoints()
                imgHEditBox:SetPoint("TOPLEFT", imgWEditBox, "TOPRIGHT", 40, 0)
                imgWEditBox:Show()
                imgHEditBox:Show()
                if not imageDropdown.selectedFile then
                    SelectImage(FirstFight())
                end
            elseif opt == "Flipbook" then
                newModDialog:SetHeight(400)
                imageDropdown:Hide()
                imageNameEdit:Hide()
                fbDropdown:Show()
                fbNameEdit:Show()
                layoutFbGrid()
                for _, eb in ipairs(fbGrid) do eb:Show() end
                imgWEditBox:ClearAllPoints()
                imgWEditBox:SetPoint("TOPLEFT", newModDialog, "TOP", -70, -318)
                imgHEditBox:ClearAllPoints()
                imgHEditBox:SetPoint("TOPLEFT", imgWEditBox, "TOPRIGHT", 40, 0)
                imgWEditBox:Show()
                imgHEditBox:Show()
                if not fbDropdown.selectedFile and strtrim(fbNameEdit:GetText() or "") == "" then
                    SelectFlipbook(SlerneNotes.FirstFlipbook())
                end
            else
                local h = slot and 262 or 200
                newModDialog:SetHeight(h)
                imageDropdown:Hide()
                imageNameEdit:Hide()
                fbDropdown:Hide()
                fbNameEdit:Hide()
                imgWEditBox:Hide()
                imgHEditBox:Hide()
            end
        end)
    end
end)

local createModBtn = CreateFrame("Button", nil, newModDialog, "UIPanelButtonTemplate")
createModBtn:SetSize(85, 24)
createModBtn:SetPoint("BOTTOM", -48, 14)
createModBtn:SetText("Create")
SlerneNotes.Skin.Button(createModBtn)
createModBtn:SetScript("OnClick", function()
    local text = newModEditBox:GetText()
    if text and strtrim(text) ~= "" then

        local isFlipbook = (typeDropdown.selectedType == "Flipbook")
        local imgFile
        if isFlipbook then
            imgFile = strtrim(fbNameEdit:GetText() or "")
            if imgFile == "" then imgFile = fbDropdown.selectedFile or "" end
            if imgFile ~= "" and not imgFile:find("%.") then imgFile = imgFile .. ".png" end
        else
            imgFile = strtrim(imageNameEdit:GetText() or "")
            if imgFile == "" then imgFile = imageDropdown.selectedFile or "" end
            if imgFile ~= "" and not imgFile:find("%.") then imgFile = imgFile .. ".tga" end
        end
        Data_AddModule(
            strtrim(text),
            typeDropdown.selectedType,
            lengthEditBox:GetNumber(),
            imgFile,
            imgWEditBox:GetNumber(),
            imgHEditBox:GetNumber()
        )
        if isFlipbook then
            Data_SetModuleFlipbook(strtrim(text), imgFile,
                imgWEditBox:GetNumber(), imgHEditBox:GetNumber(),
                tonumber(fbRowsEdit:GetText()), tonumber(fbColsEdit:GetText()),
                tonumber(fbFramesEdit:GetText()), tonumber(fbFpsEdit:GetText()))
        end
        if typeDropdown.selectedType == "List" or typeDropdown.selectedType == "Action List" then
            Data_SetModuleAllowDup(strtrim(text), dupCheckNew:GetChecked())
        end
        SlerneNotes.UpdateModules()
        newModDialog:Hide()
    end
end)

local cancelModBtn = CreateFrame("Button", nil, newModDialog, "UIPanelButtonTemplate")
cancelModBtn:SetSize(85, 24)
cancelModBtn:SetPoint("BOTTOM", 48, 14)
cancelModBtn:SetText("Cancel")
SlerneNotes.Skin.Button(cancelModBtn)
cancelModBtn:SetScript("OnClick", function() newModDialog:Hide() end)

newModDialog:SetScript("OnShow", function()
    newModEditBox:SetText(""); lengthEditBox:SetNumber(10)
    imageDropdown.selectedFile = nil
    fbDropdown.selectedFile = nil
    imageNameEdit:SetText("")
    fbNameEdit:SetText("")
    fbPathLabel:SetText("Flipbook")
    imgWEditBox:SetNumber(400); imgHEditBox:SetNumber(300)
    typeDropdown.selectedType = "Assignment"
    lengthEditBox:Hide(); imageDropdown:Hide(); imageNameEdit:Hide()
    fbDropdown:Hide(); fbNameEdit:Hide()
    for _, eb in ipairs(fbGrid) do eb:Hide() end
    imgWEditBox:Hide(); imgHEditBox:Hide()
    dupCheckNew:SetChecked(false); dupCheckNew:Hide()
end)

local newCanvasDialog = CreateFrame("Frame", "SlerneNotesNewCanvasDialog", frame, "BackdropTemplate")
newCanvasDialog:SetSize(280, 200)
newCanvasDialog:SetPoint("CENTER")
newCanvasDialog:SetFrameStrata("FULLSCREEN_DIALOG")
newCanvasDialog:SetFrameLevel(500)
SlerneNotes.Skin.Panel(newCanvasDialog, SlerneNotes.Theme.windowBot, SlerneNotes.Theme.borderLight)
newCanvasDialog:Hide()

local newCanvasTitle = newCanvasDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
newCanvasTitle:SetPoint("TOP", 0, -15); newCanvasTitle:SetText("New Canvas")
SlerneNotes.Skin.Title(newCanvasTitle)

local newCanvasEditBox = CreateFrame("EditBox", nil, newCanvasDialog, "InputBoxTemplate")
newCanvasEditBox:SetSize(180, 20); newCanvasEditBox:SetPoint("TOP", newCanvasTitle, "BOTTOM", 0, -18)
newCanvasEditBox:SetAutoFocus(false)
SlerneNotes.Skin.Input(newCanvasEditBox)

local bossDropdown = CreateFrame("DropdownButton", "SlerneNotesNewCanvasBossDropdown", newCanvasDialog, "WowStyle1DropdownTemplate")
bossDropdown:SetWidth(200); bossDropdown:SetPoint("TOP", newCanvasEditBox, "BOTTOM", 0, -28)
SlerneNotes.Skin.Dropdown(bossDropdown)
bossDropdown.selectedBoss = nil

local bossLabel = bossDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
bossLabel:SetPoint("BOTTOM", bossDropdown, "TOP", 0, 5); bossLabel:SetText("Boss (icons for the draw bar)")

local function bossText()
    if not bossDropdown.selectedBoss then return "None" end
    for _, s in ipairs(SlerneNotes.Arenas or {}) do
        for _, r in ipairs(s.raids or {}) do
            for _, fg in ipairs(r.fights or {}) do
                if fg.file == bossDropdown.selectedBoss then return fg.label end
            end
        end
    end
    return "None"
end

bossDropdown:SetupMenu(function(dropdown, root)
    root:CreateRadio("None",
        function() return bossDropdown.selectedBoss == nil end,
        function() bossDropdown.selectedBoss = nil; bossDropdown:GenerateMenu() end)
    for _, season in ipairs(SlerneNotes.Arenas or {}) do
        local sMenu = root:CreateButton(season.season)
        for _, raid in ipairs(season.raids or {}) do
            local rMenu = sMenu:CreateButton(raid.raid)
            for _, fight in ipairs(raid.fights or {}) do
                if not fight.mapOnly then
                    rMenu:CreateRadio(fight.label,
                        function() return bossDropdown.selectedBoss == fight.file end,
                        function() bossDropdown.selectedBoss = fight.file; bossDropdown:GenerateMenu() end)
                end
            end
        end
    end
end)

local createCanvasBtn = CreateFrame("Button", nil, newCanvasDialog, "UIPanelButtonTemplate")
createCanvasBtn:SetSize(85, 24); createCanvasBtn:SetPoint("BOTTOM", -48, 14); createCanvasBtn:SetText("Create")
createCanvasBtn:SetScript("OnClick", function()
    local name = strtrim(newCanvasEditBox:GetText() or "")
    if name == "" then return end
    Data_SetCanvas(name)
    Data_SetCanvasBoss(name, bossDropdown.selectedBoss)
    SlerneNotes.UpdateModules(); newCanvasDialog:Hide()
    SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
    if SlerneNotes.UpdatePageTabs then SlerneNotes.UpdatePageTabs() end
    if SlerneNotes.RefreshFightPalette then SlerneNotes.RefreshFightPalette() end
    if SlerneNotes.RefreshFooterBoss then SlerneNotes.RefreshFooterBoss() end
    if SlerneNotes.RefreshArchiveButton then SlerneNotes.RefreshArchiveButton() end
    if SlerneNotes.RefreshCanvasDropdown then SlerneNotes.RefreshCanvasDropdown() end
end)
SlerneNotes.Skin.Button(createCanvasBtn)

local cancelCanvasBtn = CreateFrame("Button", nil, newCanvasDialog, "UIPanelButtonTemplate")
cancelCanvasBtn:SetSize(85, 24); cancelCanvasBtn:SetPoint("BOTTOM", 48, 14); cancelCanvasBtn:SetText("Cancel")
cancelCanvasBtn:SetScript("OnClick", function() newCanvasDialog:Hide() end)
SlerneNotes.Skin.Button(cancelCanvasBtn)

newCanvasDialog:SetScript("OnShow", function()
    newCanvasEditBox:SetText("")
    bossDropdown.selectedBoss = nil
    if bossDropdown.GenerateMenu then bossDropdown:GenerateMenu() end
end)

local confirmDeleteDialog = CreateFrame("Frame", "SlerneNotesConfirmDeleteDialog", frame, "BackdropTemplate")
confirmDeleteDialog:SetSize(300, 120)
confirmDeleteDialog:SetPoint("CENTER")
confirmDeleteDialog:SetFrameStrata("FULLSCREEN_DIALOG")
confirmDeleteDialog:SetFrameLevel(500)
SlerneNotes.Skin.Panel(confirmDeleteDialog, SlerneNotes.Theme.windowBot, SlerneNotes.Theme.borderLight)
confirmDeleteDialog:Hide()

local confirmDeleteTitle = confirmDeleteDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
confirmDeleteTitle:SetPoint("TOP", 0, -25)
confirmDeleteTitle:SetText("Delete this Canvas?")
SlerneNotes.Skin.Title(confirmDeleteTitle)

local confirmDeleteYes = CreateFrame("Button", nil, confirmDeleteDialog, "UIPanelButtonTemplate")
confirmDeleteYes:SetSize(80, 25)
confirmDeleteYes:SetPoint("BOTTOMLEFT", 40, 20)
confirmDeleteYes:SetText("Yes")
confirmDeleteYes:SetScript("OnClick", function()
    Data_DeleteCanvas(Data_GetActiveCanvas())
    SlerneNotes.UpdateModules()
    SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
    if SlerneNotes.UpdatePageTabs then SlerneNotes.UpdatePageTabs() end
    if SlerneNotes.RefreshArchiveButton then SlerneNotes.RefreshArchiveButton() end
    if SlerneNotes.RefreshCanvasDropdown then SlerneNotes.RefreshCanvasDropdown() end
    confirmDeleteDialog:Hide()
end)
SlerneNotes.Skin.Button(confirmDeleteYes)

local confirmDeleteNo = CreateFrame("Button", nil, confirmDeleteDialog, "UIPanelButtonTemplate")
confirmDeleteNo:SetSize(80, 25)
confirmDeleteNo:SetPoint("BOTTOMRIGHT", -40, 20)
confirmDeleteNo:SetText("No")
confirmDeleteNo:SetScript("OnClick", function() confirmDeleteDialog:Hide() end)
SlerneNotes.Skin.Button(confirmDeleteNo)

local confirmDelPageDialog = CreateFrame("Frame", "SlerneNotesConfirmDelPageDialog", frame, "BackdropTemplate")
confirmDelPageDialog:SetSize(280, 96)
confirmDelPageDialog:SetPoint("CENTER")
confirmDelPageDialog:SetFrameStrata("FULLSCREEN_DIALOG")
confirmDelPageDialog:SetFrameLevel(500)
confirmDelPageDialog:EnableMouse(true)
SlerneNotes.Skin.Panel(confirmDelPageDialog, SlerneNotes.Theme.windowBot, SlerneNotes.Theme.borderLight)
confirmDelPageDialog:Hide()

local confirmDelPageTitle = confirmDelPageDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
confirmDelPageTitle:SetPoint("TOP", 0, -20)
confirmDelPageTitle:SetText("Delete this page?")
SlerneNotes.Skin.Title(confirmDelPageTitle)

local confirmDelPageYes = CreateFrame("Button", nil, confirmDelPageDialog, "UIPanelButtonTemplate")
confirmDelPageYes:SetSize(75, 24)
confirmDelPageYes:SetPoint("BOTTOM", -45, 16)
confirmDelPageYes:SetText("Yes")
confirmDelPageYes:SetScript("OnClick", function()
    Data_DeletePage(Data_GetActivePage())
    SlerneNotes.UpdateModules()
    SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
    if SlerneNotes.UpdatePageTabs then SlerneNotes.UpdatePageTabs() end
    confirmDelPageDialog:Hide()
end)
SlerneNotes.Skin.Button(confirmDelPageYes)

local confirmDelPageNo = CreateFrame("Button", nil, confirmDelPageDialog, "UIPanelButtonTemplate")
confirmDelPageNo:SetSize(75, 24)
confirmDelPageNo:SetPoint("BOTTOM", 45, 16)
confirmDelPageNo:SetText("No")
confirmDelPageNo:SetScript("OnClick", function() confirmDelPageDialog:Hide() end)
SlerneNotes.Skin.Button(confirmDelPageNo)

local CLASS_LIST = {
    {"DEATHKNIGHT", "Death Knight"}, {"DEMONHUNTER", "Demon Hunter"}, {"DRUID", "Druid"},
    {"EVOKER", "Evoker"}, {"HUNTER", "Hunter"}, {"MAGE", "Mage"}, {"MONK", "Monk"},
    {"PALADIN", "Paladin"}, {"PRIEST", "Priest"}, {"ROGUE", "Rogue"}, {"SHAMAN", "Shaman"},
    {"WARLOCK", "Warlock"}, {"WARRIOR", "Warrior"},
}
local function classColoredName(token)
    for _, c in ipairs(CLASS_LIST) do
        if c[1] == token then return "|cff" .. SlerneNotes.GetClassHex(token) .. c[2] .. "|r" end
    end
    return token or ""
end

local newDummyDialog = CreateFrame("Frame", "SlerneNotesNewDummyDialog", frame, "BackdropTemplate")
newDummyDialog:SetSize(280, 190); newDummyDialog:SetPoint("CENTER")
newDummyDialog:SetFrameStrata("FULLSCREEN_DIALOG"); newDummyDialog:SetFrameLevel(500)
SlerneNotes.Skin.Panel(newDummyDialog, SlerneNotes.Theme.windowBot, SlerneNotes.Theme.borderLight)
newDummyDialog:Hide()

local dummyTitle = newDummyDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
dummyTitle:SetPoint("TOP", 0, -15); dummyTitle:SetText("New Placeholder Player")
SlerneNotes.Skin.Title(dummyTitle)

local dummyNameEdit = CreateFrame("EditBox", nil, newDummyDialog, "InputBoxTemplate")
dummyNameEdit:SetSize(180, 20); dummyNameEdit:SetPoint("TOP", dummyTitle, "BOTTOM", 0, -25)
dummyNameEdit:SetAutoFocus(false)
SlerneNotes.Skin.Input(dummyNameEdit)

local classDropdown = CreateFrame("DropdownButton", "SlerneNotesDummyClassDropdown", newDummyDialog, "WowStyle1DropdownTemplate")
classDropdown:SetPoint("TOP", dummyNameEdit, "BOTTOM", 0, -20); classDropdown:SetWidth(180)
classDropdown.selectedClass = "WARRIOR"
classDropdown:SetupMenu(function(dropdown, rootDescription)
    for _, c in ipairs(CLASS_LIST) do
        rootDescription:CreateRadio(classColoredName(c[1]),
            function() return classDropdown.selectedClass == c[1] end,
            function() classDropdown.selectedClass = c[1] end)
    end
end)
SlerneNotes.Skin.Dropdown(classDropdown)

local createDummyBtn = CreateFrame("Button", nil, newDummyDialog, "UIPanelButtonTemplate")
createDummyBtn:SetSize(85, 24); createDummyBtn:SetPoint("BOTTOM", -48, 14); createDummyBtn:SetText("Create")
createDummyBtn:SetScript("OnClick", function()
    local nm = dummyNameEdit:GetText()
    if nm and strtrim(nm) ~= "" then
        Data_AddDummy(strtrim(nm), classDropdown.selectedClass)
        newDummyDialog:Hide()
        SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
        SlerneNotes.UpdateModules()
    end
end)
SlerneNotes.Skin.Button(createDummyBtn)

local cancelDummyBtn = CreateFrame("Button", nil, newDummyDialog, "UIPanelButtonTemplate")
cancelDummyBtn:SetSize(85, 24); cancelDummyBtn:SetPoint("BOTTOM", 48, 14); cancelDummyBtn:SetText("Cancel")
cancelDummyBtn:SetScript("OnClick", function() newDummyDialog:Hide() end)
SlerneNotes.Skin.Button(cancelDummyBtn)

newDummyDialog:SetScript("OnShow", function()
    dummyNameEdit:SetText("")
    classDropdown.selectedClass = "WARRIOR"
    if classDropdown.GenerateMenu then classDropdown:GenerateMenu() end
end)

local editModDialog = CreateFrame("Frame", "SlerneNotesEditModDialog", frame, "BackdropTemplate")
editModDialog:SetSize(300, 200); editModDialog:SetPoint("CENTER")
editModDialog:SetFrameStrata("FULLSCREEN_DIALOG"); editModDialog:SetFrameLevel(500)
SlerneNotes.Skin.Panel(editModDialog, SlerneNotes.Theme.windowBot, SlerneNotes.Theme.borderLight)
editModDialog:Hide()
editModDialog.modName = nil

local emTitle = editModDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
emTitle:SetPoint("TOP", 0, -15); emTitle:SetText("Edit Module")
SlerneNotes.Skin.Title(emTitle)

local nameEdit = CreateFrame("EditBox", nil, editModDialog, "InputBoxTemplate")
nameEdit:SetSize(200, 20); nameEdit:SetPoint("TOPLEFT", 40, -52); nameEdit:SetAutoFocus(false)
SlerneNotes.Skin.Input(nameEdit)
local nameLabel = nameEdit:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
nameLabel:SetPoint("BOTTOMLEFT", nameEdit, "TOPLEFT", 0, 3); nameLabel:SetText("Box name")

local rowsEdit = CreateFrame("EditBox", nil, editModDialog, "InputBoxTemplate")
rowsEdit:SetSize(50, 20); rowsEdit:SetPoint("TOPLEFT", 40, -100); rowsEdit:SetNumeric(true); rowsEdit:SetAutoFocus(false)
SlerneNotes.Skin.Input(rowsEdit)
local rowsLabel = rowsEdit:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
rowsLabel:SetPoint("BOTTOMLEFT", rowsEdit, "TOPLEFT", 0, 3); rowsLabel:SetText("Rows")

local dupCheck = CreateFrame("CheckButton", nil, editModDialog, "UICheckButtonTemplate")
dupCheck:SetSize(22, 22); dupCheck:SetPoint("TOPLEFT", 40, -128)
local dupCheckLabel = dupCheck:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
dupCheckLabel:SetPoint("LEFT", dupCheck, "RIGHT", 4, 0); dupCheckLabel:SetText("Allow duplicate players")
dupCheckLabel:SetTextColor(1, 1, 1)

local eiDropdown = CreateFrame("DropdownButton", "SlerneNotesEditImgDropdown", editModDialog, "WowStyle1DropdownTemplate")
eiDropdown:SetWidth(220); eiDropdown:SetPoint("TOPLEFT", 38, -150)
SlerneNotes.Skin.Dropdown(eiDropdown)
eiDropdown.selectedFile = nil
local eiPathLabel = eiDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
eiPathLabel:SetPoint("BOTTOMLEFT", eiDropdown, "TOPLEFT", 2, 5); eiPathLabel:SetText("Image")

local eiNameEdit = CreateFrame("EditBox", nil, editModDialog, "InputBoxTemplate")
eiNameEdit:SetSize(220, 20); eiNameEdit:SetPoint("TOPLEFT", 40, -190); eiNameEdit:SetAutoFocus(false)
SlerneNotes.Skin.Input(eiNameEdit)
local eiNameLabel = eiNameEdit:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
eiNameLabel:SetPoint("BOTTOMLEFT", eiNameEdit, "TOPLEFT", 0, 3)
eiNameLabel:SetText("or type a custom filename (e.g. Alleriap3)")

local eiWEdit = CreateFrame("EditBox", nil, editModDialog, "InputBoxTemplate")
eiWEdit:SetSize(50, 20); eiWEdit:SetPoint("TOPLEFT", 60, -240)
eiWEdit:SetNumeric(true); eiWEdit:SetAutoFocus(false); SlerneNotes.Skin.Input(eiWEdit)
local eiWLabel = eiWEdit:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
eiWLabel:SetPoint("BOTTOM", eiWEdit, "TOP", 0, 5); eiWLabel:SetText("Width")

local eiHEdit = CreateFrame("EditBox", nil, editModDialog, "InputBoxTemplate")
eiHEdit:SetSize(50, 20); eiHEdit:SetPoint("TOPLEFT", eiWEdit, "TOPRIGHT", 40, 0)
eiHEdit:SetNumeric(true); eiHEdit:SetAutoFocus(false); SlerneNotes.Skin.Input(eiHEdit)
local eiHLabel = eiHEdit:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
eiHLabel:SetPoint("BOTTOM", eiHEdit, "TOP", 0, 5); eiHLabel:SetText("Height")

local efbDropdown = CreateFrame("DropdownButton", "SlerneNotesEditFbDropdown", editModDialog, "WowStyle1DropdownTemplate")
efbDropdown:SetWidth(220)
SlerneNotes.Skin.Dropdown(efbDropdown)
efbDropdown.selectedFile = nil
local efbPathLabel = efbDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
efbPathLabel:SetPoint("BOTTOMLEFT", efbDropdown, "TOPLEFT", 2, 5); efbPathLabel:SetText("Flipbook")

local efbNameEdit = CreateFrame("EditBox", nil, editModDialog, "InputBoxTemplate")
efbNameEdit:SetSize(220, 20); efbNameEdit:SetAutoFocus(false)
SlerneNotes.Skin.Input(efbNameEdit)
local efbNameLabel = efbNameEdit:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
efbNameLabel:SetPoint("BOTTOMLEFT", efbNameEdit, "TOPLEFT", 0, 3)
efbNameLabel:SetText("or type a custom sheet in img/flipbooks/custom")

local efbRowsEdit   = makeNumBox(editModDialog, "Rows")
local efbColsEdit   = makeNumBox(editModDialog, "Cols")
local efbFramesEdit = makeNumBox(editModDialog, "Frames", 50)
local efbFpsEdit    = makeNumBox(editModDialog, "FPS")
local efbGrid = { efbRowsEdit, efbColsEdit, efbFramesEdit, efbFpsEdit }

local editModOptional = { rowsEdit, dupCheck, eiDropdown, eiNameEdit, eiWEdit, eiHEdit,
                          efbDropdown, efbNameEdit, efbRowsEdit, efbColsEdit, efbFramesEdit, efbFpsEdit }
local function showCtl(c) c:SetAlpha(1); c:Show() end

local function hideCtl(c)
    c:Hide()
    c:SetAlpha(0)
    c:ClearAllPoints()
    c:SetPoint("TOPLEFT", editModDialog, "TOPLEFT", -5000, 0)
end
for _, c in ipairs(editModOptional) do hideCtl(c) end

local function eiSelectImage(img)
    eiDropdown.selectedFile = img and img.file or nil
    if img then
        eiNameEdit:SetText("")
        eiWEdit:SetNumber(img.w or 400)
        eiHEdit:SetNumber(img.h or 300)
        eiPathLabel:SetText("Image: " .. (img.label or img.file))
    else
        eiPathLabel:SetText("Image")
    end
    if eiDropdown.GenerateMenu then eiDropdown:GenerateMenu() end
end

eiDropdown:SetupMenu(function(dropdown, root)
    local list = SlerneNotes.Arenas or {}
    if #list == 0 then root:CreateButton("(no base images)", function() end); return end
    for _, season in ipairs(list) do
        local sMenu = root:CreateButton(season.season)
        for _, raid in ipairs(season.raids or {}) do
            local rMenu = sMenu:CreateButton(raid.raid)
            for _, fight in ipairs(raid.fights or {}) do
                rMenu:CreateRadio(fight.label,
                    function() return eiDropdown.selectedFile == fight.file end,
                    function() eiSelectImage(fight) end)
            end
        end
    end
end)

local function efbSelect(fb)
    efbDropdown.selectedFile = fb and fb.file or nil
    if fb then
        efbNameEdit:SetText("")
        eiWEdit:SetNumber(fb.w or 128)
        eiHEdit:SetNumber(fb.h or 128)
        efbRowsEdit:SetText(tostring(fb.rows or 1))
        efbColsEdit:SetText(tostring(fb.cols or 1))
        efbFramesEdit:SetText(tostring(fb.frames or 1))
        efbFpsEdit:SetText(tostring(fb.fps or 10))
        efbPathLabel:SetText("Flipbook: " .. (fb.label or fb.file))
    else
        efbPathLabel:SetText("Flipbook")
    end
    if efbDropdown.GenerateMenu then efbDropdown:GenerateMenu() end
end

efbDropdown:SetupMenu(function(dropdown, root)
    local list = SlerneNotes.Flipbooks or {}
    if #list == 0 then root:CreateButton("(no built-in flipbooks)", function() end); return end
    for _, season in ipairs(list) do
        local sMenu = root:CreateButton(season.season)
        for _, clip in ipairs(season.clips or {}) do
            sMenu:CreateRadio(clip.label or clip.file,
                function() return efbDropdown.selectedFile == clip.file end,
                function() efbSelect(clip) end)
        end
    end
end)

local emSaveBtn = CreateFrame("Button", nil, editModDialog, "UIPanelButtonTemplate")
emSaveBtn:SetSize(85, 24); emSaveBtn:SetPoint("BOTTOM", -48, 14); emSaveBtn:SetText("Save")
SlerneNotes.Skin.Button(emSaveBtn)
emSaveBtn:SetScript("OnClick", function()
    local old = editModDialog.modName
    if not old then editModDialog:Hide(); return end

    local eff = old
    local newName = strtrim(nameEdit:GetText() or "")
    if newName ~= "" and newName ~= old then
        Data_RenameModule(old, newName)
        local layout = Data_GetCurrentLayout()
        if layout and layout[newName] and not layout[old] then eff = newName end
    end

    if editModDialog.hasRows then
        Data_SetModuleLength(eff, rowsEdit:GetNumber())
        Data_SetModuleAllowDup(eff, dupCheck:GetChecked())
    end
    if editModDialog.hasImage then

        local imgFile = strtrim(eiNameEdit:GetText() or "")
        if imgFile == "" then imgFile = eiDropdown.selectedFile or "" end
        if imgFile ~= "" and not imgFile:find("%.") then imgFile = imgFile .. ".tga" end
        Data_SetModuleImage(eff, imgFile, eiWEdit:GetNumber(), eiHEdit:GetNumber())
    end
    if editModDialog.hasFlipbook then
        local fbFile = strtrim(efbNameEdit:GetText() or "")
        if fbFile == "" then fbFile = efbDropdown.selectedFile or "" end
        if fbFile ~= "" and not fbFile:find("%.") then fbFile = fbFile .. ".png" end
        Data_SetModuleFlipbook(eff, fbFile, eiWEdit:GetNumber(), eiHEdit:GetNumber(),
            tonumber(efbRowsEdit:GetText()), tonumber(efbColsEdit:GetText()),
            tonumber(efbFramesEdit:GetText()), tonumber(efbFpsEdit:GetText()))
    end

    SlerneNotes.UpdateModules()
    SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
    editModDialog:Hide()
end)

local emCancelBtn = CreateFrame("Button", nil, editModDialog, "UIPanelButtonTemplate")
emCancelBtn:SetSize(85, 24); emCancelBtn:SetPoint("BOTTOM", 48, 14); emCancelBtn:SetText("Cancel")
SlerneNotes.Skin.Button(emCancelBtn)
emCancelBtn:SetScript("OnClick", function() editModDialog:Hide() end)

function SlerneNotes.ShowEditModuleDialog(modName, meta)
    editModDialog.modName = modName
    local t = meta and meta.type or "Assignment"
    local hasRows = (t == "List" or t == "Image List" or t == "Action List")
    local hasImage = (t == "Image" or t == "Image List")
    local hasFlipbook = (t == "Flipbook")
    editModDialog.hasRows = hasRows
    editModDialog.hasImage = hasImage
    editModDialog.hasFlipbook = hasFlipbook

    for _, c in ipairs(editModOptional) do hideCtl(c) end

    local pad = 40
    local cursor = -52

    nameEdit:SetText(modName or "")
    nameEdit:ClearAllPoints(); nameEdit:SetPoint("TOPLEFT", pad, cursor); nameEdit:Show()
    cursor = cursor - 44

    if hasRows then
        rowsEdit:SetNumber(meta.length or 0)
        rowsEdit:ClearAllPoints(); rowsEdit:SetPoint("TOPLEFT", pad, cursor); showCtl(rowsEdit)
        cursor = cursor - 36

        dupCheck:SetChecked(meta.allowDup and true or false)
        dupCheck:ClearAllPoints(); dupCheck:SetPoint("TOPLEFT", pad - 2, cursor); showCtl(dupCheck)
        cursor = cursor - 32
    end

    if hasImage then
        local img = meta and meta.image or ""
        if img ~= "" and string.find(img, "[\\/]") then
            eiDropdown.selectedFile = img
            eiNameEdit:SetText("")
            eiPathLabel:SetText("Image")
            for _, s in ipairs(SlerneNotes.Arenas or {}) do
                for _, r in ipairs(s.raids or {}) do
                    for _, fg in ipairs(r.fights or {}) do
                        if fg.file == img then eiPathLabel:SetText("Image: " .. fg.label) end
                    end
                end
            end
        else
            eiDropdown.selectedFile = nil
            eiNameEdit:SetText((img:gsub("%.tga$", "")))
            eiPathLabel:SetText("Image")
        end
        eiWEdit:SetNumber(meta and meta.imgW or 400)
        eiHEdit:SetNumber(meta and meta.imgH or 300)
        if eiDropdown.GenerateMenu then eiDropdown:GenerateMenu() end

        cursor = cursor - 8
        eiDropdown:ClearAllPoints(); eiDropdown:SetPoint("TOPLEFT", pad - 2, cursor); showCtl(eiDropdown)
        cursor = cursor - 44
        eiNameEdit:ClearAllPoints(); eiNameEdit:SetPoint("TOPLEFT", pad, cursor); showCtl(eiNameEdit)
        cursor = cursor - 48
        eiWEdit:ClearAllPoints(); eiWEdit:SetPoint("TOPLEFT", pad + 20, cursor); showCtl(eiWEdit)
        eiHEdit:ClearAllPoints(); eiHEdit:SetPoint("TOPLEFT", eiWEdit, "TOPRIGHT", 40, 0); showCtl(eiHEdit)
        cursor = cursor - 34
    end

    if hasFlipbook then
        local img = meta and meta.image or ""
        local fb = SlerneNotes.GetFlipbook and SlerneNotes.GetFlipbook(img)
        if fb then
            efbDropdown.selectedFile = img
            efbNameEdit:SetText("")
            efbPathLabel:SetText("Flipbook: " .. (fb.label or fb.file))
        else
            efbDropdown.selectedFile = nil
            efbNameEdit:SetText((img:gsub("%.png$", "")))
            efbPathLabel:SetText("Flipbook")
        end
        eiWEdit:SetNumber((meta and meta.imgW) or (fb and fb.w) or 128)
        eiHEdit:SetNumber((meta and meta.imgH) or (fb and fb.h) or 128)
        efbRowsEdit:SetText(tostring((meta and meta.fbRows) or (fb and fb.rows) or 1))
        efbColsEdit:SetText(tostring((meta and meta.fbCols) or (fb and fb.cols) or 1))
        efbFramesEdit:SetText(tostring((meta and meta.fbFrames) or (fb and fb.frames) or 1))
        efbFpsEdit:SetText(tostring((meta and meta.fbFps) or (fb and fb.fps) or 10))
        if efbDropdown.GenerateMenu then efbDropdown:GenerateMenu() end

        cursor = cursor - 8
        efbDropdown:ClearAllPoints(); efbDropdown:SetPoint("TOPLEFT", pad - 2, cursor); showCtl(efbDropdown)
        cursor = cursor - 44
        efbNameEdit:ClearAllPoints(); efbNameEdit:SetPoint("TOPLEFT", pad, cursor); showCtl(efbNameEdit)
        cursor = cursor - 46
        local gx = pad
        for _, eb in ipairs(efbGrid) do
            eb:ClearAllPoints(); eb:SetPoint("TOPLEFT", gx, cursor); showCtl(eb)
            gx = gx + (eb:GetWidth() or 44) + 10
        end
        cursor = cursor - 46
        eiWEdit:ClearAllPoints(); eiWEdit:SetPoint("TOPLEFT", pad + 20, cursor); showCtl(eiWEdit)
        eiHEdit:ClearAllPoints(); eiHEdit:SetPoint("TOPLEFT", eiWEdit, "TOPRIGHT", 40, 0); showCtl(eiHEdit)
        cursor = cursor - 34
    end

    editModDialog:SetHeight(math.max(150, -cursor + 48))
    editModDialog:Show()
end

local confirmArchiveDialog = CreateFrame("Frame", "SlerneNotesConfirmArchiveDialog", frame, "BackdropTemplate")
confirmArchiveDialog:SetSize(340, 140)
confirmArchiveDialog:SetPoint("CENTER")
confirmArchiveDialog:SetFrameStrata("FULLSCREEN_DIALOG")
confirmArchiveDialog:SetFrameLevel(500)
SlerneNotes.Skin.Panel(confirmArchiveDialog, SlerneNotes.Theme.windowBot, SlerneNotes.Theme.borderLight)
confirmArchiveDialog:Hide()

local confirmArchiveTitle = confirmArchiveDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
confirmArchiveTitle:SetPoint("TOP", 0, -22)
confirmArchiveTitle:SetText("Archive this canvas?")
SlerneNotes.Skin.Title(confirmArchiveTitle)

local confirmArchiveBody = confirmArchiveDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
confirmArchiveBody:SetPoint("TOP", confirmArchiveTitle, "BOTTOM", 0, -10)
confirmArchiveBody:SetWidth(290)
confirmArchiveBody:SetText("It moves into the Archive folder in the canvas dropdown. Nothing is deleted.")
confirmArchiveBody:SetTextColor(0.8, 0.8, 0.8)

local confirmArchiveYes = CreateFrame("Button", nil, confirmArchiveDialog, "UIPanelButtonTemplate")
confirmArchiveYes:SetSize(80, 25)
confirmArchiveYes:SetPoint("BOTTOMLEFT", 55, 18)
confirmArchiveYes:SetText("Archive")
confirmArchiveYes:SetScript("OnClick", function()
    Data_SetCanvasArchived(Data_GetActiveCanvas(), true)
    if SlerneNotes.RefreshArchiveButton then SlerneNotes.RefreshArchiveButton() end
    if SlerneNotes.RefreshCanvasDropdown then SlerneNotes.RefreshCanvasDropdown() end
    confirmArchiveDialog:Hide()
end)
SlerneNotes.Skin.Button(confirmArchiveYes)

local confirmArchiveNo = CreateFrame("Button", nil, confirmArchiveDialog, "UIPanelButtonTemplate")
confirmArchiveNo:SetSize(80, 25)
confirmArchiveNo:SetPoint("BOTTOMRIGHT", -55, 18)
confirmArchiveNo:SetText("Cancel")
confirmArchiveNo:SetScript("OnClick", function() confirmArchiveDialog:Hide() end)
SlerneNotes.Skin.Button(confirmArchiveNo)

confirmArchiveDialog:SetScript("OnShow", function()
    local name = Data_GetActiveCanvas()
    confirmArchiveTitle:SetText("Archive \"" .. (name or "") .. "\"?")
end)

function SlerneNotes.ShowConfirmArchiveDialog() confirmArchiveDialog:Show() end

local dialogDimmer = CreateFrame("Frame", nil, UIParent)
dialogDimmer:SetAllPoints(UIParent)
dialogDimmer:SetFrameStrata("FULLSCREEN_DIALOG")
dialogDimmer:EnableMouse(true)
local dimTex = dialogDimmer:CreateTexture(nil, "BACKGROUND")
dimTex:SetAllPoints()
dimTex:SetColorTexture(0, 0, 0, 0.85)
dialogDimmer:Hide()

local function PrepDialog(dlg)
    if dlg.SetBackdropColor then dlg:SetBackdropColor(0.06, 0.04, 0.08, 1) end
    dlg:HookScript("OnShow", function(self)
        self:SetFrameLevel((frame:GetFrameLevel() or 0) + 250)
        dialogDimmer:SetFrameLevel(math.max(1, self:GetFrameLevel() - 20))
        dialogDimmer:Show()
    end)
    dlg:HookScript("OnHide", function() dialogDimmer:Hide() end)
end
for _, d in ipairs({ newModDialog, newCanvasDialog, confirmDeleteDialog, confirmDelPageDialog, newDummyDialog, editModDialog, confirmArchiveDialog }) do
    PrepDialog(d)
end

function SlerneNotes.ShowNewDummyDialog() newDummyDialog:Show() end
function SlerneNotes.ShowNewModDialog() newModDialog:Show() end
function SlerneNotes.ShowNewCanvasDialog() newCanvasDialog:Show() end
function SlerneNotes.ShowConfirmDeleteDialog() confirmDeleteDialog:Show() end
function SlerneNotes.ShowConfirmDeletePage()
    if Data_GetPageCount() <= 1 then
        print("Slerne Notes: A canvas must keep at least one page.")
        return
    end
    confirmDelPageDialog:Show()
end
