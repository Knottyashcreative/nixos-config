#!/usr/bin/env bash

# Professional PDF to Markdown Converter Script (Enhanced)
# Recursively processes all PDFs in the directory tree.

set -euo pipefail
IFS=$'\n\t'

# ----- CONFIGURATION -----
DEBUG=1            # 1=enable debug output, 0=disable
VERBOSE=1          # 1=enable info output, 0=disable
FORCE_OVERWRITE=0  # 1=overwrite existing outputs, 0=skip if exists
CLEANUP=1          # 1=remove intermediate files, 0=keep
PREVIEW=0          # 1=show preview of new markdown files, 0=disable

ERROR_DIR="./error_files"
mkdir -p "$ERROR_DIR"

log() { [[ "$VERBOSE" -eq 1 ]] && echo "[$(date +'%Y-%m-%d %H:%M:%S')] [INFO] $*"; }
debug() { [[ "$DEBUG" -eq 1 ]] && echo "[$(date +'%Y-%m-%d %H:%M:%S')] [DEBUG] $*"; }
error_exit() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] [ERROR] $*" >&2; exit 1; }

# Check for required tools
required_cmds=(pdftotext pandoc pdfimages sed find mkdir rm file cp)
for cmd in "${required_cmds[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || error_exit "Missing required command: $cmd"
done

# Check write permission
check_write_permission() {
    local dir="$1"
    if ! [ -w "$dir" ]; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] [WARNING] No write permission in $dir, skipping."
        return 1
    fi
    return 0
}

# Extract text from PDF with multiple, quality-focused fallbacks
pdf_to_text() {
    local pdf="$1"
    local txt="$2"

    if pdftotext -layout "$pdf" "$txt"; then
        debug "pdftotext -layout succeeded for $pdf"
        return 0
    fi

    if pdftotext "$pdf" "$txt"; then
        debug "pdftotext without layout succeeded for $pdf"
        return 0
    fi

    if command -v pdftohtml >/dev/null 2>&1; then
        debug "Trying pdftohtml for $pdf"
        if pdftohtml -stdout -xml "$pdf" | sed -n 's/.*<text[^>]*>\(.*\)<\/text>.*/\1/p' > "$txt"; then
            debug "pdftohtml succeeded for $pdf"
            return 0
        fi
    fi

    if command -v mutool >/dev/null 2>&1; then
        debug "Trying mutool for $pdf"
        if mutool extract -F txt "$pdf" > "$txt" 2>/dev/null; then
            debug "mutool succeeded for $pdf"
            return 0
        fi
    fi

    return 1
}

# Prepend 'xx' to each non-empty line, preserve empty lines
prepend_xx() {
    local input="$1"
    local output="$2"
    sed '/^$/!s/^/xx/' "$input" > "$output"
}

# Convert text to Markdown, preserving structure and line breaks
text_to_markdown() {
    local input="$1"
    local output="$2"
    pandoc "$input" -f markdown -t markdown -o "$output" --wrap=preserve
}

# Extract images from PDF
extract_images() {
    local pdf="$1"
    local images_dir="$2"
    mkdir -p "$images_dir"
    if ! pdfimages -all "$pdf" "$images_dir/image"; then
        echo "[$(date +'%Y-%m-%d %H:%M:%S')] [WARNING] pdfimages failed for $pdf"
    fi
}

# ----- MAIN PROCESSING LOOP -----

processed_count=0
skipped_count=0
failed_count=0
processed_files=()
skipped_files=()
failed_files=()

find . -type f -iname '*.pdf' | while IFS= read -r pdf; do
    dir="$(dirname "$pdf")"
    base="$(basename "$pdf" .pdf)"

    txt="$dir/$base.txt"
    xx_txt="$txt.xx"
    md="$dir/$base.md"
    images_dir="$dir/${base}_images"

    log "Processing: $pdf"

    # Check write permission
    if ! check_write_permission "$dir"; then
        ((skipped_count++))
        skipped_files+=("$pdf (no write permission)")
        continue
    fi

    # Determine if skipping due to existing outputs
    if [[ -f "$md" && -d "$images_dir" && "$(ls -A "$images_dir" 2>/dev/null)" && "$FORCE_OVERWRITE" -eq 0 ]]; then
        debug "$md exists and images already extracted in $images_dir, skipping all processing."
        ((skipped_count++))
        skipped_files+=("$pdf (already processed)")
        continue
    fi

    # Text extraction
    if [[ -f "$txt" && "$FORCE_OVERWRITE" -eq 0 ]]; then
        debug "Text file $txt exists, skipping extraction."
    else
        if ! pdf_to_text "$pdf" "$txt"; then
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] [WARNING] Text extraction failed for $pdf"
            ((failed_count++))
            failed_files+=("$pdf (text extraction failed)")
            cp -n "$pdf" "$ERROR_DIR/" 2>/dev/null || true
            continue
        fi
    fi

    # Prepend 'xx'
    if [[ -f "$xx_txt" && "$FORCE_OVERWRITE" -eq 0 ]]; then
        debug "$xx_txt exists, skipping prepend step."
    else
        if ! prepend_xx "$txt" "$xx_txt"; then
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] [WARNING] Failed to prepend 'xx' for $txt"
            ((failed_count++))
            failed_files+=("$pdf (prepend xx failed)")
            cp -n "$pdf" "$ERROR_DIR/" 2>/dev/null || true
            continue
        fi
    fi

    # Convert to Markdown
    if [[ -f "$md" && "$FORCE_OVERWRITE" -eq 0 ]]; then
        debug "$md exists, skipping markdown conversion."
    else
        if ! text_to_markdown "$xx_txt" "$md"; then
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] [WARNING] Pandoc conversion failed for $xx_txt"
            ((failed_count++))
            failed_files+=("$pdf (pandoc failed)")
            cp -n "$pdf" "$ERROR_DIR/" 2>/dev/null || true
            continue
        fi
    fi

    # Extract images
    if [[ -d "$images_dir" && "$(ls -A "$images_dir" 2>/dev/null)" && "$FORCE_OVERWRITE" -eq 0 ]]; then
        debug "Images already extracted in $images_dir, skipping extraction."
    else
        extract_images "$pdf" "$images_dir"
    fi

    # Cleanup
    if [[ "$CLEANUP" -eq 1 ]]; then
        rm -f "$txt" "$xx_txt"
    fi

    ((processed_count++))
    processed_files+=("$pdf")
    log "Completed: $md and images in $images_dir"

    # Optional: Preview output
    if [[ "$PREVIEW" -eq 1 ]]; then
        echo "Preview of $md:"
        head -n 10 "$md"
        echo "..."
    fi
done

# ----- SUMMARY -----
echo
log "Processing complete."
echo "--------------------------------------"
echo "Total processed: $processed_count"
echo "Total skipped:   $skipped_count"
echo "Total failed:    $failed_count"
echo
if [[ "${#processed_files[@]}" -gt 0 ]]; then
    echo "Processed files:"
    for f in "${processed_files[@]}"; do
        echo " - $f"
    done
    echo
fi
if [[ "${#skipped_files[@]}" -gt 0 ]]; then
    echo "Skipped files:"
    for f in "${skipped_files[@]}"; do
        echo " - $f"
    done
    echo
fi
if [[ "${#failed_files[@]}" -gt 0 ]]; then
    echo "Failed files (copied to $ERROR_DIR):"
    for f in "${failed_files[@]}"; do
        echo " - $f"
    done
    echo
fi
