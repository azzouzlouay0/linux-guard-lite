
#!/bin/bash

# Linux Guard Lite - Main Menu
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_module() {
    local file="$BASE_DIR/modules/$1"

    if [[ -f "$file" ]]; then
        bash "$file"
    else
        echo "Module not available yet!"
    fi

    read -rp "Press Enter to continue..."
}

while true; do
    clear
    echo "================================="
    echo "        LINUX GUARD LITE         "
    echo "================================="
    echo "1. File Management"
    echo "2. User Management"
    echo "3. Permissions Management"
    echo "4. Compression / Decompression"
    echo "5. Backup / Restore"
    echo "6. Cron Scheduling"
    echo "7. AT Scheduling"
    echo "8. Network Configuration"
    echo "9. System Administration"
    echo "0. Exit"
    echo "================================="

    read -rp "Choose an option: " choice

    case "$choice" in
        1) run_module "files.sh" ;;
        2) run_module "users.sh" ;;
        3) run_module "permissions.sh" ;;
        4) run_module "compression.sh" ;;
        5) run_module "backup.sh" ;;
        6) run_module "cron.sh" ;;
        7) run_module "at.sh" ;;
        8) run_module "network.sh" ;;
        9) run_module "administration.sh" ;;
        0)
            echo "Goodbye!"
            exit 0
            ;;
        *) echo "Invalid choice!"
           sleep 1 ;;
    esac
done
