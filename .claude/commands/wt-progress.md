---
allowed-tools: Bash(bash *wt-progress.sh:*), Glob(*THREAD-*-PLAN.md:*)
description: 检查当前线程或所有线程的开发进度
---

## Context

当前目录: !`pwd`
当前 worktree: !`bash $(git rev-parse --show-toplevel)/scripts/wt-detect.sh 2>/dev/null || echo ""`
Worktree 列表: !`git worktree list`

## Task

1. 如果提供了线程名称，使用它
2. 如果没有提供，尝试自动检测当前 worktree
3. 如果是 "all"，检查所有线程

运行 wt-progress.sh 脚本生成进度报告，包括：
- 各线程进度条 (████░░░░░ 60%)
- 检查点完成状态
- 阻塞项列表 (如果有)
- 剩余工作量估算

同时读取各线程的 THREAD-*-PLAN.md 解析具体进度。
