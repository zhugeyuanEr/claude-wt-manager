#!/bin/bash
# wt-progress.sh - 检查各线程进度

WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"

echo "==============================================="
echo "       多线开发进度报告"
echo "==============================================="
echo ""

# 进度条函数
progress_bar() {
    local pct=$1
    local width=30
    local filled=$((width * pct / 100))
    local empty=$((width - filled))

    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "] %3d%%" "$pct"
}

# 解析 checkpoint 完成度
parse_progress() {
    local plan_file="$1"
    if [[ ! -f "$plan_file" ]]; then
        echo "0"
        return
    fi

    local total=$(grep -c "\[ \]\|\[x\]" "$plan_file" 2>/dev/null || echo "0")
    local done=$(grep -c "\[x\]" "$plan_file" 2>/dev/null || echo "0")

    if [[ "$total" -eq 0 ]]; then
        echo "0"
        return
    fi

    echo $((done * 100 / total))
}

# 获取线程列表
THREADS=$(git worktree list | grep -o 'worktree-thread-[a-z]*' | sed 's/worktree-//' 2>/dev/null)

if [[ -z "$THREADS" ]]; then
    echo "未找到任何 worktree-thread-*"
    exit 0
fi

# 显示各线程进度
for thread in $THREADS; do
    WT_PATH="$WORKTREE_ROOT/worktree-thread-$thread"

    if [[ -d "$WT_PATH" ]]; then
        PLAN_FILE="$WT_PATH/THREAD-${thread^^}-PLAN.md"

        if [[ -f "$PLAN_FILE" ]]; then
            # 提取线程名称
            THREAD_NAME=$(grep "^> 分支:" "$PLAN_FILE" | head -1 | sed 's/> 分支://' | xargs)

            # 计算进度
            PROGRESS=$(parse_progress "$PLAN_FILE")
            progress_bar "$PROGRESS"
            echo "  $thread ($THREAD_NAME)"

            # 显示检查点状态
            echo "    检查点:"
            grep -E "^\[.\]" "$PLAN_FILE" 2>/dev/null | head -4 | sed 's/^/      /'
        else
            echo "⚠ $thread - 无计划文件"
        fi
    fi
done

echo ""
echo "==============================================="
echo "更新于: $(date '+%Y-%m-%d %H:%M')"
