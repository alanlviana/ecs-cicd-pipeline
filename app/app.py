from flask import Flask
import os

app = Flask(__name__)

@app.route('/')
def index():
    environment = os.getenv('environment', 'Not Set')
    hostname = os.uname()[1]
    return f"""
    <html><body>
    <h1>Version: 4</h1>
    <h1>Environment: {environment}</h1>
    <h1>Hostname: {hostname}</h1>
    </body></html>
    """

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
