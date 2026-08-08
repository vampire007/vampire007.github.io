---
layout: page
title: Jekyll 博客添加 PV 统计与评论区
date: 2026-08-08 10:00:00 +0800
description: 使用 Cloudflare Workers + Durable Objects 实现文章阅读统计，以及 Giscus 接入 GitHub Discussions 评论系统
categories: [Jekyll, 教程]
tags: [jekyll, cloudflare, pv, giscus, comments]
---

本教程介绍如何为你的 Jekyll 博客添加两个实用功能：**文章阅读统计（PV Counter）** 和 **评论区（Giscus）**。

---

## 一、PV 阅读统计

### 1. 方案说明

使用 Cloudflare Workers + Durable Objects 实现原子计数，每个页面路径对应一个独立的 Durable Object 实例，避免并发冲突。

### 2. 创建 Cloudflare Worker

#### 步骤 1：登录 Cloudflare Dashboard

访问 [https://dash.cloudflare.com](https://dash.cloudflare.com) 登录你的账号。

#### 步骤 2：创建 Worker 项目

在本地创建一个新目录（例如 `worker/`），初始化 Wrangler 项目：

```bash
mkdir worker && cd worker
npx wrangler init jekyll-pv-do
```

#### 步骤 3：编写 Worker 代码

创建 `worker/index.js`：

```javascript
export class PageViewCounter {
  constructor(state, env) {
    this.state = state
    this.data = { pageViews: {}, total: 0 }
    this.storagePromise = this.state.storage.get('data').then(d => {
      if (d) this.data = d
    })
  }

  async fetch(request) {
    await this.storagePromise
    const url = new URL(request.url)
    const page = url.searchParams.get('page') || '/'

    if (request.method === 'POST') {
      if (!this.data.pageViews[page]) {
        this.data.pageViews[page] = 0
      }
      this.data.pageViews[page] += 1
      this.data.total += 1
      this.state.storage.put('data', this.data)
    }

    return new Response(JSON.stringify({
      page,
      count: this.data.pageViews[page] || 0,
      total: this.data.total
    }), {
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      }
    })
  }
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url)

    if (url.pathname !== '/track') {
      return new Response('Not Found', { status: 404 })
    }

    const origin = request.headers.get('Origin') || ''
    const referer = request.headers.get('Referer') || ''
    const allowedHosts = ['yourdomain.com']
    const isAllowed = allowedHosts.some(h => origin.includes(h) || referer.includes(h))
    if (!isAllowed) {
      return new Response('Forbidden', { status: 403 })
    }

    const page = url.searchParams.get('page') || '/'
    const id = env.PV_COUNTER.idFromName(page)
    const stub = env.PV_COUNTER.get(id)
    return stub.fetch(request)
  }
}
```

**注意**：将 `allowedHosts` 数组中的 `yourdomain.com` 替换为你的实际域名。

#### 步骤 4：配置 Wrangler

创建 `worker/wrangler.toml`：

```toml
name = "jekyll-pv-do"
main = "index.js"
compatibility_date = "2025-04-05"

[[durable_objects]]
name = "PV_COUNTER"
class_name = "PageViewCounter"

[[migrations]]
tag = "v1"
new_sqlite_classes = ["PageViewCounter"]
```

#### 步骤 5：部署 Worker

```bash
cd worker
npx wrangler deploy
```

部署成功后，你会看到一个默认域名（如 `jekyll-pv-do.your-account.workers.dev`）。

### 3. 配置自定义域名（可选）

在 Cloudflare Dashboard 中：

1. 进入 **Workers & Pages** → 选择你的 Worker
2. 点击 **Triggers** → **Add Custom Domain**
3. 输入你的子域名（如 `pv.yourdomain.com`）
4. 在 DNS 设置中添加 CNAME 记录指向 Worker 域名

### 4. 在 Jekyll 中添加 PV 统计

#### 步骤 1：创建 PV 统计组件

创建 `_includes/pv-counter.html`：

```html
<div class="pv-counter" id="pv-counter">
  <span class="pv-item">阅读 <span id="pv-count" class="pv-num">—</span></span>
  <span class="pv-sep">·</span>
  <span class="pv-item">全站 <span id="pv-total" class="pv-num">—</span></span>
</div>

<script>
(function() {
  var apiUrl = 'https://jekyll-pv-do.yourdomain.com/track';
  var page = window.location.pathname;

  function render(count, total) {
    document.getElementById('pv-count').textContent = count;
    document.getElementById('pv-total').textContent = total;
  }

  fetch(apiUrl + '?page=' + encodeURIComponent(page), {
    method: 'POST',
    credentials: 'omit'
  }).then(function(r) { return r.json(); })
    .then(function(d) { render(d.count, d.total); })
    .catch(function() {
      fetch(apiUrl + '?page=' + encodeURIComponent(page) + '&dry=1')
        .then(function(r) { return r.json(); })
        .then(function(d) { render(d.count, d.total); })
    });
})();
</script>

<style>
.pv-counter {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.85rem;
  color: var(--text-muted-color, #6c757d);
  padding: 0.5rem 0;
  margin-top: 0.5rem;
}
.pv-num {
  font-weight: 600;
  color: var(--text-color, #212529);
}
.pv-sep {
  opacity: 0.5;
}
</style>
```

**注意**：将 `apiUrl` 中的域名替换为你的 Worker 域名。

#### 步骤 2：在文章页面中引入

在 `_layouts/post.html` 中添加（在内容下方）：

```liquid
<div class="content">
  {{ content }}
</div>

{% include pv-counter.html %}
```

---

## 二、Giscus 评论区

### 1. 前置条件

giscus 连接你的 GitHub 仓库需要满足以下三个硬性条件：

| 条件 | 说明 |
|------|------|
| **公开仓库** | 访客需要读取 Discussions 内容，私有仓库会导致评论区无法加载 |
| **已安装 Giscus App** | giscus 读写 Discussions 的授权凭证，未安装则无法评论 |
| **已启用 Discussions** | 在仓库 Settings → Features 中勾选 Discussions |

### 2. 安装 Giscus App

访问 [Giscus GitHub App 安装页](https://github.com/apps/giscus/installations/new)，选择你的博客仓库进行安装。

### 3. 配置 Giscus

#### 步骤 1：访问 giscus.app

打开 [https://giscus.app](https://giscus.app)，按照提示：

1. 选择你的 GitHub 仓库
2. 创建一个 Discussion 分类（如 `Comments` 或 `Q&A`）
3. 获取配置参数：
   - `data-repo`：仓库名，格式为 `username/repo`
   - `data-repo-id`：仓库的 GraphQL ID
   - `data-category`：分类名称
   - `data-category-id`：分类的 GraphQL ID

#### 步骤 2：获取 ID

在浏览器中查看 giscus.app 生成的代码，或右键页面查看源码，找到类似这样的内容：

```html
data-repo-id="R_kgDOxxxxxx"
data-category-id="DIC_kwDOxxxxxx"
```

### 4. 在 Jekyll 中配置

#### 方法一：使用 Chirpy 主题（推荐）

在 `_config.yml` 中添加：

```yaml
comments:
  provider: giscus
  giscus:
    repo: username/repo-name
    repo_id: 'R_kgDOxxxxxx'
    category: Comments
    category_id: 'DIC_kwDOxxxxxx'
    mapping: pathname
    strict: 0
    reactions_enabled: 1
    emit_metadata: 0
    input_position: bottom
    lang: zh-CN
```

#### 方法二：手动添加

在 `_layouts/post.html` 中添加：

```liquid
{% if site.comments.provider == 'giscus' %}
  <div id="giscus-thread"></div>
  <script>
    const giscus = document.createElement('script');
    giscus.src = 'https://giscus.app/client.js';
    giscus.setAttribute('data-repo', '{{ site.comments.giscus.repo }}');
    giscus.setAttribute('data-repo-id', '{{ site.comments.giscus.repo_id }}');
    giscus.setAttribute('data-category', '{{ site.comments.giscus.category }}');
    giscus.setAttribute('data-category-id', '{{ site.comments.giscus.category_id }}');
    giscus.setAttribute('data-mapping', '{{ site.comments.giscus.mapping | default: "pathname" }}');
    giscus.setAttribute('data-strict', '{{ site.comments.giscus.strict | default: 0 }}');
    giscus.setAttribute('data-reactions-enabled', '{{ site.comments.giscus.reactions_enabled | default: 1 }}');
    giscus.setAttribute('data-emit-metadata', '{{ site.comments.giscus.emit_metadata | default: 0 }}');
    giscus.setAttribute('data-input-position', '{{ site.comments.giscus.input_position | default: "top" }}');
    giscus.setAttribute('data-lang', '{{ site.comments.giscus.lang | default: "zh-CN" }}');
    document.head.appendChild(giscus);
  </script>
{% endif %}
```

### 5. 配置说明

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `mapping` | 页面映射方式（`pathname`/`url`/`title` 等） | `pathname` |
| `strict` | 是否严格匹配标题（0=关闭，1=开启） | `0` |
| `reactions_enabled` | 是否启用表情反应 | `1` |
| `emit_metadata` | 是否发送元数据 | `0` |
| `input_position` | 评论框位置（`top`/`bottom`） | `top` |
| `lang` | 界面语言 | `zh-CN` |

---

## 三、常见问题

### Q1: PV 统计不工作？

检查以下几点：
- Worker 是否已部署（访问 `https://your-worker.workers.dev/track?page=/'` 看是否返回 JSON）
- 浏览器控制台是否有 CORS 错误
- `_includes/pv-counter.html` 中的 API URL 是否正确

### Q2: 评论区不显示？

检查以下几点：
- 仓库是否公开
- Giscus App 是否已安装（在仓库 Settings → Applications 中查看）
- Discussions 功能是否已启用（在仓库 Settings → Features 中勾选）
- `repo_id` 和 `category_id` 是否正确

### Q3: 如何实现防盗链？

在 Worker 代码中添加 Referer/Origin 检查：

```javascript
const allowedHosts = ['yourdomain.com'];
const isAllowed = allowedHosts.some(h => 
  origin.includes(h) || referer.includes(h)
);
if (!isAllowed) {
  return new Response('Forbidden', { status: 403 });
}
```

### Q4: 私有仓库如何实现评论功能？

参考 giscus 官方文档：[私有仓库解决方案](https://giscus.app/zh-CN#%E7%A7%81%E6%9C%89%E4%BB%93%E5%BA%93%E7%9A%84%E8%A7%A3%E5%86%B3%E6%96%B9%E6%A1%88)

核心思路：新建一个公开仓库专门存放评论，在配置中指向这个公开仓库。

---

## 四、参考链接

- [Cloudflare Workers 文档](https://developers.cloudflare.com/workers/)
- [Durable Objects 文档](https://developers.cloudflare.com/durable-objects/)
- [Giscus 官方文档](https://giscus.app/zh-CN)
- [Wrangler CLI 文档](https://developers.cloudflare.com/workers/wrangler/)