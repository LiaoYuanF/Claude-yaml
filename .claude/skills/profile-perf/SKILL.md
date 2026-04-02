---
name: profile-perf
description: >
  Use when the user asks to "profile performance", "run profiling",
  "analyze bottleneck", "generate perf report", "memory profiling",
  or wants GPU/CPU/memory profiling data collected from the test cluster.
  Also triggered by: "性能分析", "profiling", "产出性能报告".
user-invocable: true
disable-model-invocation: true
allowed-tools: [Read, Grep, Bash, Write]
argument-hint: "[model-name] [--tools torch_profiler,memory_snapshot,nsight] [--compare baseline.json]"
---

# 性能 Profiling: $ARGUMENTS

## 配置
- 测试环境: `configs/ci/test-env.yaml`
- Profiling 配置: test-env.yaml 的 `profiling` 段

## 当前状态
- 分支: !`git branch --show-current`
- 最近提交: !`git log -1 --oneline`

---

## Step 1: 准备

1. 读取 `configs/ci/test-env.yaml` 的 profiling 配置
2. 确认远程环境可达，GPU 可用
3. 同步最新代码到远程

```bash
export CI_HOST="<from test-env.yaml>"
export CI_USER="<from test-env.yaml>"
export CI_WORK_DIR="<from test-env.yaml>"

# GPU 状态
ssh "${CI_USER}@${CI_HOST}" "nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv"
```

## Step 2: 运行 Profiling

按 test-env.yaml 中启用的 profiling tools 逐项执行：

### 2.1 torch.profiler
```bash
ssh "${CI_USER}@${CI_HOST}" "cd ${CI_WORK_DIR} && \
  # TODO: 替换为实际命令
  # python -c '
  # from torch.profiler import profile, ProfilerActivity, schedule
  # with profile(
  #     activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA],
  #     schedule=schedule(wait=1, warmup=3, active=10),
  #     record_shapes=True, profile_memory=True, with_stack=True
  # ) as prof:
  #     for step in range(14):
  #         run_inference_step()
  #         prof.step()
  # print(prof.key_averages().table(sort_by=\"cuda_time_total\", row_limit=30))
  # prof.export_chrome_trace(\"results/profiling/trace.json\")
  # '
  echo 'torch.profiler placeholder'"
```

### 2.2 Memory Snapshot
```bash
ssh "${CI_USER}@${CI_HOST}" "cd ${CI_WORK_DIR} && \
  # TODO: 替换为实际命令
  # python scripts/profiling/memory_snapshot.py \
  #   --output results/profiling/memory_snapshot.json
  echo 'memory snapshot placeholder'"
```

### 2.3 Benchmark (对比基线)
```bash
ssh "${CI_USER}@${CI_HOST}" "cd ${CI_WORK_DIR} && \
  # TODO: 替换为实际命令
  # python benchmarks/run_benchmark.py \
  #   --model ${MODEL} \
  #   --batch-sizes 1,4,8,16,32 \
  #   --output results/profiling/benchmark.json
  echo 'benchmark placeholder'"
```

## Step 3: 收集数据

```bash
mkdir -p results/profiling
rsync -avz "${CI_USER}@${CI_HOST}:${CI_WORK_DIR}/results/profiling/" \
  ./results/profiling/ 2>/dev/null || true
```

## Step 4: 分析

读取收集到的 profiling 数据，分析：

1. **GPU 算子耗时 Top-10**（from torch.profiler trace）
2. **显存峰值和分配热点**（from memory snapshot）
3. **吞吐/延迟/显存三指标**（from benchmark）
4. 如果有 baseline 对比文件，计算各指标变化率

## Step 5: 产出报告

将分析结果写入 `results/profiling/report.md`：

```markdown
## 性能 Profiling 报告

- **时间:** YYYY-MM-DD HH:MM
- **分支:** <branch> (<commit>)
- **GPU:** <gpu name> x <count>
- **模型:** <model name>

### GPU 算子耗时 Top-10

| 算子 | 调用次数 | CUDA 总时间 | 占比 |
|------|---------|------------|------|
| ... | | | |

### 显存分析

- 峰值: X.XX GB / Y GB (XX%)
- 主要分配:
  - KV Cache: X.XX GB
  - Model Weights: X.XX GB
  - Activations: X.XX GB

### 性能指标

| 指标 | 当前值 | Baseline | 变化 | 判定 |
|------|--------|----------|------|------|
| Throughput (tok/s) | | | | |
| Latency P50 (ms) | | | | |
| Latency P99 (ms) | | | | |
| Memory Peak (GB) | | | | |
| TTFT (ms) | | | | |

### 瓶颈分析

[基于以上数据，分析主要瓶颈：compute-bound / memory-bound / communication-bound]

### 优化建议

[给出 1-3 条具体可执行的优化建议，关联到具体文件/函数]
```
