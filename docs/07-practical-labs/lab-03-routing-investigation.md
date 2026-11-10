# Lab 03 · Routing Table Investigation

## 1. Objective

See exactly how the kernel decides where each destination goes, before and after
the VPN, and understand longest-prefix match well enough to spot a routing leak.

## 2. Required knowledge

- [Module 01, routing](../01-network-fundamentals/04-routing.md).
- [Module 03, routing leaks](../03-vpn-leaks/05-routing-leaks.md).
- [Lab 02](lab-02-vpn-interface-analysis.md) (a working tunnel).

## 3. Required tools

`ip` (especially `ip route get`), and the helper
[`route-check.sh`](../../labs/scripts/route-check.sh).

## 4. Lab topology

The client VM, with the WireGuard tunnel from Lab 02 available to bring up/down.

## 5. Environment setup

Complete Lab 02 so you can toggle the tunnel. No extra packages.

## 6–7. Steps and commands

**Baseline (VPN down):**

```bash
ip route
../../labs/scripts/route-check.sh        # predicts routes to several targets
```

**VPN up:**

```bash
sudo wg-quick up ./wg-client.conf
ip route                                  # note the new default / covering routes
../../labs/scripts/route-check.sh        # same targets, now via wg0
ip route get 203.0.113.10                # single-destination decision
ip -6 route get 2001:db8:99::1           # IPv6 decision (often still eth0!)
```

**Demonstrate longest-prefix match** (safe, reversible, on the client):

```bash
# Add a more-specific physical route for one documentation range:
sudo ip route add 203.0.113.0/24 via 192.0.2.1 dev eth0
ip route get 203.0.113.10                # now goes via eth0 despite the tunnel!
# Remove it again:
sudo ip route del 203.0.113.0/24 via 192.0.2.1 dev eth0
ip route get 203.0.113.10                # back via wg0
```

## 8. Expected observations

- With the VPN down, all probes resolve to the physical interface.
- With a full tunnel up, IPv4 probes resolve to `wg0`.
- The IPv6 probe may still resolve to `eth0` if the tunnel/config doesn't cover
  IPv6 — a real, observable gap.
- Adding the `/24` physical route overrides the tunnel for that range, proving
  that specificity beats the covering routes.

## 9. Illustrative output

> **ILLUSTRATIVE** — not a real capture.

```text
$ ./route-check.sh            # VPN up, full IPv4 tunnel
DESTINATION            KERNEL ROUTE DECISION
203.0.113.10           203.0.113.10 dev wg0 src 10.8.0.2
198.51.100.5           198.51.100.5 dev wg0 src 10.8.0.2
2001:db8:99::1         2001:db8:99::1 via fe80::1 dev eth0 src 2001:db8:1::10

$ ip route get 203.0.113.10   # after adding the /24 physical route
203.0.113.10 via 192.0.2.1 dev eth0 src 192.0.2.10
```

## 10. Technical explanation

`ip route get` runs the kernel's actual longest-prefix-match decision without
sending traffic. A full tunnel wins by installing a default (or two `/1`s) via
`wg0`, but any *more-specific* route elsewhere overrides it for that range —
which is precisely how routing leaks survive a "full tunnel." The separate IPv6
table shows why IPv4-only coverage leaves IPv6 exposed.

## 11. Troubleshooting

- **`RTNETLINK answers: File exists`** adding the route — it's already there;
  skip the add or delete it first.
- **`Nexthop has invalid gateway`** — use your real gateway/interface from
  `ip route`, not the documentation values.
- **IPv6 probe says "no route"** — the lab network is IPv4-only; note that and
  move on (Lab 05 covers IPv6 where it exists).

## 12. Cleanup

```bash
sudo ip route del 203.0.113.0/24 via 192.0.2.1 dev eth0   # if you added it
sudo wg-quick down ./wg-client.conf                       # if you brought it up
ip route                                                  # confirm normal table
```

## 13. Learning outcomes

You can predict a packet's interface with `ip route get`, explain longest-prefix
match, demonstrate how a specific route creates a leak, and check IPv4 and IPv6
independently.

---

Next: [Lab 04 · DNS Leak Investigation](lab-04-dns-leak.md) ·
Back: [Lab index](README.md)