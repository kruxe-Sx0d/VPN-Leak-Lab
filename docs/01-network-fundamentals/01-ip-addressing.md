# 01 · IP Addressing

Every packet carries two addresses: where it came from and where it's going.
A VPN leak almost always means one of those addresses is *not* the one you
expected. So it's worth being precise about what an IP address is and what
kinds exist.

## IPv4

An IPv4 address is a 32-bit number, usually written as four decimal octets:
`192.0.2.10`. Each octet is 8 bits, so each runs from 0 to 255. That gives
roughly 4.3 billion addresses — far fewer than the number of devices online,
which is why private addresses and NAT exist (more in
[chapter 06](06-nat-and-packet-flow.md)).

Some ranges have special jobs:

| Range | Purpose |
|-------|---------|
| `10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16` | Private ([RFC 1918](https://www.rfc-editor.org/rfc/rfc1918)); not routed on the public Internet |
| `127.0.0.0/8` | Loopback; traffic to yourself |
| `169.254.0.0/16` | Link-local; auto-assigned when no DHCP answer arrives |
| `192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24` | Documentation/examples ([RFC 5737](https://www.rfc-editor.org/rfc/rfc5737)); used throughout this repo |

> **CONCEPT**
> A **public** address is globally reachable and unique. A **private** address
> only has meaning inside a local network. When people say "my real IP leaked,"
> they usually mean their public IPv4 address — the one their ISP assigns and
> that a remote server can see and geolocate.

## IPv6

IPv6 is a 128-bit address written as eight groups of four hex digits:
`2001:db8:1::10`. The space is effectively unlimited, so the private/public
distinction works differently:

- **Global unicast** (currently `2000::/3`) is the public, routable space. Most
  hosts get a globally routable IPv6 address directly from their ISP — no NAT
  required.
- **Link-local** (`fe80::/10`) is auto-configured on every interface and only
  valid on the local link. Routers use these as next-hops.
- **Loopback** is `::1`.
- `2001:db8::/32` is reserved for documentation ([RFC 3849](https://www.rfc-editor.org/rfc/rfc3849))
  and is what this repo uses in examples.

IPv6 has a shorthand: one run of consecutive zero groups can be collapsed to
`::` (once per address), and leading zeros in a group can be dropped. So
`2001:0db8:0000:0000:0000:0000:0000:0010` becomes `2001:db8::10`.

> **IMPORTANT**
> A host can — and usually does — have a public IPv6 address *even when its
> IPv4 is private behind NAT*. This asymmetry is the root of IPv6 leaks: a VPN
> that only handles IPv4 leaves the IPv6 path wide open. We return to this in
> [Module 03](../03-vpn-leaks/03-ipv6-leaks.md).

## Dual-stack

A **dual-stack** host runs IPv4 and IPv6 simultaneously. It has both kinds of
address on the same interface, and the OS chooses which to use per connection
(generally preferring IPv6 when both work, per
[RFC 6724](https://www.rfc-editor.org/rfc/rfc6724)). That choice is exactly where
unexpected traffic paths appear: the IPv4 connection goes into the tunnel while
the IPv6 connection quietly goes out the physical interface.

You can see both families on one interface:

```bash
ip -brief addr
```

Illustrative output (documentation addresses):

```text
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             192.0.2.10/24 2001:db8:1::10/64 fe80::a00:27ff:fe4e:66a1/64
```

Read the `eth0` line: one IPv4 (`192.0.2.10/24`), one global IPv6
(`2001:db8:1::10/64`), and one link-local IPv6 (`fe80::…`). The `/24` and `/64`
are prefix lengths — the subject of the [next chapter](02-subnetting.md).

## What to look for

- Does the interface have a **global** IPv6 address, or only link-local? If it
  has a global one, IPv6 can reach the Internet without IPv4 at all.
- Is the IPv4 address public or in an RFC 1918 private range? That tells you
  whether NAT sits between you and the Internet.
- After connecting a VPN, you should see a *new* address on the tunnel
  interface (often `10.x.x.x`). The physical interface keeps its original
  addresses — that's normal, and it's why leaks are possible.

## References

- [RFC 791 — Internet Protocol (IPv4)](https://www.rfc-editor.org/rfc/rfc791)
- [RFC 8200 — IPv6 Specification](https://www.rfc-editor.org/rfc/rfc8200)
- [RFC 1918 — Private Address Space](https://www.rfc-editor.org/rfc/rfc1918)
- [RFC 5737 — IPv4 Documentation Addresses](https://www.rfc-editor.org/rfc/rfc5737)
- [RFC 3849 — IPv6 Documentation Prefix](https://www.rfc-editor.org/rfc/rfc3849)
- [RFC 6724 — Default Address Selection for IPv6](https://www.rfc-editor.org/rfc/rfc6724)

---

Next: [02 · Subnetting](02-subnetting.md) ·
Back: [Module index](README.md)