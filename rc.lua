-- rc.lua: entry point only. All real config lives in config/ and keys/.
pcall(require, "luarocks.loader")

local gears     = require("gears")
local awful     = require("awful")
local beautiful = require("beautiful")

require("awful.autofocus")
require("awful.hotkeys_popup.keys")

-- Order matters: errors first, theme before anything that reads beautiful.*
require("config.errors")
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme/myTheme.lua")

awful.layout.layouts = require("config.layouts")

require("config.autostart")
require("config.screens")   -- wallpaper + tags
require("config.gifwall") -- video wallpaper (mpv), Mod+Shift+w toggles
require("config.wibar")     -- bar, taglist, tasklist
require("keys")             -- all keybindings (keys/init.lua)
require("config.rules")     -- needs keys, so load after
require("config.signals")
