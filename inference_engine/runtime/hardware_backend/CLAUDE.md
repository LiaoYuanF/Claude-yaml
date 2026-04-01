# hardware_backend — 硬件抽象

隔离 CUDA/ROCm 差异。

## 依赖关系
- **上游:** `kernels/*`, `distributed/*` — 使用硬件抽象
- **下游:** CUDA/ROCm 驱动

## 修改模式
- 新增硬件后端: 在对应子目录实现，注册到抽象层
