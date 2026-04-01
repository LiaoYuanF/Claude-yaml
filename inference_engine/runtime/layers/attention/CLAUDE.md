# layers/attention — 注意力计算 (性能热点)

`base_attn_backend.py` 定义接口，`flashinfer_backend.py` 是主要实现。

## 依赖关系
- **上游:** `models/*` — 所有模型的注意力层
- **下游:** `kernels/triton` — Triton kernel; FlashInfer 外部库

## 接口契约
- 新增后端须实现 `base_attn_backend.py` 完整接口
- KV cache layout 变更影响 `mem_cache/memory_pool.py`
- 性能目标: HBM 带宽利用率 ≥80% 理论峰值

## 修改模式
- 修改 `flashinfer_backend.py`: 必须 A/B benchmark（prefill + decode 分别测）
- `triton_ops/` 修改须附带 benchmark 结果
- 注意 GQA/MQA 变体兼容性
