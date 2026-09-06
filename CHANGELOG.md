# Changelog

Every published version is a line in `VERSION` (`date sha repo`). Installed copies see the newest one at the next start and offer `ai update`. Newest first.

## 2026-09-06 — first public beta

**One bundle, three devices.** Android/Termux, Linux/macOS/WSL2, Windows, all from one repo, one `ai`.

- Installers are staged and consent-first on every platform; manifest-based uninstall on PC; wizard with fit-check and back-navigation on Android.
- 18 experts, each with a persona and a knowledge base (sources dated), loaded by question.
- Provider ladder: local Ollama → free cloud tiers you keyed → keyless builtins → recipes → tool forge. Privacy scrub before any cloud call.
- `/attach` for files, PDFs and screenshots with preview; vision only through brains that can see.
- Chat-to-command rules ("agents dikhao", "go offline", "update yourself"); `/capabilities` reports what *this* install can do right now.
- Self-update: daily 60-byte version check, `ai update` / `ai setup` / `ai keys`, keys and memory always kept.
- Daemon (opt-in): awareness only, `AI_ATTENDED=0` blocks forging and shell.
- Telegram helper bot (`ai telegram`): fail-closed allowlist, fixed commands, `/feedback` to a local file, free-text off by default; `ai announce` posts to Telegram + a Discord webhook.
- Repo face: CI on three OSes, issue/feedback templates, SECURITY, docs site, WHY, COMMUNITY.
- `ai pair`: QR in the terminal (stdlib QR encoder, verified bit-for-bit against a reference), token-locked panel for any phone including iPhone, Tailscale preferred over LAN.
- Fixes found by running, not reading: crisis phrasing routed to no expert (now → margdarshak); unknown RAM was treated as low RAM; Windows crashed on `os.uname()`; Ollama's 4k default context pinned to 16k.

**Known gaps, stated:** Windows path verified only by CI, not on a physical machine yet; iOS is a thin-client path (see docs/ROADMAP.md); OS keychain for keys not yet used on PC; screen-read is Android-only (Shizuku); the floating fact-checker bubble is planned, not built.
