## AI 协作规范

- **核心思维：** 运用第一性原理，拒绝经验主义和路径盲从。若动机模糊请停下讨论；若路径非最优，直接建议更短的办法。
- **输出结构：** 所有回答分 **[直接执行]** 和 **[深度交互]** 两部分。

## Agent Team 协议

复杂任务按 6 阶段执行：Clarifier → Scout → Architect → Builder → Verifier → Critic。
完整协议见 [docs/claude/agent-team-protocol.md](docs/claude/agent-team-protocol.md)。
远程验证流程见 [docs/claude/remote-verification-workflow.md](docs/claude/remote-verification-workflow.md)。

## 项目上下文

- **类型：** AI 推理引擎骨架（LLM + 视觉生成），用于维护 AI-native 开发配置
- **架构：** SGLang 风格分层 — `api/`（前端协议层）+ `runtime/`（后端运行时）
- **技术栈：** PyTorch, CUDA, Triton, NCCL, gRPC/HTTP
- **关注指标：** P50/P99 延迟, tokens/s, images/s, 显存峰值, TTFT

## 架构总览

```
请求流向: Client → api/entrypoints → api/openai (协议解析)
                                   → runtime/managers/scheduler (调度)
                                   → runtime/model_executor/model_runner (执行)
                                   → runtime/layers/* (计算)
                                   → runtime/kernels/* (底层算子)

内存管理: runtime/mem_cache ←→ runtime/model_executor (KV cache 分配/释放)
分布式:   runtime/distributed → runtime/layers (TP/PP/EP 切分注入)
```

## 并行开发策略

当任务可分解为 2-4 个独立子任务（修改不同模块、无顺序依赖）时，使用 `/parallel-dev` 启动多 worktree 并行开发模式。每个 agent 在隔离 worktree 中工作，完成后由 `/review-worktree` 审查，通过后串行 merge。

**适用：** 多模块特性开发、独立 bug 修复批量处理、重构+新功能并行
**不适用：** 单文件改动、有顺序依赖的任务链、快速 hotfix

## CI 闭环

代码变更的验证通过 `/ci-test` skill 在远程 GPU 测试集群执行。流程：

```
代码变更 → /ci-test → 远程执行测试 → 失败? → 自动修复(最多3轮) → 全量通过 → /profile-perf → 产出报告
```

- 测试环境配置: `configs/ci/test-env.yaml`（迁移时填入实际值）
- 测试矩阵: `configs/ci/test-matrix.yaml`（smoke/unit/integration/e2e/performance）
- 遗留代码库完整重构: `/refactor-legacy`（编排 ai-native-transform → parallel-dev → ci-test → profile-perf）

## 代码质量偏好

- 性能关键路径（scheduler, kernels, attention）：极致优化
- 非关键路径（config, utils, client）：清晰简洁优先
- 所有路径：完整类型注解 + 明确错误处理
