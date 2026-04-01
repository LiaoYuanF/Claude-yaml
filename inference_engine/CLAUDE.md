# inference_engine 主包

前端 API 层 (`api/`) 和后端运行时层 (`runtime/`) 的顶层包。

## 模块职责

| 层 | 职责 | 不做什么 |
|---|------|---------|
| `api/` | HTTP/gRPC 协议、请求解析、对话模板 | 不接触 GPU、不管理内存 |
| `runtime/` | 调度、执行、内存、分布式 | 不处理协议细节 |

## 层间通信

`api/` 通过 `runtime/managers/io_struct.py` 定义的数据结构与 `runtime/` 通信。
这是两层之间唯一的接口契约文件——修改它需要两层同步更新。
