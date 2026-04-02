# 自动生成文档

此目录存放由 agent 或脚本自动生成的文档。不要手动编辑——下次生成会覆盖。

## 生成来源

| 文件 | 生成方式 | 触发时机 |
|------|---------|---------|
| `dependency-graph.md` | `/gardening` skill 分析 import 关系 | 定期 |
| `api-schema.md` | 从 protocol.py 提取 | API 变更时 |
| `model-registry.md` | 从 models/__init__.py 提取 | 模型变更时 |

<!-- 生成的文档放在此目录下 -->
