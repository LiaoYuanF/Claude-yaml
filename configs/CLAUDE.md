# Configs 配置模板

模型、服务、量化的配置文件模板。

## 目录结构

| 目录 | 用途 | 代表文件 |
|------|------|---------|
| `model_configs/` | 模型定义（名称、序列长度、dtype） | `llama3_70b.yaml` |
| `serving_configs/` | 服务参数（TP/PP、batch size、并发） | `single_gpu.yaml` |
| `quantization_configs/` | 量化策略（FP8、INT8、AWQ） | `fp8_w8a8.yaml` |

## 修改模式

新增模型时，在 `model_configs/` 添加配置，然后在 `runtime/models/` 添加对应实现。
