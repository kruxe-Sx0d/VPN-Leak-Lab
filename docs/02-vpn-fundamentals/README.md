# Module 02 · VPN Fundamentals

Now we add the VPN to the model from Module 01. The goal is a precise picture of
what a VPN does — and, just as importantly, what it doesn't do. Many leak
misconceptions come from assuming a VPN is a magic privacy switch rather than a
specific set of routing and encapsulation steps.

| Chapter | Topic |
|---------|-------|
| [01 · What a VPN Actually Does](01-what-is-a-vpn.md) | Client/server model, full vs split tunneling |
| [02 · Tunneling & Encapsulation](02-tunneling-and-encapsulation.md) | How a packet gets wrapped, encryption vs tunneling |
| [03 · WireGuard](03-wireguard.md) | Architecture, keys, the UDP tunnel |
| [04 · OpenVPN](04-openvpn.md) | Architecture, TLS control channel, tun/tap |
| [05 · Connection Lifecycle](05-connection-lifecycle.md) | From "connect" to a working tunnel, and teardown |

## The one-paragraph version

A VPN client creates a virtual network interface and arranges routing so that
selected traffic goes into it. The client encrypts each packet and wraps it in a
new outer packet addressed to the VPN server. The server unwraps it and forwards
the original packet to the Internet, so the destination sees the server's
address instead of yours. Everything else — DNS, IPv6, WebRTC — only stays
private if it is *also* routed into that interface.

> **IMPORTANT**
> A VPN does **not** automatically encrypt every application protocol
> independently of configuration. It protects what its routes send into the
> tunnel. Traffic that never enters the tunnel (a stray DNS query, an IPv6
> connection, a WebRTC STUN request) gets no protection at all. This is the
> central idea of [Module 03](../03-vpn-leaks/README.md).

## Diagrams

The figures below are used throughout the module. Sources live in
[`diagrams/`](../../diagrams/).

- [VPN architecture](../../diagrams/vpn-architecture.mmd)
- [Packet encapsulation (Mermaid)](../../diagrams/vpn-encapsulation.mmd) and the
  [SVG version](../../assets/images/encapsulation.svg)
- [Routing decision flow](../../diagrams/routing-flow.mmd)

Prerequisites: [Module 01](../01-network-fundamentals/README.md). When you're
done, continue to [Module 03 · VPN Traffic Leaks](../03-vpn-leaks/README.md).