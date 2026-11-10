# 01 · Hardening the VPN

## Overview

This chapter turns the leak analysis into concrete configuration steps. Each
mechanism is paired with what it does and — just as importantly — what it does
**not** do, so you can stack them without false confidence.

## Secure configuration

Start from a correct full-tunnel baseline:

- **Full tunnel for both families.** WireGuard `AllowedIPs = 0.0.0.0/0, ::/0`
  with both an IPv4 and IPv6 tunnel address; OpenVPN `redirect-gateway` (and
  IPv6 handling). Verify, don't assume.
- **Set MTU appropriately** (e.g. 1420 for WireGuard) to avoid black-holed large
  packets.
- **Use a narrow server endpoint** (specific IP + port) so firewall allow rules
  can be precise.

*Limit:* configuration only protects traffic that matches it. Pre-existing
connections and reconnect gaps need the kill switch.

## DNS leak prevention

- Push/set the VPN's resolver on connect (`DNS =` in WireGuard).
- Ensure the resolver's address routes **through the tunnel**.
- With `systemd-resolved`, give the tunnel the default DNS domain (`~.`).
- Block outbound 53/853 on the physical interface as a backstop.
- Account for browser DoH that bypasses the system resolver.

*Limit:* DoH/DoT hides DNS from port-53 checks, so you must verify the resolver
endpoint and path, not just the absence of port-53 traffic.

## IPv6 handling

Two sound options, chosen by whether the VPN supports IPv6:

1. **Tunnel IPv6** (preferred when supported): add the IPv6 tunnel address and
   `::/0` coverage. Keeps IPv6 working and private.
2. **Block IPv6 outside the tunnel** (fallback): drop IPv6 on the physical
   interface so traffic falls back to protected IPv4.

> **IMPORTANT**
> Disabling IPv6 is **not** the universal or preferred solution. It's a fallback
> for VPNs that can't carry IPv6. Where IPv6 tunneling is available, use it —
> turning IPv6 off degrades connectivity and doesn't address the root cause.

*Limit:* blocking IPv6 can break IPv6-only services; tunneling requires provider
support.

## Kill switch implementation

- Default-deny egress on the physical interface; allow loopback, tunnel-interface
  egress, and the narrow encapsulated flow to the server. See the
  [template](../../labs/configs/kill-switch.nft) and [Lab 07](../07-practical-labs/lab-07-kill-switch.md).
- Cover **both** IPv4 and IPv6, and DNS.
- Test the disconnect case, not just connected.

*Limit:* a kill switch blocks traffic when the tunnel is down — it doesn't keep
you online. That's the intended trade-off (privacy over availability). It also
can't protect against a malicious provider (see [Module 04](../04-malicious-vpns/README.md)).

## Routing verification

Make verification a habit, not a one-time check:

```bash
ip route get 203.0.113.10        # IPv4 path
ip -6 route get 2001:db8:99::1   # IPv6 path
../../labs/scripts/route-check.sh
```

*Limit:* a route check shows the decision for *new* packets now; it doesn't
account for already-open connections or future route churn.

## Firewall considerations

- Keep allow rules narrow (specific endpoint, not "allow all to anywhere").
- Don't blanket-allow "established" out the physical interface in a kill switch —
  that re-opens the leak for pre-existing connections.
- Remember the order: routing decides the path, then Netfilter decides allow/drop.

## Mechanism summary

| Mechanism | Closes | Does NOT cover |
|-----------|--------|----------------|
| Full tunnel (v4+v6) | Most routing leaks | Reconnect gaps, existing sockets |
| DNS in tunnel | DNS path leaks | Browser DoH bypass unless configured |
| Kill switch | Tunnel-down windows | Provider-side observation |
| Route verification | Misconfiguration | Future changes after the check |
| Narrow firewall rules | Accidental broad bypass | Anything you explicitly allow |

## References

- [RFC 7359 — VPN Traffic Leakage](https://www.rfc-editor.org/rfc/rfc7359)
- [`wg-quick(8)`](https://man7.org/linux/man-pages/man8/wg-quick.8.html),
  [`nft(8)`](https://man7.org/linux/man-pages/man8/nft.8.html)
- [WireGuard quick-start](https://www.wireguard.com/quickstart/)

---

Next: [02 · Trust & Verification](02-trust-and-verification.md) ·
Back: [Module index](README.md)