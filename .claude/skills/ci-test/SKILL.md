---
name: ci-test
description: >
  Use when the user asks to "run CI", "run tests", "integration test",
  "validate changes", "check before merge", "test on cluster",
  or when code changes need to be verified on remote GPU test environment.
  Also triggered by: "CI 测试", "集成测试", "跑测试", "验证一下".
user-invocable: true
disable-model-invocation: true
allowed-tools: [Read, Glob, Grep, Bash, Write, Edit]
argument-hint: "[quick|standard|full|perf_only] [--no-retry] [--profile]"
---

# CI 集成测试: $ARGUMENTS

## 配置
- 测试环境: `configs/ci/test-env.yaml`
- 测试矩阵: `configs/ci/test-matrix.yaml`

## 当前状态
- 分支: !`git branch --show-current`
- 未提交变更: !`git status --short | head -5`
- 最近提交: !`git log -1 --oneline`

---

## Step 1: 解析参数

从 $ARGUMENTS 中解析：
- **测试级别:** quick / standard / full / perf_only（默认 standard）
- **--no-retry:** 禁用自动修复重试
- **--profile:** 测试通过后追加性能 profiling

读取 `configs/ci/test-env.yaml` 获取连接信息。
读取 `configs/ci/test-matrix.yaml` 获取对应 preset 的测试组。

若 test-env.yaml 中连接信息为空，提醒用户先填入实际值。

## Step 2: 预检

```bash
# 检查是否有未提交变更
git status --short

# 检查远程连接可达（读取 test-env.yaml 中的 host）
# ssh -o ConnectTimeout=5 ${HOST} "echo 'reachable'" || echo "FAIL: cannot reach ${HOST}"
```

如果有未提交变更，询问用户是否继续（未提交的代码不会被同步）。

## Step 3: 同步代码到测试环境

```bash
# 使用 scripts/ci/run-remote-tests.sh 的同步步骤
export CI_HOST="<from test-env.yaml>"
export CI_USER="<from test-env.yaml>"
export CI_WORK_DIR="<from test-env.yaml>"

rsync -avz --exclude='.git' --exclude='__pycache__' --exclude='results/' \
  ./ "${CI_USER}@${CI_HOST}:${CI_WORK_DIR}/" 2>&1 | tail -5
```

## Step 4: 执行测试 (带重试闭环)

按 test-matrix.yaml 中定义的 preset 逐组执行。

```
设 retry_count = 0
设 max_retries = 3 (from test-env.yaml)

LOOP:
  对每个 test_group 在 preset 中:
    执行远程测试命令
    收集 stdout/stderr + exit code
    
  IF 全部通过:
    → 跳到 Step 5
    
  IF 有失败 AND retry_count < max_retries AND 非 --no-retry:
    retry_count += 1
    
    分析失败原因:
      读取测试输出中的错误信息
      定位失败的测试 + 对应的源码文件
      参考对应模块的 CLAUDE.md 中的依赖关系和修改指南
    
    尝试修复:
      修改本地代码 → 重新同步 → 重新执行失败的测试组
      
    → 回到 LOOP
    
  IF 有失败 AND (retry_count >= max_retries OR --no-retry):
    → 输出失败报告，终止
```

**自动修复的边界：**
- 只修复明确的代码错误（import error、type error、assertion failure）
- 不修复设计级问题（架构错误、需求理解偏差）
- 如果连续 2 次修复同一个测试，说明需要人工介入，停止重试

## Step 5: 收集结果

```bash
# 拉取测试结果
rsync -avz "${CI_USER}@${CI_HOST}:${CI_WORK_DIR}/results/" ./results/ 2>/dev/null || true
```

## Step 6: 性能 Profiling（可选）

如果传入了 `--profile` 参数且所有测试通过：

```
调用 /profile-perf 执行性能 profiling
```

## Step 7: 产出报告

```markdown
## CI 测试报告

- **时间:** YYYY-MM-DD HH:MM
- **分支:** <branch>
- **提交:** <commit hash>
- **测试级别:** <preset>

### 测试结果

| 测试组 | 用例数 | 通过 | 失败 | 跳过 | 耗时 |
|--------|--------|------|------|------|------|
| smoke  | N | N | 0 | 0 | Xs |
| unit   | N | N | 0 | 0 | Xs |
| ...    |   |   |   |   |    |

### 自动修复记录

| 轮次 | 失败测试 | 修复内容 | 结果 |
|------|---------|---------|------|
| 1 | test_xxx | 修改了 xxx.py L42 | ✅ 通过 |

### 性能指标（如有）

| 指标 | 当前值 | Baseline | 比率 | 判定 |
|------|--------|----------|------|------|
| Throughput | N tok/s | N tok/s | 0.98 | ✅ PASS |

### 结论

✅ ALL PASS / ❌ FAILED (N failures after M retries)
```
