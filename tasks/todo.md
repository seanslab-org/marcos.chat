# marcos.chat — Implementation Tasks

## Phase 0: Disk Cleanup — N/A (marcos has 116GB NVMe)

## Phase 1: Install Dependencies (marcos @ 100.65.235.58)
- [x] Node.js 22 — already installed (v22.22.0)
- [x] OpenClaw — already installed (v2026.3.2)
- [x] Ollama 0.18.0 — installed (binary scp'd from Mac)
- [x] Model: `qwen3.5:9b-q8_0` (10GB) — pulled

## Phase 2: Configure OpenClaw
- [x] Create workspace: `/home/nvidia/marcos-chat/`
- [x] Deploy persona files (SOUL.md, IDENTITY.md, USER.md)
- [x] Write `~/.openclaw/openclaw.json` with Ollama provider
- [x] Test: `openclaw gateway` → health check passes

## Phase 3: Network Access
- [x] Configure Tailscale serve for HTTPS
- [x] Verify: WebChat accessible at https://marcos.tail159bb1.ts.net/openclaw/webchat

## Phase 4: Systemd Service
- [x] Create `/etc/systemd/system/openclaw-marcos.service`
- [x] Enable and start service
- [ ] Reboot test: service auto-starts

## Phase 5: Custom Chat Web UI
- [x] Create `web/serve.js` — Node.js HTTP server + WebSocket proxy
- [x] Create `web/index.html` — Single-file chat UI (Google-style landing → chat mode)
- [x] Create `deploy/marcos-chat-web.service` — Systemd unit for web server
- [x] Local test: serve.js starts, serves HTML on :18790
- [x] Deploy to marcos: scp web/ files, install service
- [x] Update Tailscale serve: point to :18790 instead of :18789
- [x] End-to-end test: send message via custom UI, get streaming response

## Acceptance Criteria
- [x] WebChat responds with Marco's AI persona
- [ ] Avatar speaks Cantonese/Mandarin/English as appropriate (needs testing)
- [ ] Service survives reboot (needs reboot test)

## Review
- **Services verified**: ollama (active), openclaw-marcos (active)
- **Health check**: `{"ok":true,"status":"live"}`
- **WebChat**: serving at /openclaw/webchat
- **Tailscale HTTPS**: https://marcos.tail159bb1.ts.net/
- **Known limitations**:
  - OpenClaw 2026.3.2 (update available: 2026.3.13)
  - No auth on gateway (tailnet-only access)
  - Reboot test pending
