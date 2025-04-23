#!/bin/bash

# Script: disable-lid-suspend.sh
# Description: Configure Ubuntu 22.04 to do nothing when the laptop lid is closed
# Requires: sudo privileges

set -e  # Exit immediately if a command exits with a non-zero status

LOGIND_CONF="/etc/systemd/logind.conf"
BACKUP_FILE="${LOGIND_CONF}.bak.$(date +%Y%m%d%H%M%S)"

# Backup original config file
if [[ -f "$LOGIND_CONF" ]]; then
    sudo cp "$LOGIND_CONF" "$BACKUP_FILE"
    echo "Backup of original config file created at $BACKUP_FILE"
else
    echo "Error: $LOGIND_CONF not found. Exiting."
    exit 1
fi

# Modify logind.conf to ignore lid closure
sudo sed -i '/^#*HandleLidSwitch=/s/^#*//; s/=.*/=ignore/' "$LOGIND_CONF"
sudo sed -i '/^#*HandleLidSwitchExternalPower=/s/^#*//; s/=.*/=ignore/' "$LOGIND_CONF"
sudo sed -i '/^#*HandleLidSwitchDocked=/s/^#*//; s/=.*/=ignore/' "$LOGIND_CONF"

echo "Configuration updated: Lid close action set to 'ignore'."

# Prompt user before restarting systemd-logind
read -p "Restart systemd-logind to apply changes? (y/N): " RESTART_CHOICE
if [[ "$RESTART_CHOICE" =~ ^[Yy]$ ]]; then
    sudo systemctl restart systemd-logind.service
    echo "systemd-logind service restarted. Note: You may have been logged out."
else
    echo "Please restart the systemd-logind service or reboot for changes to take effect."
fi

# Optional reboot prompt
read -p "Reboot now? (y/N): " REBOOT_CHOICE
if [[ "$REBOOT_CHOICE" =~ ^[Yy]$ ]]; then
    sudo reboot
fi