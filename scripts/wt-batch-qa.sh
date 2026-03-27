#!/bin/bash
# wt-batch-qa.sh - 批量质量检测

WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
FAILED=0
TOTAL=0

echo "==============================================="
echo "       批量质量检测"
echo "==============================================="
echo ""

# 获取所有 worktree
git worktree list | grep 'worktree-thread-' | while IFS= read -r line; do
    if [[ "$line" =~ ^([^\ ]+)\ \+\[([^\]]+)\]$ ]]; then
        WT_PATH="${BASH_REMATCH[1]}"

        if [[ "$WT_PATH" =~ worktree-thread-([a-zA-Z0-9_-]+)$ ]]; then
            WT_NAME="${BASH_REMATCH[1]}"
            TOTAL=$((TOTAL + 1))

            echo ">>> 检测: $WT_NAME"
            cd "$WT_PATH" >/dev/null

            # 运行 lint
            if [[ -f "package.json" ]]; then
                if npm run lint >/dev/null 2>&1; then
                    echo "  ✓ Lint 通过"
                else
                    echo "  ✗ Lint 失败"
                    FAILED=$((FAILED + 1))
                fi
            fi

            # 运行测试
            if [[ -f "package.json" ]]; then
                if npm test >/dev/null 2>&1; then
                    echo "  ✓ 测试通过"
                else
                    echo "  ✗ 测试失败"
                    FAILED=$((FAILED + 1))
                fi
            elif [[ -f "requirements.txt" ]]; then
                if pytest tests/ -q >/dev/null 2>&1; then
                    echo "  ✓ 测试通过"
                else
                    echo "  ✗ 测试失败"
                    FAILED=$((FAILED + 1))
                fi
            fi

            echo ""
            cd "$WORKTREE_ROOT" >/dev/null
        fi
    fi
done

echo "==============================================="
echo "结果: $((TOTAL - FAILED))/$TOTAL 通过"
if [[ $FAILED -eq 0 ]]; then
    echo "✓ 全部通过"
else
    echo "⚠ $FAILED 个失败"
fi
