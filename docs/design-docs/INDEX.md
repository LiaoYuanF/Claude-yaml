# 设计文档索引

记录关键架构决策及其背景。Agent 在做架构判断时应先查阅此处。

## 索引

| 编号 | 标题 | 状态 | 日期 |
|------|------|------|------|
| ADR-001 | SGLang 风格分层架构（api/ + runtime/） | 已采纳 | — |
| ADR-002 | CLAUDE.md 4 层渐进式披露 | 已采纳 | — |
| ADR-003 | Agent-to-agent 审查 + 最终人类门控 | 已采纳 | — |

<!-- 新增设计文档时在此追加索引行 -->

## 模板

新增设计文档时使用以下模板，保存到 `docs/design-docs/adr-NNN-title.md`：

```markdown
# ADR-NNN: 标题

## 状态
Proposed / Accepted / Deprecated

## 背景
[为什么需要这个决策]

## 决策
[做了什么选择]

## 后果
[预期的正面和负面影响]
```
