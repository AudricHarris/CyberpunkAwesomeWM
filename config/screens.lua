-- Per-screen setup: wallpaper and the single shared pool of tags (1-9)
local gears      = require("gears")
local awful      = require("awful")
local beautiful  = require("beautiful")
local sharedtags = require("sharedtags")

local layout = awful.layout.layouts[1]

-- One global set of 9 workspaces. 1-5 start on screen 1, 6-9 on screen 2.
-- Names are zero-padded for the HUD look; bindings use the index, not the name.
local tags = sharedtags({
    { name = "01", layout = layout },
    { name = "02", layout = layout },
    { name = "03", layout = layout },
    { name = "04", layout = layout },
    { name = "05", layout = layout },
    { name = "06", screen = 2, layout = layout },
    { name = "07", screen = 2, layout = layout },
    { name = "08", screen = 2, layout = layout },
    { name = "09", screen = 2, layout = layout },
})

local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then wallpaper = wallpaper(s) end
        gears.wallpaper.maximized(wallpaper, s, true)
    else
        gears.wallpaper.set("#000000")
    end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)
    -- Safety net: every screen must show at least one tag.
    if #s.selected_tags == 0 and s.tags[1] then
        s.tags[1]:view_only()
    end
end)

return tags
