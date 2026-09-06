# Aasmaan · PC edition

**Free AI on your own PC, for writing code and algorithms. One file. No account needed. Your data stays on your machine.**

Aasmaan is a single Python file (`ai.py`, ~3,000 lines, read it in Notepad) plus 18 small expert "packs" (plain Markdown). It talks to a local model through Ollama, and optionally to free cloud tiers if *you* choose to add a key. No telemetry. No server. Nothing phones home.

## Install — one command

**Windows 10/11** (PowerShell, normal user, no admin):
```powershell
irm https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.ps1 | iex
```

**Linux / macOS / WSL2** (needs `python3` and `curl`):
```bash
curl -fsSL https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.sh | bash
```

The installer is **staged**: it shows you your machine (RAM, GPU, Python, Ollama), then asks before each step. `Enter` = do it, `s` = skip, `q` = stop (what's done stays done; run again to continue). Nothing is installed silently.

## What it touches on your PC — the full list

| What | Where | Why |
|---|---|---|
| `ai.py` + a launcher | Windows: `%LOCALAPPDATA%\Aasmaan\` · Linux/macOS: `~/.local/bin/ai` | the program |
| experts + packs | `~/.ai-experts.json`, `~/.ai-experts/` | the 18 specialists |
| tool router, panel | `~/.ai-tools.json`, `~/.ai-panel.html` | `/do` routing, `ai serve` |
| keys (optional) | `~/.ai-env`, readable only by you | cloud brains you *chose* to add |
| memory | `~/ai-vault/` | your notes and recall, plain files |
| PATH | Windows: one folder in **user** PATH, only if you press Enter · Linux/macOS: **never edited** — the line is shown, you add it | so `ai` runs by name |

**Never:** `sudo`/admin · `pip install` · edits to `.bashrc`/`.zshrc` · touching your existing Ollama models · background services of its own · analytics of any kind.

Everything installed is listed in a manifest. **Uninstall removes exactly that list** (and asks about runtime files); your keys file and your vault are deliberately left for you:
```powershell
$env:AI_UNINSTALL=1; irm https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.ps1 | iex   # Windows
bash ~/.local/share/aasmaan/app/pc-setup.sh --uninstall                                          # Linux/macOS
```

## Local model — adapts to your hardware, never depends on it

The installer picks a **coding model** for what you have (all Apache-2.0; sizes are the download):

| Your machine | Model | Download |
|---|---|---|
| 4 GB RAM, no GPU | qwen2.5-coder:1.5b | 1 GB |
| 8 GB RAM, no GPU | qwen2.5-coder:3b | 1.9 GB |
| 16 GB RAM, no GPU · or 6–8 GB VRAM · or Apple M-series 16 GB | qwen2.5-coder:7b | 4.7 GB |
| 12 GB VRAM | qwen2.5-coder:14b | 9 GB |
| 16–24 GB VRAM | qwen2.5-coder:32b | 20 GB |
| 32 GB+ RAM or Apple 32 GB | qwen3-coder:30b | 19 GB |

Ollama itself is installed **by you**, from Ollama's own installer (the script prints the official command: `winget install Ollama.Ollama` / `brew install ollama` / Ollama's Linux script). If you already have Ollama, it is reused, models untouched. Context is pinned to 16k because Ollama's default 4k is too small for code.

Low RAM and no GPU? The install still completes: you get memory, knowledge base, and keyless tools; add a free cloud key later if you want a brain.

## What to expect, honestly

- **Good on a 7B–14B local model:** write a function, fix a traceback, explain an algorithm, write a test, small scripts, "which is faster".
- **Not this tool:** whole-repo refactors, multi-file agentic edits. That is Claude Code / Codex territory; Aasmaan is a single file that hosts brains, it does not pretend to be one.
- **Never fakes results.** If a test did not run, it says so. Generated tools are scanned for destructive commands before they run, and anything flagged asks you first.

## First 5 minutes

```
ai                                    # start (new terminal window after install)
/agents                               # the 18 experts (* = full pack)
/agent rachaka <paste your traceback> # coding expert
/ctx myfile.py                        # give it a file, then ask
/do research <question>               # keyless web search
/memory  ·  /kb <query>               # your own notes, offline
ai version                            # what is running: edition, python, sha256 of ai.py
```

## Updates — you always press the button

When we publish a new version, `ai` notices (it fetches this repo's 60-byte `VERSION` file at most once a day, 3-second cap, opt out with `AI_UPDATE_CHECK=0`) and prints one line under its banner:

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

Groq, Cerebras, Gemini, OpenRouter all have free tiers. If a key is already in your environment (`GROQ_API_KEY` etc.), it is used and you are not asked again. New keys go to `~/.ai-env`, readable only by you, never exported to other programs.

## Trust

Read `ai.py`. Search it for `urllib.request` — every network call is there, and every one is either your local Ollama, a provider *you* keyed, or a keyless public endpoint you invoked with `/do`. Report anything that surprises you: open an issue on this repo.

License: MIT (see `LICENSE`). Models have their own licenses (linked above). Ollama is a separate product under its own license.
