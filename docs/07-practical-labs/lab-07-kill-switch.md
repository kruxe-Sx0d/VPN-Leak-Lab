# Lab 07 · Kill Switch Testing

## 1. Objective

Test the case most people forget: what happens when the tunnel **drops**. First
observe traffic leak without a kill switch, then apply an nftables kill switch
and prove the leak is blocked — while the tunnel can still reconnect.

## 2. Required knowledge

- [Module 03, kill switch failures](../03-vpn-leaks/07-kill-switch-failures.md).
- [Module 02, lifecycle](../02-vpn-fundamentals/05-connection-lifecycle.md).
- [Lab 02](lab-02-vpn-interface-analysis.md).

## 3. Required tools

`nft`, `ip`, `ping`, `curl`, `tcpdump`, WireGuard, and the template
[`kill-switch.nft`](../../labs/configs/kill-switch.nft).

## 4. Lab topology

The client VM with the tunnel from Lab 02. The server (`192.0.2.20`) is both the
WireGuard endpoint and a reachable "destination" (run `ip-echo.py` on it).

## 5. Environment setup

```bash
sudo apt install -y nftables wireguard iproute2 curl
```

> **WARNING**
> Firewall rules can cut network access. Do this on a **VM with console access**,
> not over a connection that depends on the interface you're filtering. Know the
> removal command before you start: `sudo nft delete table inet killswitch`.

The template's defaults (`eth0`, `wg0`, server `192.0.2.20`, port `51820`) match
this lab, so it can be applied as-is. If your names differ, edit the `define`
lines first.

## 6–7. Steps and commands

**Scenario A — no kill switch, watch it leak.**

```bash
sudo wg-quick up ./wg-client.conf
# In another terminal, watch the physical interface:
sudo tcpdump -ni eth0 'icmp or tcp port 8080'
# Now drop the tunnel and immediately send traffic:
sudo wg-quick down ./wg-client.conf
ping -c 3 192.0.2.20                       # goes out eth0 with your real IP
curl -4 http://192.0.2.20:8080/            # echo sees 192.0.2.10 (leak)
```

**Scenario B — apply the kill switch, watch it block.**

```bash
sudo wg-quick up ./wg-client.conf
sudo nft -f ../../labs/configs/kill-switch.nft
sudo nft list table inet killswitch       # confirm rules + policy drop

# Drop the tunnel again and try to leak:
sudo wg-quick down ./wg-client.conf
ping -c 3 192.0.2.20                       # now fails (blocked)
curl -4 --max-time 5 http://192.0.2.20:8080/   # times out (blocked)
sudo nft list table inet killswitch       # the drop counter has increased
```

**Confirm reconnect still works** (the narrow allow rule permits the tunnel's
own traffic):

```bash
sudo wg-quick up ./wg-client.conf          # handshake succeeds through the rules
sudo wg show                               # latest handshake is recent
```

## 8. Expected observations

- **Scenario A:** after the tunnel drops, `ping`/`curl` succeed out `eth0` and the
  echo service sees your real IP — a leak.
- **Scenario B:** after the tunnel drops, `ping`/`curl` fail; the nftables drop
  counter rises; nothing leaks. Bringing the tunnel back up still handshakes.

## 9. Illustrative output

> **ILLUSTRATIVE** — not a real capture.

```text
# Scenario A (no kill switch), echo response after tunnel drop:
192.0.2.10
family=IPv4

# Scenario B (kill switch), after tunnel drop:
$ ping -c 3 192.0.2.20
3 packets transmitted, 0 received, 100% packet loss
$ sudo nft list table inet killswitch
... counter packets 6 bytes 504 comment "dropped non-tunnel egress"
```

## 10. Technical explanation

The kill switch is a default-deny `output` chain: it allows loopback, anything
leaving via `wg0`, and the narrow encapsulated flow to the VPN server, then drops
the rest. When the tunnel drops and routing reverts to `eth0`, the packets hit
the drop policy instead of leaking. The narrow allow rule is what lets the
tunnel re-establish. This is the firewall backstop that routing alone can't
provide.

## 11. Troubleshooting

- **Lost access after applying** — use the VM console and run
  `sudo nft delete table inet killswitch`.
- **Tunnel won't reconnect in Scenario B** — check the allow rule's server IP and
  port match your endpoint; if the endpoint is a hostname, you must allow
  bootstrap DNS (see the template notes).
- **`ping` still works in Scenario B** — ICMP to the *tunnel* address is allowed;
  make sure you're pinging the server's physical address (`192.0.2.20`), and that
  the rule's `oifname` matches your physical interface.

## 12. Cleanup

```bash
sudo nft delete table inet killswitch      # remove the kill switch
sudo wg-quick down ./wg-client.conf        # if up
sudo nft list ruleset                      # confirm the table is gone
```

## 13. Learning outcomes

You can reproduce a tunnel-drop leak, apply a default-deny kill switch that
covers the gap, verify it blocks non-tunnel egress while allowing reconnect, and
remove it safely.

---

Next: [Module 08 · Prevention & Best Practices](../08-prevention/README.md) ·
Back: [Lab index](README.md)