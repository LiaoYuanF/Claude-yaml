# multimodal/processors — 图像预处理

`base_processor.py` 定义预处理接口。

## 依赖关系
- **上游:** API 层（原始图像数据）
- **下游:** `models/vision/` — 消费预处理后的 tensor

## 修改模式
- 新增预处理器: 实现 `base_processor.py` 接口
- 分辨率/格式变更须同步 `models/vision/`
