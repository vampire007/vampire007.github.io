#!/bin/bash

# Jekyll Documentation Automation Script
# This script automates the workflow of adding/updating docs to Jekyll Chirpy theme
# Supports: new documents, updated documents, and batch validation

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

# Check if file has valid front matter
check_front_matter() {
    local file=$1
    
    # Check if file starts with ---
    if ! head -1 "$file" | grep -q '^---$'; then
        echo "missing"
        return
    fi
    
    # Check for required fields
    local has_title=$(grep -c '^title:' "$file" || true)
    local has_layout=$(grep -c '^layout:' "$file" || true)
    local has_date=$(grep -c '^date:' "$file" || true)
    
    if [ "$has_title" -eq 0 ] || [ "$has_layout" -eq 0 ] || [ "$has_date" -eq 0 ]; then
        echo "incomplete"
        return
    fi
    
    # Check layout value
    local layout_value=$(grep '^layout:' "$file" | sed 's/^layout: *//')
    if [ "$layout_value" != "page" ]; then
        echo "wrong_layout"
        return
    fi
    
    echo "valid"
}

# Fix or add front matter
fix_front_matter() {
    local file=$1
    local fm_status=$2
    local title=${3:-""}
    local categories=${4:-"docs"}
    local tags=${5:-""}
    local current_date=$(get_current_date)
    
    local temp_file=$(mktemp)
    
    case $fm_status in
        "missing")
            # No front matter, add complete one
            cat > "$temp_file" << EOF
---
title: ${title}
layout: page
date: ${current_date}
categories: [${categories}]
tags: [${tags}]
---

EOF
            cat "$file" >> "$temp_file"
            ;;
        "incomplete"|"wrong_layout")
            # Has some front matter but incomplete or wrong
            # Extract existing content (skip old front matter)
            local content_start=$(awk '/^---$/ {count++; if(count==2) {print NR+1; exit}}' "$file")
            
            if [ -z "$content_start" ]; then
                # Malformed front matter, treat as missing
                cat > "$temp_file" << EOF
---
title: ${title}
layout: page
date: ${current_date}
categories: [${categories}]
tags: [${tags}]
---

EOF
                cat "$file" >> "$temp_file"
            else
                # Extract title from existing or use provided
                if [ -z "$title" ]; then
                    title=$(grep '^title:' "$file" | sed 's/^title: *//' | head -1)
                fi
                
                cat > "$temp_file" << EOF
---
title: ${title}
layout: page
date: ${current_date}
categories: [${categories}]
tags: [${tags}]
---

EOF
                tail -n +"$content_start" "$file" >> "$temp_file"
            fi
            ;;
        "valid")
            # Front matter is valid, just update date
            local content_start=$(awk '/^---$/ {count++; if(count==2) {print NR+1; exit}}' "$file")
            local existing_title=$(grep '^title:' "$file" | sed 's/^title: *//' | head -1)
            local existing_categories=$(grep '^categories:' "$file" | sed 's/^categories: *//')
            local existing_tags=$(grep '^tags:' "$file" | sed 's/^tags: *//')
            
            cat > "$temp_file" << EOF
---
title: ${existing_title}
layout: page
date: ${current_date}
categories: ${existing_categories}
tags: ${existing_tags}
---

EOF
            tail -n +"$content_start" "$file" >> "$temp_file"
            ;;
    esac
    
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
    git commit -m "docs: update ${title}"
    
    if git push origin main; then
        print_success "Changes pushed to remote repository!"
    else
        print_error "Push failed. You may need to pull first:"
        print_info "Run: git pull origin main --rebase"
        return 1
    fi
}

# Verify document in search index
verify_search_index() {
    local title=$1
    local search_file="$SITE_ROOT/_site/assets/js/data/search.json"
    
    if [ ! -f "$search_file" ]; then
        print_error "Search index not found!"
        return 1
    fi
    
    if grep -q "$title" "$search_file"; then
        print_success "Document found in search index"
        return 0
    else
        print_error "Document NOT found in search index!"
        print_info "This may indicate a build issue"
        return 1
    fi
}

# Verify document URL/route
verify_document_url() {
    local file=$1
    local basename=$(basename "$file" .md)
    local dir=$(dirname "$file" | sed "s|^$DOCS_DIR||")
    
    # Construct expected URL
    local expected_url="/docs${dir}/${basename}/"
    local site_file="$SITE_ROOT/_site${expected_url}index.html"
    
    if [ -f "$site_file" ]; then
        print_success "Document route verified: $expected_url"
        return 0
    else
        print_error "Document route broken! Expected: $expected_url"
        print_info "Check if file is in correct directory structure"
        return 1
    fi
}

