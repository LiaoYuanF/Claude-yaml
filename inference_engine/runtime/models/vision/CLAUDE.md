# models/vision — 视觉编码器

`clip.py` 是参考实现。

## 依赖关系
- **上游:** `model_loader`; `multimodal/processors` — 图像预处理
- **下游:** `model_executor` — 编码器输出注入 LLM

## 接口契约
- 输出维度须与对应 LLM 的 cross-attention 输入匹配
- 图像分辨率变更须同步 `multimodal/processors`

## 修改模式
- 新增编码器: 参考 `clip.py`，实现标准 `encode()` 接口
