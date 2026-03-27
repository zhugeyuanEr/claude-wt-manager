---
allowed-tools: Bash(bash *wt-merge-check.sh:*), Bash(git status:*), Bash(git log:*)
description: 合并前检查
---

## Context

当前目录: !`pwd`
Worktree 列表: !`git worktree list`

## Task

支持自动检测当前 worktree，也支持手动指定线程名称。

1. 如果在 worktree 目录中，自动检测当前 worktree
2. 如果提供了线程名称参数，使用它
3. 执行合并前检查：
   - 与 origin/master 的同步状态
   - 冲突检查
   - 工作区状态
   - 分支信息
4. 输出检查结果和合并建议

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
