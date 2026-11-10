# Glossary

Short definitions of the terms used across the project. For depth, follow the
module links in each chapter.

**ASN (Autonomous System Number)** — an identifier for an organization that
announces IP prefixes to the global routing table; used to classify an IP's
owner (Module 05).

**BPF (Berkeley Packet Filter)** — the expression language `tcpdump` uses to
select which packets to capture (Module 06).

**CIDR** — Classless Inter-Domain Routing; the `/prefix` notation where the split
between network and host bits can fall anywhere (Module 01).

**Default gateway / default route** — the router / the `0.0.0.0/0` (or `::/0`)
route used for any destination with no more-specific match (Module 01).

**DNAT** — Destination NAT; rewriting the destination address of incoming
packets (port forwarding) (Module 01).

**DNS** — the Domain Name System; maps names to addresses (Module 01).

**DoH / DoT** — DNS over HTTPS (port 443) / DNS over TLS (port 853); encrypted DNS
that hides queries from on-path observers (Modules 01, 03).

**Dual-stack** — a host running IPv4 and IPv6 simultaneously, with two
independent paths to the Internet (Modules 01, 03).

**Encapsulation** — wrapping one packet inside another so it can cross a network;
the core of tunneling (Module 02).

**Full tunnel** — a VPN configuration that routes all traffic (both families)
into the tunnel (Modules 02, 03).

**GeoIP** — a database mapping IP ranges to approximate geographic location
(Module 05).

**ICE** — Interactive Connectivity Establishment; how WebRTC gathers candidate
addresses to connect peers (Module 03).

**Interface** — the kernel's abstraction for a network attachment point; physical
(real hardware) or virtual (software, e.g. a tunnel) (Module 01).

**Kill switch** — firewall rules that block non-tunnel traffic when the VPN is
down, closing reconnect/teardown leak windows (Modules 03, 08).

**Leak** — traffic that escapes the VPN tunnel and travels the ordinary network,
exposing something the VPN should hide (Module 03). Distinct from *detection*.

**Link-local** — an address valid only on the local link (`169.254.0.0/16`,
`fe80::/10`); not routed onward (Module 01).

**Longest prefix match** — the rule that the most-specific matching route wins;
the basis of routing decisions and many leaks (Modules 01, 03).

**Loopback** — the virtual interface (`lo`, `127.0.0.1`, `::1`) for traffic to the
machine itself (Module 01).

**MAC address** — the link-layer (layer 2) hardware address used to deliver frames
on a local network (Module 01).

**Masquerading** — a form of SNAT where the source becomes the outgoing
interface's address (Module 01).

**mDNS candidates** — WebRTC's use of multicast-DNS `.local` names to hide local
IPs from sites (Module 03).

**MTU** — Maximum Transmission Unit; the largest packet an interface carries.
Tunnels often need a smaller MTU (Modules 01, 02).

**NAT** — Network Address Translation; rewriting addresses (usually private ↔
public) at a network edge (Module 01).

**Netfilter / nftables** — the Linux packet-filtering framework and its modern
configuration tool; where kill switches and NAT live (Modules 01, 03, 08).

**On-link** — a destination inside a directly connected prefix, reachable without
a gateway (Module 01).

**Prefix** — the network portion of an address, written as a length (`/24`,
`/64`) (Module 01).

**Private / public address** — private addresses (RFC 1918) are local-only; public
addresses are globally routable and reachable (Module 01).

**Recursive resolver** — the DNS server that walks root → TLD → authoritative on
your behalf (Module 01).

**Routing table** — the kernel's set of "to reach X, send via Y out Z" rules
(Module 01).

**SNAT** — Source NAT; rewriting the source address of outgoing packets so
replies can return (Module 01).

**SNI** — Server Name Indication; the hostname sent in a TLS handshake, often
visible to observers unless Encrypted Client Hello is used (Module 04).

**Split tunneling** — routing only some traffic through the VPN; the rest uses
the physical interface (Modules 02, 03).

**STUN** — Session Traversal Utilities for NAT; a protocol that tells a client
the public address a server sees it from (Module 03).

**Stub resolver** — the lightweight OS client that forwards queries to a
recursive resolver (Module 01).

**Subnet** — a subdivision of an IP network defined by a prefix (Module 01).

**TCP / UDP** — connection-oriented reliable transport / connectionless datagram
transport (Module 01).

**TLS** — Transport Layer Security; the protocol behind HTTPS, protecting content
end-to-end (Modules 02, 04).

**tun / tap** — virtual tunnel interfaces carrying routed IP packets (layer 3) /
Ethernet frames (layer 2) respectively (Module 02).

**Tunnel** — a virtual link carried inside another network connection, usually
encrypted (Module 02).

**VPN detection** — a platform recognizing VPN use from the exit IP and behavior;
distinct from leakage (Module 05).

**WebRTC** — a browser API for real-time communication that can disclose candidate
IP addresses (Module 03).

**WireGuard / OpenVPN** — two VPN protocols with different designs: WireGuard is a
minimal UDP tunnel keyed by public keys; OpenVPN uses a TLS control channel and
PKI (Module 02).

Back: [References](references.md) · [RFC list](rfc-list.md) ·
[Project README](../README.md)