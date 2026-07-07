local addonName, SlerneNotes = ...
local regTab = SlerneNotes.registriesTab

local footer = CreateFrame("Frame", nil, regTab, "BackdropTemplate")
footer:SetHeight(50)
footer:SetPoint("BOTTOMLEFT", 0, 0)
footer:SetPoint("BOTTOMRIGHT", 0, 0)
SlerneNotes.Skin.Panel(footer)

local canvasArea = CreateFrame("Frame", nil, regTab, "BackdropTemplate")
canvasArea:SetPoint("TOPLEFT", 0, 0)
canvasArea:SetPoint("BOTTOMRIGHT", 0, 50)

local newCanvasDialog = CreateFrame("Frame", "SlerneNotesRegNewCanvasDialog", SlerneNotes.frame, "BackdropTemplate")
newCanvasDialog:SetSize(300, 140); newCanvasDialog:SetPoint("CENTER")
newCanvasDialog:SetFrameStrata("FULLSCREEN_DIALOG"); newCanvasDialog:SetFrameLevel(500)
SlerneNotes.Skin.Panel(newCanvasDialog, SlerneNotes.Theme.windowBot, SlerneNotes.Theme.borderLight)
newCanvasDialog:Hide()

local newCanvasEditBox = CreateFrame("EditBox", nil, newCanvasDialog, "InputBoxTemplate")
newCanvasEditBox:SetSize(160, 20); newCanvasEditBox:SetPoint("CENTER", 0, 10)
SlerneNotes.Skin.Input(newCanvasEditBox)

local createCanvasBtn = CreateFrame("Button", nil, newCanvasDialog, "UIPanelButtonTemplate")
createCanvasBtn:SetSize(90, 25); createCanvasBtn:SetPoint("BOTTOMLEFT", 20, 15); createCanvasBtn:SetText("Create")
createCanvasBtn:SetScript("OnClick", function()
    Data_SetRegistryCanvas(newCanvasEditBox:GetText())
    SlerneNotes.UpdateRegistryModules(); newCanvasDialog:Hide()
end)
SlerneNotes.Skin.Button(createCanvasBtn)
local cancelCanvasBtn = CreateFrame("Button", nil, newCanvasDialog, "UIPanelButtonTemplate")
cancelCanvasBtn:SetSize(90, 25); cancelCanvasBtn:SetPoint("BOTTOMRIGHT", -20, 15); cancelCanvasBtn:SetText("Cancel")
cancelCanvasBtn:SetScript("OnClick", function() newCanvasDialog:Hide() end)
SlerneNotes.Skin.Button(cancelCanvasBtn)

local confirmDeleteDialog = CreateFrame("Frame", "SlerneNotesRegConfirmDeleteDialog", SlerneNotes.frame, "BackdropTemplate")
confirmDeleteDialog:SetSize(300, 120); confirmDeleteDialog:SetPoint("CENTER")
confirmDeleteDialog:SetFrameStrata("FULLSCREEN_DIALOG"); confirmDeleteDialog:SetFrameLevel(500)
SlerneNotes.Skin.Panel(confirmDeleteDialog, SlerneNotes.Theme.windowBot, SlerneNotes.Theme.borderLight)
confirmDeleteDialog:Hide()

local confirmDeleteTitle = confirmDeleteDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
confirmDeleteTitle:SetPoint("TOP", 0, -25); confirmDeleteTitle:SetText("Delete this Registries Canvas?")
SlerneNotes.Skin.Title(confirmDeleteTitle)

local confirmDeleteYes = CreateFrame("Button", nil, confirmDeleteDialog, "UIPanelButtonTemplate")
confirmDeleteYes:SetSize(80, 25); confirmDeleteYes:SetPoint("BOTTOMLEFT", 40, 20); confirmDeleteYes:SetText("Yes")
confirmDeleteYes:SetScript("OnClick", function()
    Data_DeleteRegistryCanvas(Data_GetActiveRegistryCanvas())
    SlerneNotes.UpdateRegistryModules(); confirmDeleteDialog:Hide()
end)
SlerneNotes.Skin.Button(confirmDeleteYes)
local confirmDeleteNo = CreateFrame("Button", nil, confirmDeleteDialog, "UIPanelButtonTemplate")
confirmDeleteNo:SetSize(80, 25); confirmDeleteNo:SetPoint("BOTTOMRIGHT", -40, 20); confirmDeleteNo:SetText("No")
confirmDeleteNo:SetScript("OnClick", function() confirmDeleteDialog:Hide() end)
SlerneNotes.Skin.Button(confirmDeleteNo)

