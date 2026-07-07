local addonName, SlerneNotes = ...

local LDB = LibStub and LibStub:GetLibrary("LibDataBroker-1.1", true)
local LDBIcon = LibStub and LibStub:GetLibrary("LibDBIcon-1.0", true)
if not (LDB and LDBIcon) then return end

local function ToggleWindow()
    local f = SlerneNotes.frame
    if not f then return end
    if f:IsShown() then f:Hide() else f:Show() end
end

local dataObj = LDB:NewDataObject("SlerneNotes", {
    type = "launcher",
    text = "Slerne Notes",
    icon = "Interface\\AddOns\\SlerneNotes\\img\\theme\\LogoMinimap.tga",
    OnClick = function(_, button)
        if button == "RightButton" then

            if SlerneNotes.frame then
                SlerneNotes.frame:Show()
                if SlerneNotes.tabs and SlerneNotes.tabs[5] then
                    SlerneNotes.tabs[5]:Click()
                end
            end
        else
            ToggleWindow()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("Slerne Notes")
        tooltip:AddLine("|cffffff00Click|r to toggle the window.", 1, 1, 1)
        tooltip:AddLine("|cffffff00Right-click|r for settings.", 1, 1, 1)
    end,
})

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, _, arg1)
    if arg1 == "SlerneNotes" then
        SlerneNotesDB = SlerneNotesDB or {}

        if SlerneNotesDB.minimap == nil then SlerneNotesDB.minimap = { hide = true } end
        if not LDBIcon:IsRegistered("SlerneNotes") then
            LDBIcon:Register("SlerneNotes", dataObj, SlerneNotesDB.minimap)
        end
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

function SlerneNotes.SetMinimapHidden(hide)
    SlerneNotesDB.minimap = SlerneNotesDB.minimap or {}
    SlerneNotesDB.minimap.hide = hide and true or false
    if SlerneNotesDB.minimap.hide then LDBIcon:Hide("SlerneNotes") else LDBIcon:Show("SlerneNotes") end
end

function SlerneNotes.IsMinimapHidden()
    return SlerneNotesDB and SlerneNotesDB.minimap and SlerneNotesDB.minimap.hide or false
end
