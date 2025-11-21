#!/bin/bash
# Firewall initialization script for Claude Code container
# This script sets up basic iptables rules for network sandboxing

# Exit on error
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Only initialize if not already done
if [ -f /var/run/firewall-initialized ]; then
    exit 0
fi

# Basic firewall setup (customize as needed)
echo "Initializing firewall rules..."

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Mark as initialized
touch /var/run/firewall-initialized

echo "Firewall initialized successfully"
