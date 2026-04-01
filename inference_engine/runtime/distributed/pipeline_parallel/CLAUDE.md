# distributed/pipeline_parallel — 流水线并行

## 依赖关系
- **上游:** `parallel_state.py` — stage 划分
- **下游:** `model_executor` — 跨 stage 调度

## 修改模式
- 关注 bubble ratio，目标 <10%
- schedule 策略变更须验证端到端吞吐
