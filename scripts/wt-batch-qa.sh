#!/bin/bash
# wt-batch-qa.sh - 批量质量检测

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

FAILED=0
TOTAL=0

wt_header "批量质量检测"

git worktree list | grep 'worktree-thread-' | while IFS= read -r line; do
    RESULT=$(wt_parse_worktree_line "$line")
    [[ -z "$RESULT" ]] && continue

    IFS='|' read -r WT_NAME WT_PATH WT_BRANCH <<< "$RESULT"
    TOTAL=$((TOTAL + 1))

    echo ">>> 检测: $WT_NAME"
    cd "$WT_PATH" >/dev/null

    if [[ -f "package.json" ]]; then
        npm run lint >/dev/null 2>&1 && echo "  ✓ Lint 通过" || { echo "  ✗ Lint 失败"; FAILED=$((FAILED + 1)); }
        npm test >/dev/null 2>&1 && echo "  ✓ 测试通过" || { echo "  ✗ 测试失败"; FAILED=$((FAILED + 1)); }
    elif [[ -f "requirements.txt" ]]; then
        pytest tests/ -q >/dev/null 2>&1 && echo "  ✓ 测试通过" || { echo "  ✗ 测试失败"; FAILED=$((FAILED + 1)); }
    fi

    echo ""
    cd "$WT_ROOT" >/dev/null
done

wt_divider
echo "结果: $((TOTAL - FAILED))/$TOTAL 通过"
[[ $FAILED -eq 0 ]] && echo "✓ 全部通过" || echo "⚠ $FAILED 个失败"
echo ""
