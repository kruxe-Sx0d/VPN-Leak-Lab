#!/usr/bin/env bash
# net-inspect.sh — read-only snapshot of local network state (Lab 01).
#
# Usage:
#   ./net-inspect.sh            # inspect all interfaces
#   ./net-inspect.sh eth0       # focus on one interface
#
# Privileges: none required. Some process/socket detail may be limited without
# root, but nothing here changes system state. Safe to run anywhere.

set -euo pipefail

IFACE="${1:-}"

need() {
  command -v "$1" >/dev/null 2>&1 || { echo "missing tool: $1" >&2; exit 1; }
}
need ip
need ss

section() { printf '\n=== %s ===\n' "$1"; }

section "Interfaces (ip -brief link)"
ip -brief link

section "Addresses (ip -brief addr)"
if [[ -n "$IFACE" ]]; then
  ip -brief addr show dev "$IFACE"
else
  ip -brief addr
fi

section "IPv4 routes (ip route)"
ip route

section "IPv6 routes (ip -6 route)"
ip -6 route || echo "(no IPv6 routes / IPv6 disabled)"

section "Neighbors (ip neigh)"
ip neigh || true

section "Listening sockets (ss -tulpn)"
ss -tulpn || true

section "DNS configuration"
if command -v resolvectl >/dev/null 2>&1; then
  resolvectl status || true
elif [[ -r /etc/resolv.conf ]]; then
  cat /etc/resolv.conf
else
  echo "(no resolvectl and no readable /etc/resolv.conf)"
fi

printf '\nDone. This was a read-only inspection; nothing was changed.\n'