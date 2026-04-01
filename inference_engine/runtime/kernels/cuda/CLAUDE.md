# kernels/cuda — CUDA Kernels

`fused_add_rmsnorm.cu` 是代表性 kernel。

## 修改模式
- 关注 warp divergence 和 shared memory bank conflict
- 修改后必须附带 nsight 分析或 benchmark 数据
