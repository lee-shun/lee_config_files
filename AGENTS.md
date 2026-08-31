# AGENTS.md

## What this repo is

Personal Linux dotfiles and config files. Not a software project — no build, test, lint, or typecheck commands exist.

## Deploying configs

从 repo 根目录运行以下命令将配置软链接到 `~/.config/`：

```bash
bash auto_scripts/config_rofi_i3_polybar_dunst.sh
```

该脚本使用 `get_repo_root()` 自动定位 repo 根目录，创建以下软链接：`i3`、`i3blocks`、`i3_scripts`、`polybar`、`ranger`、`rofi`、`dunst`。

pi 的配置不在 `~/.config/` 下，单独运行：

```bash
bash auto_scripts/config_pi.sh
```

创建软链接：`~/.pi/agent/settings.json` → `pi/settings.json`、`~/.pi/agent/skills` → `pi/skills`。

## auto_scripts 安装脚本

所有脚本均 `source` 了 `utility_tool_bash/common_utils.sh`，具备彩色日志、用户交互、路径自动定位等功能：

| 脚本 | 用途 | 权限 |
|---|---|---|
| `install_i3wm_repo_apt.sh` | 添加 sur5r 仓库并安装 i3-gaps | sudo |
| `compile_install_picom.sh` | 从源码编译安装 picom 合成器 | sudo |
| `compile_install_polybar.sh` | 从源码编译安装 polybar | sudo |
| `config_rofi_i3_polybar_dunst.sh` | 创建配置软链接 | 普通用户 |
| `config_pi.sh` | 创建 pi 配置软链接（`~/.pi/agent/`） | 普通用户 |
| `install_zsh_oh_my_zsh.sh` | 安装 zsh + oh-my-zsh | 部分需 sudo |
| `clone_install_xfce4_terminal_themes.sh` | 克隆 xfce4 终端主题 | 普通用户 |
| `mod_hpdi.sh` | 配置 HiDPI 和 Xresources | 普通用户 |
| `sync_opencode_llamacpp_router.py` | 从 llama.cpp 路由服务器同步 opencode 模型列表（独立 Python，不依赖公共模块） | 普通用户 |

### sync_opencode_llamacpp_router.py 用法

opencode 的本地模型 `llama.cpp` 指向一台以**路由模式**（router mode）运行的 llama.cpp 服务器（默认 `http://192.168.1.105:8080`）。路由模式同时托管多个模型，按请求体里的 `model` 字段路由到对应模型。opencode 会把 `provider.llama.cpp.models` 下的 key 作为 `model` 字段发送，因此每个 key 必须等于路由服务器 `GET /v1/models` 返回的 `id`。

```bash
# 从路由服务器拉取模型列表，重写 opencode/opencode.json 的 models 段（自动备份 .bak）
python3 auto_scripts/sync_opencode_llamacpp_router.py

# 自定义服务器 / 配置文件 / 默认模型
LLAMACPP_ROUTER_URL=http://192.168.1.105:8080 python3 auto_scripts/sync_opencode_llamacpp_router.py --default Qwen3.8-27B-Q5_K_M
```

- 保留配置其余部分；若当前默认模型仍在路由列表中则保持不变，否则回退到已加载/首个模型
- 路由服务器增删模型后重跑即可，无需手改 opencode.json

## pi 配置

pi 编码代理的用户配置，repo 中 `pi/` 目录对应 `~/.pi/agent/`：

| 文件 | 说明 |
|---|---|
| `pi/settings.json` | 全局设置（`defaultProvider`/`defaultModel`/`defaultThinkingLevel`、主题、packages 等） |
| `pi/skills/` | 全局自定义 Skill（每个子目录一个 SKILL.md） |

**不纳入 repo 管理**（保留在 `~/.pi/agent/` 本地）：

- `auth.json` — 含 API key，**不要提交到 git**
- `sessions/`、`missions/`、`wechat-assistant/`、`npm/`、`models-store.json` — 运行时数据/缓存

## i3_scripts 实用脚本

独立小工具，不依赖公共模块：

| 脚本 | 用途 |
|---|---|
| `net_watch.sh` | 外网连通性监测，状态变化时弹通知 |
| `inverse_scroll.sh` | 反向滚动 |
| `tap-to-click.sh` | 触摸板点按 |

### net_watch.sh 用法

```bash
# 后台启动（检测间隔 30s，测试 https://www.baidu.com）
setsid nohup i3_scripts/net_watch.sh >/dev/null 2>&1 </dev/null &

# 自定义配置（环境变量）
NET_WATCH_INTERVAL=10 NET_WATCH_URL=https://www.example.com i3_scripts/net_watch.sh

# 停止 / 查看日志
pkill -f net_watch.sh
tail -f /tmp/net_watch.log
```

- 测试覆盖 DNS + TCP 443，任一不通即判定 down
- 状态变化时 `notify-send` 弹通知（dunst / xfce4-notifyd 均可）：恢复为 critical 级不自动消失，断开为 normal 级
- 适用场景：排查路由器只通 ICMP 不通 TCP/UDP 等故障，等待网络恢复

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
- `pi/` — pi 编码代理配置（软链接到 `~/.pi/agent/`，见「pi 配置」节）

## Notable configs

- `.bashrc` — 包含 ROS Kinetic 设置（`source /opt/ros/kinetic/setup.bash`），新系统可能已过期
- `.profile` — HiDPI 缩放环境变量（`GDK_SCALE=2`、`GDK_DPI_SCALE=0.5`）
- `tmux/` — 模块化 tmux 配置：`.tmux.conf` 为主入口，按职责拆分为 `options.conf`、`statusline.conf`、`plugins.conf`、`keybindings.conf`；插件由 TPM 管理并安装到 gitignore 的 `plugins/`
- `pi/settings.json` — pi 默认模型/思考级别等；`defaultModel` 必须等于 llama.cpp 路由服务器 `GET /v1/models` 返回的 `id`