# Main processing function for single document
process_document() {
    local file=$1
    local auto_fix=${2:-"interactive"}  # interactive, yes, no
    
    print_header
    print_info "Processing: $file"
    
    # Check if file exists
    if [ ! -f "$file" ]; then
        print_error "File not found: $file"
        exit 1
    fi
    
    # Check front matter status
    local fm_status=$(check_front_matter "$file")
    local title=$(extract_title "$file")
    
    print_info "Front matter status: $fm_status"
    print_info "Detected title: $title"
    
    # Determine action based on status
    local needs_fix=false
    case $fm_status in
        "valid")
            print_success "Front matter is valid"
            ;;
        "missing")
            print_error "Front matter is missing"
            needs_fix=true
            ;;
        "incomplete")
            print_error "Front matter is incomplete (missing required fields)"
            needs_fix=true
            ;;
        "wrong_layout")
            print_error "Layout is incorrect (should be 'page')"
            needs_fix=true
            ;;
    esac
    
    # Ask for metadata if needed
    local categories="docs"
    local tags=""
    
    if [ "$needs_fix" = true ]; then
        if [ "$auto_fix" = "interactive" ] || [ "$auto_fix" = "no" ]; then
            echo ""
            read -p "Enter categories (comma-separated, e.g., '编程, Python') [docs]: " categories
            categories=${categories:-"docs"}
            
            read -p "Enter tags (comma-separated, e.g., '入门, 教程'): " tags
            tags=${tags:-""}
            
            read -p "Auto-commit after processing? (yes/no) [yes]: " auto_commit
            auto_commit=${auto_commit:-"yes"}
        else
            auto_commit="yes"
        fi
        
        echo ""
        print_info "Fixing front matter..."
        fix_front_matter "$file" "$fm_status" "$title" "$categories" "$tags"
        print_success "Front matter fixed!"
    else
        # For valid documents, still ask about commit
        if [ "$auto_fix" = "interactive" ]; then
            echo ""
            read -p "Rebuild and verify document? (yes/no) [yes]: " rebuild
            rebuild=${rebuild:-"yes"}
            
            read -p "Commit changes? (yes/no) [yes]: " auto_commit
            auto_commit=${auto_commit:-"yes"}
            
            if [ "$rebuild" != "yes" ] && [ "$rebuild" != "y" ]; then
                print_info "Skipping rebuild"
                return 0
            fi
        else
            auto_commit="yes"
        fi
    fi
    
    echo ""
    
    # Build site
    build_site
    echo ""
    
    # Verify search index
    print_info "Verifying search index..."
    verify_search_index "$title"
    echo ""
    
    # Verify document URL
    print_info "Verifying document route..."
    verify_document_url "$file"
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
    echo "  Status: ${fm_status} → fixed" 
    if [ -n "$categories" ]; then
        echo "  Categories: [$categories]"
    fi
    if [ -n "$tags" ]; then
        echo "  Tags: [$tags]"
    fi
    echo ""
    print_info "Your document will be live on GitHub Pages in a few minutes."
}

# Batch process all modified documents
batch_process() {
    local mode=${1:-"modified"}  # modified, all, new
    
    print_header
    print_info "Batch processing mode: $mode"
    
    local files_to_process=()
    
    cd "$SITE_ROOT"
    
    case $mode in
        "modified")
            # Get modified .md files in _docs/
            while IFS= read -r file; do
                if [[ "$file" == _docs/*.md ]]; then
                    files_to_process+=("$file")
                fi
            done < <(git diff --name-only HEAD 2>/dev/null || find _docs -name "*.md" -mtime -1)
            ;;
        "all")
            # Process all documents
            while IFS= read -r file; do
                files_to_process+=("$file")
            done < <(find _docs -name "*.md" -type f)
            ;;
        "new")
            # Process only new (untracked) files
            while IFS= read -r file; do
                files_to_process+=("$file")
            done < <(git ls-files --others --exclude-standard _docs/*.md 2>/dev/null || find _docs -name "*.md" -type f)
            ;;
    esac
    
    if [ ${#files_to_process[@]} -eq 0 ]; then
        print_info "No documents to process"
        return 0
    fi
    
    print_info "Found ${#files_to_process[@]} document(s) to process"
    echo ""
    
    local success_count=0
    local fail_count=0
    
    for file in "${files_to_process[@]}"; do
        echo "----------------------------------------"
        if process_document "$file" "yes"; then
            ((success_count++))
        else
            ((fail_count++))
            print_error "Failed to process: $file"
        fi
        echo ""
    done
    
    print_header
    print_success "Batch processing complete!"
    echo ""
    echo "Results:"
    echo "  Success: $success_count"
    echo "  Failed: $fail_count"
    echo "  Total: ${#files_to_process[@]}"
}

# Usage information
usage() {
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  process <file.md>          Process a single document"
    echo "  validate <file.md>         Validate document without modifying"
    echo "  batch [mode]               Batch process documents"
    echo "                             Modes: modified (default), all, new"
    echo ""
    echo "Examples:"
    echo "  $0 process _docs/my-doc.md"
    echo "  $0 validate _docs/my-doc.md"
    echo "  $0 batch modified"
    echo "  $0 batch all"
    echo ""
    echo "The script will:"
    echo "  1. Check/fix front matter (title, layout, date, categories, tags)"
    echo "  2. Build the Jekyll site"
    echo "  3. Verify search index includes the document"
    echo "  4. Verify document URL/route is correct"
    echo "  5. Optionally commit and push to Git"
}

# Main entry point
if [ $# -eq 0 ]; then
    usage
    exit 1
fi

command=$1
shift

case $command in
    "process")
        if [ $# -eq 0 ]; then
            print_error "Please specify a file"
            usage
            exit 1
        fi
        process_document "$1" "interactive"
        ;;
    "validate")
        if [ $# -eq 0 ]; then
            print_error "Please specify a file"
            usage
            exit 1
        fi
        # Validate mode: check without modifying
        file=$1
        fm_status=$(check_front_matter "$file")
        title=$(extract_title "$file")
        
        print_header
        print_info "Validating: $file"
        echo ""
        echo "Front matter status: $fm_status"
        echo "Title: $title"
        echo ""
        
        if [ "$fm_status" = "valid" ]; then
            print_success "Document is valid!"
        else
            print_error "Document needs fixing"
            print_info "Run: $0 process $file"
        fi
        ;;
    "batch")
        mode=${1:-"modified"}
        batch_process "$mode"
        ;;
    *)
        print_error "Unknown command: $command"
        usage
        exit 1
        ;;
esac
