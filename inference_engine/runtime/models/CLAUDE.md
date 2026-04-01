# models — 模型注册表

按模态分为 `llm/`、`vision/`、`diffusion/`。

## 依赖关系
- **上游:** `model_loader` — 加载权重; 模型配置
- **下游:** `model_executor` — 调用 forward; `layers/*` — 使用计算层

## 接口契约
- 每个模型必须实现 `forward()` 和 `load_weights()` 标准接口
- 新模型必须在注册表中注册

## 修改模式
- **新增模型:** 复制 `llm/llama.py` → 修改架构 → 注册
- MoE 模型参考 `llm/deepseek_v2.py`
- 视觉模型参考 `vision/clip.py`
- 扩散模型参考 `diffusion/flux.py`
