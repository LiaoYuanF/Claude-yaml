# distributed/device_communicators — 设备通信

`pynccl.py` 封装 NCCL 操作。

## 依赖关系
- **上游:** 所有并行策略（TP/PP/EP）
- **下游:** NCCL 库

## 修改模式
- 通信算子变更: 必须多卡测试
- 注意 NCCL 版本兼容性
