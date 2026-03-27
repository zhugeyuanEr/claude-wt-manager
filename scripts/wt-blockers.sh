#!/bin/bash
# wt-blockers.sh - 查看所有 worktree 的阻塞清单

WORKTREE_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"

echo "==============================================="
echo "       阻塞清单"
echo "==============================================="
echo ""

# 获取线程列表
THREADS=$(git worktree list | grep -o 'worktree-thread-[a-z]*' | sed 's/worktree-//' 2>/dev/null)

if [[ -z "$THREADS" ]]; then
    echo "未找到任何 worktree-thread-*"
    exit 0
fi

BLOCKER_COUNT=0

for thread in $THREADS; do
    WT_PATH="$WORKTREE_ROOT/worktree-thread-$thread"
    PLAN_FILE="$WT_PATH/THREAD-${thread^^}-PLAN.md"

    if [[ ! -d "$WT_PATH" ]]; then
        continue
    fi

    # 查找阻塞项
    BLOCKERS=""

    if [[ -f "$PLAN_FILE" ]]; then
        # 查找标记为阻塞的项 (⚠, WAITING, BLOCKED, 依赖等)
        BLOCKERS=$(grep -n -E "(⚠|WAITING|BLOCKED|依赖|等待|阻塞)" "$PLAN_FILE" 2>/dev/null)

        # 也查找明确标记的阻塞章节
        BLOCKER_SECTION=$(sed -n '/^##.*阻塞/,/^##/p' "$PLAN_FILE" 2>/dev/null | grep -v "^##")
    fi

    if [[ -n "$BLOCKERS" ]] || [[ -n "$BLOCKER_SECTION" ]]; then
        echo "### $thread"
        echo ""

        if [[ -n "$BLOCKER_SECTION" ]]; then
            echo "$BLOCKER_SECTION" | sed 's/^/  /'
        elif [[ -n "$BLOCKERS" ]]; then
            echo "$BLOCKERS" | head -10 | sed 's/^/  /'
        fi

        echo ""
        BLOCKER_COUNT=$((BLOCKER_COUNT + 1))
    fi
done

# 如果有阻塞的 plan 文件但上面没找到，显示它们
for thread in $THREADS; do
    WT_PATH="$WORKTREE_ROOT/worktree-thread-$thread"

    if [[ -d "$WT_PATH" ]]; then
        # 检查 plan 文件中是否有未完成的前置依赖
        PLAN_FILE="$WT_PATH/THREAD-${thread^^}-PLAN.md"

        if [[ -f "$PLAN_FILE" ]]; then
            # 查找任务项并检查依赖
            TASKS=$(grep -E "^\[ \]" "$PLAN_FILE" 2>/dev/null | head -5)

            if [[ -n "$TASKS" ]]; then
                # 检查是否有依赖说明
                DEPENDENCIES=$(grep -B1 -E "^\[ \]|^\- \[ \]" "$PLAN_FILE" 2>/dev/null | grep -E "(依赖|等待|需要|before)" | head -5)

                if [[ -n "$DEPENDENCIES" ]]; then
                    # 已经显示过了，跳过
                    continue
                fi
            fi
        fi
    fi
done

if [[ $BLOCKER_COUNT -eq 0 ]]; then
    echo "✓ 当前无阻塞项"
    echo ""
    echo "所有线程开发进度正常"
else
    echo ""
    echo "==============================================="
    echo "共发现 $BLOCKER_COUNT 个线程存在阻塞项"
fi

echo ""
echo "==============================================="
echo "更新于: $(date '+%Y-%m-%d %H:%M')"
