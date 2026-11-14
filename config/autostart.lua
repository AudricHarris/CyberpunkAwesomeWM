-- Programs started with the session. Add new ones to the list.
local awful = require("awful")
local gears = require("gears")

-- picom config lives next to rc.lua. It is only read at picom start:
-- after editing it run `pkill picom` then restart awesome (Mod+Ctrl+r).
local picom_conf = gears.filesystem.get_configuration_dir() .. "picom.conf"
awful.spawn.with_shell("pgrep -u $USER -x picom > /dev/null || picom --config '" .. picom_conf .. "' &")
awful.spawn.with_shell("xrandr --output DVI-D-0 --auto --primary --output HDMI-0 --auto --right-of DVI-D-0")

-- Example: run_once("nm-applet")
-- local function run_once(cmd)
--     awful.spawn.with_shell("pgrep -u $USER -x " .. cmd .. " > /dev/null || " .. cmd .. " &")
-- end
