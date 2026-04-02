# Inference Engine

> AI-native 推理引擎目录骨架 — 用于维护 Claude Code 配置文档、Skills 和 Hooks。
> 代码文件为空桩，核心价值在各层的 `CLAUDE.md` 和 `.claude/` 下的 AI 工具链配置。

## 目录结构

```
inference_engine/              # 主 Python 包
├── api/                       # 前端 API 层 (OpenAI/gRPC/客户端)
└── runtime/                   # 后端运行时层
    ├── managers/               #   调度器、请求管理
    ├── model_executor/         #   模型执行器、CUDA graph
    ├── models/{llm,vision,diffusion}/  #   模型实现
    ├── layers/{attention,moe,quantization,...}  #   计算层
    ├── kernels/{cuda,triton}/  #   自定义算子
    ├── distributed/            #   TP/PP/EP 分布式
    ├── mem_cache/              #   KV cache、GPU 内存
    └── ...                     #   sampling, speculative, lora, multimodal, observability
```

## AI-Native 配置层级

```
CLAUDE.md (L0 地图)                    ← 纯指针，指向 docs/ 中的深层文档
├── docs/
│   ├── CORE_BELIEFS.md               ← Agent-first 运行的不可违背原则
│   ├── QUALITY_SCORE.md              ← 各模块质量评分（gardening agent 维护）
│   ├── design-docs/INDEX.md          ← 架构决策记录 (ADR)
│   ├── exec-plans/INDEX.md           ← 执行计划持久化（active/completed）
│   ├── generated/                    ← agent 自动生成的文档
│   ├── references/                   ← 外部依赖的 LLM 友好参考
│   └── claude/                       ← Agent Team 协议、远程验证、集群配置
├── inference_engine/CLAUDE.md (L1)   ← 层间通信、接口契约
│   ├── api/*/CLAUDE.md (L2)          ← 模块职责、依赖关系、修改指南
│   └── runtime/*/CLAUDE.md (L2)      ← 模块职责、依赖关系、修改指南
├── .claude/skills/                   ← 12 个领域工作流
├── .claude/settings.json             ← 机械约束 Hooks + MCP servers
└── configs/ci/                       ← CI 测试环境 + 测试矩阵
```

## Skills

### 开发工作流

| 命令 | AI 自动触发 | 用途 |
|------|-----------|------|
| `/add-model` | 可 | 新增模型支持的标准流程 |
| `/optimize-kernel` | 可 | 优化 CUDA/Triton kernel |
| `/debug-perf` | 可 (fork) | 性能问题排查（隔离 subagent） |

### CI / 测试 / 性能

| 命令 | AI 自动触发 | 用途 |
|------|-----------|------|
| `/ci-test` | 禁止 | 远程 CI 集成测试（带自动修复重试闭环） |
| `/benchmark` | 禁止 | 运行性能基准测试并对比 baseline |
| `/profile-perf` | 禁止 | 远程 profiling + 性能分析报告 |
| `/deploy` | 禁止 | 部署推理服务到 GPU 集群 |

### 熵管理

| 命令 | AI 自动触发 | 用途 |
|------|-----------|------|
| `/gardening` | 禁止 | 代码质量扫描 + 文档腐化检测 + 质量评分更新 |

### 协作与编排

| 命令 | AI 自动触发 | 用途 |
|------|-----------|------|
| `/parallel-dev` | 禁止 | 多 worktree 并行开发编排 |
| `/review-worktree` | 禁止 | 审查 worktree 分支变更 |
| `/refactor-legacy` | 禁止 | 遗留代码库完整重构（顶层编排） |
| `/ai-native-transform` | 禁止 | 将传统代码库改造为 AI-native |
