# 02 · Trust & Verification

## Overview

Configuration protects the path; trust protects you from the endpoint. This
chapter covers choosing and installing a client safely, evaluating a provider,
and a single checklist you can run to verify a setup end to end.

## VPN client trust

The client runs with networking privileges, so treat it as high-trust software:

- Prefer **open-source** clients you (or the community) can inspect.
- Prefer a small privileged helper over an everything-as-root design.
- Be wary of clients requesting permissions unrelated to networking.
- Recall [Module 04](../04-malicious-vpns/03-clients-and-supply-chain.md): a
  malicious client can exfiltrate data regardless of how good the tunnel is.

## Software authenticity

- Download only from the **official source** or your distribution's repository.
- Verify **signatures/checksums** when provided (e.g. Debian's signed packages
  via SecureApt).
- Avoid cracked/"modded" installers and unofficial mirrors.
- Keep the client updated through a trusted channel; updates are also a
  supply-chain attack vector, so authenticity matters most there.

## Secure installation practices

- Install the minimal package set; don't bundle unrelated "optimizer" tools.
- Never install a root certificate a VPN app asks for without understanding why
  (see [TLS interception](../04-malicious-vpns/02-traffic-manipulation.md)).
- Review what services/helpers the installer adds and what they can access.

## Privacy policy evaluation

From [Module 01 of Module 04](../04-malicious-vpns/01-trust-model.md), weigh:

- Specific, bounded statements about what is logged and for how long.
- Independent audits with published results.
- A business model that doesn't depend on selling user data.
- Jurisdiction and data-request exposure.

A policy is a promise; audits and technical design are evidence. Prefer the
latter.

## Practical verification checklist

Run this against a setup to confirm it does what it claims. Each item links to
the lab or command that proves it.

- [ ] **Tunnel is up:** `sudo wg show` shows a recent handshake and transfer.
      ([Lab 02](../07-practical-labs/lab-02-vpn-interface-analysis.md))
- [ ] **IPv4 full tunnel:** `ip route get <public-v4>` resolves to the tunnel.
      ([Lab 03](../07-practical-labs/lab-03-routing-investigation.md))
- [ ] **IPv6 handled:** `ip -6 route get <public-v6>` is tunneled or blocked.
      ([Lab 05](../07-practical-labs/lab-05-ipv6-leak.md))
- [ ] **No more-specific bypass:** `ip route show table all` has no unexpected
      physical route overriding the tunnel.
- [ ] **DNS in tunnel:** resolver is the VPN's and routes through it; no port-53
      on the physical interface. ([Lab 04](../07-practical-labs/lab-04-dns-leak.md))
- [ ] **Physical capture clean:** before/after capture shows only the tunnel
      stream after connect. ([Lab 06](../07-practical-labs/lab-06-traffic-analysis.md))
- [ ] **Kill switch works:** dropping the tunnel blocks egress; reconnect still
      works. ([Lab 07](../07-practical-labs/lab-07-kill-switch.md))
- [ ] **Client is authentic:** official source, signature verified, minimal
      permissions, no rogue root certificates.
- [ ] **Provider is acceptable:** policy + audits match your privacy needs.

> **IMPORTANT**
> A checklist proves the state *at the time you run it*. Re-verify after client
> updates, network changes, and reconnects — the moments when configuration
> drifts.

## References

- Debian [SecureApt](https://wiki.debian.org/SecureApt)
- [RFC 8446 — TLS 1.3](https://www.rfc-editor.org/rfc/rfc8446)
- [RFC 7359 — VPN Traffic Leakage](https://www.rfc-editor.org/rfc/rfc7359)

---

Back: [Module index](README.md) · [Project README](../../README.md)