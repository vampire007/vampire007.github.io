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
3. **Process images** - detect and fix image paths to use assets directory
4. **Build the site** to verify everything works
5. **Commit and push** changes to Git repository

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

### Step 3: Process Images (Critical)

Jekyll Chirpy theme requires images to be in the `assets/` directory for proper rendering. This step automatically handles all image references.

#### Image Path Problem
When Markdown uses relative image paths like:
```markdown
![description](img.png)
![description](./image.jpg)
```

Jekyll may not resolve these correctly, causing broken images on the rendered page.

#### Solution: Move Images to Assets Directory

**Step 3.1: Detect all image references in the document**

Search for image patterns in the Markdown file:
```bash
# Find all image references
grep -oE '!\[.*?\]\(([^)]+\.png|[^)]+\.jpg|[^)]+\.jpeg|[^)]+\.gif|[^)]+\.webp)\)' <filepath>
```

**Step 3.2: Extract image filenames**

For each image reference, extract the filename (e.g., `img.png`, `screenshot.jpg`).

**Step 3.3: Determine source and destination paths**

- Source: Check if image exists in the same directory as the Markdown file
- Destination: `assets/img/docs/<subdirectory>/` where `<subdirectory>` matches the doc's location

Example mapping:
- `_docs/mac/github加速.md` → images go to `assets/img/docs/mac/`
- `_docs/nodejs/install.md` → images go to `assets/img/docs/nodejs/`
- `_docs/git.md` → images go to `assets/img/docs/`

**Step 3.4: Create destination directory and copy images**

```bash
# Create directory structure
mkdir -p assets/img/docs/<subdirectory>

# Copy all images
cp _docs/<subdirectory>/*.png assets/img/docs/<subdirectory>/
cp _docs/<subdirectory>/*.jpg assets/img/docs/<subdirectory>/
# ... repeat for other image formats
```

**Step 3.5: Update image paths in Markdown**

Replace all relative image paths with absolute paths to assets directory:

Before:
```markdown
![img.png](img.png)
![screenshot](./screenshot.jpg)
```

After:
```markdown
![img.png](/assets/img/docs/mac/img.png)
![screenshot](/assets/img/docs/mac/screenshot.jpg)
```

Use search and replace to update all image references:
```python
# Pseudo-code for updating image paths
import re

# Pattern to match markdown images
image_pattern = r'!\[(.*?)\]\(([^)]+\.(?:png|jpg|jpeg|gif|webp))\)'

def update_image_path(match):
    alt_text = match.group(1)
    original_path = match.group(2)
    filename = os.path.basename(original_path)
    
    # Determine subdirectory based on doc location
    # e.g., _docs/mac/file.md -> mac
    subdirectory = get_doc_subdirectory(filepath)
    
    new_path = f'/assets/img/docs/{subdirectory}/{filename}'
    return f'![{alt_text}]({new_path})'

updated_content = re.sub(image_pattern, update_image_path, content)
```

**Important notes:**
- Always use absolute paths starting with `/` for assets
- Preserve the original alt text
- Handle both relative paths (`img.png`) and current directory paths (`./img.png`)
- Support common image formats: png, jpg, jpeg, gif, webp

### Step 4: Add Front Matter

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

### Step 5: Build and Verify

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

### Step 6: Git Commit and Push

If user agreed to auto-commit:

```bash
# Stage the document AND images
git add <filepath>
git add assets/img/docs/<subdirectory>/*

# Create descriptive commit message
git commit -m "docs: add <document title> with images"

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
Images: <count> images moved to assets/
Commit: <commit hash>

Your document will be live on GitHub Pages in a few minutes.
```

### Edge Cases and Handling

#### No Images Found
If the document has no images:
- Skip image processing step
- Show message: "ℹ️ No images detected in this document"

#### Images Already in Assets
If images are already referenced with `/assets/` path:
- Skip those images
- Only process images with relative paths

#### Missing Image Files
If an image is referenced but file doesn't exist:
- Warn user: "⚠️ Image file not found: <path>"
- Continue processing other images
- Don't fail the entire workflow

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

### Example 1: Single Document with Images

**User input:**
```
我刚写了一个关于 Docker 的文档，在 _docs/docker.md，帮我处理一下
```

**Skill actions:**
1. Read `_docs/docker.md`
2. Extract title from first H1 or filename
3. Ask for categories and tags
4. **Detect images in document**
5. **Copy images to `assets/img/docs/`**
6. **Update image paths to absolute paths**
7. Add front matter
8. Build site
9. Commit document AND images
10. Push to remote

### Example 2: Document Without Images

**User input:**
```
处理一下 _docs/git.md 这个文档
```

**Skill actions:**
1. Read `_docs/git.md`
2. Detect no images present
3. Skip image processing
4. Add front matter
5. Build site
6. Commit only the document
7. Push to remote

### Example 3: Batch Processing

**User input:**
```
我在 _docs/ 目录下写了三个新文档，帮我全部处理并提交
```

**Skill actions:**
1. List all `.md` files in `_docs/`
2. Identify which ones lack front matter
3. For each file:
   - Process images (if any)
   - Ask for metadata or use defaults
   - Add front matter
4. Build site once
5. Commit all files and images together

### Example 4: Quick Add with Defaults

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
6. **Process images if any**
7. Build, commit, push

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

### Image Path Issues

Symptoms:
- Images show as broken icons
- Console shows 404 errors for image files

Solutions:
- Ensure images are in `assets/img/docs/<subdirectory>/`
- Verify paths start with `/` (absolute paths)
- Check that images were copied during processing
- Rebuild site after moving images

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
git add assets/img/docs/<subdirectory>/*
git commit -m "docs: <action> <title>"
git push origin main
```

### Image Processing Quick Reference

**Image Directory Structure:**
```
assets/img/docs/
├── mac/           # Images for _docs/mac/*.md
├── nodejs/        # Images for _docs/nodejs/*.md
├── claudeCodeCli/ # Images for _docs/claudeCodeCli/*.md
└── ...            # Other subdirectories as needed
```

**Image Path Format:**
```markdown
# Correct (absolute path)
![description](/assets/img/docs/mac/image.png)

# Incorrect (relative path - will break)
![description](image.png)
![description](./image.png)
```

**Supported Image Formats:**
- PNG (.png)
- JPEG (.jpg, .jpeg)
- GIF (.gif)
- WebP (.webp)
