# Contributing to VPN Leak Lab

Thanks for wanting to help. This is an educational project, so the bar is
**clarity and correctness**, not volume. A single well-explained chapter is
worth more than ten shallow ones.

## What belongs here

- Explanations of how VPNs, routing, DNS, and leaks actually work.
- Reproducible, safe labs that run in an environment the reader controls.
- Diagrams that clarify a real technical relationship.
- Corrections to technical claims, with a source.

## What does not belong here

- Instructions for attacking third-party services, intercepting other people's
  traffic, stealing credentials, or bypassing a platform's security controls.
- Real credentials, private keys, or packet captures from real networks.
- Marketing claims about specific commercial VPN products.
- Filler content, placeholder `TODO` sections, or empty files.

## Writing style

Read any existing chapter before writing a new one, and match it:

- Explain concepts before relying on them. Don't assume the reader knows NAT,
  subnetting, or virtual interfaces.
- Prefer a concrete example over an abstract definition.
- Keep paragraphs short and focused. Vary sentence structure.
- Use the callout labels consistently: `CONCEPT`, `TECHNICAL NOTE`, `WARNING`,
  `LAB`, `OBSERVATION`, `IMPORTANT`.
- Cite a claim near where it appears. Prefer RFCs, official docs, and man pages.
  Never invent a source, RFC number, or statistic.

## Labs

Every lab must include the full checklist in
[docs/07-practical-labs/README.md](docs/07-practical-labs/README.md): objective,
prerequisites, topology, setup, steps, expected observations, explanation,
troubleshooting, cleanup, and learning outcomes.

- Label any output you did not personally capture as **illustrative**.
- Never claim a lab is "tested" unless you actually ran it.
- Use documentation address ranges (`192.0.2.0/24`, `198.51.100.0/24`,
  `203.0.113.0/24`, `2001:db8::/32`) in examples, never real addresses.
- Scripts must be readable, validate their assumptions, avoid destructive
  defaults, and state which commands need root.

## Diagrams

- Use Mermaid (`.mmd`) for flowcharts and sequence diagrams.
- Use SVG only when Mermaid can't express the idea cleanly.
- Keep the palette consistent: charcoal, muted green, soft blue, neutral gray.
- Every diagram needs a caption explaining what it shows.

## Before you open a pull request

1. Check that all relative Markdown links resolve.
2. Render any Mermaid diagram you touched (GitHub renders `.mmd` fenced blocks).
3. Run `bash -n` on any shell script you changed.
4. Re-read your prose out loud; cut anything that sounds like filler.

## Licensing

By contributing, you agree your contributions are licensed under the
[MIT License](LICENSE).