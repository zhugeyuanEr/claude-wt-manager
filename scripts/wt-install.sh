#!/bin/bash
# wt-install.sh - 全局安装 WT Manager 插件

set -e

GLOBAL_COMMANDS="$HOME/.claude/commands"
GLOBAL_SCRIPTS="$HOME/.claude/commands-scripts"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==============================================="
echo "       WT Manager 全局安装"
echo "==============================================="
echo ""

# 创建全局目录
echo ">>> 创建全局目录..."
mkdir -p "$GLOBAL_COMMANDS"
mkdir -p "$GLOBAL_SCRIPTS"

# 复制命令文件 (.md files)
echo ">>> 安装命令文件..."
if [[ -d "$SCRIPT_DIR/../.claude/commands" ]]; then
    cp -r "$SCRIPT_DIR/../.claude/commands/"* "$GLOBAL_COMMANDS/"
    echo "  ✓ 命令文件 → $GLOBAL_COMMANDS"
else
    echo "  ✗ 未找到 .claude/commands 目录"
    exit 1
fi

# 复制脚本文件 (.sh files)
echo ">>> 安装脚本文件..."
for script in "$SCRIPT_DIR"/wt-*.sh; do
    if [[ -f "$script" ]]; then
        cp "$script" "$GLOBAL_SCRIPTS/"
        echo "  ✓ $(basename "$script")"
    fi
done

echo ""
echo "==============================================="
echo "       安装完成!"
echo "==============================================="
echo ""
echo "现在可以在任意项目中使用以下命令:"
echo ""
echo "  /wt-plan       分析项目，生成 worktree 规划"
echo "  /wt-list       查看 worktree 列表"
echo "  /wt-status     显示所有 worktree 状态"
echo "  /wt-progress   检查进度"
echo "  /wt-qa         质量检测"
echo "  /wt-batch-qa   批量质量检测"
echo "  /wt-contract   接口协议检查"
echo "  /wt-merge-check 合并前验证"
echo "  /wt-report     生成完整进度报告"
echo "  /wt-dev        启动/继续开发"
echo "  /wt-commit     提交当前更改"
echo "  /wt-blockers   查看阻塞清单"
echo "  /wt-switch     切换 worktree"
echo "  /wt-help       显示帮助"
echo ""
echo "注意: 确保目标项目根目录有 .git 和 scripts/ 目录"
echo "==============================================="
