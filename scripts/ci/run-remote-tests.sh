#!/bin/bash
# 远程测试执行脚本模板
# 迁移时替换具体命令
set -euo pipefail

# --- 配置（由 ci-test skill 通过环境变量传入）---
HOST="${CI_HOST:?CI_HOST not set}"
USER="${CI_USER:?CI_USER not set}"
WORK_DIR="${CI_WORK_DIR:?CI_WORK_DIR not set}"
TEST_SUITE="${1:-standard}"  # quick | standard | full | perf_only
TIMEOUT="${CI_TIMEOUT:-1800}"

echo "=== Remote Test Execution ==="
echo "Host: ${HOST}"
echo "Suite: ${TEST_SUITE}"
echo "Timeout: ${TIMEOUT}s"

# --- Step 1: 同步代码 ---
echo "[1/4] Syncing code..."
rsync -avz --exclude='.git' --exclude='__pycache__' --exclude='results/' \
  ./ "${USER}@${HOST}:${WORK_DIR}/" 2>&1 | tail -3

# --- Step 2: 环境准备 ---
echo "[2/4] Setting up environment..."
ssh "${USER}@${HOST}" "cd ${WORK_DIR} && \
  # TODO: 替换为实际的环境初始化命令
  # conda activate inference && \
  # pip install -e . --quiet && \
  echo 'Environment ready'"

# --- Step 3: 执行测试 ---
echo "[3/4] Running test suite: ${TEST_SUITE}..."
ssh "${USER}@${HOST}" "cd ${WORK_DIR} && \
  timeout ${TIMEOUT} bash -c '
    # TODO: 替换为实际的测试命令
    # case ${TEST_SUITE} in
    #   quick)    pytest tests/test_api/ -x --timeout=30 ;;
    #   standard) pytest tests/ -v --timeout=120 -k \"not e2e\" ;;
    #   full)     pytest tests/ -v --timeout=300 ;;
    #   perf_only) python benchmarks/run_benchmark.py --output results/benchmark.json ;;
    # esac
    echo \"Tests passed (placeholder)\"
  ' 2>&1"
TEST_EXIT=$?

# --- Step 4: 收集结果 ---
echo "[4/4] Collecting results..."
rsync -avz "${USER}@${HOST}:${WORK_DIR}/results/" ./results/ 2>/dev/null || true

exit ${TEST_EXIT}
