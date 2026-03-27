#!/bin/bash
# wt-switch.sh - 切换到指定的 worktree

TARGET="${1:-}"
WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
CURRENT_DIR="$(pwd)"

# 列出所有可用的 worktree
list_worktrees() {
    echo "可用 Worktree:"
    echo ""
    local idx=1
    local current=""
    git worktree list | while IFS= read -r line; do
        if [[ "$line" =~ ^([^\ ]+)\ \+\[([^\]]+)\]$ ]]; then
            WT_PATH="${BASH_REMATCH[1]}"
            WT_BRANCH="${BASH_REMATCH[2]}"
            if [[ "$WT_PATH" =~ worktree-([a-zA-Z0-9_-]+)$ ]]; then
                WT_NAME="${BASH_REMATCH[1]}"
            else
                WT_NAME="main"
            fi
            if [[ "$CURRENT_DIR" == "$WT_PATH" || "$CURRENT_DIR" == "$WT_PATH/"* ]]; then
                current=" ← 当前"
            else
                current=""
            fi
            printf "  %2d. %-20s %-25s%s\n" "$idx" "$WT_NAME" "[$WT_BRANCH]" "$current"
            idx=$((idx + 1))
        fi
    done
}

# 没有参数时显示列表
if [[ -z "$TARGET" ]]; then
    echo "==============================================="
    echo "       Worktree 切换"
    echo "==============================================="
    echo ""
    list_worktrees
    echo ""
    echo "使用方式:"
    echo "  /wt-switch <thread-name>    # 例如: /wt-switch thread-api"
    echo "  /wt-switch                  # 显示列表"
    echo ""
    echo "示例:"
    echo "  /wt-switch thread-infra"
    echo "  /wt-switch thread-api"
    echo "  /wt-switch thread-ux"
    echo "==============================================="
    exit 0
fi

# 支持直接指定 thread 名称
if [[ ! "$TARGET" =~ ^worktree- ]]; then
    TARGET="worktree-$TARGET"
fi

WT_PATH="$WORKTREE_ROOT/$TARGET"

# 检查 worktree 是否存在
if [[ ! -d "$WT_PATH" ]]; then
    echo "错误: $TARGET 不存在"
    echo ""
    echo "可用 worktree:"
    git worktree list | grep -E "worktree-" | sed 's/^/  /'
    exit 1
fi

# 检查是否是当前目录
if [[ "$CURRENT_DIR" == "$WT_PATH" || "$CURRENT_DIR" == "$WT_PATH/"* ]]; then
    echo "提示: 已在 $TARGET 中"
    BRANCH=$(git branch --show-current 2>/dev/null)
    echo "当前分支: $BRANCH"
    exit 0
fi

echo "==============================================="
echo "       切换到: $TARGET"
echo "==============================================="
echo ""
echo "路径: $WT_PATH"
echo ""
echo "执行以下命令切换:"
echo ""
echo "  cd $WT_PATH"
echo ""
echo "或在 Claude Code 中直接继续工作,"
echo "系统会自动检测当前 worktree。"
echo "==============================================="
