# 02 · Behavioral Detection

## Overview

Network signals tell a platform *what kind of address* a visitor uses.
Behavioral signals tell it *how that visitor acts*. Platforms combine the two
into a risk score. This chapter covers the behavioral side — authentication
anomalies, activity patterns, rate limiting — and why these systems produce
false positives even for ordinary users.

## Authentication anomalies

Account systems watch for login patterns that don't fit the account's history:

- **Impossible travel:** a login from one country minutes after a login from
  another. A VPN exit in a different country can trigger this even for a
  legitimate user.
- **New device + new location at once:** a VPN changes the apparent location, so
  a routine login from a new browser can look like a takeover.
- **Shared-exit collisions:** many accounts logging in from one VPN exit IP
  looks like credential stuffing or a bot farm, even when each login is genuine.

These are heuristics over the *pattern*, not proof of wrongdoing.

## Behavioral risk analysis

Beyond logins, platforms score ongoing activity:

- Request rate and rhythm (humans are irregular; scripts are metronomic).
- Mouse/keyboard/touch dynamics where available.
- Consistency of headers, TLS fingerprint, and device characteristics.
- Whether many sessions share one IP or one device fingerprint.

A VPN interacts with these mostly through the **shared exit**: many unrelated
users behind one IP inflate the apparent "activity per address," which can push
the score up for everyone on that exit.

## Rate limiting and reputation systems

Rate limits cap requests per IP (or per account) over a window. Because a VPN
exit aggregates many users, a shared exit hits per-IP limits faster than a home
connection would. Reputation systems extend this with longer memory: an exit
that was abusive yesterday gets stricter treatment today, affecting all its
current users.

> **CONCEPT**
> Most "VPN detection" consequences are really **risk management**: the platform
> isn't certain you're on a VPN, it's managing the *probability* of abuse. A
> challenge (CAPTCHA, 2FA step-up) is often the response, not a hard block.

## Example: how signals combine

| Signal | Alone | Combined with others |
|--------|-------|----------------------|
| Datacenter IP | Weak hint | Stronger with shared-exit + anomaly |
| Shared exit, many accounts | Suspicious | Very strong if also new devices |
| GeoIP mismatch | Weak (GeoIP is rough) | Stronger with impossible travel |
| High request rate | Could be a busy API | Stronger with datacenter + automation fingerprint |

No single row is decisive; the score is the aggregate. That's why false
positives happen: a legitimate user can accumulate several weak signals at once.

## Limitations and false positives

- **Legitimate privacy users get flagged.** Using a VPN for privacy is not
  abuse, but it shares signals with abuse.
- **Shared exits punish the group.** One bad actor degrades the exit for all.
- **Behavioral models misread normal variation.** Travel, new devices, and
  accessibility tools can look anomalous.
- **Sophisticated abuse mimics normal behavior.** Detection is an arms race, not
  a solved problem.

> **IMPORTANT**
> This chapter explains how detection works so you can reason about privacy and
> false positives. It is not a guide to evading a platform's security controls.
> Circumventing access controls or anti-abuse systems may violate terms of
> service or law.

## References

- [RFC 4271 — BGP-4](https://www.rfc-editor.org/rfc/rfc4271) (for the network
  signals this chapter builds on)
- [RFC 8446 — TLS 1.3](https://www.rfc-editor.org/rfc/rfc8446) (TLS fingerprinting
  context: what is and isn't visible)
- General reference: OWASP on
  [credential stuffing](https://owasp.org/www-community/attacks/Credential_stuffing)
  and automated-attack context

---

Next: [Module 06 · Network Traffic Analysis](../06-traffic-analysis/README.md) ·
Back: [Module index](README.md)