-- Layout list. Order matters for awful.layout.inc.
local awful = require("awful")
local naughty = require("naughty")

local layouts = {}

-- treetile is optional: it must live in ~/.config/awesome/treetile/
local ok, treetile = pcall(require, "treetile")
if ok then
    table.insert(layouts, treetile)
else
    naughty.notify({ preset = naughty.config.presets.critical,
        title = "treetile not found",
        text = "Put it in ~/.config/awesome/treetile/ - falling back to tile.\n" .. tostring(treetile) })
    table.insert(layouts, awful.layout.suit.tile)
end

table.insert(layouts, awful.layout.suit.max)
table.insert(layouts, awful.layout.suit.floating)
-- table.insert(layouts, awful.layout.suit.fair)
-- table.insert(layouts, awful.layout.suit.spiral.dwindle)

return layouts
