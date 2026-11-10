# 03 · Clients & Supply Chain

## Overview

The VPN *client* runs on your device with elevated networking privileges. That
makes it a high-value target: a malicious or compromised client can do damage
that has nothing to do with the tunnel itself. This chapter covers fake apps,
permission abuse, data exfiltration, and supply-chain risk.

## Malicious clients and fake apps

A VPN client typically needs permission to create interfaces, change routes, and
modify DNS — powerful capabilities. A malicious client can abuse them or go
further:

- **Fake VPN apps** that don't actually tunnel traffic but harvest data, show
  ads, or sell "premium" upgrades. Some route nothing at all while claiming
  protection.
- **Trojanized clients** — a legitimate-looking app bundled with malware,
  often distributed outside official stores or via cracked/"modded" installers.
- **Over-privileged apps** that request access far beyond networking (contacts,
  files, location, accessibility services) and use it to collect data.

> **WARNING**
> A VPN app asking for broad device permissions is a red flag. Creating a tunnel
> needs network configuration rights — not your contacts, SMS, or files. Treat
> excessive permission requests as a reason to walk away.

## Data exfiltration

A malicious client can send collected data to a third party. Because it already
has network access, exfiltration blends into normal traffic. On Linux you can
look for unexpected connections from the client process:

```bash
ss -tnp                       # established connections + owning process
sudo tcpdump -ni eth0 host <suspicious-endpoint>
```

The defensive lesson: know what destinations your VPN client *should* talk to
(its servers and update endpoints), and investigate anything else.

## Application permissions

On desktop Linux, VPN configuration usually requires root or a privileged
helper. On mobile OSes, a VPN profile grants the app broad traffic access. In
both cases:

- Grant the minimum privilege needed.
- Prefer clients that use a small, auditable privileged helper rather than
  running everything as root.
- Review what the app can access beyond the network.

## Supply-chain risk

Even an honest provider can ship a compromised client if its build or
distribution is attacked:

- Compromised update servers pushing a malicious version.
- Tampered installers on mirror sites.
- A dependency or build pipeline injected with code.

Mitigations are the standard software-authenticity ones:

- Download only from the official source or your distribution's repository.
- Verify signatures / checksums where provided.
- Prefer reproducible builds and open-source clients.
- Keep the client updated through a trusted channel.

These practices are expanded in
[Module 08, trust & verification](../08-prevention/02-trust-and-verification.md).

## Telling the categories apart

Recall the module's four categories. A fake app that harvests data is
**malicious software**; a client with a leak bug is **misconfiguration**; a
provider that sells metadata is a **privacy-invasive business practice**. The
symptoms can look similar (your data ends up somewhere it shouldn't), but the
fixes differ: don't install malware, fix configuration, or choose a better
provider, respectively.

## References

- [RFC 7359 — VPN Traffic Leakage](https://www.rfc-editor.org/rfc/rfc7359)
- Linux man pages: [`ss(8)`](https://man7.org/linux/man-pages/man8/ss.8.html)
- Debian: [SecureApt / repository signing](https://wiki.debian.org/SecureApt)

---

Next: [Module 05 · VPN Detection](../05-vpn-detection/README.md) ·
Back: [Module index](README.md)