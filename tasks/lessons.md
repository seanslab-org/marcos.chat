# Lessons Learned

## 2026-03-15: Wrong deployment target
- **Mistake**: Deployed to orin32g (100.123.48.6) instead of marcos (100.65.235.58). Deleted Ollama models on the wrong machine.
- **Rule**: Always verify the target machine hostname after first SSH connection. For marcos.chat, the target is `nvidia@100.65.235.58` (hostname: marcos).

## 2026-03-15: Qwen3.5 model sizing
- **Mistake**: Plan referenced "Qwen3.5 14B Q4_K_M" which doesn't exist. Qwen3.5 comes in 0.8B, 2B, 4B, 9B, 27B, 35B, 122B.
- **Rule**: Verify model availability on Ollama before planning. Final choice: `qwen3.5:9b-q8_0`.

## 2026-03-15: OpenClaw config schema changes
- **Mistake**: Used old `identity` and `agent` top-level keys in openclaw.json. OpenClaw 2026.3.x moved these to `agents.list[].identity` and `agents.defaults`.
- **Rule**: Run `openclaw doctor` after deploying config to catch schema errors. Use `agents.defaults` and `agents.list` instead of `agent` and `identity`.

## 2026-03-15: Jetson slow internet
- **Observation**: The Jetson marcos has slow internet (~4 MB/s). Downloads from GitHub often time out.
- **Rule**: For large files (Ollama binary, models), download on Mac first and scp to Jetson.

## 2026-03-16: Jetson Orin 16G crashes under repeated LLM load
- **Observation**: Running multiple back-to-back LLM test requests via OpenClaw causes marcos to become unreachable (SSH times out, needs power cycle).
- **Rule**: Avoid rapid-fire LLM requests during testing. Space out test messages and limit to 1-2 short prompts. The 16GB Orin can be overwhelmed by concurrent Qwen3.5 9B inference.

## 2026-03-16: crypto.randomUUID() requires HTTPS
- **Mistake**: Used `crypto.randomUUID()` in browser JS. This API requires a secure context (HTTPS). When accessed via plain HTTP, it throws an error that silently breaks the WebSocket handshake.
- **Rule**: Always provide a Math.random() fallback for UUID generation in browser code that may be served over HTTP.

## 2026-03-30: OpenClaw 2026.3.28 scope enforcement change
- **Observation**: After upgrading OpenClaw from 2026.3.2 to 2026.3.28, `chat.send` failed with `missing scope: operator.write`. The new version enforces device identity (public key auth) for full operator scopes. Webchat clients with simple token auth get their scopes silently cleared.
- **Rule**: For webchat clients without device identity, use `client.id: "openclaw-control-ui"` with `mode: "ui"` and set `gateway.controlUi.dangerouslyDisableDeviceAuth: true` + `allowInsecureAuth: true` in the config. Also set `gateway.trustedProxies: ["127.0.0.1", "::1"]` when proxying via serve.js.

## 2026-03-30: First message lost on page load
- **Observation**: The `onSubmit` handler cleared the input field before `sendMessage` checked if the WebSocket was ready (`sessionKey` set). If the user typed and hit Enter before the WS handshake completed, the message was silently lost.
- **Rule**: Always guard form submission with readiness checks (`!sessionKey`) before clearing user input.

## 2026-03-16: OpenClaw WebSocket protocol details
- **Mistake**: Assumed request `id` could be a number, `client.id` could be arbitrary, and no auth was needed.
- **Rule**: OpenClaw gateway protocol requires:
  - Request frame: `{type:"req", id:<UUID string>, method, params}` — id must be non-empty string
  - Client ID: must be a known constant (`"openclaw-control-ui"`, `"webchat"`, `"cli"`, etc.) — use `"openclaw-control-ui"` for full operator scopes with token auth
  - Auth: when `gateway.auth.mode` is `"token"`, include `auth:{token}` in connect params
  - Scopes: `["operator.admin","operator.write","operator.read"]` needed for chat operations
  - Origin header: must match `gateway.controlUi.allowedOrigins` — proxy must rewrite it
  - Connect flow: wait for `connect.challenge` event before sending connect request
  - Session key: extracted from `payload.snapshot.sessionDefaults.mainSessionKey`
  - Chat events: `event:"chat"`, payload has `state:"delta"|"final"`, `message.content:[{type,text}]`
