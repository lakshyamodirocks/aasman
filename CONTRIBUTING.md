# Contributing

Aasmaan is one Python file plus Markdown. That is deliberate: anyone can read all of it in an evening, and every change is a diff a stranger can judge.

## The one rule

**A change is done when it was run, not when it was written.** Before you open a PR:

```bash
python tests/golden.py                 # pinned behaviours — no network, no keys, ~5 s
AI_YES=1 HOME=$(mktemp -d) bash pc-setup.sh    # scripted install into a throwaway HOME
```
On Windows: `$env:AI_YES=1; .\install.ps1`. CI repeats both on Linux, macOS and Windows.

## Where things are

| File | What |
|---|---|
| `ai.py` | the whole program: brains, privacy scrub, memory, `/do` ladder, experts, self-update, daemon |
| `experts.json` + `experts/<name>/{PERSONA,KB}.md` | the 18 specialists (voice · refusals · cheat-sheet · sources) |
| `tools-routing.json` | which provider/builtin handles each `/do` capability |
| `fold-all-setup.sh`, `setup-wizard.sh`, `setup-menu.sh` | Android/Termux install, wizard, guided keys/voice/tools |
| `pc-setup.sh`, `install.sh`, `install.ps1` | Linux/macOS/WSL and Windows install + bootstraps |
| `panel.html`, `whiteboard.html` | the optional web panel served by `ai serve` (the program runs fully without them) |
| `lib/ux.sh`, `lib/probe.sh` | staged-prompt helpers and hardware probes shared by the installers |
| `tests/golden.py` | the gate |
| `docs/` | the site (GitHub Pages) and plain-language docs |

## What we say yes to

- Fixes with a golden test that fails before and passes after.
- New expert packs (copy an existing `experts/<name>/` pair; 5 Hinglish exemplars; sources with dates).
- Translations of `docs/` and installer prompts.
- Recipes in `RECIPES_PC` / `RECIPES_TERMUX` for tools people actually have.

## What we say no to

- Any dependency. `ai.py` is stdlib-only because that is the only thing that runs on a phone (Bionic libc) and the only thing a stranger can audit.
- Telemetry, analytics, "anonymous" pings of any kind.
- An install step that runs without asking.
- Code that phones a server of ours. There is none, and there will be none.

## Language

Comments and prompts are in Hinglish where the user reads them, English where only developers do. Keep it that way; do not "clean up" Hinglish into English.
