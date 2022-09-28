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
	color_scheme = "nordfox",
	enable_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	disable_default_key_bindings = true,
	keys = {
		{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
		{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
		{ key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize },
		{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize },
		{ key = "j", mods = "ALT", action = wezterm.action.ScrollByLine(-3) },
		{ key = "k", mods = "ALT", action = wezterm.action.ScrollByLine(3) },
		{ key = "j", mods = "CTRL|ALT", action = wezterm.action.ScrollByPage(-1) },
		{ key = "k", mods = "CTRL|ALT", action = wezterm.action.ScrollByPage(1) },
        { key = 'x', mods = 'CTRL', action = wezterm.action.ActivateCopyMode },
        { key = 'q', mods = 'CTRL', action = wezterm.action.QuickSelect }
	},
}
return configuration
