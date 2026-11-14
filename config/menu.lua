-- Main menu + launcher widget
local awful         = require("awful")
local beautiful     = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local menubar       = require("menubar")
local vars          = require("config.vars")

menubar.utils.terminal = vars.terminal

local awesomemenu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual", vars.terminal .. " -e man awesome" },
    { "edit config", vars.editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end },
}

local M = {}

M.main = awful.menu({ items = {
    { "awesome", awesomemenu, beautiful.awesome_icon },
    { "open terminal", vars.terminal },
}})

M.launcher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = M.main })

return M
