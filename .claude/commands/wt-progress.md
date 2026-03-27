---
allowed-tools: Bash(bash *wt-progress.sh:*), Glob(*THREAD-*-PLAN.md:*)
description: 检查当前线程或所有线程的开发进度
---

## Context

当前目录: $(pwd)
当前 worktree: $(bash "$(git rev-parse --show-toplevel 2>/dev/null)/scripts/wt-detect.sh" 2>/dev/null || echo "unknown")
Worktree 列表: $(git worktree list 2>/dev/null || echo "无法获取")

## Task

wt-progress.sh 始终检查所有 worktree 的进度。

运行 wt-progress.sh 脚本生成进度报告，包括：
- 各线程进度条 (████░░░░░ 60%)
- 检查点完成状态
- 阻塞项列表 (如果有)
- 剩余工作量估算

同时读取各线程的 THREAD-*-PLAN.md 解析具体进度。
