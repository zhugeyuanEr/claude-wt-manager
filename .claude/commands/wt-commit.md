---
description: 提交当前 worktree 的更改
---
# 提交更改

提交当前 worktree 的更改。

## 使用方式

```
/wt-commit
```

## 执行流程

1. 显示当前 git 状态
2. 显示变更摘要
3. 交互确认:
   - commit 类型 (feat/fix/docs/test/chore)
   - commit 消息
   - 确认没有包含不该提交的文件
4. 执行 git add 和 git commit
5. 输出 commit hash

## Commit 消息格式

```
<type>: <description>

[optional body]
```

类型: feat, fix, docs, test, chore, refactor, perf, ci

## 工作区干净时

输出: "无更改可提交，工作区干净"
