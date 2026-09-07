# Aasmaan (आसमान)

[![ci](https://github.com/lakshyamodirocks/aasman/actions/workflows/ci.yml/badge.svg)](https://github.com/lakshyamodirocks/aasman/actions/workflows/ci.yml) · [Site](https://lakshyamodirocks.github.io/aasman/) · [How it works](docs/ARCHITECTURE.md) · [Trust](docs/TRUST.md) · [FAQ](docs/FAQ.md) · [Roadmap](docs/ROADMAP.md) · [Hands](docs/HANDS.md) · [Pairing](docs/PAIRING.md) · [Every switch](docs/FLAGS.md) · [Security](SECURITY.md) · [Changelog](CHANGELOG.md)

**Free AI on your own device — phone or PC. One program, one file. No account needed. Your data stays with you.**

Aasmaan is one Python program (`ai.py`, ~6,350 lines, stdlib only, read it in any editor — see *Why one file* below) plus 19 expert "packs" (plain Markdown: 18 specialists and one for the product itself, generated from these docs at build so it can explain itself offline), a small web panel, and the installers. It runs a local model through Ollama and, only if *you* add a key, free cloud tiers. No telemetry. No server. Nothing phones home. The **same `ai`** runs on Android (Termux), Linux, macOS and Windows; the installer adapts to the device instead of asking the device to adapt to it.

## Install — one command per device

**Android (Termux)** — install **Termux from F-Droid** ([f-droid.org/packages/com.termux](https://f-droid.org/packages/com.termux/) — the Play Store build is old and broken; F-Droid is a free store for open-source apps, install it from [f-droid.org](https://f-droid.org/)), open Termux, then:
```bash
(apt update || { echo "deb https://packages-cf.termux.dev/apt/termux-main stable main" > "$PREFIX/etc/apt/sources.list"; apt update; }) && apt -y -o Dpkg::Options::=--force-confnew full-upgrade && apt -y install curl python && curl -fsSL https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.sh | bash || echo "Aasmaan: install ruk gaya - upar ki aakhri 10 lines ka screenshot bhejo (docs/FAQ.md)"
```
One line, zero dialogs: it picks a working mirror by itself if Termux has none set, upgrades the base packages, installs curl and python, then runs the installer; if anything stops, the last line tells you what to send. The upgrade first is not optional, and it is `apt`, not `pkg`: a fresh Termux ships a `curl` that fails with a libcurl/SSL symbol error until the base packages are upgraded, and `pkg` itself calls that broken curl to pick a mirror, so `pkg upgrade` dies the same way (both seen on a Moto, 2026-09-06). `apt` fetches with its own code. If `apt update` stops with a *mirror / unable to resolve* error, run `termux-change-repo` (Enter, Enter) and paste the command again.
You get: setup wizard (you pick RAM/battery/model, with a fit-check, back-navigation, nothing forced) → 7-stage phone installer → `setup-menu` (press **G**) for free keys, voice, tools. Optional add-ons from the same F-Droid source unlock more: [**Termux:API**](https://f-droid.org/packages/com.termux.api/) (mic, TTS, notifications), [**Termux:Boot**](https://f-droid.org/packages/com.termux.boot/) (start on reboot), [**Termux:Float**](https://f-droid.org/packages/com.termux.window/) (floating window; the fact-checker bubble is planned), [**Shizuku**](https://shizuku.rikka.app/) (screen-read, no root). Each is asked for, never assumed.

**Linux / macOS / WSL2** (needs `python3`, and `curl` or `wget`):
```bash
curl -fsSL https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.sh | bash
```
No `curl` (minimal Debian/Ubuntu ships neither)? Same script through wget: `wget -qO- https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.sh | bash`. On a fresh Mac, `python3` is Apple's stub until you run `xcode-select --install` once; the installer says so instead of hanging on the dialog.

**Windows 10/11** (PowerShell, normal user, no admin):
```powershell
irm https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.ps1 | iex
```

Every installer is **staged**: it shows your device first (RAM, GPU, Python, Ollama), then asks before each step. `Enter` = do it, `s` = skip, `q` = stop (what's done stays done; run again to continue). Nothing installs silently. If the GitHub archive download is blocked on your network, the bootstrap falls back to `git`, then to fetching files one by one.

## Without a key, without a model — what still works

The first thing a new user types is arithmetic, a date, or a conversion. Those never reach a brain: a rung-0 layer answers `2+2`, `15% of 4200`, `date`, `time in Tokyo`, `30 days from today`, `age 16 Nov 1994`, `days until 25 Dec`, `5 km in miles`, `100 f to c`, `2 gb in mb`, `b64 …`, `sha256 …`, `uuid`, `json …`, `pw 20` (never written to the journal), `wa <number>: <text>` / `upi <vpa> <amount>` / `qr <text>` link and QR makers, `emi` / `sip` / `lumpsum` (formula shown, calculator-only wording, no advice), and with net but no key `mausam Jaipur` (Open-Meteo, attribution printed). The calculator walks an allow-listed syntax tree — never `eval`. `ai tour` runs six of these for real in a minute. Then: keyless web search, scraping and images, the 18 expert packs, memory and KB, and every device hand — all without an account.

## What each device gets

| | Android / Termux | Linux · macOS | Windows |
|---|---|---|---|
| `ai` chat, 19 experts, memory, `/do` tools, keyless web | ✓ | ✓ | ✓ |
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

What each combination can and cannot do — including why the panel never controls the phone in your hand, the HTTPS rung with Tailscale, and safety per cell: [docs/PAIRING.md](docs/PAIRING.md).

## Voice — push-to-talk, the same rules as chat

`v` (or `/voice`) listens once, then treats the words exactly like typed chat: stop-words first, device hands, plain-word commands, then the brain, and it speaks the answer one sentence at a time so "ruk" lands after the current sentence. Safe commands run at once; non-destructive ones ask *by voice* and take a spoken haan/nahi (silence is no); the destructive tier (`/quit /clear /keys /update /setup /net /bg ! /run /serve`) always needs a typed yes, because a mis-heard Hindi word through an English recogniser is a real failure mode. No wake word, no always-on mic. Transcripts are not written to the journal unless `/voice log on`. Engines are whatever the device has: Android TTS or the setup-menu's kokoro/piper wrapper (and Google STT, which is English-only there; offline Hindi = whisper via setup-menu), `say` on macOS (Hindi voice Lekha if installed), `spd-say`/`espeak-ng` on Linux, System.Speech on Windows, piper anywhere with a model. `ai voice notify` pins a bol/ruk notification on Android. `/voice off` closes everything, including the panel's mic endpoint.

## Language — English by default, yours after that

The installer's first question is the language (Enter keeps English). Never picked? `ai` mirrors what you type: when two of your last three messages are Hinglish it switches and says so; `/lang en|hinglish|hi|auto` pins or releases it; the choice lives in `~/.ai-setup-profile` as `AI_LANG`. The model answers in that language, with command names, paths and flags untouched. Honest scope: about twenty of the visible UI strings exist in English and Hinglish; the rest are Hinglish for now. Devanagari (`hi`) applies to the model's answers, not installer text, because Windows consoles cannot shape it. Detection is deterministic and stdlib (script block wins, else Hinglish marker words); Marathi and Nepali are read as Hindi by script and are not advertised.

## Models and connectors — what attaches by itself

Whatever you download attaches by discovery, not by editing files. **Ollama models:** `ai` reads what Ollama has and files each model as chat, vision or embedding by its tag; roles you did not set attach at start (a vision model makes `/attach shot.png` work, an embedding model turns memory search semantic) and it says so once; a pinned model that is not installed falls back to one that is, with the `ollama pull` line. `/models` shows the picture; `/model <name>` warns if the name is not installed. **Any OpenAI-compatible server** (LM Studio, llama.cpp server, Jan, vLLM, a gateway): `ai connect http://localhost:1234` lists its models and adds it as a brain; a loopback or private address is treated as local (raw text, first in line, still works with `/net off`), a remote one as cloud (redacted first). **MCP servers** (streamable-HTTP or stdio): `/mcp add <name> <url|command> cap=<capability> tool=<tool>` makes a `/do <capability>` rung; your text is sent as one JSON argument, never a shell; attended only; results are data. **Voice engines** (whisper, piper, kokoro, `say`, espeak) attach by being on PATH. What "tuning" means here: routing by question profile, aliveness and cooldowns, context by RAM tier, exemplars learned from runs that worked, the answer cache. Model weights are never touched; there is no on-device fine-tuning, and nothing here pretends otherwise.

## Connectors — found, suggested, added, or forged

A vetted catalogue ships as data (`connectors.json`): only servers with a permissive licence that need no browser login, each with what leaves the device, the install line for your platform, and its tier (official reference server · vetted single-purpose · touches a real account, with a warning). `/mcp find pdf`, `/mcp find business`, or plain words ("pdf ka connector chahiye", "connect google sheets") show the fit and the exact `/mcp add` line; the installer's use-case orders the suggestions and `ai` names them once at start. Services that need your own account stay options, never dead ends: `/mcp setup notion` (or Google Calendar, GitHub, Gmail, Todoist, Spotify, Home Assistant) first shows an awareness card (which account, what leaves the device and to whom, that it is free, how many steps), does nothing without your yes, then walks the numbered steps Enter by Enter, takes the token hidden into `~/.ai-env`, prints the install line for you to run, and finally verifies with one read-only call, naming the fix when it fails. Where a browser login is needed, the connector itself opens it in your browser; this program never sees the login page. The connector's process receives only its own credential, never your other keys. Every login entry was vetted against the server's own docs and LICENSE file (research in the monorepo, 2026-09-06); the card says so, and says when we have not yet run it end to end. Only Canva, Google Photos and WhatsApp remain without a path today, each with the honest reason and its local alternative. Nothing installs itself; a folder-scoped connector never gets your whole home. When the catalogue has nothing, `/mcp forge <what it should do>` has a brain fill one function inside a fixed stdio MCP skeleton, scans it, previews it, and registers it only if clean. Shopping and todo lists are built in (`/list`, "shopping list me doodh") because no trustworthy server existed for them. A daily greeting is one toggle away (`/greet on`, default 10:00, `/greet at 07:30`): your name, the day, the weather if you name a city, today's reminders, your lists and one tip, composed on the device, one brain sentence only if a brain is reachable; delivered when `ai` starts or by `ai daemon` as a notification, spoken when voice is on. Off by default.

## The tuning layer — the harness is what is tuned

Every knob is a number per model tier (tiny ≤2.5B, small, mid, large, cloud), read off the brain that will answer: persona budget, KB budget, exemplar count, answer cap, plan depth; plus routing thresholds (when a brain is demoted, what counts as a short or a deep question). `/tuning` shows the active tier and every knob; `~/.ai-tuning.json` overrides numbers only, so research can retune an install without touching code, and anything that is not a number is ignored by name. `/usage` reports the real token counts the brains return (Ollama, OpenAI-shaped, Gemini), per brain per day, and says when the local brain would have been enough. `/plan <goal>` is the in-harness orchestrator: rung-0 tools, hands and self-intents resolve without a brain; the rest becomes a small JSON plan whose steps can only be an expert, a `/do` capability, a device hand, a plain question or an arithmetic line, shown and confirmed before anything runs, attended only. The installer's one question ("mostly for?") becomes `AI_USE` and only orders suggestions.

## Hands — your device, by plain words

`awaaz 30`, `pause`, `next song`, `battery`, `say hello`, `copy: some text`, `torch on`, `screenshot le`, `alarm 6:30 baje`, `timer 10 min chai`, `remind me at 10:30 chai`, `meeting daal do 3 pm: dentist` — in chat, by voice, or `/hand <id>`. The terminal itself is measured too (`/term`): which program, what it can push and pull, and how many cells each glyph really takes — so on a console that cannot draw ✓ or │ the harness falls back to plain text instead of printing boxes. Four colour-theory themes ship (`/theme light|dark|nerd|aasmaan`) with the contrast ratio measured in code; a theme applies to the session by default and only writes your terminal's config when you say `save`, after one backup, with `/theme undo` to put it back. Alarms, timers, reminders and calendar events use the OS's own apps on each platform (Android Clock/Calendar through intents, Reminders.app, Task Scheduler, systemd timers), and `/remind` is the floor under them: one store on every platform that fires while `ai` is open or through `ai daemon`, with a notification and, with voice on, aloud. `/hands` lists what **this** device can do right now and why the rest is hidden (Termux:API, Shizuku, a desktop session). `/stop` (or "ruk") is the brake; `/undo` puts a state back. Every hand is a code-owned template with typed parameters, a risk letter, and an undo or a stop; free text never enters a script; the daemon may only use read-only hands. What ships per platform, and what the OS does not allow (screen cast, for one): [docs/HANDS.md](docs/HANDS.md).

## What it touches — the full list

| What | Where | Why |
|---|---|---|
| `ai.py` + a launcher | Windows: `%LOCALAPPDATA%\Aasmaan\` · Linux/macOS/Termux: `~/.local/bin/ai` | the program |
| experts + packs | `~/.ai-experts.json`, `~/.ai-experts/` | 18 specialists + `aasmaan`, the product explaining itself |
| tool router, panel | `~/.ai-tools.json`, `~/.ai-panel.html` | `/do` routing, `ai serve` |
| keys (optional) | `~/.ai-env`, readable only by you | cloud brains you *chose* to add |
| memory | `~/ai-vault/` | your notes and recall, plain files |
| PATH | Windows: one folder in **user** PATH, only if you press Enter · Linux/macOS: **never edited** — the line is shown, you add it · Termux: `~/.bashrc` gets the PATH line only | so `ai` runs by name |

**Never on a PC:** `sudo`/admin · `pip install` · editing `.bashrc`/`.zshrc` · touching your existing Ollama models · background services of its own without asking · analytics of any kind (anywhere).

**On Android, the phone installer asks stage by stage and writes more:** Termux packages via `pkg` and a few Python packages via `pip` (inside Termux only; your phone's photos and apps are untouched), a PATH line in Termux's `~/.bashrc`, an optional wake-lock and boot autostart (so `ai` survives Android's background killer), and an **optional** security-tools stage (nmap, nikto, sqlmap and friends, ~600 MB, for the OSINT expert) that you can skip with `s`. Undo everything with `cleanup.sh --uninstall`, or uninstall the Termux app.

The last stage of every installer asks whether you want a **shortcut** where your OS keeps the things you open (a Termux:Widget script on Android, a `.desktop` entry on Linux, an `.app` on macOS, Desktop + Start Menu `.lnk` on Windows) — Enter creates it, `s` skips, and the card says honestly where a program may pin (GNOME: yes · macOS Dock: asks · Windows taskbar and Android home screen: no API, the manual step is printed). `ai shortcut rm` reverses it; uninstall does that first.

On Linux/macOS/Windows everything installed is listed in a manifest and **uninstall removes exactly that list** (and asks about runtime files). On Android, `cleanup.sh --uninstall` removes a fixed list of what the phone installer writes (dry-run first). Your keys file and your vault are deliberately left for you:
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

Ollama itself is installed **by you**, from Ollama's own installer (the script prints the official command: `winget install Ollama.Ollama` / `brew install ollama` / Ollama's Linux script / `pkg install ollama` on Termux). If you already have Ollama, it is reused, models untouched. Context is set by RAM tier (4k on small machines, up to 32k) because Ollama's default 4k is too small for code; `AI_LOCAL_CTX` pins it.

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

- **Runs and is gated on Linux**: a gate of scripted installs from this exact bundle, uninstall, and a golden set of 146 pinned behaviours (`tests/golden.py`) and an adversarial set of 10 trust invariants proven by attack (`tests/adversarial.py`). CI repeats golden + adversarial + install (see `.github/workflows/ci.yml`) on Linux, macOS and Windows; the badge at the top is the live answer.
- **Android/Termux**: the install path is replayed in tests from this exact bundle; Ollama + local models ran on the maintainer's phone in earlier sessions. whisper.cpp / Piper voice are offered by `setup-menu` and are being verified device by device.
- **Windows**: verified by CI only; no physical Windows machine yet. Your first run is a real test — please report.
- **Hands** (device control): engine and rules are pinned by tests on Linux; the macOS and Windows hands are built from vendor documentation and not yet run on a physical machine — `/hands` marks the unverified ones.
- **Shipped**: the one-file harness, provider ladder, privacy scrub, `/trust` card + threat model + adversarial suite, 19/19 expert packs (incl. the self-KB), memory + KB, `/do` ladder with tool forge and safety scan, `/attach` with vision, chat-to-command, `/capabilities`, self-update, daemon, Telegram helper bot.
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
ai tour                               # 60 seconds: six things run for real on this device, no key needed
ai                                    # start (new terminal window after install)
2+2  ·  15% of 4200  ·  date  ·  time in Boston  ·  5 km in miles  ·  age 16 Nov 1994   # answered offline, before any brain
battery  ·  awaaz 30  ·  pause  ·  say hello  ·  /hands                                 # your device (docs/HANDS.md)
/agents                               # the 19 experts (* = full pack) · "kya ye offline chalta hai?" is answered from its own KB, even with no brain
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

## Trust — visible, proven, written down

`ai trust` (or `/trust`) prints one card from live state: which brain answers first (LOCAL, or CLOUD with scrubbed text), the network intent (0 none · 1 local · 2 only when you ask · 3 plus one daily version check), which cloud brains and connectors are wired, what it can read and write, whether the screen or mic are reachable, that nothing is ever sent for you, that the background daemon is read-only, and the last cloud call. It ends with the rule everything obeys: **data can never grant authority** — a webpage, a memory, an MCP reply or a voice line may suggest; you approve with a typed yes; code executes.

`ai doctor` checks the install itself — Python, the running file's sha, update state, device, disk, the local brain, keys and the permissions on the file that holds them, the vault, network mode, connectors, forged tools, voice, hands, the daemon — one line each, ✓/✗/○, with the exact fix under every ✗; it only reads. `/capabilities matrix` lists every single thing this install can do as one descriptor (class, risk letter, whether the unattended daemon may do it, what confirmation it needs, what network and credentials it touches) — the policy the gates already enforce, made explicit, and tested to match what the gates really do.

That rule is not a claim, it is tested as an attack. `tests/adversarial.py` (ten cases, run in the gate and from inside this bundle on every OS) tries to break it: a spawned process cannot read an API key, a forged tool that reads the environment or opens the network is flagged and left unregistered, a connector's server gets only its own credential, the unattended daemon refuses to write or forge, an MCP reply saying "add a connector" registers nothing, injected text never auto-executes, a memory note is context not a command, key-shaped strings are scrubbed before a log or a cloud brain sees them, and the paired door needs a token. [docs/THREAT-MODEL.md](docs/THREAT-MODEL.md) is the asset/threat/boundary/mitigation table for a security reviewer, with each defence pointing at the test that proves it — and the limits stated rather than hidden.

Read `ai.py`. Search it for `urllib.request` — every network call `ai` itself makes is there, and every one is either your local Ollama, a provider *you* keyed, or a keyless public endpoint you invoked with `/do`; `/egress` logs each one. A program `ai` runs for you (yt-dlp, an MCP server, ffmpeg) does its own network and is named separately when you add it. [docs/TRUST.md](docs/TRUST.md) lists exactly what leaves the device and what never does.

### Why one file

Reviewers ask why a ~6,200-line product is one Python file instead of a package. It is a choice, and it serves the trust story: one stdlib file is one thing you can read end to end, `ai version` is one sha256 you can compare with the repo, the installer embeds it whole, and there is no import tree or dependency to audit. The real cost is that module boundaries inside the file are discipline, not import walls — so the boundary that matters (data never becomes authority) is held by the adversarial suite instead: any change that weakens it fails the gate before it ships. The file is sectioned by concern (config → env/keys → network → providers/routing → memory/KB → tools → hands → voice → connectors → REPL), and a split into a package stays possible behind those tests; it is not the next step, proof is.

License: MIT (see `LICENSE`). Models have their own licenses (linked above). Ollama is a separate product under its own license. Made in Jaipur by Lakshya Sunderwani.
