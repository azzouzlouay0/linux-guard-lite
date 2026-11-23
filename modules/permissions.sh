#!/bin/bash

while true; do
    echo "===== PERMISSIONS ====="
    echo "1. Show permissions"
    echo "2. Change permissions"
    echo "3. Detect permission 777"
    echo "0. Back"
    read -rp "Choose: " choice

    case $choice in
        1)
            read -rp "Path: " path
            ls -ld -- "$path"
            ;;
        2)
            read -rp "Path: " path
            read -rp "Mode (ex: 700): " mode
            chmod -- "$mode" "$path"
            ;;
        3)
            read -rp "Directory to scan: " path
            find "$path" -perm 0777 -print
            ;;
        0) break ;;
        *) echo "Invalid choice" ;;
    esac
done
