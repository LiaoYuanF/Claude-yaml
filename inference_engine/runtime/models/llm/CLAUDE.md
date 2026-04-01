# models/llm — 大语言模型

`llama.py` 是参考实现，`deepseek_v2.py` 展示 MoE 模式。

## 依赖关系
- **上游:** `model_loader`; 模型配置
- **下游:** `layers/attention`, `layers/moe`, `layers/rotary_embedding`

## 接口契约
- `forward()` 必须接受 `model_runner.py` 标准参数集
- `load_weights()` 权重名映射必须与 HuggingFace checkpoint 一致

## 修改模式
- 新增 LLM: 复制 `llama.py`，修改 attention/FFN，注册
- 确认不破坏 CUDA Graph 兼容性
