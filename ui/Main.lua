local addonName, SlerneNotes = ...
local frame = SlerneNotes.frame

frame:SetSize(1800, 1000)
frame:SetPoint("CENTER")
frame:SetFrameStrata("FULLSCREEN_DIALOG")
frame:EnableMouse(true)
frame:SetMovable(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

tinsert(UISpecialFrames, "SlerneNotesFrame")

local bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
bg:SetPoint("TOPLEFT", frame, "TOPLEFT", 110, 0)
bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
bg:SetFrameLevel(frame:GetFrameLevel() + 5)
SlerneNotes.Skin.OuterFrame(bg)

local tabBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
tabBar:SetSize(90, 980)
tabBar:SetPoint("TOPLEFT", 10, -10)

local btnNotes = CreateFrame("Button", nil, tabBar, "UIPanelButtonTemplate")
btnNotes:SetSize(108, 54); btnNotes:SetPoint("TOPRIGHT", tabBar, "TOPRIGHT", 22, -16)
btnNotes:SetText("Notes")

local btnRoster = CreateFrame("Button", nil, tabBar, "UIPanelButtonTemplate")
btnRoster:SetSize(108, 54); btnRoster:SetPoint("TOPRIGHT", btnNotes, "BOTTOMRIGHT", 0, -10)
btnRoster:SetText("Roster")

local btnRegistries = CreateFrame("Button", nil, tabBar, "UIPanelButtonTemplate")
btnRegistries:SetSize(108, 54); btnRegistries:SetPoint("TOPRIGHT", btnRoster, "BOTTOMRIGHT", 0, -10)
btnRegistries:SetText("Registries")
btnRegistries:GetFontString():SetFontObject("GameFontNormalSmall")

local btnLoot = CreateFrame("Button", nil, tabBar, "UIPanelButtonTemplate")
btnLoot:SetSize(108, 54); btnLoot:SetPoint("TOPRIGHT", btnRegistries, "BOTTOMRIGHT", 0, -10)
btnLoot:SetText("Loot")

local btnConfig = CreateFrame("Button", nil, tabBar, "UIPanelButtonTemplate")
btnConfig:SetSize(108, 54); btnConfig:SetPoint("TOPRIGHT", btnLoot, "BOTTOMRIGHT", 0, -10)
btnConfig:SetText("Config")

SlerneNotes.Skin.FolderTab(btnNotes)
SlerneNotes.Skin.FolderTab(btnRoster)
SlerneNotes.Skin.FolderTab(btnRegistries)
SlerneNotes.Skin.FolderTab(btnLoot)
SlerneNotes.Skin.FolderTab(btnConfig)
SlerneNotes.tabs = { btnNotes, btnRoster, btnRegistries, btnLoot, btnConfig }
local function SetActiveTab(active)
    for _, t in ipairs(SlerneNotes.tabs) do
        SlerneNotes.Skin.SetFolderTabActive(t, t == active)
    end
end

local CONTENT_INSET = 22
local CONTENT_LEVEL = frame:GetFrameLevel() + 15

SlerneNotes.notesTab = CreateFrame("Frame", nil, frame)
SlerneNotes.notesTab:SetPoint("TOPLEFT", bg, "TOPLEFT", CONTENT_INSET, -CONTENT_INSET)
SlerneNotes.notesTab:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -CONTENT_INSET, CONTENT_INSET)
SlerneNotes.notesTab:SetFrameLevel(CONTENT_LEVEL)

SlerneNotes.rosterTab = CreateFrame("Frame", nil, frame)
SlerneNotes.rosterTab:SetPoint("TOPLEFT", bg, "TOPLEFT", CONTENT_INSET, -CONTENT_INSET)
SlerneNotes.rosterTab:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -CONTENT_INSET, CONTENT_INSET)
SlerneNotes.rosterTab:SetFrameLevel(CONTENT_LEVEL)
SlerneNotes.rosterTab:Hide()

SlerneNotes.registriesTab = CreateFrame("Frame", nil, frame)
SlerneNotes.registriesTab:SetPoint("TOPLEFT", bg, "TOPLEFT", CONTENT_INSET, -CONTENT_INSET)
SlerneNotes.registriesTab:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -CONTENT_INSET, CONTENT_INSET)
SlerneNotes.registriesTab:SetFrameLevel(CONTENT_LEVEL)
SlerneNotes.registriesTab:Hide()

