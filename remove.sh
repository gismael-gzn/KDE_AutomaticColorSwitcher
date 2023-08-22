#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root or using sudo"
   exit 1
fi

# Define the target directories
SYSTEMD_DIR="/etc/systemd/system"
BIN_DIR="/usr/local/bin"

# Stop and disable the theme-switching timer if it's running
TIMER_UNIT_NAME=$(systemctl list-unit-files | grep "theme-switching.*\.timer" | awk '{print $1}' | head -1)
if [[ ! -z $TIMER_UNIT_NAME ]]; then
    systemctl stop "$TIMER_UNIT_NAME"
    systemctl disable "$TIMER_UNIT_NAME"
    echo "Timer unit stopped and disabled!"
else
    echo "Timer unit not found!"
fi

# Remove files from /etc/systemd/system and /usr/local/bin
rm -f "${SYSTEMD_DIR}/theme-switching."*
rm -f "${BIN_DIR}/theme-switcher.sh"

systemctl daemon-reload

echo "Files removed and systemd configurations reloaded!"