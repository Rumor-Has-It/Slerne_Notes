local addonName, SlerneNotes = ...
local modPool = {}
SlerneNotes.dropTargets = {}
SlerneNotes.iconLockRects = {}

local function Clear(f)
    if not f then return end
    for _, c in ipairs({f:GetChildren()}) do
        c:Hide()
    end
end

local function EnsureModules()
    return Data_GetCurrentLayout() or {}
end

local function GetImagePath(imgName)
    if not imgName or imgName == "" then return "" end

    if string.find(imgName, "[\\/]") then
        return "Interface\\AddOns\\SlerneNotes\\img\\maps\\base\\" .. imgName
    end
    return "Interface\\AddOns\\SlerneNotes\\img\\maps\\custom\\" .. imgName
end

local function GetIconPath(iconName)
    return "Interface\\AddOns\\SlerneNotes\\img\\icons\\" .. iconName .. ".tga"
end

local function GetFlipbookPath(name)
    if not name or name == "" then return "" end
    if string.find(name, "[\\/]") then
        return "Interface\\AddOns\\SlerneNotes\\img\\flipbooks\\base\\" .. name
    end
    return "Interface\\AddOns\\SlerneNotes\\img\\flipbooks\\custom\\" .. name
end

local function FlipbookParams(meta)
    local fb = SlerneNotes.GetFlipbook and SlerneNotes.GetFlipbook(meta.image) or nil
    local rows   = tonumber(meta.fbRows)   or (fb and fb.rows)   or 1
    local cols   = tonumber(meta.fbCols)   or (fb and fb.cols)   or 1
    local frames = tonumber(meta.fbFrames) or (fb and fb.frames) or (rows * cols)
    local fps    = tonumber(meta.fbFps)    or (fb and fb.fps)    or 10
    local w = meta.imgW or (fb and fb.w) or 128
    local h = meta.imgH or (fb and fb.h) or 128
    return rows, cols, frames, fps, w, h
end

local function ApplyFlipbook(tex, file, rows, cols, frames, fps)
    local key = table.concat({ file or "", rows, cols, frames, fps }, "|")
    if tex._fbKey == key and tex._fbGroup then
        if not tex._fbGroup:IsPlaying() and not tex._fbPaused then tex._fbGroup:Play() end
        return
    end
    if tex._fbGroup then tex._fbGroup:Stop() end
    tex:SetTexCoord(0, 1, 0, 1)
    local ag = tex._fbGroup or tex:CreateAnimationGroup()
    local anim = tex._fbAnim or ag:CreateAnimation("FlipBook")
    anim:SetFlipBookRows(rows)
    anim:SetFlipBookColumns(cols)
    anim:SetFlipBookFrames(frames)
    anim:SetDuration(frames / math.max(0.1, fps))
    ag:SetLooping("REPEAT")
    tex._fbGroup, tex._fbAnim, tex._fbKey, tex._fbPaused = ag, anim, key, false
    ag:Play()
end

local function StopFlipbook(tex)
    if tex._fbGroup then tex._fbGroup:Stop() end
    tex._fbKey, tex._fbPaused = nil, false
    tex:SetTexCoord(0, 1, 0, 1)
end

local function ToggleFlipbook(tex)
    local ag = tex and tex._fbGroup
    if not ag then return false end
    if ag.IsPaused and ag:IsPaused() then
        ag:Play(); tex._fbPaused = false
    elseif ag:IsPlaying() then
        ag:Pause(); tex._fbPaused = true
    else
        ag:Play(); tex._fbPaused = false
    end
    return tex._fbPaused
end

local measureFS
local function MaxLineWidth(text)
    if not measureFS then
        measureFS = UIParent:CreateFontString(nil, "ARTWORK")
        measureFS:SetFontObject(ChatFontNormal)
        measureFS:Hide()
    end
    local maxw = 0
    for line in (tostring(text or "") .. "\n"):gmatch("([^\n]*)\n") do
        measureFS:SetText(line)
        local w = measureFS:GetStringWidth() or 0
        if w > maxw then maxw = w end
    end
    return maxw
