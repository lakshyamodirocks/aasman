# Aasmaan (आसमान)

**Free AI on your own device — phone or PC. One program, one file. No account needed. Your data stays with you.**

Aasmaan is a single Python file (`ai.py`, ~3,000 lines, read it in any editor) plus 18 small expert "packs" (plain Markdown). It runs a local model through Ollama and, only if *you* add a key, free cloud tiers. No telemetry. No server. Nothing phones home. The **same `ai`** runs on Android (Termux), Linux, macOS and Windows; the installer adapts to the device instead of asking the device to adapt to it.

## Install — one command per device

**Android (Termux)** — install **Termux from F-Droid** (the Play Store build is old and broken), open it, then:
```bash
pkg install -y curl python && curl -fsSL https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.sh | bash
```
You get: setup wizard (you pick RAM/battery/model, with a fit-check, back-navigation, nothing forced) → 7-stage phone installer → `setup-menu` (press **G**) for free keys, voice, tools. Optional add-ons from the same F-Droid source unlock more: **Termux:API** (mic, TTS, notifications), **Termux:Float** (floating bubble), **Shizuku** (screen-read, no root). Each is asked for, never assumed.

**Linux / macOS / WSL2** (needs `python3` and `curl`):
```bash
curl -fsSL https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.sh | bash
```

**Windows 10/11** (PowerShell, normal user, no admin):
```powershell
irm https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.ps1 | iex
```

Every installer is **staged**: it shows your device first (RAM, GPU, Python, Ollama), then asks before each step. `Enter` = do it, `s` = skip, `q` = stop (what's done stays done; run again to continue). Nothing installs silently. If the GitHub archive download is blocked on your network, the bootstrap falls back to `git`, then to fetching files one by one.

## What each device gets

| | Android / Termux | Linux · macOS | Windows |
|---|---|---|---|
| `ai` chat, 18 experts, memory, `/do` tools, keyless web | ✓ | ✓ | ✓ |
| local model (Ollama) | ✓ RAM-tiered, wizard picks | ✓ hardware-tiered | ✓ hardware-tiered |
| voice in/out | ✓ Termux:API / whisper.cpp / piper | `say` on macOS, espeak on Linux | via PowerShell TTS (recipe) |
| floating bubble, screen-read | ✓ Termux:Float, Shizuku | — | — |
| daemon (awareness only) | `ai daemon` in tmux / Termux:Boot | systemd --user / LaunchAgent (opt-in) | Task Scheduler (opt-in) |
| uninstall | `cleanup.sh` (dry-run first) | `pc-setup.sh --uninstall` (manifest) | `$env:AI_UNINSTALL=1; irm … \| iex` |

