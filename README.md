# Claude WT Manager

Claude Code slash commands for managing multiple Git worktrees in parallel AI-assisted development.

**[中文](./README-CN.md) | [安装指南](./INSTALL.md) | [快速参考](./WORKTREE-QUICKSTART.md) | [CLAUDE](./CLAUDE.md)**

## Features

- **Auto-detection**: Automatically detects current worktree from directory path
- **Multi-thread coordination**: Manages parallel development across 4 threads
- **Quality gates**: Built-in QA, contract checking, and merge validation
- **Progress tracking**: Visual progress reports for all worktrees
- **Dependency management**: Enforces correct merge order (infra → api → ux → advanced)

## Architecture

```
Thread-infra (Level 0: Infrastructure)
    │
    ├──▶ Thread-api (Level 1: Backend API)
    │         │
    │         └──▶ Thread-ux (Level 2: UX)
    │                   │
    │                   └──▶ Thread-advanced (Level 3: Advanced)
    │
    └──────────────────────▶ Thread-advanced (parallel track)
```

**Note**: thread-advanced can start after thread-infra (uses shared test framework),
but officially merges last after all other threads complete.

## Installation

### Option 1: Copy Commands (Any Project)

Copy the `.claude` folder and `scripts` folder to your project root:

```bash
# In your project
cp -r .claude/ your-project/
cp -r scripts/ your-project/
```

### Option 2: VSCode Extension (Recommended)

1. Copy `claude-wt-manager/` folder to `.claude/extensions/`
2. Restart Claude Code

### Option 3: Global Installation

```bash
# Clone to global location
git clone https://github.com/zhugeyuanEr/claude-wt-manager.git ~/.claude/extensions/claude-wt-manager
```

## Usage

### Automatic Worktree Detection

When working inside a worktree directory, commands automatically use the current worktree name:

```bash
cd your-project/worktree-thread-ux
/wt-progress    # Detects "thread-ux" automatically
/wt-qa          # Runs QA for thread-ux
```

### Manual Worktree Specification

```bash
/wt-progress thread-api    # Check specific thread
/wt-qa thread-advanced          # QA for specific thread
/wt-merge-check thread-ux  # Pre-merge check
```

### Available Commands

| Command | Description | Auto-detect |
|---------|-------------|-------------|
| `/wt-plan` | Analyze project, generate worktree plan | No |
| `/wt-status` | Show all worktree status | No |
| `/wt-progress` | Check progress | Yes |
| `/wt-qa` | Quality inspection | Yes |
| `/wt-batch-qa` | Batch quality inspection | No |
| `/wt-contract` | Interface contract check | No |
| `/wt-merge-check` | Pre-merge validation | Yes |
| `/wt-report` | Full progress report | No |
| `/wt-dev` | Start/continue development | Yes |
| `/wt-commit` | Commit current changes | Yes |
| `/wt-blockers` | View blocker list | Yes |

## Command Reference

### `/wt-plan` - Project Analysis & Planning

```
/wt-plan                      # Auto-analyze, recommend count and strategy
/wt-plan 3                   # Specify 3 worktrees
/wt-plan 3 level             # Use level-based strategy
/wt-plan 3 module            # Use module-based strategy
/wt-plan 3 feature           # Use feature-based strategy
/wt-plan 3 team              # Use team-based strategy
/wt-plan 2 frontend-backend  # Simple 2-line frontend-backend split
```

**Allocation Strategies (Detailed)**:

#### 1. `level` - Level Strategy (Default)

Allocate by dependency levels, ensuring clear dependency relationships.

```
Level 0 (thread-infra)
    ↓  Infrastructure first
Level 1 (thread-api)
    ↓  Core functions next
Level 2 (thread-ux)
    ↓  Frontend depends on backend
Level 3 (thread-advanced)
    ↓  Advanced features last
```

