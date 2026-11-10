# 01 · Capture Fundamentals

## Overview

A packet capture is a copy of the frames crossing an interface. This chapter
gets you capturing confidently with `tcpdump`, saving captures for Wireshark,
and — most importantly for this project — capturing on the *right* interface.

## Your first capture

```bash
sudo tcpdump -ni eth0
```

Flags:

- `-n` — don't resolve addresses/ports to names (faster, less noise, and avoids
  generating extra DNS traffic that would pollute your capture).
- `-i eth0` — listen on this interface. Use `ip -brief link` to list names.
- Running with no filter shows everything; add a filter to focus.

Illustrative output (documentation addresses):

```text
12:01:02.123456 IP 192.0.2.10.52314 > 192.0.2.53.53: 4242+ A? example.com. (29)
12:01:02.135678 IP 192.0.2.53.53 > 192.0.2.10.52314: 4242 1/0/0 A 203.0.113.80 (45)
```

Each line is one packet: timestamp, protocol, `source.port > destination.port`,
then a protocol-specific summary. The two lines above are a DNS query and its
answer.

## Capture filters (BPF)

`tcpdump` filters use Berkeley Packet Filter syntax, applied *at capture time*
so you only record what matters:

```bash
sudo tcpdump -ni eth0 'udp port 53'              # DNS over UDP
sudo tcpdump -ni eth0 'tcp port 443'             # HTTPS
sudo tcpdump -ni eth0 'host 198.51.100.5'        # to/from one host
sudo tcpdump -ni eth0 'ip6'                      # all IPv6
sudo tcpdump -ni eth0 'udp port 51820'           # WireGuard outer traffic
sudo tcpdump -ni eth0 'not udp port 51820'       # everything EXCEPT the tunnel
```

That last one is the leak-hunting filter: on the physical interface, anything
that isn't the tunnel's encapsulated stream is a candidate leak.

> **TECHNICAL NOTE**
> Capture filters (BPF, set before capture) differ from Wireshark *display*
> filters (applied after capture, e.g. `dns` or `tcp.port == 443`). Capture
> filters decide what's recorded; display filters decide what's shown. Use
> capture filters to keep files small, display filters to explore.

## Saving and reading captures

```bash
sudo tcpdump -ni eth0 -c 200 -w capture.pcap     # record 200 packets to a file
tcpdump -nr capture.pcap                          # read it back (-r)
```

The `.pcap` file opens directly in Wireshark. Keep captures small and targeted
(`-c` limits packet count); don't record indefinitely.

> **WARNING**
> A capture can contain sensitive data. Store it locally, don't commit real
> captures, and delete it when you're done. The repo's
> [`.gitignore`](../../.gitignore) blocks real `.pcap` files on purpose.

## Reading with more detail

```bash
sudo tcpdump -ni eth0 -vv 'udp port 53'          # verbose protocol decode
sudo tcpdump -ni eth0 -X 'udp port 53'           # hex + ASCII payload
```

`-vv` expands DNS records, TTLs, and flags; `-X` shows raw bytes, useful to see
that an "encrypted" payload really is opaque.

## Wireshark in one paragraph

Open a `.pcap` in Wireshark (or run `wireshark` and capture live). You get a
packet list, a protocol tree, and a bytes pane. Type a display filter like `dns`
or `tcp.flags.syn == 1` in the bar. Right-click a packet → *Follow → TCP/UDP
Stream* to reassemble a conversation. For leak hunting, the *Conversations* and
*Endpoints* statistics windows quickly show which addresses are talking.

## Interface-specific monitoring

The single most important habit: choose the interface deliberately.

- `eth0` (physical) — see what actually leaves the machine, including leaks and
  the tunnel's outer packets.
- `wg0`/`tun0` (tunnel) — see the inner, pre-encapsulation traffic.
- `lo` — local-only traffic (e.g. the stub resolver on `127.0.0.53`).

Comparing `eth0` and `wg0` captures of the same activity is how you prove whether
something stayed inside the tunnel.

## References

- [`tcpdump(1)` man page](https://man7.org/linux/man-pages/man1/tcpdump.1.html)
- [tcpdump official manual](https://www.tcpdump.org/manpages/tcpdump.1.html)
- [Wireshark User's Guide](https://www.wireshark.org/docs/wsug_html/)
- [BPF / pcap-filter syntax](https://www.tcpdump.org/manpages/pcap-filter.7.html)

---

Next: [02 · Inspecting DNS & TCP](02-inspecting-dns-and-tcp.md) ·
Back: [Module index](README.md)