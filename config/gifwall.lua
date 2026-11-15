-- Animated GIF wallpaper, drawn straight onto the root window (no extra window).
-- Toggle with Mod+Shift+w. Scales the gif to "cover" each screen.
local gears     = require("gears")
local beautiful = require("beautiful")
local lgi       = require("lgi")

lgi.require("Gdk", "3.0")         -- must be 3.0, the unversioned load picks Gdk 4
local GdkPixbuf = lgi.require("GdkPixbuf", "2.0")

local GIF = gears.filesystem.get_configuration_dir() .. "Edgerunner.gif"

local M = {}
local enabled, generation, iter = false, 0, nil

local function static_wallpaper()
    for s in screen do
        if beautiful.wallpaper then
            gears.wallpaper.maximized(beautiful.wallpaper, s, true)
        else
            gears.wallpaper.set("#000000")
        end
    end
end

local function draw_frame(gen)
    if gen ~= generation or not enabled then return end

    iter:advance(nil)
    local pb = iter:get_pixbuf()
    local pw, ph = pb.width, pb.height

    for s in screen do
        local geom, cr = gears.wallpaper.prepare_context(s)
        local scale = math.max(geom.width / pw, geom.height / ph)   -- cover
        cr:rectangle(0, 0, geom.width, geom.height)
        cr:clip()
        cr:translate((geom.width - pw * scale) / 2, (geom.height - ph * scale) / 2)
        cr:scale(scale, scale)
        cr:set_source_pixbuf(pb, 0, 0)
        cr.operator = "SOURCE"
        cr:paint()
    end

    local delay = iter:get_delay_time()
    if delay ~= -1 then
        gears.timer.start_new(math.max(delay, 20) / 1000, function()
            draw_frame(gen)
            return false
        end)
    end
end

function M.start()
    local anim, err = GdkPixbuf.PixbufAnimation.new_from_file(GIF)
    if not anim then
        require("naughty").notify({ preset = require("naughty").config.presets.critical,
            title = "GIF wallpaper failed", text = tostring(err) })
        return
    end
    iter = anim:get_iter(nil)
    generation = generation + 1
    enabled = true
    draw_frame(generation)
end

function M.stop()
    enabled = false
    generation = generation + 1
    static_wallpaper()
end

function M.toggle()
    if enabled then M.stop() else M.start() end
end

-- Start 2s after load so the xrandr line in autostart has time to finish
gears.timer.start_new(2, function() M.start(); return false end)

return M
