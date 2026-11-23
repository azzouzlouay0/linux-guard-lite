#!/bin/bash

while true; do
    echo "===== FILE MANAGEMENT ====="
    echo "1. Create file"
    echo "2. Create directory"
    echo "3. List files"
    echo "4. Delete file"
    echo "0. Back"
    read -rp "Choose: " choice

    case $choice in
        1)
            read -rp "File name: " name
            touch -- "$name"
            ;;
        2)
            read -rp "Directory name: " name
            mkdir -p -- "$name"
            ;;
        3)
            ls -la
            ;;
        4)
            read -rp "File name: " name
            if [ -f "$name" ]; then
                rm -i -- "$name"
            else
                echo "File not found"
            fi
            ;;
        0) break ;;
        *) echo "Invalid choice" ;;
    esac
done
