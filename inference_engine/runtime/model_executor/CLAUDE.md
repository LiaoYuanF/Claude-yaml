# model_executor — 模型前向执行

`model_runner.py` 执行 forward pass，`cuda_graph_runner.py` 捕获/重放 CUDA Graph。

## 依赖关系
- **上游:** `managers/scheduler` — 提供 ScheduleBatch
- **下游:** `layers/*` — 调用计算层; `models/*` — 加载模型定义

## 接口契约
- `model_runner.py` 的 `forward()` 签名变更须同步 scheduler 调用
- CUDA Graph 依赖固定 tensor shape — 动态 shape 需更新 capture 逻辑
- 新增 model feature 须确保 eager 和 CUDA Graph 两种模式均通过

## 修改模式
- 修改 forward 路径: 必须同时验证 eager 和 CUDA Graph
- 性能优化: 减少 CPU-GPU 同步点和 kernel launch 开销
