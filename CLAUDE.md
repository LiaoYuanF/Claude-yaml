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

## 代码质量偏好

- 性能关键路径（scheduler, kernels, attention）：极致优化
- 非关键路径（config, utils, client）：清晰简洁优先
- 所有路径：完整类型注解 + 明确错误处理