local newModDialog = CreateFrame("Frame", "SlerneNotesRegNewModDialog", SlerneNotes.frame, "BackdropTemplate")
newModDialog:SetSize(300, 200); newModDialog:SetPoint("CENTER")
newModDialog:SetFrameStrata("FULLSCREEN_DIALOG"); newModDialog:SetFrameLevel(500)
SlerneNotes.Skin.Panel(newModDialog, SlerneNotes.Theme.windowBot, SlerneNotes.Theme.borderLight)
newModDialog:Hide()

local newModTitle = newModDialog:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
newModTitle:SetPoint("TOP", 0, -15); newModTitle:SetText("Create Registry")
SlerneNotes.Skin.Title(newModTitle)

local newModEditBox = CreateFrame("EditBox", nil, newModDialog, "InputBoxTemplate")
newModEditBox:SetSize(160, 20); newModEditBox:SetPoint("TOP", newModTitle, "BOTTOM", 0, -15)
SlerneNotes.Skin.Input(newModEditBox)

local typeDropdown = CreateFrame("DropdownButton", "SlerneNotesRegTypeDropdown", newModDialog, "WowStyle1DropdownTemplate")
typeDropdown:SetPoint("TOP", newModEditBox, "BOTTOM", 0, -15)
typeDropdown:SetWidth(150)
typeDropdown.selectedType = "Manual"
SlerneNotes.Skin.Dropdown(typeDropdown)

typeDropdown:SetupMenu(function(dropdown, rootDescription)
    rootDescription:CreateRadio("Manual", function() return typeDropdown.selectedType == "Manual" end, function() typeDropdown.selectedType = "Manual" end)
    rootDescription:CreateRadio("Countdown", function() return typeDropdown.selectedType == "Countdown" end, function() typeDropdown.selectedType = "Countdown" end)
end)

local createModBtn = CreateFrame("Button", nil, newModDialog, "UIPanelButtonTemplate")
createModBtn:SetSize(90, 25); createModBtn:SetPoint("BOTTOMLEFT", 20, 15); createModBtn:SetText("Create")
createModBtn:SetScript("OnClick", function()
    local text = newModEditBox:GetText()
    if text and strtrim(text) ~= "" then
        Data_AddRegistryModule(strtrim(text), typeDropdown.selectedType)
        SlerneNotes.UpdateRegistryModules(); newModDialog:Hide()
    end
end)
SlerneNotes.Skin.Button(createModBtn)
local cancelModBtn = CreateFrame("Button", nil, newModDialog, "UIPanelButtonTemplate")
cancelModBtn:SetSize(90, 25); cancelModBtn:SetPoint("BOTTOMRIGHT", -20, 15); cancelModBtn:SetText("Cancel")
cancelModBtn:SetScript("OnClick", function() newModDialog:Hide() end)
SlerneNotes.Skin.Button(cancelModBtn)

local btnNewCanvas = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
btnNewCanvas:SetSize(120, 30); btnNewCanvas:SetPoint("LEFT", 15, 0); btnNewCanvas:SetText("New Canvas")
btnNewCanvas:SetScript("OnClick", function() newCanvasDialog:Show() end)
SlerneNotes.Skin.Button(btnNewCanvas)

local canvasDropdown = CreateFrame("DropdownButton", "SlerneNotesRegCanvasDropdown", footer, "WowStyle1DropdownTemplate")
canvasDropdown:SetPoint("LEFT", btnNewCanvas, "RIGHT", 10, 0); canvasDropdown:SetWidth(140)
SlerneNotes.Skin.Dropdown(canvasDropdown)

local btnDelCanvas = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
btnDelCanvas:SetSize(120, 30); btnDelCanvas:SetPoint("LEFT", canvasDropdown, "RIGHT", 15, 0); btnDelCanvas:SetText("Delete Canvas")
btnDelCanvas:SetScript("OnClick", function() confirmDeleteDialog:Show() end)
SlerneNotes.Skin.Button(btnDelCanvas)

local btnNewMod = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
btnNewMod:SetSize(120, 30); btnNewMod:SetPoint("CENTER", 0, 0); btnNewMod:SetText("New Registry")
btnNewMod:SetScript("OnClick", function() newModEditBox:SetText(""); newModDialog:Show() end)
SlerneNotes.Skin.Button(btnNewMod)

local btnExit = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
btnExit:SetSize(100, 30); btnExit:SetPoint("RIGHT", -15, 0); btnExit:SetText("Exit")
btnExit:SetScript("OnClick", function() SlerneNotes.frame:Hide() end)
SlerneNotes.Skin.Button(btnExit)

local popoutFrames = {}

