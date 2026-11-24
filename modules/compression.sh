#!/bin/bash

for cmd in tar gzip; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "The '$cmd' command is not installed."
        echo "Install it with: sudo apt install $cmd"
        exit 1
    fi
done

# Ask before overwriting an existing file. Returns 0 if it is safe to write.
can_write() {
    local target=$1 confirm
    if [ -e "$target" ]; then
        read -rp "$target already exists. Overwrite? (y/N): " confirm
        [[ $confirm =~ ^[Yy]$ ]] || return 1
    fi
    return 0
}

# Compress a file or directory into a .tar.gz archive
compress_tar() {
    local src out dir base
    read -rp "File or directory to compress: " src
    if [ -z "$src" ] || [ ! -e "$src" ]; then
        echo "Path not found"
        return
    fi

    src=$(realpath -- "$src")
    dir=$(dirname -- "$src")
    base=$(basename -- "$src")

    read -rp "Archive name (default: $base.tar.gz): " out
    out=${out:-$base.tar.gz}
    [[ $out == *.tar.gz ]] || out="$out.tar.gz"

    can_write "$out" || { echo "Cancelled"; return; }

    if tar -czf "$out" -C "$dir" -- "$base"; then
        echo "Archive created: $out ($(du -h -- "$out" | cut -f1))"
    else
        echo "Compression failed"
        rm -f -- "$out"
    fi
}

# Compress a single file with gzip (original file is kept)
compress_gzip() {
    local src
    read -rp "File to compress: " src
    if [ ! -f "$src" ]; then
        echo "File not found"
        return
    fi

    can_write "$src.gz" || { echo "Cancelled"; return; }

    if gzip -c -- "$src" > "$src.gz"; then
        echo "Created: $src.gz (original kept)"
    else
        echo "Compression failed"
        rm -f -- "$src.gz"
    fi
}

# Extract a .tar.gz archive
decompress_tar() {
    local archive dest
    read -rp "Archive to extract (.tar.gz): " archive
    if [ ! -f "$archive" ]; then
        echo "Archive not found"
        return
    fi
    if ! tar -tzf "$archive" >/dev/null 2>&1; then
        echo "Not a valid .tar.gz archive"
        return
    fi

    read -rp "Destination directory (default: current directory): " dest
    dest=${dest:-.}
    mkdir -p -- "$dest" || return

    if tar -xzf "$archive" -C "$dest"; then
        echo "Extracted to: $dest"
    else
        echo "Extraction failed"
    fi
}

# Decompress a single .gz file (the .gz file is kept)
decompress_gzip() {
    local src out
    read -rp "File to decompress (.gz): " src
    if [ ! -f "$src" ] || [[ $src != *.gz ]]; then
        echo "Please give an existing .gz file"
        return
    fi

    out=${src%.gz}
    can_write "$out" || { echo "Cancelled"; return; }

    if gzip -dc -- "$src" > "$out"; then
        echo "Created: $out (.gz file kept)"
    else
        echo "Decompression failed"
        rm -f -- "$out"
    fi
}

# Show the content of a .tar.gz without extracting it
list_archive() {
    local archive
    read -rp "Archive to inspect (.tar.gz): " archive
    if [ ! -f "$archive" ]; then
        echo "Archive not found"
    elif ! tar -tzvf "$archive" 2>/dev/null; then
        echo "Not a valid .tar.gz archive"
    fi
}

while true; do
    echo "===== COMPRESSION / DECOMPRESSION ====="
    echo "1. Compress file/directory (tar.gz)"
    echo "2. Compress a single file (gzip)"
    echo "3. Decompress archive (.tar.gz)"
    echo "4. Decompress a file (.gz)"
    echo "5. List archive content"
    echo "0. Back"
    read -rp "Choose: " choice || break

    case $choice in
        1) compress_tar ;;
        2) compress_gzip ;;
        3) decompress_tar ;;
        4) decompress_gzip ;;
        5) list_archive ;;
        0) break ;;
        *) echo "Invalid choice" ;;
    esac
done
