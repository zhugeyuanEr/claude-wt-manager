---
allowed-tools: Bash(cd *), Bash(git worktree*), Read(*THREAD-*-PLAN.md:*), Read(*INTERFACE-CONTRACT.md:*)
description: 在 worktree 中启动或继续开发
---

## Context

当前目录: !`pwd`
当前 worktree: !`bash $(git rev-parse --show-toplevel)/scripts/wt-detect.sh 2>/dev/null || echo ""`
Worktree 列表: !`git worktree list`

## Task

1. 确定目标 worktree（参数或自动检测当前）
2. 读取该线程的 THREAD-*-PLAN.md 了解：
   - 当前迭代任务
   - 下一步行动
   - 依赖的接口
3. 读取 INTERFACE-CONTRACT.md 了解该线程提供的接口
4. 显示：
   - 当前进度摘要
   - 当前/下一步任务
   - 需要的接口
   - 阻塞项（如果有）
5. 等待确认后开始协助开发

如果指定的任务 ID 存在，定位到该任务；否则找到下一个未完成的任务。
