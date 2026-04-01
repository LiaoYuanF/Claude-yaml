# constrained — 受限解码

`grammar_manager.py` 支持 JSON schema 等结构化输出。

## 依赖关系
- **上游:** `api/` — 传入 grammar/schema 约束
- **下游:** `sampling/` — 在采样时应用约束

## 修改模式
- 新增约束类型: 实现 grammar backend 接口
- 性能: 约束检查不能阻塞 GPU 计算
