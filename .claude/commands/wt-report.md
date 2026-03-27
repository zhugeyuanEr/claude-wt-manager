---
allowed-tools: Bash(bash *wt-report.sh:*), Glob(*THREAD-*-PLAN.md:*), Read(*INTERFACE-CONTRACT.md:*)
description: 生成完整的多线开发进度报告
---

## Context

项目根目录: $(git rev-parse --show-toplevel 2>/dev/null || echo "unknown")
Worktree 列表: $(git worktree list 2>/dev/null || echo "无法获取")
接口协议: INTERFACE-CONTRACT.md (在项目根目录)

## Task

生成完整的多线开发进度报告，包括：

1. **执行摘要**
   - 总线程数
   - 整体进度
   - 关键里程碑状态

2. **Worktree 状态**
   - 各 worktree 名称和分支
   - 工作区状态

3. **各线程详细进度**
   - 进度条可视化
   - 检查点完成状态
   - 阻塞项
   - 剩余工作量

4. **接口对接状态**
   - 已实现接口
   - 待实现接口
   - 依赖关系

5. **风险评估**
   - 已知风险
   - 建议行动

运行 wt-report.sh 生成 Markdown 格式报告。
