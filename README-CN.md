# Claude WT Manager - 多线程开发管理器

Claude Code 命令集，用于管理多个 Git worktree 的并行 AI 辅助开发。

**[English](./README.md) | [安装指南](./INSTALL-CN.md) | [快速参考](./WORKTREE-QUICKSTART.md) | [CLAUDE](./CLAUDE.md)**

## 特性

- **自动检测**：从目录路径自动检测当前所在 worktree
- **多线程协调**：管理 4 个线程的并行开发
- **质量门禁**：内置 QA、接口协议检查、合并验证
- **进度追踪**：所有 worktree 的可视化进度报告
- **依赖管理**：强制执行正确的合并顺序 (infra → api → ux → advanced)

## 架构

```
Thread-infra (Level 0: 基础设施)
    │
    ├──▶ Thread-api (Level 1: 后端 API)
    │         │
    │         └──▶ Thread-ux (Level 2: 前端 UX)
    │                   │
    │                   └──▶ Thread-advanced (Level 3: 高级功能)
    │
    └──────────────────────▶ Thread-advanced (并行)
```

**说明**: thread-advanced 可以在 thread-infra 完成后并行开发，但合并顺序必须在最后。

## 安装

### 方式一：复制命令（任意项目）

将 `.claude` 文件夹和 `scripts` 文件夹复制到项目根目录：

```bash
# 在项目中执行
cp -r .claude/ your-project/
cp -r scripts/ your-project/
```

### 方式二：VSCode 扩展（推荐）

1. 将 `claude-wt-manager/` 文件夹复制到 `.claude/extensions/`
2. 重启 Claude Code

### 方式三：全局安装

```bash
# 克隆到全局目录
git clone https://github.com/zhugeyuanEr/claude-wt-manager.git ~/.claude/extensions/claude-wt-manager
```

## 使用

### 自动检测 Worktree

在 worktree 目录内工作时，命令自动使用当前 worktree 名称：

```bash
cd your-project/worktree-thread-ux
/wt-progress    # 自动检测为 "thread-ux"
/wt-qa          # 对 thread-ux 运行 QA
```

### 手动指定 Worktree

```bash
/wt-progress thread-api    # 查看指定线程
/wt-qa thread-advanced          # 对指定线程进行 QA
/wt-merge-check thread-ux  # 合并前检查
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

## 命令详解

### `/wt-plan` - 项目分析与规划

```
/wt-plan                      # 自动分析，推荐数量和策略
/wt-plan 3                   # 指定 3 个 worktree
/wt-plan 3 level            # 使用层级策略
/wt-plan 3 module           # 使用模块策略
/wt-plan 3 feature          # 使用功能策略
/wt-plan 3 team            # 使用团队策略
/wt-plan 2 frontend-backend # 简单前后端分离
```

**分配策略详解**：

#### 1. `level` - 层级策略（默认）

按依赖层级分配，确保依赖关系清晰。

```
Level 0 (thread-infra)
    ↓  基础设施先行
Level 1 (thread-api)
    ↓  核心功能次之
Level 2 (thread-ux)
    ↓  前端依赖后端
Level 3 (thread-advanced)
    ↓  高级功能最后
