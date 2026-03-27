#!/bin/bash
# wt-list.sh - 显示 worktree 列表

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

CURRENT_WT="$(wt_detect)"

wt_header "Worktree 列表"

git worktree list | while IFS= read -r line; do
    RESULT=$(wt_parse_worktree_line "$line")
    if [[ -n "$RESULT" ]]; then
        IFS='|' read -r WT_NAME WT_PATH WT_BRANCH <<< "$RESULT"

        if [[ "$WT_PATH" == "$WT_CURRENT" || "$WT_CURRENT" == "$WT_PATH/"* ]]; then
            echo "  * $WT_NAME  [$WT_BRANCH]  ← 当前"
        else
            echo "    $WT_NAME  [$WT_BRANCH]"
        fi
    elif [[ -n "$line" ]]; then
        echo "  $line"
    fi
done

wt_footer
