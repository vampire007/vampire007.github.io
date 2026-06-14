---
name: jekyll-doc-automation
description: Automatically process, format, and commit Jekyll Chirpy theme documentation. Use this skill whenever the user wants to add new Markdown documents to their Jekyll blog, needs to add proper front matter (title, layout, date, categories, tags) to raw Markdown files, or wants to automatically build and commit documentation changes to Git. This skill handles the complete workflow from raw Markdown to deployed GitHub Pages content.
---

# Jekyll Documentation Automation

This skill automates the complete workflow of adding new documentation to a Jekyll Chirpy theme blog. It transforms raw Markdown files into properly formatted documents with front matter, builds the site, and commits changes to Git.

## When to Use

Use this skill when:
- User has written a raw Markdown file and wants to add it to their Jekyll blog
- User mentions "add document", "new doc", "commit docs", or similar phrases
- User wants to automate the Jekyll documentation workflow
- Front matter needs to be added to Markdown files for Chirpy theme compatibility

## Workflow Overview

1. **Extract metadata** from the Markdown file or ask user for details
2. **Add front matter** with required fields (title, layout, date, categories, tags)
3. **Build the site** to verify everything works
4. **Commit and push** changes to Git repository

## Step-by-Step Process

### Step 1: Identify the Document

First, determine which Markdown file needs processing:

- If user specifies a file path, use that
- If user mentions a topic but no file, ask where the file is located
- Check if the file exists in `_docs/` directory

```bash
# Example: Check for new docs
ls -la _docs/*.md
```

### Step 2: Extract or Generate Metadata

#### Title Extraction
Try to extract the title from:
1. First H1 heading (`# Title`) in the Markdown content
2. Filename (convert kebab-case to Title Case)
3. Ask user if neither is clear

#### Categories and Tags
Ask the user interactively:

```
📝 Document Processing

File: <filename.md>
Detected Title: <extracted title>

Please provide:
1. Categories (comma-separated, e.g., "编程, Python"): 
2. Tags (comma-separated, e.g., "入门, 教程"): 
3. Auto-commit after processing? (yes/no): 
```

If user doesn't specify categories, default to `["docs"]`.

### Step 3: Add Front Matter

Create the front matter block with these required fields:

```yaml
---
title: <extracted or provided title>
layout: page
date: YYYY-MM-DD HH:mm:ss +0800
categories: [<category1>, <category2>]
tags: [<tag1>, <tag2>]
---
```

**Important notes:**
- `layout` must be `page` for Chirpy theme docs collection
- `date` should use current date/time in `+0800` timezone (China Standard Time)
- Use proper YAML list syntax with square brackets
- Ensure there's a blank line between front matter and content

#### Implementation

Read the original file, prepend the front matter, and write it back:

```python
# Pseudo-code for adding front matter
original_content = read_file(filepath)
front_matter = f"""---
title: {title}
layout: page
date: {current_date}
categories: [{categories}]
tags: [{tags}]
---

"""
new_content = front_matter + original_content.lstrip()
write_file(filepath, new_content)
```

### Step 4: Build and Verify

Run Jekyll build to ensure the document is properly processed:

```bash
cd /Users/andy/andy/vampire007.github.io
bundle exec jekyll build
```

Check for errors:
- If build fails, show error messages and help user fix issues
- If build succeeds, verify the document appears in search index

Optional: Check search index to confirm document is searchable:

```bash
cat _site/assets/js/data/search.json | python3 -m json.tool | grep "<title>"
```

### Step 5: Git Commit and Push

If user agreed to auto-commit:

```bash
# Stage the document
git add <filepath>

# Create descriptive commit message
git commit -m "docs: add <document title>"

# Push to remote repository
git push origin main
```

Show the user the commit status:

```
✅ Document processed and committed successfully!

File: <filepath>
Title: <title>
Categories: [<categories>]
Tags: [<tags>]
Commit: <commit hash>

Your document will be live on GitHub Pages in a few minutes.
```

## Edge Cases and Handling

### Missing Information

If critical information is missing:
- **No title found**: Ask user to provide one
- **File not found**: Ask for correct path
- **Not a Markdown file**: Warn user and ask for confirmation

### Existing Front Matter

If the file already has front matter:
- Detect existing front matter boundaries (`---`)
- Ask user if they want to:
  - Replace existing front matter
  - Update specific fields
  - Keep as-is

### Multiple Documents

If user wants to process multiple files:
- Process them in batch
- Show summary table of all processed documents
- Commit all at once with appropriate message

## Examples

### Example 1: Single Document Processing

**User input:**
```
我刚写了一个关于 Docker 的文档，在 _docs/docker.md，帮我处理一下
```

**Skill actions:**
1. Read `_docs/docker.md`
2. Extract title from first H1 or filename
3. Ask for categories and tags
4. Add front matter
5. Build site
6. Commit and push

### Example 2: Batch Processing

**User input:**
```
我在 _docs/ 目录下写了三个新文档，帮我全部处理并提交
```

**Skill actions:**
1. List all `.md` files in `_docs/`
2. Identify which ones lack front matter
3. Process each file (ask for metadata per file or use defaults)
4. Build site once
5. Commit all files together

### Example 3: Quick Add with Defaults

**User input:**
```
快速添加一个文档，标题是 "Linux 常用命令"，内容在剪贴板
```

**Skill actions:**
1. Create new file: `_docs/linux-commands.md`
2. Use provided title
3. Use default categories: `["docs"]`
4. Use current date
5. Add content from clipboard
6. Build, commit, push

## Best Practices

### Naming Conventions
- Use kebab-case for filenames: `my-document.md`
- Use descriptive titles in front matter
- Keep URLs clean and readable

### Categories Strategy
Suggest common categories based on project structure:
- `编程` - Programming tutorials
- `工具` - Tool usage guides
- `配置` - Configuration guides
- `笔记` - Learning notes

### Commit Messages
Follow conventional commits pattern:
- `docs: add <title>` - New document
- `docs: update <title>` - Updated document
- `docs: fix <title>` - Fixed errors in document

## Troubleshooting

### Build Fails
Common causes:
- Invalid YAML in front matter (check indentation)
- Missing required fields
- Special characters not properly escaped

### Search Not Working
Verify:
- Document has `layout: page`
- Document is in `_docs/` directory
- Site was rebuilt after adding document
- Check `_site/assets/js/data/search.json` contains the document

### Git Conflicts
If push fails:
```bash
git pull origin main --rebase
git push origin main
```

## Quick Reference

### Required Front Matter Fields
```yaml
title: string      # Document title
layout: page       # Must be "page" for docs
date: datetime     # YYYY-MM-DD HH:mm:ss +0800
```

### Optional Fields
```yaml
categories: [string]  # Document categories
tags: [string]        # Document tags
```

### File Location
All documentation files should be in: `_docs/` directory

### Build Command
```bash
bundle exec jekyll build
```

### Commit Pattern
```bash
git add _docs/<filename>.md
git commit -m "docs: <action> <title>"
git push origin main
```
