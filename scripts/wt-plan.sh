#!/bin/bash
# wt-plan.sh - 自动分析项目并生成 worktree 规划

source "$(dirname "${BASH_SOURCE[0]}")/wt-lib.sh"

REQUESTED_COUNT="${1:-}"

wt_header "项目分析与 Worktree 规划"

# ============ 阶段1: 项目分析 ============
echo ">>> 阶段1: 分析项目结构..."
echo ""

# 统计代码行数
[[ -d "$WT_ROOT/backend" ]] && BACKEND_LINES=$(find "$WT_ROOT/backend" -name "*.py" -exec cat {} \; 2>/dev/null | wc -l) && echo "  后端代码: $BACKEND_LINES 行 (Python)"

[[ -d "$WT_ROOT/frontend" ]] && FRONTEND_LINES=$(find "$WT_ROOT/frontend" -name "*.vue" -o -name "*.ts" -o -name "*.tsx" -exec cat {} \; 2>/dev/null | wc -l) && echo "  前端代码: $FRONTEND_LINES 行 (Vue/TS)"

# 统计文件数
TOTAL_FILES=$(find "$WT_ROOT" -type f \( -name "*.py" -o -name "*.ts" -o -name "*.vue" -o -name "*.go" -o -name "*.java" \) 2>/dev/null | wc -l)
echo "  总文件数: $TOTAL_FILES"

# 识别主要模块
echo ""
echo "  识别的主要模块:"

[[ -d "$WT_ROOT/backend/app" ]] && echo "    [后端] app/ - 核心应用"

if [[ -d "$WT_ROOT/backend/app/api" ]]; then
    API_DIRS=$(find "$WT_ROOT/backend/app/api" -maxdepth 1 -type d 2>/dev/null | tail -n +2 | xargs -I {} basename {} | tr '\n' ', ')
    [[ -n "$API_DIRS" ]] && echo "    [后端] api/ - $API_DIRS"
fi

[[ -d "$WT_ROOT/frontend/src" ]] && echo "    [前端] src/ - 源码目录"
[[ -d "$WT_ROOT/frontend/src/components" ]] && echo "    [前端] components/ - UI 组件"
[[ -d "$WT_ROOT/frontend/src/views" ]] && echo "    [前端] views/ - 页面"
[[ -d "$WT_ROOT/frontend/src/stores" ]] && echo "    [前端] stores/ - 状态管理"
[[ -d "$WT_ROOT/tests" ]] && echo "    [基础设施] tests/ - 测试"
[[ -d "$WT_ROOT/.github" ]] && echo "    [基础设施] CI/CD 配置"
[[ -f "$WT_ROOT/docker-compose.yml" ]] && echo "    [基础设施] Docker 配置"

DOC_FILES=$(find "$WT_ROOT" -maxdepth 2 -name "*.md" 2>/dev/null | wc -l)
echo "    [文档] $DOC_FILES 个 Markdown 文件"

echo ""

# ============ 阶段2: 计算推荐数量 ============
echo ">>> 阶段2: 计算推荐 Worktree 数量..."
echo ""

MODULE_COUNT=2

[[ $TOTAL_FILES -gt 100 ]] && MODULE_COUNT=3
[[ $TOTAL_FILES -gt 300 ]] && MODULE_COUNT=4
[[ $TOTAL_FILES -gt 500 ]] && MODULE_COUNT=5
[[ $TOTAL_FILES -gt 800 ]] && MODULE_COUNT=6

[[ -d "$WT_ROOT/tests" ]] && MODULE_COUNT=$((MODULE_COUNT + 1))
[[ -d "$WT_ROOT/.github" ]] && MODULE_COUNT=$((MODULE_COUNT + 1))
[[ -d "$WT_ROOT/frontend/src/components/editor" ]] && MODULE_COUNT=$((MODULE_COUNT + 1))
[[ -d "$WT_ROOT/frontend/src/components/generation" ]] && MODULE_COUNT=$((MODULE_COUNT + 1))

[[ $MODULE_COUNT -gt 6 ]] && MODULE_COUNT=6

echo "  因素分析:"
echo "    - 基础模块: 前端 + 后端 = 2"
echo "    - 代码规模 (${TOTAL_FILES} 文件): +$((MODULE_COUNT - 3))"
echo "    - 特殊模块 (测试/CI/组件): +1"
echo ""

# ============ 阶段3: 判断数量 ============
if [[ -z "$REQUESTED_COUNT" ]]; then
    RECOMMENDED=$MODULE_COUNT
    echo "  ★ 推荐: $RECOMMENDED 个 worktree"
    echo ""
    echo "  使用方式:"
    echo "    ./wt-plan.sh 2          # 指定 2 个"
    echo "    ./wt-plan.sh 4          # 指定 4 个"
