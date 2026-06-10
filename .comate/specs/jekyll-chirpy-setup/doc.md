# Jekyll Chirpy 主题配置与目录结构保持

## 需求分析

用户希望：
1. 使用 jekyll-theme-chirpy 主题替换当前的 minima 主题
2. 将 `hacker/` 目录下的文档在渲染为网页时保持原有的目录结构

## 当前项目结构

```
hacker/
├── claudeCodeCli/
│   ├── cc-tap.md
│   ├── img_1.png
│   ├── img_2.png
│   ├── img_3.png
│   ├── img.png
│   ├── modelScope.md
│   └── tips.md
├── mac/
│   └── brew.md
├── nodejs/
│   ├── cmd.md
│   └── install.md
└── git.md
```

## 解决方案

### 方案：使用 _docs Collection

Chirpy 主题支持 `_docs` 目录作为文档集合，可以自动保持目录结构并生成侧边栏导航。

**步骤：**
1. 将 `hacker/` 目录重命名为 `_docs/`
2. 更新 `_config.yml` 添加 docs collection 配置
3. 更新 Gemfile 使用 chirpy 主题
4. 调整文档的 front matter

## 配置文件修改

### 1. _config.yml 关键配置

```yaml
theme: jekyll-theme-chirpy
collections:
  docs:
    layout: doc
    title: Hacker Notes
    nav: true
```

### 2. 目录重命名

- `hacker/` → `_docs/`
- `_docs/` 下的子目录会作为分类显示

### 3. 文档 front matter 要求

每个文档需要包含：
```yaml
---
title: 文档标题
---

或使用分类导航：

```yaml
---
title: 文档标题
category: 子目录名
---
```

## 受影响文件

1. **目录重命名**：
   - `hacker/` → `_docs/`

2. **配置文件修改**：
   - `_config.yml` - 更新主题和添加 collection 配置
   - `Gemfile` - 更新主题 gem

3. **可能需要调整**：
   - 各文档的 front matter（添加 title 等元数据）

## 预期结果

应用后，网站将：
- 使用 Chirpy 主题的美观界面
- `_docs/` 下的目录结构会作为侧边栏分类导航
- 每个子目录成为一组文档分类