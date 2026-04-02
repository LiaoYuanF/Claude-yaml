# CI 配置

测试环境和测试矩阵的配置模板。迁移到实际项目时替换空值。

## 文件

| 文件 | 用途 | 迁移时需填入 |
|------|------|-------------|
| `test-env.yaml` | 测试环境连接信息、超时、重试策略 | host, user, ssh_key, setup_commands |
| `test-matrix.yaml` | 测试分组、命令、通过标准 | 各 group 的 commands, pass_criteria |

## 测试级别

| 级别 | 环境 | 用途 |
|------|------|------|
| smoke | 本地 | import 检查，基本功能 |
| unit | 本地 | 不依赖 GPU 的单元测试 |
| integration | 远程 GPU | 模型推理正确性、kernel 测试 |
| e2e | 远程 GPU | 启动完整服务、发送请求验证 |
| performance | 远程 GPU | 性能基准对比 baseline |

## 预设

- `quick`: smoke + unit（本地快速验证）
- `standard`: smoke + unit + integration（常规 CI）
- `full`: 全部 5 级（发布前完整验证）

## 依赖关系

- **上游:** `/ci-test` skill 读取这些配置
- **下游:** `scripts/ci/` 中的脚本按配置执行
