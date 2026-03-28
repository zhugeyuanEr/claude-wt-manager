---
description: 自动分析项目并生成 worktree 规划方案
---
# Worktree 规划

分析项目结构，生成合理的 worktree 分配方案。

## 使用方式

```
/wt-plan                    # 自动分析，推荐数量和策略
/wt-plan 3                 # 指定 3 个 worktree
/wt-plan 3 level           # 使用层级策略
/wt-plan 3 module          # 使用模块策略
/wt-plan 3 feature         # 使用功能策略
/wt-plan 3 team            # 使用团队策略
/wt-plan 2 frontend-backend # 简单前后端分离
```

## 分配策略

### `level` - 层级策略（默认）

按依赖层级分配，适用于大多数项目。

```
Level 0: thread-infra (基础设施)
    ↓
Level 1: thread-api (核心 API)
    ↓
Level 2: thread-ux (前端 UX)
    ↓
Level 3: thread-advanced (高级功能)
```

### `module` - 模块策略

按服务/模块边界分配，适用于微服务架构。

### `feature` - 功能策略

按功能领域分配，适用于功能独立的项目。

### `team` - 团队策略

按团队/职责划分，适用于多人协作。

### `frontend-backend` - 前后端分离

简单的 2 线分离，适用于中小型前后端分离项目。

## 分析步骤

1. 扫描项目结构 (frontend/backend/modules)
2. 分析代码规模 (行数、文件数)
3. 识别依赖关系
4. 评估复杂度

## 推荐数量

```
基础: 2 (前端 + 后端)
+1 if 文件数 > 100
+1 if 文件数 > 300
+1 if 文件数 > 500
+1 if 文件数 > 800
+1 if 存在 tests/ 目录
+1 if 存在 .github/ 目录
最大: 6
```

## 交互式输入

当指定数量后，脚本会逐个询问每个 worktree 的：
- **名称**: 默认依次为 thread-infra, thread-api, thread-ux 等，可自定义
- **工作内容**: 该 worktree 负责的开发任务描述

示例：
```
>>> 阶段3: 定义每个 Worktree 的工作内容...

  --- Worktree 1/3 ---
    名称 [thread-infra]:
    工作内容: 搭建 CI/CD 流水线，配置 Docker 环境

  --- Worktree 2/3 ---
    名称 [thread-api]:
    工作内容: 开发用户认证和权限管理 API

  --- Worktree 3/3 ---
    名称 [thread-ux]:
    工作内容: 开发登录页面和仪表盘 UI
```

## 输出内容

- 项目分析摘要
- 每个 worktree 的名称和工作内容
- 依赖关系图（自动根据 level 计算）
- 详细规划表
- 合并顺序: infra → api → ux → advanced
- git worktree 创建命令
