local addonName, SlerneNotes = ...

SlerneNotes.FightIcons = {

}

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
    {
        season = "Midnight S2",
        raids = {
            {
                raid = "The Venomous Abyss",
                fights = {
                    { label = "Nek'zali the Soulcoiler", file = "midnight_s2\\the_venomous_abyss\\Nekzali.tga", w = 863, h = 767,
                      icons = { "NekzaliBoss", "NekzaliAdd1", "NekzaliAdd2", "NekzaliAdd3", "NekzaliAdd4" } },
                    { label = "Entombed Sentinels", file = "midnight_s2\\the_venomous_abyss\\Sentinels.tga", w = 772, h = 743,
                      icons = { "SentinelsBoss1", "SentinelsBoss2", "SentinelsAdd1", "SentinelsAdd2" } },
                    { label = "Vashnik the Malignant", file = "midnight_s2\\the_venomous_abyss\\Vashnik.tga", w = 1059, h = 764,
                      icons = { "VashnikBoss", "VashnikAdd1", "VashnikAdd2", "VashnikAdd3", "VashnikAdd4" } },
                    { label = "The Lost Explorers", file = "midnight_s2\\the_venomous_abyss\\Explorers.tga", w = 771, h = 744,
                      icons = { "ExplorersBoss1", "ExplorersBoss2", "ExplorersBoss3", "ExplorersBoss4" } },
                    { label = "Sszorak", file = "midnight_s2\\the_venomous_abyss\\Sszorak.tga", w = 729, h = 731,
                      icons = { "SszorakBoss" } },
                    { label = "The Twin Fangs", file = "midnight_s2\\the_venomous_abyss\\Fangs.tga", w = 750, h = 683,
                      icons = { "FangsBoss1", "FangsBoss2", "FangsAdd1", "FangsAdd2" } },
                    { label = "The Coiled Altar", file = "midnight_s2\\the_venomous_abyss\\Zuljan.tga", w = 723, h = 723,
                      icons = { "ZuljanBoss1", "ZuljanBoss2", "ZuljanAdd1", "ZuljanAdd2", "ZuljanAdd3", "ZuljanAdd4" } },
                    { label = "Ula'tek", file = "midnight_s2\\the_venomous_abyss\\Ulatek.tga", w = 687, h = 685,
                      icons = { "UlatekBoss1", "UlatekBoss2", "UlatekAdd1", "UlatekAdd2", "UlatekAdd3", "UlatekAdd4",
                                "UlatekAdd5", "UlatekAdd6", "UlatekAdd7", "UlatekAdd8", "UlatekAdd9" } },
                    { label = "Ula'tek (Broken Arena)", file = "midnight_s2\\the_venomous_abyss\\UlatekBroken.tga", w = 726, h = 719,
                      mapOnly = true },
                },
            },
            {
                raid = "The Tidebound Grotto",
                fights = {
                    { label = "Nymrissa Wavecaller", file = "midnight_s2\\the_tidebound_grotto\\Nymrissa.tga", w = 1003, h = 957,
                      icons = { "NymrissaBoss", "NymrissaAdd1", "NymrissaAdd2", "NymrissaAdd3" } },
                },
            },
        },
    },
}
