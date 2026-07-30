---
layout: page
title: Agnes AI API 接入指南（Claude CLI）
date: 2026-07-30 +0800
---

# 🚀 Agnes AI API 接入完整指南（基于 Claude CLI）

## 一、概述

本文档介绍如何通过 **CC-Switch** 将本地安装的 Claude CLI 连接至 Agnes AI API 网关，从而在本地使用 Agnes 文本模型进行 Agent 任务或编码工作流。

通过 CC-Switch 的路由机制，Claude CLI 的请求会被转发到 Agnes API 网关，使用户能够在本地开发环境中无缝调用 Agnes 模型的能力。

## 二、前置条件

在开始配置前，请确保已完成以下准备工作：

| 要求 | 说明 |
|------|------|
| **Claude CLI** | 已安装并可在终端正常运行 `claude` 命令 |
| **CC-Switch** | 版本 ≥ v3.16.1，下载地址：[https://github.com/farion1231/cc-switch/releases](https://github.com/farion1231/cc-switch/releases) |
| **Agnes AI API Key** | 需先在 [平台](https://platform.agnes-ai.com/) 申请获取 |
| **网络环境** | 可访问 `https://api.agnes-ai.cn/v1`（如有代理请提前配置） |
| **目标模型名称** | 计划使用的 Agnes 模型名称（如 `agnes-2.0-flash`） |

## 三、获取 Agnes API Key

1. 访问 Agnes AI 控制台：👉 [https://platform.agnes-ai.com/](https://platform.agnes-ai.com/)
2. 登录您的账号
3. 进入 **API Key** 管理页面
4. 点击 **"Create New Key"** 创建新密钥
5. 复制生成的 API Key（⚠️请妥善保存，仅显示一次）

> 💡 **安全提示**：请勿将 API Key 公开到代码仓库或公共日志中，建议在环境变量或配置文件中引用。

## 四、启动与配置 CC-Switch

### 4.1 启动 CC-Switch

在您的桌面环境中启动 CC-Switch 应用（可通过 Dock、菜单栏或快捷键打开）。

### 4.2 选择 Claude CLI 代理模式

在顶部工具栏中选择：

```
Claude CLI
```

此菜单项用于配置 Claude CLI 的模型代理服务。

### 4.3 添加新提供商

点击右上角的 **+ 号** 按钮，添加一个新的模型提供商。

| 选项 | 值 |
|------|-----|
| **Provider Type** | `Claude Provider` |
| **Subtype** | `Custom Provider` |

选择 `Custom Provider` 表示您将通过自定义方式接入 Agnes API。

### 4.4 输入 API Key

在 **API Key** 字段中输入从 Agnes 平台复制的密钥：

```
YOUR_API_KEY_HERE
```

> ⚡ **注意**：大多数情况下只需输入密钥本身，**不要**手动添加 `Bearer` 前缀，除非工具明确要求完整的 Authorization Header。

### 4.5 配置请求 URL

在 **Base URL / API Endpoint** 字段中输入：

```
https://api.agnes-ai.cn/v1
```

此 URL 是 Agnes AI API 的网关入口，所有请求将被转发至此。

### 4.6 选择 API 格式

在 **API Format** 下拉菜单中选择：

```
OpenAI Chat Completions
```

Agnes API 兼容 OpenAI 的 Chat Completions 接口协议，因此使用该格式即可实现正确的请求构造和响应解析。

### 4.7 认证字段设置

默认情况下，CC-Switch 会使用内置的认证字段：

```
ANTHROPIC_AUTH_TOKEN
```

如需手动调整，可在认证设置页面修改，但通常情况下保持默认即可正常工作。

### 4.8 获取模型列表并映射

点击 **"Fetch Model List"** 按钮：

- ✅ 成功：CC-Switch 会向 Agnes API 发起 GET 请求，返回可用模型列表
- ❌ 失败：检查网络连接、API Key 是否正确，以及 Base URL 是否拼写正确

模型获取成功后，将 Claude CLI 的常用模型映射到对应的 Agnes 模型：

| Claude CLI 模型 → | Agnes 模型推荐 |
|-------------------|----------------|
| Sonnet            | agnes-2.0-flash    |
| Opus              | agnes-2.0-flash    |
| Haiku             | agnes-2.0-flash    |

> 💡 您也可以根据实际业务需求选择其他可用模型（如更大上下文窗口或特定能力模型）。

### 4.9 添加兼容性参数（关键步骤！）

为避免 Claude CLI 发送的参数与 Agnes API 不兼容导致错误，请在 **Custom Parameters / Advanced Settings** 中添加以下 JSON 配置：

```json
{
  "allowed_openai_params": ["thinking", "context_management"],
  "litellm_settings": {
    "drop_params": true
  }
}
```

| 配置项 | 作用说明 |
|--------|----------|
| `allowed_openai_params` | 显式允许指定的 OpenAI 风格参数通过（如 `thinking`、`context_management`） |
| `litellm_settings.drop_params` | 设置为 `true` 时，自动丢弃模型不支持的未知参数，提高兼容性 |

该配置能显著减少因参数不匹配导致的报错，提升调用成功率。

### 4.10 保存配置

确认以上所有设置无误后，点击 **"Save"** 或 **"Add"** 按钮保存新的提供商配置。

保存成功后，您将在提供商列表中看到新增的 Agnes Provider 条目。

## 五、启用路由功能

### 5.1 进入路由配置

点击 CC-Switch 左上角的 **齿轮（设置）图标**，进入路由设置页面。

### 5.2 开启本地路由

在路由类型中选择：

```
Route → Local Route
```

然后在 **Local Route** 设置中，找到 Claude CLI 的开关选项并将其 **启用（Enable）**。

### 5.3 激活 Agnes 提供商

返回主界面的 **Providers** 列表，找到刚创建的 Agnes Provider 条目，点击其右侧的开关按钮将其 **启用**。

此时 CC-Switch 会将 Claude CLI 的所有请求通过本地路由转发至 Agnes API 网关。

## 六、验证配置

打开终端，运行 Claude CLI 进行测试：

```bash
claude "你好，请做一下自我介绍"
```

如果配置成功，您将收到来自 Agnes 模型的响应内容，而不是本地的 Claude 模型输出。

也可以通过以下方式进一步验证：

- 检查 CC-Switch 界面上的日志输出，查看是否有请求转发成功的记录
- 在 Agnes 平台后台查看请求统计（如果有权限访问）

## 七、故障排查指南

### 🛑 问题 1：无法获取模型列表

**症状**：点击 Fetch Model List 后无反应，或出现超时/错误提示。

**解决方案**：

1. 确认 Base URL 是否正确：`https://api.agnes-ai.cn/v1`
2. 检查网络连接是否正常（可尝试在浏览器中访问该地址）
3. 若在企业网络环境下，可能需要配置代理
4. 验证 API Key 是否有效且未过期

### 🛑 问题 2：认证失败（401 Unauthorized）

**症状**：提示认证错误或 API Key 无效。

**解决方案**：

1. 重新复制 API Key，确保没有多余空格或字符
2. 不需要手动添加 `Bearer` 前缀
3. 确认使用的是对应区域的 API Key（如有多区域）
4. 尝试重新生成 API Key

### 🛑 问题 3：参数不兼容或请求错误

**症状**：运行时报出不支持参数或 JSON 解析错误。

**解决方案**：

请务必在 Custom Parameters 中添加兼容性配置（见第 4.9 节），特别是：

```json
{
  "litellm_settings": {"drop_params": true}
}
```

这会帮助自动过滤掉 Agnes 不支持的参数。

### 🛑 问题 4：Claude CLI 未使用 Agnes 模型

**症状**：返回的内容仍然像本地 Claude，而非 Agnes 模型输出。

**解决方案**：

1. 确认已在 Route → Local Route 中启用了 Claude 开关
2. 确认 Agnes Provider 处于 Enable 状态
3. 重启 CC-Switch 和终端，重新测试
4. 检查是否有多个 Provider 冲突，确保 Agnes 为默认/首选

### 🛑 问题 5：模型响应异常或截断

可能的原因包括：

- 所选模型能力限制（建议先用 `agnes-2.0-flash` 测试）
- 上下文窗口不足（长文本任务可尝试大上下文模型）
- 网络波动导致部分数据丢失（可重试或增加超时时间）

## 八、进阶建议

### 🔧 环境变量方式（更适合 CI/CD）

如果您希望在自动化脚本中使用 Agnes API，可直接设置环境变量绕过 CC-Switch 图形界面：

```bash
export AGNES_API_KEY="your-api-key"
export AGNES_BASE_URL="https://api.agnes-ai.cn/v1"

# 然后通过 OpenAI 兼容客户端调用
openai.chat.create(
  model: "agnes-2.0-flash",
  messages: [{ role: "user", content: "Hello!" }]
)
```

### 🔐 API Key 安全管理

- 将 API Key 存储在 `.env` 文件或系统 Keychain 中
- 生产环境中请使用专门的密钥管理服务
- 定期轮换 API Key 以提升安全性

### 🔄 多模型切换

CC-Switch 支持配置多个不同 Provider，您可以通过以下步骤快速切换模型：

1. 在 Providers 列表中启用/禁用不同的模型配置
2. 或使用 CC-Switch 的快捷切换命令（视具体版本支持情况而定）

## 九、参考资源

| 资源 | 链接 |
|------|------|
| Agnes AI 平台 | [https://platform.agnes-ai.com/](https://platform.agnes-ai.com/) |
| CC-Switch GitHub | [https://github.com/farion1231/cc-switch/releases](https://github.com/farion1231/cc-switch/releases) |
| Agnes API 文档索引 | [https://wiki.agnes-ai.cn/llms.txt](https://wiki.agnes-ai.cn/llms.txt) |
| 本文档来源 | wiki.agnes-ai.cn/llms.txt - Claude CLI 集成指南 |

完成上述配置后，您就可以在本地通过 Claude CLI 无缝调用 Agnes AI 模型，享受其强大的智能助手能力了！✨
