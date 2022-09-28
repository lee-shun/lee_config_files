local wezterm = require("wezterm")

local default_prog = {}
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	default_prog = { "powershell.exe", "-NoLogo" }
else
	default_prog = { "/usr/bin/zsh", "-l" }
end

local configuration = {
	default_prog = default_prog,
	font = wezterm.font_with_fallback({
		"Hasklug NF",
		{ family = "Microsoft YaHei", weight = "Medium" },
		"Noto Color Emoji",
	}),
	font_size = 14.0,
	color_scheme = "nord",
	enable_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
}
return configuration
