-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.
config.default_prog = { "bash" }

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28

-- or, changing the font size and color scheme.
-- config.font = wezterm.font("Maple Mono SC NF", { weight = "Medium", italic = false })
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"Maple Mono SC NF",
})
config.font_size = 11
config.color_scheme = "Dracula (Official)"

-- bars
config.enable_tab_bar = false
config.enable_scroll_bar = true

-- 取消 WezTerm 对 Ctrl+Space 的拦截
config.keys = {
	{ key = "Space", mods = "CTRL", action = act.DisableDefaultAssignment }
}

-- 确保 IME 功能开启（默认就是 true，显式写一下）
config.xim_im_name = "fcitx"

-- Finally, return the configuration to wezterm:
return config
