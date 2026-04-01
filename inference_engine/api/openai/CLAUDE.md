# OpenAI 兼容 API

实现 OpenAI Chat/Completions API 协议，是外部用户的主要交互接口。

## 依赖关系
- **上游:** `runtime/managers/io_struct.py`（内部数据结构）、`chat_template/`（消息格式化）
- **下游:** 外部 OpenAI 兼容客户端（openai-python 等）

## 关键文件
- `protocol.py` — 定义请求/响应的 Pydantic 模型，是 OpenAI 兼容性的核心
- `serving_chat.py` — Chat Completions 处理器，代表性 handler 实现

## 接口契约
- `protocol.py` 的字段名和类型必须与 OpenAI API 规范一致
- 流式响应须遵循 SSE `data: [DONE]` 协议
- 新增字段时需同步更新 `io_struct.py` 的转换逻辑

## 修改模式
- 新增 API 参数：`protocol.py` 添加字段 → handler 中读取 → 转换为 io_struct 传入 runtime
- 参考 `serving_chat.py` 作为实现新 handler 的模板
- 兼容性验证：用 `openai` Python SDK 发送标准请求测试
