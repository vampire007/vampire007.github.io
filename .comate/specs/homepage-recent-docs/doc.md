# 首页展示最近文档功能

## 需求
首页目前使用 Chirpy 主题的 `layout: home`，仅展示 `_posts/` 中的博客文章（目前仅 2 篇）。站点实际的技术笔记内容存放在 `_docs/` 集合中（共 6 篇），但这些文档从未在首页展示，导致首页内容显得空荡。

用户希望首页能够展示最近发布的文档，让访问者一进入网站就能看到最新的内容。

## 架构与技术方案

### 核心思路
1. **覆盖（override）Chirpy 主题的 `home` 布局**：在站点中创建 `_layouts/home.html`，Jekyll 会优先使用站点目录下的布局文件而非主题 gem 中的同名文件。
2. **保留原有博文列表**：保持 Chirpy 主题 home 布局中 `site.posts` 的渲染逻辑不变。
3. **新增"最新文档"区块**：在博文列表下方增加一个区域，展示 `_docs` 集合中最近的文档。
4. **为文档添加日期元数据**：`_docs/` 中的文档缺少 `date` 字段，需要在每篇文档的 front matter 中补充 `date`，以便按时间排序。

### 数据流
```
用户访问首页
  ↓
_layouts/home.html (覆盖主题)
  ├── 渲染 site.posts 列表 (与主题原有行为一致)
  │     └── post-paginator.html (分页)
  └── 新增: 渲染 site.docs 列表 (按 date 降序排列, 取前 N 篇)
        └── 样式与 post-list 保持一致
```

### 影响范围
| 文件 | 修改类型 | 说明 |
|------|----------|------|
| `_layouts/home.html` | **新建** | 覆盖 Chirpy 主题的 home 布局，在博文列表后新增"最新文档"区块 |
| `_docs/git.md` | **修改 front matter** | 添加 `date` 字段 |
| `_docs/nodejs/cmd.md` | **修改 front matter** | 添加 `date` 字段 |
| `_docs/nodejs/install.md` | **修改 front matter** | 添加 `date` 字段 |
| `_docs/mac/brew.md` | **修改 front matter** | 添加 `date` 字段 |
| `_docs/claudeCodeCli/cc-tap.md` | **修改 front matter** | 添加 `date` 字段 |
| `_docs/claudeCodeCli/modelScope.md` | **修改 front matter** | 添加 `date` 字段 |
| `_docs/claudeCodeCli/tips.md` | **修改 front matter** | 添加 `date` 字段 |

### 实现细节

#### 1. `_layouts/home.html` 实现

基于 Chirpy 主题 `_layouts/home.html`（位于 gem `jekyll-theme-chirpy-7.5.0`），完整保留其原有逻辑，在 `#post-list` 和分页器之后新增文档区块。

新增的文档区块代码：

```html
<!-- #recent-docs -->
{% if site.docs.size > 0 %}
  {% assign sorted_docs = site.docs | sort: 'date' | reverse %}
  {% assign MAX_DOCS = 5 %}
  <section id="recent-docs" class="mt-5">
    <h2 class="mb-4">
      <i class="fas fa-book me-2"></i>
      {{ site.data.locales[lang].tabs.docs | default: "最新文档" }}
    </h2>
    <div id="doc-list" class="flex-grow-1 px-xl-1">
      {% for doc in sorted_docs limit: MAX_DOCS %}
        <article class="card-wrapper card">
          <a href="{{ doc.url | relative_url }}" class="post-preview row g-0 flex-md-row-reverse">
            <div class="col-md-12">
              <div class="card-body d-flex flex-column">
                <h1 class="card-title my-2 mt-md-0">{{ doc.title }}</h1>
                <div class="post-meta flex-grow-1 d-flex align-items-end">
                  <div class="me-auto">
                    <i class="far fa-calendar fa-fw me-1"></i>
                    {% include datetime.html date=doc.date lang=lang %}
                  </div>
                </div>
              </div>
            </div>
          </a>
        </article>
      {% endfor %}
    </div>
  </section>
{% endif %}
```

完整 `_layouts/home.html` 就是将 Chirpy 主题原始 home 布局（见 `doc.md` 附件 1）整体复制，然后在 `{% if paginator.total_pages > 1 %}...{% endif %}` 块之后插入上述文档区块代码。

#### 2. docs front matter 添加 `date` 字段

每篇文档在原有的 front matter 中添加 `date` 字段，格式为 `YYYY-MM-DD HH:MM:SS +/-TTTT`，例如：
```yaml
---
title: Git SSH 配置
layout: page
date: 2026-01-15 10:00:00 +0800
---
```

各文档的预计日期（根据内容性质估算，用户可自行调整）：
| 文档路径 | 建议 date |
|----------|-----------|
| `_docs/git.md` | `2026-01-15 10:00:00 +0800` |
| `_docs/nodejs/cmd.md` | `2026-02-20 10:00:00 +0800` |
| `_docs/nodejs/install.md` | `2026-02-20 10:00:00 +0800` |
| `_docs/mac/brew.md` | `2026-03-10 10:00:00 +0800` |
| `_docs/claudeCodeCli/cc-tap.md` | `2026-05-01 10:00:00 +0800` |
| `_docs/claudeCodeCli/modelScope.md` | `2026-05-20 10:00:00 +0800` |
| `_docs/claudeCodeCli/tips.md` | `2026-05-25 10:00:00 +0800` |

### 边界条件与异常处理
- **docs 为空**：不显示"最新文档"区块（通过 `{% if site.docs.size > 0 %}` 判断）
- **docs 数量不足 5 篇**：正常显示全部文档（`limit: MAX_DOCS` 会自动处理）
- **docs 无 date 字段**：Jekyll 对未设置 `date` 的文档将其视为 nil，sort 过滤器会跳过 nil 值
- **与博文列表的关系**：文档区块独立于博文列表，两者互不影响
- **响应式**：卡片样式与博文列表一致，使用 Chirpy 主题的 Bootstrap 类

### 预期效果
用户访问首页后，可以看到两个内容区域：
1. **博文列表**（上方）：显示 `_posts/` 中的文章（原有行为）
2. **最新文档**（下方）：显示 `_docs/` 中最近发布的 5 篇文档，带日期和标题，点击可跳转到文档详情页
