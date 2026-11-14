-- Window rules
local awful     = require("awful")
local beautiful = require("beautiful")
local keys      = require("keys")

awful.rules.rules = {
    -- All clients
    { rule = { },
      properties = {
          border_width = beautiful.border_width,
          border_color = beautiful.border_normal,
          focus     = awful.client.focus.filter,
          raise     = true,
          keys      = keys.client,
          buttons   = keys.clientbuttons,
          screen    = awful.screen.preferred,
          placement = awful.placement.under_mouse + awful.placement.no_offscreen,
          -- Tiled windows must obey the layout, not their own size hints.
          -- This is the usual cause of apps sticking out of their tile (treetile).
          size_hints_honor = false,
          maximized_horizontal = false,
          maximized_vertical   = false,
      } },

    -- Floating clients
    { rule_any = {
        instance = { "DTA", "copyq", "pinentry" },
        class = { "Arandr", "Blueman-manager", "Gpick", "Kruler", "MessageWin",
                  "Sxiv", "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer" },
        name = { "Event Tester" },
        role = { "AlarmWindow", "ConfigManager", "pop-up" },
      }, properties = { floating = true, size_hints_honor = true } },

    -- Dialogs, splash screens, utility windows: float, centered, on screen
    { rule_any = { type = { "dialog", "splash", "utility" } },
      properties = {
          floating = true,
          size_hints_honor = true,
          placement = awful.placement.centered + awful.placement.no_offscreen,
      } },

    -- No titlebars anymore (the "awesome - Dolphin" bar on top of windows)

    -- Pin an app to a tag:
    -- { rule = { class = "Firefox" }, properties = { screen = 1, tag = "2" } },
}
