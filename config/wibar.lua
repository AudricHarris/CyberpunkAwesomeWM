-- Wibar: Edgerunners HUD bar (workspaces | clock | meters, tray, layout)
local gears     = require("gears")
local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local dpi       = beautiful.xresources.apply_dpi
local vars      = require("config.vars")
local menu      = require("config.menu")

local modkey = vars.modkey

---------------------------------------------------------------- helpers
local function cut(cr, w, h) gears.shape.cut_corner(cr, w, h, dpi(8)) end

-- Cut-corner outlined box (optionally filled)
local function pill(widget, border, bg)
    return wibox.widget {
        {
            widget,
            left = dpi(12), right = dpi(12), top = dpi(3), bottom = dpi(3),
            widget = wibox.container.margin,
        },
        bg                 = bg or (beautiful.panel_bg .. "e6"),
        shape              = cut,
        shape_border_width = dpi(1),
        shape_border_color = border or beautiful.yellow,
        widget             = wibox.container.background,
    }
end

local function read_file(path)
    local f = io.open(path)
    if not f then return nil end
    local s = f:read("*a")
    f:close()
    return s
end

local function label(text, color)
    return string.format("<span foreground='%s'>%s</span>", color, text)
end

-- Text meter like the breach-protocol buffer: ████░░
local function meter(pct, len)
    len = len or 6
    local filled = math.floor(pct / 100 * len + 0.5)
    filled = math.max(0, math.min(len, filled))
    return string.rep("█", filled) .. string.rep("░", len - filled)
end

local function level_color(pct)
    if pct >= 85 then return beautiful.red
    elseif pct >= 60 then return beautiful.yellow
    else return beautiful.cyan end
end

---------------------------------------------------------------- widgets
local keyboardlayout = awful.widget.keyboardlayout()

-- Clock: bold yellow text, no black-on-colour anywhere
local textclock = wibox.widget.textbox()
gears.timer {
    timeout = 5, call_now = true, autostart = true,
    callback = function()
        textclock.markup = string.format("<span foreground='%s'><b>%s // %s</b></span>",
            beautiful.yellow, os.date("%a %d %b"):upper(), os.date("%H:%M"))
    end,
}

-- CPU (reads /proc/stat, no shell involved)
local cpu_widget = wibox.widget.textbox()
local last_total, last_idle = 0, 0
gears.timer {
    timeout = 2, call_now = true, autostart = true,
    callback = function()
        local line = (read_file("/proc/stat") or ""):match("^cpu%s+([^\n]+)")
        if not line then return end
        local v = {}
        for n in line:gmatch("%d+") do v[#v + 1] = tonumber(n) end
        local idle, total = v[4] + (v[5] or 0), 0
        for i = 1, 8 do total = total + (v[i] or 0) end
        local dt, di = total - last_total, idle - last_idle
        local usage = dt > 0 and math.floor((1 - di / dt) * 100 + 0.5) or 0
        last_total, last_idle = total, idle
        cpu_widget.markup = label("CPU", beautiful.cyan) .. " " ..
            label(meter(usage), level_color(usage)) .. string.format(" %02d%%", usage)
    end,
}

-- RAM (reads /proc/meminfo)
local ram_widget = wibox.widget.textbox()
gears.timer {
    timeout = 5, call_now = true, autostart = true,
    callback = function()
        local s = read_file("/proc/meminfo") or ""
        local total = tonumber(s:match("MemTotal:%s+(%d+)"))
        local avail = tonumber(s:match("MemAvailable:%s+(%d+)"))
        if not (total and avail) then return end
        local pct = (total - avail) / total * 100
        ram_widget.markup = label("RAM", beautiful.cyan) .. " " ..
            label(meter(pct), level_color(pct)) ..
            string.format(" %.1fG", (total - avail) / 1048576)
    end,
}

-- Volume (pactl works on PulseAudio and PipeWire-pulse). Click = mute, scroll = +/-5%
local volume_widget = awful.widget.watch(
    { "sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@; pactl get-sink-mute @DEFAULT_SINK@" }, 2,
    function(widget, stdout)
        local vol   = tonumber(stdout:match("(%d+)%%"))
        local muted = stdout:find("Mute: yes") or stdout:find("Silencieux : oui")
        if muted or not vol then
            widget.markup = label("VOL", beautiful.red) .. " " ..
                label(meter(0), beautiful.red) .. " " .. label("MUTE", beautiful.red)
        else
            widget.markup = label("VOL", beautiful.cyan) .. " " ..
                label(meter(math.min(vol, 100)), beautiful.yellow) .. string.format(" %02d%%", vol)
        end
    end)
volume_widget:buttons(gears.table.join(
    awful.button({ }, 1, function() awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end),
    awful.button({ }, 4, function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%") end),
    awful.button({ }, 5, function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%") end)
))

---------------------------------------------------------------- buttons
local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then client.focus:toggle_tag(t) end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

---------------------------------------------------------------- per screen
awful.screen.connect_for_each_screen(function(s)
    s.mypromptbox = awful.widget.prompt()

    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.layout.inc(1) end),
        awful.button({ }, 3, function() awful.layout.inc(-1) end),
        awful.button({ }, 4, function() awful.layout.inc(1) end),
        awful.button({ }, 5, function() awful.layout.inc(-1) end)))

    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        layout  = { spacing = dpi(4), layout = wibox.layout.fixed.horizontal },
        widget_template = {
            {
                { id = "text_role", widget = wibox.widget.textbox },
                left = dpi(8), right = dpi(8),
                widget = wibox.container.margin,
            },
            id     = "background_role",
            widget = wibox.container.background,
        },
    }

    -- The tray can only live on one screen: put it on the primary one
    local right_items = {
        layout  = wibox.layout.fixed.horizontal,
        spacing = dpi(8),
        pill(cpu_widget, beautiful.cyan),
        pill(ram_widget, beautiful.cyan),
        pill(volume_widget, beautiful.cyan),
        pill(keyboardlayout, beautiful.yellow),
    }
    if s == screen.primary then
        table.insert(right_items, pill(
            wibox.widget { wibox.widget.systray(), top = dpi(2), bottom = dpi(2),
                           widget = wibox.container.margin },
            beautiful.yellow))
    end
    table.insert(right_items, pill(s.mylayoutbox, beautiful.yellow))

    -- Transparent bar window: the floating look comes from the boxes (needs picom)
    s.mywibox = awful.wibar({
        position = "top", screen = s, height = dpi(44),
        bg = "#00000000", fg = beautiful.fg_normal,
    })

    s.mywibox:setup {
        {
            layout = wibox.layout.align.horizontal,
            expand = "none",
            { layout = wibox.layout.fixed.horizontal, spacing = dpi(8),
              pill(s.mytaglist, beautiful.yellow), s.mypromptbox },
            pill(textclock, beautiful.yellow),
            right_items,
        },
        top = dpi(6), bottom = dpi(2), left = dpi(10), right = dpi(10),
        widget = wibox.container.margin,
    }
end)

-- Root mouse bindings (right click on the desktop = main menu)
root.buttons(gears.table.join(
    awful.button({ }, 3, function() menu.main:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
