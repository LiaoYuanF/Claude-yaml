# 对话模板（Chat Template）

将原始消息列表转换为模型特定的 prompt 格式（如 ChatML、Llama 格式等）。

## 依赖关系
- **上游:** 模型配置文件（tokenizer_config.json 中的 chat_template 字段）
- **下游:** `openai/` handler 层（调用模板渲染后再传入 runtime）

## 接口契约
- 模板输出必须与目标模型的训练格式严格匹配，否则会导致生成质量下降
- 新增模型系列时需添加对应模板或验证 Jinja2 模板兼容性
- system/user/assistant 角色映射须保持一致

## 修改模式
- 新增模型支持：检查模型的 `tokenizer_config.json` → 若有 Jinja2 模板则自动适配，否则手动添加
- 调试输出异常：打印模板渲染结果，对比模型预期的 token 序列
- 特殊 token 问题：确认 BOS/EOS/分隔符与 tokenizer 配置一致
