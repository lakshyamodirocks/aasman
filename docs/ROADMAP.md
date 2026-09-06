# Roadmap

Plain list, newest thinking first. "Done" means run and verified, not written. Items move only when a golden test or a device run proves them.

## Now (beta, 2026-09)

- [x] One bundle, three devices: Android/Termux · Linux/macOS/WSL2 · Windows
- [x] Staged, consent-first installers; manifest uninstall on PC; wizard with fit-check on Android
- [x] 18 experts with persona + knowledge base; question-matched loading
- [x] Privacy scrub before any cloud call; local brain gets raw text
- [x] `/attach` files, PDFs, screenshots with preview; vision only via seeing brains
- [x] Chat-to-command rules; `/capabilities`; self-update with a notice, never automatic
- [x] Daemon (opt-in), awareness only, unattended gate
- [x] CI on Linux, macOS, Windows: golden set + scripted install
- [x] Egress log, key-scrubbed child processes, `ai pair` (QR), `/capabilities`, Telegram helper bot

## Next

- [ ] **First physical Windows run** by a real user; fix whatever CI could not see
- [ ] **Keys in the OS keychain** (macOS `security`, Linux secret-service, Windows Credential Manager) instead of a `0600` file; on Android, `termux-keystore` wrapping with an auto-relock timer and a manual lock/unlock
- [ ] **Family profiles** on shared phones: a picker at start, per-profile memory, consent-based sharing between devices
- [x] **Telegram helper bot** (stdlib long-poll, fail-closed allowlist, never spawns a shell unattended) — shipped 2026-09-06
- [ ] **Fact-checker floater** on Android (Termux:Float + user-initiated OCR with pinned model files)
- [ ] `format_check.py` for publishing experts (deterministic caption/limit validator)
- [ ] Devanagari-script onboarding; screen-reader pass; localisation beyond Hindi

## iOS — thin client, local only, no server of ours (researched 2026-09-06)

- **Terminal:** a-Shell (App Store, free, BSD-3-Clause, real CPython 3.11). `ai.py` is stdlib-only, so it runs there without pip — a-Shell cannot install compiled Python packages, which is exactly the constraint we already design for.
- **Brain:** no iOS app today exposes a local model over HTTP that a script can call (PocketPal's local-server request is an open, unimplemented issue; Enchanted is a client). So on iOS "local only" honestly means **your own PC or Mac's Ollama** over your own network (LAN / Tailscale) — your hardware, not ours — or a free cloud key you own.
- **What will not work there:** the `/do` tool layer, voice, forge and anything that spawns a subprocess (17 call sites need Linux binaries a-Shell does not have). Core chat, memory, KB, experts: yes. No floater, no daemon, no screen-read.
- **Store rules:** Apple guideline 2.5.2 (downloaded code) — a-Shell and iSH survived 2020 takedown notices on appeal and remain listed; precedent, not a written carve-out. We will not ship an App Store app of our own until that is worth the risk.
- **Shipped instead (2026-09-06):** `ai pair` — the Mac/PC prints a QR, the iPhone scans it and gets that computer's full `ai` panel over Wi-Fi/Tailscale, token-locked. Your hardware, your network. The a-Shell path stays documented for people without a computer; both await a real-iPhone test.

## Never

- A server that sees your data
- Telemetry of any kind
- A dependency in `ai.py`
- An install step that does not ask

## How to influence this list

Open a **feedback** issue (template provided) or a Discussion. Feedback is read weekly, tagged by severity and sequence; the top rank gets immediate attention. Security findings go to a private advisory, see SECURITY.md.
