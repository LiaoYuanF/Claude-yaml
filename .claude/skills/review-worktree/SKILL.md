---
name: review-worktree
description: >
  Use when a worktree agent completes its task and changes need review
  before merging. Triggered by: "review branch", "审查分支", "检查 worktree",
  or automatically by /parallel-dev after each agent completes.
user-invocable: true
disable-model-invocation: true
context: fork
allowed-tools: [Read, Glob, Grep, Bash]
---

# 审查 Worktree 变更: $ARGUMENTS

## 当前 Worktree 列表
!`git worktree list 2>/dev/null || echo "无活跃 worktree"`

## 当前分支状态
!`git branch -a --sort=-committerdate | head -10`

---

## Step 1: 获取 Diff

```bash
# $ARGUMENTS 应为分支名
git log main..$ARGUMENTS --oneline
git diff main...$ARGUMENTS --stat
git diff main...$ARGUMENTS
```

逐文件审查变更，理解每个修改的意图。

## Step 2: 自动检查

### 2.1 接口兼容性
```bash
# 检查是否修改了接口契约文件
git diff main...$ARGUMENTS --name-only | grep -E '(io_struct|protocol|base_attn_backend|__init__)\.py'
```
如果修改了接口文件 → 检查上下游是否同步更新（参考对应 CLAUDE.md 的依赖关系）

### 2.2 CLAUDE.md 一致性
```bash
# 检查修改的模块是否需要更新 CLAUDE.md
for f in $(git diff main...$ARGUMENTS --name-only); do
  dir=$(dirname "$f")
  if [ -f "$dir/CLAUDE.md" ]; then
    echo "CHECK: $dir/CLAUDE.md — 模块 $f 已修改"
  fi
done
```

### 2.3 测试覆盖
```bash
# 检查新增的源文件是否有对应测试
git diff main...$ARGUMENTS --name-only --diff-filter=A | grep -v test | while read f; do
  base=$(basename "$f" .py)
  if ! find tests/ -name "test_${base}.py" 2>/dev/null | grep -q .; then
    echo "WARN: 新增文件 $f 没有对应测试"
  fi
done
```

## Step 3: 审查清单

- [ ] **正确性:** 逻辑是否正确？边界条件是否处理？
- [ ] **接口契约:** 跨模块接口变更是否同步更新？
- [ ] **性能影响:** 是否涉及热路径 (scheduler, attention, kernels)？
- [ ] **CUDA Graph:** 修改的 layer 是否同时支持 eager 和 graph 模式？
- [ ] **类型注解:** 新增函数是否有完整类型注解？
- [ ] **代码风格:** 是否与现有代码保持一致？
- [ ] **最小变更:** 是否有超出任务范围的修改？

## Step 4: 判定

### APPROVE
```
结论: APPROVE
理由: [一句话总结]
可以合并到 main。
```

### REQUEST_CHANGES
```
结论: REQUEST_CHANGES
问题列表:
1. [文件:行号] — [具体问题]
2. [文件:行号] — [具体问题]

修复建议:
- [具体建议]
```
