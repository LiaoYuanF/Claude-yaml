# sampling — 采样策略

`sampling_params.py` 定义所有采样参数 (top-k, top-p, temperature, penalties)。

## 依赖关系
- **上游:** `api/openai/protocol.py` — API 层传入采样参数
- **下游:** `model_executor` — 执行采样

## 修改模式
- 新增采样参数: 同步更新 `api/openai/protocol.py` 和 `managers/io_struct.py`
- 采样策略变更须验证生成质量
