---
name: git-operations
description: 处理常见的 Git 操作，包括 pull、add、commit、push。始终在执行任何 Git 命令前获得用户明确确认，使用 conventional commit 规范生成提交信息，并确保操作安全且透明。
license: MIT
compatibility: opencode
metadata:
  category: development
  tools: bash-git
---

# Git 操作技能

## 何时使用本技能
- 用户需要更新本地代码（pull）、暂存更改（add）、提交代码（commit）或推送更改（push）时。
- 用户要求进行 Git 相关操作，但未明确指定细节。
- 需要生成符合 Conventional Commits 规范的提交信息时。
- 任何涉及代码仓库变更的操作，必须优先考虑安全性和用户确认。

## 核心原则（必须严格遵守）
- **用户确认优先**：在执行任何 `git` 命令前，必须先清晰询问用户是否同意执行该操作。只有获得用户**明确同意**（如“是”、“确认”、“执行”等）后才能运行命令。
- **绝不自动执行**：如果用户拒绝、取消或犹豫，立即停止操作，不要执行任何命令，并等待用户下一步指示。
- **透明性**：每次执行命令后，必须向用户展示完整命令输出结果。如果出现错误，清晰解释错误原因并提供可能的解决方案。
- **提交信息规范**：使用 Conventional Commits 风格生成提交信息，格式为 `<type>: <描述>`。
- **最小干预**：默认使用安全命令（如 `git add .`），但允许用户指定具体文件或参数。

## 支持的操作及详细流程

### 1. Git Pull（拉取最新代码）
当用户需要同步远程仓库最新更改时：
- 先询问用户：“是否现在执行 `git pull` 更新本地代码？”
- 获得明确同意后，执行 `git pull`。
- 执行完成后，完整显示命令输出。
- 如果有冲突或错误，解释原因并建议用户手动处理或提供下一步指导。

### 2. Git Add（暂存更改）
当用户需要将修改添加到暂存区时：
- 默认询问：“是否执行 `git add .` 添加所有更改到暂存区？”
- 如果用户指定特定文件，改用对应命令（如 `git add <file>`）。
- 获得同意后执行命令。
- 显示执行结果（包括暂存的文件列表）。

### 3. Git Commit（提交更改）
当用户需要提交暂存的更改时：
- 先询问用户是否要提交。
- 获得同意后：
  1. 检查暂存区：运行 `git diff --cached`（若无暂存更改，则检查 `git diff`）。
  2. 分析更改的文件和具体代码差异。
  3. 根据更改类型自动生成 Conventional Commits 风格的提交信息：
     - 新功能 → `feat: ...`
     - Bug 修复 → `fix: ...`
     - 文档更新 → `docs: ...`
     - 代码重构 → `refactor: ...`
     - 样式/格式调整 → `style: ...`
     - 测试相关 → `test: ...`
     - 构建/依赖/其他杂项 → `chore: ...`
- 向用户展示生成的提交信息，并询问：“是否使用此提交信息？如需修改请直接提供新信息。”
- 使用用户确认（或修改后）的消息执行 `git commit -m "<提交信息>"`。
- 显示提交结果。

**提交信息生成示例**：
- 添加用户登录功能 → `feat: add user login functionality`
- 修复分页问题 → `fix: resolve pagination issue`
- 更新 README 文档 → `docs: update README`
- 重构用户验证模块 → `refactor: user validation module`
- 格式化代码 → `style: format code`
- 添加单元测试 → `test: add unit tests`
- 更新依赖版本 → `chore: update dependencies`

### 4. Git Push（推送更改）
当用户需要将本地提交推送到远程仓库时：
- 询问用户：“是否现在执行 `git push` 推送更改到远程仓库？”
- 获得明确同意后执行 `git push`。
- 显示完整输出结果。
- 如果 push 失败（如需要 force 或有远程冲突），解释原因并建议安全解决方案（避免盲目使用 `--force`）。

## 注意事项与最佳实践
- 始终优先用户意图和安全，不要假设用户想要执行危险操作（如 force push）。
- 如果仓库状态复杂（未暂存更改、分支问题等），先报告当前状态（如 `git status` 输出），再询问下一步。
- 支持组合操作：用户可一次性要求 “pull → add → commit → push”，但每一步仍需分别确认。
- 遇到权限、认证、网络等问题时，指导用户检查 SSH key、远程 URL 或凭证。

通过本技能，Git 操作将始终安全、规范且用户可控。
