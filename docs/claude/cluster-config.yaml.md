# 远程 GPU 集群配置

> 在各项目的 `CLAUDE.md` 或 Claude Code settings 中引用此配置。  
> **注意：不要在此文件中存放密码或私钥内容，仅存放连接元数据。**

## 集群列表

```yaml
clusters:
  # 示例配置，按实际环境修改
  dev:
    host: "gpu-dev.example.com"
    user: "ryan"
    ssh_key: "~/.ssh/id_ed25519"
    gpu_type: "A100-80G"
    gpu_count: 8
    work_dir: "/home/ryan/workspace"
    conda_env: "inference"
    description: "开发测试集群"

  prod:
    host: "gpu-prod.example.com"
    user: "ryan"
    ssh_key: "~/.ssh/id_ed25519"
    gpu_type: "H100-80G"
    gpu_count: 8
    work_dir: "/home/ryan/workspace"
    conda_env: "inference"
    description: "生产验证集群"
```

## SSH 连接约定

- 所有连接使用 key 认证，不使用密码
- 跳板机（如有）配置在 `~/.ssh/config` 中，此处仅记录最终目标主机
- 长时间任务使用 `tmux` 或 `nohup` 防止断连丢失
