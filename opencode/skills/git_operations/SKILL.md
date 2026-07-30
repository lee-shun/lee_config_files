---
name: git-operations
description: 处理常见的 Git 操作，包括 pull、add、commit、push、status、branch、log、stash、diff、reset、merge、rebase、remote。始终在执行任何 Git 命令前获得用户明确确认，使用 conventional commit 规范生成提交信息，并确保操作安全且透明。
license: MIT
compatibility: opencode
metadata:
  category: development
  tools: bash-git
---

# Git 操作技能

## 何时使用本技能
- 用户需要执行任何 Git 操作时。
- 用户要求进行 Git 相关操作，但未明确指定细节。
- 需要生成符合 Conventional Commits 规范的提交信息时。
- 任何涉及代码仓库变更的操作，必须优先考虑安全性和用户确认。

## 核心原则（必须严格遵守）
- **用户确认优先**：在执行任何 `git` 命令前，必须先清晰询问用户是否同意执行该操作。只有获得用户**明确同意**（如"是"、"确认"、"执行"等）后才能运行命令。
- **绝不自动执行**：如果用户拒绝、取消或犹豫，立即停止操作，不要执行任何命令，并等待用户下一步指示。
- **透明性**：每次执行命令后，必须向用户展示完整命令输出结果。如果出现错误，清晰解释错误原因并提供可能的解决方案。
- **提交信息规范**：使用 Conventional Commits 风格生成提交信息，格式为 `<type>: <描述>`。
- **最小干预**：默认使用安全命令，但允许用户指定具体文件或参数。
- **前置检查**：在执行任何可能改变仓库状态的操作前，先运行 `git status` 展示当前仓库状态，让用户了解情况。

## 前置步骤（大部分操作前执行）

在执行任何 Git 操作前，先运行 `git status` 并展示输出，让用户了解当前仓库状态。如果仓库有未暂存/未跟踪的变更，先询问用户如何处理。

## 支持的操作及详细流程

### 1. Git Status（查看仓库状态）
当用户想了解仓库当前状态时：
- 执行 `git status` 并显示完整输出。
- 如有需要，可额外执行 `git status -s`（简洁模式）或 `git status -b`（显示分支信息）。

### 2. Git Log（查看提交历史）
当用户想查看提交历史时：
- 默认执行 `git log --oneline -10` 显示最近 10 条提交。
- 如用户想看更多细节，执行 `git log --oneline -30` 或根据用户要求调整。
- 支持用户指定参数：`--graph`（图形化）、`--all`（所有分支）、`--author`（按作者筛选）等。

### 3. Git Diff（查看差异）
当用户想查看代码变更时：
- 未暂存的变更：`git diff`
- 已暂存的变更：`git diff --cached`
- 特定文件的变更：`git diff <file>`
- 与某次提交的比较：`git diff <commit>`
- 显示统计信息：`git diff --stat`

### 4. Git Pull（拉取最新代码）
当用户需要同步远程仓库最新更改时：
- 先询问用户："是否现在执行 `git pull` 更新本地代码？"
- 获得明确同意后，执行 `git pull`（或 `git pull --rebase` 如果用户偏好 rebase）。
- 执行完成后，完整显示命令输出。
- 如果有冲突或错误，解释原因并建议用户手动处理或提供下一步指导。

### 5. Git Add（暂存更改）
当用户需要将修改添加到暂存区时：
- 默认询问："是否执行 `git add .` 添加所有更改到暂存区？"
- 如果用户指定特定文件，改用对应命令（如 `git add <file>`）。
- 可选择暂存部分更改：`git add -p`（交互式分段暂存）。
- 获得同意后执行命令。
- 显示执行结果（包括暂存的文件列表）。

### 6. Git Commit（提交更改）
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
     - 性能优化 → `perf: ...`
- 向用户展示生成的提交信息，并询问："是否使用此提交信息？如需修改请直接提供新信息。"
- 使用用户确认（或修改后）的消息执行 `git commit -m "<提交信息>"`。
- 如果用户需要详细提交信息，改用 `git commit` 打开编辑器。
- 显示提交结果。

**提交信息生成示例**：
- 添加用户登录功能 → `feat: add user login functionality`
- 修复分页问题 → `fix: resolve pagination issue`
- 更新 README 文档 → `docs: update README`
- 重构用户验证模块 → `refactor: user validation module`
- 格式化代码 → `style: format code`
- 添加单元测试 → `test: add unit tests`
- 更新依赖版本 → `chore: update dependencies`

