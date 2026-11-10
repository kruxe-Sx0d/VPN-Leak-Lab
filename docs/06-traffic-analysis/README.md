# Module 06 · Network Traffic Analysis

Theory tells you what *should* happen; a packet capture tells you what *actually*
happens. This module teaches you to capture and read traffic with `tcpdump` and
Wireshark, so you can verify every claim from the earlier modules yourself.

| Chapter | Topic |
|---------|-------|
| [01 · Capture Fundamentals](01-capture-fundamentals.md) | tcpdump, Wireshark, interface-specific capture |
| [02 · Inspecting DNS & TCP](02-inspecting-dns-and-tcp.md) | DNS queries, the TCP handshake, UDP |
| [03 · Observing VPN Traffic](03-observing-vpn-traffic.md) | Encapsulation on the wire, before/after comparison |

## The golden rule of leak hunting

> **CONCEPT**
> Capture on the **physical interface** (`eth0`), not the tunnel. The physical
> interface is where a leak becomes visible: if a query or connection appears
> there in the clear while the VPN is up, it escaped the tunnel. Capturing on
> `wg0` only shows what's *already inside* — it can't reveal what got out.

## Tools

- **`tcpdump`** — command-line capture, great for quick, filtered looks and for
  scripting. Part of the `tcpdump` package.
- **Wireshark / `tshark`** — GUI (and CLI) protocol analyzer with deep decoders,
  follow-stream, and coloring rules. Best for exploring an unfamiliar capture.
- **`iproute2`, `dig`, `ss`, `curl`** — the stimulus and inspection tools you
  already know; you'll generate traffic with them and capture the result.
- **`nftables`** — for the kill-switch lab.

Install on Debian:

```bash
sudo apt install tcpdump wireshark tshark dnsutils iproute2 nftables curl
```

> **WARNING**
> Capturing requires elevated privileges and may expose sensitive data. Only
> capture on networks and machines you control, and don't commit real captures
> to this repository. The samples in [`labs/sample-captures/`](../../labs/sample-captures/)
> are synthetic and clearly labeled.

The hands-on application of this module is
[Lab 06](../07-practical-labs/lab-06-traffic-analysis.md). Prerequisites:
[Module 01](../01-network-fundamentals/README.md) and
[Module 02](../02-vpn-fundamentals/README.md).