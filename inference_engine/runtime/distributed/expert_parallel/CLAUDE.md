# distributed/expert_parallel — 专家并行

Elastic EP 支持动态 expert 放置。

## 依赖关系
- **上游:** `parallel_state.py`; `layers/moe/router.py` — 路由结果
- **下游:** `device_communicators/` — all-to-all 通信

## 修改模式
- 与 `layers/moe/` 联动: 确保分布式路由一致性
- 动态放置变更须验证负载均衡
