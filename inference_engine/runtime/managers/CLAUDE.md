# managers — 调度核心

`scheduler.py` 是全系统性能最关键的组件。每个 step 调用一次，目标 overhead <1ms。

## 依赖关系
- **上游:** `api/entrypoints` — 创建 Scheduler、提交请求
- **下游:** `model_executor` — 消费 ScheduleBatch; `mem_cache` — KV cache 分配

## 接口契约
- `io_struct.py` 是 API/Runtime 边界 — 修改字段须同步 `api/openai/protocol.py`
- `scheduler.py` 返回的 batch 格式变更须同步 `model_executor/model_runner.py`
- `schedule_policy.py` 变更须用真实负载跑 benchmark

## 修改模式
- 调度策略调优: 修改 `schedule_policy.py`，benchmark 验证吞吐
- 请求数据结构: 修改 `io_struct.py`，全文搜索所有消费方
