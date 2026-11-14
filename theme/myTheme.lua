------------------------------------
-- Edgerunners awesome theme      --
-- yellow / cyan / red on black   --
------------------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources   = require("beautiful.xresources")
local dpi          = xresources.apply_dpi
local gears        = require("gears")
local gfs          = require("gears.filesystem")
local themes_path  = gfs.get_themes_dir()

local theme = {}

-- Palette (also read by config/wibar.lua as beautiful.yellow, beautiful.cyan...)
theme.yellow       = "#fcee0a"
theme.cyan         = "#02d7f2"
theme.red          = "#ff003c"
theme.panel_bg     = "#0a0a0f"
theme.panel_bg_alt = "#16160c"
theme.dim          = "#4a4a3a"

-- Needs a Nerd Font; pango falls back to a default font if it is missing
theme.font = "JetBrainsMono Nerd Font 10"

theme.bg_normal   = theme.panel_bg
theme.bg_focus    = theme.panel_bg_alt
theme.bg_urgent   = theme.red
theme.bg_minimize = "#1a1a10"
theme.bg_systray  = theme.panel_bg

theme.fg_normal   = "#c8c35c"
theme.fg_focus    = theme.yellow
theme.fg_urgent   = "#ffffff"
theme.fg_minimize = "#ffffff"

-- Borders / gaps: sharp edges, picom adds the glow
theme.useless_gap   = dpi(8)
theme.border_width  = dpi(2)
theme.border_normal = "#2a2a14"
theme.border_focus  = theme.yellow
theme.border_marked = theme.red

-- Cut-corner shape used everywhere (the "breach protocol" look)
local function cut(size)
    return function(cr, w, h) gears.shape.cut_corner(cr, w, h, size) end
end

-- Taglist: chamfered squares
theme.taglist_shape                = cut(dpi(5))
theme.taglist_shape_border_width   = dpi(1)
theme.taglist_shape_border_color_focus    = theme.yellow
theme.taglist_shape_border_color_occupied = "#6b6718"
theme.taglist_shape_border_color_empty    = "#26261c"
theme.taglist_shape_border_color_urgent   = theme.red
theme.taglist_bg_focus     = theme.yellow
theme.taglist_fg_focus     = theme.panel_bg
theme.taglist_bg_occupied  = theme.panel_bg_alt
theme.taglist_fg_occupied  = theme.yellow
theme.taglist_bg_empty     = theme.panel_bg
theme.taglist_fg_empty     = theme.dim
theme.taglist_bg_urgent    = theme.red
theme.taglist_fg_urgent    = "#ffffff"

-- Tasklist (not shown in the bar, kept in case you re-add it)
theme.tasklist_bg_focus = theme.panel_bg_alt
theme.tasklist_fg_focus = theme.yellow

-- Notifications
theme.notification_font         = theme.font
theme.notification_bg           = theme.panel_bg
theme.notification_fg           = "#e6e2a0"
theme.notification_border_color = theme.yellow
theme.notification_border_width = dpi(2)
theme.notification_margin       = dpi(10)
theme.notification_shape        = cut(dpi(10))

-- Menu
theme.menu_submenu_icon  = themes_path .. "default/submenu.png"
theme.menu_height        = dpi(24)
theme.menu_width         = dpi(180)
theme.menu_bg_normal     = theme.panel_bg
theme.menu_bg_focus      = theme.yellow
theme.menu_fg_normal     = theme.fg_normal
theme.menu_fg_focus      = theme.panel_bg
theme.menu_border_color  = theme.yellow
theme.menu_border_width  = dpi(1)

-- Hotkeys help popup
theme.hotkeys_bg               = theme.panel_bg
theme.hotkeys_fg               = "#e6e2a0"
theme.hotkeys_border_color     = theme.yellow
theme.hotkeys_border_width     = dpi(2)
theme.hotkeys_modifiers_fg     = theme.cyan
theme.hotkeys_label_bg         = theme.yellow
theme.hotkeys_label_fg         = theme.panel_bg
theme.hotkeys_shape            = cut(dpi(14))
theme.hotkeys_font             = theme.font
theme.hotkeys_description_font = theme.font

-- Prompt
theme.prompt_fg        = theme.cyan
theme.prompt_fg_cursor = theme.panel_bg
theme.prompt_bg_cursor = theme.cyan

-- Wallpaper
theme.wallpaper = (os.getenv("HOME") or "") .. "/Pictures/Wallpaper.png"

-- Layout icons (treetile reuses the tile icon)
theme.layout_fairh      = themes_path .. "default/layouts/fairhw.png"
theme.layout_fairv      = themes_path .. "default/layouts/fairvw.png"
theme.layout_floating   = themes_path .. "default/layouts/floatingw.png"
theme.layout_magnifier  = themes_path .. "default/layouts/magnifierw.png"
theme.layout_max        = themes_path .. "default/layouts/maxw.png"
theme.layout_fullscreen = themes_path .. "default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path .. "default/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path .. "default/layouts/tileleftw.png"
theme.layout_tile       = themes_path .. "default/layouts/tilew.png"
theme.layout_treetile   = themes_path .. "default/layouts/tilew.png"
theme.layout_tiletop    = themes_path .. "default/layouts/tiletopw.png"
theme.layout_spiral     = themes_path .. "default/layouts/spiralw.png"
theme.layout_dwindle    = themes_path .. "default/layouts/dwindlew.png"
theme.layout_cornernw   = themes_path .. "default/layouts/cornernww.png"
theme.layout_cornerne   = themes_path .. "default/layouts/cornernew.png"
theme.layout_cornersw   = themes_path .. "default/layouts/cornersww.png"
theme.layout_cornerse   = themes_path .. "default/layouts/cornersew.png"

theme.awesome_icon = theme_assets.awesome_icon(theme.menu_height, theme.yellow, theme.panel_bg)

theme.icon_theme = nil

return theme
