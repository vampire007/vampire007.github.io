# Project Summary: AndyVictory's Homepage

## Overview

A personal coding blog and technical notes website built with Jekyll and deployed on GitHub Pages. The site serves as a knowledge base for development tool configurations, programming tutorials, and exam study materials.

## Tech Stack

- **Static Site Generator**: Jekyll 4.x
- **Theme**: jekyll-theme-chirpy
- **Syntax Highlighting**: Rouge
- **Math Rendering**: MathJax (via kramdown)
- **Deployment**: GitHub Pages (push to `main` triggers auto-deploy)

## Main Features

- **Blog Posts** (`_posts/`) — Technical articles and coding notes, bilingual (Chinese & English), following the `YYYY-MM-DD-title.markdown` naming convention.
- **Technical Guides** (`hacker/`) — Hands-on configuration notes covering topics like Git SSH setup, Homebrew mirrors, Node.js/nvm installation, and more. These are static pages using `layout: page`.
- **Exam Notes** (`_posts/r.md`) — Study materials for the System Architecture Designer certification exam (软考).
- **Navigation Tabs** (`_tabs/`) — Top-level navigation pages (e.g., docs).
- **Search** — Full-text search enabled via Chirpy's built-in search feature.
- **Feed & Sitemap** — RSS feed (`jekyll-feed`) and XML sitemap (`jekyll-sitemap`) for discoverability.
- **Code Snippets** — Gist embedding supported via `jekyll-gist`.
- **Caching** — Page include caching (`jekyll-include-cache`) for faster builds.

## Directory Structure

| Path | Purpose |
|------|---------|
| `_posts/` | Blog articles (Markdown) |
| `hacker/` | Technical guides organized by topic |
| `_tabs/` | Static navigation pages |
| `_config.yml` | Site configuration |
| `assets/` | Images, CSS, JS resources |
| `_data/` | Data files for the site |
| `_docs/` | Documentation content |

## Quick Start

```bash
bundle install                    # Install dependencies
bundle exec jekyll serve          # Start dev server at http://localhost:4000
bundle exec jekyll build          # Build static site to _site/
```

Note: Changes to `_config.yml` require a server restart since the config does not hot-reload.
