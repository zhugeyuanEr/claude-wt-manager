# Claude WT Manager

Claude Code 命令集，用于管理多线程 Git Worktree 开发。

## 核心概念

- **Worktree**：Git 工作树，允许同时在多个分支上工作
- **Thread**：开发线程，对应一个 Worktree
- **Level**：线程层级，决定依赖和合并顺序

## 线程层级

```
Level 0: thread-infra (基础设施)
    ↓
Level 1: thread-api (后端 API)
    ↓
Level 2: thread-ux (前端 UX)
    ↓
Level 3: thread-advanced (高级功能)
```

## 可用命令

| 命令 | 描述 | 自动检测 |
|------|------|----------|
| `/wt-plan` | 分析项目，生成 worktree 规划 | 否 |
| `/wt-status` | 显示所有 worktree 状态 | 否 |
| `/wt-progress` | 检查进度 | 是 |
| `/wt-qa` | 质量检查 | 是 |
| `/wt-batch-qa` | 批量质量检测 | 否 |
| `/wt-contract` | 接口协议检查 | 否 |
| `/wt-merge-check` | 合并前验证 | 是 |
| `/wt-report` | 生成完整进度报告 | 否 |
| `/wt-dev` | 启动/继续开发 | 是 |
| `/wt-commit` | 提交当前更改 | 是 |
| `/wt-blockers` | 查看阻塞清单 | 是 |
| `/wt-help` | 显示所有命令帮助 | 否 |

## 自动检测

从目录路径自动提取 worktree 名称：
- `/worktree-thread-ux/` → `thread-ux`
- `/worktree-thread-api/` → `thread-api`

## 合并顺序

必须按 Level 从低到高合并：
```
infra → api → ux → advanced
```

**说明**: thread-advanced 在 thread-infra 完成后可并行开发，但必须最后合并。

## PLAN 文件命名

| Thread | PLAN 文件 |
|--------|----------|
| thread-infra | `THREAD-INFRA-PLAN.md` |
| thread-api | `THREAD-API-PLAN.md` |
| thread-ux | `THREAD-UX-PLAN.md` |
| thread-advanced | `THREAD-ADVANCED-PLAN.md` |

**格式**: `THREAD-{线程名大写}-PLAN.md`