```

**分配规则**:
- **Level 0**: 基础设施、测试框架、CI/CD 配置、代码规范
- **Level 1**: 核心 API、数据模型、业务逻辑
- **Level 2**: 前端 UI、组件、样式、状态管理
- **Level 3**: 高级特性、AI 集成、性能优化

**适用场景**:
- 有明确前后端分离的项目
- 需要统一基础设施的项目
- 依赖链清晰的中大型项目

---

#### 2. `module` - 模块策略

按服务/模块边界分配，适合微服务架构。

**识别方式**:
- 扫描 `services/`、`modules/`、`apps/` 目录
- 识别 `package.json`、`requirements.txt`、`go.mod`
- 按功能内聚性分组

**分配示例**（电商系统）:
```
thread-user        # 用户模块：注册、登录、权限
thread-product    # 商品模块：商品列表、详情、搜索
thread-order      # 订单模块：购物车、下单、支付
thread-payment    # 支付模块：支付网关、账单
```

**合并顺序**: 按模块间依赖拓扑排序

**适用场景**:
- 微服务架构项目
- 多模块独立部署项目
- 有明确服务边界的项目

---

#### 3. `feature` - 功能策略

按功能领域分配，适合功能相对独立的项目。

**识别方式**:
- 核心功能：用户、商品、订单等核心业务
- 支撑功能：搜索、推荐、通知等
- 高级功能：AI 助手、数据分析等

**分配示例**:
```
thread-auth        # 认证授权：登录、注册、OAuth
thread-search      # 搜索功能：全文搜索、过滤、排序
thread-notification # 通知功能：邮件、短信、推送
thread-analytics   # 数据分析：报表、统计、导出
```

**合并顺序**: 核心功能优先 → 支撑功能 → 高级功能

**适用场景**:
- 功能模块相对独立的项目
- 需要并行开发多个功能的团队
- 功能迭代频繁的项目

---

#### 4. `team` - 团队策略

按团队/职责划分，适合多人协作。

**识别维度**:
- 前端团队 / 后端团队
- 平台团队 / 业务团队
- 独立团队（AI 团队、数据团队）

**分配示例**:
```
thread-frontend   # 前端团队：React/Vue、UI 组件、样式
thread-backend    # 后端团队：API、业务逻辑、数据库
thread-platform   # 平台团队：基础设施、CI/CD、监控
thread-ai        # AI 团队：AI 模型、智能推荐、内容生成
```

**合并顺序**: 平台基础设施优先 → 业务功能次之 → 高级功能最后

**适用场景**:
- 多个团队并行开发
- 有独立团队负责特定领域
- 需要明确团队职责边界的项目

---

#### 5. `frontend-backend` - 前后端分离

最简单的 2 线分离，适合中小型项目。

```
thread-backend   # 后端全部：API + 业务逻辑 + 数据库
thread-frontend  # 前端全部：UI + 组件 + 状态管理
```

**特点**:
- 只有 2 个 worktree，管理简单
- 合并顺序固定：backend → frontend
- 适合 2-4 人小团队
- 前后端接口契约清晰

**适用场景**:
- 前后端完全分离的项目
- 小型团队（2-4 人）
- 快速迭代的敏捷项目

---

**策略选择指南**:

| 项目特点 | 推荐策略 |
|----------|----------|
| 通用项目，有明确层级 | `level` |
| 微服务架构，多个独立服务 | `module` |
| 功能相对独立，并行开发 | `feature` |
| 多团队协作，需明确边界 | `team` |
| 中小型，前后端分离 | `frontend-backend` |

**输出**：分析结果、推荐数量、策略、任务分配方案

---

### `/wt-status` - Worktree 状态
```
/wt-status
```
**输出**：各 worktree 的分支、提交状态、待提交修改

---

### `/wt-progress` - 进度检查
```
/wt-progress              # 自动检测当前 worktree
/wt-progress thread-ux   # 指定线程
```
**输出**：已完成任务、当前阶段、剩余工作

---

### `/wt-qa` - 质量检查
```
/wt-qa              # 自动检测当前 worktree
/wt-qa thread-api   # 指定线程
```
**输出**：代码规范检查、测试覆盖率、潜在问题

---

### `/wt-contract` - 接口协议检查
```
/wt-contract
```
**输出**：API 接口实现状态、接口契约符合度

---

### `/wt-merge-check` - 合并前验证
```
/wt-merge-check thread-ux   # 检查 thread-ux 是否可合并
```
**检查项**：依赖是否满足、接口是否完整、冲突是否存在

---

### `/wt-report` - 完整进度报告
```
/wt-report
```
**输出**：所有线程的详细进度、阻塞项、风险评估

---

### `/wt-dev` - 启动/继续开发
```
/wt-dev                  # 自动检测当前线程
/wt-dev thread-advanced  # 指定线程开始开发
```
**输出**：开发状态、待办任务、下一步建议

---

### `/wt-commit` - 提交更改
```
/wt-commit
```
**输出**：待提交文件列表、提交信息建议、执行提交

---

### `/wt-blockers` - 查看阻塞清单
```
/wt-blockers
```
**输出**：所有阻塞项、阻塞者、建议处理方式

---

### 自动检测机制

在 worktree 目录内使用时，命令自动识别当前线程：

```bash
# 在 worktree-thread-ux/ 目录中
/wt-progress    # 自动识别为 thread-ux
/wt-qa         # 对 thread-ux 进行 QA
```

### 线程命名

| 线程 | 层级 | 说明 |
|------|------|------|
| `thread-infra` | Level 0 | 基础设施、测试框架 |
| `thread-api` | Level 1 | 后端 API |
| `thread-ux` | Level 2 | 前端 UX |
| `thread-advanced` | Level 3 | 高级功能 |

### 合并顺序

```
thread-infra → thread-api → thread-ux → thread-advanced
```

必须按此顺序合并以避免依赖冲突。

## Worktree 命名规范

```
worktree-thread-{name}
├── worktree-thread-ux    # 前端 UX 开发
├── worktree-thread-api    # 后端 API
├── worktree-thread-advanced    # 高级功能
└── worktree-thread-infra    # 基础设施
```

## 配置

### 创建 Worktrees

```bash
# 使用 /wt-plan 命令
/wt-plan              # 自动分析并推荐
/wt-plan 4            # 指定 4 个 worktrees
```

### 手动设置

```bash
# 创建功能分支
git checkout -b feature/thread-infra
git checkout -b feature/thread-api
git checkout -b feature/thread-ux
git checkout -b feature/thread-advanced

