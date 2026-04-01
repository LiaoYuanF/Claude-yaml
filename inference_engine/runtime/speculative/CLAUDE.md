# speculative — 投机解码

`eagle_worker.py` 实现 EAGLE 投机解码。

## 依赖关系
- **上游:** `managers/scheduler` — 调度投机请求
- **下游:** `model_executor` — draft + verify forward

## 接口契约
- acceptance rate 目标 >70%
- 投机长度变更影响 `mem_cache` 的 KV cache 预分配

## 修改模式
- 调优: 关注 acceptance rate vs overhead 的权衡
- 新增投机策略: 实现 worker 接口，通过配置切换
