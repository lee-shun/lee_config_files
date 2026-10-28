# pi-tasks（本地 vendor 版）

`pi-simple-tasks` 0.1.3 的精简副本。上游已于 2026-10-03 从 npm 和 GitHub 一并删除
（registry 返回 `404 Unpublished`，`github.com/usamaasfar/pi-simple-tasks` 也 404），
所以把它 vendor 到本地，settings.json 里用本地路径引用：

```jsonc
"packages": [ /* ... */ "local/pi-tasks" ]   // 相对 ~/.pi/agent 解析
```

`~/.pi/agent/local/pi-tasks` 是指向本目录的符号链接（与 settings.json / models.json 同样的纳管方式）。

## 相对上游删掉了什么

| | 上游 0.1.3 | 本副本 |
|---|---|---|
| 代码 | 259 行 | 261 行（本地加了可点击的分页 widget，见下） |
| 注册工具 | `tasks` + `tasks_reset` | 只有 `tasks` |
| subtasks 嵌套 | 有 | 无（每次调用都要重发嵌套对象，浪费 token） |
| 运行时依赖 | 0 | 0 |

清空清单改为传空数组：`{"tasks": []}`。

保留：整表重建语义、composer 上方悬浮清单（全部完成后自动收起）、`/tasks` 弹窗、
`session_start` / `session_tree` 状态重建（跨 `/reload`、分支、compaction 均正确）。

## 本地改动：清单分页 + 可点击按钮

上游把清单交给 `ctx.ui.setWidget(key, string[])`，pi 对字符串数组 widget 硬截 10 行，
多出来的任务只能显示成一行死的 `… N more`，点不动。

本副本改传组件工厂（`setWidget(key, (tui, theme) => new TasksWidget(...))`）：

- 默认显示 8 条（表头 + 8 行 + 按钮 = 10 行，跟改之前的占位一样大）。
- 点 `[ 显示更多 +N ▾ ]` 每次多 8 条，可连点；全部露出来后按钮变 `[ 收起 ▴ ]`。
- 分页位置存在 widget 外的 `model` 里，agent 更新清单不会把你的展开状态冲掉。
- 高度预算自己算：`floor(terminal.rows * 0.4) - 2`。dock 对 widget 是 `shrink:1, minSize:0`，
  撑太高会被 pi 整块挤掉，所以到顶时改成 `… N 条 · 终端不够高，用 /tasks 看全部`，
  不放一个点了没反应的按钮。

**只有全屏模式能点**：pi 只在 alt-screen（`tuiMode: "fullscreen"`，默认值）打开鼠标上报，
regular 模式鼠标归终端，任何按钮都点不到——键盘路径是 `/tasks` 弹窗看全表。
事件链：alt-screen `dispatchMouseToLayout` → `widgetContainerAbove`（普通 `Container`，
没有 layout node，所以不会被那句 `handleMouse === Container.prototype.handleMouse` 的跳过分支拦掉）
→ `Container.handleMouse` 按行高把 y 换算成局部坐标 → `TasksWidget.handleMouse`。
一次物理点击 pi 会发 press 和 click 两个事件，只认 click，否则一次点击翻两页。

自检两套，都在 `tests/`：

- `node tests/click-check.mjs` — 用 jiti 按 pi 扩展加载器的 alias 方式载入真扩展，合成鼠标事件直接驱动
  `TasksWidget`（24 项：翻页/收起、误点不响应、press 不重复触发、宽字符列宽、高度封顶走 /tasks 提示、
  RPC 宿主退回字符串数组）。
- `node tests/click-e2e.mjs` — 真跑一遍 pi 的全屏链：真 `TuiAltScreen`（`mouse: true`）+ pi 自己的
  `createChatViewport` 布局，widget 挂在 `widgetsAbove` 同一槽位，渲染出真 frame，
  再从 frame 里找到按钮的屏幕坐标，喂终端会发的 SGR 字节（`\x1b[<0;col;rowM` + `…m`）。
  8 项：点得到、点完不会触发选中复制、点任务行/点空白不翻页。

## 改动生效

编辑 `extensions/tasks.ts` 后在 TUI 里 `/reload` 即可，无需重启。
pi 的扩展加载器会把 `typebox` / `@earendil-works/pi-tui` / `@earendil-works/pi-coding-agent`
alias 到 pi 自身，所以本目录不需要 node_modules。
