-- Workspace bindings on the shared tag pool (same 1-9 for both screens)
--
-- Rule: an EMPTY workspace goes to whichever screen asks for it.
--       A workspace WITH windows is pinned to the screen it lives on:
--       pressing its number takes you there instead of pulling it over.
local gears      = require("gears")
local awful      = require("awful")
local sharedtags = require("sharedtags")
local vars       = require("config.vars")
local tags       = require("config.screens")   -- returns the shared tag table

local modkey = vars.modkey

-- Clients that count as "real" windows (video wallpaper, docks and other
-- skip-taskbar helpers must not make a workspace look occupied)
local function real_clients(tag)
    local out = {}
    for _, c in ipairs(tag:clients()) do
        if c.type ~= "desktop" and c.type ~= "dock" and not c.skip_taskbar then
            out[#out + 1] = c
        end
    end
    return out
end

-- Most recently focused client of a tag (falls back to its first client)
local function pick_client(tag)
    local cs = real_clients(tag)
    local recent = awful.client.focus.history.get(tag.screen, 0)
    for _, c in ipairs(cs) do
        if c == recent then return c end
    end
    return cs[1]
end

local function warp_to_geometry(g)
    mouse.coords({ x = g.x + g.width / 2, y = g.y + g.height / 2 }, true)
end

-- Move keyboard focus and the mouse to the screen a tag lives on
local function focus_screen_of(tag)
    local target = tag.screen
    awful.screen.focus(target)
    local c = pick_client(tag)
    if c then
        client.focus = c
        c:raise()
        warp_to_geometry(c:geometry())
    else
        warp_to_geometry(target.geometry)
    end
end

local function goto_tag(tag)
    local s = awful.screen.focused()
    if tag.selected then
        -- already visible: if it is on the other screen, go there
        if tag.screen ~= s then focus_screen_of(tag) end
    elseif #real_clients(tag) > 0 then
        -- hidden but has windows: it stays on its own screen
        sharedtags.viewonly(tag, tag.screen)
        if tag.screen ~= s then focus_screen_of(tag) end
    else
        -- empty: free to move, show it on the current screen
        sharedtags.viewonly(tag, s)
    end
end

-- Cycle through the workspaces, skipping the ones pinned to the other screen
local function cycle(step)
    return function()
        local s   = awful.screen.focused()
        local cur = s.selected_tag
        local idx = 1
        for i, t in ipairs(tags) do
            if t == cur then idx = i break end
        end
        local n = idx
        for _ = 1, #tags do
            n = (n - 1 + step) % #tags + 1
            local t = tags[n]
            if t.screen == s or (not t.selected and #real_clients(t) == 0) then break end
        end
        sharedtags.viewonly(tags[n], s)
    end
end

-- Send the focused window to a workspace AND follow it there.
-- An empty workspace is first brought to the current screen, so the window
-- stays on the screen you are working on; a workspace that already has
-- windows stays on its own screen and you are taken there.
local function send_and_follow(tag)
    local c = client.focus
    if not c then return end
    if not tag.selected and #real_clients(tag) == 0 then
        sharedtags.movetag(tag, awful.screen.focused())
    end
    c:move_to_tag(tag)
    goto_tag(tag)
    client.focus = c
    c:raise()
    -- once the layout has re-arranged, bring the pointer to the window
    gears.timer.delayed_call(function()
        if c.valid then warp_to_geometry(c:geometry()) end
    end)
end

local keys = gears.table.join(
    awful.key({ modkey, "Control" }, "Left",  cycle(-1),
        { description = "previous workspace", group = "tag" }),
    awful.key({ modkey, "Control" }, "Right", cycle(1),
        { description = "next workspace", group = "tag" }),
    awful.key({ modkey }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" })
)

-- Keycodes (#10..#18) so it works on any layout (AZERTY included)
for i = 1, 9 do
    keys = gears.table.join(keys,
        awful.key({ modkey }, "#" .. i + 9, function()
            goto_tag(tags[i])
        end, { description = "go to workspace #" .. i, group = "tag" }),

        awful.key({ modkey, "Control" }, "#" .. i + 9, function()
            sharedtags.viewtoggle(tags[i], awful.screen.focused())
        end, { description = "toggle workspace #" .. i, group = "tag" }),

        awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
            send_and_follow(tags[i])
        end, { description = "move window to workspace #" .. i .. " and follow", group = "tag" }),

        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
            if client.focus then client.focus:toggle_tag(tags[i]) end
        end, { description = "toggle focused client on workspace #" .. i, group = "tag" })
    )
end

return keys
