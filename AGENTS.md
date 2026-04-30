# AGENTS.md

## What this repo is

Personal Linux dotfiles and config files. Not a software project — no build, test, lint, or typecheck commands exist.

## Deploying configs

从 repo 根目录运行以下命令将配置软链接到 `~/.config/`：

```bash
bash auto_scripts/config_rofi_i3_polybar_dunst.sh
```

该脚本使用 `get_repo_root()` 自动定位 repo 根目录，创建以下软链接：`i3`、`i3blocks`、`i3_scripts`、`polybar`、`ranger`、`rofi`、`dunst`。

## auto_scripts 安装脚本

所有脚本均 `source` 了 `utility_tool_bash/common_utils.sh`，具备彩色日志、用户交互、路径自动定位等功能：

| 脚本 | 用途 | 权限 |
|---|---|---|
| `install_i3wm_repo_apt.sh` | 添加 sur5r 仓库并安装 i3-gaps | sudo |
| `compile_install_picom.sh` | 从源码编译安装 picom 合成器 | sudo |
| `compile_install_polybar.sh` | 从源码编译安装 polybar | sudo |
| `config_rofi_i3_polybar_dunst.sh` | 创建配置软链接 | 普通用户 |
| `install_zsh_oh_my_zsh.sh` | 安装 zsh + oh-my-zsh | 部分需 sudo |
| `clone_install_xfce4_terminal_themes.sh` | 克隆 xfce4 终端主题 | 普通用户 |
| `mod_hpdi.sh` | 配置 HiDPI 和 Xresources | 普通用户 |

## utility_tool_bash 公共模块

| 文件 | 功能 |
|---|---|
| `common_utils.sh` | 公共工具函数（日志、权限检查、包管理、软链接、Git 操作、路径定位） |
| `log_helper.sh` | 日志辅助函数（可独立 source） |
| `find_the_root.sh` | 向上查找 repo 根目录 |
| `clone_checkout_latest_tag.sh` | 克隆仓库并切换到最新 tag |
| `change_the_directory_mod.sh` | 批量修改目录/文件权限 |

## 目录结构

- 配置目录直接在 repo 根目录：`i3/`、`polybar/`、`rofi/`、`dunst/`、`tmux/` 等
- 平台特定配置：`Aarch64_platform/`、`AMD_platform/`、`Intel_platform/`、`mac_m2_ubuntu_setup/`、`Windows/`
- `oh-my-bash/` 和 `oh-my-zsh/` 已从 `i3wm_setup/` 移到根目录

## Notable configs

- `.bashrc` — 包含 ROS Kinetic 设置（`source /opt/ros/kinetic/setup.bash`），新系统可能已过期
- `.profile` — HiDPI 缩放环境变量（`GDK_SCALE=2`、`GDK_DPI_SCALE=0.5`）
- `tmux/.tmux.conf` — 唯一保留的 tmux 配置，含 TPM 自动安装 bootstrap
