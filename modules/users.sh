#!/bin/bash

while true; do
    echo "===== USER MANAGEMENT ====="
    echo "1. Create user"
    echo "2. List users"
    echo "3. Create group"
    echo "0. Back"
    read -rp "Choose: " choice

    case $choice in
        1)
            read -rp "Username: " name
            sudo useradd -m -- "$name"
            ;;
        2)
            getent passwd | cut -d: -f1
            ;;
        3)
            read -rp "Group name: " name
            sudo groupadd -- "$name"
            ;;
        0) break ;;
        *) echo "Invalid choice" ;;
    esac
done