SlerneNotes.lootTab = CreateFrame("Frame", nil, frame)
SlerneNotes.lootTab:SetPoint("TOPLEFT", bg, "TOPLEFT", CONTENT_INSET, -CONTENT_INSET)
SlerneNotes.lootTab:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -CONTENT_INSET, CONTENT_INSET)
SlerneNotes.lootTab:SetFrameLevel(CONTENT_LEVEL)
SlerneNotes.lootTab:Hide()

SlerneNotes.configTab = CreateFrame("Frame", nil, frame)
SlerneNotes.configTab:SetPoint("TOPLEFT", bg, "TOPLEFT", CONTENT_INSET, -CONTENT_INSET)
SlerneNotes.configTab:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -CONTENT_INSET, CONTENT_INSET)
SlerneNotes.configTab:SetFrameLevel(CONTENT_LEVEL)
SlerneNotes.configTab:Hide()

local currentTab = "notes"
local function ShowOnly(tab)
    currentTab = tab
    SlerneNotes.notesTab:SetShown(tab == "notes")
    SlerneNotes.rosterTab:SetShown(tab == "roster")
    SlerneNotes.registriesTab:SetShown(tab == "registries")
    SlerneNotes.lootTab:SetShown(tab == "loot")
    SlerneNotes.configTab:SetShown(tab == "config")
end
btnNotes:SetScript("OnClick", function()
    ShowOnly("notes")
    SetActiveTab(btnNotes)
end)
btnRoster:SetScript("OnClick", function()
    ShowOnly("roster")
    SetActiveTab(btnRoster)
    if SlerneNotes.UpdateRosterList then SlerneNotes.UpdateRosterList() end
end)
btnRegistries:SetScript("OnClick", function()
    ShowOnly("registries")
    SetActiveTab(btnRegistries)
    if SlerneNotes.UpdateRegistryModules then SlerneNotes.UpdateRegistryModules() end
end)
btnLoot:SetScript("OnClick", function()
    ShowOnly("loot")
    SetActiveTab(btnLoot)
    if SlerneNotes.RefreshLootUI then SlerneNotes.RefreshLootUI() end
end)
btnConfig:SetScript("OnClick", function()
    ShowOnly("config")
    SetActiveTab(btnConfig)
    if SlerneNotes.RefreshConfigUI then SlerneNotes.RefreshConfigUI() end
end)

SetActiveTab(btnNotes)

local tabOrder = {
    { btn = btnNotes,      key = "notes" },
    { btn = btnRoster,     key = "roster" },
    { btn = btnRegistries, key = "registries" },
    { btn = btnLoot,       key = "loot" },
    { btn = btnConfig,     key = "config" },
}

function SlerneNotes.ApplyPluginVisibility()
    local hidden = (Data_GetHiddenPlugins and Data_GetHiddenPlugins()) or {}
    local prev
    for _, t in ipairs(tabOrder) do
        local hide = hidden[t.key] and t.key ~= "notes" and t.key ~= "config"
        t.btn:SetShown(not hide)
        if not hide then
            t.btn:ClearAllPoints()
            if prev then
                t.btn:SetPoint("TOPRIGHT", prev, "BOTTOMRIGHT", 0, -10)
            else
                t.btn:SetPoint("TOPRIGHT", tabBar, "TOPRIGHT", 22, -16)
            end
            prev = t.btn
        end
        if hide and currentTab == t.key then
            ShowOnly("notes")
            SetActiveTab(btnNotes)
        end
    end
end

local footer = CreateFrame("Frame", nil, SlerneNotes.notesTab, "BackdropTemplate")
footer:SetHeight(50)
footer:SetPoint("BOTTOMLEFT", 0, 0)
footer:SetPoint("BOTTOMRIGHT", 0, 0)
SlerneNotes.Skin.Panel(footer)

local left = CreateFrame("Frame", nil, SlerneNotes.notesTab, "BackdropTemplate")
left:SetWidth(250)
left:SetPoint("TOPLEFT", 0, 0)
left:SetPoint("BOTTOMLEFT", 0, 50)
SlerneNotes.Skin.Panel(left)

SlerneNotes.rightPanel = CreateFrame("Frame", nil, SlerneNotes.notesTab)
SlerneNotes.rightPanel:SetPoint("TOPLEFT", left, "TOPRIGHT", 10, 0)
SlerneNotes.rightPanel:SetPoint("BOTTOMRIGHT", 0, 50)

SlerneNotes.draggingPlayer = nil
local rosterPool = {}

local function Clear(f)
    for _, c in ipairs({f:GetChildren()}) do
        c:Hide()
    end
end

