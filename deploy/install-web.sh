#!/usr/bin/env bash
# marcos.chat web UI deployment script
# Run ON marcos: bash /home/nvidia/marcos-chat/deploy/install-web.sh
set -euo pipefail

echo "=== marcos.chat Web UI Deployment ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WEB_DIR="$(dirname "$SCRIPT_DIR")/web"

# --- Verify files ---
echo ""
echo "--- Verify web files ---"
ls -la "$WEB_DIR/serve.js" "$WEB_DIR/index.html"
node -c "$WEB_DIR/serve.js"
echo "serve.js syntax OK"

# --- Install systemd service ---
echo ""
echo "--- Install systemd service ---"
sudo cp "$SCRIPT_DIR/marcos-chat-web.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable marcos-chat-web.service
sudo systemctl restart marcos-chat-web.service

echo "Waiting for service to start..."
sleep 3

if systemctl is-active --quiet marcos-chat-web.service; then
    echo "marcos-chat-web service is running!"
else
    echo "WARNING: Service failed to start. Check: journalctl -u marcos-chat-web.service -n 20"
    exit 1
fi

# --- Update Tailscale serve ---
echo ""
echo "--- Update Tailscale serve ---"
sudo tailscale serve reset
sudo tailscale serve --bg https+insecure://127.0.0.1:18790
echo "Tailscale serve → :18790"

# --- Verification ---
echo ""
echo "=== Verification ==="
echo "Service: $(systemctl is-active marcos-chat-web.service)"
curl -s -o /dev/null -w "HTTP %{http_code}" http://127.0.0.1:18790 && echo ""
echo "URL: https://marcos.tail159bb1.ts.net/"
echo ""
echo "=== Done ==="
