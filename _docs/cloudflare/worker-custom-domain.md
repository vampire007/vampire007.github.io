---
title: Cloudflare Workers 自定义域名配置
layout: page
date: 2026-08-08 10:00:00 +0800
---

在 Cloudflare Workers 上绑定自定义域名，不是去 DNS 面板手写一条 CNAME 指向 `*.workers.dev`，而是在 Workers 侧声明自定义域名后，由 Cloudflare **自动**帮你创建 DNS 记录 + 签发 SSL 证书。这条 DNS 记录直接把你的域名"指"向这个 Worker，绕开了传统的 CNAME 链条。

> ⚠️ **Custom Domain 不能在「已有 CNAME 记录的主机名」上创建**，也不能用在非你拥有的 zone 上。所以如果你的域名已经托管在 Cloudflare，正确做法是走 Workers 控制台的 **Add Custom Domain**，而不是手动去 DNS 面板加 CNAME。

## 前置条件

- 你的域名已经托管在 Cloudflare（NS 指向 Cloudflare，zone 状态为 **Active**）
- 你已经部署了一个 Worker（`*.workers.dev` 默认地址能正常访问）

这两个条件缺一不可。Custom Domain 的本质是「Cloudflare 在自己的 DNS 系统里给你的 Worker 登记为某个主机名的源站」，域名不在 Cloudflare 就没法这么玩。

---

## 方法一：通过 Cloudflare 控制台添加（推荐）

1. 登录 Cloudflare 控制台，进入 **Workers & Pages**
2. 在 Overview 里选中你的 Worker
3. 进入 **Settings → Domains & Routes**
4. 点击 **Add → Custom Domain**
5. 输入你想绑定的域名或子域名，例如：
   - 根域名：`example.com`
   - 子域名：`api.example.com`
6. 点击 **Add Custom Domain**

Cloudflare 会自动做两件事：

- 在你的 zone 里创建一条指向该 Worker 的 DNS 记录（你会在 DNS 面板看到它，类型是**系统托管记录**，**不要手动改**）
- 为目标主机名签发一张 Advanced Certificate（SSL 证书自动管）

等待状态变成 **Active**，通常 1–5 分钟。期间证书状态可能短暂显示 Pending，属于正常。

> 💡 想同时支持 `www.example.com` 和根域名？Custom Domain 要求精确主机名匹配，`example.com` 不会自动接管 `www.example.com`。你需要**分别为 www 再添加一次 Custom Domain**，或者加一条 proxied 的 DNS 记录 + 重定向规则把 www 跳转到根域名。

---

## 方法二：通过 Wrangler 配置文件添加

如果你用 `wrangler.toml` / `wrangler.jsonc` 管理部署，在 `routes` 里加上 `custom_domain = true`：

```toml
[[routes]]
pattern = "api.example.com"
custom_domain = true
```

多个域名就写多条：

```toml
[[routes]]
pattern = "shop.example.com"
custom_domain = true

[[routes]]
pattern = "shop-two.example.com"
custom_domain = true
```

然后 `npx wrangler deploy`，Cloudflare 会创建对应的 Custom Domain。

---

## 迁移：从旧的 CNAME / Route 方式切换到 Custom Domain

这是很多人踩坑的地方。老的玩法是：在 DNS 里建一条 CNAME 指向 `100::`（IPv6 占位地址），再用 Route 规则 `example.com/*` 把请求转给 Worker。

现在官方推荐用 **Custom Domain** 替换这套老机制，迁移步骤：

1. 到 DNS 面板删除 `example.com` 那条旧的 CNAME 记录
2. 到 Worker 的 **Settings → Domains & Routes → Add → Custom Domain**，填入 `example.com`
3. 回到 **Domains & Routes**，删除旧的 `example.com/*` 路由

> ⚠️ 如果不先删 CNAME，Custom Domain 会因为「主机名已有 CNAME 记录」而创建失败。

---

## 几个容易忽略的细节

### 证书不会自动清理

你删掉 Custom Domain 后，Cloudflare 不会自动清理那张 Advanced Certificate。需要去 **SSL/TLS → Edge Certificates** 手动删除，否则证书清单里会留下孤儿记录。

### Custom Domain 匹配整个主机名

不像 Route 可以只匹配 `/api/*`，Custom Domain 是 `api.example.com` 下的**所有路径**都进同一个 Worker。如果你想在 Custom Domain 上再细分路径给其他 Worker，可以在 Custom Domain 之上叠加 Route 规则——**Route 会优先执行**，并可通过 `fetch(request)` 调用 Custom Domain 背后的 Worker。

### 同 zone 内 Worker 互调

一旦用了 Custom Domain，同 zone 内一个 Worker 可以直接 `fetch('https://api.example.com')` 调用另一个 Worker，不需要 Service Binding。这是 Custom Domain 相比传统 Route 的一个优势。

---

## 常见问题

| 问题 | 原因 | 解决 |
|------|------|------|
| 添加后一直 Pending | 证书签发中 | 等 1–5 分钟，通常会自动 Active |
| 提示「主机名已有 CNAME 记录」 | 旧 CNAME 未删除 | 先去 DNS 面板删除 CNAME，再重试 |
| 根域名绑定成功但 www 不行 | Custom Domain 不自动包含 www | 再添加一次 www 的 Custom Domain |
| 删除 Custom Domain 后证书还在 | 证书不会自动清理 | 去 SSL/TLS → Edge Certificates 手动删除 |
| 绑定后访问 404 | Worker 没有处理该路径 | 检查 Worker 代码是否正确响应 |

按上面步骤操作完，访问你的域名应该就能直接命中 Worker 了。如果一直没 Active，先检查 zone 是不是真的 Active、主机名是不是已经有别的 DNS 记录占着——这两个是最常见的卡点。
