# 04 · Routing

Routing is the decision process that picks an interface and a next-hop for every
outgoing packet. If you understand this chapter, you understand most of how VPN
leaks happen: a leak is usually just a packet matching the *wrong* route.

## The routing table

The kernel keeps a table of rules of the form "to reach *this network*, send via
*that gateway* out *this interface*." View it with:

```bash
ip route
```

Illustrative output for a host before any VPN:

```text
default via 192.0.2.1 dev eth0 proto dhcp src 192.0.2.10 metric 100
192.0.2.0/24 dev eth0 proto kernel scope link src 192.0.2.10
```

Read each field:

- `default` is shorthand for `0.0.0.0/0` — the route that matches any
  destination not covered by a more specific entry.
- `via 192.0.2.1` is the **gateway** (next-hop router).
- `dev eth0` is the outgoing interface.
- `src 192.0.2.10` is the source address the kernel will use.
- `proto dhcp` / `proto kernel` records who installed the route.
- `metric 100` is a preference value; lower wins when two routes are equally
  specific.

The second line is the **directly connected** route for the local `/24`. It has
no `via` because those hosts are on-link (see
[chapter 02](02-subnetting.md)).

## Longest prefix match

When several routes could match a destination, the kernel picks the one with
the **longest prefix** (most specific). A `/24` beats a `/16`, which beats the
`/0` default. This single rule explains a lot of VPN behavior.

Example: suppose the table has

```text
default via 192.0.2.1 dev eth0
203.0.113.0/24 via 10.8.0.1 dev wg0
```

A packet to `203.0.113.10` matches both, but the `/24` is more specific, so it
goes into `wg0`. A packet to `198.51.100.5` matches only the default, so it goes
out `eth0` — unless the VPN also covers it.

> **CONCEPT**
> A full-tunnel VPN wants *every* destination to match a tunnel route. Clients
> achieve this either by replacing the default route with one pointing at the
> tunnel, or by adding the two covering routes `0.0.0.0/1` and `128.0.0.0/1`.
> Both `/1`s are more specific than the `/0` default, so they win without
> deleting it. If either is missing, half the address space leaks.

## The IPv6 table is separate

IPv4 and IPv6 have **independent** routing tables. A VPN that installs only IPv4
routes does nothing to IPv6. Inspect it with:

```bash
ip -6 route
```

Illustrative output:

```text
2001:db8:1::/64 dev eth0 proto ra metric 100
fe80::/64 dev eth0 proto kernel metric 256
default via fe80::1 dev eth0 proto ra metric 100
```

Notice the `default via fe80::1` — an IPv6 default route out the *physical*
interface. If the VPN doesn't add an IPv6 default (or covering) route through the
tunnel, IPv6 traffic uses this path and exposes your real IPv6 address. This is
the mechanism behind [IPv6 leaks](../03-vpn-leaks/03-ipv6-leaks.md).

## Predicting a route: `ip route get`

Instead of guessing, ask the kernel directly:

```bash
ip route get 203.0.113.10
ip -6 route get 2001:db8:99::1
```

Illustrative output:

```text
203.0.113.10 via 10.8.0.1 dev wg0 src 10.8.0.2
```

This tells you the exact interface, next-hop, and source address the kernel will
use. It's the single most useful command for leak hunting: run it before and
after connecting the VPN and compare. If a destination still resolves to `eth0`
after the VPN is up, that's a leak path.

## Policy routing: `ip rule`

Some VPN clients (WireGuard's `wg-quick`, for instance) don't just add routes —
they add **rules** that select between multiple routing tables based on source
address or firewall marks. View the rule list with:

```bash
ip rule
```

Illustrative output:

```text
0:      from all lookup local
32766:  from all lookup main
32767:  from all lookup default
```

A full-tunnel WireGuard setup may add a rule sending marked traffic to a
separate table. You don't need to master policy routing to follow the labs, but
know it exists so `ip rule` output doesn't surprise you. We use it in
[Lab 03](../07-practical-labs/lab-03-routing-investigation.md).

## What to look for

- Before the VPN: note the default route and its interface.
- After the VPN: the default (or the two `/1`s) should point at the tunnel.
- Run `ip route get` for a public IPv4 and a public IPv6 destination. Both
  should resolve to the tunnel for a true full-tunnel setup.
- Check `ip -6 route` separately — it's the most commonly forgotten table.

## References

- Linux man pages: [`ip-route(8)`](https://man7.org/linux/man-pages/man8/ip-route.8.html),
  [`ip-rule(8)`](https://man7.org/linux/man-pages/man8/ip-rule.8.html)
- [RFC 1812 — Requirements for IP Version 4 Routers](https://www.rfc-editor.org/rfc/rfc1812)
- [WireGuard quick-start (routing notes)](https://www.wireguard.com/quickstart/)

---

Next: [05 · DNS](05-dns.md) ·
Back: [Module index](README.md)