# References

Primary and official sources used across the project. RFCs are listed separately
in the [RFC list](rfc-list.md). Claims are cited near where they appear in each
chapter; this page collects the sources in one place.

## VPN protocol documentation

- [WireGuard — official site](https://www.wireguard.com/) — architecture and
  quick-start.
- [WireGuard — protocol & whitepaper](https://www.wireguard.com/protocol/) — the
  cryptographic design and handshake.
- [WireGuard — quick-start](https://www.wireguard.com/quickstart/) — `wg` /
  `wg-quick` usage and routing.
- [OpenVPN — community resources](https://openvpn.net/community-resources/) —
  official documentation hub.
- [OpenVPN — how-to](https://openvpn.net/community-resources/how-to/) —
  configuration, including `redirect-gateway`.

## Packet analysis tools

- [Wireshark — User's Guide](https://www.wireshark.org/docs/wsug_html/) — capture
  and display filters, following streams.
- [tcpdump — manual](https://www.tcpdump.org/manpages/tcpdump.1.html) — capture
  syntax and options.
- [pcap-filter — BPF syntax](https://www.tcpdump.org/manpages/pcap-filter.7.html)
  — capture filter expressions.

## Linux manual pages

- [`ip-link(8)`](https://man7.org/linux/man-pages/man8/ip-link.8.html),
  [`ip-address(8)`](https://man7.org/linux/man-pages/man8/ip-address.8.html),
  [`ip-route(8)`](https://man7.org/linux/man-pages/man8/ip-route.8.html),
  [`ip-rule(8)`](https://man7.org/linux/man-pages/man8/ip-rule.8.html),
  [`ip-neighbour(8)`](https://man7.org/linux/man-pages/man8/ip-neighbour.8.html),
  [`ip-tuntap(8)`](https://man7.org/linux/man-pages/man8/ip-tuntap.8.html)
- [`wg(8)`](https://man7.org/linux/man-pages/man8/wg.8.html),
  [`wg-quick(8)`](https://man7.org/linux/man-pages/man8/wg-quick.8.html)
- [`ss(8)`](https://man7.org/linux/man-pages/man8/ss.8.html),
  [`nft(8)`](https://man7.org/linux/man-pages/man8/nft.8.html)
- [`resolvectl(1)`](https://man7.org/linux/man-pages/man1/resolvectl.1.html),
  [`resolv.conf(5)`](https://man7.org/linux/man-pages/man5/resolv.conf.5.html),
  [`systemd-resolved.service(8)`](https://man7.org/linux/man-pages/man8/systemd-resolved.service.8.html)

## Firewall & distribution

- [nftables wiki](https://wiki.nftables.org/) — ruleset structure and examples.
- [Debian — SecureApt](https://wiki.debian.org/SecureApt) — signed package
  verification.
- [Debian — ca-certificates / update-ca-certificates](https://manpages.debian.org/update-ca-certificates)
  — managing trusted roots.

## Security context

- [OWASP — Credential stuffing](https://owasp.org/www-community/attacks/Credential_stuffing)
  — context for the behavioral detection discussion (Module 05).

## On source quality

This project prioritizes primary sources (RFCs, official protocol docs, man
pages) over blog posts. Where a claim is about browser behavior (WebRTC) or a
commercial practice (logging), it is framed as behavior-dependent rather than a
universal fact, because those vary by version and provider. No statistics or
research findings are cited that could not be traced to a primary source.

Back: [RFC list](rfc-list.md) · [Glossary](glossary.md) ·
[Project README](../README.md)