#!/bin/bash
# wt-uninstall.sh - 卸载 WT Manager 全局插件

set -e

GLOBAL_COMMANDS="$HOME/.claude/commands"
GLOBAL_SCRIPTS="$HOME/.claude/commands-scripts"

echo "==============================================="
echo "       WT Manager 卸载"
echo "==============================================="
echo ""

# 删除全局命令文件
echo ">>> 删除命令文件..."
if [[ -d "$GLOBAL_COMMANDS" ]]; then
    rm -f "$GLOBAL_COMMANDS"/wt-*.md
    echo "  ✓ 已删除 $GLOBAL_COMMANDS"
fi

# 删除全局脚本文件
echo ">>> 删除脚本文件..."
if [[ -d "$GLOBAL_SCRIPTS" ]]; then
    rm -f "$GLOBAL_SCRIPTS"/wt-*.sh
    echo "  ✓ 已删除 $GLOBAL_SCRIPTS"
fi

echo ""
echo "==============================================="
echo "       卸载完成!"
echo "==============================================="
