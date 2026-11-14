-- Video wallpaper: one mpv window per screen, pinned behind everything.
-- Needs only mpv (no xwinwrap). Toggle with Mod+Shift+w.
--
-- Where the video is looked for (first one that exists wins):
--   vars.videowall (config/vars.lua), then Edgerunner.mp4 next to rc.lua,
--   ~/Videos/Edgerunner_wall.mp4, ~/Videos/Edgerunner.mp4,
--   ~/Pictures/Edgerunner.mp4, ~/Downloads/Edgerunner.mp4, ~/Edgerunner.mp4
--
-- If it fails, a red notification tells you why (missing mpv, missing file,
-- or mpv's own error text).
local awful   = require("awful")
local gears   = require("gears")
local naughty = require("naughty")
local vars    = require("config.vars")
local menu    = require("config.menu")

local M = {}
local TAG = "awesome-videowall"                  -- marker for pkill / window instance
local PAT = "^awesome%-videowall%-(%d+)$"        -- instance name = TAG-<screen index>
local enabled, generation = false, 0
local restart_timer

local function notify(title, text)
    naughty.notify({ preset = naughty.config.presets.critical,
        title = title, text = text, timeout = 12 })
end

local function have(cmd)
    local ok, _, code = os.execute("command -v " .. cmd .. " >/dev/null 2>&1")
    return ok == true or ok == 0 or code == 0
end

local function find_video()
    local cfg, home = gears.filesystem.get_configuration_dir(), vars.home
    local list = {
        vars.videowall,
        cfg  .. "Edgerunner.mp4",
        home .. "/Videos/Edgerunner_wall.mp4",
        home .. "/Videos/Edgerunner.mp4",
        home .. "/Pictures/Edgerunner.mp4",
        home .. "/Downloads/Edgerunner.mp4",
        home .. "/Edgerunner.mp4",
    }
    for _, p in ipairs(list) do
        if p and gears.filesystem.file_readable(p) then return p end
    end
end

---------------------------------------------------------------- the mpv windows
local function launch(s, video, gen)
    local g  = s.geometry
    local t0 = os.time()
    awful.spawn.easy_async({
        "mpv", "--no-config",
        "--x11-name=" .. TAG .. "-" .. s.index, "--title=" .. TAG,
        string.format("--geometry=%dx%d+%d+%d", g.width, g.height, g.x, g.y),
        "--no-border", "--no-audio", "--loop-file=inf", "--panscan=1.0",
        "--no-osc", "--osd-level=0", "--no-input-default-bindings",
        "--input-conf=/dev/null", "--cursor-autohide=no",
        "--stop-screensaver=no", "--hwdec=auto-safe",
        "--msg-level=all=error", video,
    }, function(stdout, stderr, _, code)
        -- ignore processes we killed on purpose (restart / toggle off)
        if gen ~= generation or not enabled then return end
        if os.time() - t0 < 5 then
            notify("Video wallpaper stopped (exit " .. tostring(code) .. ")",
                (stderr ~= "" and stderr or stdout ~= "" and stdout or "no output") ..
                "\nTry the command by hand in a terminal to see more.")
        end
    end)
end

-- Turn the mpv window into a wallpaper: floating, below everything, on every
-- workspace, never focused, hidden from taskbars, exactly the screen's size.
local function style(c)
    local idx = c.instance and c.instance:match(PAT)
    if not idx then return end
    local s = screen[tonumber(idx)]
    if not s then return end
    c.screen = s
    c.floating = true
    c.fullscreen = false
    c.maximized = false
    c.size_hints_honor = false
    c.border_width = 0
    c.below = true
    c.ontop = false
    c.sticky = true
    c.skip_taskbar = true
    c.focusable = false
    c:geometry(s.geometry)
    -- clicks land on this window, so give it the desktop mouse bindings
    c:buttons(gears.table.join(
        awful.button({ }, 1, function() menu.main:hide() end),
        awful.button({ }, 3, function() menu.main:toggle() end),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)))
end

client.connect_signal("manage", function(c)
    if c.instance and c.instance:match(PAT) then
        -- run after the other manage handlers / rules have had their say
        gears.timer.delayed_call(function()
            if c.valid then style(c) end
            gears.timer.delayed_call(function() if c.valid then style(c) end end)
        end)
    end
end)

---------------------------------------------------------------- start / stop
function M.stop()
    enabled = false
    generation = generation + 1
    awful.spawn({ "pkill", "-f", TAG })
end

function M.start()
    local video = find_video()
    if not video then
        notify("Video wallpaper: file not found",
            "Put Edgerunner.mp4 in ~/.config/awesome/ (or ~/Videos/), " ..
            "or set M.videowall in config/vars.lua.")
        return
    end
    if not have("mpv") then
        notify("Video wallpaper: mpv not installed", "Install mpv with your package manager.")
        return
    end

    generation = generation + 1
    local gen = generation
    enabled = true
    -- kill any previous instance first, then start one player per screen
    awful.spawn.easy_async({ "pkill", "-f", TAG }, function()
        if gen ~= generation then return end
        for s in screen do launch(s, video, gen) end
    end)
end

function M.toggle()
    if enabled then M.stop() else M.start() end
end

-- Screens changed (xrandr finished, monitor plugged...): restart after things settle
local function schedule_restart()
    if not enabled then return end
    if not restart_timer then
        restart_timer = gears.timer { timeout = 1.5, single_shot = true,
                                      callback = function() M.start() end }
    end
    if restart_timer.started then restart_timer:stop() end
    restart_timer:start()
end
screen.connect_signal("property::geometry", schedule_restart)
screen.connect_signal("added", schedule_restart)
screen.connect_signal("removed", schedule_restart)

-- Don't leave players running when you quit awesome (a restart relaunches anyway)
awesome.connect_signal("exit", function(restart)
    if not restart then os.execute("pkill -f " .. TAG .. " >/dev/null 2>&1") end
end)

-- Start 2s after load so the xrandr line in autostart has time to finish
gears.timer.start_new(2, function() M.start(); return false end)

return M
