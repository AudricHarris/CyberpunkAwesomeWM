-- Screenshot binds (logic lives in lib/screenshot.lua)
local awful      = require("awful")
local gears      = require("gears")
local screenshot = require("lib.screenshot")
local vars       = require("config.vars")

local modkey = vars.modkey

local function bind(mods, fn, desc)
    return awful.key(mods, "s", fn, { description = desc, group = "screenshots" })
end

return gears.table.join(
    bind({ modkey },                function() screenshot.take("full") end,      "screenshot (full screen)"),
    bind({ modkey, "Shift" },       function() screenshot.take("select") end,    "screenshot (select area)"),
    bind({ modkey, "Control" },     function() screenshot.take("window") end,    "screenshot (focused window)"),
    bind({ modkey, "Mod1" },        function() screenshot.take("full", 5) end,   "screenshot in 5 seconds")
)
