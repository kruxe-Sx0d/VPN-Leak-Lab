# 02 · Subnetting

An IP address on its own doesn't tell a host whether a destination is "on my
local network" or "somewhere else, reachable via a router." The **prefix**
attached to the address is what makes that decision possible. This is the idea
behind every routing decision a VPN does — or fails to make.

## Prefixes and masks

When you see `192.0.2.10/24`, the `/24` is the **prefix length**: the first 24
bits identify the *network*, and the remaining bits identify the *host* on that
network.

- `/24` → 24 network bits, 8 host bits → 2⁸ = 256 addresses
  (`192.0.2.0` through `192.0.2.255`).
- The older dotted "subnet mask" notation says the same thing: `/24` is
  `255.255.255.0` — a 1-bit for every network bit.

The first address of a block is the **network address** (`192.0.2.0`) and, in
IPv4, the last is the **broadcast address** (`192.0.2.255`). The addresses in
between are assignable to hosts.

> **CONCEPT**
> **CIDR** (Classless Inter-Domain Routing) is just the `/prefix` notation.
> "Classless" means the network/host split can fall at *any* bit, not only the
> old class A/B/C boundaries. A `/26`, `/27`, or `/30` are all valid.

## Working out a range

Take `198.51.100.77/26`. A `/26` leaves 6 host bits, so blocks are 64 addresses
wide: `.0–.63`, `.64–.127`, `.128–.191`, `.192–.255`. The address `.77` falls in
the second block, so:

- Network: `198.51.100.64`
- Usable hosts: `198.51.100.65` – `198.51.100.126`
- Broadcast: `198.51.100.127`

You rarely compute this by hand on Linux — the tools do it — but understanding
it lets you read a routing table and know what a route actually covers.

## Local vs remote

Here's the part that matters for leaks. When a host wants to send to a
destination, it asks: *does the destination fall inside any of my directly
connected prefixes?*

- **Yes** → the destination is on-link. The host resolves its MAC address
  (ARP for IPv4, Neighbor Discovery for IPv6) and sends the frame directly.
- **No** → the destination is off-link. The host sends the packet to a
  **gateway** (router) and lets it forward onward.

A VPN works by inserting routes so that "remote" destinations get pointed at the
tunnel interface instead of the physical gateway. If a destination isn't covered
by the VPN's routes, it stays "remote via the physical gateway" — a leak.

## IPv6 subnets

IPv6 uses the same prefix idea, but the conventions differ. A typical LAN is a
`/64` — that's the standard subnet size, required for stateless address
autoconfiguration (SLAAC). So `2001:db8:1::/64` is one LAN containing a huge
number of host addresses. You'll see `/64` on interfaces and `/128` for a single
host address (the IPv6 equivalent of a `/32` in IPv4).

```bash
ip -6 addr show dev eth0
```

Illustrative output:

```text
2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500
    inet6 2001:db8:1::10/64 scope global dynamic
       valid_lft 86395sec preferred_lft 86395sec
    inet6 fe80::a00:27ff:fe4e:66a1/64 scope link
```

The `scope global` line is the routable address; `scope link` is the link-local
one. Note both are `/64`, but they mean different things — the global `/64` is
your LAN prefix, the link-local `/64` is just the `fe80::/64` link.

## What to look for

- The prefix on each address tells you the size of the directly connected
  network.
- A route to `0.0.0.0/0` (IPv4) or `::/0` (IPv6) matches *everything* — that's
  the default route, covered in [chapter 04](04-routing.md).
- When a VPN adds routes, check their prefixes: a pair of `/1` routes
  (`0.0.0.0/1` and `128.0.0.0/1`) is a common trick to cover the whole IPv4 space
  without deleting the existing default route. More-specific prefixes always
  win, so these override the default.

## References

- [RFC 4632 — CIDR](https://www.rfc-editor.org/rfc/rfc4632)
- [RFC 4291 — IPv6 Addressing Architecture](https://www.rfc-editor.org/rfc/rfc4291)
- [RFC 4862 — IPv6 Stateless Address Autoconfiguration](https://www.rfc-editor.org/rfc/rfc4862)

---

Next: [03 · Network Interfaces](03-network-interfaces.md) ·
Back: [Module index](README.md)