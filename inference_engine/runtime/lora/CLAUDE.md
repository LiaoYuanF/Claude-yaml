# lora — LoRA 适配器管理

`lora_manager.py` 处理 adapter 生命周期（加载/卸载/切换）。

## 依赖关系
- **上游:** API 层 — 指定 adapter; `model_loader` — 加载 adapter 权重
- **下游:** `layers/*` — 注入 LoRA 计算; `mem_cache` — adapter 显存管理

## 修改模式
- 多 adapter 并发: 关注显存碎片和热加载延迟
- adapter 切换: 验证无请求泄漏
