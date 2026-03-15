#!/usr/bin/env bash
# marcos.chat deployment script for Jetson Orin 16G (hostname: marcos)
# Target: nvidia@100.65.235.58
# Run as user nvidia: bash install.sh
set -euo pipefail

echo "=== marcos.chat deployment ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
HOME_DIR="/home/nvidia"

# --- Phase 1: Verify Prerequisites ---
echo ""
echo "--- Phase 1: Verify Prerequisites ---"
echo "Node.js: $(node --version)"
echo "OpenClaw: $(openclaw --version)"
ollama --version
echo "Ollama model:"
ollama list | grep qwen3.5 || echo "WARNING: qwen3.5:9b-q8_0 not pulled yet. Run: ollama pull qwen3.5:9b-q8_0"

# --- Phase 2: Configure OpenClaw ---
echo ""
echo "--- Phase 2: Configure OpenClaw ---"

mkdir -p "$HOME_DIR/marcos-chat"
mkdir -p "$HOME_DIR/.openclaw/agents/main/sessions"

cp "$REPO_DIR/SOUL.md" "$HOME_DIR/marcos-chat/"
cp "$REPO_DIR/IDENTITY.md" "$HOME_DIR/marcos-chat/"
cp "$REPO_DIR/USER.md" "$HOME_DIR/marcos-chat/"
cp "$SCRIPT_DIR/openclaw.json" "$HOME_DIR/.openclaw/openclaw.json"

chmod 700 "$HOME_DIR/.openclaw"
chmod 600 "$HOME_DIR/.openclaw/openclaw.json"

echo "Persona files deployed to $HOME_DIR/marcos-chat/"
echo "Config deployed to $HOME_DIR/.openclaw/openclaw.json"

# --- Phase 3: Systemd Service ---
echo ""
echo "--- Phase 3: Systemd Service ---"

sudo cp "$SCRIPT_DIR/openclaw-marcos.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable openclaw-marcos.service
sudo systemctl restart openclaw-marcos.service

echo "Waiting for service to start..."
sleep 5

if systemctl is-active --quiet openclaw-marcos.service; then
    echo "openclaw-marcos service is running!"
else
    echo "WARNING: Service failed to start. Check: journalctl -u openclaw-marcos.service -n 20"
    exit 1
fi

# --- Phase 4: Tailscale Serve ---
echo ""
echo "--- Phase 4: Configure Tailscale Serve ---"
sudo tailscale serve --bg https+insecure://127.0.0.1:18789
echo "Tailscale serve configured"

# --- Verification ---
echo ""
echo "=== Verification ==="
echo "Disk: $(df -h / | tail -1 | awk '{print $4}') free"
echo "Service: $(systemctl is-active openclaw-marcos.service)"
curl -s http://127.0.0.1:18789/health && echo ""
echo ""
echo "WebChat: http://127.0.0.1:18789/openclaw/webchat"
echo ""
echo "=== Done ==="
