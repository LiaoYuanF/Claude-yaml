---
name: debug-perf
description: 性能问题排查流程
user_invocable: true
---

# 性能排查: $ARGUMENTS

跳过 Plan 阶段，直入 Scout + 诊断。

## Step 1: 复现 — 确认症状

1. 确认具体指标的退化情况（延迟? 吞吐? 显存?）
2. 确认退化的时间点或触发条件
3. 如有 commit hash，通过 `git log` 定位可疑变更

## Step 2: 定位 — 缩小范围

按热路径逐层排查：

```
managers/scheduler → model_executor/model_runner → layers/* → kernels/*
                                                 ↕
                                            mem_cache/*
```

排查工具：
- `scripts/profiling/memory_snapshot.py` — 显存分析
- `torch.profiler` — 算子级别耗时
- `nvidia-smi dmon` — GPU 利用率监控

## Step 3: 分析 — 常见原因

| 症状 | 常见原因 | 排查方向 |
|------|---------|---------|
| P99 延迟突增 | 调度策略退化 / 不必要的 sync | `managers/schedule_policy.py` |
| 吞吐下降 | batch 填充率低 / kernel 退化 | `managers/scheduler.py`, `kernels/` |
| 显存溢出 | KV cache 泄漏 / 未释放临时 tensor | `mem_cache/memory_pool.py` |
| TTFT 退化 | prefill attention 慢 / 模型加载慢 | `layers/attention/`, `model_loader/` |
| GPU 利用率低 | CPU 瓶颈 / 通信等待 | `distributed/`, tokenizer |

## Step 4: 修复并验证

修复后运行 `/benchmark` 确认指标恢复。
