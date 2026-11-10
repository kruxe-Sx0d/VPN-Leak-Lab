# 03 · Observing VPN Traffic

## Overview

This chapter ties capture skills to the VPN itself: what encapsulated traffic
looks like on the wire, how to compare before/after, and how to interpret the
results without over-claiming. It's the direct preparation for
[Lab 06](../07-practical-labs/lab-06-traffic-analysis.md).

## What the tunnel looks like on the physical interface

With WireGuard up, capture on `eth0`:

```bash
sudo tcpdump -ni eth0 'udp port 51820'
```

Illustrative output:

```text
IP 192.0.2.10.51820 > 198.51.100.5.51820: UDP, length 148
IP 198.51.100.5.51820 > 192.0.2.10.51820: UDP, length 132
IP 192.0.2.10.51820 > 198.51.100.5.51820: UDP, length 148
```

Notice what's **not** there: no readable DNS, no HTTP, no inner destinations.
Just a stream of UDP datagrams between you and the VPN server, each an opaque
blob. Add `-X` and the payload is ciphertext — no structure to decode. That
opacity *is* the protection working.

> **OBSERVATION**
> On the physical interface you can see the tunnel's *existence* (your IP ↔
> server IP, UDP/51820, timing, sizes) but not its *contents*. This is exactly
> the distinction from [Module 02](../02-vpn-fundamentals/02-tunneling-and-encapsulation.md):
> encapsulation hides the inside, not the fact of the tunnel.

## What the same traffic looks like inside the tunnel

Capture on `wg0` at the same time:

```bash
sudo tcpdump -ni wg0
```

Illustrative output:

```text
IP 10.8.0.2.52314 > 10.8.0.1.53: 4242+ A? example.com. (29)
IP 10.8.0.2.47122 > 203.0.113.80.443: Flags [S], seq 100, length 0
```

Here you see the **inner** packets: the tunnel source `10.8.0.2`, the real
destinations, readable DNS. Comparing the two captures proves the traffic is
being encapsulated: readable inside, opaque outside.

## Before/after comparison method

The cleanest way to verify a VPN changes the path:

1. **Before:** with the VPN down, capture on `eth0` while you `dig` and `curl`.
   You'll see plaintext DNS and connections with your real source.
2. **After:** bring the VPN up, repeat the *same* actions, capture on `eth0`
   again. You should now see only the tunnel stream (no plaintext DNS, no direct
   connections).
3. **Diff the observations:** anything that still appears in the clear on
   `eth0` after the VPN is up is a leak.

Save both captures (`-w before.pcap`, `-w after.pcap`) and open them side by side
in Wireshark, or use the [comparison script](../../labs/scripts/capture-summary.sh)
to summarize each.

## Interpreting results honestly

A few rules keep you from over-claiming:

- **Absence of port-53 traffic ≠ no DNS leak.** DoH/DoT hides DNS in TLS. Check
  the resolver endpoint and route.
- **Seeing the tunnel ≠ full tunnel.** The tunnel can be up while some traffic
  (IPv6, specific routes) bypasses it. Test both families and several
  destinations.
- **One passing test ≠ no leaks.** Existing connections, other apps, and
  reconnect windows aren't covered by a single fresh `curl`.
- **A capture is evidence of a moment.** It shows what happened during the
  capture window, not a guarantee about all future traffic.

> **IMPORTANT**
> Label your conclusions precisely: "during this capture, DNS to the ISP
> resolver appeared on eth0" is a finding. "My VPN never leaks" is not something
> a single capture can prove.

## A minimal interpretation checklist

- [ ] Captured on the **physical** interface.
- [ ] Generated known traffic (`dig`, `curl -4`, `curl -6`).
- [ ] Confirmed the tunnel stream is present (VPN actually up).
- [ ] Checked for plaintext DNS, direct TCP, and IPv6 outside the tunnel.
- [ ] Repeated for IPv6 explicitly.
- [ ] Noted the capture window and what it does *not* cover.

## References

- [WireGuard protocol](https://www.wireguard.com/protocol/)
- [`tcpdump(1)`](https://man7.org/linux/man-pages/man1/tcpdump.1.html)
- [Wireshark User's Guide](https://www.wireshark.org/docs/wsug_html/)
- [RFC 7359 — VPN Traffic Leakage](https://www.rfc-editor.org/rfc/rfc7359)

---

Next: [Module 07 · Practical Labs](../07-practical-labs/README.md) ·
Back: [Module index](README.md)