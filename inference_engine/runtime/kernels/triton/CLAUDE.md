# kernels/triton — Triton Kernels

`fused_moe_kernel.py` 是代表性 kernel。

## 修改模式
- 调优参数: BLOCK_SIZE, num_warps, num_stages
- 使用 triton.testing.do_bench 做 micro-benchmark
