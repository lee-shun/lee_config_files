# Lee 的 Linux 配置文件

个人 Linux 桌面环境的配置文件集合。

## 窗口管理器

- **i3-gaps** — 平铺窗口管理器（`i3/`）
- **bspwm** — 备用平铺窗口管理器（`bspwm/`）

## 状态栏与通知

- **polybar** — 状态栏配置（`polybar/`）
- **i3blocks** — i3 状态块（`i3blocks/`）
- **dunst** — 通知守护进程（`dunst/`）

## 终端与工具

- **tmux** — 终端复用器（`tmux/`）
- **ranger** — 终端文件管理器
- **rofi** — 应用启动器
- **alacritty** / **st** — GPU 加速终端
- **kitty** / **wezterm** — 终端配置
- **zathura** — 终端 PDF 阅读器
- **joshuto** — 终端文件管理器
- **xfce4-terminal** — 终端主题

## Shell

- **oh-my-bash** — Bash 框架与插件
- **oh-my-zsh** — Zsh 框架与插件

## 其他配置

- **compton** / **picom** — 窗口合成器
- **redshift** — 屏幕色温调节
- **sxhkd** — 快捷键守护进程

## 平台特定配置

| 目录 | 说明 |
|---|---|
| `Aarch64_platform/` | ARM64 / Nvidia TX2 |
| `AMD_platform/` | AMD GPU |
| `Intel_platform/` | Intel GPU |
| `mac_m2_ubuntu_setup/` | Apple Silicon 上的 Ubuntu（内核修改、swap、grub） |
| `Windows/` | Windows 相关配置 |

## 一键部署

### 创建配置软链接

```bash
bash auto_scripts/config_rofi_i3_polybar_dunst.sh
```

将 `i3`、`i3blocks`、`i3_scripts`、`polybar`、`ranger`、`rofi`、`dunst` 软链接到 `~/.config/`。

### 安装脚本

| 脚本 | 说明 |
|---|---|
| `auto_scripts/install_i3wm_repo_apt.sh` | 安装 i3-gaps（需 sudo） |
| `auto_scripts/compile_install_picom.sh` | 编译安装 picom（需 sudo） |
| `auto_scripts/compile_install_polybar.sh` | 编译安装 polybar（需 sudo） |
| `auto_scripts/install_zsh_oh_my_zsh.sh` | 安装 zsh + oh-my-zsh |
| `auto_scripts/clone_install_xfce4_terminal_themes.sh` | 安装 xfce4 终端主题 |
| `auto_scripts/mod_hpdi.sh` | 配置 HiDPI 和 Xresources |

## 公共工具模块

`utility_tool_bash/common_utils.sh` 提供日志、权限检查、包管理、软链接、Git 操作等公共函数，所有安装脚本统一使用。
