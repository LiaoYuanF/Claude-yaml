# Runtime — 推理运行时核心

热路径: `managers/` → `model_executor/` → `layers/` → `kernels/`

## 依赖关系
- **上游:** `api/entrypoints` — 创建引擎实例、提交请求
- **下游:** 无（Runtime 是最底层执行单元）

## 接口契约
- `managers/io_struct.py` — API 与 Runtime 的边界数据结构
- `layers/attention/base_attn_backend.py` — 注意力后端统一接口
- `distributed/parallel_state.py` — 进程组全局状态

## 修改模式
- 所有热路径变更必须评估: P99 延迟、吞吐量、显存峰值
- 新增模型: 从 `models/` 入手，参考 `llama.py`
- 新增算子: 先在 `kernels/` 实现，再在 `layers/` 封装
- 显存相关: 必须与 `mem_cache/` 协调
