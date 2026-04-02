---
name: parallel-dev
description: >
  Use when the user asks to "work on multiple tasks in parallel", "use worktrees",
  "parallel development", "split into subtasks", or gives a complex task that
  naturally decomposes into 2-4 independent implementation streams.
  Also triggered by: "并行开发", "多 agent", "worktree 模式".
user-invocable: true
disable-model-invocation: true
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash, Agent]
argument-hint: <task-description>
---

# 并行 Worktree 开发: $ARGUMENTS

## 编排流程

```
Phase 1: 分解    — 将任务拆为 2-4 个独立子任务
Phase 2: 派发    — 每个子任务启动一个 worktree agent
Phase 3: 监控    — 跟踪各 agent 进度
Phase 4: 审查    — 每个 agent 完成后运行 /review-worktree
Phase 5: 合并    — 审查通过后串行 merge 到开发分支
```

---

## Phase 1: 分解

分析任务，拆分为独立子任务。每个子任务必须满足：

- **独立性:** 不依赖其他子任务的产出（可能修改不同文件/模块）
- **原子性:** 单独合入不会破坏主分支
- **可验证:** 有明确的完成标准

用 TaskCreate 创建所有子任务，标注依赖关系。

**分解示例：**
```
原始任务: "添加 Qwen3 模型支持并优化 attention kernel"

子任务 A (worktree-qwen3):
  实现 Qwen3 模型 → models/llm/qwen3.py + 配置 + 测试

子任务 B (worktree-attn-opt):
  优化 attention kernel → layers/attention/ + kernels/triton/

→ A 和 B 修改不同文件，可并行
```

**不适合并行的情况：**
- 子任务之间有顺序依赖（B 需要 A 的产出）
- 修改同一个文件的不同部分（merge 冲突风险高）
- 任务太小（单文件改动不值得 worktree 开销）

遇到以上情况时，告知用户并改为串行执行。

---

## Phase 2: 派发

为每个子任务启动 worktree agent。**必须在单条消息中并行启动所有 agent：**

```
对每个子任务，调用：

Agent(
  description: "子任务简述",
  isolation: "worktree",
  run_in_background: true,
  prompt: """
  ## 任务
  [具体任务描述]

  ## 约束
  - 只修改与本任务相关的文件
  - 遵循项目 CLAUDE.md 中的代码规范
  - 完成后确保代码可正常 import
  - 提交所有变更（git add + git commit）

  ## 参考
  [相关 CLAUDE.md 中的依赖关系和修改模式]

  ## 完成标准
  [明确的验收条件]
  """
)
```

**关键：**
- 每个 agent 的 prompt 必须包含完整上下文（agent 看不到主对话）
- 把相关模块的 CLAUDE.md 中的依赖关系和接口契约复制进 prompt
- 明确告诉 agent "提交你的变更"，否则 worktree 清理时会丢失

---

## Phase 3: 监控

Agent 在后台运行时，向用户汇报状态：

```
当前并行任务：
  ✅ worktree-qwen3     — Agent 已完成
  🔄 worktree-attn-opt  — Agent 执行中
  ⏳ worktree-fix-sched — Agent 排队中
```

收到每个 agent 的完成通知后，进入 Phase 4。

---

## Phase 4: 审查

每个 worktree agent 完成后，启动审查。调用 `/review-worktree` skill：

```
对每个完成的 worktree：

1. 获取 agent 返回的 branch name
2. 运行 /review-worktree <branch-name>
3. 根据审查结果决定：
   - APPROVE → 进入 Phase 5
   - REQUEST_CHANGES → 启动新 agent 在同一 worktree 继续修改
```

**打回重做时的 prompt 模板：**
```
Agent(
  prompt: """
  审查发现以下问题，请在 worktree [path] 中修复：

  [审查意见列表]

  修复后重新提交（git add + git commit --amend）。
  """
)
```

---

## Phase 5: 合并

审查通过的分支，**串行 merge** 到开发分支（避免并发冲突）：

```bash
# 按完成顺序逐个 merge
git checkout main
git merge --no-ff <branch-1> -m "merge: [子任务1描述]"
git merge --no-ff <branch-2> -m "merge: [子任务2描述]"
# 如果冲突：尝试自动 resolve，失败则通知用户
```

合并完成后清理 worktree：
```bash
git worktree remove .claude/worktrees/<name>
```

---

## 完成报告

```markdown
## 并行开发完成

| 子任务 | 分支 | 状态 | 审查轮次 |
|--------|------|------|---------|
| ... | ... | ✅ merged | 1 |
| ... | ... | ✅ merged | 2 (打回1次) |

合并到: main
冲突: 无 / [描述]
```
