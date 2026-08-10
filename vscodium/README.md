# VSCodium + VSCodeVim 配置

> 本目录管理 VSCodium 的 VSCodeVim 插件配置，通过软链接部署到
> `~/.config/VSCodium/User/`。
>
> - `settings.json`   → `~/.config/VSCodium/User/settings.json`
> - `keybindings.json` → `~/.config/VSCodium/User/keybindings.json`

## 背景

以 `~/.config/nvim` 的按键与功能为参照，把 nvim 习惯迁移到
VSCodium 的 VSCodeVim 插件（vscodevim.vim 1.32.4），并禁用与 vim
重复的原生快捷键。

---

## 更改说明

### 1. settings.json — 编辑器与 vim 选项

**对应 nvim 的 `lua/config/options.lua`：**

| 设置 | 值 | 来源（nvim） |
|---|---|---|
| `vim.leader` | `<space>` | `mapleader=" "` |
| `vim.hlsearch` / `vim.incsearch` | true | `hlsearch` / `incsearch` |
| `vim.ignorecase` / `vim.smartcase` | true | `ignorecase` / `smartcase` |
| `vim.whichwrap` | `b,s,<,>,[,]` | `whichwrap` |
| `vim.iskeyword` | `@,48-57,_,192-255,$,%,#` | `iskeyword += _,$,@,%,#`（含默认值） |
| `vim.matchpairs` | `(:),{:},[:],<:>` | `matchpairs` |
| `vim.textwidth` | 80 | `textwidth=80` |
| `vim.timeout` | 800 | `timeoutlen=800` |
| `vim.showcmd` / `vim.showmodename` | true | `showcmd` / `showmode` |
| `vim.useSystemClipboard` | true | `clipboard=unnamedplus` |
| `vim.smartRelativeLine` | true | `relativenumber` |
| `vim.visualstar` | true | 视觉模式 `*` 搜索 |
| `vim.surround` | true | mini.surround |
| `vim.targets.enable` | true | text-objects |
| `vim.highlightedyank.enable` | true | yank 高亮 autocmd |
| `vim.cursorStylePerMode` | normal/visual=block, insert=line | 按模式光标 |

**对应 nvim 的 VSCode 原生项：**

| 设置 | 值 | 来源（nvim） |
|---|---|---|
| `editor.lineNumbers` | `relative` | `number + relativenumber` |
| `editor.rulers` | `[81, 121]` | `colorcolumn=81,121` |
| `editor.cursorSurroundingLines` | 5 | `scrolloff=5` |
| `editor.renderLineHighlight` | `all` | `cursorline` |
| `editor.tabSize` / `insertSpaces` | 4 / true | `tabstop=4, expandtab` |
| `editor.detectIndentation` | false | 强制 4 空格 |
| `editor.renderWhitespace` | `all` | `listchars`（近似） |
| `workbench.editor.enablePreview` | false | buffer 行为近似 |

**Normal 模式按键映射（`vim.normalModeKeyBindingsNonRecursive`）**
—— 对应 nvim `keymaps.lua` 及各插件：

| 按键 | 功能 | 对应 nvim |
|---|---|---|
| `Y` | yank 到行尾 | `Y` → `y$` |
| `[e` / `]e` | 行上移 / 下移 | `[e` / `]e` |
| `[<space>` / `]<space>` | 上方 / 下方插空行 | `[<leader>` / `]<leader>` |
| `K` | LSP hover | `K` |
| `↑` `↓` `←` `→` | 调整窗口高 / 宽 | 方向键 resize |
| `<C-w>h/l/j/k` | 切左 / 右 / 下 / 上窗口 | `<C-w>h/l/j/k` |
| `<C-w>w` | 循环切换窗口 | `<C-w>w` |
| `<space>t` | 打开文件树 | `<leader>t` (NvimTree) |
| `<space>ff` | 快速打开文件 | `<leader>ff` |
| `<space>fw` | 全局搜索 | `<leader>fw` |
| `<space>fb` | 已打开文件列表 | `<leader>fb` |
| `<space>fd` | 问题 / 诊断面板 | `<leader>fd` |
| `<space>fs` | 符号大纲 | `<leader>fs` |
| `<space>fm` | 最近文件 | `<leader>fm` |
| `<space>fl` | 跳转到行 | `<leader>fl` |
| `<space>ft` | 插入片段 | `<leader>ft` |
| `<space>cf` | 格式化文档 | `<leader>cf` |
| `<space>cr` | 全局替换 | `<leader>cr` (spectre) |
| `<space>bd` | 关闭编辑器 | `<leader>bd` |
| `<space>gj` / `<space>gk` | 下一 / 上一 diff | `<leader>gj` / `gk` |
| `<space>mr` | Markdown 预览 | `<leader>mr` |
| `<space>rt` | 切换终端 | `<leader>rt` |
| `<space>sa` / `sd` / `sr` | surround 增 / 删 / 改 | `<leader>sa/sd/sr` |
| `gc` | 注释行 | `gc` (Comment.nvim) |
| `<space>db` | 切换断点 | `<leader>db` |
| `<space>dc/di/do/ds` | 继续 / 步入 / 步出 / 单步 | `<leader>dc/di/do/ds` |
| `<space>du` | 调试视图 | `<leader>du` |

