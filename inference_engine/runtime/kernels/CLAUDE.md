# kernels — 自定义算子

`cuda/` 放原生 CUDA kernel，`triton/` 放 Triton kernel。

## 依赖关系
- **上游:** `layers/*` — 封装调用 kernel
- **下游:** 无（最底层）

## 接口契约
- 所有 kernel 变更须附带 benchmark 对比
- 优先 Triton，除非有明确性能需求才用 CUDA

## 修改模式
- 新增 kernel: 先写 Triton 版本，性能不够再写 CUDA
- 修改: 注意 warp divergence, bank conflict, 不必要的 sync
