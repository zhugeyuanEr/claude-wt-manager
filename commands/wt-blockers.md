---
description: 查看所有 worktree 的阻塞清单
---
# 阻塞清单

查看所有线程的阻塞项。

## 使用方式

```
/wt-blockers
```

## 输出格式

```
## 阻塞清单

### thread-ux
- ⚠ 等待 thread-api 的 audit-scores API (B4)
  - 状态: NEW
  - 建议: thread-api 优先完成 B4

### thread-advanced
- ⚠ 依赖 thread-ux 的质量评分 UI
  - 状态: 进行中
  - 建议: thread-ux 完成后通知
```

## 实现方式

1. 运行 `git worktree list` 查找所有 worktree
2. 读取 `THREAD-*-PLAN.md` 文件
3. 从各 plan 中提取阻塞项
4. 按线程分组
5. 显示状态和解决建议

## 无阻塞时

输出: "✓ 当前无阻塞项"
