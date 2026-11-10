# Sample Captures

These are **synthetic, illustrative** text renderings of what `tcpdump` output
looks like in different scenarios. They are **not** real captures and were not
taken from a live network. They use documentation addresses
([RFC 5737](https://www.rfc-editor.org/rfc/rfc5737) /
[RFC 3849](https://www.rfc-editor.org/rfc/rfc3849)).

Their purpose is to show you the *shape* of the evidence before you run the labs
yourself. Your actual output will differ in addresses, interface names, ports,
and timing.

| File | Scenario | What to notice |
|------|----------|----------------|
| [`dns-leak-eth0.txt`](dns-leak-eth0.txt) | DNS leaking on the physical interface | Readable `A?` queries on `eth0` |
| [`tunneled-eth0.txt`](tunneled-eth0.txt) | Correctly tunneled traffic | Only opaque UDP/51820 on `eth0` |
| [`ipv6-leak-eth0.txt`](ipv6-leak-eth0.txt) | IPv6 bypassing an IPv4-only tunnel | Public IPv6 on `eth0` |

> **IMPORTANT**
> Do not cite these as experimental results. They are teaching illustrations.
> To produce real evidence, run the corresponding lab and capture it yourself.

Real `.pcap` files are intentionally excluded from version control by the
[`.gitignore`](../../.gitignore); only these curated text illustrations live here.