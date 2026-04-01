# distributed — 分布式推理

`parallel_state.py` 管理进程组。子策略: `tensor_parallel/`, `pipeline_parallel/`, `expert_parallel/`。

## 依赖关系
- **上游:** 启动配置（TP/PP/EP size）
- **下游:** `layers/*` — 注入并行切分; `device_communicators/` — 底层通信

## 接口契约
- `parallel_state.py` 的 process group 变更影响所有并行策略
- 通信开销是主要瓶颈，变更须在多卡环境验证

## 修改模式
- 新增并行策略: 在对应子目录实现，注册到 `parallel_state.py`
- 修改通信算子: 必须在多卡 (≥2) 环境测试
