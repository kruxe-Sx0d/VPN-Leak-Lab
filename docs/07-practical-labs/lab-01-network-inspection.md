# Lab 01 · Basic Network Inspection

## 1. Objective

Build a baseline picture of a Linux host's network state — interfaces,
addresses, routes, neighbors, sockets, and DNS — so you can recognize what
"normal" looks like before adding a VPN.

## 2. Required knowledge

- [Module 01](../01-network-fundamentals/README.md): addressing, interfaces,
  routing, DNS. You don't need to be fast yet, just familiar with the terms.

## 3. Required tools

`ip` (iproute2), `ss`, `dig`, and either `resolvectl` or `/etc/resolv.conf`.
The helper [`net-inspect.sh`](../../labs/scripts/net-inspect.sh) runs them all.

## 4. Lab topology

Just the **client** VM for this lab. No VPN, no server needed.

```text
[ client VM ]  eth0: 192.0.2.10/24  ->  gateway 192.0.2.1
```

## 5. Environment setup

```bash
sudo apt update && sudo apt install -y iproute2 dnsutils
```

No root is needed for the inspection itself.

## 6–7. Steps and commands

Run each command, read its output, and note what it tells you. Or run the helper
to get them all at once:

```bash
../../labs/scripts/net-inspect.sh          # from the repo root
# or, if you copied the script locally:
./net-inspect.sh eth0
```

Individually:

```bash
ip -brief link            # interfaces + state + MAC
ip -brief addr            # addresses per interface (v4 + v6)
ip route                  # IPv4 routing table
ip -6 route               # IPv6 routing table (may be empty)
ip neigh                  # ARP / neighbor cache
ss -tulpn                 # listening TCP/UDP sockets
resolvectl status         # DNS config (or: cat /etc/resolv.conf)
dig example.com           # a live lookup; read the SERVER: line
```

## 8. Expected observations

- At least `lo` and one physical interface (`eth0`/`enp0s3`/…).
- The physical interface has an IPv4 address; possibly a global IPv6 too.
- A `default via <gateway>` route on the physical interface.
- A neighbor entry for the gateway.
- A DNS resolver listed, and `dig` reports which `SERVER:` answered.

## 9. Illustrative output

> **ILLUSTRATIVE** — not captured from your machine. Documentation addresses.

```text
$ ip -brief addr
lo               UNKNOWN        127.0.0.1/8 ::1/128
eth0             UP             192.0.2.10/24 2001:db8:1::10/64 fe80::a00:27ff:fe4e:66a1/64

$ ip route
default via 192.0.2.1 dev eth0 proto dhcp src 192.0.2.10 metric 100
192.0.2.0/24 dev eth0 proto kernel scope link src 192.0.2.10

$ dig example.com +short
203.0.113.80
```

Record **your** actual values in a notebook — you'll compare against them in
later labs.

## 10. Technical explanation

Each command exposes one layer of the model from Module 01: `ip link` is layer
2, `ip addr` adds layer 3, `ip route` is the forwarding decision, `ip neigh` is
the IP→MAC mapping, `ss` shows transport endpoints, and `resolvectl`/`dig` show
name resolution. Together they're the complete "before" snapshot.

## 11. Troubleshooting

- **`resolvectl: command not found`** — use `cat /etc/resolv.conf` instead.
- **No IPv6 routes** — the network may be IPv4-only; that's fine, note it.
- **`ss -p` shows no process names** — run with `sudo` to see owners.
- **Interface isn't `eth0`** — substitute the name from `ip -brief link`.

## 12. Cleanup

Nothing to clean up — this lab only reads state.

## 13. Learning outcomes

You can list interfaces and addresses, read a routing table and the default
route, find the configured DNS resolver, and capture a baseline to compare
against after a VPN connects.

---

Next: [Lab 02 · VPN Interface Analysis](lab-02-vpn-interface-analysis.md) ·
Back: [Lab index](README.md)