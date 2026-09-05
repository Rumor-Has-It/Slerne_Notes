local addonName, SlerneNotes = ...

SlerneNotes.Flipbooks = {
    {
        season = "Midnight S2",
        clips = {
            { label = "Sentinels Intermission", file = "midnight_s2\\SentinelsIntermission.png",
              rows = 7, cols = 7,  frames = 47, fps = 7.5, w = 448, h = 390 },
            { label = "Vashnik Froth",          file = "midnight_s2\\VashnikFroth.png",
              rows = 7, cols = 11, frames = 76, fps = 7.5, w = 448, h = 374 },
            { label = "Twin Fangs Soak",        file = "midnight_s2\\FangsSoak.png",
              rows = 6, cols = 12, frames = 72, fps = 7.5, w = 448, h = 370 },
            { label = "Coiled Altar Ghosts",    file = "midnight_s2\\CoiledAltarGhosts.png",
              rows = 7, cols = 9,  frames = 62, fps = 7.5, w = 448, h = 342 },
            { label = "Ula'tek Tethers",        file = "midnight_s2\\UlatekTethers.png",
              rows = 6, cols = 8,  frames = 47, fps = 7.5, w = 448, h = 416 },
            { label = "Ula'tek Soaks",          file = "midnight_s2\\UlatekSoaks.png",
              rows = 8, cols = 11, frames = 87, fps = 7.5, w = 448, h = 411 },
        },
    },
}

function SlerneNotes.GetFlipbook(file)
    if not file or file == "" then return nil end
    for _, season in ipairs(SlerneNotes.Flipbooks) do
        for _, clip in ipairs(season.clips or {}) do
            if clip.file == file then return clip end
        end
    end
    return nil
end

function SlerneNotes.FirstFlipbook()
    local s = SlerneNotes.Flipbooks[1]
    return s and s.clips and s.clips[1]
end