local function SpawnPopout(modName, text, regType)
    local old = popoutFrames[modName]
    if old then
        old:UnregisterAllEvents()
        old:SetScript("OnUpdate", nil)
        old:Hide()
    end

    local isCountdown = (regType == "Countdown" or regType == "Timed")
    local hasTimer = isCountdown

    local pop = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    pop:SetWidth(250)
    pop:SetPoint("CENTER")
    pop:SetFrameStrata("FULLSCREEN_DIALOG")
    pop:SetMovable(true); pop:EnableMouse(true)
    pop:RegisterForDrag("LeftButton")
    pop:SetScript("OnDragStart", pop.StartMoving)
    pop:SetScript("OnDragStop", pop.StopMovingOrSizing)
    SlerneNotes.Skin.Module(pop)

    local title = pop:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -10)
    title:SetText(modName)
    SlerneNotes.Skin.Title(title)

    local yOffset = -35

    if hasTimer then
        pop.timerText = pop:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        pop.timerText:SetPoint("TOP", title, "BOTTOM", 0, -5)
        pop.timerText:SetText("0:00")
        yOffset = -55
    end

    local closeBtn = CreateFrame("Button", nil, pop, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", pop, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function()
        pop:SetScript("OnUpdate", nil)
        pop:UnregisterAllEvents()
        pop:Hide()
    end)
    SlerneNotes.Skin.CloseButton(closeBtn)

    local resetBtn = CreateFrame("Button", nil, pop, "UIPanelButtonTemplate")
    resetBtn:SetSize(80, 22)
    resetBtn:SetPoint("BOTTOM", 0, 10)
    resetBtn:SetText("Reset")
    SlerneNotes.Skin.Button(resetBtn)

    local lines = {strsplit("\n", text)}
    local lineBtns = {}

    local function parseTime(lineText)
        local m, s = string.match(lineText, "^(%d+):(%d%d)")
        if m and s then return tonumber(m) * 60 + tonumber(s) end
        return nil
    end

    for i, lineText in ipairs(lines) do
        if strtrim(lineText) ~= "" then
            local btn = CreateFrame("Button", nil, pop)
            btn:SetSize(230, 20)
            btn:SetPoint("TOPLEFT", 10, yOffset)

            local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            fs:SetPoint("LEFT", 0, 0)
            fs:SetText(lineText)
            fs:SetJustifyH("LEFT")
            btn:SetFontString(fs)

            btn.isActive = true
            btn.autoTriggered = false
            btn.targetTime = hasTimer and parseTime(lineText) or nil

            if not hasTimer then
                btn:SetScript("OnClick", function(self)
                    self.isActive = not self.isActive
                    if self.isActive then
                        self:GetFontString():SetTextColor(1, 1, 1, 1)
                    else
                        self:GetFontString():SetTextColor(0.4, 0.4, 0.4, 1)
                    end
                end)
            end

            table.insert(lineBtns, btn)
            yOffset = yOffset - 25
        end
    end

    pop:SetHeight(math.abs(yOffset) + 40)

    local function ResetLines()
        for _, btn in ipairs(lineBtns) do
            btn.isActive = true
            btn.autoTriggered = false
            btn:GetFontString():SetTextColor(1, 1, 1, 1)
        end
        if hasTimer then
            pop.timerText:SetText("0:00")
        end
    end

    resetBtn:SetScript("OnClick", ResetLines)

    if isCountdown then
        pop:RegisterEvent("PLAYER_REGEN_DISABLED")
        pop:RegisterEvent("PLAYER_REGEN_ENABLED")

        pop:SetScript("OnEvent", function(self, event)
            if event == "PLAYER_REGEN_DISABLED" then
                self.startTime = GetTime()
                self:SetScript("OnUpdate", function(self, elapsed)
                    local diff = GetTime() - self.startTime
                    local m = math.floor(diff / 60)
                    local s = math.floor(diff % 60)
                    self.timerText:SetText(string.format("%d:%02d", m, s))

                    for _, btn in ipairs(lineBtns) do
                        if btn.targetTime and not btn.autoTriggered and diff >= btn.targetTime then
                            btn.isActive = false
                            btn.autoTriggered = true
                            btn:GetFontString():SetTextColor(0.4, 0.4, 0.4, 1)
                        end
                    end
                end)
            elseif event == "PLAYER_REGEN_ENABLED" then
                self:SetScript("OnUpdate", nil)
                ResetLines()
            end
        end)
    end

    popoutFrames[modName] = pop
    return pop
end

local modPool = {}
local function Clear(f)
    for _, c in ipairs({f:GetChildren()}) do c:Hide() end
end

