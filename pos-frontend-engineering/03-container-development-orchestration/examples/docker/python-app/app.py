from http.server import BaseHTTPRequestHandler, HTTPServer
import json
import os


class Handler(BaseHTTPRequestHandler):
    def do_GET(self) -> None:
        if self.path in {"/health", "/health/live", "/health/ready"}:
            payload = {"status": "ok"}
            status = 200
        else:
            payload = {
                "message": "Container Development & Orchestration",
                "hostname": os.uname().nodename,
            }
            status = 200

        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


if __name__ == "__main__":
    port = int(os.getenv("PORT", "8080"))
    server = HTTPServer(("0.0.0.0", port), Handler)
    print(f"Servidor iniciado na porta {port}", flush=True)
    server.serve_forever()
