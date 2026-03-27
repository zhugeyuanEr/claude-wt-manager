---
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git add:*), Bash(git commit:*)
description: 提交当前 worktree 的更改
---

## Context

当前目录: !`pwd`
当前 worktree: !`bash $(git rev-parse --show-toplevel)/scripts/wt-detect.sh 2>/dev/null || echo ""`
Git 状态: !`git status`
Git 分支: !`git branch --show-current`
最近提交: !`git log --oneline -5`

## Task

1. 显示当前 worktree 的 git 状态
2. 显示变更摘要
3. 交互确认：
   - commit type (feat/fix/docs/test/chore)
   - commit message
   - 没有包含不该提交的文件
4. 执行 git add 和 git commit
5. 输出 commit hash

如果工作区干净，提示无需提交。
