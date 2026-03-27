---
description: 检查接口协议实现状态
---
# 接口协议检查

检查 API 接口的实现状态。

## 使用方式

```
/wt-contract
```

## 前置条件

项目根目录应有 `INTERFACE-CONTRACT.md` 文件。

## 接口格式

```markdown
### 接口名称

**路径**: `/api/v1/xxx`
**方法**: GET/POST/PUT/DELETE
**实现方**: thread-name (已完成) | 待实现
```

## 输出示例

```
接口清单:
✓ /api/v1/chapters/{id}/audit-scores → thread-api (B4)
○ /api/v1/chapters/batch_status/{task_id} → 待实现
```

显示哪些接口已实现、哪些待实现。
