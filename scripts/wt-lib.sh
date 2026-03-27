#!/bin/bash
# wt-lib.sh - WT Manager 共享库
# 使用方式: source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

# ============ 全局变量 ============
WT_ROOT="${WT_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null)}"
WT_CURRENT="${WT_CURRENT:-$(pwd)}"
WT_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ============ 工具函数 ============

# 打印分隔线
wt_divider() {
    echo "==============================================="
}

# 打印标题
wt_header() {
    echo ""
    wt_divider
    echo "       $1"
    wt_divider
    echo ""
}

# 打印脚注
wt_footer() {
    echo ""
    wt_divider
}

# 自动检测当前 worktree 名称
wt_detect() {
    if [[ "$WT_CURRENT" =~ /worktree-([a-zA-Z0-9_-]+) ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    return 1
}

# 获取 worktree 路径
wt_path() {
    local name="$1"
    echo "$WT_ROOT/worktree-thread-$name"
}

# 验证 worktree 是否存在
wt_validate() {
    local name="$1"
    [[ -d "$(wt_path "$name")" ]]
}

# 解析 plan 文件进度百分比
wt_parse_progress() {
    local plan="$1"
    [[ ! -f "$plan" ]] && echo "0" && return

    local total=$(grep -c "\[ \]\|\[x\]" "$plan" 2>/dev/null || echo "0")
    local done=$(grep -c "\[x\]" "$plan" 2>/dev/null || echo "0")

    [[ "$total" -eq 0 ]] && echo "0" && return
    echo $((done * 100 / total))
}

# 打印进度条
wt_progress_bar() {
    local pct="${1:-0}"
    local width=20
    local filled=$((width * pct / 100))
    local empty=$((width - filled))

    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "] %3d%%" "$pct"
}

# 获取所有 worktree 线程列表
wt_list_threads() {
    git worktree list | grep -o 'worktree-thread-[a-z]*' | sed 's/worktree-//' 2>/dev/null
}

# 解析 worktree 列表行
wt_parse_worktree_line() {
    local line="$1"
    if [[ "$line" =~ ^([^\ ]+)\ \+\[([^\]]+)\]$ ]]; then
        local path="${BASH_REMATCH[1]}"
        local branch="${BASH_REMATCH[2]}"
        if [[ "$path" =~ worktree-thread-([a-zA-Z0-9_-]+)$ ]]; then
            local name="${BASH_REMATCH[1]}"
            echo "$name|$path|$branch"
            return 0
        fi
    fi
    return 1
}
