-- Loads every *.lua file from the toggles state dir, so scripts can flip
-- Hyprland config by dropping/removing a small Lua file there (see
-- bin/chocomazapan-toggle-enabled and friends).

local home = os.getenv("HOME")
local require_all = require("hypr.core.require_all")

local toggles_dir = (os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")) .. "/chocomazapan/toggles/hypr"
package.path = toggles_dir .. "/?.lua;" .. package.path

require_all.files(toggles_dir, nil, { reload = true })
