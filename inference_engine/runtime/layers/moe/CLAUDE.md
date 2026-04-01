# layers/moe — Mixture of Experts

`router.py` 处理路由，`fused_moe.py` 是性能关键融合 kernel。

## 依赖关系
- **上游:** MoE 模型 (`models/llm/deepseek_v2.py` 等)
- **下游:** `kernels/triton/fused_moe_kernel.py`

## 接口契约
- router 输出格式须与 `fused_moe.py` 输入一致
- expert 数量变更影响 `distributed/expert_parallel/`

## 修改模式
- `fused_moe.py` 修改: 用不同 expert 数和 token 数做 benchmark
- 路由策略: 关注负载均衡，避免 expert 过载
