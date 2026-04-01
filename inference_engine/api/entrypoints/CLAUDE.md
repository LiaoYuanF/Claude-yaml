# 服务入口（Entrypoints）

负责服务启动编排、FastAPI 应用初始化和路由注册。是整个 API 层的启动根节点。

## 依赖关系
- **上游:** 命令行参数、配置文件、runtime 初始化接口
- **下游:** `api/` 下所有子模块均依赖此层完成初始化和路由挂载

## 关键文件
- `engine.py` — 启动编排器，协调 runtime 和 API 层的初始化顺序
- `http_server.py` — FastAPI 应用实例，注册所有 HTTP 路由

## 接口契约
- 新增 API 端点必须在 `http_server.py` 中注册路由
- `engine.py` 的启动顺序不可随意调整（runtime 须先于 API 层就绪）
- 端口、host 等配置变更需确认不与 gRPC 端口冲突

## 修改模式
- 新增端点：在 handler 模块实现后，到 `http_server.py` 添加路由绑定
- 启动问题排查：从 `engine.py` 入口开始，沿初始化链逐步检查
- 中间件变更（CORS、鉴权等）：在 `http_server.py` 的 app 配置中修改
