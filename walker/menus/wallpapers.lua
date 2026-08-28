Name = "wallpapers"
NamePretty = "Wallpapers"
Icon = "preferences-desktop-wallpaper"
Cache = false
HideFromProviderlist = false
SearchName = true
Description = "Elegir wallpaper (con miniatura)"

function GetEntries()
    local entries = {}

    table.insert(entries, {
        Text = "Aleatorio",
        Subtext = "elige una imagen al azar",
        Value = "random",
        Icon = "media-playlist-shuffle",
        Actions = {
            set_matugen = "chocomazapan-wallpaper-set random matugen",
            set_wallust = "chocomazapan-wallpaper-set random wallust",
        },
    })

    local wallpaper_dir = os.getenv("HOME") .. "/Imágenes/Wallpapers"
    local handle = io.popen(
        "find '" .. wallpaper_dir ..
        "' -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) 2>/dev/null | sort"
    )

    if handle then
        for line in handle:lines() do
            local filename = line:match("([^/]+)$")
            if filename then
                table.insert(entries, {
                    Text = filename,
                    Subtext = "wallpaper",
                    Value = line,
                    Icon = line,
                    Preview = line,
                    PreviewType = "file",
                    Actions = {
                        set_matugen = "chocomazapan-wallpaper-set '" .. line .. "' matugen",
                        set_wallust = "chocomazapan-wallpaper-set '" .. line .. "' wallust",
                    },
                })
            end
        end
        handle:close()
    end

    return entries
end
