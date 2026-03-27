#!/bin/bash
# wt-contract.sh - 接口协议检查

WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
CONTRACT_FILE="$WORKTREE_ROOT/INTERFACE-CONTRACT.md"

echo "==============================================="
echo "       接口协议检查"
echo "==============================================="
echo ""

if [[ ! -f "$CONTRACT_FILE" ]]; then
    echo "⚠ 未找到 INTERFACE-CONTRACT.md"
    exit 0
fi

echo "实现的接口:"
echo ""

# 解析接口实现状态
grep -E "^\*\*实现方\*\*:" "$CONTRACT_FILE" 2>/dev/null | while IFS= read -r line; do
    # 获取上一行的接口路径
    prev_line=$(grep -B2 "$line" "$CONTRACT_FILE" | head -1)
    if [[ "$prev_line" =~ ^\*\*路径\*\*:\ \`([^\`]+)\` ]]; then
        API_PATH="${BASH_REMATCH[1]}"
        IMPL_BY=$(echo "$line" | sed 's/\*\*实现方\*\*://' | sed 's/(//' | sed 's/)//' | xargs)
        echo "  $API_PATH → $IMPL_BY"
    fi
done

echo ""
echo "接口统计:"
echo "  总接口数: $(grep -c "\*\*路径\*\*:" "$CONTRACT_FILE" 2>/dev/null || echo "0")"

echo ""
echo "==============================================="
