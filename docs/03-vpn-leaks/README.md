# Module 03 · VPN Traffic Leaks

This is the heart of the project. A **leak** is traffic that escapes the VPN
tunnel and travels over the ordinary network, exposing something the VPN was
supposed to hide — your real IP, a DNS query, an IPv6 connection. Each chapter
below dissects one leak class using the same structure, so you can compare them.

| Chapter | Leak class |
|---------|-----------|
| [01 · Public IP Leaks](01-public-ip-leaks.md) | Your real IPv4 address reaches a destination |
| [02 · DNS Leaks](02-dns-leaks.md) | Name resolution goes outside the tunnel |
| [03 · IPv6 Leaks](03-ipv6-leaks.md) | IPv6 bypasses an IPv4-only tunnel |
| [04 · WebRTC Leaks](04-webrtc-leaks.md) | Browser ICE/STUN discloses addresses |
| [05 · Routing Leaks](05-routing-leaks.md) | Wrong routes send traffic out the physical interface |
| [06 · Split Tunneling Risks](06-split-tunneling-risks.md) | Deliberate bypasses wider than intended |
| [07 · Kill Switch Failures](07-kill-switch-failures.md) | Traffic flows when the tunnel drops |

## Chapter structure

Every chapter follows the same outline:

1. Overview
2. Technical background
3. How it works
4. Packet / traffic flow
5. Architecture diagram
6. Root causes
7. Practical scenario
8. Detection methods
9. Prevention techniques
10. Common misconceptions
11. References

## Two distinctions to keep straight

> **IMPORTANT**
> **Leakage ≠ detection.** A *leak* is your traffic escaping the tunnel (this
> module). *Detection* is a platform recognizing that you're using a VPN even
> when nothing leaks ([Module 05](../05-vpn-detection/README.md)). A perfectly
> leak-free VPN can still be detected; a VPN can leak without being detected.
> They're separate problems with separate fixes.

> **IMPORTANT**
> **IPv4 ≠ IPv6.** Your public IPv4 (often the router's, via NAT) and your
> public IPv6 (often assigned straight to your host) are different addresses on
> different routing tables. A tunnel can protect one and not the other. Several
> chapters below hinge on this asymmetry.

## How to use this module

Read the chapters in order the first time; routing (05) and kill switches (07)
tie the others together. Then reproduce the behavior in
[Module 07's labs](../07-practical-labs/README.md) — Lab 04 (DNS), Lab 05 (IPv6),
and Lab 07 (kill switch) map directly onto these chapters.

Prerequisites: [Module 01](../01-network-fundamentals/README.md) and
[Module 02](../02-vpn-fundamentals/README.md).