# 02 · Inspecting DNS & TCP

## Overview

Now that you can capture, let's read the two patterns you'll use constantly:
DNS queries (to spot leaks) and the TCP handshake (to confirm connections and
where they go). Both are small, recognizable, and perfect for building
confidence.

## DNS queries

Generate one and capture it:

```bash
# terminal 1
sudo tcpdump -ni eth0 'udp port 53'
# terminal 2
dig example.com
```

Illustrative capture:

```text
IP 192.0.2.10.52314 > 192.0.2.53.53: 4242+ A? example.com. (29)
IP 192.0.2.53.53 > 192.0.2.10.52314: 4242 1/0/0 A 203.0.113.80 (45)
```

Read it:

- `4242+` — transaction ID 4242, `+` means recursion desired.
- `A? example.com.` — a question for the IPv4 (`A`) record.
- The reply `1/0/0 A 203.0.113.80` — one answer, zero authority, zero
  additional records.

The key leak question: **which interface did this appear on?** If it's on
`eth0` while the VPN is up, DNS is escaping. If `eth0` shows only the tunnel
stream and the query appears on `wg0` instead, it stayed inside.

With `-vv` you get the full decode:

```bash
sudo tcpdump -ni eth0 -vv 'udp port 53'
```

In Wireshark, filter `dns` and expand the *Domain Name System* tree to see
flags, questions, and answers cleanly.

> **TECHNICAL NOTE**
> If the system uses DoH/DoT, you won't see this port-53 pattern. You'll see TLS
> to port 443/853 instead. The *absence* of DNS packets is then ambiguous — check
> the resolver endpoint and its route, as discussed in
> [Module 03, DNS leaks](../03-vpn-leaks/02-dns-leaks.md).

## The TCP three-way handshake

Before TCP data flows, three packets establish the connection. Capture one:

```bash
sudo tcpdump -ni eth0 'tcp[tcpflags] & (tcp-syn) != 0'
# then, in another terminal:
curl -4 http://example.com >/dev/null
```

Illustrative capture (the three packets):

```text
IP 192.0.2.10.47122 > 203.0.113.80.80: Flags [S], seq 100, win 64240, length 0
IP 203.0.113.80.80 > 192.0.2.10.47122: Flags [S.], seq 500, ack 101, win 65160, length 0
IP 192.0.2.10.47122 > 203.0.113.80.80: Flags [.], ack 501, win 502, length 0
```

The flags tell the story:

- `[S]` — SYN: client proposes a connection, picks initial sequence 100.
- `[S.]` — SYN-ACK: server agrees, picks its own sequence 500, acknowledges 101.
- `[.]` — ACK: client acknowledges 501. Connection established.

After this, data packets carry `Flags [P.]` (push) with `length > 0`.

For leak hunting, the handshake's **source address and interface** are what
matter: a SYN to a public destination leaving `eth0` with your real source while
the VPN is up is a leaked connection.

In Wireshark, filter `tcp.flags.syn == 1` to list connection attempts, or
right-click → *Follow → TCP Stream* to see a whole conversation.

## UDP traffic

UDP has no handshake. A DNS query is typically one request datagram and one
reply; WireGuard is a continuous stream of UDP datagrams with no connection
setup to observe. That's why you can't "follow a UDP connection" the way you do
TCP — you infer flows from the 4-tuple and timing.

```bash
sudo tcpdump -ni eth0 'udp'                      # all UDP
sudo tcpdump -ni eth0 'udp port 51820'           # just the WireGuard stream
```

## Putting the patterns to work

| You see on `eth0` (VPN up) | Interpretation |
|----------------------------|----------------|
| Only UDP/51820 to the VPN server | Traffic is tunneled (good) |
| DNS on UDP/53 to a public resolver | DNS leak |
| TCP SYN to a public IP, real source | Connection leak |
| IPv6 packets to public destinations | IPv6 leak |
| STUN on UDP/3478 | Possible WebRTC exposure |

This table is the practical core of leak detection, and it's exactly what
[Lab 06](../07-practical-labs/lab-06-traffic-analysis.md) has you build.

## References

- [RFC 1035 — DNS](https://www.rfc-editor.org/rfc/rfc1035)
- [RFC 793 — TCP](https://www.rfc-editor.org/rfc/rfc793)
- [RFC 768 — UDP](https://www.rfc-editor.org/rfc/rfc768)
- [`tcpdump(1)`](https://man7.org/linux/man-pages/man1/tcpdump.1.html)
- [Wireshark User's Guide](https://www.wireshark.org/docs/wsug_html/)

---

Next: [03 · Observing VPN Traffic](03-observing-vpn-traffic.md) ·
Back: [Module index](README.md)