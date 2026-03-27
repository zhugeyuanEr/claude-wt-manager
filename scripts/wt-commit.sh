#!/bin/bash
# wt-commit.sh - 提交当前 worktree 的更改

WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
CURRENT_DIR="$(pwd)"

# 自动检测当前 worktree
if [[ "$CURRENT_DIR" =~ /worktree-([a-zA-Z0-9_-]+) ]]; then
    TARGET="${BASH_REMATCH[1]}"
    WT_PATH="$CURRENT_DIR"
else
    echo "错误: 请在 worktree 目录中运行此命令"
    exit 1
fi

cd "$WT_PATH"

echo "==============================================="
echo "       提交更改: $TARGET"
echo "==============================================="
echo ""

# 显示 Git 状态
echo ">>> Git 状态"
echo ""

GIT_STATUS=$(git status --porcelain 2>/dev/null)
if [[ -z "$GIT_STATUS" ]]; then
    echo "✓ 工作区干净，无更改可提交"
    echo ""
    echo "==============================================="
    cd "$WORKTREE_ROOT" >/dev/null
    exit 0
fi

echo "变更文件:"
echo "$GIT_STATUS" | sed 's/^/  /'
echo ""

# 显示变更统计
echo ">>> 变更统计"
echo ""

STATS=$(git diff --stat 2>/dev/null)
if [[ -n "$STATS" ]]; then
    echo "$STATS" | sed 's/^/  /'
fi
echo ""

# 显示 diff 摘要
echo ">>> 变更摘要"
echo ""

git diff --name-only 2>/dev/null | while read file; do
    echo "  - $file"
done
echo ""

# 询问 commit 类型
echo ">>> Commit 类型"
echo "  1) feat   - 新功能"
echo "  2) fix    - Bug 修复"
echo "  3) docs   - 文档更新"
echo "  4) style  - 代码格式（不影响功能）"
echo "  5) refactor - 重构"
echo "  6) test   - 测试"
echo "  7) chore  - 构建/工具"
echo ""

read -p "选择类型 (1-7，默认为 feat): " type_choice
case "${type_choice:-1}" in
    2) COMMIT_TYPE="fix" ;;
    3) COMMIT_TYPE="docs" ;;
    4) COMMIT_TYPE="style" ;;
    5) COMMIT_TYPE="refactor" ;;
    6) COMMIT_TYPE="test" ;;
    7) COMMIT_TYPE="chore" ;;
    *) COMMIT_TYPE="feat" ;;
esac

echo ""
echo ">>> Commit 消息"
echo ""

read -p "简短描述: " commit_msg

if [[ -z "$commit_msg" ]]; then
    echo "错误: Commit 消息不能为空"
    exit 1
fi

# 显示要提交的内容供确认
echo ""
echo "==============================================="
echo "即将提交:"
echo ""
echo "类型: $COMMIT_TYPE"
echo "描述: $commit_msg"
echo ""
echo "文件:"
echo "$GIT_STATUS" | sed 's/^/  /'
echo ""

read -p "确认提交? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "已取消提交"
    cd "$WORKTREE_ROOT" >/dev/null
    exit 0
fi

# 执行提交
git add -A
git commit -m "$COMMIT_TYPE: $commit_msg"

echo ""
echo "✓ 提交成功"
echo ""

COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null)
echo "Commit: $COMMIT_HASH"

echo ""
echo "==============================================="

cd "$WORKTREE_ROOT" >/dev/null
