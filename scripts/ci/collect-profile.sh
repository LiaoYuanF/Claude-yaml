#!/bin/bash
# 远程 profiling 数据收集脚本模板
# 迁移时替换具体 profiling 命令
set -euo pipefail

HOST="${CI_HOST:?CI_HOST not set}"
USER="${CI_USER:?CI_USER not set}"
WORK_DIR="${CI_WORK_DIR:?CI_WORK_DIR not set}"
OUTPUT_DIR="${1:-results/profiling}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "=== Performance Profiling ==="
echo "Host: ${HOST}"
echo "Output: ${OUTPUT_DIR}/${TIMESTAMP}/"

# --- Step 1: GPU 状态快照 ---
echo "[1/5] GPU status..."
ssh "${USER}@${HOST}" "nvidia-smi --query-gpu=name,memory.total,memory.free,utilization.gpu --format=csv" 2>/dev/null || echo "nvidia-smi unavailable"

# --- Step 2: torch.profiler ---
echo "[2/5] Running torch.profiler..."
ssh "${USER}@${HOST}" "cd ${WORK_DIR} && \
  # TODO: 替换为实际的 profiling 命令
  # python -c '
  # import torch
  # from torch.profiler import profile, ProfilerActivity
  # with profile(activities=[ProfilerActivity.CPU, ProfilerActivity.CUDA],
  #              schedule=torch.profiler.schedule(wait=1, warmup=3, active=10),
  #              on_trace_ready=torch.profiler.tensorboard_trace_handler(\"${OUTPUT_DIR}/${TIMESTAMP}/torch_trace\"),
  #              record_shapes=True, profile_memory=True, with_stack=True) as prof:
  #     # run inference steps here
  #     pass
  # print(prof.key_averages().table(sort_by=\"cuda_time_total\", row_limit=20))
  # '
  echo 'torch.profiler placeholder'"

# --- Step 3: 显存快照 ---
echo "[3/5] Memory snapshot..."
ssh "${USER}@${HOST}" "cd ${WORK_DIR} && \
  # TODO: 替换为实际命令
  # python scripts/profiling/memory_snapshot.py --output ${OUTPUT_DIR}/${TIMESTAMP}/memory_snapshot.json
  echo 'Memory snapshot placeholder'"

# --- Step 4: Benchmark ---
echo "[4/5] Running benchmark..."
ssh "${USER}@${HOST}" "cd ${WORK_DIR} && \
  # TODO: 替换为实际命令
  # python benchmarks/run_benchmark.py \
  #   --batch-sizes 1,4,8,16,32 \
  #   --output ${OUTPUT_DIR}/${TIMESTAMP}/benchmark.json
  echo 'Benchmark placeholder'"

# --- Step 5: 收集结果 ---
echo "[5/5] Collecting profiling data..."
mkdir -p "${OUTPUT_DIR}/${TIMESTAMP}"
rsync -avz "${USER}@${HOST}:${WORK_DIR}/${OUTPUT_DIR}/${TIMESTAMP}/" \
  "./${OUTPUT_DIR}/${TIMESTAMP}/" 2>/dev/null || true

echo "=== Profiling complete ==="
echo "Results: ${OUTPUT_DIR}/${TIMESTAMP}/"
