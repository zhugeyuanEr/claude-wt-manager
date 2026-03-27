#!/bin/bash
# wt-report.sh - 生成完整进度报告

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

echo "# 多线开发进度报告"
echo ""
echo "生成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo "---"
echo ""

# Worktree 列表
echo "## Worktree 状态"
echo ""
echo '```'
git worktree list
echo '```'
echo ""

# 各线程进度
echo "## 进度详情"
echo ""

git worktree list | grep 'worktree-thread-' | while IFS= read -r line; do
    RESULT=$(wt_parse_worktree_line "$line")
    [[ -z "$RESULT" ]] && continue

    IFS='|' read -r WT_NAME WT_PATH WT_BRANCH <<< "$RESULT"
    PLAN_FILE="$WT_PATH/THREAD-${WT_NAME^^}-PLAN.md"

    PROGRESS=$(wt_parse_progress "$PLAN_FILE")
    wt_progress_bar "$PROGRESS"
    echo " $WT_NAME ($WT_BRANCH)"

    if [[ -f "$PLAN_FILE" ]]; then
        grep -E "^\[.\]|^- \[.\]|^\- \[[ x]\]" "$PLAN_FILE" 2>/dev/null | head -5 | sed 's/^/  /'
    fi
    echo ""
done

echo "---"
echo ""

echo "## 接口实现状态"
echo ""

if [[ -f "$WT_ROOT/INTERFACE-CONTRACT.md" ]]; then
    grep -E "^\*\*实现方\*\*:|^Implementation:|^Implemented By:" "$WT_ROOT/INTERFACE-CONTRACT.md" 2>/dev/null | while IFS= read -r line; do
        prev_line=$(grep -B2 "$line" "$WT_ROOT/INTERFACE-CONTRACT.md" | head -1)
        if [[ "$prev_line" =~ ^\*\*路径\*\*:\ \`([^\`]+)\` ]]; then
            API_PATH="${BASH_REMATCH[1]}"
        elif [[ "$prev_line" =~ ^Path:\ \`([^\`]+)\` ]]; then
            API_PATH="${BASH_REMATCH[1]}"
        elif [[ "$prev_line" =~ ^\*\*路径\*\*:\ (.+) ]]; then
            API_PATH="${BASH_REMATCH[1]}"
        else
            API_PATH="未知"
        fi
        IMPL_BY=$(echo "$line" | sed -E 's/^\*\*实现方\*\*:|^Implementation:|^Implemented By://' | sed 's/(//' | sed 's/)//' | xargs)
        echo "- [ ] $API_PATH → $IMPL_BY"
    done
else
    echo "(无 INTERFACE-CONTRACT.md)"
fi

echo ""
echo "---"
echo ""
echo "*报告自动生成*"
