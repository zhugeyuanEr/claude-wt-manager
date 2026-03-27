#!/bin/bash
# wt-blockers.sh - 查看所有 worktree 的阻塞清单

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

wt_header "阻塞清单"
echo ""

THREADS=$(wt_list_threads)

if [[ -z "$THREADS" ]]; then
    echo "未找到任何 worktree-thread-*"
    wt_footer
    exit 0
fi

BLOCKER_COUNT=0

for thread in $THREADS; do
    WT_PATH="$(wt_path "$thread")"
    PLAN_FILE="$WT_PATH/THREAD-${thread^^}-PLAN.md"

    [[ ! -d "$WT_PATH" ]] && continue

    BLOCKERS=""
    BLOCKER_SECTION=""

    if [[ -f "$PLAN_FILE" ]]; then
        BLOCKERS=$(grep -n -E "(⚠|WAITING|BLOCKED|依赖|等待|阻塞)" "$PLAN_FILE" 2>/dev/null)
        BLOCKER_SECTION=$(sed -n '/^##.*阻塞/,/^##/p' "$PLAN_FILE" 2>/dev/null | grep -v "^##")
    fi

    if [[ -n "$BLOCKERS" ]] || [[ -n "$BLOCKER_SECTION" ]]; then
        echo "### $thread"
        echo ""

        if [[ -n "$BLOCKER_SECTION" ]]; then
            echo "$BLOCKER_SECTION" | sed 's/^/  /'
        elif [[ -n "$BLOCKERS" ]]; then
            echo "$BLOCKERS" | head -10 | sed 's/^/  /'
        fi

        echo ""
        BLOCKER_COUNT=$((BLOCKER_COUNT + 1))
    fi
done

if [[ $BLOCKER_COUNT -eq 0 ]]; then
    echo "✓ 当前无阻塞项"
    echo ""
    echo "所有线程开发进度正常"
else
    echo ""
    wt_divider
    echo "共发现 $BLOCKER_COUNT 个线程存在阻塞项"
fi

echo ""
wt_divider
echo "更新于: $(date '+%Y-%m-%d %H:%M')"
echo ""
