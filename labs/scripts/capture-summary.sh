#!/usr/bin/env bash
# capture-summary.sh — summarize a .pcap by traffic category (Lab 06).
#
# Usage:
#   ./capture-summary.sh before.pcap
#   ./capture-summary.sh before.pcap after.pcap     # compare two captures
#
# Privileges: none. Reading a capture file does not need root. Requires tcpdump.
#
# It counts packets in a few leak-relevant categories so you can compare a
# "before VPN" and "after VPN" capture at a glance. Counts are a starting point,
# not a verdict — open the file in Wireshark to interpret.

set -euo pipefail

command -v tcpdump >/dev/null 2>&1 || { echo "missing tool: tcpdump" >&2; exit 1; }
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <capture.pcap> [another.pcap]" >&2
  exit 1
fi

count() { # count <file> <filter>
  tcpdump -nr "$1" "$2" 2>/dev/null | wc -l
}

summarize() {
  local f="$1"
  [[ -r "$f" ]] || { echo "cannot read: $f" >&2; return 1; }
  echo "=== $f ==="
  printf '  %-28s %s\n' "total packets:"        "$(count "$f" '')"
  printf '  %-28s %s\n' "DNS (port 53):"        "$(count "$f" 'udp port 53 or tcp port 53')"
  printf '  %-28s %s\n' "WireGuard (udp 51820):" "$(count "$f" 'udp port 51820')"
  printf '  %-28s %s\n' "IPv6:"                 "$(count "$f" 'ip6')"
  printf '  %-28s %s\n' "TCP SYN (conn starts):" "$(count "$f" 'tcp[tcpflags] & (tcp-syn) != 0')"
  printf '  %-28s %s\n' "STUN (udp 3478):"      "$(count "$f" 'udp port 3478')"
  echo
}

for f in "$@"; do
  summarize "$f"
done

echo "Interpretation: after the VPN is up, DNS / direct TCP / IPv6 counts on the"
echo "PHYSICAL interface should drop to ~0, leaving mostly the WireGuard stream."
echo "Anything else still present is a candidate leak. Verify in Wireshark."