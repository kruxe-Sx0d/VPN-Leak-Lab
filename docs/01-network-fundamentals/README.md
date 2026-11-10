# Module 01 · Network Fundamentals

Before you can understand how a VPN leaks, you need a mental model of how a
packet gets from an application to the network on an ordinary Linux box. This
module builds that model. Nothing here is VPN-specific yet — that comes next.

The chapters are ordered so each one only uses ideas from the ones before it.

| Chapter | Topic |
|---------|-------|
| [01 · IP Addressing](01-ip-addressing.md) | IPv4 and IPv6, and what an address actually identifies |
| [02 · Subnetting](02-subnetting.md) | Prefixes, masks, and how a host decides "local vs remote" |
| [03 · Network Interfaces](03-network-interfaces.md) | Physical and virtual interfaces, `ip addr`, `ip link`, `ip neigh` |
| [04 · Routing](04-routing.md) | Routing tables, the default gateway, `ip route`, `ip -6 route` |
| [05 · DNS](05-dns.md) | Name resolution, recursive resolvers, `dig`, `resolvectl status` |
| [06 · NAT & Packet Flow](06-nat-and-packet-flow.md) | NAT/SNAT/DNAT, TCP/IP basics, and a packet's path through Linux |

## How to read this module

Each chapter pairs a short explanation with commands you can run right now.
The example outputs use **documentation address ranges** reserved for examples
([RFC 5737](https://www.rfc-editor.org/rfc/rfc5737) for IPv4,
[RFC 3849](https://www.rfc-editor.org/rfc/rfc3849) for IPv6), so they are
illustrative, not captures from a real network. Run the commands yourself to
see your own values.

> **CONCEPT**
> A recurring theme: the operating system makes decisions (which interface,
> which source address, which resolver) *before* any application traffic leaves
> the machine. Most VPN leaks are these decisions going wrong, not the
> encryption failing.

## What you should be able to do afterwards

- Explain the difference between an IPv4 and an IPv6 address and why a host can
  have both at once (dual-stack).
- Read a prefix like `192.0.2.0/24` and say which addresses are local.
- List interfaces and tell a physical NIC from a virtual tunnel interface.
- Read `ip route` output and predict where a packet to a given destination goes.
- Trace a DNS lookup and name the resolver that answered it.
- Describe, in order, what happens to a packet from `send()` to the wire.

When that feels comfortable, continue to
[Module 02 · VPN Fundamentals](../02-vpn-fundamentals/README.md).