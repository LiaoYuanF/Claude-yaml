# observability — 可观测性

`metrics_collector.py` 导出 Prometheus 指标。

## 依赖关系
- **上游:** 各模块（注册指标）
- **下游:** 监控系统 (Prometheus/Grafana)

## 接口契约
- 新增指标不能引入热路径开销（避免 atomic、避免锁）
- 指标命名遵循 Prometheus 规范

## 修改模式
- 新增指标: 在对应模块注册，此处汇总导出
- 性能: 热路径用 counter，冷路径可用 histogram