else
    REQUESTED=$((10#$REQUESTED_COUNT))

    echo "  您指定: $REQUESTED 个 worktree"
    echo ""

    ISSUES=""
    [[ $REQUESTED -gt 6 ]] && ISSUES="⚠️ 超过推荐上限 (6)，人工监督多线开发复杂度上限为 6"
    [[ $REQUESTED -lt 1 ]] && ISSUES="⚠️ 数量过少，至少需要 1 个 worktree"
    [[ $REQUESTED -gt $((MODULE_COUNT + 2)) ]] && ISSUES="⚠️ 超过模块数过多，建议最多 $((MODULE_COUNT + 1)) 个"

    if [[ -n "$ISSUES" ]]; then
        echo "  $ISSUES"
        echo ""
        echo "  推荐方案: $MODULE_COUNT 个"
    else
        echo "  ✓ 数量合理"
        RECOMMENDED=$REQUESTED
    fi
fi

# ============ 阶段4: 交互式输入工作内容 ============
if [[ -n "$REQUESTED_COUNT" && -z "$ISSUES" ]]; then
    echo ""
    echo ">>> 阶段3: 定义每个 Worktree 的工作内容..."
    echo ""

    # 预设的线程名称（可用户自定义）
    DEFAULT_NAMES=("thread-infra" "thread-api" "thread-ux" "thread-advanced" "thread-feature-a" "thread-feature-b")

    # 读取每个 worktree 的信息
    declare -a WORKTREE_NAMES=()
    declare -a WORKTREE_TASKS=()

    for ((i=1; i<=REQUESTED; i++)); do
        echo "  --- Worktree $i/$REQUESTED ---"

        # 默认名称
        DEFAULT_NAME="${DEFAULT_NAMES[$((i-1))]}"
        [[ -z "$DEFAULT_NAME" ]] && DEFAULT_NAME="thread-$i"

        # 读取名称
        read -p "    名称 [${DEFAULT_NAME}]: " NAME
        NAME="${NAME:-$DEFAULT_NAME}"
        WORKTREE_NAMES+=("$NAME")

        # 读取工作内容
        echo -n "    工作内容: "
        read TASK
        WORKTREE_TASKS+=("${TASK:-未指定}")

        echo ""
    done

    # ============ 阶段5: 生成规划方案 ============
    echo ""
    echo "================================================================"
    echo "                      Worktree 规划方案"
    echo "================================================================"
    echo ""

    # 计算依赖关系
    echo "  依赖关系图:"
    echo ""
    for ((i=0; i<REQUESTED; i++)); do
        LEVEL=$((i))

        # 绘制箭头
        if [[ $i -eq 0 ]]; then
            echo "  ★ ${WORKTREE_NAMES[$i]} (Level $LEVEL)"
        else
            INDENT=""
            for ((j=0; j<i; j++)); do
                INDENT="    $INDENT"
            done
            echo "${INDENT}↓"
            echo "${INDENT}★ ${WORKTREE_NAMES[$i]} (Level $LEVEL)"
        fi

        # 依赖说明
        if [[ $i -eq 0 ]]; then
            echo "    └── 无依赖，可独立开发"
        else
            echo "    └── 依赖: ${WORKTREE_NAMES[$((i-1))]}"
        fi
        echo ""
    done

    echo "----------------------------------------------------------------"
    echo "                      详细规划表"
    echo "----------------------------------------------------------------"
    echo ""

    printf "  %-20s | %-10s | %s\n" "线程名称" "Level" "工作内容"
    printf "  %-20s-+-%-10s-+-%s\n" "--------------------" "----------" "----------------------------------------------------------------"

    for ((i=0; i<REQUESTED; i++)); do
        printf "  %-20s | %-10s | %s\n" "${WORKTREE_NAMES[$i]}" "Level $i" "${WORKTREE_TASKS[$i]}"
    done

    echo ""
    echo "----------------------------------------------------------------"
    echo "                      合并顺序"
    echo "----------------------------------------------------------------"
    echo ""
    echo "  警告: 必须按 Level 从低到高合并！"
    echo ""

    MERGE_ORDER=""
    for ((i=0; i<REQUESTED; i++)); do
        [[ $i -gt 0 ]] && MERGE_ORDER+=" → "
        MERGE_ORDER+="${WORKTREE_NAMES[$i]}"
    done
    echo "  合并顺序: $MERGE_ORDER"
    echo ""

    echo "================================================================"
    echo ""
    echo "  提示: 使用 'git worktree add' 创建 worktree:"
    echo ""
    for ((i=0; i<REQUESTED; i++)); do
        echo "    git worktree add worktree-${WORKTREE_NAMES[$i]} -b ${WORKTREE_NAMES[$i]}"
    done
    echo ""
fi

echo ""
wt_footer
[[ -z "$REQUESTED_COUNT" ]] && echo "提示: 运行 './wt-plan.sh N' 可生成 N 个 worktree 的详细规划"
echo ""
