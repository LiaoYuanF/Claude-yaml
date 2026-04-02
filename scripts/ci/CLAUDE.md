# CI 脚本

远程测试执行和 profiling 数据收集的脚本模板。

## 文件

| 脚本 | 用途 | 环境变量 |
|------|------|---------|
| `run-remote-tests.sh` | SSH 到远程集群执行测试套件 | CI_HOST, CI_USER, CI_WORK_DIR |
| `collect-profile.sh` | SSH 到远程集群运行 profiling 并收集结果 | CI_HOST, CI_USER, CI_WORK_DIR |

## 依赖关系

- **上游:** `/ci-test` 和 `/profile-perf` skill 调用这些脚本
- **下游:** `configs/ci/test-env.yaml` 提供连接配置

## 迁移须知

脚本中 `# TODO:` 标注的位置需替换为实际命令。环境变量由调用方（skill 中的 Bash 命令）设置。
