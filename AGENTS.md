# AGENTS.md

## What this repo is

Personal Linux dotfiles and config files. Not a software project — no build, test, lint, or typecheck commands exist.

## Deploying configs

The main i3wm setup script symlinks configs into `~/.config/`:

```bash
bash i3wm_setup/config_rofi_i3_polybar_dunst.sh
```

This creates symlinks for: `i3`, `i3blocks`, `i3_scripts`, `polybar`, `ranger`, `rofi`, `dunst`.

Platform-specific variants live at root level: `i3/`, `polybar/`, `rofi/`, `bspwm/`, `sxhkd/` etc.

## Platform-specific directories

| Directory | Purpose |
|---|---|
| `Aarch64_platform/` | ARM64 / Nvidia TX2 configs |
| `AMD_platform/` | AMD GPU configs |
| `Intel_platform/` | Intel GPU configs |
| `mac_m2_ubuntu_setup/` | Ubuntu on Apple Silicon (kernel mods, swap, grub) |
| `Windows/` | Windows-specific configs |

## Git submodules

One submodule: `i3wm_setup/tmux/plugins/tpm` (tmux plugin manager). Initialize with `git submodule update --init --recursive`.

## Notable configs

- `.bashrc` — includes ROS Kinetic setup (`source /opt/ros/kinetic/setup.bash`), likely stale on newer systems
- `.profile` — HiDPI scaling env vars (`GDK_SCALE=2`, `GDK_DPI_SCALE=0.5`)
- `i3wm_setup/` — the canonical i3wm config set with install scripts
- `Auto_scripts/` — standalone installers (nvim, zsh, alacritty/st)
- `utility_tool_bash/` — small helper scripts
