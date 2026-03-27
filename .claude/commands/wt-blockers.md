---
allowed-tools: Glob(*THREAD-*-PLAN.md:*), Read(*PLAN.md:*)
description: 查看阻塞清单
---

## Context

当前目录: !`pwd`
Worktree 列表: !`git worktree list`

## Task

收集所有线程 PLAN 文件中的阻塞项，输出汇总报告：

1. **全局阻塞项**
   - 阻塞描述
   - 阻塞者 (哪个线程/任务)
   - 状态 (NEW/IN_PROGRESS/RESOLVED)
   - 建议处理方式

2. **按线程分组**
   - 每个线程的阻塞项
   - 解除阻塞的建议

如果没有阻塞项，输出 "✓ 当前无阻塞项"。

格式示例：
```
## 阻塞清单

### Thread-ux
- ⚠ 等待 Thread-api 的 audit-scores API (B4)
  - 状态: NEW
  - 建议: Thread-api 优先完成 B4

### Thread-advanced
- ⚠ 依赖 Thread-ux 的质量评分 UI
  - 状态: IN_PROGRESS
  - 建议: Thread-ux 完成后通知
```
