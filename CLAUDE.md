## 核心信念

详见 [docs/CORE_BELIEFS.md](docs/CORE_BELIEFS.md)。最重要的三条：
1. 机械约束优于自然语言建议
2. 纠正是廉价的，等待是昂贵的
3. 渐进式披露，不是一次性灌输

## 输出结构

所有回答分 **[直接执行]** 和 **[深度交互]** 两部分。

## 知识地图

| 要找什么 | 去哪里看 |
|---------|---------|
| 架构设计与决策记录 | [docs/design-docs/INDEX.md](docs/design-docs/INDEX.md) |
| 执行计划（活跃/已完成） | [docs/exec-plans/INDEX.md](docs/exec-plans/INDEX.md) |
| 质量评分与技术债 | [docs/QUALITY_SCORE.md](docs/QUALITY_SCORE.md) |
| Agent Team 协议 (6阶段) | [docs/claude/agent-team-protocol.md](docs/claude/agent-team-protocol.md) |
| 远程验证与 CI 流程 | [docs/claude/remote-verification-workflow.md](docs/claude/remote-verification-workflow.md) |
| 集群连接配置 | [docs/claude/cluster-config.yaml.md](docs/claude/cluster-config.yaml.md) |
| CI 测试配置 | [configs/ci/](configs/ci/) |
| 外部参考文档 | [docs/references/](docs/references/) |
| 自动生成文档 | [docs/generated/](docs/generated/) |

## 项目上下文

- **类型：** AI 推理引擎（LLM + 视觉生成）
- **架构：** `api/`（前端协议层）+ `runtime/`（后端运行时）
- **技术栈：** PyTorch, CUDA, Triton, NCCL, gRPC/HTTP
- **关注指标：** P50/P99 延迟, tokens/s, images/s, 显存峰值, TTFT

## 请求流向

```
Client → api/entrypoints → api/openai → runtime/managers/scheduler
       → runtime/model_executor → runtime/layers/* → runtime/kernels/*
```

## 工作模式

| 场景 | 使用 |
|------|------|
| 简单任务 (< 20行) | 直接执行 |
| 多模块并行任务 | `/parallel-dev` — worktree 隔离 |
| 远程测试验证 | `/ci-test` — 自动修复闭环 |
| 遗留代码库重构 | `/refactor-legacy` — 全流程编排 |
| 审查 | agent-to-agent 自主审查，仅最终合入须人类确认 |
