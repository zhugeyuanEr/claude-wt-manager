# 安装指南

**[English](./INSTALL.md) | [中文](./INSTALL-CN.md) | [README](./README.md) | [快速参考](./WORKTREE-QUICKSTART.md)**

## 全局安装（推荐）

全局安装后，在任意 Git 项目中都可以使用 WT Manager 命令。

```bash
# 在 claude-wt-manager 目录中执行
cd claude-wt-manager
bash scripts/wt-install.sh
```

卸载：
```bash
bash scripts/wt-uninstall.sh
```

---

## 在新机器上配置

```bash
git clone https://github.com/zhugeyuanEr/claude-wt-manager.git
cd claude-wt-manager
```

### 步骤 2：安装 Claude WT Manager

```bash
# 复制命令和脚本到项目
cp -r claude-wt-manager/.claude/ .
cp -r claude-wt-manager/scripts/ .
```

### 步骤 3：创建 Worktrees

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

### 步骤 4：分发命令到各 Worktree

```bash
# 复制命令到每个 worktree
for wt in worktree-thread-ux worktree-thread-api worktree-thread-advanced worktree-thread-infra; do
    mkdir -p "$wt/.claude/commands"
    cp -r .claude/commands/ "$wt/.claude/"
    cp -r scripts/ "$wt/"
done
```

### 步骤 5：在各 Worktree 中打开 Claude Code

1. 打开 VSCode + Claude Code 扩展
2. 文件 → 打开文件夹 → 选择 `worktree-thread-infra/`
3. 为其他 worktree 重复上述步骤


## 验证安装

```bash
# 安装后测试命令
/wt-status          # 应显示所有 worktrees
/wt-plan             # 应分析项目并给出建议
```

---

**[English](./INSTALL.md) | [中文](./INSTALL-CN.md) | [README](./README.md) | [快速参考](./WORKTREE-QUICKSTART.md)**