function SlerneNotes.UpdateRegistryModules()
    Clear(canvasArea)

    canvasDropdown:SetupMenu(function(dropdown, rootDescription)
        for cName in pairs(Data_GetRegistryCanvases() or {}) do
            rootDescription:CreateRadio(cName, function() return cName == Data_GetActiveRegistryCanvas() end, function()
                Data_SetRegistryCanvas(cName)
                SlerneNotes.UpdateRegistryModules()
            end)
        end
    end)

    local layout = Data_GetRegistryLayout() or {}
    local index = 0

    for modName, modData in pairs(layout) do
        index = index + 1
        local modFrame = modPool[index]

        if not modFrame then
            modFrame = CreateFrame("Frame", nil, canvasArea, "BackdropTemplate")
            modFrame:SetSize(250, 230)
            SlerneNotes.Skin.Module(modFrame)

            modFrame:SetMovable(true); modFrame:EnableMouse(true)
            modFrame:RegisterForDrag("LeftButton")
            modFrame:SetScript("OnDragStart", modFrame.StartMoving)
            modFrame:SetScript("OnDragStop", function(self)
                self:StopMovingOrSizing()
                local pX, pY = canvasArea:GetLeft(), canvasArea:GetTop()
                local fX, fY = self:GetLeft(), self:GetTop()
                if pX and pY and fX and fY then
                    local relX, relY = fX - pX, fY - pY
                    Data_SetRegistryModulePos(self.modName, relX, relY)
                    self:ClearAllPoints()
                    self:SetPoint("TOPLEFT", canvasArea, "TOPLEFT", relX, relY)
                end
            end)

            modFrame.title = modFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            modFrame.title:SetPoint("TOP", 0, -5)
            SlerneNotes.Skin.Title(modFrame.title)

            modFrame.closeBtn = CreateFrame("Button", nil, modFrame, "UIPanelCloseButton")
            modFrame.closeBtn:SetSize(24, 24); modFrame.closeBtn:SetPoint("TOPRIGHT", modFrame, "TOPRIGHT", 2, 2)
            SlerneNotes.Skin.CloseButton(modFrame.closeBtn)

            modFrame.exportBtn = CreateFrame("Button", nil, modFrame, "UIPanelButtonTemplate")
            modFrame.exportBtn:SetSize(80, 22)
            modFrame.exportBtn:SetPoint("BOTTOM", 0, 10)
            modFrame.exportBtn:SetText("Export")
            SlerneNotes.Skin.Button(modFrame.exportBtn)

            modFrame.editBox = CreateFrame("EditBox", nil, modFrame)
            modFrame.editBox:SetMultiLine(true); modFrame.editBox:SetAutoFocus(false)
            modFrame.editBox:SetFontObject(ChatFontNormal)
            modFrame.editBox:SetPoint("TOPLEFT", 15, -30)
            modFrame.editBox:SetWidth(200)
            modFrame.editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

            modFrame.measure = modFrame:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
            modFrame.measure:Hide()

            modFrame.DoResize = function()
                local text = modFrame.editBox:GetText() or ""
                local lineCount, maxW = 0, 70
                for line in (text .. "\n"):gmatch("(.-)\n") do
                    lineCount = lineCount + 1
                    modFrame.measure:SetText(line ~= "" and line or " ")
                    maxW = math.max(maxW, modFrame.measure:GetStringWidth())
                end
                if lineCount < 1 then lineCount = 1 end
                local boxW = math.ceil(maxW) + 12
                local boxH = lineCount * 14
                modFrame.editBox:SetWidth(boxW)
                modFrame.editBox:SetHeight(boxH)
                local titleW = (modFrame.title:GetStringWidth() or 0) + 55
                modFrame:SetSize(math.max(boxW + 30, titleW, 150), boxH + 78)
            end

            modPool[index] = modFrame
        end

        modFrame.modName = modName

        local displayTitle = modName
        if modData.type == "Timed" or modData.type == "Countdown" then displayTitle = displayTitle .. " (Countdown)" end
        modFrame.title:SetText(displayTitle)

        modFrame.editBox:SetScript("OnTextChanged", nil)
        modFrame.editBox:SetText(modData.text or "")
        modFrame.DoResize()
        modFrame.editBox:SetScript("OnTextChanged", function(self, isUserInput)
            if isUserInput then Data_SetRegistryModuleText(modName, self:GetText()) end
            modFrame.DoResize()
        end)

        modFrame.closeBtn:SetScript("OnClick", function()
            Data_RemoveRegistryModule(modName)
            SlerneNotes.UpdateRegistryModules()
        end)

        modFrame.exportBtn:SetScript("OnClick", function()
            SpawnPopout(modName, modFrame.editBox:GetText(), modData.type or "Manual")
        end)

        modFrame:ClearAllPoints()

        modFrame:SetPoint("TOPLEFT", canvasArea, "TOPLEFT", modData.posX or 1400, modData.posY or -650)
        modFrame:Show()
    end
end
