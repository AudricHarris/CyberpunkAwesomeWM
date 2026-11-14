-- keys/init.lua: collects every key module into one root.keys call.
-- To add a new group of binds: create keys/<name>.lua returning a gears.table.join(...)
-- table, then add it to the list below.
local gears = require("gears")

local M = {}

M.global = gears.table.join(
    require("keys.awesome"),
    require("keys.tags"),
    require("keys.focus"),
    require("keys.layout"),
    require("keys.launcher"),
    require("keys.screenshots")
    -- require("keys.media"),   -- <- example: add yours here
)

M.client        = require("keys.client")
M.clientbuttons = require("keys.buttons")

root.keys(M.global)

return M
