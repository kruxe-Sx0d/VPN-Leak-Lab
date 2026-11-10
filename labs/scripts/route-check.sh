#!/usr/bin/env bash
# route-check.sh — predict which interface/source the kernel will use (Lab 03).
#
# Usage:
#   ./route-check.sh                       # check a default set of destinations
#   ./route-check.sh 203.0.113.10 2001:db8:99::1   # check specific destinations
#
# Privileges: none. `ip route get` is read-only; it asks the kernel for its
# decision without sending any traffic.
#
# Reading the output: the `dev` field is the interface a packet would leave on.
# If it's your physical interface while the VPN is up, that destination leaks.

set -euo pipefail

command -v ip >/dev/null 2>&1 || { echo "missing tool: ip" >&2; exit 1; }

# Default probe set: a couple of public IPv4 + IPv6 documentation addresses.
if [[ $# -gt 0 ]]; then
  DESTS=("$@")
else
  DESTS=(203.0.113.10 198.51.100.5 2001:db8:99::1 2001:db8:42::1)
fi

printf '%-22s %s\n' "DESTINATION" "KERNEL ROUTE DECISION"
printf '%-22s %s\n' "-----------" "---------------------"
for d in "${DESTS[@]}"; do
  if [[ "$d" == *:* ]]; then
    result="$(ip -6 route get "$d" 2>&1)" || result="(no IPv6 route)"
  else
    result="$(ip route get "$d" 2>&1)" || result="(no route)"
  fi
  # Collapse to one line for a tidy table.
  result="$(echo "$result" | tr '\n' ' ' | sed 's/  */ /g')"
  printf '%-22s %s\n' "$d" "$result"
done

printf '\nLook at the "dev" field: it should be the tunnel interface for a\n'
printf 'full-tunnel VPN. A physical interface here means that destination leaks.\n'