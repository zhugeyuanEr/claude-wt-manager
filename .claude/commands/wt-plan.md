---
allowed-tools: Bash(find:*), Bash(git:*), Glob(**/*.{py,ts,vue,go,java,rs}*), Read(*.md:*), Read(*PLAN.md:*)
description: 自动分析项目并生成 worktree 规划方案 (可指定数量和分配策略)
---

## Context

项目根目录: $(git rev-parse --show-toplevel 2>/dev/null || echo "unknown")
当前分支: $(git branch --show-current 2>/dev/null || echo "unknown")
Git 历史: $(git log --oneline -20 2>/dev/null || echo "无")

## Task

分析当前项目，生成合理的 worktree 规划方案。

---

## 使用方式

```
/wt-plan                    # 自动分析，推荐 worktree 数量和策略
/wt-plan 3                 # 指定 3 个 worktree，使用默认策略
/wt-plan 3 level           # 指定 3 个 worktree，使用层级策略
/wt-plan 3 module          # 指定 3 个 worktree，使用模块策略
/wt-plan 3 feature         # 指定 3 个 worktree，使用功能策略
/wt-plan 3 team            # 指定 3 个 worktree，使用团队策略
/wt-plan 3 frontend-backend # 指定 2 个 worktree，简单前后端分离
```

---

## 分配策略

### 策略 1: `level` - 层级策略（默认）

按依赖层级分配，适用于大多数项目。

```
Level 0 (thread-infra)
    ↓
Level 1 (thread-api)
    ↓
Level 2 (thread-ux)
    ↓
Level 3 (thread-advanced)
```

**分配规则**:
- Level 0: 基础设施、测试框架、配置、CI/CD
- Level 1: 核心业务逻辑、API、数据模型
- Level 2: 前端 UI、UX、样式
- Level 3: 高级特性、集成、优化

---

### 策略 2: `module` - 模块策略

按服务/模块边界分配，适用于微服务架构。

**识别模块**:
- 扫描 `services/`、`modules/`、`apps/` 目录
- 识别 `package.json`、`requirements.txt`、`go.mod` 等
- 按功能内聚性分组

**分配示例**（电商系统）:
```
thread-user        # 用户模块
thread-product     # 商品模块
thread-order       # 订单模块
thread-payment     # 支付模块
```

**合并顺序**: 按模块间依赖拓扑排序

---

### 策略 3: `feature` - 功能策略

按功能领域分配，适用于功能独立的项目。

**识别功能域**:
- 识别核心功能（如电商的 用户、商品、订单）
- 识别支撑功能（如搜索、推荐、通知）
- 识别高级功能（如 AI 助手、数据分析）

**分配示例**:
```
thread-auth        # 认证授权
thread-search      # 搜索功能
thread-notification # 通知功能
thread-analytics   # 数据分析
```

**合并顺序**: 核心功能优先，高级功能最后

---

### 策略 4: `team` - 团队策略

按团队/职责划分，适用于多人协作。

**识别维度**:
- 前端团队 / 后端团队
- 平台团队 / 业务团队
- 独立团队（如 AI 团队、数据团队）

**分配示例**:
```
thread-frontend    # 前端团队
thread-backend     # 后端团队
thread-platform    # 平台团队
thread-ai          # AI 团队
```

**合并顺序**: 平台基础设施优先，业务功能次之

---

### 策略 5: `frontend-backend` - 前后端分离

简单的 2 线分离，适用于中小型前后端分离项目。

```
thread-backend    # 后端 API + 业务逻辑
thread-frontend   # 前端 UI + UX
```

**特点**:
- 只有 2 个 worktree
- 合并顺序固定: backend → frontend
- 适合 2-4 人小团队

---

## 阶段1: 项目分析

1. **扫描项目结构**
   - 识别前端/后端模块
   - 识别微服务或大模块
   - 识别独立功能域
   - 识别多团队边界

2. **分析代码规模**
   - 各模块代码行数
   - 文件数量
   - 目录深度

3. **识别依赖关系**
   - 模块间依赖
   - 前后端依赖
   - 基础设施依赖

4. **评估复杂度**
   - 业务复杂度
   - 技术复杂度
   - 集成复杂度

---

## 阶段2: Worktree 数量建议

根据分析结果，计算推荐的 worktree 数量：

**计算公式**:
```
MODULE_COUNT = 2  (基础: 前端 + 后端)
MODULE_COUNT += 1  if 文件数 > 100
MODULE_COUNT += 1  if 文件数 > 300
MODULE_COUNT += 1  if 文件数 > 500
MODULE_COUNT += 1  if 文件数 > 800
MODULE_COUNT += 1  if 存在 tests/ 目录
MODULE_COUNT += 1  if 存在 .github/ 目录
MODULE_COUNT += 1  if 存在 editor 组件
MODULE_COUNT += 1  if 存在 generation 组件
MODULE_COUNT = min(MODULE_COUNT, 6)
```

**数量约束**:
- ≤2 个模块: 1-2 个 worktree
- 3-6 个模块: 2-3 个 worktree
- 7-12 个模块: 3-4 个 worktree
- 13+ 个模块: 4-6 个 worktree
- 人工上限: 6 个 (超过需拆分项目)

**如果用户指定了数量**:
- 使用用户指定数量
- 如果数量明显不合理 (>6 或 <模块数)，给出警告并要求确认

---

## 阶段3: 任务分配

根据选定策略分配任务：

### `level` 策略分配

```
Level 0: thread-infra    → 基础设施
Level 1: thread-api      → 核心 API
Level 2: thread-ux       → 前端 UX
Level 3: thread-advanced → 高级功能
```

### `module` 策略分配

按模块边界分配，每个模块一个 thread。

### `feature` 策略分配

按功能域分配，核心功能先行。

### `team` 策略分配

按团队划分，每个团队一个 thread。

### `frontend-backend` 策略分配

```
thread-backend   → 后端全部
thread-frontend  → 前端全部
```

---

## 阶段4: 输出规划

生成完整的规划文档，包括：

```markdown
# Worktree 规划方案

## 项目分析摘要

- 总模块数: X
- 代码规模: XXX 行
- 复杂度评级: 低/中/高

## 分配策略

- 策略: level | module | feature | team | frontend-backend
- 理由: ...

## 推荐 Worktree 数量

- 推荐: X 个
- 理由: ...

## Worktree 分配

### thread-infra (Level 0: 基础设施)
- 职责: 配置、测试框架、基础设施
- 任务: T1, T2, T3
- 依赖: 无

### thread-api (Level 1: 核心功能)
- 职责: [模块A, 模块B]
- 任务: T4, T5
- 依赖: thread-infra

...

## 依赖关系图

```
thread-infra ──▶ thread-api ──▶ thread-ux ──▶ thread-advanced
      │
      └─────────────────────────────▶ thread-advanced (并行)
```

**说明**: thread-advanced 在 thread-infra 完成后可并行开发，但必须最后合并。

## 开发顺序

1. thread-infra (Level 0)
2. thread-api (Level 1)
3. thread-ux (Level 2)
4. thread-advanced (Level 3)

---

## 确认流程

### 如果用户未指定策略和数量

1. 显示分析结果
2. 显示推荐的 worktree 数量
3. 显示推荐的分配策略
4. 等待用户确认或调整

```
推荐 3 个 worktree，使用 level 策略，原因:
- 项目有 5 个主要模块
- 前后端分离，基础设施独立
- 使用层级策略便于依赖管理

确认? (y/n/调整)
- 输入 "3 module" → 调整为 3 个，使用模块策略
- 输入 "2" → 调整为 2 个，使用前后端分离策略
```

### 如果用户指定了数量

1. 如果 数量 > 6:
   ```
   警告: 指定数量 (8) 超过推荐上限 (6)
   原因: 人工监督多线开发的复杂度上限为 6
   建议: 考虑拆分项目或减少 worktree 数量
   ```

2. 如果 数量 < 2:
   ```
   警告: 指定数量 (1) 过少
   原因: 单线开发效率低
   建议: 至少 2 个 worktree
   ```

### 如果用户指定了策略

验证策略是否适用于当前项目结构：
- `module`: 需要有明确的模块边界
- `team`: 需要有明确的团队划分
- `frontend-backend`: 仅适用于 2 个 worktree

---

## 执行命令模板

生成后输出类似以下内容：

```bash
# 创建 thread-infra (基础设施)
git worktree add worktree-thread-infra feature/thread-infra
cd worktree-thread-infra
# → 在此 worktree 中进行基础设施开发

# 创建 thread-api (核心功能)
git worktree add worktree-thread-api feature/thread-api
...

# 合并顺序
# 1. thread-infra → main (Level 0 先合并)
# 2. thread-api → main
# 3. thread-ux → main
```

---

## 输出要求

1. 始终先分析后规划
2. 数量建议要有明确理由
3. 策略选择要适合项目特点
4. 不合理的数量要警告并确认
5. 生成的规划要可执行
6. 包括文件创建和 Git 操作命令

---

## 策略选择指南

| 项目特点 | 推荐策略 |
|----------|----------|
| 通用项目 | `level` |
| 微服务架构 | `module` |
| 功能独立项目 | `feature` |
| 多人多团队 | `team` |
| 中小型前后端 | `frontend-backend` |
