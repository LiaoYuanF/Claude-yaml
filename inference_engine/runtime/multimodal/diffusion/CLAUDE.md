# multimodal/diffusion — 扩散推理管线

`pipeline.py` 编排去噪步骤。

## 依赖关系
- **上游:** API 层（生成请求）
- **下游:** `models/diffusion/` — 执行去噪; 后处理 (VAE decode)

## 修改模式
- 管线优化: 关注 step cache（减少重复计算）和 VAE decode 延迟占比
