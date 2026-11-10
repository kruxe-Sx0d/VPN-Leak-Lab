#!/usr/bin/env bash
# dns-leak-check.sh — check whether DNS leaves the physical interface (Lab 04).
#
# Usage:
#   sudo ./dns-leak-check.sh eth0                 # probe with a default domain
#   sudo ./dns-leak-check.sh eth0 example.com     # probe a specific domain
#
# Privileges: ROOT (tcpdump needs it). Pass the PHYSICAL interface, not the
# tunnel — the whole point is to see what escapes onto the real network.
#
# What it does:
#   1. Shows the configured resolver(s).
#   2. Captures port-53 traffic on the given interface for a few seconds.
#   3. Generates one DNS query during the capture.
#   4. Reports whether the query appeared on that interface.
#
# Interpretation: seeing the query on the physical interface while the VPN is up
# is a DNS path leak. Seeing nothing there (only the tunnel stream) suggests DNS
# stayed inside. NOTE: with DoH/DoT there is no port-53 traffic to see — this
# check is for classic DNS.

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "This script needs root for tcpdump. Re-run with sudo." >&2
  exit 1
fi
if [[ $# -lt 1 ]]; then
  echo "Usage: sudo $0 <physical-interface> [domain]" >&2
  exit 1
fi

IFACE="$1"
DOMAIN="${2:-example.com}"
SECONDS_CAPTURE=5
TMP="$(mktemp /tmp/dns-leak-check.XXXXXX.pcap)"
trap 'rm -f "$TMP"' EXIT

command -v tcpdump >/dev/null 2>&1 || { echo "missing tool: tcpdump" >&2; exit 1; }
command -v dig >/dev/null 2>&1 || { echo "missing tool: dig" >&2; exit 1; }
ip link show dev "$IFACE" >/dev/null 2>&1 || { echo "no such interface: $IFACE" >&2; exit 1; }

echo "=== Configured resolver(s) ==="
if command -v resolvectl >/dev/null 2>&1; then
  resolvectl status || true
else
  cat /etc/resolv.conf 2>/dev/null || echo "(no /etc/resolv.conf)"
fi

echo
echo "=== Capturing port 53 on $IFACE for ${SECONDS_CAPTURE}s while querying $DOMAIN ==="
timeout "$SECONDS_CAPTURE" tcpdump -ni "$IFACE" -w "$TMP" 'udp port 53 or tcp port 53' 2>/dev/null &
CAP_PID=$!
sleep 1
dig +time=2 +tries=1 "$DOMAIN" >/dev/null 2>&1 || true
wait "$CAP_PID" 2>/dev/null || true

echo
echo "=== DNS packets seen on $IFACE ==="
if tcpdump -nr "$TMP" 2>/dev/null | grep -q .; then
  tcpdump -nr "$TMP" 2>/dev/null
  echo
  echo "RESULT: DNS traffic appeared on $IFACE."
  echo "If the VPN is up, this is a DNS path leak. Confirm the resolver and route."
else
  echo "(none)"
  echo
  echo "RESULT: no port-53 traffic on $IFACE during the probe."
  echo "DNS likely stayed in the tunnel — but if DoH/DoT is in use, this test"
  echo "cannot see it. Check the resolver endpoint and its route separately."
fi