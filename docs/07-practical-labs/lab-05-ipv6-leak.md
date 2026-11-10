# Lab 05 · IPv6 Leak Investigation

## 1. Objective

Show that an IPv4-only VPN leaves IPv6 exposed on a dual-stack host, then close
the gap. You'll observe a real IPv6 connection bypassing the tunnel and verify a
fix.

## 2. Required knowledge

- [Module 01, addressing](../01-network-fundamentals/01-ip-addressing.md) and
  [routing](../01-network-fundamentals/04-routing.md).
- [Module 03, IPv6 leaks](../03-vpn-leaks/03-ipv6-leaks.md).
- [Lab 02](lab-02-vpn-interface-analysis.md).

## 3. Required tools

`ip`, `curl`, `tcpdump`, `nft`, WireGuard, and
[`ip-echo.py`](../../labs/scripts/ip-echo.py) on the server.

## 4. Lab topology

Same two VMs as Lab 02, made **dual-stack** with static documentation IPv6 so the
lab is self-contained (no hypervisor IPv6 needed):

```text
client eth0: 192.0.2.10/24 + 2001:db8:1::10/64
server eth0: 192.0.2.20/24 + 2001:db8:1::20/64   (runs ip-echo.py on [::]:8080)
```

The two IPv6 addresses are in the same `/64`, so they're on-link over `eth0`.

## 5. Environment setup

Add the static IPv6 addresses (documentation range, isolated lab L2):

```bash
# client
sudo ip -6 addr add 2001:db8:1::10/64 dev eth0
# server
sudo ip -6 addr add 2001:db8:1::20/64 dev eth0
```

On the server, start the echo service dual-stack:

```bash
python3 labs/scripts/ip-echo.py --bind :: --port 8080
```

Confirm IPv6 works on the lab link (VPN down):

```bash
ping -6 -c 2 2001:db8:1::20        # from the client
```

## 6–7. Steps and commands

**Scenario A — reproduce the leak with an IPv4-only tunnel.** Temporarily use a
client config whose `AllowedIPs` is IPv4-only (`0.0.0.0/0`, no `::/0`), then:

```bash
sudo wg-quick up ./wg-client-v4only.conf
ip -6 route                              # no IPv6 route via wg0
ip -6 route get 2001:db8:1::20           # resolves via eth0 (on-link)
curl -6 http://[2001:db8:1::20]:8080/    # what source does the server see?
sudo tcpdump -ni eth0 'ip6 and tcp port 8080'   # watch it leave eth0
```

The echo service reports `2001:db8:1::10` — your **real** IPv6 — even though the
IPv4 VPN is up.

**Scenario B — close the gap.** Two options:

```bash
# Option 1 (preferred if the VPN supports IPv6): tunnel it.
#   Add an IPv6 tunnel address and AllowedIPs = 0.0.0.0/0, ::/0, with the
#   server routing the IPv6 tunnel subnet. Then:
ip -6 route get 2001:db8:99::1           # should now resolve via wg0

# Option 2 (fallback when the VPN has no IPv6): block IPv6 outside the tunnel.
sudo nft add table inet v6block
sudo nft add chain inet v6block out '{ type filter hook output priority 0; }'
sudo nft add rule inet v6block out oifname "eth0" meta nfproto ipv6 drop
curl -6 http://[2001:db8:1::20]:8080/    # now fails; traffic can't leak via IPv6
```

## 8. Expected observations

- **Scenario A:** `ip -6 route get` shows `eth0`; the echo service sees your real
  IPv6; `tcpdump` shows IPv6 TCP on `eth0`.
- **Scenario B, Option 1:** IPv6 destinations resolve via `wg0`.
- **Scenario B, Option 2:** the IPv6 `curl` fails (blocked), so nothing leaks;
  IPv4 still works through the tunnel.

## 9. Illustrative output

> **ILLUSTRATIVE** — see also
> [`ipv6-leak-eth0.txt`](../../labs/sample-captures/ipv6-leak-eth0.txt).

```text
$ curl -6 http://[2001:db8:1::20]:8080/      # Scenario A
2001:db8:1::10
family=IPv6

$ ip -6 route get 2001:db8:1::20
2001:db8:1::20 dev eth0 src 2001:db8:1::10
```

## 10. Technical explanation

IPv4 and IPv6 use separate routing tables. An IPv4-only tunnel installs no IPv6
routes, so the IPv6 on-link/default route via `eth0` remains, and address
selection may prefer it. The destination therefore sees the host's real global
IPv6. The fix either extends the tunnel to IPv6 or removes the unprotected IPv6
path.

## 11. Troubleshooting

- **`ping -6` fails at setup** — the static addresses must be in the same `/64`
  and on the same L2 segment; check `ip -6 addr` on both VMs.
- **`curl -6` says "Couldn't connect"** in Scenario A — the echo service must be
  bound to `::` (IPv6), not just `0.0.0.0`.
- **Option 2 blocks too much** — the rule drops *all* IPv6 on `eth0`, including
  lab IPv6. That's intended for the demo; remove it in cleanup.

## 12. Cleanup

```bash
sudo wg-quick down ./wg-client-v4only.conf
sudo nft delete table inet v6block                 # if you added Option 2
sudo ip -6 addr del 2001:db8:1::10/64 dev eth0     # client
sudo ip -6 addr del 2001:db8:1::20/64 dev eth0     # server
# Stop ip-echo.py (Ctrl-C in its terminal).
```

## 13. Learning outcomes

You can demonstrate an IPv6 leak on a dual-stack host, explain it via the
separate IPv6 routing table, and apply either of the two sound fixes (tunnel
IPv6, or block it outside the tunnel).

---

Next: [Lab 06 · Wireshark & tcpdump Analysis](lab-06-traffic-analysis.md) ·
Back: [Lab index](README.md)