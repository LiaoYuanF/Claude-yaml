# distributed/tensor_parallel — 张量并行

Column/Row parallel 切分。

## 依赖关系
- **上游:** `parallel_state.py` — 进程组
- **下游:** `layers/linear.py`, `layers/attention/` — 注入 TP 切分

## 修改模式
- 新增 TP 切分: 确保 all-reduce 通信量最小化
