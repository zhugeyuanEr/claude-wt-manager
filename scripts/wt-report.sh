#!/bin/bash
# wt-report.sh - 生成完整进度报告

WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"

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

progress_bar() {
    local pct=$1
    local width=20
    local filled=$((width * pct / 100))
    local empty=$((width - filled))
    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "] %3d%%" "$pct"
}

git worktree list | grep 'worktree-thread-' | while IFS= read -r line; do
    if [[ "$line" =~ ^([^\ ]+)\ \+\[([^\]]+)\]$ ]]; then
        WT_PATH="${BASH_REMATCH[1]}"
        WT_BRANCH="${BASH_REMATCH[2]}"

        if [[ "$WT_PATH" =~ worktree-thread-([a-zA-Z0-9_-]+)$ ]]; then
            WT_NAME="${BASH_REMATCH[1]}"
            PLAN_FILE="$WT_PATH/THREAD-${WT_NAME^^}-PLAN.md"

            PROGRESS=$(parse_progress "$PLAN_FILE")
            progress_bar "$PROGRESS"
            echo " $WT_NAME ($WT_BRANCH)"

            # 读取检查点
            if [[ -f "$PLAN_FILE" ]]; then
                # 查找 Checkpoint 部分
                sed -n '/## 进度检查点/,/^##/p' "$PLAN_FILE" 2>/dev/null | grep "\- \[" | head -5 | sed 's/^/  /'
            fi
            echo ""
        fi
    fi
done

echo "---"
echo ""
echo "## 接口实现状态"
echo ""
grep -E "^\*\*实现方\*\*:" "$WORKTREE_ROOT/INTERFACE-CONTRACT.md" 2>/dev/null | while IFS= read -r line; do
    prev_line=$(grep -B2 "$line" "$WORKTREE_ROOT/INTERFACE-CONTRACT.md" | head -1)
    if [[ "$prev_line" =~ ^\*\*路径\*\*:\ \`([^\`]+)\` ]]; then
        API_PATH="${BASH_REMATCH[1]}"
        IMPL_BY=$(echo "$line" | sed 's/\*\*实现方\*\*://' | sed 's/(//' | sed 's/)//' | xargs)
        echo "- [ ] $API_PATH → $IMPL_BY"
    fi
done

echo ""
echo "---"
echo ""
echo "*报告自动生成*"