**Visual 模式映射（`vim.visualModeKeyBindingsNonRecursive`）：**

| 按键 | 功能 | 对应 nvim |
|---|---|---|
| `J` / `K` | 选中行下移 / 上移 | Visual `J` / `K` |
| `<space>p` | 粘贴不覆盖寄存器 | `<leader>p` |
| `gc` | 注释选中行 | `gc` |

### 2. keybindings.json — 禁用重复原生快捷键

在 **Normal/Visual 模式**（`vim.mode != 'Insert' && vim.mode != 'Replace'`）
禁用与 vim 重复的原生快捷键，Insert 模式保留原生行为：

| 原生快捷键 | 原生功能 | vim 替代 |
|---|---|---|
| `Ctrl+D` | 添加下一匹配 | `Ctrl-D` 半页下翻 |
| `Ctrl+F` | 查找 | `Ctrl-F` 页下翻 |
| `Ctrl+G` | 跳转到行 | `Ctrl-G` 文件状态 |
| `Ctrl+H` | 文件中替换 | `Ctrl-H` 光标左移 |
| `Ctrl+B` | 切换侧边栏 | `Ctrl-B` 页上翻 |
| `Ctrl+W` | 关闭编辑器 | `Ctrl-W` 窗口前缀 |
| `Ctrl+Shift+K` | 删除行 | `dd` |
| `Ctrl+Shift+[` / `]` | 折叠 / 展开 | `za` / `zo` / `zc` |
| `Alt+↑` / `Alt+↓` | 移动行 | `[e` / `]e`、Visual `J`/`K` |
| `Ctrl+Shift+↑` / `↓` | 复制行 | — |

**补全弹出时的 Tab / Enter 行为**（对应 nvim `pumvisible` 分支）：

| 按键 | 补全弹出时 | 无补全时 |
|---|---|---|
| `Tab` | 选择下一个建议 | 正常缩进 |
| `Shift+Tab` | 选择上一个建议 | — |
| `Enter` | 确认选择（VSCode 默认） | 正常换行 |

### 3. 已知限制

- `gc` 的 `gcc` 会被拆成 `gc` + `c`（vscodevim 限制），整行注释建议用
  `<space>t` 旁的原生 `Ctrl+/` 或 `gcc` 实测。
- `<C-w>` 系列为显式映射（直接调用原生命令），`<C-w>v/s` 分割、
  `<C-w>q` 关闭仍由 vscodevim 内置处理。
- 多键前缀（`<space>`、`<C-w>`）需在 800ms 内完成第二键（`vim.timeout`）。

---

## 使用说明

### 部署（软链接）

```bash
ln -sf ~/.config/lee_config_files/vscodium/settings.json   ~/.config/VSCodium/User/settings.json
ln -sf ~/.config/lee_config_files/vscodium/keybindings.json ~/.config/VSCodium/User/keybindings.json
```

### 修改配置后生效

1. 编辑本目录下的 `settings.json` / `keybindings.json`
2. 在 VSCodium 中执行 `Ctrl+Shift+P` → **Developer: Reload Window**

### 排错

- **按键不生效**：确认已 Reload Window；`Ctrl+Shift+U` 打开 Output
  面板，下拉选 **Vim** 查看按键日志。
- **`<space>` 开头的映射失效**：检查 `vim.timeout` 是否为数字（毫秒），
  布尔值会导致超时立即触发、多键映射全部失效（曾踩过的坑）。
- **光标样式**：`vim.cursorStylePerMode.*`，取值
  `block` / `line` / `underline` / `line-thin` 等。
