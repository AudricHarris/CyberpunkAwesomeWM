-- Shared variables. Everything else requires this instead of using globals.
local M = {}

M.modkey    = "Mod4"
M.terminal  = "kitty"
M.editor    = os.getenv("EDITOR") or "nvim"
M.editor_cmd = M.terminal .. " -e " .. M.editor
M.home      = os.getenv("HOME")
M.screenshot_dir = M.home .. "/Images/Screenshots"
-- Full path to the video wallpaper. Leave nil to auto-find Edgerunner.mp4
-- (see config/videowall.lua for the places it looks).
-- M.videowall = M.home .. "/Videos/Edgerunner.mp4"

return M
