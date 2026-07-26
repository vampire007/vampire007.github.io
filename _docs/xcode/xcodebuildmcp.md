---
layout: page
title: XcodeBuildMCP 配置指南
date: 2026-07-20 +0800
categories: [Xcode]
tags: [Xcode, MCP, iOS, Automation]
---

## 1 简介

**XcodeBuildMCP** 是一个基于 **Model Context Protocol (MCP)** 的服务器工具，专门用来把 Xcode 的完整开发能力（构建、模拟器操控、UI 自动化、LLDB 调试等）封装成标准化接口，让 AI Agent（如 Claude Code、Cursor 等）能直接调用，从而实现"AI 自己写代码、自己编译、自己点模拟器、自己看报错再修"的闭环。

简单说，它给 AI 配了一双**眼睛（截图/UI 树）**和一双**手（点击/输入/构建）**，解决了你提到的"Agent 没法操控模拟器"的痛点。

## 2 功能

+ **构建与运行**：Agent 调用一个工具就能完成 `xcodebuild` 编译、安装到 Simulator 并启动，还能抓运行日志。
+ **UI 自动化**：截取模拟器屏幕、读取视图层级、执行点击（tap）、滑动（swipe）、输入文本等操作。
+ **调试能力**：Attach LLDB、设断点、看堆栈变量，把运行时错误反馈给 AI。
+ **项目管理**：自动发现 `.xcodeproj` / `.xcworkspace`，记住 Scheme 和模拟器配置，减少重复传参。

## 3 前置准备

+ 本地已安装 **Node.js (v18+)**（因为 xcodebuildmcp 通过 npx 运行）。
+ 已安装 **Xcode** 及命令行工具（`xcodebuild` 可用）。
+ 已安装并初始化 **Claude Code CLI**。

## 4 使用

### 4.1 安装 XcodeBuildMCP

需要 macOS + Xcode 16+，有两种常见装法：

+ **Homebrew**（推荐，无 Node 依赖）：

```bash
brew tap getsentry/xcodebuildmcp
brew install xcodebuildmcp
```

### 4.2 在 AI Agent 里配置 MCP 服务

在 Claude Code（或你用的支持 MCP 的配置）里添加服务器，让它启动时连上 XcodeBuildMCP：

#### Claude Code

```bash
claude mcp add --transport stdio XcodeBuildMCP -- npx -y xcodebuildmcp@latest mcp
```

#### opencode

编辑 `~/.config/opencode/opencode.json`：

```json
{
  "mcp": {
    "XcodeBuildMCP": {
      "type": "local",
      "command": ["npx", "-y", "xcodebuildmcp@latest", "mcp"],
      "enabled": true
    }
  }
}
```

### 4.3 在项目里做首次配置

进入你的 iOS 项目根目录，运行：

```bash
xcodebuildmcp setup
```

它会交互式生成 `.xcodebuildmcp/config.yaml`，包含：

+ 项目/workspace 路径
+ Scheme
+ 目标平台（iOS / macOS 等）
+ 默认模拟器
+ 启用的工作流

这样 Claude 在调用工具时就不用每次都让你指定 scheme、项目路径等信息，可以直接说类似：

> "Build and run my app on iPhone 17 Pro simulator and show any errors."

Claude 会通过 `session_set_defaults` + `build_sim` 等工具自动完成。

## 5 Agent 实际使用流程

配置好后，你在 Agent 里说一句话，它就会串联调用工具：

1. 让 Agent "构建并跑一下这个 iOS 项目"，它会调用 `simulator build-and-run` 编译安装启动。
2. 跑起来后，Agent 调用 `screenshot` 看模拟器画面，或 `snapshot-ui` 拿元素树。
3. 发现某个按钮没反应，Agent 调用 `ui-automation/tap` 自己去点，复现问题后读日志回传给你或直接修改代码重编。

本质上你不用手动去点 Simulator 了，Agent 通过 MCP 协议把这一系列 Xcode 操作都自动化了。

### 5.1 在 Claude Code 中实际使用

配置好后，在 Claude Code 对话里你可以直接下指令，比如：

+ "用模拟器编译并运行这个项目，把编译错误告诉我"
+ "列出当前可用的 iOS 模拟器并启动 iPhone 16 Pro"
+ "跑一下测试，告诉我哪些失败了"
+ "启动模拟器里的 App 并截个屏看看 UI"
+ "捕获一下运行时日志，看看有没有 crash"

Claude 会调用 xcodebuildmcp 提供的工具（如 `build_sim`、`test_sim`、`list_sims`、`boot_sim`、`screenshot`、`capture_logs` 等），返回的是**结构化 JSON 结果**，比直接让 Claude 跑裸 `xcodebuild` 解析几千行日志要可靠得多。
