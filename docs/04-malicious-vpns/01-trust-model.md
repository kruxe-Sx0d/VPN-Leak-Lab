# 01 · The Trust Model

## Overview

When you use a VPN, the provider's server sits between you and the Internet and
decrypts your tunnel. That position grants real visibility. This chapter maps
what a provider can observe, what "no logs" can and cannot mean, and how to tell
an unreliable provider from a deliberately malicious one.

## What the provider can see

Because the server decapsulates and forwards your traffic, it is positioned to
observe:

- Your **real source address** (the outer packet's source) and connection times.
- The **destinations** you contact (inner packet destinations / DNS queries it
  resolves for you).
- **Timing and volume** of traffic.
- For TLS connections, often the **SNI** (the requested hostname) unless
  Encrypted Client Hello is in use — but **not** the encrypted content.

What it does **not** get, when HTTPS is used correctly:

- The **content** of TLS-protected requests and responses (URLs beyond the
  hostname, bodies, cookies, credentials). TLS is end-to-end between you and the
  destination; the VPN server only relays ciphertext.

> **CONCEPT**
> A VPN shifts the observer from your ISP to the provider. It doesn't remove
> observation. So the provider's *policy* and *incentives* become the core
> privacy question — which is why "trust model" is the right framing.

## Unreliable vs malicious

These are different failure modes:

- **Unreliable / careless:** leaks from bugs, oversubscribed infrastructure,
  sloppy DNS handling, vague policies. Harm is usually incidental. This overlaps
  with Module 03's misconfiguration category.
- **Privacy-invasive business model:** the service is free or cheap because it
  monetizes user metadata — logging, profiling, selling to third parties. Harm
  is intentional but may be disclosed (buried) in a policy.
- **Malicious:** the client or service deliberately steals data, injects
  content, or abuses the device. Harm is covert and criminal. This is covered in
  [chapters 02](02-traffic-manipulation.md) and
  [03](03-clients-and-supply-chain.md).

## Logging and retention

"No logs" is a marketing phrase, not a technical guarantee. Evaluate what is
actually retained:

- **Connection logs:** source IP, timestamps, assigned tunnel IP, bandwidth.
  Even "minimal" connection logs can enable correlation if retained.
- **Activity/traffic logs:** destinations, DNS queries, content metadata. Far
  more invasive.
- **Aggregate/diagnostic logs:** crash reports, total bandwidth. Usually low
  risk.

Key questions: *what* is logged, *how long* it's kept, whether it's *linked to
an identity*, and whether the claim has been *independently audited*. A policy
is a promise; an audit and a technical design (e.g. RAM-only servers) are
evidence.

> **TECHNICAL NOTE**
> Distinguish **legitimate operational logging** (short-lived data needed to run
> the service, like aggregate counters or abuse signals) from **retained
> activity logs** that reconstruct user behavior. The former is normal; the
> latter is the privacy concern. Scope and retention time are what matter.

## Traffic metadata collection

Even without content, metadata is powerful: the set of destinations you contact,
when, and how much can reveal a lot. A provider that retains metadata can build
a profile or hand it to third parties. This is why destination/DNS logging is a
red flag even when a provider claims it "can't see your traffic."

## Privacy policies and trust signals

Read the policy for specifics, and weigh independent signals:

- Clear, specific statements about what is and isn't logged, with retention
  periods.
- Independent security/privacy audits with published results.
- Jurisdiction and legal data-request exposure.
- Transparent ownership and a business model that doesn't depend on selling
  user data.
- Open-source clients you can inspect.

None of these is proof alone; together they form a reasonable trust assessment.

## References

- [RFC 8446 — TLS 1.3](https://www.rfc-editor.org/rfc/rfc8446) (what TLS protects)
- [RFC 7359 — VPN Traffic Leakage](https://www.rfc-editor.org/rfc/rfc7359)
- [WireGuard protocol](https://www.wireguard.com/protocol/) (what the server
  necessarily sees)

---

Next: [02 · Traffic Manipulation](02-traffic-manipulation.md) ·
Back: [Module index](README.md)