end

local function CreatePlayerSlot(parent, width)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, 20)
    SlerneNotes.Skin.Slot(btn)
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    btn.text:SetPoint("CENTER")
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(17, 17)
    btn.icon:SetPoint("RIGHT", btn.text, "LEFT", -4, 0)
    btn:RegisterForClicks("RightButtonUp")
    return btn
end

local function ConfigPlayerSlot(btn, playerName, modName, slotKey, currentRoster)
    btn.modName = modName
    btn.slotIndex = slotKey
    btn.playerName = playerName
    if playerName then
        btn.text:SetText(playerName)
        local classToken = currentRoster[playerName] and currentRoster[playerName].class
        if classToken and SlerneNotes.ClassColors[classToken] then
            local c = SlerneNotes.ClassColors[classToken]
            btn.text:SetTextColor(c.r, c.g, c.b, 1)
        else
            btn.text:SetTextColor(0.5, 0.5, 0.5, 1)
        end
        local role = Data_GetRole(playerName)
        if role then
            btn.icon:SetTexture(GetIconPath(role))
            btn.icon:Show()
            btn.text:ClearAllPoints(); btn.text:SetPoint("CENTER", 9, 0)
        else
            btn.icon:Hide()
            btn.text:ClearAllPoints(); btn.text:SetPoint("CENTER", 0, 0)
        end
    else
        btn.text:SetText("")
        btn.icon:Hide()
        btn.text:ClearAllPoints(); btn.text:SetPoint("CENTER", 0, 0)
    end
    btn:SetScript("OnClick", function(self, button)
        if button == "RightButton" then

            Data_RemoveSlot(self.modName, self.slotIndex)
            SlerneNotes.UpdateModules()
            SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
        end
    end)
    table.insert(SlerneNotes.dropTargets, { frame = btn, module = modName, slot = slotKey, type = "ListSlot" })
end

