-- Client signals: manage, focus (no titlebars anymore)
local awful     = require("awful")
local beautiful = require("beautiful")

client.connect_signal("manage", function(c)
    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
    -- Floating windows must never end up bigger/outside of the screen
    if c.floating then
        awful.placement.no_offscreen(c)
    end
end)

-- Same check when a window is toggled to floating (Mod+Ctrl+Space)
client.connect_signal("property::floating", function(c)
    if c.floating and not c.fullscreen and not c.maximized then
        awful.placement.no_offscreen(c)
    end
end)

-- Sloppy focus
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

-- Focus: highlight the border, and bring the mouse along when focus changed
-- without the mouse (new window, Mod+arrows, Mod+j/k, closing a window...).
-- If the pointer is already inside the window (you moved it there), do nothing.
client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
    if awesome.startup then return end
    local m, g = mouse.coords(), c:geometry()
    local inside = m.x >= g.x and m.x <= g.x + g.width
               and m.y >= g.y and m.y <= g.y + g.height
    if not inside then
        mouse.coords({ x = g.x + g.width / 2, y = g.y + g.height / 2 }, true)
    end
end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
