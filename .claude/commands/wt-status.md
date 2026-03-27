---
allowed-tools: Bash(git worktree list:*), Bash(bash *wt-status.sh:*)
description: 显示所有 worktree 的当前状态
---

## Context

当前目录: !`pwd`
Worktree 列表: !`git worktree list`

## Task

运行 wt-status.sh 脚本显示所有 worktree 的详细状态，包括：
- 各 worktree 名称和分支
- 工作区状态 (clean/dirty)
- 当前所在 worktree

输出格式化的状态报告。
