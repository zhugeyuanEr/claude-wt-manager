---
description: 在 worktree 中启动或继续开发
---
# 开发

在 worktree 中启动或继续开发。

## 使用方式

```
/wt-dev                  # 自动检测当前 worktree
/wt-dev thread-advanced  # 指定 worktree
```

## 执行流程

1. 确定目标 worktree（参数或自动检测）
2. 读取该线程的 `THREAD-*-PLAN.md` 了解:
   - 当前迭代任务
   - 下一步行动
   - 依赖的接口
3. 读取 `INTERFACE-CONTRACT.md` 了解该线程提供的接口
4. 显示:
   - 当前进度摘要
   - 当前/下一步任务
   - 需要的接口
   - 阻塞项（如果有）
5. 等待确认后开始协助开发

## 自动检测

从目录路径:
- `/worktree-thread-ux/` → `thread-ux`
- `/worktree-thread-api/` → `thread-api`
