# Module 05 · VPN Detection

This module is about the *opposite* side of the connection: how a website or
platform figures out that a visitor is using a VPN — even when the VPN isn't
leaking anything. Detection and leakage are different problems (see the note
below), and the techniques here are about classifying the **exit address** and
the **behavior** attached to it.

| Chapter | Topic |
|---------|-------|
| [01 · Network-Based Detection](01-network-based-detection.md) | IP reputation, ASN, datacenter vs residential, GeoIP, shared exits |
| [02 · Behavioral Detection](02-behavioral-detection.md) | Auth anomalies, risk scoring, rate limits, false positives |

> **IMPORTANT**
> **Detection ≠ leakage.** A leak (Module 03) is your traffic escaping the
> tunnel. Detection is a platform recognizing VPN use from the *outside*, using
> the exit IP and behavior. A perfectly configured, leak-free VPN can still be
> detected; detection doesn't imply anything leaked.

> **IMPORTANT**
> Using a VPN is not inherently suspicious, and a datacenter IP is not
> inherently malicious. These signals are probabilistic and produce false
> positives. This module explains how they work and where they break — it does
> not provide a guide to evading a platform's security controls.

The detection pipeline is in
[`diagrams/vpn-detection.mmd`](../../diagrams/vpn-detection.mmd).

Prerequisites: [Module 01](../01-network-fundamentals/README.md) (addressing,
NAT) and [Module 02](../02-vpn-fundamentals/README.md). Continue to
[Module 08 · Prevention](../08-prevention/README.md).