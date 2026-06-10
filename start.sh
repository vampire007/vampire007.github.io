#!/bin/bash

# Jekyll 网站启动脚本
# 用于启动 vampire007.github.io 本地开发服务器

echo "🚀 启动 Jekyll 本地开发服务器..."

# 切换到项目目录
cd /Users/andy/andy/vampire007.github.io

# 设置 Ruby 路径（使用 Homebrew 安装的 Ruby）
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"

# 检查 Ruby 版本
echo "Ruby 版本: $(ruby --version)"
echo "Bundler 版本: $(bundle --version)"

# 启动 Jekyll 服务
echo ""
echo "📍 服务器地址: http://localhost:4000"
echo "⚡ 按 Ctrl+C 停止服务器"
echo ""

bundle exec jekyll serve
