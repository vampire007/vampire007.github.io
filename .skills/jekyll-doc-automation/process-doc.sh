#!/bin/bash

# Jekyll Documentation Automation Script
# This script automates the workflow of adding new docs to Jekyll Chirpy theme

set -e

# Configuration
DOCS_DIR="_docs"
CONFIG_FILE="_config.yml"
SITE_ROOT="/Users/andy/andy/vampire007.github.io"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Jekyll Documentation Automation${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Get current date in required format
get_current_date() {
    date '+%Y-%m-%d %H:%M:%S +0800'
}

# Extract title from markdown file (first H1 heading)
extract_title() {
    local file=$1
    local title=$(grep -m1 '^# ' "$file" | sed 's/^# //' | head -1)
    
    if [ -z "$title" ]; then
        # Fallback: use filename
        local basename=$(basename "$file" .md)
        title=$(echo "$basename" | sed 's/-/ /g' | sed 's/\b\(\.\)/\u\1/g')
    fi
    
    echo "$title"
}

# Add front matter to markdown file
add_front_matter() {
    local file=$1
    local title=$2
    local categories=$3
    local tags=$4
    local current_date=$(get_current_date)
    
    # Create temporary file with front matter
    local temp_file=$(mktemp)
    
    cat > "$temp_file" << EOF
---
title: ${title}
layout: page
date: ${current_date}
categories: [${categories}]
tags: [${tags}]
---

EOF
    
    # Append original content (skip existing front matter if present)
    if grep -q '^---$' "$file"; then
        # File has existing front matter, skip it
        sed '1,/^---$/d' "$file" >> "$temp_file"
    else
        # No existing front matter, append entire file
        cat "$file" >> "$temp_file"
    fi
    
    # Replace original file
    mv "$temp_file" "$file"
}

# Build Jekyll site
build_site() {
    print_info "Building Jekyll site..."
    cd "$SITE_ROOT"
    
    if bundle exec jekyll build > /tmp/jekyll_build.log 2>&1; then
        print_success "Site built successfully!"
        return 0
    else
        print_error "Build failed! Check /tmp/jekyll_build.log for details"
        cat /tmp/jekyll_build.log
        return 1
    fi
}

# Commit and push to Git
commit_and_push() {
    local file=$1
    local title=$2
    local auto_commit=$3
    
    if [ "$auto_commit" != "yes" ] && [ "$auto_commit" != "y" ]; then
        print_info "Skipping commit (user chose not to auto-commit)"
        return 0
    fi
    
    print_info "Committing changes to Git..."
    cd "$SITE_ROOT"
    
    git add "$file"
    git commit -m "docs: add ${title}"
    
    if git push origin main; then
        print_success "Changes pushed to remote repository!"
    else
        print_error "Push failed. You may need to pull first:"
        print_info "Run: git pull origin main --rebase"
        return 1
    fi
}

# Main processing function
process_document() {
    local file=$1
    
    print_header
    print_info "Processing: $file"
    
    # Check if file exists
    if [ ! -f "$file" ]; then
        print_error "File not found: $file"
        exit 1
    fi
    
    # Extract or ask for metadata
    local title=$(extract_title "$file")
    print_info "Detected title: $title"
    
    # Ask user for categories and tags
    echo ""
    read -p "Enter categories (comma-separated, e.g., '编程, Python') [docs]: " categories
    categories=${categories:-"docs"}
    
    read -p "Enter tags (comma-separated, e.g., '入门, 教程'): " tags
    tags=${tags:-""}
    
    read -p "Auto-commit after processing? (yes/no) [yes]: " auto_commit
    auto_commit=${auto_commit:-"yes"}
    
    echo ""
    print_info "Adding front matter..."
    add_front_matter "$file" "$title" "$categories" "$tags"
    
    print_success "Front matter added!"
    echo ""
    
    # Build site
    build_site
    echo ""
    
    # Commit and push
    commit_and_push "$file" "$title" "$auto_commit"
    echo ""
    
    print_header
    print_success "Document processed successfully!"
    echo ""
    echo "Summary:"
    echo "  File: $file"
    echo "  Title: $title"
    echo "  Categories: [$categories]"
    echo "  Tags: [$tags]"
    echo ""
    print_info "Your document will be live on GitHub Pages in a few minutes."
}

# Usage information
usage() {
    echo "Usage: $0 <markdown-file>"
    echo ""
    echo "Examples:"
    echo "  $0 _docs/my-new-doc.md"
    echo "  $0 _docs/docker-tutorial.md"
    echo ""
    echo "The script will:"
    echo "  1. Extract title from the file or filename"
    echo "  2. Ask for categories and tags"
    echo "  3. Add proper front matter"
    echo "  4. Build the Jekyll site"
    echo "  5. Optionally commit and push to Git"
}

# Main entry point
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

process_document "$1"
