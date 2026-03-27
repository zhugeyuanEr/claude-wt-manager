#!/bin/bash
# wt-dev.sh - 在 worktree 中启动或继续开发

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

TARGET="${1:-}"
[[ -z "$TARGET" ]] && TARGET="$(wt_detect)"

if [[ -z "$TARGET" ]]; then
    echo "错误: 请指定 worktree 名称，或在 worktree 目录中运行"
    echo "使用方式: /wt-dev <thread-name>"
    exit 1
fi

WT_PATH="$(wt_path "$TARGET")"

if [[ ! -d "$WT_PATH" ]]; then
    echo "错误: worktree-thread-$TARGET 不存在"
    exit 1
fi

wt_header "开发模式: $TARGET"
cd "$WT_PATH"

PLAN_FILE="THREAD-${TARGET^^}-PLAN.md"
if [[ -f "$PLAN_FILE" ]]; then
    echo ">>> 当前任务 (从 $PLAN_FILE)"
    echo ""

    CURRENT_TASK=$(sed -n '/^## .*/{h;n;/^### .*进行中\|^### .*当前任务/{g;p;q}}; /^### .*进行中\|^### .*当前任务/{p;q}' "$PLAN_FILE" 2>/dev/null | head -5)
    [[ -z "$CURRENT_TASK" ]] && CURRENT_TASK=$(grep -A 3 "^\[ \]" "$PLAN_FILE" 2>/dev/null | head -5)

    [[ -n "$CURRENT_TASK" ]] && echo "$CURRENT_TASK" | sed 's/^/  /' || echo "  (无可用任务信息)"
else
    echo "警告: 未找到 $PLAN_FILE"
fi

echo ""
echo ">>> Git 状态"
echo ""

GIT_STATUS=$(git status --porcelain 2>/dev/null)
if [[ -z "$GIT_STATUS" ]]; then
    echo "  ✓ 工作区干净"
else
    echo "  ⚠ 有未提交的更改:"
    echo "$GIT_STATUS" | head -10 | sed 's/^/    /'
fi

echo ""
echo ">>> 分支信息"
echo ""

BRANCH=$(git branch --show-current 2>/dev/null)
echo "  当前分支: $BRANCH"

LAST_COMMIT=$(git log -1 --oneline 2>/dev/null)
[[ -n "$LAST_COMMIT" ]] && echo "  最后提交: $LAST_COMMIT"

echo ""
wt_footer
echo ""
echo "下一步行动:"
echo "  1. 查看完整计划: cat $PLAN_FILE"
echo "  2. 查看接口合同: cat INTERFACE-CONTRACT.md (如果存在)"
echo "  3. 开始开发工作..."
echo ""
wt_divider

cd "$WT_ROOT" >/dev/null