**Allocation Rules**:
- **Level 0**: Infrastructure, test framework, CI/CD, code standards
- **Level 1**: Core API, data models, business logic
- **Level 2**: Frontend UI, components, styles, state management
- **Level 3**: Advanced features, AI integration, performance optimization

**Best For**: Projects with clear frontend/backend separation, needing unified infrastructure

---

#### 2. `module` - Module Strategy

Allocate by service/module boundaries, suitable for microservices architecture.

**Identification**:
- Scan `services/`, `modules/`, `apps/` directories
- Identify `package.json`, `requirements.txt`, `go.mod`
- Group by functional cohesion

**Example** (E-commerce):
```
thread-user        # User: registration, login, permissions
thread-product    # Product: catalog, details, search
thread-order      # Order: cart, checkout, orders
thread-payment    # Payment: gateway, billing
```

**Merge Order**: Topological sort by module dependencies

**Best For**: Microservices, multi-module deployments, clear service boundaries

---

#### 3. `feature` - Feature Strategy

Allocate by feature domains, suitable for projects with independent features.

**Identification**:
- Core features: User, Product, Order (core business)
- Supporting features: Search, Recommendations, Notifications
- Advanced features: AI assistant, Analytics

**Example**:
```
thread-auth        # Auth: login, register, OAuth
thread-search      # Search: full-text, filters, sorting
thread-notification # Notifications: email, SMS, push
thread-analytics   # Analytics: reports, stats, export
```

**Merge Order**: Core → Supporting → Advanced

**Best For**: Independent feature modules, parallel development, frequent feature iterations

---

#### 4. `team` - Team Strategy

Allocate by teams/responsibilities, suitable for multi-team collaboration.

**Dimensions**:
- Frontend team / Backend team
- Platform team / Business team
- Independent teams (AI team, Data team)

**Example**:
```
thread-frontend   # Frontend team: React/Vue, UI components, styles
thread-backend    # Backend team: API, business logic, database
thread-platform   # Platform team: infrastructure, CI/CD, monitoring
thread-ai        # AI team: models, recommendations, content generation
```

**Merge Order**: Platform infrastructure → Business features → Advanced features

**Best For**: Multiple teams, clear team boundaries, distinct team responsibilities

---

#### 5. `frontend-backend` - Frontend-Backend Split

Simplest 2-line split, suitable for small-medium projects.

```
thread-backend   # Backend: API + business logic + database
thread-frontend  # Frontend: UI + components + state management
```

**Characteristics**:
- Only 2 worktrees, simple management
- Fixed merge order: backend → frontend
- Best for 2-4 person teams
- Clear frontend-backend contract

**Best For**: Fully separated frontend/backend, small teams, agile projects

---

**Strategy Selection Guide**:

| Project Type | Recommended Strategy |
|--------------|---------------------|
| General with clear levels | `level` |
| Microservices | `module` |
| Independent features | `feature` |
| Multi-team collaboration | `team` |
| Small frontend-backend | `frontend-backend` |

**Output**: Analysis results, recommended count, strategy, task allocation plan

---

### `/wt-status` - Worktree Status
```
/wt-status
```
**Output**: Each worktree's branch, commit status, pending changes

---

### `/wt-progress` - Progress Check
```
/wt-progress              # Auto-detect current worktree
/wt-progress thread-ux   # Specify thread
```
**Output**: Completed tasks, current phase, remaining work

---

### `/wt-qa` - Quality Inspection
```
/wt-qa              # Auto-detect current worktree
/wt-qa thread-api   # Specify thread
```
**Output**: Code style check, test coverage, potential issues

---

### `/wt-contract` - Interface Contract Check
```
/wt-contract
```
**Output**: API implementation status, contract compliance

---

### `/wt-merge-check` - Pre-merge Validation
```
/wt-merge-check thread-ux   # Check if thread-ux is ready to merge
```
**Checks**: Dependencies satisfied, interfaces complete, conflicts resolved

---

### `/wt-report` - Full Progress Report
```
/wt-report
```
**Output**: All threads' detailed progress, blockers, risk assessment

---