function SlerneNotes.UpdateModules()
    local right = SlerneNotes.rightPanel
    if not right then return end

    Clear(right)
    wipe(SlerneNotes.dropTargets)
    wipe(SlerneNotes.iconLockRects)

    local layout = EnsureModules()
    local currentRoster = SlerneNotes:GetCombinedRoster()
    local index = 0

    for modName, modData in pairs(layout) do
        index = index + 1
        local meta = modData.meta
        local players = modData.players

        local modFrame = modPool[index]
        if not modFrame then
            modFrame = CreateFrame("Frame", nil, right, "BackdropTemplate")
            SlerneNotes.Skin.Module(modFrame)

            modFrame:SetMovable(true)
            modFrame:EnableMouse(true)
            modFrame:RegisterForDrag("LeftButton")
            modFrame:SetScript("OnDragStart", function(self)
                if self.locked then return end
                if self.iconLock and SlerneNotes.CaptureDrawingsForModule then
                    local parent = self:GetParent()
                    local rx = (self:GetLeft() or 0) - (parent:GetLeft() or 0)
                    local ry = (self:GetTop() or 0) - (parent:GetTop() or 0)
                    self._dragFromX, self._dragFromY = rx, ry
                    SlerneNotes.CaptureDrawingsForModule(self,
                        { x = rx, y = ry, w = self:GetWidth() or 0, h = self:GetHeight() or 0 })
                end
                self:StartMoving()
            end)
            modFrame:SetScript("OnDragStop", function(self)
                self:StopMovingOrSizing()
                local parent = self:GetParent()
                local pX, pY = parent:GetLeft(), parent:GetTop()
                local fX, fY = self:GetLeft(), self:GetTop()
                local dx, dy = 0, 0
                if pX and pY and fX and fY then
                    local relX, relY = fX - pX, fY - pY
                    Data_SetModulePosition(self.modName, relX, relY)

                    self:ClearAllPoints()
                    self:SetPoint("TOPLEFT", parent, "TOPLEFT", relX, relY)
                    if self._dragFromX then
                        dx, dy = relX - self._dragFromX, relY - self._dragFromY
                    end
                end
                self._dragFromX, self._dragFromY = nil, nil
                if SlerneNotes.CommitCapturedDrawings then
                    SlerneNotes.CommitCapturedDrawings(self, dx, dy)
                end
            end)

            modFrame.title = modFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            modFrame.title:SetPoint("TOP", 0, -5)
            modFrame.title:SetJustifyH("CENTER")
            modFrame.title:SetWordWrap(false)
            SlerneNotes.Skin.Title(modFrame.title)

            modFrame.closeBtn = CreateFrame("Button", nil, modFrame, "UIPanelCloseButton")
            modFrame.closeBtn:SetSize(22, 22)
            modFrame.closeBtn:SetPoint("TOPRIGHT", modFrame, "TOPRIGHT", 2, 2)
            SlerneNotes.Skin.CloseButton(modFrame.closeBtn)

            modFrame.lockBtn = CreateFrame("Button", nil, modFrame)
            modFrame.lockBtn:SetSize(22, 22)
            modFrame.lockBtn:SetPoint("RIGHT", modFrame.closeBtn, "LEFT", -2, 0)
            modFrame.lockBtn:EnableMouse(true)
            modFrame.lockBtn:RegisterForClicks("LeftButtonUp")
            modFrame.lockBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine(self._stateText or "Lock")
                GameTooltip:Show()
            end)
            modFrame.lockBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
            SlerneNotes.Skin.LockButton(modFrame.lockBtn)

            modFrame.swapBtn = CreateFrame("Button", nil, modFrame)
            modFrame.swapBtn:SetSize(22, 22)
            modFrame.swapBtn:SetPoint("RIGHT", modFrame.lockBtn, "LEFT", -2, 0)
            modFrame.swapBtn:EnableMouse(true)
            modFrame.swapBtn:RegisterForClicks("LeftButtonUp")
            SlerneNotes.Skin.IconBox(modFrame.swapBtn)
            modFrame.swapBtn.tex = modFrame.swapBtn:CreateTexture(nil, "ARTWORK")
            modFrame.swapBtn.tex:SetSize(15, 15)
            modFrame.swapBtn.tex:SetPoint("CENTER")

            modFrame.swapBtn.tex:SetTexture("Interface\\Buttons\\UI-RefreshButton")
            SlerneNotes.Skin.TintTexture(modFrame.swapBtn.tex)
            modFrame.swapBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:AddLine("Edit")
                GameTooltip:Show()
            end)
            modFrame.swapBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            modFrame.sortBtn = CreateFrame("Button", nil, modFrame)
            modFrame.sortBtn:SetSize(22, 22)
            modFrame.sortBtn:SetPoint("RIGHT", modFrame.swapBtn, "LEFT", -2, 0)
            modFrame.sortBtn:EnableMouse(true)
            modFrame.sortBtn:RegisterForClicks("LeftButtonUp")
            SlerneNotes.Skin.IconBox(modFrame.sortBtn)
            modFrame.sortBtn.glyph = modFrame.sortBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            modFrame.sortBtn.glyph:SetPoint("CENTER")
            modFrame.sortBtn.glyph:SetText("S")
            SlerneNotes.Skin.TintTexture(modFrame.sortBtn.glyph)
            modFrame.sortBtn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText("Sort raid groups")
                GameTooltip:AddLine("Rearranges your raid so list slots 1-5 fill group 1, slots 6-10 fill group 2, and so on.", 0.8, 0.8, 0.8, true)
                GameTooltip:AddLine("Needs raid lead or assist, out of combat.", 0.8, 0.8, 0.8)
                GameTooltip:Show()
            end)
            modFrame.sortBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

            if modFrame.closeBtn.SetToplevel then modFrame.closeBtn:SetToplevel(false) end
            modFrame.closeBtn:SetFrameLevel(modFrame.lockBtn:GetFrameLevel())
            modFrame.swapBtn:SetFrameLevel(modFrame.lockBtn:GetFrameLevel())
            modFrame.sortBtn:SetFrameLevel(modFrame.lockBtn:GetFrameLevel())

            modFrame.displayImage = modFrame:CreateTexture(nil, "ARTWORK")

            modFrame.fbClick = CreateFrame("Button", nil, modFrame)
            modFrame.fbClick:RegisterForClicks("LeftButtonUp")
            modFrame.fbClick:RegisterForDrag("LeftButton")
            modFrame.fbClick:Hide()
            modFrame.fbClick:SetScript("OnDragStart", function(self)
                local p = self:GetParent()
                local h = p:GetScript("OnDragStart")
                if h then h(p) end
            end)
            modFrame.fbClick:SetScript("OnDragStop", function(self)
                local p = self:GetParent()
                local h = p:GetScript("OnDragStop")
                if h then h(p) end
            end)
            modFrame.fbClick:SetScript("OnClick", function(self)
                local paused = ToggleFlipbook(self:GetParent().displayImage)
                self.pauseIcon:SetShown(paused and true or false)
            end)
            modFrame.fbClick:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText("Click to pause or resume")
                GameTooltip:Show()
            end)
            modFrame.fbClick:SetScript("OnLeave", function() GameTooltip:Hide() end)

            local pauseIcon = CreateFrame("Frame", nil, modFrame.fbClick)
            pauseIcon:SetSize(24, 24)
            pauseIcon:SetPoint("TOPRIGHT", -5, -5)
            pauseIcon:Hide()
            local pbg = pauseIcon:CreateTexture(nil, "BACKGROUND")
            pbg:SetAllPoints(); pbg:SetColorTexture(0, 0, 0, 0.55)
            local bar1 = pauseIcon:CreateTexture(nil, "OVERLAY")
            bar1:SetColorTexture(1, 1, 1, 0.9); bar1:SetSize(4, 13); bar1:SetPoint("CENTER", -4, 0)
            local bar2 = pauseIcon:CreateTexture(nil, "OVERLAY")
            bar2:SetColorTexture(1, 1, 1, 0.9); bar2:SetSize(4, 13); bar2:SetPoint("CENTER", 4, 0)
            modFrame.fbClick.pauseIcon = pauseIcon

            modFrame.playerTexts = {}
            modFrame.listRows = {}
            modFrame.actionRows = {}
            modPool[index] = modFrame
        end

        modFrame.modName = modName

        for _, pt in ipairs(modFrame.playerTexts) do pt:Hide() end
        for _, row in ipairs(modFrame.listRows) do row:Hide() end
        for _, row in ipairs(modFrame.actionRows) do row:Hide() end
        modFrame.displayImage:Hide()
        if modFrame.fbClick then modFrame.fbClick:Hide() end
        if modFrame.displayImage._fbGroup and meta.type ~= "Flipbook" then
            StopFlipbook(modFrame.displayImage)
        end
        if modFrame.editBox then modFrame.editBox:Hide() end

        modFrame.closeBtn:SetScript("OnClick", function()
            Data_RemoveModule(modName)
            SlerneNotes.UpdateModules()
            SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
        end)

        local isImage = (meta.type == "Image")
        if not isImage and meta.locked == "icons" then meta.locked = true end
        modFrame.locked = (meta.locked == true)
        modFrame.iconLock = isImage and meta.locked == "icons"
        modFrame.lockBtn:SetLockedState(meta.locked)
        if isImage then
            if meta.locked == true then modFrame.lockBtn._stateText = "Fully locked"
            elseif meta.locked == "icons" then modFrame.lockBtn._stateText = "Icons locked (dragging the image moves its icons)"
            else modFrame.lockBtn._stateText = "Unlocked" end
        else
            modFrame.lockBtn._stateText = meta.locked and "Locked" or "Unlocked"
        end
        modFrame.lockBtn:SetScript("OnClick", function()
            if isImage then
                if not meta.locked then meta.locked = "icons"
                elseif meta.locked == "icons" then meta.locked = true
                else meta.locked = false end
            else
                meta.locked = not meta.locked
            end
            SlerneNotes.UpdateModules()
        end)

        modFrame.swapBtn:Show()
        modFrame.swapBtn:SetScript("OnClick", function()
            SlerneNotes.ShowEditModuleDialog(modName, meta)
        end)

        if meta.type == "List" or meta.type == "Image List" then
            modFrame.sortBtn:Show()
            modFrame.sortBtn:SetScript("OnClick", function()
                SlerneNotes.SortRaidToList(modName)
            end)
        else
            modFrame.sortBtn:Hide()
        end

        modFrame.title:SetText(modName)

        local titleWidth = modFrame.title:GetStringWidth() + 156

        if meta.type == "Assignment" then

            local sortedPlayers = {}
            for player in pairs(players) do
                table.insert(sortedPlayers, player)
            end

            local roleOrder = {
                ["tank"] = 1,
                ["healer"] = 2,
                ["melee"] = 3,
                ["ranged"] = 4
            }

            table.sort(sortedPlayers, function(a, b)
                local roleA = Data_GetRole(a)
                local roleB = Data_GetRole(b)

                local orderA = roleA and roleOrder[roleA] or 5
                local orderB = roleB and roleOrder[roleB] or 5

                if orderA == orderB then
                    return a < b
                end

                return orderA < orderB
            end)

            local pCount = #sortedPlayers
            local boxW = math.max(180, titleWidth)
            modFrame:SetSize(boxW, math.max(60, 40 + (pCount * 15)))

            local blockW = 0
            for i, player in ipairs(sortedPlayers) do
                local textBtn = modFrame.playerTexts[i]
                if not textBtn then
                    textBtn = CreateFrame("Button", nil, modFrame)
                    textBtn:SetSize(160, 15)
                    local fs = textBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                    fs:SetPoint("LEFT", 0, 0)
                    textBtn:SetFontString(fs)
                    textBtn.icon = textBtn:CreateTexture(nil, "ARTWORK")
                    textBtn.icon:SetSize(17, 17)
                    textBtn.icon:SetPoint("RIGHT", fs, "LEFT", -4, 0)
                    textBtn:RegisterForClicks("RightButtonUp")
                    modFrame.playerTexts[i] = textBtn
                end
                textBtn.playerName = player
                textBtn.modName = modName
                textBtn:SetText(player)
                local classToken = currentRoster[player] and currentRoster[player].class
                if classToken and SlerneNotes.ClassColors[classToken] then
                    local c = SlerneNotes.ClassColors[classToken]
                    textBtn:GetFontString():SetTextColor(c.r, c.g, c.b, 1)
                else
                    textBtn:GetFontString():SetTextColor(0.5, 0.5, 0.5, 1)
                end

                local role = Data_GetRole(player)
                if role then
                    textBtn.icon:SetTexture(GetIconPath(role))
                    textBtn.icon:Show()
                else
                    textBtn.icon:Hide()
                end

                textBtn:SetScript("OnClick", function(self, button)
                    if button == "RightButton" then
                        Data_Remove(self.playerName, self.modName)
                        SlerneNotes.UpdateModules()
                        SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
                    end
                end)
                textBtn:Show()

                local nameW = (textBtn:GetFontString() and textBtn:GetFontString():GetStringWidth()) or 0
                local w = nameW + (role and 18 or 0)
                if w > blockW then blockW = w end
            end

            local textX = math.max(25, (boxW - blockW) / 2 + 18)
            for i = 1, pCount do
                modFrame.playerTexts[i]:SetPoint("TOPLEFT", textX, -20 - (i*15))
            end

            table.insert(SlerneNotes.dropTargets, { frame = modFrame, module = modName, type = "Box" })

        elseif meta.type == "List" or meta.type == "Image List" or meta.type == "Image" then
            local rowHeight = 25
            local listWidth = math.max(220, titleWidth)

            local totalWidth = listWidth
            local minHeight = 40 + ((meta.length or 0) * rowHeight)
            local totalHeight = minHeight

            if (meta.type == "Image List" or meta.type == "Image") and meta.image and meta.image ~= "" then
                local fullImgPath = GetImagePath(meta.image)
                modFrame.displayImage:SetTexture(fullImgPath)
                local imgW = meta.imgW or 400
                local imgH = meta.imgH or 300

                modFrame.displayImage:SetSize(imgW, imgH)
                modFrame.displayImage:ClearAllPoints()

                if meta.type == "Image" then

                    modFrame.displayImage:SetPoint("TOP", modFrame, "TOP", 0, -30)
                    totalWidth = math.max(imgW + 30, titleWidth)
                    totalHeight = math.max(40, imgH + 50)
                else
                    modFrame.displayImage:SetPoint("TOPLEFT", modFrame, "TOPLEFT", listWidth + 15, -30)
                    totalWidth = listWidth + imgW + 25
                    totalHeight = math.max(minHeight, imgH + 50)
                end

                modFrame.displayImage:Show()
            end

            modFrame:SetSize(totalWidth, totalHeight)

            if meta.type == "List" or meta.type == "Image List" then

                local rowX = (meta.type == "List") and math.max(10, (totalWidth - 210) / 2) or 10
                for i = 1, meta.length do
                    local row = modFrame.listRows[i]
                    if not row then
                        row = CreateFrame("Frame", nil, modFrame)
                        row:SetSize(210, 20)

                        row.edit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
                        row.edit:SetSize(75, 20)
                        row.edit:SetPoint("LEFT", 0, 0)
                        row.edit:SetAutoFocus(false)
                        SlerneNotes.Skin.Input(row.edit)

                        row.btn = CreateFrame("Button", nil, row, "BackdropTemplate")
                        row.btn:SetSize(125, 20)
                        row.btn:SetPoint("LEFT", row.edit, "RIGHT", 5, 0)
                        SlerneNotes.Skin.Slot(row.btn)
                        row.btn.text = row.btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                        row.btn.text:SetPoint("CENTER")

                        row.btn.icon = row.btn:CreateTexture(nil, "ARTWORK")
                        row.btn.icon:SetSize(17, 17)
                        row.btn.icon:SetPoint("RIGHT", row.btn.text, "LEFT", -4, 0)

                        row.btn:RegisterForClicks("RightButtonUp")

                        modFrame.listRows[i] = row
                    end

                    row:SetPoint("TOPLEFT", rowX, -30 - ((i-1)*rowHeight))
                    row.edit:SetScript("OnTextChanged", nil)
                    row.edit:SetText(meta.labels[i] or tostring(i))
                    row.edit:SetScript("OnTextChanged", function(self, isUserInput)
                        if isUserInput then Data_SetLabel(modName, i, self:GetText()) end
                    end)

                    local playerName = players[i]
                    row.btn.modName = modName
                    row.btn.slotIndex = i
                    row.btn.playerName = playerName

                    if playerName then
                        row.btn.text:SetText(playerName)
                        local classToken = currentRoster[playerName] and currentRoster[playerName].class
                        if classToken and SlerneNotes.ClassColors[classToken] then
                            local c = SlerneNotes.ClassColors[classToken]
                            row.btn.text:SetTextColor(c.r, c.g, c.b, 1)
                        else
                            row.btn.text:SetTextColor(0.5, 0.5, 0.5, 1)
                        end

                        local role = Data_GetRole(playerName)
                        if role then
                            row.btn.icon:SetTexture(GetIconPath(role))
                            row.btn.icon:Show()

                            row.btn.text:ClearAllPoints()
                            row.btn.text:SetPoint("CENTER", 9, 0)
                        else
                            row.btn.icon:Hide()

                            row.btn.text:ClearAllPoints()
                            row.btn.text:SetPoint("CENTER", 0, 0)
                        end
                    else
                        row.btn.text:SetText("")
                        row.btn.icon:Hide()

                        row.btn.text:ClearAllPoints()
                        row.btn.text:SetPoint("CENTER", 0, 0)
                    end

                    row.btn:SetScript("OnClick", function(self, button)
                        if button == "RightButton" then
                            Data_Remove(self.playerName, self.modName)
                            SlerneNotes.UpdateModules()
                            SlerneNotes.UpdateRaidList(SlerneNotes:GetRoster())
                        end
                    end)

                    row:Show()
                    table.insert(SlerneNotes.dropTargets, { frame = row.btn, module = modName, slot = i, type = "ListSlot" })
                end
            end

        elseif meta.type == "Flipbook" then

            local rows, cols, frames, fps, imgW, imgH = FlipbookParams(meta)

            modFrame.displayImage:SetTexture(GetFlipbookPath(meta.image))
            modFrame.displayImage:SetSize(imgW, imgH)
            modFrame.displayImage:ClearAllPoints()
            modFrame.displayImage:SetPoint("TOP", modFrame, "TOP", 0, -30)
            modFrame.displayImage:Show()
            ApplyFlipbook(modFrame.displayImage, meta.image, rows, cols, frames, fps)

            modFrame.fbClick:ClearAllPoints()
            modFrame.fbClick:SetAllPoints(modFrame.displayImage)
            modFrame.fbClick.pauseIcon:SetShown(modFrame.displayImage._fbPaused and true or false)
            modFrame.fbClick:Show()

            modFrame:SetSize(math.max(imgW + 30, titleWidth), math.max(40, imgH + 50))

        elseif meta.type == "Action List" then

            local rowHeight = 25
            local slotW = 110
            local editW = 84
            local contentW = 12 + slotW + 12 + editW + 12 + slotW + 12
            local boxW = math.max(contentW, titleWidth)
            modFrame:SetSize(boxW, 40 + ((meta.length or 0) * rowHeight))

            local rowX = math.max(12, (boxW - contentW) / 2)

            for i = 1, (meta.length or 0) do
                local row = modFrame.actionRows[i]
                if not row then
                    row = CreateFrame("Frame", nil, modFrame)
                    row:SetSize(contentW, 20)

                    row.leftBtn = CreatePlayerSlot(row, slotW)
                    row.leftBtn:SetPoint("LEFT", 0, 0)

                    row.edit = CreateFrame("EditBox", nil, row, "InputBoxTemplate")
                    row.edit:SetSize(editW, 20)
                    row.edit:SetPoint("LEFT", row.leftBtn, "RIGHT", 12, 0)
                    row.edit:SetAutoFocus(false)
                    SlerneNotes.Skin.Input(row.edit)

                    row.rightBtn = CreatePlayerSlot(row, slotW)
                    row.rightBtn:SetPoint("LEFT", row.edit, "RIGHT", 12, 0)

                    modFrame.actionRows[i] = row
                end

                row:SetPoint("TOPLEFT", rowX, -30 - ((i - 1) * rowHeight))

                row.edit:SetScript("OnTextChanged", nil)
                row.edit:SetText(meta.labels[i] or "")
                row.edit:SetScript("OnTextChanged", function(self, isUserInput)
                    if isUserInput then Data_SetLabel(modName, i, self:GetText()) end
                end)

                ConfigPlayerSlot(row.leftBtn, players["L" .. i], modName, "L" .. i, currentRoster)
                ConfigPlayerSlot(row.rightBtn, players["R" .. i], modName, "R" .. i, currentRoster)

                row:Show()
            end

        elseif meta.type == "Text Block" then

            local MIN_TEXT_W, MAX_TEXT_W = 150, 500
            if not modFrame.editBox then
                modFrame.editBox = CreateFrame("EditBox", nil, modFrame)
                modFrame.editBox:SetMultiLine(true)
                modFrame.editBox:SetAutoFocus(false)
                modFrame.editBox:SetFontObject(ChatFontNormal)

                modFrame.editBox:SetPoint("TOP", modFrame, "TOP", 0, -30)

                modFrame.ResizeTextBlock = function(self)

                    local tw = (self.title:GetStringWidth() or 0) + 156
                    local contentW = MaxLineWidth(self.editBox:GetText())
                    local boxW = math.max(MIN_TEXT_W, math.min(MAX_TEXT_W, contentW + 18))
                    self.editBox:SetWidth(boxW)
                    local h = self.editBox:GetHeight() or 0
                    self:SetSize(math.max(tw, boxW + 30), math.max(70, h + 45))
                end

                modFrame.editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
                modFrame.editBox:SetScript("OnTextChanged", function(self, isUserInput)
                    if isUserInput then
                        Data_SetReminderText(self.modName, self:GetText())
                    end
                    self:GetParent():ResizeTextBlock()
                end)
            end

            modFrame.editBox.modName = modName
            modFrame.editBox:SetText(meta.text or "")
            modFrame.editBox:Show()
            modFrame:ResizeTextBlock()

            C_Timer.After(0, function()
                if modFrame.editBox:IsShown() then modFrame:ResizeTextBlock() end
            end)
        end

        modFrame.title:SetWidth(math.max(20, (modFrame:GetWidth() or 180) - 150))

        local posX = meta.posX or 50
        local posY = meta.posY or -50

        modFrame:ClearAllPoints()
        modFrame:SetPoint("TOPLEFT", right, "TOPLEFT", posX, posY)
        modFrame:Show()

        if isImage and meta.locked then
            SlerneNotes.iconLockRects[#SlerneNotes.iconLockRects + 1] =
                { x = posX, y = posY, w = modFrame:GetWidth() or 0, h = modFrame:GetHeight() or 0 }
        end
    end

    if SlerneNotes.UpdateDrawings then SlerneNotes.UpdateDrawings() end
end

function SlerneNotes.HighlightPlayerNotes(playerName, isHighlighted)
    local currentRoster = SlerneNotes:GetCombinedRoster()
    for _, modFrame in ipairs(modPool) do
        if modFrame:IsShown() then

            for _, textBtn in ipairs(modFrame.playerTexts) do
                if textBtn:IsShown() and textBtn.playerName == playerName then
                    if isHighlighted then
                        textBtn:GetFontString():SetTextColor(1, 1, 0, 1)
                    else
                        local classToken = currentRoster[playerName] and currentRoster[playerName].class
                        if classToken and SlerneNotes.ClassColors[classToken] then
                            local c = SlerneNotes.ClassColors[classToken]
                            textBtn:GetFontString():SetTextColor(c.r, c.g, c.b, 1)
                        else
                            textBtn:GetFontString():SetTextColor(0.5, 0.5, 0.5, 1)
                        end
                    end
                end
            end

            for _, row in ipairs(modFrame.listRows) do
                if row:IsShown() and row.btn.playerName == playerName then
                    if isHighlighted then
                        row.btn:SetBackdropColor(0.8, 0.8, 0.2, 0.9)
                    else
                        local s = SlerneNotes.Theme.slotBG
                        row.btn:SetBackdropColor(s[1], s[2], s[3], s[4])
                    end
                end
            end

            for _, row in ipairs(modFrame.actionRows) do
                if row:IsShown() then
                    for _, slot in ipairs({ row.leftBtn, row.rightBtn }) do
                        if slot.playerName == playerName then
                            if isHighlighted then
                                slot:SetBackdropColor(0.8, 0.8, 0.2, 0.9)
                            else
                                local s = SlerneNotes.Theme.slotBG
                                slot:SetBackdropColor(s[1], s[2], s[3], s[4])
                            end
                        end
                    end
                end
            end
        end
    end
end
