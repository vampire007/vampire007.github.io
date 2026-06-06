# CLAUDE.md

本文件为 Claude Code (claude.ai/code) 提供本仓库的工作指引。

## 仓库概述

基于 Jekyll 的个人编码笔记博客，托管在 GitHub Pages。内容中英混杂，涵盖开发工具配置（Git SSH 密钥、Homebrew 国内镜像、Node.js/nvm 安装）和考试学习笔记（系统架构设计师软考）。

## 常用命令

```bash
bundle exec jekyll serve          # 本地开发服务器，自动刷新（默认 http://localhost:4000）
bundle exec jekyll build          # 构建静态站点到 _site/
bundle install                    # 安装/更新 Ruby 依赖
```

修改 `_config.yml` 后需重启服务器，配置文件不会自动热加载。

## 架构

- **Minima 主题**，无自定义 `_layouts/` 或 `_includes/` 覆盖——所有模板来自主题 gem。
- **`_posts/`** — 博客文章，遵循 `YYYY-MM-DD-title.markdown` 命名规范，带 YAML front matter。`_posts/r.md` 是一篇独立的考试笔记（未遵循命名规范）。
- **`hacker/`** — 技术指南，按主题组织为子目录中的 `.md` 文件（`hacker/git.md`、`hacker/nodejs/install.md`、`hacker/nodejs/cmd.md`、`hacker/mac/brew.md`）。使用 `layout: page`，是独立页面而非文章。
- **配置** — `_config.yml` 使用 kramdown + MathJax (`math_engine: mathjax`) 和 Rouge 语法高亮。未使用 `github-pages` gem，直接使用 Jekyll 4.4.1。
- **部署** — 推送到 `main` 分支即触发 GitHub Pages 自动部署。

## 内容规范

- 内容中英混杂，编辑时请匹配周围内容的语言风格。
- `hacker/` 下的指南为实操配置笔记（镜像源、SSH 配置、nvm 安装等），保持简练、以命令为主。
- 文章 front matter 必须包含：`layout`、`title`、`date`（带时区如 `+0800`）。