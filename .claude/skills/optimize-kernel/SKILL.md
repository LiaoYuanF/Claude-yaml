---
name: optimize-kernel
description: >
  Use when the user asks to "optimize a kernel", "speed up", "improve performance of",
  mentions CUDA/Triton kernel tuning, warp divergence, bank conflict, memory bandwidth,
  or says "make this faster".
user-invocable: true
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash]
---

# 优化 Kernel: $ARGUMENTS

## Step 1: Profile — 定位瓶颈

1. 读取目标 kernel 源码（`inference_engine/runtime/kernels/`）
2. 分析计算强度：compute-bound vs memory-bound
3. 检查已知问题：warp divergence, bank conflict, 不必要的 sync

## Step 2: Baseline — 采集基线

在优化前运行 benchmark，记录当前性能数据。

## Step 3: Implement — 实施优化

常见优化路径：
- **Memory-bound kernel**: 减少全局内存访问，增加数据复用
- **Compute-bound kernel**: 提高指令级并行，优化 warp 利用率
- **Triton kernel**: 调整 BLOCK_SIZE, num_warps, num_stages

修改时注意：
- 保持与 `base_attn_backend.py` 等接口的兼容性
- CUDA graph 兼容性（不能有动态 shape 依赖）

## Step 4: Verify — 正确性验证

运行对应的 kernel 测试（`tests/test_kernels/`），确保数值精度无退化。

## Step 5: Benchmark — 性能对比

运行 `/benchmark` 对比优化前后的性能数据。
