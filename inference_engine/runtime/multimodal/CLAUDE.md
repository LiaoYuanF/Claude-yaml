# multimodal — 多模态处理

`processors/` 处理图像预处理，`diffusion/` 处理扩散推理管线。

## 依赖关系
- **上游:** `api/` — 接收多模态请求
- **下游:** `models/vision`, `models/diffusion` — 提供预处理后的输入

## 修改模式
- 新增模态: 在 `processors/` 添加预处理器
- 扩散管线: 在 `diffusion/` 中编排步骤
