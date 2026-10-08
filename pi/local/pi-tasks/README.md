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
| 代码 | 259 行 | 141 行 |
| 注册工具 | `tasks` + `tasks_reset` | 只有 `tasks` |
| subtasks 嵌套 | 有 | 无（每次调用都要重发嵌套对象，浪费 token） |
| 运行时依赖 | 0 | 0 |

清空清单改为传空数组：`{"tasks": []}`。

保留：整表重建语义、composer 上方悬浮清单（全部完成后自动收起）、`/tasks` 弹窗、
`session_start` / `session_tree` 状态重建（跨 `/reload`、分支、compaction 均正确）。

## 改动生效

编辑 `extensions/tasks.ts` 后在 TUI 里 `/reload` 即可，无需重启。
pi 的扩展加载器会把 `typebox` / `@earendil-works/pi-tui` / `@earendil-works/pi-coding-agent`
alias 到 pi 自身，所以本目录不需要 node_modules。
