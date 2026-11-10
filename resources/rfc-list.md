# RFC List

The IETF RFCs referenced across this project, grouped by topic. Titles are the
official RFC titles; the "used for" column says where each one matters here.
All links go to the RFC Editor, the authoritative source.

## Core Internet protocols

| RFC | Title | Used for |
|-----|-------|----------|
| [791](https://www.rfc-editor.org/rfc/rfc791) | Internet Protocol | IPv4 addressing & packet format (Module 01) |
| [768](https://www.rfc-editor.org/rfc/rfc768) | User Datagram Protocol | UDP, DNS/WireGuard transport (Modules 01, 06) |
| [793](https://www.rfc-editor.org/rfc/rfc793) | Transmission Control Protocol | TCP & the handshake (Modules 01, 06) |
| [8200](https://www.rfc-editor.org/rfc/rfc8200) | Internet Protocol, Version 6 (IPv6) Specification | IPv6 (Modules 01, 03) |
| [826](https://www.rfc-editor.org/rfc/rfc826) | An Ethernet Address Resolution Protocol | ARP / neighbor cache (Module 01) |

## Addressing & subnetting

| RFC | Title | Used for |
|-----|-------|----------|
| [1918](https://www.rfc-editor.org/rfc/rfc1918) | Address Allocation for Private Internets | Private IPv4 ranges (Module 01) |
| [4632](https://www.rfc-editor.org/rfc/rfc4632) | Classless Inter-domain Routing (CIDR) | Prefix notation (Module 01) |
| [4291](https://www.rfc-editor.org/rfc/rfc4291) | IP Version 6 Addressing Architecture | IPv6 address types (Module 01) |
| [4862](https://www.rfc-editor.org/rfc/rfc4862) | IPv6 Stateless Address Autoconfiguration | SLAAC / `/64` (Module 01) |
| [6724](https://www.rfc-editor.org/rfc/rfc6724) | Default Address Selection for Internet Protocol Version 6 (IPv6) | IPv6 preference / dual-stack leaks (Module 03) |
| [5737](https://www.rfc-editor.org/rfc/rfc5737) | IPv4 Address Blocks Reserved for Documentation | Example addresses used throughout |
| [3849](https://www.rfc-editor.org/rfc/rfc3849) | IPv6 Address Prefix Reserved for Documentation | Example IPv6 used throughout |

## Routing, NAT & neighbors

| RFC | Title | Used for |
|-----|-------|----------|
| [1812](https://www.rfc-editor.org/rfc/rfc1812) | Requirements for IP Version 4 Routers | Forwarding / longest-prefix match (Module 01) |
| [4861](https://www.rfc-editor.org/rfc/rfc4861) | Neighbor Discovery for IP version 6 (IPv6) | IPv6 neighbors (Module 01) |
| [2663](https://www.rfc-editor.org/rfc/rfc2663) | IP Network Address Translator (NAT) Terminology and Considerations | NAT concepts (Module 01) |
| [3022](https://www.rfc-editor.org/rfc/rfc3022) | Traditional IP Network Address Translator (Traditional NAT) | SNAT/DNAT (Module 01) |

## DNS

| RFC | Title | Used for |
|-----|-------|----------|
| [1034](https://www.rfc-editor.org/rfc/rfc1034) | Domain names — concepts and facilities | DNS model (Module 01) |
| [1035](https://www.rfc-editor.org/rfc/rfc1035) | Domain names — implementation and specification | DNS protocol (Modules 01, 06) |
| [7858](https://www.rfc-editor.org/rfc/rfc7858) | Specification for DNS over Transport Layer Security (TLS) | DoT (Modules 01, 03) |
| [8484](https://www.rfc-editor.org/rfc/rfc8484) | DNS Queries over HTTPS (DoH) | DoH (Modules 01, 03) |

## VPN leakage & TLS

| RFC | Title | Used for |
|-----|-------|----------|
| [7359](https://www.rfc-editor.org/rfc/rfc7359) | Layer 3 Virtual Private Network (VPN) Tunnel Traffic Leakages in Dual-Stack Hosts/Networks | The core problem statement (Modules 02, 03) |
| [8446](https://www.rfc-editor.org/rfc/rfc8446) | The Transport Layer Security (TLS) Protocol Version 1.3 | What TLS protects; OpenVPN control channel (Modules 02, 04) |
| [6125](https://www.rfc-editor.org/rfc/rfc6125) | Representation and Verification of Domain-Based Application Service Identity within Internet PKI Using X.509 (PKIX) Certificates in the Context of TLS | Why TLS interception needs a trusted rogue root (Module 04) |

## WebRTC

| RFC | Title | Used for |
|-----|-------|----------|
| [8825](https://www.rfc-editor.org/rfc/rfc8825) | Overview: Real-Time Protocols for Browser-Based Applications | WebRTC overview (Module 03) |
| [8445](https://www.rfc-editor.org/rfc/rfc8445) | Interactive Connectivity Establishment (ICE): A Protocol for NAT Traversal | ICE candidates (Module 03) |
| [5389](https://www.rfc-editor.org/rfc/rfc5389) | Session Traversal Utilities for NAT (STUN) | STUN reflexive candidates (Module 03) |
| [8828](https://www.rfc-editor.org/rfc/rfc8828) | WebRTC IP Address Handling Requirements | mDNS candidate hiding (Module 03) |

## VPN detection (ownership / routing data)

| RFC | Title | Used for |
|-----|-------|----------|
| [4271](https://www.rfc-editor.org/rfc/rfc4271) | A Border Gateway Protocol 4 (BGP-4) | How prefixes/ASNs are announced (Module 05) |
| [3912](https://www.rfc-editor.org/rfc/rfc3912) | WHOIS Protocol Specification | IP ownership lookup (Module 05) |
| [7480](https://www.rfc-editor.org/rfc/rfc7480) | HTTP Usage in the Registration Data Access Protocol (RDAP) | Modern registration lookup (Module 05) |

> **NOTE**
> RFC 7359 is the single most on-point reference for this project: it documents
> exactly the dual-stack tunnel leakage behavior the labs reproduce.

Back: [References](references.md) · [Project README](../README.md)