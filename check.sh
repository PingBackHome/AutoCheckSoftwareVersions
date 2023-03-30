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
echo "Start time,End time,IPv4 address,Hostname,Package managers in use,Installed items found" > "$REPORT_FILE"

# Write system information to CSV file
echo "$START_TIME,$(date),$IPV4_ADDRESS,$HOSTNAME,$PKG_MANAGERS,$INSTALLED_ITEMS" >> "$REPORT_FILE"
