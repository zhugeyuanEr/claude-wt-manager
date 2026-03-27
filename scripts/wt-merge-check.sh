#!/bin/bash
# wt-merge-check.sh - 合并前检查

TARGET="${1:-}"
WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
CURRENT_DIR="$(pwd)"

# 自动检测
if [[ -z "$TARGET" ]]; then
    if [[ "$CURRENT_DIR" =~ /worktree-([a-zA-Z0-9_-]+) ]]; then
        TARGET="${BASH_REMATCH[1]}"
    else
        echo "错误: 请指定 worktree 名称"
        exit 1
    fi
fi

WT_PATH="$WORKTREE_ROOT/worktree-thread-$TARGET"
WT_BRANCH="feature/thread-$TARGET"

if [[ ! -d "$WT_PATH" ]]; then
    echo "错误: worktree-thread-$TARGET 不存在"
    exit 1
fi

echo "==============================================="
echo "       合并前检查: $TARGET"
echo "==============================================="
echo ""

cd "$WT_PATH"

# 1. 与 main/master 同步检查
echo ">>> 同步状态检查..."
git fetch origin 2>/dev/null

# 检测默认分支名
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
[[ -z "$DEFAULT_BRANCH" ]] && DEFAULT_BRANCH="main"

MASTER_HASH=$(git rev-parse "origin/$DEFAULT_BRANCH" 2>/dev/null)
BRANCH_HASH=$(git rev-parse HEAD 2>/dev/null)

if [[ "$MASTER_HASH" == "$BRANCH_HASH" ]]; then
    echo "  ✓ 已与远程 $DEFAULT_BRANCH 同步"
else
    echo "  ⚠ 落后于远程 $DEFAULT_BRANCH"
    BEHIND=$(git rev-list --count HEAD.."origin/$DEFAULT_BRANCH" 2>/dev/null || echo "?")
    echo "    落后 $BEHIND 个 commit"
fi

# 2. 冲突检查
echo ""
echo ">>> 冲突检查..."
MERGE_CONFLICT=$(git ls-files -u | wc -l)
if [[ "$MERGE_CONFLICT" -eq 0 ]]; then
    echo "  ✓ 无冲突"
else
    echo "  ⚠ 存在冲突文件"
    git diff --name-only --diff-filter=U 2>/dev/null | sed 's/^/    /'
fi

# 3. 工作区状态
echo ""
echo ">>> 工作区状态..."
STATUS=$(git status --porcelain)
if [[ -z "$STATUS" ]]; then
    echo "  ✓ 工作区干净"
else
    echo "  ⚠ 有未提交的更改"
fi

# 4. 分支信息
echo ""
echo ">>> 分支信息..."
echo "  当前分支: $(git branch --show-current)"
echo "  提交历史: $(git rev-list --count HEAD) commits"
echo "  最新提交: $(git log -1 --oneline 2>/dev/null | head -c 60)..."

echo ""
echo "==============================================="
cd "$WORKTREE_ROOT" >/dev/null
