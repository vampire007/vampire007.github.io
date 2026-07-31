---
title: DigitalPlat 免费域名接入 Cloudflare
layout: page
date: 2026-08-01 10:00:00 +0800
---

## 一、注册 DigitalPlat 免费二级域名

访问 [DigitalPlat](https://digitalplat.org/)，使用 GitHub OAuth 登录即可快速注册。支持的免费二级域名包括 `.dpdns.org`、`.us.kg`、`.qzz.io` 等。

## 二、将 Nameserver 指向 Cloudflare

在 DigitalPlat 后台的 DNS 管理页面，将 Nameservers 改为 Cloudflare 提供的两个 NS 地址（格式示例）：

```
lun.ns.cloudflare.com
tom.ns.cloudflare.com
```

修改后等待 DNS 生效，可通过以下命令验证：

```bash
nslookup -type=ns your-domain.dpdns.org
```

若返回的 Nameserver 与 Cloudflare 一致，说明已顺利对接。

## 三、在 Cloudflare 中配置 CNAME 或 URL 重定向

### A. Apex 域名 CNAME（Cloudflare CNAME Flattening）

对于根域名（如 `example.com` 映射到 DigitalPlat 的 apex），Cloudflare 提供 CNAME Flatten 功能。在 DNS 记录中添加一条 CNAME 记录：

- **Name**: `@` （或留空）
- **Target**: DigitalPlap 分配的域名（如 `yourname.dpdns.org`）
- **Proxy status**: 开启橙色云（Proxied）

> ⚠️ 注意：开启 CNAME Flatten 后，Cloudflare 会自动将 CNAME 解析为 A 记录，以兼容根域名对 CNAME 的限制。

### B. 子域名或路径级 CNAME

对于子域名（如 `blog.yourname.dpdns.org`）或更细粒度的场景：

- **Name**: `blog`（或其他子域名前缀）
- **Target**: 后端服务域名（如 `your-site.cloudapp.net`）
- **Proxy status**: 根据需求选择（静态资源建议开启橙色云，API 可选灰色云）

### C. URL 重定向（推荐用于简单跳转）

如果只需将 DigitalPlat 免费域名跳转到自有域名，可在 Cloudflare Pages Rules 或 Redirect Rules 中设置：

```
From: https://yourname.dpdns.org/*
To: https://your-main-domain.com/$1
Status: 301 Permanent
```

或在 Page Rules 中选择「Forwarding URL」并设置为 301 永久重定向。

## 四、常见坑点

- 🕐 DNS 传播可能需要数分钟至数小时不等，请耐心等待。
- 🔒 开启代理（橙色云）可启用 CDN 加速和 WAF 防护；关闭代理（灰色云）则只做 DNS 解析。
- 📍 某些第三方服务（如 Let's Encrypt）可能对 CNAME 有校验要求，请确保在证书申请前完成 DNS 同步。
- 🔄 若同时使用了 Cloudflare Tunnel，请确认端点可达性并检查 Firewall Rules 是否拦截了流量。

## 五、总结

本教程遵循「注册 → NS 改到 Cloudflare → 在 CF 里把新域名 CNAME 到老域名」三步走流程，配置完成后即可通过 DigitalPlat 免费二级域名访问您的服务。遇到任何网络不连通问题，优先检查 DNS 解析状态和 Cloudflare 代理开关。