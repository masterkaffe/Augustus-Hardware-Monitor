# Augustus Hardware Monitor

A lightweight Bash terminal dashboard for the **Augustus** Proxmox/Linux host.

It combines local hardware telemetry with selected OpenWrt sensor and network data in one live view:

- AMD Threadripper CPU temperatures and CCDs
- DDR4 DIMM temperature sensors
- Intel Arc GPU temperature
- NVMe temperatures
- Physical disk I/O utilization bars
- ASRock TRX40 Creator / NCT6683 mainboard sensors
- Fan and water-pump RPM
- Mellanox and Aquantia temperatures from OpenWrt over SSH
- Live OpenWrt RX/TX traffic with adaptive bit/s, Kbit/s, Mbit/s and Gbit/s units

## Hardware profile

This repository is currently tailored to the Augustus host:

- ASRock TRX40 Creator
- AMD Threadripper 3960X
- Intel Arc A770
- Nuvoton NCT6683 hardware monitor
- Intel Optane + Samsung 970 EVO Plus NVMe devices
- OpenWrt router at `192.168.10.2`
- Mellanox ConnectX interfaces and Aquantia 10G interface on OpenWrt

The script can be adapted to other systems, but sensor names, PCI addresses and interface names may need adjustment.

## Fan mapping

| Fan | Label | Function |
|---|---|---|
| FAN1 | CPU Fan | CPU/radiator fan, controlled from CPU temperature |
| FAN2 | VRM Fan | MOSFET/VRM fan on the mainboard |
| FAN3 | Water Pump | CPU water-cooling pump |
| FAN4 | Top / RAM Fan | Upper case fan for RAM/mainboard airflow |
| FAN5 | NVMe Fan | Lower case fan for NVMe/PCIe airflow |
| FAN6 | HDD Fan | External HDD fan; currently without a usable tachometer signal |

## Requirements

On the Proxmox/Linux host:

```bash
apt install lm-sensors openssh-client
```

The NCT6683 chip on the ASRock TRX40 Creator requires:

```text
options nct6683 force=1
```

in:

```text
/etc/modprobe.d/nct6683.conf
```

On OpenWrt the script expects `ethtool`, hwmon support and SSH key authentication from Augustus.

## Installation und gleichzeitige Anzeige

Der Monitor besteht aus drei Teilen:

1. `augustus-temp-collect` sammelt die Werte lokal auf `augustus`, inklusive SSH-Zugriff auf OpenWrt und die aktive GPU-VM.
2. `augustus-temp-collector.timer` ruft den Collector regelmässig auf. Der systemd-Service hat ein festes Zeitlimit; ein hängender SSH-Prozess darf den Monitor nicht dauerhaft blockieren.
3. `augustus-temp` zeigt ausschliesslich die letzte vollständige Momentaufnahme aus `/run/augustus-temp/snapshot` an, ohne selbst Hardware oder SSH abzufragen.

Installation auf `augustus` als root:

```bash
git clone https://github.com/masterkaffe/Augustus-Hardware-Monitor.git
cd Augustus-Hardware-Monitor
./install.sh
```

Bei bestehender Installation genügt `git pull && ./install.sh`, wenn keine lokalen Änderungen einen Konflikt verursachen.

Einmalige Anzeige:

```bash
augustus-temp
```

**Empfohlene Live-Anzeige (automatisches Ende nach 24 Stunden):**

```bash
augustus-watch
```

`augustus-watch` prüft nur alle 1 Sekunde den Zeitstempel der Snapshot-Datei und zeichnet das Terminal **erst bei neuen Messwerten** neu. Es ruft weder GPU noch OpenWrt ab. Bei fehlenden oder veralteten Messwerten bleibt die letzte vollständige Anzeige sichtbar; der Warnhinweis wird bei Erreichen der Altersgrenze aktualisiert. Der Collector läuft unabhängig weiter. Optional lässt sich das Polling mit `AUGUSTUS_WATCH_POLL=2 augustus-watch` anpassen.

Herkömmliches `watch -c -n2 augustus-temp` bleibt verfügbar, läuft aber ohne Zeitlimit und zeichnet auch unveränderte Werte neu. Die Option `AUGUSTUS_MAX_AGE=45` steuert die Warnschwelle für veraltete Momentaufnahmen.

Mehrere Terminals können gleichzeitig zugreifen, auch über SSH aus anderen VMs:

```bash
ssh root@augustus augustus-temp
```

(Der SSH-Zugang muss bereits eingerichtet sein; Hostnamen/IP-Adressen können abweichen.)

Collector-Zustand und Fehler:

```bash
systemctl status augustus-temp-collector.timer
systemctl status augustus-temp-collector.service
journalctl -u augustus-temp-collector.service -n 40 --no-pager
```

Der Collector wird nach Abschluss seiner Messung erneut geplant; bei SSH-Problemen kann ein Messzyklus länger dauern. Der letzte gültige Snapshot bleibt sichtbar und wird bei Überschreitung des Alterslimits als veraltet gekennzeichnet. Die Snapshot-Datei wird atomar ausgetauscht.


## OpenWrt SSH

The default OpenWrt target is:

```text
root@192.168.10.2
```

A passwordless SSH key is required for live OpenWrt data:

```bash
ssh -o BatchMode=yes root@192.168.10.2 'echo OK'
```

The command should return `OK` without prompting for a password.

## OpenWrt interface mapping

Current Augustus/OpenWrt mapping:

| Interface | Role | Link |
|---|---|---:|
| eth3 | WAN / Init7 | 25 Gbit/s |
| eth4 | Mellanox LAN | 10 Gbit/s |
| eth5 | Realtek LAN | 1 Gbit/s |
| eth6 | Aquantia 10G | shown as DOWN when no link is present |

## Color thresholds

Temperature thresholds depend on each sensor section.

Disk I/O and network utilization bars use:

- **0–59 %**: green
- **60–84 %**: yellow
- **85–100 %**: red

A red I/O bar means high utilization, not necessarily a hardware fault.

## Notes

Kurzlebiger Zählerzustand, Cache und Locks liegen unter `/run/augustus-temp/`. Der Collector verarbeitet jeweils einen Messzyklus, während beliebig viele Anzeigeprozesse den Cache lesen. Die GPU-Messung nutzt `intel_gpu_top` für Engines und `nvtop -s` für VRAM, sofern verfügbar.

## License

No license has been selected yet. Add an explicit license before treating the project as reusable third-party software.
