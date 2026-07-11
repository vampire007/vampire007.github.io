---
title: Claude Code 安装指南
layout: page
date: 2026-07-11 10:00:00 +0800
---

# 安装 Claude Code

官方安装脚本在国内网络环境下通常不可用，推荐使用 npm 方式安装。

## 前置配置

### 设置 npm 全局路径

```bash
npm config set prefix /Users/andy/npmGlobal
```

### 切换国内镜像源

```bash
npm config set registry https://registry.npmmirror.com
```

## 安装步骤

全局安装 Claude Code：

```bash
npm install -g @anthropic-ai/claude-code
```

安装完成后二进制文件位于 `/Users/andy/npmGlobal/bin/claude`，需要将对应目录加入 shell 路径：

```bash
export PATH="$PATH:/Users/andy/npmGlobal/bin"
```

可将上述 `export` 命令写入 `~/.zshrc` 或 `~/.bash_profile` 使其永久生效。

## 配置 API 接入

配置文件位于 `~/.claude.json`：

```json
{
    "env": {
        "ANTHROPIC_AUTH_TOKEN": "sk-你的百炼API密钥",
        "ANTHROPIC_BASE_URL": "https://dashscope.aliyuncs.com/api/v2/apps/claude-code-proxy"
    },
    "hasCompletedOnboarding": true
}
```

### 使用魔搭社区（ModelScope）免费额度

魔搭社区提供每天 **2000 次**免费调用：[ModelScope Limits](https://modelscope.cn/docs/model-service/API-Inference/limits)

#### 配置步骤

1. 访问 [modelscope.cn](https://www.modelscope.cn) 注册并获取 Token
2. 配置环境变量：

```bash
# 魔搭社区的模型
export ANTHROPIC_BASE_URL="https://api-inference.modelscope.cn"
export ANTHROPIC_AUTH_TOKEN="ms-xxx-xxx"
# 模型 ID 需带服务商标识
export ANTHROPIC_MODEL="Qwen/Qwen3-Coder-480B-A35B-Instruct"
```

#### 支持的千问模型

| 模型名称 | 说明 |
|----------|------|
| `qwen3-coder-plus` | 编程专用模型（当前推荐） |
| `qwen3-max` | 通义千问3最大版本 |
| `qwen3-coder-480B-A35B-Instruct` | 480B MoE 编程模型 |

## 其他可选方案

### claude-code-router

如果需要同时配置多个模型并灵活切换，可使用第三方路由工具：

```bash
# 安装路由工具
npm install -g claude-code-router

# 配置多个提供商
ccr setup
```

### CC Switch

GitHub 上的 [cc-switch](https://github.com/farion1231/cc-switch) 工具可以方便地管理多个 API 配置。

## 常见问题

| 问题 | 解决方案 |
|------|----------|
| 配置后无法连接 | 检查 API Key 是否正确，确保没有多余空格 |
| 模型响应慢 | 百炼免费用户有速率限制，可升级套餐提升 TPM |
| 需要指定模型 | 设置 `ANTHROPIC_MODEL=qwen3-coder-plus` |

## 验证安装

启动 Claude Code 后，输入以下命令查看当前使用的模型：

```
/model
```

如果配置成功，即可使用千问大模型进行编程辅助。
