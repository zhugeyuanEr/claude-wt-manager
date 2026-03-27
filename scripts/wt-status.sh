#!/bin/bash
# wt-status.sh - 显示 worktree 状态

WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
CURRENT_DIR="$(pwd)"
CURRENT_WT=""

# 检测当前 worktree
if [[ "$CURRENT_DIR" =~ /worktree-([a-zA-Z0-9_-]+) ]]; then
    CURRENT_WT="${BASH_REMATCH[1]}"
fi

echo "==============================================="
echo "       Worktree 状态概览"
echo "==============================================="
echo ""

# 获取 worktree 列表
git worktree list | while IFS= read -r line; do
    # 解析路径和分支
    if [[ "$line" =~ ^([^\ ]+)\ \+\[([^\]]+)\]$ ]]; then
        WT_PATH="${BASH_REMATCH[1]}"
        WT_BRANCH="${BASH_REMATCH[2]}"

        # 提取 worktree 名称
        if [[ "$WT_PATH" =~ worktree-([a-zA-Z0-9_-]+)$ ]]; then
            WT_NAME="${BASH_REMATCH[1]}"
        else
            WT_NAME="main"
        fi

        # 检查状态
        if [[ -d "$WT_PATH/.git" ]] || git -C "$WT_PATH" rev-parse --git-dir >/dev/null 2>&1; then
            cd "$WT_PATH" 2>/dev/null
            if git status --porcelain | grep -q .; then
                WT_STATUS="✗ dirty"
            else
                WT_STATUS="✓ clean"
            fi
            cd - >/dev/null
        else
            WT_STATUS="? unknown"
        fi

        # 标记当前 worktree
        MARKER=""
        if [[ "$WT_NAME" == "$CURRENT_WT" ]]; then
            MARKER=" ← 当前"
        fi

        printf "%-20s %-25s %s%s\n" "$WT_NAME" "$WT_BRANCH" "$WT_STATUS" "$MARKER"
    else
        echo "$line"
    fi
done

echo ""
echo "当前目录: $CURRENT_DIR"
echo "当前 Worktree: ${CURRENT_WT:-无}"
echo "==============================================="
