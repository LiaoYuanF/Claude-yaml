# Benchmarks 性能基准

## 入口

`run_benchmark.py` 是统一入口，支持 `--model`, `--batch-sizes`, `--output` 参数。

## 核心指标

| 指标 | 单位 | 回归阈值 |
|------|------|---------|
| Throughput | tokens/s, images/s | ≥ baseline x 0.95 |
| Latency P50/P99 | ms | ≤ baseline x 1.05 |
| GPU Memory Peak | GB | ≤ baseline x 1.10 |
| TTFT | ms | ≤ baseline x 1.05 |
