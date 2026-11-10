# Lab 06 · Wireshark & tcpdump Traffic Analysis

## 1. Objective

Capture the same activity before and after the VPN comes up, then compare the
two captures to see exactly what the tunnel hides — and practice reading the
results in both `tcpdump` and Wireshark.

## 2. Required knowledge

- [Module 06](../06-traffic-analysis/README.md) (all three chapters).
- [Lab 02](lab-02-vpn-interface-analysis.md) (a working tunnel).

## 3. Required tools

`tcpdump`, Wireshark (or `tshark`), `dig`, `curl`, and the helper
[`capture-summary.sh`](../../labs/scripts/capture-summary.sh).

## 4. Lab topology

The client VM, capturing on its **physical** interface `eth0`, with the tunnel
available to toggle.

## 5. Environment setup

```bash
sudo apt install -y tcpdump wireshark tshark dnsutils curl
```

Complete Lab 02. Work in a directory where you can save two small `.pcap` files
(remember: real captures stay local, never committed).

## 6–7. Steps and commands

**Before (VPN down):**

```bash
sudo wg-quick down ./wg-client.conf 2>/dev/null || true
sudo tcpdump -ni eth0 -c 100 -w before.pcap &
sleep 1
dig example.com >/dev/null
curl -4 http://192.0.2.20:8080/ >/dev/null      # ip-echo on the server
wait
```

**After (VPN up):**

```bash
sudo wg-quick up ./wg-client.conf
sudo tcpdump -ni eth0 -c 100 -w after.pcap &
sleep 1
dig example.com >/dev/null
curl -4 http://192.0.2.20:8080/ >/dev/null
wait
```

**Compare:**

```bash
../../labs/scripts/capture-summary.sh before.pcap after.pcap
wireshark before.pcap after.pcap     # or open each in the GUI
```

In Wireshark, try display filters `dns`, `tcp.flags.syn == 1`, and
`udp.port == 51820`; use *Statistics → Conversations* to see who talks to whom.

## 8. Expected observations

- **before.pcap:** readable DNS on port 53 and a direct TCP connection with your
  real source (`192.0.2.10`).
- **after.pcap:** mostly/only the WireGuard UDP stream to the server; no
  plaintext DNS or direct TCP to the destination.
- `capture-summary.sh` shows DNS / TCP-SYN counts drop to ~0 after, while the
  WireGuard count rises.

## 9. Illustrative output

> **ILLUSTRATIVE** — see
> [`tunneled-eth0.txt`](../../labs/sample-captures/tunneled-eth0.txt) and
> [`dns-leak-eth0.txt`](../../labs/sample-captures/dns-leak-eth0.txt).

```text
$ ./capture-summary.sh before.pcap after.pcap
=== before.pcap ===
  total packets:              42
  DNS (port 53):              4
  WireGuard (udp 51820):      0
  TCP SYN (conn starts):      2
=== after.pcap ===
  total packets:              38
  DNS (port 53):              0
  WireGuard (udp 51820):      36
  TCP SYN (conn starts):      0
```

## 10. Technical explanation

The physical interface is the leak boundary. Before the VPN, queries and
connections cross it in the clear. After a full tunnel, they're encapsulated
into the opaque UDP stream, so the same interface shows only ciphertext between
you and the server. The before/after diff is direct evidence of what the tunnel
protects — and anything still visible after is a leak.

## 11. Troubleshooting

- **`tcpdump: permission denied`** — run with `sudo`.
- **after.pcap still shows DNS** — you've found a real leak; confirm with Lab 04.
- **Capture too big / never stops** — `-c 100` caps it; make sure the background
  job finishes (`wait`) before reading.
- **Wireshark won't open as root** — capture with `tcpdump -w`, then open the
  file as your normal user.

## 12. Cleanup

```bash
sudo wg-quick down ./wg-client.conf
rm -f before.pcap after.pcap        # delete real captures when done
```

## 13. Learning outcomes

You can capture on the correct interface, produce a before/after pair, summarize
it, and interpret the difference in Wireshark — the core skill for verifying any
VPN claim yourself.

---

Next: [Lab 07 · Kill Switch Testing](lab-07-kill-switch.md) ·
Back: [Lab index](README.md)