### `/wt-dev` - Start/Continue Development
```
/wt-dev                  # Auto-detect current thread
/wt-dev thread-advanced  # Specify thread
```
**Output**: Development status, todo items, next steps

---

### `/wt-commit` - Commit Changes
```
/wt-commit
```
**Output**: Files to commit, commit message suggestions, execute commit

---

### `/wt-blockers` - View Blocker List
```
/wt-blockers
```
**Output**: All blockers, blocked by, suggested resolution

---

### Auto-detection Mechanism

When using commands inside a worktree directory, they automatically identify the current thread:

```bash
# Inside worktree-thread-ux/
/wt-progress    # Auto-identifies as thread-ux
/wt-qa         # Runs QA for thread-ux
```

### Thread Naming

| Thread | Level | Description |
|--------|-------|-------------|
| `thread-infra` | Level 0 | Infrastructure, test framework |
| `thread-api` | Level 1 | Backend API |
| `thread-ux` | Level 2 | Frontend UX |
| `thread-advanced` | Level 3 | Advanced features |

### Merge Order

```
thread-infra → thread-api → thread-ux → thread-advanced
```

Always merge in this order to avoid dependency conflicts.

## Worktree Naming Convention

```
worktree-thread-{name}
├── worktree-thread-ux    # UX Development
├── worktree-thread-api    # Backend API
├── worktree-thread-advanced    # Advanced Features
└── worktree-thread-infra    # Infrastructure
```

## PLAN File Naming Convention

Each worktree requires a PLAN file for progress tracking:

| Thread | PLAN File |
|--------|-----------|
| thread-infra | `THREAD-INFRA-PLAN.md` |
| thread-api | `THREAD-API-PLAN.md` |
| thread-ux | `THREAD-UX-PLAN.md` |
| thread-advanced | `THREAD-ADVANCED-PLAN.md` |

**Format**: `THREAD-{THREAD-NAME}-PLAN.md` (all uppercase)

## Configuration

### Creating Worktrees

```bash
# Using /wt-plan command
/wt-plan              # Auto-analyze and recommend
/wt-plan 4            # Specify 4 worktrees
```

### Manual Setup

```bash
# Create feature branches
git checkout -b feature/thread-infra
git checkout -b feature/thread-api
git checkout -b feature/thread-ux
git checkout -b feature/thread-advanced

# Create worktrees
git worktree add worktree-thread-infra feature/thread-infra
git worktree add worktree-thread-api feature/thread-api
git worktree add worktree-thread-ux feature/thread-ux
git worktree add worktree-thread-advanced feature/thread-advanced
```

## Multi-Window Development

For parallel development with 4 Claude Code windows:

1. Open Claude Code Window 1 → `worktree-thread-infra/`
2. Open Claude Code Window 2 → `worktree-thread-api/`
3. Open Claude Code Window 3 → `worktree-thread-ux/`
4. Open Claude Code Window 4 → `worktree-thread-advanced/`

Each window automatically detects its worktree.

## File Structure

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
├── CLAUDE.md              # Per-project guide
├── WORKTREE-QUICKSTART.md  # Quick reference
├── INSTALL.md             # Installation guide
├── INSTALL-CN.md          # 中文安装指南
├── LICENSE                # MIT License
├── plugin.json            # Extension manifest
└── README.md
```

## Examples

### Daily Workflow

```bash
# Morning: Check all progress
/wt-report

# Development
/wt-dev thread-ux    # Continue UX work
/wt-qa              # Quick quality check

# Before commit
/wt-commit

# Before merge
/wt-merge-check thread-ux
```

### Creating New Worktree Setup

```bash
# Analyze project
/wt-plan

# Follow recommendations to create worktrees
git worktree add worktree-thread-x feature/thread-x
```

## License

MIT

---

**[中文](./README-CN.md) | [安装指南](./INSTALL.md) | [快速参考](./WORKTREE-QUICKSTART.md) | [CLAUDE](./CLAUDE.md)**
