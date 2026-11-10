#!/usr/bin/env python3
"""ip-echo.py — tiny HTTP service that reports the requester's source address.

Used by the labs as a controlled "destination" so you can check which source IP
a remote server actually sees, without contacting any third-party service.

Usage (on the server VM):
    python3 ip-echo.py                 # listen on 0.0.0.0:8080
    python3 ip-echo.py --port 9000     # custom port
    python3 ip-echo.py --bind ::       # listen on IPv6 too (dual-stack)

Then, from the client:
    curl -4 http://192.0.2.20:8080/    # see which IPv4 source arrives
    curl -6 http://[2001:db8:1::20]:8080/   # IPv6, if configured

No root needed for ports > 1024. Standard library only. This is a lab aid, not
a hardened service — run it only on an isolated lab network.
"""

import argparse
import http.server
import socket
import sys


class EchoHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        # client_address is (host, port); host is the source IP as we see it.
        src_ip = self.client_address[0]
        family = "IPv6" if ":" in src_ip else "IPv4"
        body = f"{src_ip}\nfamily={family}\n".encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        # One concise line per request instead of the default verbose log.
        sys.stderr.write(f"[ip-echo] {self.client_address[0]} {fmt % args}\n")


def main():
    parser = argparse.ArgumentParser(description="Report the requester's source IP.")
    parser.add_argument("--bind", default="0.0.0.0", help="address to bind (default 0.0.0.0)")
    parser.add_argument("--port", type=int, default=8080, help="port (default 8080)")
    args = parser.parse_args()

    if not (1024 <= args.port <= 65535):
        parser.error("use a port between 1024 and 65535 (no root needed)")

    # Pick the right socket family for the bind address.
    family = socket.AF_INET6 if ":" in args.bind else socket.AF_INET

    class Server(http.server.HTTPServer):
        address_family = family

    try:
        httpd = Server((args.bind, args.port), EchoHandler)
    except OSError as exc:
        sys.exit(f"Could not bind {args.bind}:{args.port}: {exc}")

    print(f"[ip-echo] listening on {args.bind}:{args.port} ({'IPv6' if family == socket.AF_INET6 else 'IPv4'})")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n[ip-echo] stopped")


if __name__ == "__main__":
    main()