# layers — 计算层

`attention/` 是性能热点，占 forward 时间主要部分。

## 依赖关系
- **上游:** `models/*` — 调用各计算层
- **下游:** `kernels/*` — 底层算子实现

## 接口契约
- 所有 layer 须同时支持 eager 和 CUDA Graph（不可有动态控制流）
- `attention/base_attn_backend.py` 定义注意力后端统一接口

## 修改模式
- 性能优化优先 `attention/`
- 新增 kernel 调用: 先在 `kernels/` 实现，再在此封装
- 修改已有层: 验证不破坏 CUDA Graph capture
