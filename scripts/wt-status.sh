#!/bin/bash
# wt-status.sh - 显示 worktree 状态

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

CURRENT_WT="$(wt_detect)"

wt_header "Worktree 状态概览"

git worktree list | while IFS= read -r line; do
    RESULT=$(wt_parse_worktree_line "$line")
    if [[ -n "$RESULT" ]]; then
        IFS='|' read -r WT_NAME WT_PATH WT_BRANCH <<< "$RESULT"

        if [[ -d "$WT_PATH/.git" ]] || git -C "$WT_PATH" rev-parse --git-dir >/dev/null 2>&1; then
            (cd "$WT_PATH" 2>/dev/null && git status --porcelain | grep -q .) && WT_STATUS="✗ 脏" || WT_STATUS="✓ 干净"
        else
            WT_STATUS="? unknown"
        fi

        MARKER=""
        [[ "$WT_NAME" == "$CURRENT_WT" ]] && MARKER=" ← 当前"

        printf "%-20s %-25s %s%s\n" "$WT_NAME" "$WT_BRANCH" "$WT_STATUS" "$MARKER"
    else
        echo "$line"
    fi
done

echo ""
echo "当前目录: $WT_CURRENT"
echo "当前 Worktree: ${CURRENT_WT:-无}"
wt_footer
