# Lab Configurations

Placeholder templates for the labs. **None of these contain real keys or
credentials.** Generate your own keys and fill in the placeholders before use.

| File | Purpose | Used by |
|------|---------|---------|
| [`wg-client.conf`](wg-client.conf) | WireGuard client (full tunnel) | Lab 02, 04, 05, 07 |
| [`wg-server.conf`](wg-server.conf) | WireGuard server | Lab 02 |
| [`kill-switch.nft`](kill-switch.nft) | nftables kill-switch ruleset | Lab 07 |

## Generating WireGuard keys

On each VM, generate a key pair (private key stays on that machine):

```bash
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
```

- Put the **private** key in that machine's `[Interface] PrivateKey`.
- Put the **peer's public** key in the corresponding `[Peer] PublicKey`.
- Never commit `privatekey` files — the repo [`.gitignore`](../../.gitignore)
  blocks `*.key` and `privatekey*` for this reason.

## Address plan

These templates use the documentation ranges from the
[lab index](../../docs/07-practical-labs/README.md):

- client `eth0`: `192.0.2.10/24`, tunnel `10.8.0.2/32`
- server `eth0`: `192.0.2.20/24`, tunnel `10.8.0.1/24`
- WireGuard port: `51820`

Substitute your hypervisor's actual addresses consistently.

## A note on the kill switch

[`kill-switch.nft`](kill-switch.nft) is a **template**, not something to apply
blindly. Read [Lab 07](../../docs/07-practical-labs/lab-07-kill-switch.md) first:
it explains each rule, how to adapt the interface names and server endpoint, and
how to test and remove the ruleset safely. Applying firewall rules can cut your
network access if done wrong, so the lab walks through it deliberately.