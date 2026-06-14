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
3. **Update navigation index** in `_tabs/docs.md` to add the document to the sidebar
4. **Build the site** to verify everything works
5. **Commit and push** changes to Git repository

## Step 3: Add Front Matter

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

## Step 3b: Update Navigation Index

After adding front matter and before building, update `_tabs/docs.md` to include the new document in the sidebar navigation.

### Navigation Mapping

Map the document's subdirectory to the corresponding `### Category` in `docs.md`:

| `_docs/` subdirectory | `docs.md` category header |
|---|---|
| `mac/` | `### Mac` |
| `nodejs/` | `### Node.js` |
| `claudeCodeCli/` | `### Claude Code CLI` |
| root (no subdirectory) | `### Git` (or default last category) |

### Update Logic

1. Read `_tabs/docs.md`
2. Extract the subdirectory from the document path (e.g., `_docs/mac/github加速.md` → `mac`)
3. Map the subdirectory to the `### Category` header using the table above
4. Search within that category block for an existing `- [title]` link
   - **If found**: the document already has a nav entry (skip)
   - **If not found**: append a new entry after the last `- [xxx]` in that category block
5. New entry format: `- [Title](/docs/subdirectory/filename/) `

### Example

For `_docs/mac/github加速.md` with title `GitHub 加速`:

```markdown
### Mac
- [Homebrew 安装与配置](/docs/mac/brew/)
- [GitHub 加速](/docs/mac/github加速/)
```

### Edge Cases

- **No matching category found**: Prompt user which category to add the document to, or append a new category block at the end
- **Batch processing multiple docs in the same category**: Collect all new titles first, then do a single update to avoid multiple passes over the file
- **Document is in `_docs/` root**: Add to the first category that makes sense or prompt the user

### Implementation (bash/awk)

```bash
# Extract subdirectory from file path
dir=$(dirname "$file")
subdir=$(basename "$dir")

# Map subdirectory to category header
case "$subdir" in
    mac) category="### Mac" ;;
    nodejs) category="### Node.js" ;;
    claudeCodeCli) category="### Claude Code CLI" ;;
    *) category="### Git" ;;
esac

# Check if entry already exists
if ! grep -q "\- \[${title}\]" _tabs/docs.md; then
    expected_url="/docs/${subdir}/$(basename "$file" .md)/"
    nav_entry="- [${title}](${expected_url})"
    
    awk -v entry="$nav_entry" -v cat="$category" '
        BEGIN { in_cat = 0; last_item = -1 }
        /^- \[/ && in_cat { last_item = NR }
        $0 ~ cat { if ($0 ~ ("^" cat "$")) in_cat = 1 }
        /^### / && !($0 ~ ("^" cat "$")) { in_cat = 0 }
        { lines[NR] = $0; total = NR }
        END {
            if (last_item > 0) {
                for (i = 1; i <= last_item; i++) print lines[i]
                print entry
                for (i = last_item + 1; i <= total; i++) print lines[i]
            } else {
                for (i = 1; i <= total; i++) print lines[i]
            }
        }
    ' _tabs/docs.md > /tmp/docs_nav_new.md && mv /tmp/docs_nav_new.md _tabs/docs.md
fi
```

## Step 4: Build and Verify

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
5. Update `_tabs/docs.md` navigation index
6. Build site
7. Commit and push

### Example 2: Batch Processing

**User input:**
```
我在 _docs/ 目录下写了三个新文档，帮我全部处理并提交
```

**Skill actions:**
1. List all `.md` files in `_docs/`
2. Identify which ones lack front matter
3. Process each file (ask for metadata per file or use defaults)
4. Update `_tabs/docs.md` navigation index for all new docs
5. Build site once
6. Commit all files together

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
