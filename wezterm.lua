-- Load the wezterm module
local wezterm = require 'wezterm'

-- Initialize configuration object
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- Use WebGPU for better performance
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"

-- Set theme Catpuccin
config.color_scheme = 'Solarized Osaka Night'

-- FONT
config.font = wezterm.font {
  family = 'JetBrains Mono',
  weight = 'Medium',
  harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }, -- disable ligatures
}
config.font_size = 16.0
config.line_height = 1.0

-- Blinking cursor
config.window_padding = { left = '0.5cell', right = '0.5cell', top = '0.5cell', bottom = '0.5cell' }
config.default_cursor_style = 'BlinkingBar'

config.window_decorations = 'RESIZE|INTEGRATED_BUTTONS'
config.window_background_opacity = 0.96
config.macos_window_background_blur = 20

-- Maximize windows on startup
wezterm.on("gui-startup", function(cmd)
  local active = wezterm.gui.screens().active
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():set_position(active.x, active.y)
  window:gui_window():set_inner_size(active.width, active.height)
end)

-- Key Bindings
config.keys = {
  { key = 'd', mods = 'CMD|SHIFT', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'd', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'k', mods = 'CMD', action = wezterm.action.ClearScrollback 'ScrollbackAndViewport' },
  { key = 'w', mods = 'CMD', action = wezterm.action.CloseCurrentPane { confirm = false } },
  { key = 'w', mods = 'CMD|SHIFT', action = wezterm.action.CloseCurrentTab { confirm = false } },
  { key = 'LeftArrow', mods = 'CMD', action = wezterm.action.SendKey { key = 'Home' } },
  { key = 'RightArrow', mods = 'CMD', action = wezterm.action.SendKey { key = 'End' } },
  { key = 'p', mods = 'CMD|SHIFT', action = wezterm.action.ActivateCommandPalette },
}

-- Set Nushell as the default shell
config.default_prog = {'/usr/local/bin/nu'}

-- Get the home directory (works on both macOS and Windows)
local home = os.getenv("HOME") or os.getenv("USERPROFILE") or ""

-- Set XDG_CONFIG_HOME environment variable for Nushell
config.set_environment_variables = {
    XDG_CONFIG_HOME = home .. "/.config",
}

local quick_select_patterns = {
  -- Nushell error paths (like ╭─[/path/to/file.nu:1946:63])
  "─\\[(.*\\:\\d+\\:\\d+)\\]",

  -- Table patterns
  -- $env.config.table.mode = "default"
  -- $env.config.table.header_on_separator = true
  -- $env.config.footer_mode = "always"
  "(?<=─|╭|┬)([a-zA-Z0-9 _%.-]+?)(?=─|╮|┬)", -- Headers
  "(?<=│ )([a-zA-Z0-9 _.-]+?)(?= │)", -- Column values

  -- File paths (stops at ~, allows dots in path but stops before dot+space)
  "/[^/\\s│~]+(?:/[^/\\s│~]+)*(?:\\.(?!\\s)[a-zA-Z0-9]+)?",
}

config.quick_select_patterns = quick_select_patterns

return config
