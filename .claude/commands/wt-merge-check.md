---
allowed-tools: Bash(bash *wt-merge-check.sh:*), Bash(git status:*), Bash(git log:*)
description: 合并前检查 (需指定线程名)
---

## Context

当前目录: !`pwd`
Worktree 列表: !`git worktree list`

## Task

**注意**: 这个命令需要指定线程名称作为参数

1. 切换到指定的 worktree
2. 执行合并前检查：
   - 与 origin/master 的同步状态
   - 冲突检查
   - 工作区状态
   - 分支信息
3. 输出检查结果和合并建议

如果检查通过，输出 "✓ 可以合并"。
如果有问题，列出具体问题和修复建议。

示例输出：
```
>>> 同步状态检查
  ✓ 已与 origin/master 同步

>>> 冲突检查
  ✓ 无冲突

>>> 工作区状态
  ✓ 工作区干净

建议: 可以合并
```
