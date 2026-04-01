# models/diffusion — 扩散模型

`flux.py` 是参考实现。

## 依赖关系
- **上游:** `model_loader`; `multimodal/diffusion` — 推理管线
- **下游:** `layers/*`; `model_executor`

## 接口契约
- 必须实现标准 `denoise_step()` 接口
- 输出 tensor shape 须与后处理管线一致

## 修改模式
- 新增扩散模型: 参考 `flux.py`，实现去噪接口
- 采样策略在 `multimodal/diffusion/` 中调整，不硬编码在模型内
