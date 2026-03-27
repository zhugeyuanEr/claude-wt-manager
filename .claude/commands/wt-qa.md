---
description: 对当前或指定的 worktree 进行质量检测
---
# 质量检测

对当前或指定的 worktree 进行质量检查。

## 使用方式

```
/wt-qa              # 自动检测当前 worktree
/wt-qa thread-api   # 指定 worktree
```

## 检查项

1. **代码规范** - 运行 linter (npm run lint / ruff / golangci-lint)
2. **类型检查** - 运行类型检查 (tsc --noEmit / mypy / go vet)
3. **测试** - 运行测试套件 (npm test / pytest / go test)
4. **Git 状态** - 检查未提交的更改

## 输出格式

```
## QA 报告: thread-ux

### ✓ 通过
- TypeScript 类型检查
- 单元测试 (23/23)

### ✗ 失败
- ESLint: 2 个警告

### 建议
- [HIGH] 合并前修复 lint 警告
- [MEDIUM] 添加 API 集成测试
```

全部通过输出: "✓ 质量检测通过"
