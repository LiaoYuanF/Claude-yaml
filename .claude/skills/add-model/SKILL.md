---
name: add-model
description: >
  Use when the user asks to "add a model", "support a new model", "implement model X",
  mentions adding LLM/vision/diffusion model support, or says "new model".
user-invocable: true
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash]
---

# 新增模型: $ARGUMENTS

按以下步骤执行。每步完成后用 TaskUpdate 标记进度。

## 当前已注册模型
!`grep -r "class.*Module" inference_engine/runtime/models/ --include="*.py" -l 2>/dev/null || echo "暂无已注册模型"`

## Step 1: Scout — 理解参考实现

读取参考模型文件，理解标准接口：
- LLM 模型参考: `inference_engine/runtime/models/llm/llama.py`
- Vision 模型参考: `inference_engine/runtime/models/vision/clip.py`
- Diffusion 模型参考: `inference_engine/runtime/models/diffusion/flux.py`

关注：`__init__` 签名、`forward` 签名、weight loading pattern、KV cache 交互方式。

## Step 2: Implement — 创建模型文件

在 `inference_engine/runtime/models/` 的对应子目录创建模型文件：
- 照搬参考实现的结构
- 实现 `forward()` 方法
- 实现 `load_weights()` 方法

## Step 3: Register — 注册模型

在 `inference_engine/runtime/models/__init__.py` 的 MODEL_REGISTRY 中注册新模型。

## Step 4: Config — 添加配置

在 `configs/model_configs/` 添加默认配置 YAML。

## Step 5: Test — 编写测试

在 `tests/test_models/` 添加测试文件。

## Step 6: Verify — 远程验证

通过 SSH 在 GPU 集群运行推理正确性验证。参考 `docs/claude/remote-verification-workflow.md`。
