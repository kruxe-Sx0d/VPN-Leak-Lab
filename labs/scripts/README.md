# Lab Scripts

Small, readable helpers used by the [practical labs](../../docs/07-practical-labs/README.md).
Each script has usage notes in its header comment; this page is the quick index.

| Script | Purpose | Privileges | Used by |
|--------|---------|------------|---------|
| [`net-inspect.sh`](net-inspect.sh) | Read-only snapshot of addresses, routes, neighbors, sockets, and resolvers | none | Lab 01 |
| [`route-check.sh`](route-check.sh) | Ask the kernel which interface a destination would leave through (`ip route get`) | none | Lab 03, 05 |
| [`ip-echo.py`](ip-echo.py) | Minimal HTTP server that reports the source IP of each request | none (bind port ≥ 1024) | Lab 02, 04, 05, 07 |
| [`dns-leak-check.sh`](dns-leak-check.sh) | Watch the physical interface for DNS while resolving a name | root | Lab 04 |
| [`capture-summary.sh`](capture-summary.sh) | Count packet types in a `.pcap` (DNS, WireGuard, IPv6, SYN, STUN) | none | Lab 06 |

## Running them

```bash
cd labs/scripts

./net-inspect.sh                       # full snapshot
./net-inspect.sh eth0                  # focus on one interface

./route-check.sh                       # default destination set
./route-check.sh 203.0.113.10 2001:db8:99::1

python3 ip-echo.py                     # on the server VM, listens on :8080
python3 ip-echo.py --bind ::           # dual-stack listener for the IPv6 lab

sudo ./dns-leak-check.sh eth0          # pass the PHYSICAL interface, not wg0
sudo ./dns-leak-check.sh eth0 example.com

./capture-summary.sh before.pcap after.pcap
```

## Design rules

- **Read-only by default.** Only `dns-leak-check.sh` captures traffic, and it
  writes to a temporary file that it removes on exit. Nothing here changes
  routing, firewall state, or interface configuration.
- **No hidden dependencies.** The Bash scripts use `iproute2`, `ss`,
  `resolvectl`, `dig`, and `tcpdump`; the Python script uses only the standard
  library. Each script checks for the tools it needs and exits with a clear
  message if one is missing.
- **Root only where required.** Capturing packets needs root; everything else
  runs as a normal user.
- **Safe addresses only.** Example destinations come from the documentation
  ranges (RFC 5737 / RFC 3849), matching the
  [lab address plan](../../docs/07-practical-labs/README.md).

> **WARNING**
> Run these only on machines you control, as part of the labs. `dns-leak-check.sh`
> captures real traffic on the interface you name — do not point it at networks
> carrying other people's traffic.