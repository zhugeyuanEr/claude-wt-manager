---
allowed-tools: Read(*INTERFACE-CONTRACT.md:*), Bash(bash *wt-contract.sh:*)
description: 检查接口协议实现状态
---

## Context

项目根目录: !`git rev-parse --show-toplevel`
接口协议: !`cat $(git rev-parse --show-toplevel)/INTERFACE-CONTRACT.md 2>/dev/null | head -100`

## Task

读取 INTERFACE-CONTRACT.md 文件，检查各接口的实现状态：

1. 列出所有接口及其实现方
2. 标记已实现的接口 (实现方完成)
3. 标记未实现的接口 (TODO)
4. 显示接口依赖关系

输出格式：
```
接口清单:
✓ /api/v1/chapters/{id}/audit-scores → 线程B (B4)
○ /api/v1/chapters/batch_status/{task_id} → TODO
```

如果有未实现的接口，给出哪些线程应该实现这些接口。

---

## INTERFACE-CONTRACT.md 格式要求

脚本期望以下格式：

```markdown
### 接口名称

**路径**: `/api/v1/xxx`
**方法**: GET/POST/PUT/DELETE
**实现方**: Thread-name (已完成) | TODO
```

**示例**:
```markdown
### 获取审核分数

**路径**: `/api/v1/chapters/{id}/audit-scores`
**方法**: GET
**实现方**: thread-api (B4)
```

```markdown
### 批量状态查询

**路径**: `/api/v1/chapters/batch_status/{task_id}`
**方法**: GET
**实现方**: TODO
```
