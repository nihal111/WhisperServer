"""HTTPS server for WhisperServer web UI with /inference proxy."""

import http.server
import ssl
import sys
import os
import urllib.request

WHISPER_BACKEND = "http://127.0.0.1:8080"

port = int(sys.argv[1])
certfile = sys.argv[2]
keyfile = sys.argv[3]
directory = sys.argv[4]

os.chdir(directory)


class Handler(http.server.SimpleHTTPRequestHandler):
    def do_POST(self):
        if self.path == "/inference":
            # Proxy to whisper-server
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length)

            req = urllib.request.Request(
                f"{WHISPER_BACKEND}/inference",
                data=body,
                headers={"Content-Type": self.headers["Content-Type"]},
                method="POST",
            )
            try:
                with urllib.request.urlopen(req, timeout=120) as resp:
                    resp_body = resp.read()
                    self.send_response(resp.status)
                    for key in ("Content-Type", "Content-Length"):
                        val = resp.getheader(key)
                        if val:
                            self.send_header(key, val)
                    self.end_headers()
                    self.wfile.write(resp_body)
            except Exception as e:
                self.send_response(502)
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                self.wfile.write(f"Proxy error: {e}".encode())
        else:
            self.send_response(404)
            self.end_headers()


httpd = http.server.HTTPServer(("0.0.0.0", port), Handler)

ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
ctx.load_cert_chain(certfile, keyfile)
httpd.socket = ctx.wrap_socket(httpd.socket, server_side=True)

print(f"Serving HTTPS on 0.0.0.0:{port}")
httpd.serve_forever()
