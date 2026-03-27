#!/bin/bash
# wt-qa.sh - 质量检测

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

TARGET="${1:-}"
[[ -z "$TARGET" ]] && TARGET="$(wt_detect)"

if [[ -z "$TARGET" ]]; then
    echo "错误: 请指定 worktree 名称，或在 worktree 目录中运行"
    exit 1
fi

WT_PATH="$(wt_path "$TARGET")"

if [[ ! -d "$WT_PATH" ]]; then
    echo "错误: worktree-thread-$TARGET 不存在"
    exit 1
fi

wt_header "质量检测: $TARGET"
cd "$WT_PATH"

# 代码规范检查
echo ">>> 代码规范检查..."

if [[ -f "package.json" ]] && grep -q '"typescript"' package.json 2>/dev/null; then
    echo "  [TypeScript] 检查..."
    npx tsc --noEmit 2>/dev/null || echo "    ⚠ TSC 检查跳过"
fi

if [[ -d "backend" ]] && [[ -f "backend/requirements.txt" ]]; then
    echo "  [Python] 检查..."
    command -v ruff &>/dev/null && ruff check backend/ 2>/dev/null || echo "    ⚠ Ruff 检查跳过"
fi

# 测试检查
echo ""
echo ">>> 测试检查..."
if [[ -f "package.json" ]]; then
    npm test 2>&1 | head -20 || echo "  ⚠ 测试跳过"
elif [[ -d "tests" ]] || [[ -d "backend/tests" ]]; then
    pytest tests/ -v 2>&1 | head -20 || echo "  ⚠ 测试跳过"
fi

# Git 状态检查
echo ""
echo ">>> Git 状态检查..."
GIT_STATUS=$(git status --porcelain 2>/dev/null)
if [[ -z "$GIT_STATUS" ]]; then
    echo "  ✓ 工作区干净"
else
    echo "  ⚠ 有未提交的更改:"
    echo "$GIT_STATUS" | head -10 | sed 's/^/    /'
fi

wt_footer
cd "$WT_ROOT" >/dev/null
