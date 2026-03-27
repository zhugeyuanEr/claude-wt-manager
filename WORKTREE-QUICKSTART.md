# Worktree 快速参考

**[README](./README.md) | [安装指南](./INSTALL.md) | [CLAUDE](./CLAUDE.md)**

## 常用命令

```bash
# 查看所有 worktree 状态
/wt-status

# 查看进度
/wt-progress

# 生成完整报告
/wt-report

# 质量检查
/wt-qa

# 合并前检查
/wt-merge-check thread-ux

# 提交更改
/wt-commit
```

## 自动检测

在 worktree 目录中直接使用命令，自动检测当前线程：
```bash
/wt-progress    # 自动使用当前线程
/wt-qa          # 对当前线程 QA
```

## 创建新 Worktree

```bash
/wt-plan 4      # 分析并推荐
git worktree add worktree-thread-x feature/thread-x
```

## 合并顺序

```
infra → api → ux → advanced
```

## 多窗口开发

4 个 VSCode 窗口 → 4 个 Worktree → 4 个 Claude Code 窗口

---

**[README](./README.md) | [安装指南](./INSTALL.md) | [CLAUDE](./CLAUDE.md)**
