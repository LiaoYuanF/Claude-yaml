# API 前端层

负责 HTTP/gRPC 协议处理、请求解析、对话模板渲染。不涉及 GPU 操作。

## 依赖关系
- **上游:** `runtime/managers/io_struct.py` — 请求/响应数据结构的唯一定义
- **下游:** 外部客户端（OpenAI 兼容 SDK、gRPC 调用方、自有 client SDK）

## 接口契约
- 所有 API 变更须保持 **OpenAI API 兼容性**（路径、字段名、流式协议）
- 修改 `io_struct.py` 中的字段需同步更新 `openai/protocol.py` 的映射逻辑
- 新增 API 端点须在 `entrypoints/http_server.py` 注册路由

## 修改模式
- 添加新 API：先在 `openai/protocol.py` 定义类型 → 在对应 handler 实现 → 在 `entrypoints/` 注册
- 调试请求流：入口在 `entrypoints/http_server.py`，沿 handler → io_struct 转换链追踪
- 模板问题：定位到 `chat_template/`，与模型配置文件对照排查
