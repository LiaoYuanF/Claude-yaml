# 远程验证流程（Phase 4: Verifier 详细规范）

> 本文档定义了 Agent Team Protocol 中 Phase 4 的远程验证执行细节。

## 前置条件

- Claude Code 已配置 MCP SSH Server（见下方「MCP 配置」节）
- 集群连接信息见 `cluster-config.yaml.md`

## 验证流程

### Step 1: 代码同步

```bash
# 将本地变更同步到远程集群
rsync -avz --exclude='.git' --exclude='__pycache__' \
  ${LOCAL_PROJECT_DIR}/ ${USER}@${HOST}:${WORK_DIR}/
```

或通过 git：
```bash
# 本地推送到远程分支，远程 pull
ssh ${USER}@${HOST} "cd ${WORK_DIR} && git pull origin ${BRANCH}"
```

### Step 2: 环境准备

```bash
ssh ${USER}@${HOST} << 'EOF'
  cd ${WORK_DIR}
  conda activate ${CONDA_ENV}
  pip install -e . 2>&1 | tail -5  # 仅展示最后几行，减少噪声
EOF
```

### Step 3: 测试执行

```bash
# 单元测试
ssh ${USER}@${HOST} "cd ${WORK_DIR} && conda activate ${CONDA_ENV} && pytest tests/ -v --tb=short 2>&1"

# 推理正确性验证
ssh ${USER}@${HOST} "cd ${WORK_DIR} && conda activate ${CONDA_ENV} && python scripts/validate_inference.py --config config/test.yaml 2>&1"
```

### Step 4: 性能基准测试

```bash
# benchmark 脚本（按项目实际修改）
ssh ${USER}@${HOST} << 'EOF'
  cd ${WORK_DIR}
  conda activate ${CONDA_ENV}
  
  # 记录 GPU 状态
  nvidia-smi --query-gpu=name,memory.total,memory.free --format=csv
  
  # 运行 benchmark
  python benchmarks/run_benchmark.py \
    --model ${MODEL_NAME} \
    --batch-sizes 1,4,8,16,32 \
    --output results/benchmark_$(date +%Y%m%d_%H%M%S).json \
    2>&1
EOF
```

### Step 5: 结果回收

```bash
# 拉取 benchmark 结果到本地
rsync -avz ${USER}@${HOST}:${WORK_DIR}/results/ ./results/

# 或直接 cat 远程结果
ssh ${USER}@${HOST} "cat ${WORK_DIR}/results/latest_benchmark.json"
```

### Step 6: 清理

```bash
# 如果是临时验证，清理远程环境
ssh ${USER}@${HOST} "cd ${WORK_DIR} && git checkout . && git clean -fd"
```

## 验证通过标准

| 检查项 | 通过条件 |
|--------|----------|
| 单元测试 | 全部通过，无 skip 增加 |
| 推理正确性 | 输出与 baseline diff < 容忍阈值 |
| 延迟 P99 | 不高于 baseline 的 105% |
| 吞吐 | 不低于 baseline 的 95% |
| 显存峰值 | 不高于 baseline 的 110% |

## MCP 配置

在 Claude Code 的 settings 中添加 MCP SSH server，使 Verifier 可直接调用远程执行工具：

```json
// ~/.claude/settings.json 或项目 .claude/settings.json
{
  "mcpServers": {
    "ssh": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-ssh"],
      "env": {
        "SSH_CONFIG_PATH": "~/.ssh/config"
      }
    }
  }
}
```

> **注意：** MCP SSH server 的具体包名和配置以实际可用的实现为准。  
> 社区方案参考：`mcp-server-ssh`、`@anthropic/mcp-ssh` 等，选择维护活跃的即可。  
> 如果没有满意的现成方案，也可以自建一个轻量 MCP server（本质上是包装 `ssh` 命令为 JSON-RPC tool）。

## Fallback: 无 MCP 时的替代方案

如果未配置 MCP SSH server，Verifier 退化为通过 Bash 工具执行 `ssh` 命令：

```markdown
## Phase 4 补充指令（写入项目 CLAUDE.md）

验证阶段需要在远程 GPU 集群执行。通过 Bash 工具运行 ssh 命令：
- 集群地址：参见 cluster-config
- 所有远程命令必须 `set -e`，失败立即停止
- 长任务加 timeout 防止挂起：`timeout 600 python benchmark.py`
- 每步执行后汇报输出摘要，不要沉默执行
```
