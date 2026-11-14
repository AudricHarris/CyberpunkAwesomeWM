-- Focus / swap / screens / urgent
local awful = require("awful")
local gears = require("gears")
local vars  = require("config.vars")

local modkey = vars.modkey

-- Focus the nearest window in a direction. Crosses to the other screen when
-- there is nothing further that way on this one.
local function focus_dir(dir)
    return function()
        local before = client.focus
        awful.client.focus.global_bydirection(dir)
        local c = client.focus
        if c and c ~= before then
            c:raise()
            -- bring the pointer along so sloppy focus doesn't pull focus back
            local g = c:geometry()
            mouse.coords({ x = g.x + g.width / 2, y = g.y + g.height / 2 }, true)
        end
    end
end

-- Move the focused window relative to the others (swap with the neighbour in
-- that direction; past the edge it goes to the other screen). Floating
-- windows are nudged by 40px instead.
local function move_dir(dir)
    return function()
        local c = client.focus
        if not c then return end
        if c.floating then
            local d = { left = {-40, 0}, right = {40, 0}, up = {0, -40}, down = {0, 40} }
            c:relative_move(d[dir][1], d[dir][2], 0, 0)
            return
        end
        awful.client.swap.global_bydirection(dir)
        -- after the layout has re-arranged, bring the pointer along so
        -- sloppy focus doesn't steal focus back
        gears.timer.delayed_call(function()
            if c.valid then
                local g = c:geometry()
                mouse.coords({ x = g.x + g.width / 2, y = g.y + g.height / 2 }, true)
            end
        end)
    end
end

return require("gears").table.join(
    awful.key({ modkey }, "Left",  focus_dir("left"),
        { description = "focus window on the left", group = "client" }),
    awful.key({ modkey }, "Right", focus_dir("right"),
        { description = "focus window on the right", group = "client" }),
    awful.key({ modkey }, "Up",    focus_dir("up"),
        { description = "focus window above", group = "client" }),
    awful.key({ modkey }, "Down",  focus_dir("down"),
        { description = "focus window below", group = "client" }),

    awful.key({ modkey }, "j", function() awful.client.focus.byidx(1) end,
        { description = "focus next by index", group = "client" }),
    awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end,
        { description = "focus previous by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, "Shift" }, "Left",  move_dir("left"),
        { description = "move window left", group = "client" }),
    awful.key({ modkey, "Shift" }, "Right", move_dir("right"),
        { description = "move window right", group = "client" }),
    awful.key({ modkey, "Shift" }, "Up",    move_dir("up"),
        { description = "move window up", group = "client" }),
    awful.key({ modkey, "Shift" }, "Down",  move_dir("down"),
        { description = "move window down", group = "client" }),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey }, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end, { description = "go back", group = "client" }),
    awful.key({ modkey, "Control" }, "n", function()
        local c = awful.client.restore()
        if c then c:emit_signal("request::activate", "key.unminimize", { raise = true }) end
    end, { description = "restore minimized", group = "client" }),

    -- Global (not per-client) on purpose: always works, even on a fullscreen window.
    -- Mod+f toggles fullscreen too; this one only ever EXITS it.
    awful.key({ modkey, "Shift" }, "f", function()
        if client.focus then
            client.focus.fullscreen = false
            client.focus:raise()
        end
    end, { description = "exit fullscreen", group = "client" })
)
