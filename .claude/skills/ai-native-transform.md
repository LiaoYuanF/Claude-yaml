---
name: ai-native-transform
description: 将传统代码库改造为 AI-native 代码库的完整流程
user_invocable: true
---

# AI-Native 代码库改造: $ARGUMENTS

将传统的人类编写的代码库改造为适配 AI agent 高效协作的结构。

---

## 设计原则

AI agent 感知代码库的成本从低到高：

```
自动注入 (CLAUDE.md)  →  工具注册 (MCP/Skills)  →  事件驱动 (Hooks)  →  主动探索 (Grep/Read)
      零成本                    零成本                  被动触发              消耗 context
```

**改造目标：将尽可能多的信息从"主动探索"层提升到"自动注入"层。**

---

## Phase 1: 诊断 — 理解现有代码库 (Scout)

### 1.1 结构扫描

```
运行以下命令，理解代码库全貌：
- tree -d -L 3           # 目录结构（3 层）
- find . -name "*.py" | wc -l    # 文件规模
- git log --oneline -20   # 近期活跃方向
- find . -name "CLAUDE.md" -o -name ".claude"  # 已有 AI 配置
```

### 1.2 架构识别

回答以下问题（写入诊断报告）：

1. **分层结构**：代码库的主要层级是什么？（如 API / Service / Data）
2. **热路径**：请求从入口到出口经过哪些关键模块？
3. **变更频率**：哪些目录变更最频繁？(`git log --format='' --name-only | sort | uniq -c | sort -rn | head -20`)
4. **耦合点**：哪些文件被最多模块 import？(`grep -r "from.*import\|import " --include="*.py" | awk -F: '{print $2}' | sort | uniq -c | sort -rn | head -20`)
5. **测试覆盖**：测试结构是否与源码目录对应？
6. **文档现状**：是否有 README / docstrings / 注释？质量如何？

### 1.3 输出诊断报告

```markdown
## 代码库诊断

- 规模：XX 文件 / XX 目录
- 主要语言：Python / Go / ...
- 架构风格：单体 / 微服务 / 分层 / ...
- 主要层级：[列出 3-5 个顶层模块及其职责]
- 热路径：[请求流向]
- 高耦合模块：[被最多模块依赖的文件]
- AI 配置现状：[已有的 CLAUDE.md / .claude / skills]
- 改造复杂度评估：低 / 中 / 高
```

---

## Phase 2: 设计 — CLAUDE.md 层级架构

### 2.1 层级规划

设计 4 层 CLAUDE.md 结构：

```
L0 项目根/CLAUDE.md      — WHO & WHY
    回答：项目是什么、技术栈、架构总览、协作规范、请求流向图
    
L1 顶层包/CLAUDE.md      — WHAT
    回答：模块间的职责划分、层间通信的接口契约文件

L2 子系统/CLAUDE.md       — HOW
    回答：该模块的职责边界、依赖关系（上游/下游）、接口契约、修改指南

L3 具体模块/CLAUDE.md     — DETAILS
    回答：实现细节的 gotchas、性能约束、常见修改模式
```

### 2.2 L0 CLAUDE.md 模板

```markdown
## 协作规范
[团队特定的 AI 协作规范]

## 项目上下文
- **类型：** [项目类型]
- **技术栈：** [语言、框架、工具]
- **关注指标：** [性能/正确性/安全性的优先级]

## 架构总览
```
[文字版请求流向图，展示模块间的数据流]
```

## 代码质量偏好
- [性能关键路径的策略]
- [非关键路径的策略]
- [测试策略]
```

### 2.3 L2 CLAUDE.md 模板（最关键）

```markdown
# [模块名]

[一句话描述职责]

## 依赖关系

上游（本模块依赖）：
- `path/to/module` — [依赖什么能力]

下游（依赖本模块）：
- `path/to/module` — [使用本模块的什么接口]

## 接口契约

修改 `[关键文件]` 时须同步更新 `[相关文件]`。

## 修改模式

[常见的修改场景和步骤，如"新增 XXX 时，照着 YYY 抄"]

## 约束

[性能约束、兼容性要求、安全要求等]
```

### 2.4 判断哪些目录需要 CLAUDE.md

不是每个目录都需要 CLAUDE.md。优先级：

1. **必须有**：项目根、每个顶层模块、高耦合模块、频繁变更的模块
2. **建议有**：有特殊约束的模块（性能关键、安全敏感、API 兼容性）
3. **不需要**：纯工具函数、简单数据结构、变更极少的稳定模块

---

## Phase 3: 实施 — 写入 CLAUDE.md

### 3.1 写入顺序

```
1. L0 (项目根)      — 建立全局上下文
2. L1 (包根)        — 建立架构地图
3. L2 (高耦合模块)   — 优先覆盖被最多模块依赖的
4. L2 (高频变更模块) — 覆盖日常开发最常改的
5. L3 (有 gotchas 的模块) — 只在确实有坑时才写
```

### 3.2 依赖关系的提取方法

```python
# 分析模块 X 的上下游依赖
# 上游：X import 了谁
grep -r "from.*import\|import " X/ --include="*.py" | grep -v __pycache__

# 下游：谁 import 了 X
grep -r "from X\|import X" . --include="*.py" | grep -v __pycache__ | grep -v X/
```

### 3.3 接口契约的识别方法

