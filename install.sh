#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Please run as root."
    exit 1
fi

cd "$(dirname "$0")"

# Validate all shell scripts before touching the running installation.
for script in augustus-temp augustus-temp-collect augustus-temp-update augustus-watch; do
    bash -n "$script"
done

install -m 0755 augustus-temp /usr/local/bin/augustus-temp
install -m 0755 augustus-temp-collect /usr/local/bin/augustus-temp-collect
install -m 0755 augustus-watch /usr/local/bin/augustus-watch
install -m 0755 augustus-temp-update /usr/local/sbin/augustus-temp-update

install -m 0644 augustus-temp-collector.service /etc/systemd/system/augustus-temp-collector.service
install -m 0644 augustus-temp-collector.timer /etc/systemd/system/augustus-temp-collector.timer

cat > /etc/modprobe.d/nct6683.conf <<'CONF'
options nct6683 force=1
CONF

modprobe nct6683 force=1 2>/dev/null || true

mkdir -p /run/augustus-temp
chmod 0755 /run/augustus-temp

systemctl daemon-reload
systemctl enable --now augustus-temp-collector.timer
systemctl restart augustus-temp-collector.timer

echo "Installed: /usr/local/bin/augustus-temp (cached viewer)"
echo "Installed: /usr/local/bin/augustus-temp-collect (telemetry collector)"
echo "Installed: /usr/local/sbin/augustus-temp-update (atomic publisher)"
echo "Timer: augustus-temp-collector.timer"
echo "NCT6683 config: /etc/modprobe.d/nct6683.conf"
echo
echo "Run:"
echo "  augustus-temp                   # last snapshot"
echo "  augustus-watch                  # up to 24 hours"
echo "  watch -c -n2 augustus-temp      # unlimited viewer"
echo "  systemctl status augustus-temp-collector.timer"
