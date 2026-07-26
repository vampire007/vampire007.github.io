---
title: Holo 3.1 本地部署与 Claude Code 集成指南
layout: page
date: 2026-07-26 10:00:00 +0800
---

# Holo 3.1 本地部署与 Claude Code 集成

本文介绍如何在 Apple Silicon Mac 上本地运行 Holo 3.1 视觉模型，并将其接入 Claude Code 实现端到端的 Computer Use 能力。

## 一、Mac 本地启动 Holo 3.1（llama.cpp 路线）

### 1. 安装推理后端

```bash
brew install llama.cpp
```

M 系列 Mac 会自动使用 Metal 加速，`-ngl 999` 参数会将计算层卸载到 GPU/统一内存，无需额外安装 CUDA。

### 2. 下载模型文件

以 9B Q8 模型为例（16GB Mac 推荐配置），从 HuggingFace 下载以下两个文件到 `~/models/holo31/`：

- **主模型**: `Holo-3.1-9B.Q8_0.gguf`
- **视觉投影**: `Holo-3.1-9B.mmproj-q8_0.gguf`

> **35B-A3B 用户**请使用 `q4_k_m.gguf` + `mmproj.f16.gguf` 组合，并相应修改后续命令中的路径。

### 3. 启动 OpenAI 兼容服务

```bash
llama-server \
  -m ~/models/holo31/Holo-3.1-9B.Q8_0.gguf \
  --mmproj ~/models/holo31/Holo-3.1-9B.mmproj-q8_0.gguf \
  -ngl 999 \
  -c 24576 \
  --temp 0.2 \
  --host 127.0.0.1 \
  --port 1234
```

启动成功后会看到 `listening on 127.0.0.1:1234`。**`--mmproj` 参数必须携带，否则模型无法进行视觉理解，Computer Use 功能将失效。**

### 验证服务

```bash
curl http://127.0.0.1:1234/v1/models
```

## 二、将 Holo 3.1 接入 Claude Code

Holo 本身不是代码模型，与 Claude Code 配合的正确策略是：**Claude Code 当脑（写代码/规划），Holo 当手（操作屏幕）**。

### 方式 A：使用官方 HoloDesktop CLI 的 MCP（推荐）

H Company 提供的 `holo` CLI 可将本地 Holo 模型暴露为 MCP tool 供 Claude Code 调用。

```bash
# 1. 安装 holo CLI（根据官网 release 安装，或使用 npm）
# 2. 配置使用本地 llama-server
export HAI_AGENT_RUNTIME_BASE_URL=http://127.0.0.1:1234/v1
export HAI_AGENT_RUNTIME_MODEL=Hcompany/Holo-3.1-9B   # 35B-A3B 用户更换为对应模型名

# 3. 在 Claude Code 工作区目录下注册 MCP
cd /your/claude-code-project
holo install claude-code
```

`holo install` 命令会在当前 workspace 的本地 scope 写入配置，等价于创建以下 JSON：

```json
{
  "mcpServers": {
    "holo": {
      "type": "stdio",
      "command": "/absolute/path/to/holo",
      "args": ["mcp"]
    }
  }
}
```

重启 Claude Code 后，会话中会出现 `holo_desktop` 工具。你可以直接说：

> "用 holo 打开浏览器搜索 X，把结果贴回给我，代码部分你（Claude）来写"

Claude Code 会调用 `holo_desktop` 让 Holo 执行屏幕操作，自己负责编写脚本和处理返回内容。

> ⚠️ **注意**：从 Dock 启动的 Claude Code 不会继承终端的环境变量，需从终端执行 `claude` 命令启动，或在 `.mcp.json` 的 `env` 块中配置这两个变量。

### 方式 B：Claude Code 自带 Computer Use + 本地 Holo 当视觉后端（进阶）

如需更精细的分工控制，可让 Claude Code 使用内置的 computer-use MCP（需开启屏幕录制和辅助功能权限），将视觉理解任务指向本地 Holo：

```bash
export VISION_BASE_URL=http://127.0.0.1:1234/v1
export VISION_MODEL=Holo-3.1-9B
```

在 Claude Code 中通过 `/mcp` 命令启用 `computer-use`。此方式下 Claude 负责发送鼠标键盘指令，Holo 仅负责图像理解，分工更清晰，但配置相对复杂。

## 三、最小可跑闭环（16GB Air 实测验证）

1. **终端 A**：启动 Holo 服务
   ```bash
   llama-server -m ~/models/holo31/Holo-3.1-9B.Q8_0.gguf --mmproj ~/models/holo31/Holo-3.1-9B.mmproj-q8_0.gguf -ngl 999 -c 24576 --temp 0.2 --host 127.0.0.1 --port 1234
   ```

2. **终端 B**：配置环境变量并注册 MCP
   ```bash
   export HAI_AGENT_RUNTIME_BASE_URL=http://127.0.0.1:1234/v1
   export HAI_AGENT_RUNTIME_MODEL=Hcompany/Holo-3.1-9B
   cd /your/project/directory
   holo install claude-code
   ```

3. **终端 C**：启动 Claude Code
   ```bash
   claude
   ```

4. **在 Claude Code 中测试**：
   > "让 holo 打开 Safari 访问 hcompany.ai 并截图，你帮我总结页面导航结构"

执行流程：Claude 调用 `holo_desktop` → Holo 执行屏幕操作 → 截图回传 → Claude 分析总结。

## 四、常见问题

| 问题 | 解决方案 |
|------|----------|
| 模型无法识别图像 | 确保启动命令中包含 `--mmproj` 参数，且路径正确 |
| Claude 无法调用 holo_desktop | 检查环境变量是否正确配置，尝试从终端启动 Claude |
| 服务启动失败 | 检查端口是否被占用，使用 `lsof -i :1234` 查看 |
| 响应缓慢 | 降低模型量化精度或减少上下文窗口大小 |