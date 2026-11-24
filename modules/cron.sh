#!/bin/bash

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$MODULE_DIR/backup.sh"
LOG_DIR="$(realpath -m -- "$MODULE_DIR/../logs")"
TAG="# linux-guard-lite"

if ! command -v crontab >/dev/null 2>&1; then
    echo "The 'crontab' command is not installed."
    echo "Install it with: sudo apt install cron"
    exit 1
fi

if command -v systemctl >/dev/null 2>&1 && ! systemctl is-active --quiet cron 2>/dev/null; then
    echo "Warning: the cron service is not running."
    echo "Start it with: sudo systemctl start cron"
fi

# Prints the current crontab (nothing if there is none)
current_cron() {
    crontab -l 2>/dev/null
}

# Reads stdin and installs it as the new crontab (removes it if empty)
install_cron() {
    local content
    content=$(cat)
    if [ -z "$content" ]; then
        crontab -r 2>/dev/null
    else
        printf '%s\n' "$content" | crontab -
    fi
}

valid_number() {   # valid_number <value> <min> <max>
    [[ $1 =~ ^[0-9]{1,2}$ ]] && (( 10#$1 >= $2 && 10#$1 <= $3 ))
}

# Cron treats % as a newline, so it must be escaped in the command
cron_quote() {
    local q
    q=$(printf '%q' "$1")
    printf '%s' "${q//%/\\%}"
}

schedule_backup() {
    local src abs freq hour min day when job

    read -rp "Directory/file to back up automatically: " src
    if [ -z "$src" ] || [ ! -e "$src" ]; then
        echo "Path not found"
        return
    fi
    abs=$(realpath -- "$src")

    echo "Frequency:"
    echo "  1. Every day"
    echo "  2. Every week"
    echo "  3. Custom cron expression"
    read -rp "Choose: " freq

    case $freq in
        1|2)
            read -rp "Hour (0-23): " hour
            read -rp "Minute (0-59): " min
            if ! valid_number "$hour" 0 23 || ! valid_number "$min" 0 59; then
                echo "Invalid time"
                return
            fi
            if [ "$freq" = "1" ]; then
                day="*"
            else
                read -rp "Day of week (0-6, 0 = Sunday): " day
                if ! valid_number "$day" 0 6; then
                    echo "Invalid day"
                    return
                fi
            fi
            [ "$day" != "*" ] && day=$((10#$day))
            when="$((10#$min)) $((10#$hour)) * * $day"
            ;;
        3)
            read -rp "Cron expression (5 fields, ex: */30 * * * *): " when
            if ! [[ $when =~ ^([-0-9*/,]+[[:space:]]+){4}[-0-9*/,]+$ ]]; then
                echo "Invalid expression. It needs exactly 5 fields."
                return
            fi
            ;;
        *)
            echo "Invalid choice"
            return
            ;;
    esac

    mkdir -p -- "$LOG_DIR" || return
    job="$when /bin/bash $(cron_quote "$BACKUP_SCRIPT") --auto $(cron_quote "$abs") >> $(cron_quote "$LOG_DIR/backup.log") 2>&1 $TAG"

    if current_cron | grep -qxF -- "$job"; then
        echo "This task already exists"
        return
    fi

    { current_cron; printf '%s\n' "$job"; } | install_cron && echo "Scheduled: $when -> backup of $abs"
}

# Prints the crontab with line numbers; returns 1 if empty
show_cron() {
    local jobs
    jobs=$(current_cron)
    if [ -z "$jobs" ]; then
        echo "No cron tasks for this user"
        return 1
    fi
    echo "$jobs" | nl -ba -w2 -s') '
}

delete_cron() {
    local num total line confirm

    show_cron || return
    total=$(current_cron | wc -l)
    read -rp "Line number to delete: " num
    if ! [[ $num =~ ^[0-9]+$ ]] || (( num < 1 || num > total )); then
        echo "Invalid number"
        return
    fi

    line=$(current_cron | sed -n "${num}p")
    echo "Selected: $line"
    read -rp "Delete this line? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        current_cron | awk -v n="$num" 'NR != n' | install_cron && echo "Deleted"
    else
        echo "Cancelled"
    fi
}

while true; do
    echo "===== CRON SCHEDULING ====="
    echo "1. Schedule an automatic backup"
    echo "2. Show cron tasks"
    echo "3. Delete a cron task"
    echo "0. Back"
    read -rp "Choose: " choice || break

    case $choice in
        1) schedule_backup ;;
        2) show_cron ;;
        3) delete_cron ;;
        0) break ;;
        *) echo "Invalid choice" ;;
    esac
done
