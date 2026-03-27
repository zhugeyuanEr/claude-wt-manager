# Installation Guide

**[English](./INSTALL.md) | [中文](./INSTALL-CN.md) | [README](./README.md) | [Quick Reference](./WORKTREE-QUICKSTART.md)**

## For New Machine Setup

### Step 1: Clone Your Project

```bash
git clone https://github.com/zhugeyuanEr/claude-wt-manager.git
cd claude-wt-manager
```

### Step 2: Install Claude WT Manager

```bash
# Copy commands and scripts to your project
cp -r claude-wt-manager/.claude/ .
cp -r claude-wt-manager/scripts/ .
```

### Step 3: Setup Worktrees

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

### Step 4: Distribute Commands to Worktrees

```bash
# Copy commands to each worktree
for wt in worktree-thread-ux worktree-thread-api worktree-thread-advanced worktree-thread-infra; do
    mkdir -p "$wt/.claude/commands"
    cp -r .claude/commands/ "$wt/.claude/"
    cp -r scripts/ "$wt/"
done
```

### Step 5: Open Claude Code in Each Worktree

1. Open VSCode with Claude Code extension
2. File → Open Folder → select `worktree-thread-infra/`
3. Repeat for other worktrees in separate windows

## Verification

```bash
# After setup, test commands
/wt-status          # Should show all worktrees
/wt-plan             # Should analyze project
```

---

**[English](./INSTALL.md) | [中文](./INSTALL-CN.md) | [README](./README.md) | [Quick Reference](./WORKTREE-QUICKSTART.md)**