# 创建 worktrees
git worktree add worktree-thread-infra feature/thread-infra
git worktree add worktree-thread-api feature/thread-api
git worktree add worktree-thread-ux feature/thread-ux
git worktree add worktree-thread-advanced feature/thread-advanced
```

## 多窗口开发

使用 4 个 Claude Code 窗口进行并行开发：

1. Claude Code 窗口 1 → `worktree-thread-infra/`
2. Claude Code 窗口 2 → `worktree-thread-api/`
3. Claude Code 窗口 3 → `worktree-thread-ux/`
4. Claude Code 窗口 4 → `worktree-thread-advanced/`

每个窗口自动检测其所在 worktree。

## 文件结构

```
claude-wt-manager/
├── .claude/
│   └── commands/
│       ├── wt-plan.md
│       ├── wt-status.md
│       ├── wt-progress.md
│       ├── wt-qa.md
│       ├── wt-batch-qa.md
│       ├── wt-contract.md
│       ├── wt-merge-check.md
│       ├── wt-report.md
│       ├── wt-dev.md
│       ├── wt-commit.md
│       └── wt-blockers.md
├── scripts/
│   ├── wt-detect.sh
│   ├── wt-plan.sh
│   ├── wt-status.sh
│   ├── wt-progress.sh
│   ├── wt-qa.sh
│   ├── wt-contract.sh
│   ├── wt-merge-check.sh
│   ├── wt-report.sh
│   └── wt-batch-qa.sh
├── CLAUDE.md              # 项目级指南
├── WORKTREE-QUICKSTART.md  # 快速参考
├── INSTALL.md             # 安装指南
├── INSTALL-CN.md          # 中文安装指南
├── LICENSE                # MIT 许可证
├── plugin.json            # 扩展清单
└── README.md
```

## 示例

### 日常工作流

```bash
# 早晨：检查所有进度
/wt-report

# 开发
/wt-dev thread-ux    # 继续 UX 工作
/wt-qa              # 快速质量检查

# 提交前
/wt-commit

# 合并前
/wt-merge-check thread-ux
```

### 创建新 Worktree

```bash
# 分析项目
/wt-plan

# 按推荐创建 worktrees
git worktree add worktree-thread-x feature/thread-x
```

## 许可证

MIT

---

**[English](./README.md) | [安装指南](./INSTALL-CN.md) | [快速参考](./WORKTREE-QUICKSTART.md) | [CLAUDE](./CLAUDE.md)**
