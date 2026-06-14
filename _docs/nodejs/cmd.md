---
title: Node.js 常用命令
layout: page
date: 2026-02-20 10:00:00 +0800
---

以下是 Node.js 开发中常用的命令分类整理，涵盖包管理、脚本执行、模块管理、调试及环境配置等方面：

---

### 一、包管理（npm/yarn/pnpm）
1. **初始化项目**
   ```bash
   npm init          # 交互式生成 package.json
   npm init -y       # 使用默认配置快速生成
   ```

2. **安装依赖**
   ```bash
   npm install <pkg>         # 安装包（默认 --save）
   npm install <pkg>@<ver>   # 安装指定版本（如 npm install express@4.18）
   npm install -D <pkg>      # 安装开发依赖（--save-dev）
   npm install -g <pkg>      # 全局安装
   npm install               # 安装所有 package.json 中的依赖
   ```

3. **卸载依赖**
   ```bash
   npm uninstall <pkg>       # 卸载并从 package.json 移除
   npm uninstall -g <pkg>    # 卸载全局包
   ```

4. **更新依赖**
   ```bash
   npm update                # 更新所有依赖到最新兼容版本
   npm outdated              # 查看过期的依赖
   ```

5. **其他包管理命令**
   ```bash
   npm list                  # 查看已安装的依赖树
   npm list -g --depth=0     # 查看全局安装的顶层包
   npm cache clean --force   # 清理缓存
   ```

---

### 二、执行脚本
1. **运行 package.json 中的脚本**
   ```bash
   npm run <script>          # 如 npm run dev/start/build
   npm start                 # 快捷运行 start 脚本
   npm test                  # 快捷运行 test 脚本
   ```

2. **直接执行 Node.js 文件**
   ```bash
   node app.js               # 运行 JavaScript 文件
   node -e "console.log('Hello')"  # 执行内联代码
   ```

3. **使用 npx 执行包命令**
   ```bash
   npx create-react-app my-app  # 临时安装并执行包命令（无需全局安装）
   npx http-server              # 启动临时 HTTP 服务器
   ```

---

### 三、模块与版本管理
1. **nvm（Node Version Manager）**
   ```bash
   nvm install <version>    # 安装指定 Node.js 版本
   nvm use <version>        # 切换版本
   nvm ls                   # 查看已安装版本
   nvm alias default <ver>  # 设置默认版本
   ```

2. **npm 版本管理**
   ```bash
   npm version <ver>        # 更新包版本（如 npm version 1.2.3）
   npm version major        # 递增主版本号（1.x.x → 2.0.0）
   npm publish              # 发布包到 npm 仓库
   ```

---

### 四、调试与监控
1. **调试模式**
   ```bash
   node inspect app.js      # 启动调试器（Chrome DevTools 协议）
   node --inspect app.js    # 启用远程调试（默认端口 9229）
   node --inspect-brk app.js # 在首行暂停等待调试器连接
   ```

2. **性能监控**
   ```bash
   node --prof app.js       # 生成 V8 性能日志
   node --prof-process isolate-*.log  # 分析性能日志
   ```

3. **进程管理**
   ```bash
   pm2 start app.js         # 使用 PM2 启动守护进程
   pm2 list                 # 查看运行中的进程
   pm2 logs                 # 查看日志
   ```

---

### 五、环境与配置
1. **环境变量**
   ```bash
   NODE_ENV=production node app.js  # 设置环境变量
   ```

2. **Node.js 选项**
   ```bash
   node --max-old-space-size=4096 app.js  # 增加内存限制
   node --experimental-modules app.mjs    # 启用实验性 ESM 支持
   ```

---

### 六、其他实用命令
1. **查看信息**
   ```bash
   node -v                  # 查看 Node.js 版本
   npm -v                   # 查看 npm 版本
   node -e "console.log(process.versions)"  # 查看详细版本信息
   ```

2. **包文档**
   ```bash
   npm docs <pkg>           # 打开包的文档网站
   npm repo <pkg>           # 打开包的 GitHub 仓库
   ```

---

### 替代包管理器（Yarn/pnpm）
- **Yarn**:
  ```bash
  yarn add <pkg>           # 安装依赖
  yarn remove <pkg>        # 卸载依赖
  yarn upgrade             # 更新依赖
  ```
- **pnpm**:
  ```bash
  pnpm add <pkg>           # 安装依赖
  pnpm install             # 安装所有依赖
  pnpm store prune         # 清理未引用的存储
  ```

---

### 总结
- **开发核心**：`npm install/run/init`、`node app.js`
- **版本控制**：`nvm install/use`
- **调试优化**：`--inspect`、`--prof`
- **进程管理**：`pm2` 系列命令

根据需求选择工具，如追求速度可用 `pnpm`，稳定项目可用 `npm`，复杂进程用 `pm2`。