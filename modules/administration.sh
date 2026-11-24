#!/bin/bash

have_systemctl() {
    if ! command -v systemctl >/dev/null 2>&1; then
        echo "systemctl is not available on this system"
        return 1
    fi
}

while true; do
    echo "===== SYSTEM ADMINISTRATION ====="
    echo "1. Memory (RAM)"
    echo "2. CPU"
    echo "3. Disk space"
    echo "4. Top processes"
    echo "5. Running services"
    echo "6. Check a service"
    echo "0. Back"
    read -rp "Choose: " choice || break

    case $choice in
        1)
            free -h
            ;;
        2)
            echo "Model: $(lscpu | sed -n 's/^Model name:[[:space:]]*//p')"
            echo "Cores: $(nproc)"
            echo "Load average (1, 5, 15 min): $(cut -d' ' -f1-3 /proc/loadavg)"
            ;;
        3)
            df -h -x tmpfs -x devtmpfs
            ;;
        4)
            echo "Top 10 processes by CPU usage:"
            ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 11
            ;;
        5)
            have_systemctl && systemctl list-units --type=service --state=running --no-pager
            ;;
        6)
            if have_systemctl; then
                read -rp "Service name (ex: ssh): " service
                if [ -z "$service" ]; then
                    echo "Service name is required"
                else
                    state=$(systemctl is-active -- "$service" 2>/dev/null)
                    echo "State of $service: ${state:-unknown}"
                    systemctl status --no-pager -n 5 -- "$service"
                fi
            fi
            ;;
        0) break ;;
        *) echo "Invalid choice" ;;
    esac
done
