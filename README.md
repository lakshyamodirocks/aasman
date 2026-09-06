# Aasmaan (आसमान)

[![ci](https://github.com/lakshyamodirocks/aasman/actions/workflows/ci.yml/badge.svg)](https://github.com/lakshyamodirocks/aasman/actions/workflows/ci.yml) · [Site](https://lakshyamodirocks.github.io/aasman/) · [How it works](docs/ARCHITECTURE.md) · [Trust](docs/TRUST.md) · [FAQ](docs/FAQ.md) · [Roadmap](docs/ROADMAP.md) · [Every switch](docs/FLAGS.md) · [Security](SECURITY.md) · [Changelog](CHANGELOG.md)

**Free AI on your own device — phone or PC. One program, one file. No account needed. Your data stays with you.**

Aasmaan is one Python program (`ai.py`, ~3,700 lines, stdlib only, read it in any editor) plus 18 expert "packs" (plain Markdown), a small web panel, and the installers. It runs a local model through Ollama and, only if *you* add a key, free cloud tiers. No telemetry. No server. Nothing phones home. The **same `ai`** runs on Android (Termux), Linux, macOS and Windows; the installer adapts to the device instead of asking the device to adapt to it.

## Install — one command per device

**Android (Termux)** — install **Termux from F-Droid** ([f-droid.org/packages/com.termux](https://f-droid.org/packages/com.termux/) — the Play Store build is old and broken; F-Droid is a free store for open-source apps, install it from [f-droid.org](https://f-droid.org/)), open Termux, then:
```bash
pkg install -y curl python && curl -fsSL https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.sh | bash
```
You get: setup wizard (you pick RAM/battery/model, with a fit-check, back-navigation, nothing forced) → 7-stage phone installer → `setup-menu` (press **G**) for free keys, voice, tools. Optional add-ons from the same F-Droid source unlock more: [**Termux:API**](https://f-droid.org/packages/com.termux.api/) (mic, TTS, notifications), [**Termux:Boot**](https://f-droid.org/packages/com.termux.boot/) (start on reboot), [**Termux:Float**](https://f-droid.org/packages/com.termux.window/) (floating window; the fact-checker bubble is planned), [**Shizuku**](https://shizuku.rikka.app/) (screen-read, no root). Each is asked for, never assumed.

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
| voice in/out | ✓ Termux:API; whisper.cpp + Piper via `setup-menu` (being verified) | `say` on macOS, espeak on Linux | via PowerShell TTS (recipe) |
| screen-read (Shizuku, no root) | ✓ via `setup-menu` | — | — |
| floating fact-checker bubble | planned (Termux:Float) | — | — |
| daemon (awareness only) | `ai daemon` in tmux / Termux:Boot | systemd --user / LaunchAgent (opt-in) | Task Scheduler (opt-in) |
| uninstall | `cleanup.sh` (dry-run first) | `pc-setup.sh --uninstall` (manifest) | `$env:AI_UNINSTALL=1; irm … \| iex` |

| **phone ↔ computer pairing** (`ai pair`, QR) | phone side: any browser | host side ✓ | host side ✓ |

## Pair your phone with your computer — iPhone included

Most people with an iPhone also have a Mac or a PC. Run this on the computer:
```
ai pair
```
It prints a QR code in the terminal. Scan it with the phone's camera: the phone opens the web panel of **that** computer's `ai` — its local model, its memory, its experts — over your own Wi-Fi or Tailscale. No server of ours, no account, nothing leaves your two devices. On iPhone: Safari → Share → **Add to Home Screen** and it behaves like an app (the icon keeps the pairing token). On Android: Chrome → ⋮ → **Add to Home screen** (a shortcut; plain http cannot "install" a PWA). The QR carries a one-time-generated token (kept in `~/.ai-env`, revoke with `ai keys rm AI_SERVE_TOKEN`); the panel refuses every call without it. Plain Wi-Fi http is unencrypted, so for use outside your home install Tailscale on both devices and `ai pair` will prefer it automatically. Mac: `caffeinate -i ai pair` keeps it awake with the lid closed.

## What it touches — the full list

| What | Where | Why |
|---|---|---|
| `ai.py` + a launcher | Windows: `%LOCALAPPDATA%\Aasmaan\` · Linux/macOS/Termux: `~/.local/bin/ai` | the program |
| experts + packs | `~/.ai-experts.json`, `~/.ai-experts/` | the 18 specialists |
| tool router, panel | `~/.ai-tools.json`, `~/.ai-panel.html` | `/do` routing, `ai serve` |
| keys (optional) | `~/.ai-env`, readable only by you | cloud brains you *chose* to add |
| memory | `~/ai-vault/` | your notes and recall, plain files |
| PATH | Windows: one folder in **user** PATH, only if you press Enter · Linux/macOS: **never edited** — the line is shown, you add it · Termux: `~/.bashrc` gets the PATH line only | so `ai` runs by name |

**Never on a PC:** `sudo`/admin · `pip install` · editing `.bashrc`/`.zshrc` · touching your existing Ollama models · background services of its own without asking · analytics of any kind (anywhere).

**On Android, the phone installer asks stage by stage and writes more:** Termux packages via `pkg` and a few Python packages via `pip` (inside Termux only; your phone's photos and apps are untouched), a PATH line in Termux's `~/.bashrc`, an optional wake-lock and boot autostart (so `ai` survives Android's background killer), and an **optional** security-tools stage (nmap, nikto, sqlmap and friends, ~600 MB, for the OSINT expert) that you can skip with `s`. Undo everything with `cleanup.sh --uninstall`, or uninstall the Termux app.

Everything installed is listed in a manifest. **Uninstall removes exactly that list** (and asks about runtime files); your keys file and your vault are deliberately left for you:
```powershell
$env:AI_UNINSTALL=1; irm https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.ps1 | iex   # Windows
```
```bash
bash ~/.local/share/aasmaan/app/pc-setup.sh --uninstall      # Linux / macOS
bash ~/.local/share/aasmaan/app/cleanup.sh --uninstall       # Android / Termux (keys, memory, backup stay)
```

## Local model — adapts to your hardware, never depends on it

The installer picks a **coding model** for what you have (sizes are the download; licences: Apache-2.0 except `qwen2.5-coder:3b`, which is under the Qwen Research licence — fine for personal use, check it before commercial use):

| Your machine | Model | Download |
|---|---|---|
| 4 GB RAM, no GPU | qwen2.5-coder:1.5b | 1 GB |
| 8 GB RAM, no GPU | qwen2.5-coder:3b | 1.9 GB |
| 16 GB RAM, no GPU · or 6–8 GB VRAM · or Apple M-series 16 GB | qwen2.5-coder:7b | 4.7 GB |
| 12 GB VRAM | qwen2.5-coder:14b | 9 GB |
| 16–24 GB VRAM | qwen2.5-coder:32b | 20 GB |
| 32 GB+ RAM or Apple 32 GB | qwen3-coder:30b | 19 GB |

On Android the wizard offers `qwen3` sizes by RAM and shows the fit (weights + context + runtime) before you choose.

Ollama itself is installed **by you**, from Ollama's own installer (the script prints the official command: `winget install Ollama.Ollama` / `brew install ollama` / Ollama's Linux script / `pkg install ollama` on Termux). If you already have Ollama, it is reused, models untouched. Context is pinned to 16k on PCs because Ollama's default 4k is too small for code.

Low RAM and no GPU? The install still completes: you get memory, knowledge base, and keyless tools; add a free cloud key later if you want a brain.

## What to expect, honestly

- **Good on a 7B–14B local model:** write a function, fix a traceback, explain an algorithm, write a test, small scripts, "which is faster".
- **Not this tool:** whole-repo refactors, multi-file agentic edits. That is Claude Code / Codex territory; Aasmaan is a single file that hosts brains, it does not pretend to be one.
- **On a phone:** a 4B model on 8 GB RAM is a helper, not a coder. The phone edition shines at voice, quick answers, memory, and tools; heavier code goes to a free cloud brain if you keyed one — or pair the phone with your computer and use its brain.
- **Never fakes results.** If a test did not run, it says so. Generated tools are scanned for destructive commands before they run, and anything flagged asks you first.

## Why this exists

Free AI keeps shrinking: free tiers get cut, logins get killed, projects relicense — we watched it happen more than once while building this. Meanwhile a huge number of people carry a genuinely capable phone, or have a laptop at home, and nothing beyond a chatbot's daily limit. Aasmaan is free AI for the device you already own — phone, laptop, or both paired together: not a lighter version of something bigger, the real thing — local where it can be, reaching free-tier clouds only when you choose to add a key.

Trust is the pitch, not a feature bolted on. The fear we heard most was "they'll steal my key." So nothing phones home, every network call is logged where you can read it, keys stay in a file only you can read, and the install adapts to your hardware instead of the other way around: a ₹8,000 phone or an old laptop gets a smaller brain, not a smaller product. It is built and actively maintained by one person in Jaipur who thinks across finance, NLP, coaching and tech, with a real feedback loop — when something goes stale, it gets fixed, not abandoned. Longer version: [docs/WHY.md](docs/WHY.md).

## Honest status (2026-09-06)

- **Runs and is gated on Linux**: a gate of scripted installs from this exact bundle, uninstall, and a golden set of pinned behaviours (`tests/golden.py`). CI repeats golden + install on Linux, macOS and Windows; the badge at the top is the live answer.
- **Android/Termux**: the install path is replayed in tests from this exact bundle; Ollama + local models ran on the maintainer's phone in earlier sessions. whisper.cpp / Piper voice are offered by `setup-menu` and are being verified device by device.
- **Windows**: verified by CI only; no physical Windows machine yet. Your first run is a real test — please report.
- **Shipped**: the one-file harness, provider ladder, privacy scrub, 18/18 expert packs, memory + KB, `/do` ladder with tool forge and safety scan, `/attach` with vision, chat-to-command, `/capabilities`, self-update, daemon, Telegram helper bot.
- **Planned, not built**: fact-checker floater, family profiles, key lock/unlock in the hardware keystore, speaker recognition, using your own ChatGPT/Claude subscription through the vendor's CLI (researched; Anthropic's terms block it, OpenAI's are grey), iOS thin client.
- Beta means worked on in the open. If a line here reads stale, that is the feedback loop's job: say so.

## What we built

- **One-file harness** — stdlib-only, the same program on four platforms; small enough to audit in an evening.
- **Provider ladder with cooldowns** — local Ollama → free tiers you keyed → keyless builtins (DuckDuckGo, scrape, Pollinations images) → a recipe for this device → the brain in text → forge a tool. A rate-limit is a cooldown, not a death; "no" is never the last answer.
- **Privacy router** — text bound for any cloud brain is scrubbed first: emails, phones, PAN/UPI/IFSC/account/Aadhaar-shaped numbers, API keys, private IPs, your home path, names you list. The local brain sees raw text and it never leaves.
- **18 experts in six groups** — CREATE (image prompts, music, video edit), PUBLISH (Instagram, YouTube, final checks), GROW (marketing, SEO, analytics), THINK (research-verify, writing, planning), BUILD (coding, UI/UX, voice), CARE (finance explain-only, coaching with a crisis protocol, self-OSINT). Each has a persona, refusals, honest weak spots on a small model, five Hinglish exemplars and a knowledge base with dated sources. `/agent auto <task>` picks; crisis phrasing always reaches the helpline protocol.
- **Memory on plain files** — `~/ai-vault`, keyword (BM25) search, hybrid if Ollama has an embedding model. Delete the folder, the memory is gone.
- **Voice** — Android: Termux:API mic/TTS today, whisper.cpp (speech-to-text) and Piper (Hindi text-to-speech) via `setup-menu`, native C/C++ so they survive where Python ML stacks cannot. macOS: `say` built in. Linux: `espeak-ng`. Windows: a PowerShell recipe. Speaker recognition planned.
- **`/attach` with vision, `/capabilities`, chat-to-command, self-update, daemon** — described below.
- **A test gate** — a golden set of pinned behaviours (scrub shapes, prompt fences, risky-code scanner, routing, packs, intents, vision refusal, unattended gate, daemon, Telegram bot, egress log) + scripted installs, on every change, in CI on three OSes.
- **Trust invariants in code** — keys never exported to child processes; no telemetry; unattended = no action; nothing runs without a visible yes.

## About the name

आसमान (Aasmaan) is the everyday Hindi and Urdu word for sky — the word a child and a grandparent both already know, tied to no religion or region. आकाश (Akasha) is the same sky in its older Sanskrit register. One word, two registers: Aasmaan is the plain, universal name for now; if this grows into a personal, sovereign AI, the natural step is not a rebrand but a name-elevation. Working name; domain and trademark not yet checked.

## Community

[Telegram group](https://t.me/+iF1WcRNqpAk0ODQ1) · [Discord](https://discord.gg/j8njkbbNY) — humans, questions, show-and-tell. Bugs and feedback go to GitHub issues so nothing is lost. The Telegram helper bot runs on the maintainer's own device (no server) and answers `/install`, `/faq`, `/version`, forwards `/feedback`; free-text answers are off by default. See [docs/COMMUNITY.md](docs/COMMUNITY.md).

## First 5 minutes

```
ai                                    # start (new terminal window after install)
/agents                               # the 18 experts (* = full pack)
/agent rachaka <paste your traceback> # coding expert
/ctx myfile.py                        # give it a file, then ask
/do research <question>               # keyless web search
/memory  ·  /kb <query>               # your own notes, offline
/capabilities                         # what THIS install can do right now
ai version                            # edition, python, sha256 of ai.py, update status
```

## Updates — you always press the button

When we publish a new version, `ai` notices (it fetches this repo's tiny `VERSION` file at most once a day, 3-second cap, opt out with `AI_UPDATE_CHECK=0`) and prints one line under its banner:

```
[ai] update available: 2026-09-10 a1b2c3d  (tera: 2026-09-06 54fb95a)
     chalao:  irm https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.ps1 | iex      ya yahin:  /update
```

Nothing installs by itself. Three ways to act, all confirmed with y/N and all keeping your keys and memory:

| You type | What happens |
|---|---|
| `/update` or `ai update` | shows the exact command, asks, runs it (fresh download + reinstall) |
| `/setup` or `ai setup` | re-runs the guided installer you saw the first time: add/change keys, pick a model, PATH |
| `/keys` · `/keys GROQ_API_KEY` · `/keys rm NAME` · `ai keys …` | list (masked), add (typing hidden), remove |
| in chat: "update yourself", "khud ko update kar lo", "setup chalao", "groq api key add karni hai" | the harness recognises it (plain rules, not the model), suggests the command, asks y/N |

`/version` (or `ai version`) prints edition, OS, Python, the SHA-256 of the running file and whether an update is available. The model itself is told the same facts every turn, so if you ask it "what version are you?" it answers from that, not from imagination.

## Files, screenshots, and "just tell it"

- **Attach a file:** `/attach error.log` (text, code, CSV) or `/attach report.pdf` (needs `pdftotext`). It shows a 6-line preview of what the model will see.
- **Attach a screenshot:** `/attach screenshot.png` (PNG/JPG/WEBP/GIF, ≤ 4 MB). It prints size and dimensions and **which brains can see it**. Images need a vision brain: Gemini (free key) or a local vision model (`ollama pull gemma3:4b`, then `AI_VISION_MODEL=gemma3:4b`). Without one it says so, it never answers blind. `/attach clear` drops them.
- **Web panel** (`ai serve`, then open the URL): the file button accepts images too, with an inline preview.
- **Plain words work as commands:** "agents dikhao", "go offline", "remember: office 10am", "what can you do", "search my notes for SIP", "update yourself". A fixed rule table maps them to `/commands` (the model never chooses); read-only ones run at once, anything that changes state asks y/N.
- **`/capabilities`** answers "what can this install do *right now*": which brains have keys and were alive at the last check, whether it can see images, the `/do` tools, experts, memory size, daemon status. The model gets the same line every turn, so it does not overclaim.

## Daemon (optional): awareness, not action

`ai daemon` (or the optional login service the installer offers) runs one pass every 30 minutes: update check, brain health ping, granting queued "wishes" that need no code generation, re-indexing your vault if it changed. It writes `~/.ai-daemon.json`; the next `ai` start prints one line from it and the model reads it as context. It runs with `AI_ATTENDED=0`, which hard-blocks tool forging and shell execution: an unattended process may look, never act. `ai daemon --once` runs a single pass.

## Free cloud brains (optional)

Groq, Cerebras, Gemini, OpenRouter all have free tiers. If a key is already in your environment (`GROQ_API_KEY` etc.), it is used and you are not asked again. New keys go to `~/.ai-env`, readable only by you, never exported to other programs. Text bound for a cloud brain is scrubbed first (emails, phones, IDs, keys, private IPs, names you list); the local brain sees raw text and never leaves the device.

## Feedback and bugs

This is a beta that is updated in place. Open a [bug or feedback issue](https://github.com/lakshyamodirocks/aasman/issues/new/choose) (templates ask for `ai version`; never paste a key), or start a [Discussion](https://github.com/lakshyamodirocks/aasman/discussions). Feedback is read weekly and tagged by severity; the top rank gets immediate attention. Security problems go to a [private advisory](https://github.com/lakshyamodirocks/aasman/security/advisories/new).

## Trust

Read `ai.py`. Search it for `urllib.request` — every network call is there, and every one is either your local Ollama, a provider *you* keyed, or a keyless public endpoint you invoked with `/do`. [docs/TRUST.md](docs/TRUST.md) lists exactly what leaves the device and what never does.

License: MIT (see `LICENSE`). Models have their own licenses (linked above). Ollama is a separate product under its own license. Made in Jaipur by Lakshya Sunderwani.
