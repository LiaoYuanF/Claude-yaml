# compilation — 编译优化

`compile.py` 集成 torch.compile。

## 依赖关系
- **上游:** `model_executor` — 触发编译
- **下游:** `layers/*` — 被编译的计算图

## 修改模式
- 编译策略变更: 验证首次编译时间和稳态性能
- 注意 dynamic shape 对编译缓存的影响
