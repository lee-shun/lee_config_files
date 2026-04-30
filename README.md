# Lee 的 Linux 配置文件

个人 Linux 桌面环境的配置文件集合，主要包含以下内容：

## 窗口管理器

- **i3-gaps** — 平铺窗口管理器（`i3/` 和 `i3wm_setup/i3/`）
- **bspwm** — 备用平铺窗口管理器（`bspwm/`）

## 状态栏与通知

- **polybar** — 状态栏配置（`polybar/`）
- **i3blocks** — i3 状态块（`i3blocks/`）
- **dunst** — 通知守护进程（`i3wm_setup/dunst/`）

## 终端与工具

- **tmux** — 终端复用器（`tmux/`、`tmux_new/`）
- **ranger** — 终端文件管理器
- **rofi** — 应用启动器
- **alacritty** / **st** — GPU 加速终端
- **kitty** / **wezterm** — 终端配置
- **zathura** — 终端 PDF 阅读器
- **joshuto** — 终端文件管理器

## 其他配置

- **compton** — 合成器
- **redshift** — 屏幕色温调节
- **sxhkd** — 快捷键守护进程
- **oh-my-bash** / **oh-my-zsh** — Shell 主题与插件

## 平台特定配置

| 目录 | 说明 |
|---|---|
| `Aarch64_platform/` | ARM64 / Nvidia TX2 |
| `AMD_platform/` | AMD GPU |
| `Intel_platform/` | Intel GPU |
| `mac_m2_ubuntu_setup/` | Apple Silicon 上的 Ubuntu（内核修改、swap、grub） |
| `Windows/` | Windows 相关配置 |

## 部署

运行以下命令将 i3wm 配置软链接到 `~/.config/`：

```bash
bash i3wm_setup/config_rofi_i3_polybar_dunst.sh
```

该脚本会创建以下目录的软链接：`i3`、`i3blocks`、`i3_scripts`、`polybar`、`ranger`、`rofi`、`dunst`。

## Git 子模块

包含一个 tmux 插件管理器子模块，初始化方式：

```bash
git submodule update --init --recursive
```
