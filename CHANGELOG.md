# Changelog

## 0.1.1 - 2026-09-29

- Fix concurrent state-file race condition that could cause `mv: cannot stat ...state.tmp`
- Add a non-blocking `flock` so only one monitor instance updates runtime state
- Use unique `mktemp` files for disk and network counters
- Clean temporary state files on exit


## 0.1.0 - 2026-09-29

Initial public version.

- CPU, CCD, RAM, GPU and NVMe temperature monitoring
- NCT6683 mainboard sensors
- Named fan mapping for Augustus
- Physical disk I/O utilization bars
- OpenWrt Mellanox/Aquantia temperature monitoring over SSH
- Live OpenWrt RX/TX throughput with adaptive units
- Installer and uninstaller
