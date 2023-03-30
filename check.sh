#!/bin/bash

# Get current user's desktop path
DESKTOP_PATH=$(xdg-user-dir DESKTOP)

# Get system information
START_TIME=$(date)
IPV4_ADDRESS=$(hostname -I | awk '{print $1}')
HOSTNAME=$(hostname)
PKG_MANAGERS=$(command -v apt-get >/dev/null 2>&1 && echo "apt-get") # add other package managers as needed
INSTALLED_ITEMS=$(dpkg-query -f '${binary:Package}\n' -W | wc -l)

# Create CSV file and write header
REPORT_FILE="${DESKTOP_PATH}/software_report_$(date +%Y-%m-%d_%H-%M-%S).csv"
echo -e "Start time: $START_TIME\n\n 
         End time: $(date)\n\n
         IPv4 address: $IPV4_ADDRESS\n\n
         Hostname: $HOSTNAME\n\n
         Package managers in use: $PKG_MANAGERS\n\n
         Installed items found: $INSTALLED_ITEMS" > "$REPORT_FILE"
