-- Screenshots via external tools (no dependency on awful.screenshot)
local awful   = require("awful")
local naughty = require("naughty")
local vars    = require("config.vars")

local M = {}

local function have(cmd)
	local ok, _, code = os.execute("command -v " .. cmd .. " >/dev/null 2>&1")
	return ok == true or ok == 0 or code == 0
end

local function notify(title, text)
	naughty.notify({ title = title, text = text, timeout = 3 })
end

-- mode: "full" | "select" | "window"; delay: seconds (optional)
function M.take(mode, delay)
	delay = delay or 0
	local d = delay > 0 and (" -d " .. delay) or ""
	local grab

	if have("maim") then
		local flags = ({ full = "", select = "-s", window = "-i $(xdotool getactivewindow)" })[mode] or ""
		grab = string.format('maim %s%s "$f"', flags, d)
	elseif have("scrot") then
		local flags = ({ full = "", select = "-s", window = "-u" })[mode] or ""
		grab = string.format('scrot %s%s "$f"', flags, d)
	else
		notify("Screenshot failed", "Install maim and xclip (or scrot)")
		return
	end

	if delay > 0 then notify("Screenshot", "in " .. delay .. " seconds") end

	-- Temp file + silenced xclip: xclip stays alive to serve the clipboard and
	-- would otherwise keep awesome's output pipe open (callback never fires).
	local cmd = 'f=/tmp/awesome-shot-$$.png; ' .. grab ..
		' && xclip -selection clipboard -t image/png -i "$f" >/dev/null 2>&1; r=$?; rm -f "$f"; exit $r'

	awful.spawn.easy_async_with_shell(cmd, function(_, stderr, _, exit_code)
		if exit_code == 0 then
			notify("Screenshot", "Copié dans le presse-papiers")
		elseif stderr and stderr ~= "" then
			notify("Screenshot failed", stderr)
		end
	end)
end

return M
