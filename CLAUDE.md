# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Jekyll-based static website hosted on GitHub Pages. The site serves as a personal coding notes blog with content focused on development topics like Git and Homebrew configuration.

## Common Development Commands

### Local Development
```bash
# Serve the site locally with live reload
bundle exec jekyll serve

# Build the site
bundle exec jekyll build

# Serve with specific port and host
bundle exec jekyll serve --host 0.0.0.0 --port 4000
```

### Dependency Management
```bash
# Install or update dependencies
bundle install

# Update gems
bundle update
```

## Code Architecture and Structure

### Key Directories and Files
- `_config.yml` - Main Jekyll configuration file
- `_posts/` - Blog posts in format `YYYY-MM-DD-title.markdown`
- `_site/` - Generated static site (don't edit directly)
- `index.markdown` - Homepage content
- `about.markdown` - About page
- `hacker/` - Directory containing technical guides (Git, Homebrew)
- `Gemfile` - Ruby gem dependencies
- `_layouts/` - Page templates (provided by minima theme)

### Content Structure
- Posts follow Jekyll naming convention: `YYYY-MM-DD-title.format`
- Posts use YAML front matter for metadata (layout, title, date, categories)
- Technical guides are written in Markdown format
- Site uses the minima theme with jekyll-feed plugin

### Theme Customization
The site uses the minima theme. Customization can be done by:
- Overriding theme layouts in `_layouts/`
- Adding custom CSS in `assets/main.scss`
- Modifying configurations in `_config.yml`

## Workflow Guidelines

### Adding New Content
1. Create new posts in `_posts/` with proper naming format
2. Use YAML front matter for post metadata
3. Write content in Markdown
4. Test locally with `bundle exec jekyll serve`

### Making Configuration Changes
1. Modify `_config.yml` for site-wide settings
2. Update `Gemfile` for dependency changes
3. Run `bundle install` after Gemfile changes
4. Restart server after config changes

### Deploying Changes
Changes are automatically deployed via GitHub Pages when pushed to the main branch.