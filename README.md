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
CLAUDE.md (L0 项目级)                  ← 架构总览、协作规范、请求流向
├── inference_engine/CLAUDE.md (L1)    ← 层间通信、接口契约
│   ├── api/*/CLAUDE.md (L2)           ← 模块职责、依赖关系、修改指南
│   └── runtime/*/CLAUDE.md (L2)       ← 模块职责、依赖关系、修改指南
├── .claude/skills/                    ← 领域工作流 (add-model, benchmark, deploy...)
├── .claude/settings.json              ← Hooks (自动提醒) + MCP servers
└── docs/claude/                       ← 全局协议、集群配置、验证流程
```

## Skills

| 命令 | 用途 |
|------|------|
| `/add-model` | 新增模型支持的标准流程 |
| `/benchmark` | 运行性能基准测试并对比 baseline |
| `/optimize-kernel` | 优化 CUDA/Triton kernel 的标准流程 |
| `/deploy` | 部署推理服务到 GPU 集群 |
| `/debug-perf` | 性能问题排查流程 |
| `/ai-native-transform` | 将传统代码库改造为 AI-native（可复用到其他项目） |
