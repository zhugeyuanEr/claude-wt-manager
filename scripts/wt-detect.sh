#!/bin/bash
# wt-detect.sh - 自动检测当前 worktree

WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
CURRENT_DIR="$(pwd)"

# 尝试从路径中提取 worktree 名称
detect_worktree() {
    local path="$1"

    # 匹配 worktree-{name} 格式
    if [[ "$path" =~ /worktree-([a-zA-Z0-9_-]+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi

    # 匹配 worktree/{name} 格式
    if [[ "$path" =~ /worktree/([a-zA-Z0-9_-]+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi

    # 匹配 worktree-{name}/ 子目录
    if [[ "$path" =~ /worktree-([a-zA-Z0-9_-]+)/ ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi

    return 1
}

# 检测
WORKTREE_NAME=$(detect_worktree "$CURRENT_DIR")

if [[ -n "$WORKTREE_NAME" ]]; then
    echo "$WORKTREE_NAME"
    exit 0
else
    echo ""
    exit 1
fi
