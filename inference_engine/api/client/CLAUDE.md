# 客户端 SDK

提供 Python 客户端封装，简化与推理引擎的 HTTP/gRPC 交互。

## 依赖关系
- **上游:** `openai/protocol.py`（请求/响应类型定义）、`entrypoints/`（服务地址）
- **下游:** 用户应用代码、测试脚本、benchmark 工具

## 关键文件
- `http_client.py` — HTTP 客户端的代表性实现，封装请求构造和流式解析

## 接口契约
- 客户端接口须与服务端 API 保持同步，protocol 变更时需同步更新
- 流式响应解析逻辑须与服务端 SSE 格式一致
- 错误码和异常类型应与服务端响应对齐

## 修改模式
- 新增 API 支持：参考 `http_client.py` 已有方法，添加对应的请求封装
- 调试连接问题：检查 base_url、超时设置、重试策略
- 测试时可直接实例化 client 对服务端做端到端验证
