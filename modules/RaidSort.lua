local addonName, SlerneNotes = ...

local MAX_MOVES = 60
local STEP_TIMEOUT = 1.5

local state
local stepPending = false

local watcher = CreateFrame("Frame")
watcher:Hide()

local function ShortName(n)
    if not n then return nil end
    return (strsplit("-", n))
end

local function Msg(text)
    print("Slerne Notes: " .. text)
end

local function BuildRoster()
    local byName, counts = {}, { 0, 0, 0, 0, 0, 0, 0, 0 }
    for i = 1, GetNumGroupMembers() do
        local name, _, subgroup = GetRaidRosterInfo(i)
        if name and subgroup then
            byName[ShortName(name)] = { index = i, group = subgroup }
            counts[subgroup] = counts[subgroup] + 1
        end
    end
    return byName, counts
end

local function Finish(text)
    watcher:UnregisterAllEvents()
    watcher:Hide()
    state = nil
    if text then Msg(text) end
end

local function Step()
    if not state then return end
    if InCombatLockdown() then
        Finish("sorting stopped, combat started.")
        return
    end
    if state.moves >= MAX_MOVES then
        Finish("sorting stopped after too many moves. Groups may be partially sorted.")
        return
    end

    local byName, counts = BuildRoster()
    for _, want in ipairs(state.list) do
        local info = byName[want.name]
        if info and info.group ~= want.group then
            state.moves = state.moves + 1
            state.waiting = GetTime()
            if counts[want.group] < 5 then
                SetRaidSubgroup(info.index, want.group)
            else
                local swapIndex
                for i = 1, GetNumGroupMembers() do
                    local n2, _, sub2 = GetRaidRosterInfo(i)
                    if n2 and sub2 == want.group and state.map[ShortName(n2)] ~= want.group then
                        swapIndex = i
                        break
                    end
                end
                if swapIndex then
                    SwapRaidSubgroup(info.index, swapIndex)
                else
                    Finish("could not finish: group " .. want.group .. " is already full of listed players.")
                end
            end
            return
        end
    end
    Finish("raid groups sorted to match the list (" .. state.moves .. " moves).")
end

local function ScheduleStep(delay)
    if not state or stepPending then return end
    stepPending = true
    C_Timer.After(delay or 0.15, function()
        stepPending = false
        Step()
    end)
end

watcher:SetScript("OnEvent", function()
    ScheduleStep(0.15)
end)
watcher:SetScript("OnUpdate", function()
    if state and state.waiting and GetTime() - state.waiting > STEP_TIMEOUT then
        state.waiting = GetTime()
        ScheduleStep(0)
    end
end)

function SlerneNotes.SortRaidToList(modName)
    if state then
        Msg("a sort is already running.")
        return
    end
    local layout = Data_GetCurrentLayout and Data_GetCurrentLayout() or {}
    local modData = layout[modName]
    if not modData then return end
    local meta, players = modData.meta, modData.players

    if not IsInRaid() then
        Msg("sorting needs a raid group.")
        return
    end
    if InCombatLockdown() then
        Msg("sorting is unavailable during combat.")
        return
    end
    if not (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
        Msg("sorting needs raid lead or assist.")
        return
    end

    local byName = BuildRoster()
    local list, map, skipped = {}, {}, {}
    for i = 1, (meta.length or 0) do
        local name = players[i]
        if name and name ~= "" and not map[name] then
            local target = math.ceil(i / 5)
            if target > 8 then break end
            if byName[name] then
                list[#list + 1] = { name = name, group = target }
                map[name] = target
            else
                skipped[#skipped + 1] = name
            end
        end
    end

    if #list == 0 then
        Msg("no listed players are in your raid.")
        return
    end
    if #skipped > 0 then
        Msg("not in the raid, skipped: " .. table.concat(skipped, ", "))
    end

    state = { list = list, map = map, moves = 0, waiting = GetTime() }
    watcher:RegisterEvent("GROUP_ROSTER_UPDATE")
    watcher:Show()
    Step()
end