function SlerneNotes.UpdateRaidList(roster)
    Clear(left)
    roster = roster or SlerneNotes:GetRoster()
    if not roster then return end

    local assignedPlayers = {}
    local layout = Data_GetCurrentLayout()
    if layout then
        for _, mod in pairs(layout) do
            if mod.players and not (mod.meta and mod.meta.type == "Action List") then
                for k, v in pairs(mod.players) do
                    if v and v ~= true then
                        assignedPlayers[v] = true
                    elseif v == true then
                        assignedPlayers[k] = true
                    end
                end
            end
        end
    end

    local entries = {}
    for name in pairs(roster) do
        table.insert(entries, { name = name, isDummy = false })
    end
    local dummies = (Data_GetDummies and Data_GetDummies()) or {}
    for _, d in ipairs(dummies) do
        if d.name and not roster[d.name] then
            table.insert(entries, { name = d.name, isDummy = true })
        end
    end

    local combined = SlerneNotes:GetCombinedRoster()

    for i, entry in ipairs(entries) do
        local name = entry.name
        local btn = rosterPool[i]
        if not btn then
            btn = CreateFrame("Button", nil, left, "UIPanelButtonTemplate")
            btn:SetSize(220, 25)
            btn:RegisterForClicks("LeftButtonUp", "RightButtonUp", "LeftButtonDown")

            btn.icon = btn:CreateTexture(nil, "ARTWORK")
            btn.icon:SetSize(20, 20)
            btn.icon:SetPoint("RIGHT", btn:GetFontString(), "LEFT", -4, 0)

            btn.deleteBtn = CreateFrame("Button", nil, btn)
            btn.deleteBtn:SetSize(16, 16)
            btn.deleteBtn:SetPoint("RIGHT", -3, 0)
            btn.deleteBtn:RegisterForClicks("LeftButtonUp")
            btn.deleteBtn.x = btn.deleteBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            btn.deleteBtn.x:SetPoint("CENTER", 0, 0)
            btn.deleteBtn.x:SetText("x")
            btn.deleteBtn.x:SetTextColor(0.95, 0.45, 0.30, 1)
            btn.deleteBtn:SetScript("OnEnter", function(self) self.x:SetTextColor(1, 0.78, 0.45, 1) end)
            btn.deleteBtn:SetScript("OnLeave", function(self) self.x:SetTextColor(0.95, 0.45, 0.30, 1) end)
            btn.deleteBtn:SetScript("OnClick", function(self)
                Data_RemoveDummy(self:GetParent().playerName)
                SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
                SlerneNotes.UpdateModules()
            end)

            btn:SetScript("OnMouseDown", function(self, button)
                if button == "LeftButton" then
                    SlerneNotes.draggingPlayer = self.playerName
                    self:SetAlpha(0.5)
                end
            end)
            btn:SetScript("OnMouseUp", function(self, button)
                if button == "RightButton" then
                    local currentRole = Data_GetRole(self.playerName)
                    local nextRole = nil
                    if not currentRole then nextRole = "tank"
                    elseif currentRole == "tank" then nextRole = "healer"
                    elseif currentRole == "healer" then nextRole = "melee"
                    elseif currentRole == "melee" then nextRole = "ranged"
                    elseif currentRole == "ranged" then nextRole = "flag"
                    end
                    Data_SetRole(self.playerName, nextRole)
                    SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
                    SlerneNotes.UpdateModules()
                elseif button == "LeftButton" then
                    self:SetAlpha(1)
                    if SlerneNotes.draggingPlayer then
                        local dropped = false
                        for _, target in ipairs(SlerneNotes.dropTargets or {}) do
                            if target.frame:IsMouseOver() then
                                if target.type == "ListSlot" then
                                    Data_Assign(SlerneNotes.draggingPlayer, target.module, target.slot)
                                else
                                    Data_Assign(SlerneNotes.draggingPlayer, target.module)
                                end
                                dropped = true
                                break
                            end
                        end
                        SlerneNotes.draggingPlayer = nil
                        if dropped then
                            SlerneNotes.UpdateModules()
                            SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
                        end
                    end
                end
            end)
            btn:SetScript("OnEnter", function(self)
                if SlerneNotes.HighlightPlayerNotes then SlerneNotes.HighlightPlayerNotes(self.playerName, true) end
            end)
            btn:SetScript("OnLeave", function(self)
                if SlerneNotes.HighlightPlayerNotes then SlerneNotes.HighlightPlayerNotes(self.playerName, false) end
            end)

            SlerneNotes.Skin.Button(btn)
            rosterPool[i] = btn
        end
        btn.playerName = name
        btn.isDummy = entry.isDummy
        btn:SetPoint("TOPLEFT", left, "TOPLEFT", 10, -(i-1)*30 - 10)

        local textToSet
        if assignedPlayers[name] then
            textToSet = "|cff808080" .. name .. "|r"
        else
            local classToken = combined[name] and combined[name].class
            textToSet = "|cff" .. SlerneNotes.GetClassHex(classToken) .. name .. "|r"
        end
        btn:SetText(textToSet)

        local role = Data_GetRole(name)
        if role then
            btn.icon:SetTexture("Interface\\AddOns\\SlerneNotes\\img\\icons\\" .. role .. ".tga")
            btn.icon:Show()
        else
            btn.icon:Hide()
        end

        if entry.isDummy then btn.deleteBtn:Show() else btn.deleteBtn:Hide() end

        btn:Show()
    end
