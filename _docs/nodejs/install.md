---
title: Node.js 安装
layout: page
date: 2026-06-14 20:49:00 +0800
categories: [工具, Node.js]
tags: [Node.js, nvm, 安装]
---

# 安装地址
选择平台/机器/安装方式进行选择
https://nodejs.org/en/download

# Mac 下使用 nvm 来安装 node

```shell
# Download and install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash


# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"


# Download and install Node.js
nvm install 24


# Verify the Node.js version
node -v # Should print "v24.14.0".


# Verify npm version
npm -v # Should print "11.9.0".
```


