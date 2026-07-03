local addonName, SlerneNotes = ...

-- Fight icons for the draw-bar "Fight" palette (placeable like the markers).
-- Each entry is a filename (without .tga) dropped in img/fights/. Empty for now
-- -- add files to img/fights/ and list them here to populate the palette.
SlerneNotes.FightIcons = {
    -- "ExampleAbility",
}

-- Manifest of the BASE arena maps in img/maps/base/, grouped Season > Raid >
-- Fight (so the New Module > Image dropdown can show a clean nested menu).
-- WoW addons cannot enumerate a folder at runtime, so the list is maintained
-- here. On disk, folders/files use clean lowercase/PascalCase names; the pretty
-- names live in `season`/`raid`/`label` (shown in-game). `file` is the path
-- RELATIVE to img/maps/base/ (kept relative so the viewer resolves it under its
-- own folder); w/h are the native pixel size.
--
-- Typing a filename in the dialog instead looks in img/maps/custom/.
-- To add a base map: drop the .tga in img/maps/base/<season>/<raid>/ and add a
-- line below (file = clean path, label = pretty display name).
-- Resolve a canvas's boss (a fight `file`) into its draw-bar icons. Returns
-- { preview = <relpath of the XBoss icon>, list = { <relpath>, ... } } where each
-- path is RELATIVE to img/maps/base (the icons live in the boss map's folder),
-- or nil if the boss is None / has no icons.
function SlerneNotes.GetBossIcons(bossFile)
    if not bossFile or bossFile == "" then return nil end
    for _, s in ipairs(SlerneNotes.Arenas or {}) do
        for _, r in ipairs(s.raids or {}) do
            for _, fg in ipairs(r.fights or {}) do
                if fg.file == bossFile and fg.icons and #fg.icons > 0 then
                    local dir = fg.file:match("^(.*[\\/])") or ""
                    local list, preview = {}, nil
                    for _, base in ipairs(fg.icons) do
                        local rel = dir .. base .. ".tga"
                        list[#list + 1] = rel
                        if not preview and base:find("Boss") then preview = rel end
                    end
                    return { preview = preview or list[1], list = list }
                end
            end
        end
    end
    return nil
end

SlerneNotes.Arenas = {
    {
        season = "Midnight S1",
        raids = {
            {
                raid = "The Voidspire",
                fights = {
                    { label = "Imperator Averzian",    file = "midnight_s1\\the_voidspire\\Averzian.tga",  w = 1000, h = 1000 },
                    { label = "Vorasius",              file = "midnight_s1\\the_voidspire\\Vorasius.tga",  w = 1000, h = 1000 },
                    { label = "Fallen-King Salhadaar", file = "midnight_s1\\the_voidspire\\Salhadaar.tga", w = 1000, h = 1000 },
                    { label = "Vaelgor & Ezzorak",     file = "midnight_s1\\the_voidspire\\Dragons.tga",   w = 1000, h = 1000 },
                    { label = "Lightblinded Vanguard", file = "midnight_s1\\the_voidspire\\Vanguard.tga",  w = 1000, h = 1000 },
                    { label = "Crown of the Cosmos",   file = "midnight_s1\\the_voidspire\\Alleria.tga",   w = 1000, h = 1000,
                      icons = { "AlleriaBoss", "AlleriaAdd1", "AlleriaAdd2", "AlleriaAdd3" } },
                },
            },
            {
                raid = "March on Quel'Danas",
                fights = {
                    -- `icons` = boss/add icon basenames in the SAME folder as the map
                    -- (NOT the map itself). The draw-bar boss flyout shows these when
                    -- the canvas is created for this boss; the XBoss one is the preview.
                    { label = "Belo'ren, Child of Al'ar", file = "midnight_s1\\march_on_queldanas\\Beloren.tga", w = 1000, h = 1000,
                      icons = { "BelorenBoss", "BelorenAdd1", "BelorenAdd2" } },
                    { label = "Midnight Falls",           file = "midnight_s1\\march_on_queldanas\\Lura.tga",    w = 1000, h = 1000,
                      icons = { "LuraBoss", "LuraAdd1", "LuraAdd2", "LuraAdd3" } },
                },
            },
            {
                raid = "Sporefall",
                fights = {
                    { label = "Rotmire", file = "midnight_s1\\sporefall\\Rotmire.tga", w = 1000, h = 1000 },
                },
            },
            {
                raid = "The Dreamrift",
                fights = {
                    { label = "Chimaerus", file = "midnight_s1\\the_dreamrift\\Chimaerus.tga", w = 1000, h = 1000 },
                },
            },
        },
    },
}
