---
name: deploy
description: >
  Use when the user asks to "deploy", "push to cluster", "launch server",
  "start serving", or mentions deploying the inference service to GPU cluster.
user-invocable: true
disable-model-invocation: true
allowed-tools: [Read, Bash, Grep]
---

# 部署: $ARGUMENTS

## 当前状态
- 分支: !`git branch --show-current`
- 未提交变更: !`git status --short | head -5`

## Step 1: 预检

1. 确认目标集群信息（参考 `docs/claude/cluster-config.yaml.md`）
2. 确认部署的模型和 serving 配置
3. 检查集群 GPU 可用状态

## Step 2: 同步代码

```bash
rsync -avz --exclude='.git' --exclude='__pycache__' \
  ./ ${USER}@${HOST}:${WORK_DIR}/
```

## Step 3: 启动服务

```bash
ssh ${HOST} "cd ${WORK_DIR} && bash scripts/deploy/launch_server.sh \
  --config configs/serving_configs/${CONFIG}.yaml \
  --model-config configs/model_configs/${MODEL}.yaml"
```

## Step 4: 健康检查

```bash
# 等待服务就绪
ssh ${HOST} "curl -s http://localhost:8000/health | jq ."

# 发送测试请求
ssh ${HOST} "curl -s http://localhost:8000/v1/chat/completions \
  -H 'Content-Type: application/json' \
  -d '{\"model\": \"${MODEL}\", \"messages\": [{\"role\": \"user\", \"content\": \"hello\"}]}' | jq .choices[0]"
```

## Step 5: 报告

汇报部署状态：服务地址、GPU 占用、首次请求延迟。
