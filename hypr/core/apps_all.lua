-- App-specific tweaks.
local home = os.getenv("HOME")
local require_all = require("hypr.core.require_all")

require_all.files(home .. "/dotfiles/hypr/core/apps", "hypr.core.apps")
