#!/bin/bash

# Function to clean orphan packages
clean_orphans() {
    echo "Cleaning orphan packages..."
    sudo pacman -Rns $(pacman -Qtdq)
    echo "Orphan package cleanup complete."
}

# Function to clean package cache
clean_cache() {
    echo "Cleaning package cache..."
    sudo pacman -Scc
    echo "Package cache cleanup complete."
}

# Function to remove old configuration files from uninstalled packages
clean_configs() {
    echo "Searching for and removing old configuration files..."
    # This command looks for pacnew and pacsave files that might be left over
    # and also searches common configuration directories for files
    # belonging to uninstalled packages.
    # **USE WITH CAUTION**: Manually review files before deletion.

    echo "You may want to manually check for configuration files in your home directory or /etc that belong to uninstalled applications."
    echo "For example, you can use 'find ~ -name \"*<app_name>*\"' or 'sudo find /etc -name \"*<app_name>*\"'."
    echo "This script will not automatically delete these files due to the risk of data loss."
    echo "It's recommended to periodically review your /etc and ~/.config directories."
    echo "Old log files can also accumulate in /var/log."
    echo "Consider using 'journalctl --vacuum-size=50M' or 'journalctl --vacuum-time=7days' to manage system journal logs."
}

# Main script execution
echo "Starting Arch Linux cleanup process..."
echo "---"

clean_orphans
echo "---"
clean_cache
echo "---"
clean_configs

echo "---"
echo "Arch Linux cleanup process finished."
echo "Remember to periodically check your system for other residual files manually."
