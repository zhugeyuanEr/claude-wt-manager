---
description: 切换到指定 worktree
---
# 切换 Worktree

切换到指定名称的 worktree 目录。

## 使用方式

```
/wt-switch              # 交互式选择
/wt-switch thread-ux    # 直接切换到指定 worktree
```

## 执行流程

1. 如果未指定 worktree，列出所有可用的 worktree 供选择
2. 验证目标 worktree 是否存在
3. 切换到目标 worktree 目录
4. 显示切换后的当前位置和分支信息

## 验证

切换前检查:
- worktree 是否存在
- 是否有未提交的更改（如果有，提示确认）

## 注意事项

- 不支持在 Windows 上直接使用 `git worktree switch`
- 使用 `cd` 命令切换到目标 worktree 目录
