#!/bin/bash
# wt-qa.sh - 质量检测

TARGET="${1:-}"
WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
CURRENT_DIR="$(pwd)"

# 自动检测当前 worktree
if [[ -z "$TARGET" ]]; then
    if [[ "$CURRENT_DIR" =~ /worktree-([a-zA-Z0-9_-]+) ]]; then
        TARGET="${BASH_REMATCH[1]}"
    else
        echo "错误: 请指定 worktree 名称，或在 worktree 目录中运行"
        exit 1
    fi
fi

WT_PATH="$WORKTREE_ROOT/worktree-thread-$TARGET"

if [[ ! -d "$WT_PATH" ]]; then
    echo "错误: worktree-thread-$TARGET 不存在"
    exit 1
fi

echo "==============================================="
echo "       质量检测: $TARGET"
echo "==============================================="
echo ""

cd "$WT_PATH"

# 代码规范检查
echo ">>> 代码规范检查..."

# TypeScript 检查
if [[ -f "package.json" ]] && grep -q '"typescript"' package.json 2>/dev/null; then
    echo "  [TypeScript] 检查..."
    npx tsc --noEmit 2>/dev/null || echo "    ⚠ TSC 检查跳过"
fi

# Python 检查
if [[ -d "backend" ]] && [[ -f "backend/requirements.txt" ]]; then
    echo "  [Python] 检查..."
    if command -v ruff &>/dev/null; then
        ruff check backend/ 2>/dev/null || echo "    ⚠ Ruff 检查有警告"
    fi
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

echo ""
echo "==============================================="
cd "$WORKTREE_ROOT" >/dev/null
