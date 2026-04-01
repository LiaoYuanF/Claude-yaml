# Scripts 脚本工具

部署、profiling、验证工具。

## 代表文件

| 文件 | 用途 |
|------|------|
| `deploy/launch_server.sh` | 启动推理服务 |
| `profiling/memory_snapshot.py` | GPU 显存快照分析 |
| `tools/validate_inference.py` | 推理正确性验证（对比 baseline） |

## 注意

`deploy/` 下的脚本直接影响生产环境，修改须经确认。
