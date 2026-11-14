-- Awesome itself: help, reload, quit, menu, lua prompt
local awful         = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
local vars          = require("config.vars")
local menu          = require("config.menu")

local modkey = vars.modkey

return require("gears").table.join(
    -- Mod+s is now the screenshot key, so help moved to Mod+F1
    awful.key({ modkey }, "F1", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" }),
    awful.key({ modkey }, "w", function() menu.main:show() end,
        { description = "show main menu", group = "awesome" }),
    awful.key({ modkey }, "x", function()
        awful.prompt.run {
            prompt       = "Run Lua code: ",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.util.eval,
            history_path = awful.util.get_cache_dir() .. "/history_eval",
        }
    end, { description = "lua execute prompt", group = "awesome" })
)
