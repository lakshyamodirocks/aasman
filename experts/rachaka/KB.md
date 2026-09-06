# Rachaka — KB (Termux/Python/Bash coding reality)

> Base for a stdlib-first coder on a phone-class device. Every claim below is either read
> from this repo's own `termux/ai-termux.py` (cited by line-area) or the Termux wiki/GitHub
> (URL given). Nothing here is invented CLI syntax.

## 1. Bionic, not glibc — the #1 thing that breaks PyPI installs

Termux ships **Bionic libc** (Android's own), not glibc. `pip install X` pulls PyPI's
**manylinux** wheels, which are built against glibc — they simply don't run here.
- **Fails as a `pip` wheel, no Termux-native package either:** PyTorch (confirmed broken,
  `pytorch/pytorch#186521`), CTranslate2/faster-whisper (manylinux-only, no Termux build
  evidence), SpeechBrain/pyannote/Resemblyzer (all ride on PyTorch).
- **Fails as a bare `pip` wheel BUT has a native Termux `.deb`** — install via `pkg`, not
  `pip`: `python-torch`, `python-onnxruntime`, `python-ctranslate2`, `python-tflite-runtime`
  (all real packages at `packages.termux.dev/apt/termux-main/pool/main/p/`). **Caveat, not a
  green light:** these have a documented history of import-breaking after a `pkg upgrade`
  bumps a shared dep (abseil ABI skew killed `python-torch` twice — `termux-packages#20129`,
  `#21188`; onnxruntime broke on the Python 3.13 bump — `#28769`, fixed by `#28775`). Say
  "install it and test on THIS device" — never promise it imports cleanly from memory.
- **Pure C/C++ compiles clean, no wall at all:** whisper.cpp, vosk (Kaldi), llama.cpp,
  sherpa-onnx (per its own NDK build path) — these are the safe recommendation.
- Rule of thumb to give the user before writing any code that needs a library: *"does it
  ship a manylinux wheel, or is it plain C/C++?"* — answers 80% of "will this even install"
  before touching the repo. (`fold-node/research/cherry-pick/11-bionic-workarounds.md`,
  `06-voice-speaker-id.md`)

## 2. `pkg` vs `pip`, paths, storage

- `pkg install <name>` = Termux's own apt-based manager, pulls **Bionic-native** builds from
  `packages.termux.dev`. Always try this first for anything with C extensions.
- `pip install <name>` = PyPI, glibc-first. Fine for pure-Python packages (no compiled
  extension) — risky for anything with a compiled backend (numpy/scipy usually now have
  Termux-friendly wheels or build from source; assume nothing without testing).
- `$PREFIX` = `/data/data/com.termux/files/usr` (where `pkg`-installed binaries/libs live).
  `$HOME` = `/data/data/com.termux/files/home`. Never hardcode either — read the env var, or
  better, use `shutil.which()` / `sys.executable` (see §4).
- **No system `/tmp`.** Termux sets its own `$TMPDIR`; `mktemp` respects it correctly — use
  `mktemp` / `tempfile` module, never hardcode `/tmp/...`.
- `termux-setup-storage` — one-time command that requests the Android storage permission and
  symlinks `~/storage/{shared,dcim,downloads,music,pictures,movies}`. A script that touches
  files outside Termux's private app dir (e.g. saving to Downloads) must tell the user to run
  this first if the symlinks aren't there — don't assume they exist.
  (wiki.termux.com/wiki/Termux-setup-storage)

## 3. Two Termux-specific runtime gotchas a coder must plan around

- **Phantom Process Killer** (Android 12+): silently `SIGKILL`s a forked child process past a
  device-wide cap (default 32) — shows up as `[Process completed (signal 9) - press Enter]`
  with no visible cause. Not fixable from inside a plain script; the workaround needs
  `device_config put activity_manager max_phantom_processes ...` via ADB/Shizuku
  (`termux-app#2366`, discussion `#3387`). **Say this plainly if a script spawns many
  subprocesses and dies mysteriously — it's not the coder's bug.**
- **Wake-lock**: `termux-wake-lock` (needs Termux:API) stops Android's Doze from suspending
  a long-running background script; `termux-wake-unlock` releases it. Any script meant to run
  more than a few seconds in the background should call this and unlock in a `finally`/trap.

## 4. Shebang lines — the exact bug this repo already hit and fixed

Hardcoding `#!/data/data/com.termux/files/usr/bin/python3` breaks the moment the same script
runs on a non-Termux host (the project's Debian VM node) — `ENOEXEC`. The fix already in
`ai-termux.py` (`_shebang()`): use `sys.executable` (falls back to `shutil.which("python3")`)
for Python, `shutil.which("bash")` (falls back to `/bin/sh`) for shell. **Copy this pattern**,
don't hardcode the Termux path. After `chmod +x file`, `./file` runs it; put finished tools in
`~/.local/bin` to run by bare name.

## 5. Stdlib-only idiom sheet (no new pip/apt unless the user names it)

```python
import urllib.request, json, sqlite3, subprocess, argparse
# GET, no requests dep:
with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent":"x"}), timeout=30) as r:
    data = r.read()
# subprocess — ARGV LIST, never a shell string:
subprocess.run(["ffmpeg","-i",infile,outfile], capture_output=True, text=True, timeout=120)  # NOT shell=True
# sqlite3 + FTS5 (already stdlib in Termux's python3, zero install) for search/memory:
con = sqlite3.connect(dbpath)
con.execute("CREATE VIRTUAL TABLE IF NOT EXISTS docs USING fts5(body)")
con.execute("INSERT INTO docs(body) VALUES (?)", (text,))
rows = con.execute("SELECT body FROM docs WHERE docs MATCH ? LIMIT 5", (query,)).fetchall()
# argparse for any script taking flags:
p = argparse.ArgumentParser(); p.add_argument("file"); p.add_argument("--out", default=None)
```
Never `shell=True`, never build a command by string-concatenation-then-`os.system`.

## 6. The harness's OWN safety gate — what the coder must never trigger

Read directly from `termux/ai-termux.py` (`_risky()` line ~1544, `permit()` line ~1973):
- **`_risky(code)`** AST-scans any freshly generated tool BEFORE it's written or registered.
  It flags (not by string spelling, by resolved import binding — `import x as y` counts too):
  dangerous imports (`socket, ftplib, smtplib, pickle, marshal, multiprocessing, requests,
  paramiko, ctypes, pty`), dangerous calls (`eval, exec, compile, __import__, getattr/setattr`
  used to dodge the scan), `os.system/remove/chmod/chown/execv/kill`, `shutil.rmtree/move`,
  `open(..., "w"/"a"/"x")`, **`subprocess` with `shell=True`**, and touching sensitive paths
  (`.ai-env`, `.termux/boot`, `/etc/`, `authorized_keys`, `.bashrc`, `id_rsa`) or reading
  `os.environ`/`getenv` (how secrets leave). A flagged tool is **saved but never auto-run or
  auto-registered** — it needs a human `y/N` before it executes even once.
- **`permit(cap, args)`** is the separate, second gate: even a clean tool's *arguments* are
  typed and bounded (`DEFAULT_SCHEMA` = plain bounded strings, no flags) before they become an
  argv — a model never gets to hand-build a shell command, ever; there is no shell in this
  path at all, only a constructed argv list.
- **What this means for Rachaka in practice:** never write `shell=True`, never pipe
  `curl|sh`, never `eval`/`exec` user input, never read `.ai-env`/API keys into a script
  "to test it," never suggest `rm -rf` or `chmod 777` without naming the risk first — these
  are exactly the patterns the harness's own code-scanner exists to catch, so writing them
  even once undermines the trust boundary this whole product is built on.

## 7. Testing before claiming — behavioural, not presence

Code that "looks right" is not code that "works." The harness enforces this structurally:
a forged tool that trips `_risky()` is held for review, never auto-run. Rachaka must mirror
that discipline in words: say **"untested"** rather than "this works," and for anything past
one function/file, say the task is bigger than a first-responder small model and stop
guessing at scale — the runtime's own brain-router already escalates harder code questions to
a cloud model when online; Rachaka is the honest offline fallback, not a senior engineer.

## 8. No-dead-end ladder for "make me a tool" (from `ai-termux.py` `RUNGS`)

1. Provider already installed / key set → use it directly.
2. Builtin (stdlib, no key, offline-safe) → e.g. `webget`, `ddg_builtin`.
3. Manual recipe → exact copy-pasteable steps for this device (see `RECIPES` dict).
4. Brain (best text-form answer) → explain/write the pattern in words.
5. **Forge** → `/tool <name> <desc>` (`gen_tool()`) writes a stdlib script, scans it with
   `_risky()`, and only runs it after a clean scan or an explicit y/N on a flagged one.

## 9. Sources
- `fold-node/termux/ai-termux.py` (`_risky`, `permit`, `_shebang`, `gen_tool`, `RUNGS`, `RECIPES`)
- `fold-node/termux/SCRIPTING-101.md`
- `fold-node/research/cherry-pick/11-bionic-workarounds.md`
- `fold-node/research/round2/A-permission-ladder.md` (Phantom Process Killer, §2 table)
- https://github.com/pytorch/pytorch/issues/186521 · https://github.com/termux/termux-packages/issues/20129 · /issues/28769
- https://github.com/termux/termux-app/issues/2366 · discussion #3387 (Phantom Process Killer)
- https://wiki.termux.com/wiki/Termux-setup-storage · https://wiki.termux.com/wiki/Differences_from_Linux
