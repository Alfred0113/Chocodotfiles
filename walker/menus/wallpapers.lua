Name = "wallpapers"
NamePretty = "Wallpapers"
Cache = false
HideFromProviderlist = true
SearchName = true

local function ShellEscape(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function FormatName(filename)
  -- Quita número y guion iniciales
  local name = filename:gsub("^%d+", ""):gsub("^%-", "")
  -- Quita la extensión
  name = name:gsub("%.[^%.]+$", "")
  -- Guiones -> espacios
  name = name:gsub("[-_]", " ")
  -- Capitaliza cada palabra
  name = name:gsub("%S+", function(word)
    return word:sub(1, 1):upper() .. word:sub(2):lower()
  end)
  return name
end

function GetEntries()
  local entries = {}
  local home = os.getenv("HOME")
  local wallpaper_dir = home .. "/Imágenes/Wallpapers"

  table.insert(entries, {
    Text = "Aleatorio",
    Value = "random",
    Actions = {
      set_matugen = "chocomazapan-wallpaper-set random matugen",
      set_wallust = "chocomazapan-wallpaper-set random wallust",
    },
  })

  local handle = io.popen(
    "find -L " .. ShellEscape(wallpaper_dir) ..
    " -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.bmp' -o -iname '*.webp' \\) 2>/dev/null | sort"
  )

  if handle then
    for background in handle:lines() do
      local filename = background:match("([^/]+)$")
      if filename then
        table.insert(entries, {
          Text = FormatName(filename),
          Value = background,
          Preview = background,
          PreviewType = "file",
          Actions = {
            set_matugen = "chocomazapan-wallpaper-set " .. ShellEscape(background) .. " matugen",
            set_wallust = "chocomazapan-wallpaper-set " .. ShellEscape(background) .. " wallust",
          },
        })
      end
    end
    handle:close()
  end

  return entries
end