end

local pageTabPool = {}
local PAGE_TAB_W, PAGE_TAB_H, PAGE_TAB_STEP = 30, 37, 34
local function getPageTab(idx)
    local t = pageTabPool[idx]
    if not t then
        t = CreateFrame("Button", nil, SlerneNotes.notesTab, "UIPanelButtonTemplate")
        t:SetSize(PAGE_TAB_W, PAGE_TAB_H)
        SlerneNotes.Skin.PageTab(t)
        t._snBaseLevel = math.max(1, bg:GetFrameLevel() - 1)
        pageTabPool[idx] = t
    end
    return t
end

function SlerneNotes.UpdatePageTabs()
    local count = math.max(1, Data_GetPageCount())
    local active = Data_GetActivePage()
    for _, t in ipairs(pageTabPool) do t:Hide() end

    local shown = 0
    local function placeTab(text, onClick, isActive)
        shown = shown + 1
        local t = getPageTab(shown)
        t:SetText(text)
        t:SetScript("OnClick", onClick)
        t:ClearAllPoints()

        t:SetPoint("BOTTOMLEFT", bg, "TOPLEFT", 16 + (shown - 1) * PAGE_TAB_STEP, -13)
        SlerneNotes.Skin.SetPageTabActive(t, isActive)
        t:Show()
    end

    for p = 1, count do
        placeTab(tostring(p), function()
            Data_SetActivePage(p)
            SlerneNotes.UpdateModules()
            SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
            SlerneNotes.UpdatePageTabs()
        end, p == active)
    end
    if count < 8 then
        placeTab("+", function()
            Data_AddPage()
            SlerneNotes.UpdateModules()
            SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
            SlerneNotes.UpdatePageTabs()
        end, false)
    end
end

local newCanvasBtn = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
newCanvasBtn:SetSize(100, 30); newCanvasBtn:SetPoint("LEFT", 12, 0); newCanvasBtn:SetText("New Canvas")
newCanvasBtn:SetScript("OnClick", function() SlerneNotes.ShowNewCanvasDialog() end)
SlerneNotes.Skin.Button(newCanvasBtn)

local canvasDropdown = CreateFrame("DropdownButton", "SlerneNotesCanvasDropdown", footer, "WowStyle1DropdownTemplate")
canvasDropdown:SetPoint("LEFT", newCanvasBtn, "RIGHT", 8, 0); canvasDropdown:SetWidth(118)
SlerneNotes.Skin.Dropdown(canvasDropdown)
canvasDropdown:SetupMenu(function(dropdown, rootDescription)
    for cName in pairs(Data_GetCanvases() or {}) do
        rootDescription:CreateRadio(cName, function() return cName == Data_GetActiveCanvas() end, function()
            Data_SetCanvas(cName);
            SlerneNotes.UpdateModules()
            SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
            if SlerneNotes.UpdatePageTabs then SlerneNotes.UpdatePageTabs() end
            if SlerneNotes.RefreshFooterBoss then SlerneNotes.RefreshFooterBoss() end
        end)
    end
end)

local function fitButton(b, minW)
    local fs = b:GetFontString()
    local tw = (fs and fs:GetStringWidth()) or 0
    b:SetWidth(math.max(minW or 60, math.ceil(tw) + 28))
end

local delCanvasBtn = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
delCanvasBtn:SetSize(86, 30)
delCanvasBtn:SetPoint("LEFT", canvasDropdown, "RIGHT", 10, 0)
delCanvasBtn:SetText("Delete Canvas")
delCanvasBtn:SetScript("OnClick", function() SlerneNotes.ShowConfirmDeleteDialog() end)
SlerneNotes.Skin.Button(delCanvasBtn)
fitButton(delCanvasBtn, 92)

