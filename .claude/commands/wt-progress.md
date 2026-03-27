---
description: 检查所有 worktree 的开发进度
---
# 开发进度

检查所有 worktree 的开发进度。

## 使用方式

```
/wt-progress              # 自动检测当前 worktree
/wt-progress thread-ux   # 指定 worktree
```

## 输出内容

- 各线程进度条 (████░░░░░ 60%)
- 检查点完成状态
- 阻塞项列表
- 剩余工作量估算

## 自动检测

从目录路径提取 worktree 名称:
- `/worktree-thread-ux/` → `thread-ux`
- `/worktree-thread-api/` → `thread-api`
