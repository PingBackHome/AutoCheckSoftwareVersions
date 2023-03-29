#!/bin/bash

# Get hostname of machine
HOSTNAME=$(hostname)

# IPv4 address from machine
IPV4=$(hostname -I | awk '{print $1}')

# Name of current user
USER=$(whoami)

# Start time 
START_TIME=$(date +"%Y-%m-%d %H:%M:%S")

# Check DPKG pachage manager
if command -v dpkg >/dev/null; then
    dpkg -l | awk '{print $2 "," $3}' | tail -n +6 > ~/installed_software.csv
# Check RPM pachage manager
elif command -v rpm >/dev/null; then
    rpm -qa --queryformat '%{NAME},%{VERSION}\n' > ~/installed_software.csv
# Check APT-GET pachage manager
elif command -v apt-get >/dev/null; then
    apt list --installed | awk -F'/' '{print $1 "," $2}' > ~/geinstalleerde_software.csv
else
    echo "No package manager."
    exit 1
fi

# End time
END_TIME=$(date +"%Y-%m-%d %H:%M:%S")

# Add header info to csv file
sed -i '1iHostname,IPv4 Address,User,Start Time,End Time' ~/installed_software.csv
sed -i "1s/.*/&,$HOSTNAME,$IPV4,$USER,$START_TIME,$END_TIME/" ~/installed_software.csv
