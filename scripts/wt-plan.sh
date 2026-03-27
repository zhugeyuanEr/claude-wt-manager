#!/bin/bash
# wt-plan.sh - 自动分析项目并生成 worktree 规划

WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
REQUESTED_COUNT="${1:-}"

echo "==============================================="
echo "       项目分析与 Worktree 规划"
echo "==============================================="
echo ""

# ============ 阶段1: 项目分析 ============
echo ">>> 阶段1: 分析项目结构..."
echo ""

# 统计代码行数
if [[ -d "$WORKTREE_ROOT/backend" ]]; then
    BACKEND_LINES=$(find "$WORKTREE_ROOT/backend" -name "*.py" -exec cat {} \; 2>/dev/null | wc -l)
    echo "  后端代码: $BACKEND_LINES 行 (Python)"
fi

if [[ -d "$WORKTREE_ROOT/frontend" ]]; then
    FRONTEND_LINES=$(find "$WORKTREE_ROOT/frontend" -name "*.vue" -o -name "*.ts" -o -name "*.tsx" -exec cat {} \; 2>/dev/null | wc -l)
    echo "  前端代码: $FRONTEND_LINES 行 (Vue/TS)"
fi

# 统计文件数
TOTAL_FILES=$(find "$WORKTREE_ROOT" -type f \( -name "*.py" -o -name "*.ts" -o -name "*.vue" -o -name "*.go" -o -name "*.java" \) 2>/dev/null | wc -l)
echo "  总文件数: $TOTAL_FILES"

# 识别主要模块
echo ""
echo "  识别的主要模块:"

# 识别后端模块
if [[ -d "$WORKTREE_ROOT/backend/app" ]]; then
    echo "    [后端] app/ - 核心应用"
fi

if [[ -d "$WORKTREE_ROOT/backend/app/api" ]]; then
    API_DIRS=$(find "$WORKTREE_ROOT/backend/app/api" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | xargs -I {} basename {} | tr '\n' ', ')
    if [[ -n "$API_DIRS" ]]; then
        echo "    [后端] api/ - $API_DIRS"
    fi
fi

# 识别前端模块
if [[ -d "$WORKTREE_ROOT/frontend/src" ]]; then
    echo "    [前端] src/ - 源码目录"
fi

if [[ -d "$WORKTREE_ROOT/frontend/src/components" ]]; then
    echo "    [前端] components/ - UI 组件"
fi

if [[ -d "$WORKTREE_ROOT/frontend/src/views" ]]; then
    echo "    [前端] views/ - 页面"
fi

if [[ -d "$WORKTREE_ROOT/frontend/src/stores" ]]; then
    echo "    [前端] stores/ - 状态管理"
fi

# 识别基础设施
if [[ -d "$WORKTREE_ROOT/tests" ]]; then
    echo "    [基础设施] tests/ - 测试"
fi

if [[ -d "$WORKTREE_ROOT/.github" ]]; then
    echo "    [基础设施] CI/CD 配置"
fi

if [[ -f "$WORKTREE_ROOT/docker-compose.yml" ]]; then
    echo "    [基础设施] Docker 配置"
fi

# 识别文档
DOC_FILES=$(find "$WORKTREE_ROOT" -maxdepth 2 -name "*.md" 2>/dev/null | wc -l)
echo "    [文档] $DOC_FILES 个 Markdown 文件"

echo ""

# ============ 阶段2: 计算推荐数量 ============
echo ">>> 阶段2: 计算推荐 Worktree 数量..."
echo ""

# 基础模块计数
MODULE_COUNT=2  # 基础: 前端 + 后端

# 根据文件数调整
if [[ $TOTAL_FILES -gt 100 ]]; then
    MODULE_COUNT=3
fi
if [[ $TOTAL_FILES -gt 300 ]]; then
    MODULE_COUNT=4
fi
if [[ $TOTAL_FILES -gt 500 ]]; then
    MODULE_COUNT=5
fi
if [[ $TOTAL_FILES -gt 800 ]]; then
    MODULE_COUNT=6
fi

# 特殊模块加分
[[ -d "$WORKTREE_ROOT/tests" ]] && MODULE_COUNT=$((MODULE_COUNT + 1))
[[ -d "$WORKTREE_ROOT/.github" ]] && MODULE_COUNT=$((MODULE_COUNT + 1))
[[ -d "$WORKTREE_ROOT/frontend/src/components/editor" ]] && MODULE_COUNT=$((MODULE_COUNT + 1))
[[ -d "$WORKTREE_ROOT/frontend/src/components/generation" ]] && MODULE_COUNT=$((MODULE_COUNT + 1))

# 上限
[[ $MODULE_COUNT -gt 6 ]] && MODULE_COUNT=6

echo "  因素分析:"
echo "    - 基础模块: 前端 + 后端 = 2"
echo "    - 代码规模 (${TOTAL_FILES} 文件): +$((MODULE_COUNT - 3))"
echo "    - 特殊模块 (测试/CI/组件): +1"
echo ""

# ============ 阶段3: 判断数量 ============
if [[ -z "$REQUESTED_COUNT" ]]; then
    # 用户未指定，使用推荐
    RECOMMENDED=$MODULE_COUNT
    echo "  ★ 推荐: $RECOMMENDED 个 worktree"
    echo ""
    echo "  使用方式:"
    echo "    ./wt-plan.sh 2          # 指定 2 个"
    echo "    ./wt-plan.sh 4          # 指定 4 个"
    echo ""
    echo "  确认后可生成规划 (y) 或指定数量 (2-6):"
else
    # 用户指定了数量
    REQUESTED=$((10#$REQUESTED_COUNT))  # 进制处理，避免 08 变 8

    echo "  您指定: $REQUESTED 个 worktree"
    echo ""

    # 检查是否合理
    ISSUES=""

    if [[ $REQUESTED -gt 6 ]]; then
        ISSUES="⚠️ 超过推荐上限 (6)，人工监督多线开发复杂度上限为 6"
    elif [[ $REQUESTED -lt 1 ]]; then
        ISSUES="⚠️ 数量过少，至少需要 1 个 worktree"
    elif [[ $REQUESTED -gt $((MODULE_COUNT + 2)) ]]; then
        ISSUES="⚠️ 超过模块数过多，建议最多 $((MODULE_COUNT + 1)) 个"
    fi

    if [[ -n "$ISSUES" ]]; then
        echo "  $ISSUES"
        echo ""
        echo "  推荐方案: $MODULE_COUNT 个"
        echo ""
        echo "  是否继续使用指定的 $REQUESTED 个? (y:继续 / n:使用推荐)"
    else
        echo "  ✓ 数量合理"
        echo ""
        RECOMMENDED=$REQUESTED
        echo "  将按 $RECOMMENDED 个 worktree 生成规划"
    fi
fi

echo ""
echo "==============================================="

# 如果需要生成详细规划，输出提示
if [[ -z "$REQUESTED_COUNT" ]]; then
    echo ""
    echo "提示: 运行 './wt-plan.sh N' 可生成 N 个 worktree 的详细规划"
fi
