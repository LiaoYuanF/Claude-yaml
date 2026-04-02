---
name: benchmark
description: >
  Use when the user asks to "run benchmark", "compare performance", "check regression",
  mentions throughput/latency/memory testing, or says "bench", "perf test".
  Also triggered after kernel optimization or model changes that may affect performance.
user-invocable: true
disable-model-invocation: true
allowed-tools: [Read, Bash, Grep]
---

# 运行 Benchmark: $ARGUMENTS

## 当前状态
- 分支: !`git branch --show-current`
- 最近提交: !`git log -1 --oneline`

## Step 1: 确认测试目标

确认要测试的内容：
- 模型名称 / 变更的模块
- 对比的 baseline（上一次的结果 JSON 或 commit hash）

## Step 2: 准备环境

1. 同步代码到远程 GPU 集群（参考 `docs/claude/remote-verification-workflow.md` Step 1）
2. 确认 GPU 状态: `nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv`

## Step 3: 运行 Benchmark

```bash
ssh ${HOST} "cd ${WORK_DIR} && python benchmarks/run_benchmark.py \
  --model ${MODEL} \
  --batch-sizes 1,4,8,16,32 \
  --output results/benchmark_$(date +%Y%m%d_%H%M%S).json"
```

## Step 4: 对比结果

对比核心指标（阈值定义在 `benchmarks/CLAUDE.md`）：

| 指标 | 通过条件 |
|------|---------|
| Throughput | ≥ baseline x 0.95 |
| Latency P99 | ≤ baseline x 1.05 |
| Memory Peak | ≤ baseline x 1.10 |

## Step 5: 报告

汇总对比结果，标注 PASS/FAIL/WARN。如有回归，定位到具体变更的模块。
