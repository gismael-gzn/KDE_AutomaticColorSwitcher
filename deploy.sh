#!/bin/bash

# Script must be ran as sudo
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or using sudo"
   exit 1
fi

# Define source and target directories
CWD=$(pwd)
SYSTEMD_DIR="/etc/systemd/system"
BIN_DIR="/usr/local/bin"

# Copy the theme-switching.* files to /etc/systemd/system and change perms
cp "${CWD}/theme-switching."* "${SYSTEMD_DIR}/"
chmod 777 "${SYSTEMD_DIR}/theme-switching."*

# Copy the theme-switcher.sh file to /usr/local/bin and change perms
cp "${CWD}/theme-switcher.sh" "${BIN_DIR}/"
chmod 777 "${BIN_DIR}/theme-switcher.sh"

# Reload systemd configurations
TIMER_UNIT_NAME="theme-switching.timer"

systemctl daemon-reload
systemctl enable "$TIMER_UNIT_NAME"
systemctl start "$TIMER_UNIT_NAME"
echo "Timer unit enabled and started!"

echo "Theme switcher deployed succesfully!\n"

systemctl status "$TIMER_UNIT_NAME"
systemctl status theme-switching.service
