from http.server import BaseHTTPRequestHandler, HTTPServer
import os

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        environment = os.getenv('environment', 'Not Set')
        hostname = os.uname()[1]
        self.wfile.write(bytes("<html><body>", "utf8"))
        self.wfile.write(bytes(f"<h1>Version: 2</h1>", "utf8"))
        self.wfile.write(bytes(f"<h1>Environment: {environment}</h1>", "utf8"))
        self.wfile.write(bytes(f"<h1>Hostname: {hostname}</h1>", "utf8"))
        self.wfile.write(bytes("</body></html>", "utf8"))

def run(server_class=HTTPServer, handler_class=RequestHandler, port=80):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f'Starting httpd on port {port}...')
    httpd.serve_forever()

if __name__ == "__main__":
    run()