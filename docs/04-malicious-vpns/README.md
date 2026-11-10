# Module 04 · Malicious VPN Applications

A VPN concentrates a lot of trust in one piece of software and one provider.
This module examines what can go wrong when that trust is misplaced — and is
careful to separate very different things that often get lumped together as
"malicious VPNs."

| Chapter | Topic |
|---------|-------|
| [01 · The Trust Model](01-trust-model.md) | Unreliable vs malicious, logging, metadata, what a provider can see |
| [02 · Traffic Manipulation](02-traffic-manipulation.md) | DNS/HTTP tampering, root certificates, TLS interception limits |
| [03 · Clients & Supply Chain](03-clients-and-supply-chain.md) | Fake apps, permissions, exfiltration, supply-chain risk |

## Four categories, not one

> **IMPORTANT**
> These are distinct problems with distinct mitigations. Don't conflate them:
>
> 1. **Technical misconfiguration** — an honest provider/client with a bug or
>    bad default that causes leaks (Module 03). Fix: better configuration.
> 2. **Privacy-invasive business practices** — a provider that legally logs,
>    retains, or sells metadata. Fix: choose a provider whose policy and audits
>    match your needs.
> 3. **Malicious software** — a client or app that deliberately steals data,
>    injects traffic, or abuses permissions. Fix: don't install it; verify
>    authenticity.
> 4. **Legitimate operational logging** — minimal logs needed to run the service
>    (e.g. aggregate bandwidth, abuse prevention). Not inherently a privacy
>    violation; evaluate scope and retention.

## The HTTPS reality check

> **IMPORTANT**
> A VPN provider **cannot automatically decrypt arbitrary HTTPS traffic.**
> Correctly implemented TLS protects content end-to-end between your browser and
> the destination server. The provider sees metadata (destinations, timing,
> volume, SNI in many cases) but not the encrypted payload. TLS interception is
> only possible if the user's device is made to trust an attacker's root
> certificate — a deliberate, visible step, not a silent VPN capability.
> [Chapter 02](02-traffic-manipulation.md) explains exactly what is and isn't
> visible.

Prerequisites: [Module 02](../02-vpn-fundamentals/README.md). Continue to
[Module 05 · VPN Detection](../05-vpn-detection/README.md) or
[Module 08 · Prevention](../08-prevention/README.md).