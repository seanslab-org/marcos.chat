# marcos.chat — Implementation Tasks

## Phase 0: Disk Cleanup — N/A (marcos has 116GB NVMe)

## Phase 1: Install Dependencies (marcos @ 100.65.235.58)
- [x] Node.js 22 — already installed (v22.22.0)
- [x] OpenClaw — already installed (v2026.3.2)
- [x] Ollama 0.18.0 — installed (binary scp'd from Mac)
- [x] Model: `qwen3.5:9b-q4_K_M` (6.6GB) — pulled (upgraded from Q8_0)

## Phase 2: Configure OpenClaw
- [x] Create workspace: `/home/nvidia/marcos-chat/`
- [x] Deploy persona files (SOUL.md, IDENTITY.md, USER.md)
- [x] Write `~/.openclaw/openclaw.json` with Ollama provider
- [x] Test: `openclaw gateway` → health check passes
- [x] Custom Ollama model `marcos-chat` (Q4_K_M, num_ctx 16384, num_predict 512)
- [x] Disable thinking: `thinkingDefault: "off"`
- [x] Timeout: 300s

## Phase 3: Network Access
- [x] Configure Tailscale serve for HTTPS
- [x] Verify: WebChat accessible at https://marcos.tail159bb1.ts.net/

## Phase 4: Systemd Services
- [x] `openclaw-marcos.service` — OpenClaw gateway
- [x] `marcos-chat-web.service` — Custom web UI (:18790)
- [x] `ollama-preload.service` — Preload model on boot
- [x] `ollama.service` — OLLAMA_KEEP_ALIVE=-1 (model stays loaded forever)
- [ ] Reboot test: all services auto-start

## Phase 5: Custom Chat Web UI
- [x] `web/serve.js` — Node.js HTTP server + WebSocket proxy + token injection
- [x] `web/index.html` — walkie.sh-inspired chat UI (monospace, flat, minimal)
- [x] OpenClaw WS protocol: challenge → connect → chat.send → streaming
- [x] Origin/Host header rewriting in proxy
- [x] crypto.randomUUID() fallback for HTTP contexts
- [x] New session per page refresh
- [x] Animated thinking dots
- [x] "patient please" warning + copyright
- [x] Deploy to marcos, Tailscale serve → :18790
- [x] End-to-end verified

## Phase 6: Performance Optimization
- [x] Q8_0 (10GB) → Q4_K_M (6.6GB): freed 4GB RAM
- [x] Disable thinking: 966 tokens → ~50 tokens per response
- [x] OLLAMA_KEEP_ALIVE=-1 + preload service
- [x] Context 32768 → 16384
- [x] Result: 145s → 36s response time (~4x faster)

## Acceptance Criteria
- [x] WebChat responds with Marco's AI persona
- [x] Custom UI live at marcos.tail159bb1.ts.net and 100.65.235.58:18790
- [x] Streaming responses with animated thinking indicator
- [ ] Avatar speaks Cantonese/Mandarin/English as appropriate (needs testing)
- [ ] Service survives reboot (needs reboot test)

## Review
- **Services**: ollama, openclaw-marcos, marcos-chat-web, ollama-preload (all active)
- **Health check**: `{"ok":true,"status":"live"}`
- **Model**: marcos-chat (Qwen3.5 9B Q4_K_M), 100% GPU, loaded forever
- **Memory**: ~4GB available (was <200MB with Q8_0)
- **Response time**: ~36s (was 145s)
- **Known limitations**:
  - OpenClaw 2026.3.2 (update available: 2026.3.13)
  - Gateway token exposed in HTML (tailnet-only access mitigates)
  - Reboot test pending
  - ~36s response time (Jetson GPU inference speed limit)
