# mem_cache — KV Cache 与 GPU 内存管理

`memory_pool.py` 管理 GPU 内存块，`radix_cache.py` 实现 prefix caching。

## 依赖关系
- **上游:** `model_executor` — 分配/释放 KV cache
- **下游:** 无（底层资源管理）

## 接口契约
- 内存块大小变更影响 `layers/attention/` 的 KV cache layout
- 分配策略直接决定最大并发数和吞吐

## 修改模式
- 分配策略变更: 必须用高并发场景测试 OOM 边界
- `radix_cache.py` 变更: 验证 cache hit rate 不退化
- 显存泄漏排查: 用 `scripts/profiling/memory_snapshot.py`
