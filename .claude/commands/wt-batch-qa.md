---
allowed-tools: Bash(bash *wt-batch-qa.sh:*)
description: 批量质量检测
---

## Context

项目根目录: $(git rev-parse --show-toplevel 2>/dev/null || echo "unknown")
Worktree 列表: $(git worktree list 2>/dev/null || echo "无法获取")

## Task

对所有 worktree 进行批量质量检测：

1. 遍历所有 `worktree-thread-*` 目录
2. 在每个 worktree 中运行：
   - Lint 检查 (npm run lint 或 ruff check)
   - 测试 (npm test 或 pytest)
3. 汇总结果

输出格式：
```
>>> 检测: thread-ux
  ✓ Lint 通过
  ✓ 测试通过

>>> 检测: thread-api
  ✗ Lint 失败

===============================================
结果: 2/3 通过
⚠ 1 个失败
```

如果全部通过，输出 "✓ 全部通过"。
