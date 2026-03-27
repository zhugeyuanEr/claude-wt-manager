#!/bin/bash
# wt-list.sh - 显示 worktree 列表

WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
CURRENT_DIR="$(pwd)"

echo "==============================================="
echo "       Worktree 列表"
echo "==============================================="
echo ""

git worktree list | while IFS= read -r line; do
    if [[ "$line" =~ ^([^\ ]+)\ \+\[([^\]]+)\]$ ]]; then
        WT_PATH="${BASH_REMATCH[1]}"
        WT_BRANCH="${BASH_REMATCH[2]}"

        # 提取 worktree 名称
        if [[ "$WT_PATH" =~ worktree-([a-zA-Z0-9_-]+)$ ]]; then
            WT_NAME="${BASH_REMATCH[1]}"
        else
            WT_NAME="main"
        fi

        # 标记当前 worktree
        if [[ "$CURRENT_DIR" == "$WT_PATH" || "$CURRENT_DIR" == "$WT_PATH/"* ]]; then
            echo "  * $WT_NAME  [$WT_BRANCH]  ← 当前"
        else
            echo "    $WT_NAME  [$WT_BRANCH]"
        fi
    elif [[ -n "$line" ]]; then
        echo "  $line"
    fi
done

echo ""
echo "==============================================="
