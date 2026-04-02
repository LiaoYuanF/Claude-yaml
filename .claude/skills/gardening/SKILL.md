---
name: gardening
description: >
  Use when the user asks to "clean up code", "check code quality",
  "update quality scores", "find stale docs", "tech debt scan",
  or when periodic maintenance is needed.
  This is the automated entropy management system.
  Also triggered by: "代码清理", "质量扫描", "文档检查", "熵管理".
user-invocable: true
allowed-tools: [Read, Glob, Grep, Bash, Write, Edit]
argument-hint: "[--scope module-name] [--fix] [--report-only]"
---

# 代码库 Gardening: $ARGUMENTS

自动化熵管理 — 扫描代码质量偏差、检测文档腐化、更新质量评分。

## 当前状态
- 分支: !`git branch --show-current`
- CLAUDE.md 数量: !`find . -name CLAUDE.md -not -path './.git/*' | wc -l`
- 总 Python 文件: !`find . -name '*.py' -not -path './.git/*' | wc -l`

---

## Step 1: CLAUDE.md 腐化检测

扫描所有 CLAUDE.md，检查引用的文件路径是否存在：

```bash
stale_count=0
for f in $(find . -name 'CLAUDE.md' -not -path './.git/*'); do
  grep -oP '`[a-zA-Z_/][a-zA-Z_/\.]+\.(py|yaml|sh|cu)`' "$f" 2>/dev/null | tr -d '`' | while read ref; do
    if [ ! -f "$ref" ] && [ ! -f "$(dirname $f)/$ref" ]; then
      echo "STALE: $f references $ref (not found)"
      stale_count=$((stale_count + 1))
    fi
  done
done
```

如果传入 `--fix`：自动修正引用（删除或更新路径）。
否则：仅报告。

## Step 2: 依赖关系一致性

对有依赖声明的 CLAUDE.md，验证声明与实际 import 是否一致：

```bash
# 对每个有"上游"/"下游"声明的模块
# 检查其 import 是否包含声明的上游模块
# 检查声明的下游模块是否确实 import 了它
```

## Step 3: 测试覆盖检查

```bash
for src in $(find inference_engine -name '*.py' -not -name '__init__.py' -not -path '*/__pycache__/*'); do
  base=$(basename "$src" .py)
  if ! find tests/ -name "test_${base}.py" 2>/dev/null | grep -q .; then
    echo "NO_TEST: $src has no corresponding test file"
  fi
done
```

## Step 4: 代码模式一致性

检查关键模式是否被遵循：
- 所有 `models/` 下的模型文件是否实现 `forward()` 和 `load_weights()`
- 所有 `layers/` 下的文件是否有类型注解
- 接口文件（`base_*`, `*_struct`）是否使用 ABC 或 Protocol

## Step 5: 更新质量评分

读取 `docs/QUALITY_SCORE.md`，根据以上检查结果更新各模块评分：

| 检查项 | A | B | C | D |
|--------|---|---|---|---|
| CLAUDE.md 时效 | 0 stale | 1-2 stale | 3+ stale | 无 CLAUDE.md |
| 测试覆盖 | 100% | ≥70% | ≥40% | <40% |
| 类型注解 | 完整 | 公开函数有 | 部分有 | 基本没有 |
| 接口契约 | 同步 | 小偏差 | 明显不同步 | 无声明 |

将更新后的评分写入 `docs/QUALITY_SCORE.md`。

## Step 6: 自动修复（如 --fix）

对 Grade C/D 的模块，尝试自动修复：
- CLAUDE.md 路径修正
- 补充缺失的 `__init__.py` 导出
- 创建缺失的测试文件（空桩）
- 更新过时的依赖声明

**不自动修复的**（需人类决策）：
- 架构级重构
- 接口变更
- 功能性 bug

## Step 7: 产出报告

```markdown
## Gardening 报告

- **时间:** YYYY-MM-DD HH:MM
- **扫描范围:** 全局 / [指定模块]

### 腐化检测
- CLAUDE.md 引用检查: N 个文件, M 处 stale
- 修复: [已修复/仅报告]

### 质量评分变更

| 模块 | 旧等级 | 新等级 | 变化原因 |
|------|--------|--------|---------|
| ... | | | |

### 待修复问题
1. [模块] — [问题描述]

### 自动开启的修复 PR
- [PR 描述]（如 --fix 模式）
```
