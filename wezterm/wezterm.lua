local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font("JetBrains Mono")
config.font_size = 14
config.color_scheme = "Catppuccin Mocha"
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = true
config.window_background_opacity = 0.8
config.window_padding = {
  left = "0px",
  right = "0px",
  top = "0px",
  bottom = "0px"
}
config.enable_wayland = true

return config
