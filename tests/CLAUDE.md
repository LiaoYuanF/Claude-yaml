# Tests 测试套件

优先集成测试（真实模型 + 真实 GPU），避免 mock 掩盖问题。

## 目录映射

| 测试目录 | 对应源码 | 代表文件 |
|----------|---------|---------|
| `test_api/` | `inference_engine/api/` | `test_openai_compat.py` |
| `test_runtime/` | `runtime/managers/` | `test_scheduler.py` |
| `test_models/` | `runtime/models/` | `test_llama.py` |
| `test_kernels/` | `runtime/kernels/` | `test_attention_kernels.py` |
| `test_distributed/` | `runtime/distributed/` | `test_tensor_parallel.py` |

## 运行环境

- 本地无 GPU: 仅运行 `test_api/`
- 远程 GPU 集群: 全量运行，流程见 `docs/claude/remote-verification-workflow.md`
