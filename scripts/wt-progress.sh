#!/bin/bash
# wt-progress.sh - 检查各线程进度

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

echo ""
wt_divider
echo "       多线开发进度报告"
wt_divider
echo ""

THREADS=$(wt_list_threads)

if [[ -z "$THREADS" ]]; then
    echo "未找到任何 worktree-thread-*"
    exit 0
fi

for thread in $THREADS; do
    WT_PATH="$(wt_path "$thread")"

    if [[ -d "$WT_PATH" ]]; then
        PLAN_FILE="$WT_PATH/THREAD-${thread^^}-PLAN.md"

        if [[ -f "$PLAN_FILE" ]]; then
            THREAD_NAME=$(grep -E "^##?\s*线程|^\*\*线程\*\*|^> 分支:" "$PLAN_FILE" 2>/dev/null | head -1 | sed -E 's/^.*://' | xargs)
            [[ -z "$THREAD_NAME" ]] && THREAD_NAME="$thread"

            PROGRESS=$(wt_parse_progress "$PLAN_FILE")
            wt_progress_bar "$PROGRESS"
            echo "  $thread ($THREAD_NAME)"

            echo "    检查点:"
            grep -E "^\[.\]|^- \[.\]" "$PLAN_FILE" 2>/dev/null | head -4 | sed 's/^/      /'
        else
            echo "⚠ $thread - 无计划文件"
        fi
    fi
done

echo ""
wt_divider
echo "更新于: $(date '+%Y-%m-%d %H:%M')"
echo ""
