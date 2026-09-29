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

## Install

Clone the repository and run:

```bash
git clone https://github.com/masterkaffe/Augustus-Hardware-Monitor.git
cd Augustus-Hardware-Monitor
sudo ./install.sh
```

Then start it with:

```bash
augustus-temp
```

For a continuously refreshing dashboard:

```bash
watch -c -n2 augustus-temp
```

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

The dashboard stores short-lived counter state under:

```text
/run/augustus-temp/
```

This is used to calculate disk utilization and network throughput between refreshes.

## License

No license has been selected yet. Add an explicit license before treating the project as reusable third-party software.
