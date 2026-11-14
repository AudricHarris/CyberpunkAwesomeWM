-- Launching programs. Add your own app shortcuts here.
local awful   = require("awful")
local menubar = require("menubar")
local vars    = require("config.vars")
local videowall = require("config.videowall")

local modkey = vars.modkey

return require("gears").table.join(
    awful.key({ modkey }, "t", function() awful.spawn(vars.terminal) end,
        { description = "open a terminal", group = "launcher" }),
    -- moved here from keys/client.lua: as a client key it only worked with a window focused
    awful.key({ modkey }, "e", function() awful.spawn("dolphin") end,
        { description = "file explorer", group = "launcher" }),
    awful.key({ modkey }, "i", function() awful.screen.focused().mypromptbox:run() end,
        { description = "run prompt", group = "launcher" }),
    awful.key({ modkey }, "r", function() menubar.show() end,
        { description = "show the menubar", group = "launcher" }),
    awful.key({ modkey, "Shift" }, "w", function() videowall.toggle() end,
        { description = "toggle video wallpaper", group = "launcher" })
    -- awful.key({ modkey }, "b", function() awful.spawn("firefox") end,
    --     { description = "browser", group = "launcher" }),
)
