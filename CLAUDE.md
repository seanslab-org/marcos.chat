# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**marcos.chat** — Marco Song's personal AI avatar experiment.

An AI avatar running on a local Jetson Orin 16G device, powered by OpenClaw with a local Qwen3.5 9B Q8_0 model via Ollama. Accessible via a web chat interface at `marcos.chat`, connected through Tailscale.

### Key Components
- **OpenClaw 2026.3.x** — AI avatar framework with personal context
- **Ollama 0.18.0** — Local LLM serving
- **Qwen3.5 9B Q8_0** — Local LLM running on Jetson Orin 16G (~10GB)
- **Tailscale** — Network connectivity with fixed IP

### Design Principles
- **Local-first**: All AI inference runs on-device (Jetson Orin 16G)
- **Personal AI avatar**: Progressively enhanced with skills and personal context
- **Vibe Coding**: Built iteratively with Claude Code as the primary development tool

## Engineering Guideline

This document defines the required engineering workflow. The standard is "firmware bring-up discipline": plan first, instrument the work, verify each stage, and only then declare completion.

### 0) Workspace and Project Structure

1. **Root work folder (authoritative):** `/Users/seansong/seanslab/` — project by project
2. **Project folder:** `/Users/seansong/seanslab/marcos.chat/`
3. **Every project must have a GitHub repo — no exceptions.**
4. **Notes directory**: Project documentation, guides, and planning docs are kept in `/Users/seansong/seanslab/Obsidian/`

### 1) Planning and Design First (No Blind Execution)

1. **Plan mode by default**
   - Enter plan mode for any non-trivial task (>=3 steps, or any architectural decision).
   - Plan must include: interfaces, constraints, failure modes, rollback plan, and verification steps.
2. **Design first**
   - Start with a written SDD (System Design Document) before meaningful implementation.
   - Reduce ambiguity up front; do not "discover requirements" in the middle of coding.
3. **Re-plan immediately when reality diverges**
   - If assumptions break, behavior is unexpected, or requirements are unclear: stop and re-plan.
   - Do not keep pushing forward in a broken state.

### 2) Execution Model (Parallelize, Keep Context Clean)

1. **Subagent strategy**
   - Use subagents liberally to keep the main context clean.
   - Offload research, exploration, tradeoff analysis, and parallel debugging hypotheses.
   - One subagent = one task. No mixed missions.
   - For complex problems, allocate more compute rather than polluting the main thread.
2. **Autonomous problem solving**
   - Solve issues independently whenever possible.
   - If uncertain, raise the issue with recommended solution options and let the user choose.

### 3) Test-First Verification and Definition of Done

1. **Unit tests are mandatory**
   - Write unit tests for each feature and run them.
   - If tests pass: proceed.
   - If tests fail: fix and re-run until all tests pass.
2. **Never mark "done" without proof**
   - Run tests, inspect logs, demonstrate expected behavior.
   - Diff behavior between baseline and changes when relevant.
   - Staff-engineer bar: _Would a staff engineer sign off on this?_ If not, it's not done.
3. **Always test**
   - No feature ships without verification (unit tests minimum; integration/system tests when applicable).

### 4) Source Control Discipline (Progress Must Be Recoverable)

1. **Commit and push periodically**
   - Push to GitHub regularly to preserve progress and enable rollback.
   - Commits should be small enough to isolate cause/effect.
2. **Minimal impact changes**
   - Touch only what's necessary.
   - Avoid broad refactors unless explicitly planned and justified.

### 5) Logging, Reporting, and Operational Visibility

1. **Maintain dev logs (required)**
   - Log achievements, discoveries, and mistakes continuously in the project folder:
     - `devlog-YYYYMMDD.md` (e.g., `devlog-20260315.md`)
2. **Proactive reporting**
   - Report progress periodically without waiting to be asked:
     - what was done
     - what's next
     - blockers / risks
     - verification status (tests/logs)

### 6) Task Management (Checkable, Granular, Enforced)

1. **Plan first**
   - Write the plan to `tasks/todo.md` with checkable items and acceptance criteria.
2. **Verify plan before implementation**
   - Quick sanity check: scope, risks, test strategy.
3. **Track progress**
   - Mark items complete as you go; keep the list accurate.
4. **Explain changes**
   - Provide high-level summaries at meaningful steps (what changed, why).
5. **Document results**
   - Add a review section in `tasks/todo.md`:
     - tests run
     - outcomes
     - known limitations
6. **Capture lessons**
   - After any user correction, update `tasks/lessons.md` with a preventative rule to avoid repeating the mistake.
   - Review relevant lessons at session start.

### 7) Engineering Standards

1. **Simplicity first**
   - Minimal change, minimal surface area, minimal regression risk.
2. **No laziness**
   - Find root causes. Avoid temporary hacks unless explicitly triaged with a follow-up item.
3. **Demand elegance (balanced)**
   - For non-trivial changes: pause and consider a cleaner, more robust solution.
   - If a fix feels hacky: implement the correct design given current knowledge.
   - For small obvious fixes: do not over-engineer.
4. **Autonomous bug fixing**
   - For bug reports: diagnose, patch, verify, and report without hand-holding.
   - Anchor on evidence: logs, errors, failing tests, reproduction steps.
   - If CI fails: fix it without being told.

### Summary: Non-Negotiables

- Design + plan first (SDD + `tasks/todo.md`)
- GitHub repo for every project
- Tests written and passing before "done"
- Frequent commits/pushes
- Proactive devlog + progress reporting
- Lessons captured in `tasks/lessons.md`
- Minimal-impact changes, root-cause fixes, staff-engineer quality bar

## Hardware Platform

- **NVIDIA Jetson Orin 16GB** (JetPack 5, R35.6.0)
- **Hostname**: marcos
- **Tailscale IP**: 100.65.235.58
- **SSH**: `nvidia@100.65.235.58`
- **NVMe SSD**: 116GB total

## Architecture

```
Tailscale → marcos (100.65.235.58)
  → OpenClaw Gateway (:18789, loopback) → WebChat UI at /openclaw/webchat
  → Ollama (:11434) → Qwen3.5 9B Q8_0
```

## Services (systemd)

- `ollama.service` — LLM serving (port 11434)
- `openclaw-marcos.service` — OpenClaw gateway (port 18789)

## Key Paths (on marcos)

- `/home/nvidia/marcos-chat/` — Workspace (SOUL.md, IDENTITY.md, USER.md)
- `/home/nvidia/.openclaw/openclaw.json` — OpenClaw config
- `/etc/systemd/system/openclaw-marcos.service` — Service unit

## Common Tools & Environment

- **Node.js 22** — OpenClaw runtime
- **Ollama** — LLM serving
- **OpenClaw** — AI avatar framework
