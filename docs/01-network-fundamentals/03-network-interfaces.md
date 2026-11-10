# 03 · Network Interfaces

An **interface** is the kernel's abstraction for a network attachment point.
Every packet leaves (or enters) through one. A VPN adds a *virtual* interface,
and understanding the difference between physical and virtual interfaces is
essential to seeing where traffic actually goes.

## Physical vs virtual

- **Physical interfaces** map to real hardware: an Ethernet port (`eth0`,
  `enp3s0`) or a Wi-Fi radio (`wlan0`, `wlp2s0`). Frames ultimately become
  electrical or radio signals here.
- **Virtual interfaces** exist only in software. The kernel creates them to
  represent something logical:
  - `lo` — loopback, for traffic to the machine itself.
  - `tun0` / `wg0` — a VPN tunnel. Packets written here get encapsulated and
    sent out a physical interface.
  - `veth` pairs, bridges (`br0`, `docker0`) — used by containers and VMs.

> **CONCEPT**
> A tunnel interface is a *fake* network card whose "cable" is actually another
> network connection. Writing a packet to `wg0` doesn't put it on a wire; it
> hands it to the VPN software, which wraps it and sends it out `eth0`. This is
> the whole trick of tunneling, and we'll dissect it in
> [Module 02](../02-vpn-fundamentals/02-tunneling-and-encapsulation.md).

## Listing interfaces: `ip link`

`ip link` shows layer-2 information: name, state, MAC address, and MTU.

```bash
ip link
```

Illustrative output:

```text
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
    link/ether 02:00:5e:10:00:0a brd ff:ff:ff:ff:ff:ff
```

What to read:

- The leading number (`1:`, `2:`) is the interface **index**, used elsewhere.
- `UP` means administratively enabled; `LOWER_UP` means the underlying link is
  actually up (cable plugged / associated). A tunnel can be `UP` without
  `LOWER_UP` semantics.
- `mtu 1500` is the maximum packet size. Tunnels often need a *smaller* MTU
  (e.g. 1420) because encapsulation adds headers — a frequent source of
  "the VPN connects but some sites stall" problems.
- `link/ether 02:00:5e:10:00:0a` is the MAC address. Tunnel interfaces usually
  show `link/none` because there's no real link layer.

## Addresses on interfaces: `ip addr`

`ip addr` adds layer-3 information — the IPv4 and IPv6 addresses bound to each
interface.

```bash
ip addr show dev eth0
```

Illustrative output:

```text
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP
    inet 192.0.2.10/24 brd 192.0.2.255 scope global dynamic eth0
       valid_lft 86395sec preferred_lft 86395sec
    inet6 2001:db8:1::10/64 scope global dynamic
    inet6 fe80::a00:27ff:fe4e:66a1/64 scope link
```

`scope global` means routable beyond the local link; `scope link` is
link-local only; `scope host` is loopback-style (only this machine). After a VPN
connects, run `ip addr` again and you'll see a new interface (`wg0`/`tun0`) with
its own address — typically a private `10.x.x.x`.

## Neighbors: `ip neigh`

To deliver a frame on a local network, the host needs the destination's (or the
gateway's) MAC address. The **neighbor table** caches these mappings — ARP for
IPv4, Neighbor Discovery for IPv6.

```bash
ip neigh
```

Illustrative output:

```text
192.0.2.1 dev eth0 lladdr 02:00:5e:10:00:01 REACHABLE
fe80::1 dev eth0 lladdr 02:00:5e:10:00:01 router STALE
```

Each line maps an IP to a link-layer address (`lladdr`) on an interface, with a
state:

- `REACHABLE` — recently confirmed working.
- `STALE` — known but not recently verified; the kernel will re-probe on use.
- `router` — this neighbor is acting as a default gateway.

This matters because your traffic to the Internet goes to the *gateway's* MAC,
not the destination's. When a VPN takes over, the next-hop for tunneled traffic
becomes the tunnel, not this gateway.

## What to look for

- Identify your physical interface(s) and note their names — you'll reference
  them constantly in the labs.
- Note whether a global IPv6 address is present (see
  [chapter 01](01-ip-addressing.md)).
- After connecting a VPN, confirm a new virtual interface appeared and has an
  address. If it doesn't, the tunnel isn't actually up.
- Watch the MTU on the tunnel interface; mismatches cause subtle failures.

## References

- Linux man pages: [`ip-link(8)`](https://man7.org/linux/man-pages/man8/ip-link.8.html),
  [`ip-address(8)`](https://man7.org/linux/man-pages/man8/ip-address.8.html),
  [`ip-neighbour(8)`](https://man7.org/linux/man-pages/man8/ip-neighbour.8.html)
- [RFC 826 — ARP (IPv4)](https://www.rfc-editor.org/rfc/rfc826)
- [RFC 4861 — Neighbor Discovery for IPv6](https://www.rfc-editor.org/rfc/rfc4861)

---

Next: [04 · Routing](04-routing.md) ·
Back: [Module index](README.md)