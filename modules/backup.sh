#!/bin/bash

# Backups are stored in <project>/backups (override with GUARD_BACKUP_DIR).
# Non-interactive use (for cron):  backup.sh --auto /path/to/source

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$(realpath -m -- "${GUARD_BACKUP_DIR:-$MODULE_DIR/../backups}")"

for cmd in tar gzip; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "The '$cmd' command is not installed."
        echo "Install it with: sudo apt install $cmd"
        exit 1
    fi
done

# Usage: create_backup <path>
create_backup() {
    local src=$1 abs dir base name file

    if [ -z "$src" ] || [ ! -e "$src" ]; then
        echo "Path not found: $src"
        return 1
    fi

    abs=$(realpath -- "$src")
    if [ "$abs" = "/" ]; then
        echo "Backing up / is not allowed"
        return 1
    fi

    # Refuse if the backup folder is inside the source (archive would contain itself)
    if [[ "$BACKUP_DIR/" == "$abs"/* ]]; then
        echo "The backup folder ($BACKUP_DIR) is inside the source. Choose another source."
        return 1
    fi

    dir=$(dirname -- "$abs")
    base=$(basename -- "$abs")
    name=${base//[^A-Za-z0-9._-]/_}

    mkdir -p -- "$BACKUP_DIR" || return 1
    file="$BACKUP_DIR/backup_${name}_$(date +%Y%m%d_%H%M%S).tar.gz"

    if tar -czf "$file" -C "$dir" -- "$base"; then
        echo "[$(date '+%F %T')] Backup created: $file ($(du -h -- "$file" | cut -f1))"
    else
        echo "[$(date '+%F %T')] Backup failed for $abs"
        rm -f -- "$file"
        return 1
    fi
}

# Fills the BACKUPS array (newest first) and prints a numbered list
list_backups() {
    BACKUPS=()
    local f i=1
    shopt -s nullglob
    for f in "$BACKUP_DIR"/backup_*.tar.gz; do
        BACKUPS+=("$f")
    done
    shopt -u nullglob

    if [ ${#BACKUPS[@]} -eq 0 ]; then
        echo "No backups found in $BACKUP_DIR"
        return 1
    fi

    # Sort newest first
    mapfile -t BACKUPS < <(ls -1t -- "${BACKUPS[@]}")

    echo "Backups in $BACKUP_DIR:"
    for f in "${BACKUPS[@]}"; do
        printf '%3d) %s  %s  %s\n' "$i" "$(basename -- "$f")" \
            "$(du -h -- "$f" | cut -f1)" "$(date -r "$f" '+%F %T')"
        i=$((i + 1))
    done
}

restore_backup() {
    local num dest

    list_backups || return
    read -rp "Backup number to restore: " num
    if ! [[ $num =~ ^[0-9]+$ ]] || (( num < 1 || num > ${#BACKUPS[@]} )); then
        echo "Invalid number"
        return
    fi

    local file=${BACKUPS[$((num - 1))]}
    if ! tar -tzf "$file" >/dev/null 2>&1; then
        echo "This backup is corrupted or not a valid archive"
        return
    fi

    read -rp "Restore into directory (default: ./restored): " dest
    dest=${dest:-./restored}
    mkdir -p -- "$dest" || return

    if tar -xzf "$file" -C "$dest"; then
        echo "Restored to: $dest"
    else
        echo "Restore failed"
    fi
}

# Non-interactive mode (used by cron)
if [ "${1:-}" = "--auto" ]; then
    create_backup "${2:-}"
    exit $?
fi

while true; do
    echo "===== BACKUP / RESTORE ====="
    echo "1. Create a backup"
    echo "2. List backups"
    echo "3. Restore a backup"
    echo "0. Back"
    read -rp "Choose: " choice || break

    case $choice in
        1)
            read -rp "File or directory to back up: " path
            create_backup "$path"
            ;;
        2)
            list_backups
            ;;
        3)
            restore_backup
            ;;
        0) break ;;
        *) echo "Invalid choice" ;;
    esac
done
