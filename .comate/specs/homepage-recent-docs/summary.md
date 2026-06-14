# 首页展示最近文档 - 执行总结

## 完成情况

所有任务已成功完成，Jekyll 构建通过。

## 变更清单

### 1. 为所有 `_docs/` 文档添加 `date` 字段（7 个文件）

每个文档的 front matter 新增了 `date` 字段，从旧到新排列如下：

| 文件 | 设置日期 |
|------|----------|
| `_docs/git.md` | 2026-01-15 |
| `_docs/nodejs/cmd.md` | 2026-02-20 |
| `_docs/nodejs/install.md` | 2026-02-20 |
| `_docs/mac/brew.md` | 2026-03-10 |
| `_docs/claudeCodeCli/cc-tap.md` | 2026-05-01 |
| `_docs/claudeCodeCli/modelScope.md` | 2026-05-20 |
| `_docs/claudeCodeCli/tips.md` | 2026-05-25 |

### 2. 新建 `_layouts/home.html`

覆盖了 Chirpy 主题的 home 布局，在原有博文列表下方新增"最新文档"区块：
- 使用 `site.docs` 集合，按 `date` 字段降序排列
- 最多展示 5 篇文档
- 每篇文档渲染为与博文列表风格一致的卡片，包含文档标题和日期，可点击跳转
- 当 `_docs` 为空时不显示该区块

### 3. 构建验证

`bundle exec jekyll build` 成功，生成的 `_site/index.html` 中包含以下内容：
- `recent-docs` 区块
- "最新文档"标题
- 所有 5 篇最近文档的标题（跳过登录、魔搭社区、cc-tap 安装、Homebrew 安装、Node.js 安装）

## 注意事项

- 用户可以自行调整 `_docs/` 中各文档的 `date` 值以控制排序
- 如果之后添加新文档，记得在 front matter 中包含 `date` 字段
- 显示的文档数量 `MAX_DOCS = 5` 可在 `_layouts/home.html` 中调整
