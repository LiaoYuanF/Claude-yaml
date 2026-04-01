# model_loader — 权重加载

`loader.py` 处理 safetensors/bin/GGUF 等格式的加载与转换。

## 依赖关系
- **上游:** 模型配置（决定加载路径和量化方式）
- **下游:** `model_executor` — 提供加载好的权重

## 接口契约
- 权重名映射变更须同步 `models/` 下对应模型的 `load_weights()`
- 新增量化格式须同步 `layers/quantization/`
- 分布式加载须与 `distributed/` 分片策略一致

## 修改模式
- 新增格式: 在 `loader.py` 添加检测和加载分支
- 注意显存峰值: 大模型加载避免同时持有两份完整权重
