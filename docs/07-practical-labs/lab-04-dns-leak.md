# Lab 04 · DNS Leak Investigation

## 1. Objective

Prove where DNS queries actually travel: first reproduce a leak (queries leaving
the physical interface while the VPN is up), then fix it and prove the queries
stay inside the tunnel.

## 2. Required knowledge

- [Module 01, DNS](../01-network-fundamentals/05-dns.md).
- [Module 03, DNS leaks](../03-vpn-leaks/02-dns-leaks.md).
- [Lab 02](lab-02-vpn-interface-analysis.md) (working tunnel).

## 3. Required tools

`dig`, `tcpdump`, `resolvectl`/`resolv.conf`, the helper
[`dns-leak-check.sh`](../../labs/scripts/dns-leak-check.sh), and a resolver on the
server (dnsmasq).

## 4. Lab topology

```text
client eth0 192.0.2.10  -- lab net --  server eth0 192.0.2.20 (runs dnsmasq)
client wg0  10.8.0.2    == tunnel ==   server wg0  10.8.0.1   (same resolver)
```

The server's resolver is reachable two ways: at `192.0.2.20` (on-link, via
`eth0`) and at `10.8.0.1` (via the tunnel). The *path* is what differs.

## 5. Environment setup

**Server — run a lab resolver:**

```bash
sudo apt install -y dnsmasq
```

Make dnsmasq listen on the lab addresses. Add to `/etc/dnsmasq.conf`:

```ini
listen-address=192.0.2.20,10.8.0.1,127.0.0.1
bind-interfaces
```

Then `sudo systemctl restart dnsmasq`. (If port 53 is taken by `systemd-resolved`,
see Troubleshooting.)

**Client:** complete Lab 02. Keep the tunnel down for now.

## 6–7. Steps and commands

**Scenario A — reproduce the leak.** Point the client's DNS at the on-link
resolver (`192.0.2.20`). Because `192.0.2.0/24` is a directly-connected route, it
is *more specific* than the tunnel default, so queries go out `eth0`.

```bash
# Temporarily set the client resolver (note the original to restore later):
cat /etc/resolv.conf
echo "nameserver 192.0.2.20" | sudo tee /etc/resolv.conf

sudo wg-quick up ./wg-client.conf          # full tunnel is up
sudo ../../labs/scripts/dns-leak-check.sh eth0 example.com
```

**Scenario B — fix it.** Use the tunnel's resolver. The `DNS = 10.8.0.1` line in
`wg-client.conf` makes `wg-quick` set this automatically; confirm:

```bash
sudo wg-quick down ./wg-client.conf
sudo wg-quick up ./wg-client.conf          # re-applies DNS = 10.8.0.1
resolvectl status                          # resolver should be 10.8.0.1 on wg0
sudo ../../labs/scripts/dns-leak-check.sh eth0 example.com   # expect: none
sudo tcpdump -ni wg0 'udp port 53'         # in another terminal, then dig:
dig example.com                            # query should appear on wg0
```

## 8. Expected observations

- **Scenario A:** `dns-leak-check.sh` reports DNS packets on `eth0` — readable
  `A? example.com` queries to `192.0.2.20`. That's a leak.
- **Scenario B:** no port-53 traffic on `eth0`; the query appears on `wg0`
  instead, addressed to `10.8.0.1`. DNS stayed inside the tunnel.

## 9. Illustrative output

> **ILLUSTRATIVE** — see also
> [`dns-leak-eth0.txt`](../../labs/sample-captures/dns-leak-eth0.txt).

```text
# Scenario A (leak), on eth0:
IP 192.0.2.10.52314 > 192.0.2.20.53: 4242+ A? example.com. (29)
RESULT: DNS traffic appeared on eth0.

# Scenario B (fixed), on eth0:
(none)
RESULT: no port-53 traffic on eth0 during the probe.
```

## 10. Technical explanation

The leak in Scenario A is a *routing* fact, not a DNS fact: the on-link
`192.0.2.0/24` route is more specific than the tunnel's default, so packets to
`192.0.2.20` bypass the tunnel. Scenario B uses a resolver whose address
(`10.8.0.1`) is only reachable through `wg0`, forcing queries inside. This is why
"which resolver" and "which path" are separate questions — and why you must check
the path, not just the resolver address.

## 11. Troubleshooting

- **Port 53 already in use** — `systemd-resolved`'s stub may hold it. Either
  disable its DNS stub (`DNSStubListener=no` in
  `/etc/systemd/resolved.conf`, then restart it) or run dnsmasq on a different
  port and query it with `dig -p`.
- **dnsmasq won't start with `wg0`** — it may start before the tunnel exists;
  `bind-interfaces` can fail on a missing interface. Restart dnsmasq after the
  tunnel is up, or list only `eth0` + `127.0.0.1` and rely on `10.8.0.1` being the
  same host.
- **Scenario B still shows eth0 DNS** — confirm `resolvectl status` actually
  lists `10.8.0.1` and that `ip route get 10.8.0.1` resolves to `wg0`.

## 12. Cleanup

```bash
sudo wg-quick down ./wg-client.conf
# Restore the client's original /etc/resolv.conf (or let DHCP/NetworkManager
# regenerate it). Remove the dnsmasq listen-address lines if you added them.
sudo systemctl restart dnsmasq     # on the server, if you changed its config
```

## 13. Learning outcomes

You can reproduce a DNS leak, explain it as a routing/specificity problem, fix it
by moving DNS into the tunnel, and prove the fix with a physical-interface
capture.

---

Next: [Lab 05 · IPv6 Leak Investigation](lab-05-ipv6-leak.md) ·
Back: [Lab index](README.md)