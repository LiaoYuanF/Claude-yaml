# gRPC 服务端

提供低延迟的内部服务间通信接口，用于微服务架构下的推理调用。

## 依赖关系
- **上游:** `runtime/managers/io_struct.py`（数据结构）、protobuf 定义文件
- **下游:** 内部微服务调用方（非面向终端用户）

## 接口契约
- `.proto` 文件变更后须重新生成 Python stub 并同步更新序列化逻辑
- 请求/响应字段须与 `io_struct.py` 保持语义一致
- gRPC 接口变更属于内部协议变更，需通知所有调用方服务

## 修改模式
- 新增 RPC 方法：修改 `.proto` → 重新生成代码 → 实现 servicer 方法
- 调试连接问题：检查端口配置、TLS 设置、protobuf 版本兼容性
- 性能调优：关注流式 RPC 的 backpressure 和连接池配置
