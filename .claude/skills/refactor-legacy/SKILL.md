---
name: refactor-legacy
description: >
  Use when the user asks to "refactor this codebase", "make AI-native",
  "modernize the repo", "set up for AI development", or wants to perform
  a complete legacy codebase transformation with CI integration.
  This is the top-level orchestration skill that coordinates all sub-skills.
  Also triggered by: "重构代码库", "AI 化改造", "改造老项目".
user-invocable: true
disable-model-invocation: true
allowed-tools: [Read, Glob, Grep, Write, Edit, Bash, Agent]
argument-hint: "<repo-path-or-description>"
---

# 遗留代码库重构: $ARGUMENTS

这是顶层编排 skill，串联以下子 skill 完成完整的重构闭环：

```
/ai-native-transform  →  /parallel-dev  →  /ci-test  →  /profile-perf
    改造结构              并行实现          测试验证       性能分析
```

---

## Phase 1: 诊断与改造 — `/ai-native-transform`

**目标：** 将代码库从传统结构改造为 AI-native 结构

调用 `/ai-native-transform` 执行：
1. 诊断现有代码库（结构、架构、热路径、耦合）
2. 设计 CLAUDE.md 4 层层级
3. 写入所有 CLAUDE.md
4. 配置 Skills、Hooks、MCP
5. 验证改造质量

**产出：**
- 完整的 CLAUDE.md 层级覆盖
- 项目特定的 skills（根据诊断结果定制）
- hooks 配置
- 诊断报告

**检查点：** 向用户确认改造结果是否满意，再进入下一阶段。

---

## Phase 2: CI 基础设施搭建

**目标：** 建立远程测试和 profiling 的基础设施

### 2.1 配置测试环境

引导用户填入 `configs/ci/test-env.yaml`：

```
请提供以下信息（我会写入配置文件）：
- 测试服务器地址 (host):
- 用户名 (user):
- SSH key 路径:
- 远程工作目录:
- 环境初始化命令 (conda activate ... 等):
```

### 2.2 配置测试矩阵

根据诊断结果，定制 `configs/ci/test-matrix.yaml`：
- 识别哪些测试可以本地跑（无 GPU 依赖）
- 识别哪些必须远程跑（GPU 相关）
- 设定各级别的通过标准

### 2.3 编写测试脚本

根据项目实际情况，填充 `scripts/ci/` 下的脚本模板：
- `run-remote-tests.sh` — 替换 TODO 为实际测试命令
- `collect-profile.sh` — 替换 TODO 为实际 profiling 命令

### 2.4 验证连通性

```bash
# 测试 SSH 连接
ssh -o ConnectTimeout=5 ${HOST} "echo 'connected' && nvidia-smi --query-gpu=name --format=csv,noheader"
```

**检查点：** 确认远程环境可达且 GPU 可用。

---

## Phase 3: 重构实施 — `/parallel-dev`

**目标：** 按 AI-native 结构实施代码重构

根据 Phase 1 诊断出的重构任务，使用 `/parallel-dev` 并行执行：

```
典型的重构子任务分解：
- worktree-A: 重构模块 A 的接口（保持向后兼容）
- worktree-B: 重构模块 B 的内部实现
- worktree-C: 补充测试覆盖
```

每个 worktree agent 完成后由 `/review-worktree` 审查，通过后合并。

**检查点：** 所有 worktree 合并完成，代码可 import。

---

## Phase 4: 测试验证 — `/ci-test full`

**目标：** 在远程 GPU 集群上运行完整测试

调用 `/ci-test full --profile` 执行：
1. 同步代码到远程
2. 逐级执行: smoke → unit → integration → e2e → performance
3. 失败自动修复（最多 3 轮）
4. 全量通过后自动运行 profiling

```
自动修复闭环:
  测试失败 → 分析错误 → 定位源码 → 修复 → 重新同步 → 重跑
  最多 3 轮，超过则停止并向用户报告
```

**检查点：** 全量测试通过 + profiling 数据收集完成。

---

## Phase 5: 性能分析 — `/profile-perf`

**目标：** 产出完整的性能分析报告

如果 Phase 4 已带 `--profile`，此步可跳过。否则单独调用：

调用 `/profile-perf` 执行：
1. 运行 torch.profiler + memory snapshot + benchmark
2. 对比 baseline（如有）
3. 分析瓶颈
4. 产出 `results/profiling/report.md`

---

## Phase 6: 产出总结报告

将所有阶段的结果汇总为最终报告：

```markdown
## 重构完成报告

### 改造概览
- **原始状态:** [文件数、目录层级、AI 配置覆盖]
- **改造后:** [CLAUDE.md 数量、Skills 数量、Hooks 数量]
- **重构任务:** N 个子任务，M 个并行 worktree

### CI 测试结果
- **测试级别:** full
- **通过率:** X/Y (XX%)
- **自动修复:** N 次
- **总耗时:** X 分钟

### 性能指标
| 指标 | Baseline | 重构后 | 变化 |
|------|----------|--------|------|
| Throughput | | | |
| Latency P99 | | | |
| Memory Peak | | | |

### 残留问题
[如有未解决的问题，列出]

### 后续建议
[1-3 条后续优化方向]
```

---

## 迁移检查清单

将此范式迁移到实际项目时：

- [ ] 替换 `configs/ci/test-env.yaml` 中的连接信息
- [ ] 替换 `configs/ci/test-matrix.yaml` 中的测试命令
- [ ] 替换 `scripts/ci/run-remote-tests.sh` 中的 TODO
- [ ] 替换 `scripts/ci/collect-profile.sh` 中的 TODO
- [ ] 根据项目实际调整 CLAUDE.md 模板内容
- [ ] 根据项目实际定制 hooks 中的文件路径 pattern
- [ ] 验证 SSH 连通性和 GPU 可用性