### 7. Git Push（推送更改）
当用户需要将本地提交推送到远程仓库时：
- 先执行 `git status` 确认本地与远程的提交差异。
- 询问用户："是否现在执行 `git push` 推送更改到远程仓库？"
- 获得明确同意后执行 `git push`。
- 显示完整输出结果。
- 如果 push 失败（如需要 force 或有远程冲突），解释原因并建议安全解决方案（避免盲目使用 `--force`，优先推荐 `--force-with-lease`）。
- 如果是新分支首次推送，使用 `git push -u origin <branch>` 建立上游关联。

### 8. Git Branch（分支管理）
当用户需要管理分支时：

**查看分支：**
- 本地分支：`git branch`
- 所有分支（含远程）：`git branch -a`
- 查看分支与上游关系：`git branch -vv`

**创建分支：**
- 询问分支名称后执行 `git branch <branch-name>` 或 `git switch -c <branch-name>`（创建并切换）。
- 确认后执行。

**切换分支：**
- 询问用户要切换到的分支名。
- 先检查工作区是否干净（如有未暂存更改，建议先 stash 或 commit）。
- 确认后执行 `git switch <branch-name>`。

**删除分支：**
- 已合并的分支：`git branch -d <branch-name>`
- 强制删除（未合并）：`git branch -D <branch-name>`（需用户确认风险）
- 删除远程分支：`git push origin --delete <branch-name>`

**重命名分支：**
- 当前分支：`git branch -m <new-name>`
- 指定分支：`git branch -m <old-name> <new-name>`

### 9. Git Stash（暂存工作进度）
当用户需要暂时保存未提交的更改时：

**暂存更改：**
- 默认：`git stash`
- 带消息的暂存：`git stash push -m "<message>"`（推荐，便于识别）
- 暂存未跟踪文件：`git stash -u` 或 `git stash --include-untracked`

**查看暂存列表：**
- `git stash list`

**恢复暂存：**
- 应用最新暂存并删除：`git stash pop`
- 应用最新暂存但保留：`git stash apply`
- 应用指定暂存：`git stash apply stash@{n}`
- 删除指定暂存：`git stash drop stash@{n}`
- 清除所有暂存：`git stash clear`（需用户确认，不可恢复）

### 10. Git Reset（撤销更改）
**注意：此操作可能造成数据丢失，必须格外谨慎。**

**撤销工作区更改（未暂存）：**
- 恢复单个文件：`git restore <file>`
- 恢复所有文件：`git restore .`（需用户确认）

**撤销暂存（unstage）：**
- 撤销单个文件：`git restore --staged <file>`
- 撤销所有暂存：`git restore --staged .`

**撤销提交（保留更改在工作区）：**
- 撤销最近一次提交，保留更改：`git reset --soft HEAD~1`
- 撤销最近一次提交，保留在工作区（unstaged）：`git reset --mixed HEAD~1`

**⚠️ 危险操作（仅当用户明确要求）：**
- 撤销提交并丢弃所有更改：`git reset --hard HEAD~1`（必须多次警告用户此操作不可恢复）

### 11. Git Merge / Rebase（合并/变基分支）

**Merge（合并）：**
- 先确认当前分支和目标分支。
- 执行 `git merge <branch>`。
- 如有冲突，展示冲突文件列表，指导用户手动解决后执行 `git add` 和 `git merge --continue`。
- 如需取消合并：`git merge --abort`。

**Rebase（变基）：**
- 先确认当前分支和基础分支。
- 执行 `git rebase <base-branch>`。
- 如有冲突，逐步骤解决，指导用户使用 `git add` 后执行 `git rebase --continue`。
- 如需跳过某次提交：`git rebase --skip`。
- 如需取消变基：`git rebase --abort`。
- **⚠️ 提醒用户**：不要对已推送到远程的分支进行 rebase（除非用户明确了解后果）。

### 12. Git Remote（远程仓库管理）
当用户需要管理远程仓库时：

**查看远程：**
- `git remote -v`（显示远程 URL）

**添加远程：**
- 询问远程名称和 URL 后执行 `git remote add <name> <url>`。

**修改远程 URL：**
- `git remote set-url <name> <new-url>`

**删除远程：**
- `git remote remove <name>`（需用户确认）

**查看远程分支：**
- `git ls-remote` 或 `git branch -r`

## 注意事项与最佳实践
- 始终优先用户意图和安全，不要假设用户想要执行危险操作（如 force push、hard reset）。
- 如果仓库状态复杂（未暂存更改、分支问题等），先报告当前状态（如 `git status` 输出），再询问下一步。
- 支持组合操作：用户可一次性要求 "pull → add → commit → push"，但每一步仍需分别确认。
- 遇到权限、认证、网络等问题时，指导用户检查 SSH key、远程 URL 或凭证。
- 避免使用 `git checkout`（语义模糊），优先使用 `git switch` 和 `git restore`。
- 对于破坏性操作（reset --hard、push --force、branch -D、stash clear 等），必须**双重确认**。

通过本技能，Git 操作将始终安全、规范且用户可控。
