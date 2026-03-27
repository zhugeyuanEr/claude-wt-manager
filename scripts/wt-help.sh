#!/bin/bash
# wt-help.sh - 显示所有可用命令的帮助信息

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

TARGET="${1:-}"

wt_header "WT Manager 帮助"

# 如果指定了命令，显示该命令的帮助
if [[ -n "$TARGET" ]]; then
    HELP_FILE="$WT_SCRIPT_DIR/../commands/wt-${TARGET}.md"

    if [[ -f "$HELP_FILE" ]]; then
        echo ">>> $TARGET 命令帮助"
        echo ""
        cat "$HELP_FILE"
    else
        echo "错误: 未找到命令 '$TARGET' 的帮助文件"
        echo ""
        echo "可用命令: wt-plan, wt-list, wt-status, wt-progress, wt-qa, wt-batch-qa,"
        echo "         wt-contract, wt-merge-check, wt-report, wt-dev,"
        echo "         wt-commit, wt-blockers, wt-switch, wt-help"
    fi
    echo ""
    wt_footer
    exit 0
fi

# 显示所有命令列表
echo ">>> 可用命令"
echo ""

COMMANDS=(
    "wt-plan:分析项目，生成 worktree 规划"
    "wt-list:查看 worktree 列表"
    "wt-status:显示所有 worktree 状态"
    "wt-progress:检查各线程进度"
    "wt-qa:质量检测"
    "wt-batch-qa:批量质量检测"
    "wt-contract:接口协议检查"
    "wt-merge-check:合并前验证"
    "wt-report:生成完整进度报告"
    "wt-dev:启动/继续开发"
    "wt-commit:提交当前更改"
    "wt-blockers:查看阻塞清单"
    "wt-switch:切换到指定 worktree"
    "wt-help:显示帮助信息"
)

for cmd in "${COMMANDS[@]}"; do
    name="${cmd%%:*}"
    desc="${cmd#*:}"
    printf "  %-18s %s\n" "/$name" "$desc"
done

echo ""
wt_footer
echo ""
echo "使用方式:"
echo "  /wt-help              # 显示所有命令"
echo "  /wt-help <命令名>     # 显示指定命令帮助"
echo ""
wt_divider
