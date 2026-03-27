#!/bin/bash
# wt-contract.sh - 接口协议检查

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

CONTRACT_FILE="$WT_ROOT/INTERFACE-CONTRACT.md"

wt_header "接口协议检查"

if [[ ! -f "$CONTRACT_FILE" ]]; then
    echo "⚠ 未找到 INTERFACE-CONTRACT.md"
    wt_footer
    exit 0
fi

echo "实现的接口:"
echo ""

grep -E "^\*\*实现方\*\*:" "$CONTRACT_FILE" 2>/dev/null | while IFS= read -r line; do
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

wt_footer
