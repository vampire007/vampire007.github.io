---
layout: post
title: "Claude Code Lens (cc-tap) 教程：本地可视化监控你的 AI 编程会话"
date: 2026-07-05 +0800
categories: tool
---

每次用 Claude Code 写代码时，你是否好奇它到底读了哪些文件、调用了什么工具、消耗了多少 token？`cc-tap`（原名 cc-lens）就是一个运行在本地的分析仪表盘，专门用来可视化 Claude Code 的本地数据。

> **声明**：本项目由 [Theodo Group](https://github.com/Theodo-Group/cc-tap) 维护，是基于 [Arindam200/cc-lens](https://github.com/Arindam200/cc-lens) 的 fork。

## 它能看什么

`cc-tap` 读取 `~/.claude/` 目录下的 JSONL 会话日志和其他本地文件，提供以下视图：

**概览面板** — 会话数、消息数、token 用量、预估费用和本地存储占用。带有趋势卡片和迷你折线图，支持 7/30/90 天预设及自定义日期范围。

**项目视图** — 可搜索、可排序的项目网格。每个项目卡片显示会话数、持续时长、预估费用、使用的语言、git 分支和常用工具。

**会话回放** — 从 JSONL 重建的完整会话记录。助手回复渲染为 GitHub 风格 Markdown，工具调用和结果内联展示，每次交互显示模型、耗时、token 分解和预估费用。

**实时捕获（Live Capture）** — 通过代理拦截对 `api.anthropic.com` 的请求，实时查看 system prompt、缓存断点、工具 schema、消息历史和 SSE 响应。

**成本分析** — 总费用、缓存节省、按模型/项目的 token 和费用分解、缓存效率面板。

**工具与功能** — 工具排名、分类统计（文件 I/O、Shell、Agent、Web、MCP 等）、错误分析、Claude Code 版本历史、git 分支分析。

**活动日历** — 类似 GitHub Contribution 的热力日历，显示连续活跃天数、最长连续、最活跃时段等。

**本地文件浏览** — 直接搜索 `history.jsonl`、`todos`、`plans`、`memory` 文件和 `settings.json`。

## 快速开始

### 安装

无需全局安装，直接用 npx 启动：

```bash
npx cc-tap
```

CLI 会自动找一个空闲的本地端口，启动仪表盘并在浏览器中打开。

### 配置多 Profile

默认读取 `~/.claude/`。如果有多个 Claude Code 配置目录（比如工作用另一个），可以通过环境变量切换：

```bash
# 工作 Profile
CLAUDE_CONFIG_DIR=~/.claude-work npx cc-tap
```

PowerShell：

```powershell
$env:CLAUDE_CONFIG_DIR="C:\Users\you\.claude-work"; npx cc-tap
```

### 实时捕获用法

1. 点击顶部栏的 **Live Capture** → **Start**
2. 终端会弹出一个命令片段，复制后在新终端执行：

```bash
ANTHROPIC_BASE_URL=http://localhost:<port> claude
```

这样 Claude Code 的所有 API 请求都会经过本地代理，实时显示在仪表盘上。捕获的数据还会自动关联到对应的 JSONL 会话。

## 导航快捷键

| 快捷键 | 功能 |
|--------|------|
| `Cmd+K` / `Ctrl+K` / `/` | 全局搜索 |
| `j` / `k` | 会话列表上下移动 |
| `Enter` | 打开选中的会话 |
| `Esc` | 清除搜索 |
| `g` + `s` | 跳转到 Sessions |
| `g` + `p` | 跳转到 Projects |
| `g` + `c` | 跳转到 Costs |

## 数据源

`cc-tap` 只读取本地文件，不上传任何数据：

- `~/.claude/projects/<slug>/*.jsonl` — 会话日志
- `~/.claude/stats-cache.json` — 聚合统计
- `~/.claude/history.jsonl` — 命令历史
- `~/.claude/todos/` — TODO 文件
- `~/.claude/plans/` — 保存的计划
- `~/.claude/projects/*/memory/` — 项目记忆文件
- `~/.claude/settings.json` — 设置、技能、插件、MCP 配置

仪表盘每 5 秒自动刷新数据。

## 导出与导入

可以导出 `.cclens.json` 文件，包含统计数据、会话元数据和常用命令历史。支持跨机器导入（目前仅预览模式，不会写入 `~/.claude/` 以防损坏原始数据）。

## 总结

`cc-tap` 是一个轻量级的本地工具，帮你理解 Claude Code 到底在做什么——调用了什么工具、花了多少 token、用了哪个模型。对于经常用 Claude Code 做开发的人来说，是个不错的透明度补充。

项目地址：[theodo-group/cc-tap](https://github.com/Theodo-Group/cc-tap)
