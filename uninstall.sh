#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run as root."
    exit 1
fi

rm -f /usr/local/bin/augustus-temp

echo "Removed /usr/local/bin/augustus-temp"
echo
echo "The file /etc/modprobe.d/nct6683.conf was intentionally left in place."
echo "Remove it manually only if you no longer need NCT6683 force support."