local delPageBtn = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
delPageBtn:SetSize(76, 30)
delPageBtn:SetPoint("LEFT", delCanvasBtn, "RIGHT", 10, 0)
delPageBtn:SetText("Delete Page")
delPageBtn:SetScript("OnClick", function() SlerneNotes.ShowConfirmDeletePage() end)
SlerneNotes.Skin.Button(delPageBtn)
fitButton(delPageBtn, 84)

local footerBossDropdown = CreateFrame("DropdownButton", "SlerneNotesFooterBossDropdown", footer, "WowStyle1DropdownTemplate")
footerBossDropdown:SetWidth(122)
footerBossDropdown:SetPoint("LEFT", delPageBtn, "RIGHT", 10, 0)
SlerneNotes.Skin.Dropdown(footerBossDropdown)

local function applyFooterBoss(file)
    Data_SetCanvasBoss(Data_GetActiveCanvas(), file)
    if SlerneNotes.RefreshFightPalette then SlerneNotes.RefreshFightPalette(true) end
    if SlerneNotes.RefreshFooterBoss then SlerneNotes.RefreshFooterBoss() end
end

footerBossDropdown:SetupMenu(function(dropdown, root)
    root:CreateRadio("None",
        function() return Data_GetCanvasBoss() == nil end,
        function() applyFooterBoss(nil) end)
    for _, season in ipairs(SlerneNotes.Arenas or {}) do
        local sMenu = root:CreateButton(season.season)
        for _, raid in ipairs(season.raids or {}) do
            local rMenu = sMenu:CreateButton(raid.raid)
            for _, fight in ipairs(raid.fights or {}) do
                rMenu:CreateRadio(fight.label,
                    function() return Data_GetCanvasBoss() == fight.file end,
                    function() applyFooterBoss(fight.file) end)
            end
        end
    end
end)

function SlerneNotes.RefreshFooterBoss()
    local boss = Data_GetCanvasBoss and Data_GetCanvasBoss() or nil
    local label = "None"
    if boss then
        for _, s in ipairs(SlerneNotes.Arenas or {}) do
            for _, r in ipairs(s.raids or {}) do
                for _, fg in ipairs(r.fights or {}) do
                    if fg.file == boss then label = fg.label end
                end
            end
        end
    end
    if footerBossDropdown.SetDefaultText then footerBossDropdown:SetDefaultText("Boss: " .. label) end
    if footerBossDropdown.GenerateMenu then footerBossDropdown:GenerateMenu() end
end
SlerneNotes.RefreshFooterBoss()

SlerneNotes.footer = footer
SlerneNotes.delCanvasBtn = delCanvasBtn
SlerneNotes.delPageBtn = delPageBtn
SlerneNotes.footerBossDropdown = footerBossDropdown

local exitBtn = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
exitBtn:SetSize(58, 30); exitBtn:SetPoint("RIGHT", -12, 0); exitBtn:SetText("Exit")
exitBtn:SetScript("OnClick", function() frame:Hide() end)
SlerneNotes.Skin.Button(exitBtn)

local exportBtn = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
exportBtn:SetSize(102, 30); exportBtn:SetPoint("RIGHT", exitBtn, "LEFT", -12, 0); exportBtn:SetText("Send to Group")
exportBtn:SetScript("OnClick", function()
    SlerneNotes.BroadcastCanvas()
end)
SlerneNotes.Skin.Button(exportBtn)

local newDummyBtn = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
newDummyBtn:SetSize(84, 30); newDummyBtn:SetPoint("RIGHT", exportBtn, "LEFT", -12, 0); newDummyBtn:SetText("New Placeholder")
newDummyBtn:SetScript("OnClick", function() SlerneNotes.ShowNewDummyDialog() end)
SlerneNotes.Skin.Button(newDummyBtn)
fitButton(newDummyBtn, 110)

local addModBtn = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
addModBtn:SetSize(72, 30); addModBtn:SetPoint("RIGHT", newDummyBtn, "LEFT", -10, 0); addModBtn:SetText("New Module")
addModBtn:SetScript("OnClick", function() SlerneNotes.ShowNewModDialog() end)
SlerneNotes.Skin.Button(addModBtn)
fitButton(addModBtn, 90)

frame:SetScript("OnShow", function()
    SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
    SlerneNotes.UpdateModules()
    SlerneNotes.UpdatePageTabs()
    if SlerneNotes.RefreshFooterBoss then SlerneNotes.RefreshFooterBoss() end
end)
