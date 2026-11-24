#!/bin/bash

if ! command -v at >/dev/null 2>&1; then
    echo "The 'at' command is not installed."
    echo "Install it with: sudo apt install at"
    exit 1
fi

if command -v systemctl >/dev/null 2>&1 && ! systemctl is-active --quiet atd 2>/dev/null; then
    echo "Warning: the atd service is not running."
    echo "Start it with: sudo systemctl start atd"
fi

while true; do
    echo "===== AT SCHEDULING ====="
    echo "1. Schedule a task"
    echo "2. List scheduled tasks"
    echo "3. Delete a task"
    echo "0. Back"
    read -rp "Choose: " choice || break

    case $choice in
        1)
            read -rp "Time (ex: 14:30, now + 5 minutes, tomorrow): " when
            read -rp "Command to run: " cmd
            if [ -z "$when" ] || [ -z "$cmd" ]; then
                echo "Time and command are required"
            else
                read -ra timespec <<< "$when"
                printf '%s\n' "$cmd" | at "${timespec[@]}"
            fi
            ;;
        2)
            jobs=$(atq)
            if [ -z "$jobs" ]; then
                echo "No scheduled tasks"
            else
                echo "$jobs"
            fi
            ;;
        3)
            read -rp "Task number to delete: " id
            if [[ $id =~ ^[0-9]+$ ]]; then
                atrm "$id"
            else
                echo "Invalid task number"
            fi
            ;;
        0) break ;;
        *) echo "Invalid choice" ;;
    esac
done
