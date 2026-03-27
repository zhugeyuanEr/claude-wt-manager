#!/bin/bash
# wt-switch.sh - 切换到指定的 worktree

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

TARGET="${1:-}"

# 没有参数时显示列表
if [[ -z "$TARGET" ]]; then
    wt_header "Worktree 切换"

    echo "可用 Worktree:"
    echo ""

    # 使用数组收集结果，避免子 shell 变量丢失问题
    mapfile -t LINES < <(git worktree list)
    idx=1
    for line in "${LINES[@]}"; do
        RESULT=$(wt_parse_worktree_line "$line")
        [[ -z "$RESULT" ]] && continue

        IFS='|' read -r WT_NAME WT_PATH WT_BRANCH <<< "$RESULT"
        [[ "$WT_PATH" == "$WT_CURRENT" || "$WT_CURRENT" == "$WT_PATH/"* ]] && current=" ← 当前" || current=""
        printf "  %2d. %-20s %-25s%s\n" "$idx" "$WT_NAME" "[$WT_BRANCH]" "$current"
        idx=$((idx + 1))
    done

    echo ""
    echo "使用方式:"
    echo "  /wt-switch <thread-name>    # 例如: /wt-switch thread-api"
    echo "  /wt-switch                  # 显示列表"
    echo ""
    echo "示例:"
    echo "  /wt-switch thread-infra"
    echo "  /wt-switch thread-api"
    echo "  /wt-switch thread-ux"
    wt_footer
    exit 0
fi

# 支持直接指定 thread 名称
[[ ! "$TARGET" =~ ^worktree- ]] && TARGET="worktree-$TARGET"

WT_PATH="$WT_ROOT/$TARGET"

# 检查 worktree 是否存在
if [[ ! -d "$WT_PATH" ]]; then
    echo "错误: $TARGET 不存在"
    echo ""
    echo "可用 worktree:"
    git worktree list | grep -E "worktree-" | sed 's/^/  /'
    exit 1
fi

# 检查是否是当前目录
if [[ "$WT_CURRENT" == "$WT_PATH" || "$WT_CURRENT" == "$WT_PATH/"* ]]; then
    echo "提示: 已在 $TARGET 中"
    BRANCH=$(git branch --show-current 2>/dev/null)
    echo "当前分支: $BRANCH"
    exit 0
fi

wt_header "切换到: $TARGET"
echo ""
echo "路径: $WT_PATH"
echo ""
echo "执行以下命令切换:"
echo ""
echo "  cd $WT_PATH"
echo ""
echo "或在 Claude Code 中直接继续工作,"
echo "系统会自动检测当前 worktree。"
wt_footer