接口契约 = 修改一处必须同步修改另一处的文件对。识别方式：

```bash
# 找出经常一起修改的文件对
git log --format='' --name-only --diff-filter=M | \
  awk 'NF{files[$0]++; next} {for(a in files) for(b in files) if(a<b) pairs[a" <-> "b]++; delete files}
  END{for(p in pairs) if(pairs[p]>3) print pairs[p], p}' | sort -rn | head -20
```

---

## Phase 4: 配置 — Skills, Hooks, MCP

### 4.1 识别可复用的工作流 → Skills

在代码库中找出重复的多步操作，每个封装为一个 Skill：

```
高频操作                    → Skill 名称
─────────────────────────────────────────
新增一种 XXX（模型/API/...）  → /add-xxx
运行测试+对比结果            → /test
部署到环境                  → /deploy
性能问题排查                → /debug-perf
数据库迁移                  → /migrate
```

Skill 文件放在 `.claude/skills/[name].md`，格式：

```markdown
---
name: skill-name
description: 一句话描述
user_invocable: true
---

# [操作名]: $ARGUMENTS

## Step 1: ...
## Step 2: ...
```

### 4.2 识别需要自动提醒的变更 → Hooks

```
如果修改了 [高风险文件]     → 自动提醒 [检查项]
如果修改了 [接口契约文件]   → 自动提醒 [同步更新的文件]
如果修改了 [性能关键路径]   → 自动提醒 [运行 benchmark]
```

Hooks 配置在 `.claude/settings.json`：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "file=\"$CLAUDE_FILE_PATH\"; if echo \"$file\" | grep -qE '[高风险路径pattern]'; then echo '[提醒信息]'; fi"
          }
        ]
      }
    ]
  }
}
```

### 4.3 识别需要外部能力 → MCP Servers

```
需要的能力                          → MCP Server
─────────────────────────────────────────────
远程执行（SSH 到 GPU/生产集群）       → ssh-executor
查询外部数据库/数据仓库               → db-query
调用内部 API（部署系统、监控系统）     → internal-api
代码搜索（跨仓库）                    → code-search
```

---

## Phase 5: 验证 — 检查改造质量

### 5.1 覆盖率检查

```bash
# CLAUDE.md 覆盖率
total_dirs=$(find . -type d -not -path './.git/*' | wc -l)
claude_dirs=$(find . -name 'CLAUDE.md' -not -path './.git/*' | wc -l)
echo "CLAUDE.md 覆盖率: $claude_dirs / $total_dirs"

# 高耦合模块是否都有 CLAUDE.md
# [手动检查 Phase 1 诊断出的高耦合模块]
```

### 5.2 质量检查清单

- [ ] L0 CLAUDE.md 包含架构流向图
- [ ] L0 CLAUDE.md 包含协作规范
- [ ] 所有 L2 CLAUDE.md 都有依赖关系声明
- [ ] 接口契约文件都已标注
- [ ] 高风险变更都有 hook 提醒
- [ ] 重复工作流都已封装为 skill
- [ ] CLAUDE.md 中提到的文件路径都是正确的

### 5.3 实际验证

让 agent 执行一个典型任务（如"新增一个功能"），观察：
- Agent 是否能快速定位到正确的模块？
- Agent 是否参考了 CLAUDE.md 的修改指南？
- Agent 是否触发了 hook 提醒？
- Agent 是否在正确的时机使用了 skill？

如果以上任何一项为"否"，说明对应的 CLAUDE.md / hook / skill 需要补充或调整。

---

## Phase 6: 维护 — 保持元数据新鲜

### 6.1 CLAUDE.md 腐化检测

定期（或通过 hook）检查 CLAUDE.md 引用的文件是否还存在：

```bash
# 提取 CLAUDE.md 中引用的文件路径，检查是否存在
for f in $(find . -name 'CLAUDE.md'); do
  grep -oP '`[a-zA-Z_/]+\.(py|yaml|sh)`' "$f" | tr -d '`' | while read ref; do
    if [ ! -f "$ref" ] && [ ! -f "$(dirname $f)/$ref" ]; then
      echo "STALE: $f references $ref (not found)"
    fi
  done
done
```

### 6.2 建议的维护节奏

| 事件 | 动作 |
|------|------|
| 新增模块 | 创建对应 CLAUDE.md |
| 重构/移动文件 | 更新受影响的 CLAUDE.md 依赖声明 |
| 接口变更 | 更新接口契约描述 |
| 每月 | 运行腐化检测脚本 |

### 6.3 高级：AI 自维护

设置定期任务，让 AI agent 审查 CLAUDE.md 是否与代码一致：

```
提示词: "扫描所有 CLAUDE.md，检查依赖关系声明是否与实际 import 一致，
        接口契约中提到的函数是否还存在。输出不一致的列表。"
```

---

## 附录: 改造复杂度评估

| 代码库特征 | 低复杂度 | 中复杂度 | 高复杂度 |
|-----------|---------|---------|---------|
| 文件数 | < 100 | 100-1000 | > 1000 |
| 目录层级 | ≤ 3 | 4-5 | > 5 |
| 已有文档 | 有 README + docstrings | 部分 README | 几乎没有 |
| 架构清晰度 | 分层明确 | 基本分层 | 意大利面条 |
| 预计工作量 | 半天 | 1-2 天 | 3-5 天 |
