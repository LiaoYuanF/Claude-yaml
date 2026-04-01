# layers/rotary_embedding — 旋转位置编码

`rope.py` 实现标准 RoPE 及变体 (YaRN, NTK-aware)。

## 依赖关系
- **上游:** `models/llm/*`
- **下游:** `kernels/`（可选融合 kernel）

## 修改模式
- 新增变体: 在 `rope.py` 添加，通过配置切换
- RoPE 计算量小，优先考虑与 attention 融合
