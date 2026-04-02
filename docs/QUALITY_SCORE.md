# 质量评分

跟踪各模块的代码质量等级。由 `/gardening` skill 定期更新。

## 评分标准

| 等级 | 含义 |
|------|------|
| A | 完全符合规范，测试充分，CLAUDE.md 时效 |
| B | 基本符合，有小问题待修 |
| C | 有明确技术债，需排期修复 |
| D | 严重问题，阻塞新功能开发 |

## 当前评分

| 模块 | 等级 | 上次评估 | 待修问题 |
|------|------|---------|---------|
| `api/openai` | — | 待评估 | |
| `api/entrypoints` | — | 待评估 | |
| `runtime/managers` | — | 待评估 | |
| `runtime/model_executor` | — | 待评估 | |
| `runtime/models/llm` | — | 待评估 | |
| `runtime/layers/attention` | — | 待评估 | |
| `runtime/layers/moe` | — | 待评估 | |
| `runtime/kernels` | — | 待评估 | |
| `runtime/distributed` | — | 待评估 | |
| `runtime/mem_cache` | — | 待评估 | |

## 评估维度

1. **CLAUDE.md 时效性** — 引用的文件路径是否存在？依赖关系是否正确？
2. **测试覆盖** — 源码文件是否有对应测试？
3. **类型注解** — 公开函数是否有完整类型注解？
4. **接口契约** — 跨模块接口变更是否同步？
5. **代码一致性** — 是否遵循参考实现的模式？
