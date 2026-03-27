---
allowed-tools: Bash(bash *wt-qa.sh:*), Bash(git status:*), Bash(npm test:*), Bash(pytest:*)
description: 对当前 worktree 或指定线程进行质量检测
---

## Context

当前目录: $(pwd)
当前 worktree: $(bash "$(git rev-parse --show-toplevel 2>/dev/null)/scripts/wt-detect.sh" 2>/dev/null || echo "unknown")

## Task

1. 确定目标 worktree（参数或自动检测）
2. 运行质量检测：
   - 代码规范检查 (npm run lint / ruff check)
   - 类型检查 (tsc --noEmit)
   - 测试执行 (npm test / pytest)
   - Git 状态检查
3. 输出报告：
   - CRITICAL (必须修复)
   - HIGH (强烈建议)
   - MEDIUM (建议优化)
   - 每项附带文件位置和修复建议

如果所有检查通过，输出 "✓ 质量检测通过"。
