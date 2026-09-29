#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run as root."
    exit 1
fi

install -m 0755 augustus-temp /usr/local/bin/augustus-temp

cat > /etc/modprobe.d/nct6683.conf <<'CONF'
options nct6683 force=1
CONF

modprobe nct6683 force=1 2>/dev/null || true

echo "Installed: /usr/local/bin/augustus-temp"
echo "NCT6683 config: /etc/modprobe.d/nct6683.conf"
echo
echo "Run:"
echo "  augustus-temp"
echo "  watch -c -n2 augustus-temp"
