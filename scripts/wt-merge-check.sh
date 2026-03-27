#!/bin/bash
# wt-merge-check.sh - 合并前检查

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

TARGET="${1:-}"
[[ -z "$TARGET" ]] && TARGET="$(wt_detect)"

if [[ -z "$TARGET" ]]; then
    echo "错误: 请指定 worktree 名称"
    exit 1
fi

WT_PATH="$(wt_path "$TARGET")"

if [[ ! -d "$WT_PATH" ]]; then
    echo "错误: worktree-thread-$TARGET 不存在"
    exit 1
fi

wt_header "合并前检查: $TARGET"
cd "$WT_PATH"

# 1. 与 main/master 同步检查
echo ">>> 同步状态检查..."
git fetch origin 2>/dev/null

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
[[ -z "$STATUS" ]] && echo "  ✓ 工作区干净" || echo "  ⚠ 有未提交的更改"

# 4. 分支信息
echo ""
echo ">>> 分支信息..."
echo "  当前分支: $(git branch --show-current)"
echo "  提交历史: $(git rev-list --count HEAD) commits"
echo "  最新提交: $(git log -1 --oneline 2>/dev/null | head -c 60)..."

wt_footer
cd "$WT_ROOT" >/dev/null
