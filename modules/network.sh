#!/bin/bash

if ! command -v ip >/dev/null 2>&1; then
    echo "The 'ip' command is not installed."
    echo "Install it with: sudo apt install iproute2"
    exit 1
fi

# Accepts an IPv4 address with a prefix, ex: 192.168.1.50/24
valid_cidr() {
    local cidr=$1 octet
    local -a octets
    [[ $cidr =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}$ ]] || return 1
    (( 10#${cidr#*/} <= 32 )) || return 1
    IFS=. read -ra octets <<< "${cidr%/*}"
    for octet in "${octets[@]}"; do
        (( 10#$octet <= 255 )) || return 1
    done
}

# Usage: change_ip add|del
change_ip() {
    local action=$1 iface addr confirm

    read -rp "Interface (ex: eth0): " iface
    read -rp "IP address with prefix (ex: 192.168.1.50/24): " addr

    if [ -z "$iface" ] || ! ip link show dev "$iface" >/dev/null 2>&1; then
        echo "Interface not found"
    elif ! valid_cidr "$addr"; then
        echo "Invalid address. Use the form 192.168.1.50/24"
    else
        if [ "$action" = "add" ]; then
            echo "This adds $addr to $iface until the next reboot."
        else
            echo "This removes $addr from $iface."
        fi
        read -rp "Continue? (y/N): " confirm
        if [[ $confirm =~ ^[Yy]$ ]]; then
            sudo ip addr "$action" "$addr" dev "$iface" && echo "Done"
        else
            echo "Cancelled"
        fi
    fi
}

while true; do
    echo "===== NETWORK CONFIGURATION ====="
    echo "1. Show IP address"
    echo "2. Test connection (ping)"
    echo "3. Show default gateway"
    echo "4. Set temporary IP address"
    echo "5. Remove temporary IP address"
    echo "0. Back"
    read -rp "Choose: " choice || break

    case $choice in
        1)
            ip -brief address
            ;;
        2)
            if ! command -v ping >/dev/null 2>&1; then
                echo "The 'ping' command is not installed."
                echo "Install it with: sudo apt install iputils-ping"
            else
                read -rp "Host to ping (default 8.8.8.8): " host
                ping -c 4 -W 2 -- "${host:-8.8.8.8}"
            fi
            ;;
        3)
            routes=$(ip route show default)
            if [ -z "$routes" ]; then
                echo "No default gateway configured"
            else
                echo "$routes" | awk '
                    {
                        gw = ""; dev = ""
                        for (i = 1; i < NF; i++) {
                            if ($i == "via") gw = $(i + 1)
                            if ($i == "dev") dev = $(i + 1)
                        }
                        if (gw != "") print "Default gateway: " gw " (interface " dev ")"
                        else print "Default route: " $0
                    }'
            fi
            ;;
        4)
            change_ip add
            ;;
        5)
            change_ip del
            ;;
        0) break ;;
        *) echo "Invalid choice" ;;
    esac
done
