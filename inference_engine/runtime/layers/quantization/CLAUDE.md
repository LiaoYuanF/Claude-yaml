# layers/quantization — 量化

`fp8.py` 是主要量化路径。

## 依赖关系
- **上游:** `model_loader` — 触发量化; `models/*` — 使用量化层
- **下游:** `kernels/*` — 量化 kernel

## 接口契约
- 量化格式变更须同步 `model_loader/loader.py`
- 精度变更须验证 PPL 无显著退化

## 修改模式
- 新增量化方法: 实现量化/反量化 + 对应 kernel
- 验证: 精度 (PPL) + 性能 (throughput) 双指标
