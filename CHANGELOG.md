# Changelog

Every published version is a line in `VERSION` (`date sha repo`). Installed copies see the newest one at the next start and offer `ai update`. Newest first.

Changes ship as **impact radii**: one commit per concern, each entry names what it touched and what it deliberately did not, so a fix in one place cannot quietly break another. (How this works: CONTRIBUTING.md → "How changes ship".)

## 2026-09-07 · radius 40 — the look is asked, not hidden

Owner, Moto: "font theme kuch change nahi hui." Correct — radius 33's four palettes existed only behind `/theme`; no installer, wizard or card ever mentioned them, so a first-time user saw the terminal's default and nothing else.

- **Stage 8 is now "Look + shortcut (your call)"** on all three installers: `[Enter] aasmaan · 2 dark · 3 light · 4 nerd · n keep` → `ai theme <name> save` (Termux: `colors.properties` + reload, visible immediately; Windows Terminal: scheme + default; GNOME/Terminal.app via their hands; elsewhere the session layer and an honest line), one backup first, `ai theme undo` restores. Then the shortcut question, separately.
- **Font stays honest:** Termux owns its font (size = pinch, family = `~/.termux/font.ttf`); we do not ship or overwrite one. The stage says so instead of implying a font change.
- The first-start card's line 3 now names `/theme` next to `ai tour`.

Touched: fold-all-setup.sh, pc-setup.sh, install.ps1 (stage 8), ai.py (card line). Not touched: the palettes, the theme hands, stage count (8).

## 2026-09-07 · radius 39 — first launch talks: what this install has, for what you said you wanted

Owner, first run on the Moto after a clean install: typed `hello`, got "kisi brain ne jawab nahi diya — key nahi lagi"; and "onboarding me MCP, skills, agents, mere use case, API logins — kuch nahi bataya gaya." Both true. The wizard asked "what do you want?"; the product never answered with what it had.

- **A first-start card**, once: (1) an honest **brain status, measured** — local reachable / cloud key / none, and when none *why*: "wizard chose qwen3:4b but Ollama is not installed → setup-menu → brain", or "Ollama installed but not running → ollama serve &"; plus the 2-minute free-key path; (2) **for your use-case**: the experts (`code → rachaka, alankar, vyuh`), the keyless connectors (`/mcp add`), and the **login connectors through the guided path** (`/mcp setup github` — the key stays with that connector only); (3) `ai tour` and what works with no brain at all. Afterwards only the brain line, and only while there is no brain.
- **"hello" with no brain gets a human line by rule** — a salutation in your language, "no brain attached yet", the fix — never the provider failure dump. A real question still goes the normal way.
- Pinned: the card for `AI_USE=code` names `rachaka`, `github`, `/mcp setup`, `qwen3:4b`, `Ollama install nahi hua`, `ai tour`; shown once; English mirrors it; small talk without a brain never prints the dump.

Touched: ai.py (`brain_status`, `first_run_text`, `nobrain_smalltalk`, REPL start, chat loop), tests/golden.py (+2 pins → 146), docs/FAQ.md, README.
Not touched: the installer, the wizard, routing, hands.

## 2026-09-07 · radius 38 — the Shizuku stage is for the people who asked for it

Owner, Moto first run: stage 5 "Android ke haath (Shizuku)" appeared as a required stage for a user who never chose Shizuku, and its text ("rish NOT working — open the Shizuku app and Start it, then re-run") read like an error.

- Stage 5 now runs **only when the wizard's "phone controls (Shizuku)" was chosen**, and even then it is **optional** (`[s] skip`); everyone else sees one grey line ("wizard me OFF tha — skip; baad me setup-menu → S"). Without Shizuku it says calmly that nothing changes and how to add it later.
- The two plain helper scripts that lived there (`screen-dump`, `vault-backup` — files, no permissions) moved to the assets stage, so skipping Shizuku loses nothing.
- Same gate pattern as the pentest stage (`want SCREEN`): the wizard's answer decides, not the installer.

Touched: fold-all-setup.sh (stage 5 + assets stage). Not touched: stage count (8), the hands themselves, ai.py.

## 2026-09-07 · radius 37 — a required stage says so, and answers "no"

Owner, first run on the Moto: "isme no ka option nahi hai, ya hai to dikh nahi raha." Stage 1 (python · git · openssl) genuinely cannot be skipped — nothing after it runs without it — but the prompt showed only `[Enter] karo [?] kyun [q] ruk ja` and swallowed any other key in silence.

- Required stages now print **(zaroori — skip nahi)** / **(required — no skip)** on the prompt line; typing `n`, `s`, `no` or `skip` gets the reason ("aage ka sab isi pe chalta hai · Enter = karo · q = poora roko, aadha kuch nahi hota") instead of nothing; any other key gets "Enter, ? ya q".
- The **wake-lock is now its own question** inside stage 1 (`[Enter] on [n] nahi`), because that one *is* your call; without the Termux:API app it says so and moves on.
- Same `lib/ux.sh` serves the PC installer, so Linux/macOS required stages get the same line.

Touched: lib/ux.sh (`stage()`), fold-all-setup.sh (stage 1). Not touched: optional stages (`[s] skip` unchanged), stage count (8/8), ai.py.

## 2026-09-07 · radius 36 — the landing page passes a launch checklist it was never written for

Owner handed over a 20-item "vibecoded website launch checklist" (colour contrast, alt text, privacy, T&Cs, cookies, tracking, embeds, fake reviews, unsupported claims, real business details, accessibility…). Audited literally, item by item, measured not eyeballed (`fold-node/research/reviews/R9`): 5 pass, 7 honestly N/A (no forms, cookies, images, payments exist), 8 to fix — all fixed here:

- **Contrast:** the light-theme advisory banner was 3.8:1 (fails AA); now 14:1 (`--warn-fg`), dark unchanged at 10:1.
- **Unsupported claim removed:** "on 1 GB/month" had no evidence anywhere (R6 A4 had flagged it; still live). Deleted rather than replaced with an invented number.
- **Accessibility:** visible focus ring on links, a skip-to-content link, `<main id>`.
- **Real details + reach:** the footer names the maintainer with a link and two ways to reach him (issues, Telegram), and states plainly: no cookies, no analytics, no forms, nothing collected — by the page or the program.
- **Privacy findable:** the TRUST.md link now reads "Privacy & trust"; the footer points at it as the data statement (India DPDP: no personal data is processed by us, none is collected).

Touched: docs/index.html only. Not touched: README, installers, ai.py.

## 2026-09-07 · radius 35 — Android: one line, zero dialogs

Owner, testing as a first-time user on a fresh Moto: the old first line stopped at a blue `termux-change-repo` dialog asking about "mirror groups". "Ek esi single cmd bana jisse prerequisites pure ho jaye — ek basic person ke liye kafi ho; exception me hi debugging karni pade."

- The Android line now **sets a working mirror itself** when Termux has none (writes Termux's own Cloudflare mirror to `sources.list`, only if the first `apt update` fails), then upgrades, installs curl + python, runs the installer. No dialog, no `pkg`, no second command.
- **If it stops, the last line says what to send** ("install ruk gaya — upar ki aakhri 10 lines ka screenshot bhejo") instead of an apt error and silence.
- Same line in README, the landing page, the in-app `/setup` card and LAKSHYA-TODO; a gate now fails if the three copies drift (they had drifted once before).
- Verified in a shim (mirror fallback → upgrade → installer ran; total apt failure → the one message); the first real run is the owner's Moto.

Touched: README, docs/index.html, docs/FAQ.md, install.sh (header), ai.py (`/setup` card text), check.sh (+1 gate).
Not touched: the installer itself, `update_cmd` (installed systems already have a working curl check).

## 2026-09-07 · radius 34b — CI told the truth: three pins were wrong, not the code

The first CI run after radius 34 went live was red on all three OS (`golden · ubuntu/macos/windows`). Read before fixing:

- **greet (every OS):** the pin compared the first word of the salutation against `Suprabhat / Namaste / Shubh`, but a nameless test HOME prints `Suprabhat!` — bang glued to the word — so the pin only ever passed after 17:00 (`Shubh sandhya!` splits cleanly). Every earlier green run happened in the evening. Pin fixed; the greeting itself was right.
- **update_cmd on Termux (Windows only):** `update_cmd` checked `os.name == "nt"` before `IS_TERMUX`; the pin fakes Termux on every OS, so on Windows it got the PowerShell line. Order swapped (Termux is never `nt`, so behaviour is unchanged for real users).
- **doctor `~/.ai-env perms` (Windows only):** Windows `st_mode` has no owner-only bit, so "chmod 644 → ✗, chmod 600 → ✓" is not measurable there. `ai doctor` on Windows now says so honestly (`○ … install.ps1 restricts it with icacls; check yourself: icacls <path>`) instead of a false ✗; the pin asserts that row on Windows.

Touched: ai.py (`update_cmd` order, `_perm_ok`/doctor row on Windows), tests/golden.py (three pins).
Not touched: anything a user sees on Android/Linux/macOS.

## 2026-09-06 · radius 34 — the onboarding's last step: a shortcut where your OS keeps the things you open

Owner: "onboarding me last step — home screen pe shortcut, ya Windows/Linux/Mac ho to pin to taskbar bhi — OS ke hisaab se user ko poochho aur shortcut add kar do." Until now the install ended with "type `ai`"; a person who never opens a terminal on purpose needs the thing they tap.

- **One more stage, always asked, never assumed:** every installer (phone, Linux/macOS, Windows) now ends with *Shortcut + pin (your call)*; Enter creates it, `s` skips it, scripted runs (`AI_YES=1`, CI) never create one. It runs `ai shortcut add` — one implementation in the harness, the installers only ask.
- **Per OS, files only under your home, every path recorded** (`~/.ai-shortcuts.json`) so `ai shortcut rm` removes exactly them: Android → `~/.shortcuts/Aasmaan` + a PNG icon for the **Termux:Widget** app (F-Droid; the widget is the only way a terminal can reach the home screen — the exact tap sequence is printed) · Linux → `~/.local/share/applications/aasmaan.desktop` (Terminal=true) + an SVG icon, so the app menu finds it · macOS → `~/Applications/Aasmaan.app`, a launcher that opens Terminal.app and runs `ai` (Launchpad/Spotlight find it) · Windows → Desktop + Start Menu `.lnk` to `ai.cmd` (Start → type the name).
- **Pin only where the OS lets a program pin** — stated on the card before anything happens: GNOME dash favourites are set automatically (reversible, the previous list is saved); the macOS Dock asks first (`/shortcut pin`: `defaults write` + the Dock restarts; undo is dragging it off); **Windows and Android have no such API** — the card prints the right-click / long-press step instead of pretending. WSL says "no launcher here" and points to the Windows side.
- **Plain words:** "home screen pe shortcut banao", "add a desktop shortcut", "pin to taskbar", "shortcut hatao". A question about keyboard shortcuts never matches.
- **Uninstall reverses it first** (all three uninstallers run `ai shortcut rm` before removing `ai`), then removes the record.
- **Gate fix that rode along:** the golden set now isolates `USERPROFILE` on Windows as well as `HOME` (Windows' `expanduser` ignores `HOME`, so until now Windows CI pins wrote into the runner's real profile).
- **Honest limit:** macOS and Windows paths are written from documentation and CI, not yet a physical device — the `.app`/`.lnk` shapes are standard, the first real run is the first real test. No icon on macOS (an `.icns` needs a build step) or Windows (the console's own icon) yet.

Touched: ai.py (`shortcut_*`, `_shortcut_*`, `_png_icon`, hands rows `shortcut_add/pin/rm` on four platforms, `/shortcut`, `ai shortcut`, chat intent, HELP), tests/golden.py (+4 pins, Windows HOME isolation), pc-setup.sh + install.ps1 + fold-all-setup.sh (stage 8; totals 7→8), setup-wizard.sh (completeness line), the three uninstall lists, README, docs/FAQ.md, docs/HANDS.md.
Not touched: any other hand, themes, the model path, connectors.

## 2026-09-06 · radius 33 — four themes from colour theory, measured for contrast, applied without touching a config unless you say so

Owner: "har platform ke default interface ke liye premade 3–4 themes — light, dark, nerd, aasmaan — colour-theory palettes; push/pull capabilities alag rakho." A theme is the one thing people change first and the one thing a tool must never change behind their back.

- **Four palettes, each with a stated principle:** `light` (warm paper, cool ink, low-chroma accents), `dark` (neutral near-black, pastel accents at even lightness), `nerd` (phosphor green, amber as the single complementary call-to-action), `aasmaan` (analogous indigo → sky → teal, one complementary saffron). Each is 16 ANSI colours + background, text, cursor.
- **Contrast is measured, not claimed:** WCAG ratio in code — text ≥ 7:1, every accent ≥ 3:1 against the background, computed every run and printed on the card; a pin fails the gate if a palette ever drifts below.
- **Two layers, kept apart:** `/theme <name>` applies for this *session* only (OSC 10/11/12 + 16× OSC 4 — sequences that carry nothing but hex digits), saved in `~/.ai-theme.json` and re-pushed at every start; `/theme <name> save` is a *hand* — one per platform (Termux `colors.properties` + reload, Windows Terminal `settings.json` scheme + default, GNOME Terminal profile via gsettings, Terminal.app window via osascript) — and every hand makes **one backup first** (`~/.ai-theme-backup/`), never twice. `/theme off` = the terminal's own colours (OSC 104/110–112); `/theme undo` puts the backed-up config back. Uninstall runs the undo before removing `ai`.
- **Plain words:** "dark theme lagao", "aasmaan theme", "theme off". A bare "dark" or "it is dark outside" never switches anything.
- **Honest limit:** OSC colour changes work in every terminal `/term` recognises except plain conhost; where a platform has no config hand yet (kitty, Alacritty, iTerm2 profiles), the card says so and the session layer still works. Font size / DPI adaptation stays the next radius.

Touched: ai.py (`THEMES`, `contrast`, `theme_*`, `_theme_*` hands, `/theme`, `ai theme`, REPL start re-push, chat intent), tests/golden.py (+6 pins), the three uninstall lists (`.ai-theme.json`, `.ai-theme-backup`, restore-before-remove), README, docs/FAQ.md, docs/HANDS.md.
Not touched: the terminal probe (`/term`), any other hand, the model path, connectors.

## 2026-09-06 · radius 32 — the terminal is a device too: measured, then adapted to

Owner: "jis bhi type ke terminal me enter kar rahe hain uske core points se capabilities grab karo — scan, verify, assess; jo terminal freely allow kare wo push/pull karke adapt karo." Until now the harness measured the hardware and the OS but assumed the terminal — which is why ✓/✗ broke on Windows consoles and a human had to be asked which glyph line renders.

- **Probe by asking, on a real tty only:** program (Termux, Windows Terminal, conhost, iTerm2, Apple Terminal, kitty, WezTerm, Konsole, GNOME, Alacritty, VS Code, Blink on iOS, ssh), size, colour depth, UTF-8, and — the useful part — **how many cells this terminal advances for each glyph we draw** (`✓ ○ → · │ █ ⚠ ⏰ 🔋 अ`), measured with cursor-position reports (DSR 6) and erased, plus device attributes (DA1). 250 ms timeout; a pipe or CI probes nothing and never hangs.
- **Adapt:** when a glyph measurably does not line up, its whole family falls back to plain text (`✓→[ok]`, `│→|`, `⏰→[alarm]`…) through a stdout wrapper — installed only on a tty, only when needed, `AI_TERM_ADAPT=0` turns it off. No UTF-8 → everything falls back.
- **`/term` (and `ai term`)**: one card — what this terminal can **push** (title, clipboard OSC 52, hyperlinks OSC 8, notifications OSC 9/777, bell) and **pull** (size, cursor, DA1, colour), each marked *run / doc / no*; the measured glyph line; which fallbacks are active; `/term probe` re-measures. Cached in `~/.ai-term.json` per program + width.
- **Honest limit, stated on the card:** a cell count proves alignment, not that the font drew the shape rather than a box — that one judgement stays with the eye, asked once. Theme / font-size hands per platform and a resolution-based size recommendation are the next radius.

Touched: ai.py (`term_*`, `_AdaptOut`, `/term`, `ai term`, REPL start), tests/golden.py (+2 pins), README, docs/FAQ.md.
Not touched: hands, connectors, any output text (only its rendering when the terminal cannot draw it).

## 2026-09-06 · radius 31 — a zero-context judge scored the bundle 6.5/10; the real findings are fixed

A reviewer with no prior context ran the shipped bundle (compile, golden, adversarial, doctor, trust, tour, wizard, a first-user session) and read `ai.py` as a staff engineer. Verified and fixed the same night:

- **A real key leak in the headline invariant.** `_SECRET_RX` matched `*_API_KEY` but not `*_KEY`, so `AI_OAI_KEY` (your custom endpoint key) reached every forged tool and MCP subprocess. Now every `*_KEY`, `*_PASSWORD`, `*_CREDENTIALS`, `*_PASS` and `OPENAPI_MCP_HEADERS` are scrubbed; adversarial case 1 now asserts `AI_OAI_KEY` never leaves.
- **A false CI claim.** README said CI runs the adversarial suite; `ci.yml` ran only compile + golden + install. The step is added — the sentence is now true.
- **A false "checkable" claim.** TRUST.md said the word `analytics` does not appear in the code; it does, once, inside an expert's topic-word list. The claim now says what is actually true (no code path reports anything) and tells you how to check.
- **Verify instructions pointed at a path that does not exist in the bundle** (`akasha-fold/tests/…`); TRUST.md and both test docstrings now say `tests/…`.
- **Residual lowercase brand** (`akasha-boot.sh`, `.cache/akasha`, a profile comment) survived the bundle sed, contradicting the "zero occurrences" claim; build-dist now substitutes all cases and the gate fails on any survivor outside CHANGELOG.
- **`ai doctor` cried wolf on a fresh install** (vault "missing / not writable" — it is created on first `/remember`); now ○ "not created yet", ✗ only when it exists and is not writable.
- **A silent `chmod 600` failure on `~/.ai-env`** now prints a warning with the fix instead of `pass`.
- **`/run` is named in TRUST.md as the one deliberate shell door** — the line you typed, terminal-only, keys scrubbed, never reachable from a model/webpage/connector/voice; the confirm-with-diff gate is on the roadmap (D19).
- **Fetch-time SSRF** (a hostname resolving to loopback/tailnet) is stated as a known limit in THREAT-MODEL until the resolve→validate→connect radius lands.
- **Number drift is now a build failure:** README's golden/adversarial counts must equal what the suites contain, or build-dist refuses. README corrected to 132 / 10 and ~6,350 lines.

Not changed on purpose: the judge's "147 broad excepts" (real; the harness's never-crash-the-session posture — narrowed case by case in Phase A, not in one sweep) and the one-file architecture (see "Why one file").

Touched: ai.py (`_SECRET_RX`, doctor vault row, `_upsert_env` warning), tests/adversarial.py (case 1), tests/golden.py + adversarial.py docstrings, .github/workflows/ci.yml, README, docs/TRUST.md, docs/THREAT-MODEL.md, build-dist (lowercase brand, count gate).
Not touched: gates, hands, connectors, onboarding.

## 2026-09-06 · radius 30 — onboarding demonstrates, it does not configure

An onboarding review (7.5/10: "technically thoughtful, cognitively too ambitious — it teaches how Aasmaan is built before why to care") and the fresh-eyes run (all-Enter ended with no brain, silently) drove a redesign of the phone wizard, keeping its 7-step skeleton so the replays in the gate still hold:

- **One question decides ~70% of the setup.** Step 2 is now *"Kya chahiye?"* — 🧠 Private AI · 💬 Quick assistant · 🎙 Voice + phone control · 💻 Coding · 🎬 Content · 🔬 Sab kuch — capability-first words, no model names. Each maps to a brain that **fits this phone's RAM**, a context size and the extras. Enter on a capable phone never yields "no brain" any more (Quick assistant takes the small local brain; only < 4 GB RAM goes cloud/keyless).
- **A Recommended card replaces the model picker** (step 3): what local brain, how many MB to download, "offline chalega", context in A4-pages, a **battery truth** line, a **storage budget** (app + model + voice + tools vs free), the RAM bar. **Enter keeps it; `[a]` opens advanced** (the old model/context pickers, unchanged); digits still pick a brain directly.
- **Extras are capability-first** — "Voice — bol ke baat", "Video/audio tools", "Web panel"; **Screen reading (Shizuku: one Android step, no root) and Pentest kit sit behind `[m]`**, so a person who wants to chat never meets nmap.
- **The closing screen tells the truth:** a setup-completeness bar (✓ core · ✓ language · ✓/○ local brain · ✓/○ voice · ○ phone controls · ○ pairing, each with where to turn it on later), "the installer runs next", `ai doctor` and `ai tour` as the two things to remember — and the correct path for re-running the wizard (it printed a monorepo path that does not exist on a phone).
- The "abhi tak: qwen3:4b · ctx 8k · RAM" crumb no longer shows before any choice exists.
- `AI_USE` now shares one vocabulary with the PC installer (private / chat / code / content).

Touched: setup-wizard.sh (`s_intent`, new `s_recommend`, `s_brain_adv`, `s_extras`, `s_write`, `hdr`), docs/FAQ.md. Not touched: the installer stages, the harness; both gate replays (fit-check + back-nav) still pass unchanged.

## 2026-09-06 · radius 29 — two trust commands: `ai doctor` and the capability matrix

Three more independent reviews (8.2–8.4/10) converged on the same ask — hardening over features, a flagship health check, and one machine-readable description of every capability. Both ship as read-only commands; no gate changed.

- **`ai doctor` / `/doctor`** — 15 measured rows: Python, the running file's sha and repo, update state (cached, never a forced fetch), device (arch/cores/RAM), disk free, local brain (Ollama installed? running? models), cloud keys, `~/.ai-env` permissions, vault, keys leaked into `.bashrc` (Termux), network mode + privacy router, connectors, forged tools (and which are flagged/unregistered), voice, hands usable on this platform, daemon. ✓ fine · ✗ wrong **with the exact fix printed** · ○ optional. It only reads — a doctor that operates on you unasked is not one. Pinned: a world-readable `~/.ai-env` is ✗ with `chmod 600 …`, ✓ once fixed.
- **`/capabilities matrix` / `ai capabilities matrix`** — every hand, every impact action, every `/do` builtin, every wired MCP server, forge, and every brain as **one descriptor**: id · class (read / write reversible / write-asks / destructive / external tool / cloud model…) · risk letter · unattended? · confirmation · network · credentials · which gate enforces it. This is the policy the gates already enforce, made explicit — the first, behaviour-free step toward one policy engine. **Pinned against reality:** no hand/action/builtin is missing a descriptor, and the `unattended` column equals what `hand_run` and `mcp_ready` actually do with `AI_ATTENDED=0`.
- Philosophy line sharpened in `/help` (from a reviewer): the DO ladder never answers "no" — **but safety is the last word.**

Touched: ai.py (`doctor_rows/doctor_text`, `cap_matrix/cap_matrix_text`, `/doctor`, `/capabilities matrix`, `ai doctor`, help), tests/golden.py (+2 pins), README, docs/TRUST.md.
Not touched: any gate, hand, action or provider behaviour.

## 2026-09-06 · radius 28 — README tells the truth about the trust work, and about the one file

The README still said "~5,000 lines" (it is ~6,200) and did not mention `/trust`, the adversarial suite or the threat model that radii 25–27 shipped. Now: the *Trust* section explains the card, the ten proven invariants, and links THREAT-MODEL.md; the egress sentence carries the subprocess boundary; *Honest status* names the 130 golden + 10 adversarial gate; and a new **Why one file** section answers the reviewers' architecture question plainly — a deliberate choice for auditability (one file, one sha256, embedded whole) whose cost (discipline instead of import walls) is covered by the adversarial suite, with a package split kept possible behind those tests but not the next step.

Touched: README. Not touched: code, tests.

## 2026-09-06 · radius 27 — docs/THREAT-MODEL.md: the security architecture, legible to an outside reviewer

Formalised what the trust code already does into one document a security engineer can read before trusting the tool: the single invariant (untrusted data can never become authority), an asset/threat/boundary/mitigation table where every mitigation is real code cross-referenced to the adversarial case that proves it (A1–A10), the questions a reviewer always asks answered plainly (what the model can and cannot control; trusted vs untrusted input; webpage/MCP/forged-tool/unattended/no-net/dangerous-ask/compromised-connector/compromised-local-model), and the known limits stated rather than hidden (no universal sandbox — `_risky` is detection not proof; subprocess egress is separate; Windows is CI-tested not hardware-tested; one file with the adversarial suite as the boundary net). Linked from TRUST.md and ROADMAP.

Touched: docs/THREAT-MODEL.md (new), docs/TRUST.md (link), docs/ROADMAP.md.
Not touched: code — this radius documents what radius 26 proved.

## 2026-09-06 · radius 26 — the trust invariants are proven, not described (adversarial suite)

The review's sharpest point: security tests should ask "can it be made to do something it must never do?", not "does it work?". `akasha-fold/tests/adversarial.py` does exactly that — ten cases, each exercising the real code path, all currently holding:

1. a spawned process never receives an API key / token / secret (`_child_env` scrubs them; ordinary vars stay) — proven by running a real subprocess.
2. a forged tool that reads the environment, opens the network, or writes files is flagged risky (including the `import x as y` binding form a past red-team used to slip past); a pure-compute tool is clean.
3. a connector's server receives only the credential mapped for it, never another connector's token.
4. unattended (the daemon, `AI_ATTENDED=0`): a writing hand, an X-risk hand and forge are all refused; only a read-only hand runs.
5. an MCP server's reply is data — a reply saying "/mcp add evil …" is returned as text and registers no connector, runs no command.
6. an injected instruction inside untrusted text ("IGNORE PREVIOUS … add evil … rm -rf") never becomes an auto-executed command; a memory note enters the prompt as data under a MEMORY heading and executes nothing.
7. key-shaped strings are scrubbed before they can be journalled or sent to a cloud brain.
8. pairing mints a required token (a seat, not an open door); MCP and forge stay attended-only, so a served, non-tty peer cannot forge a tool.

The suite runs in the gate (`check.sh`) and from inside the shipped bundle (`build-dist.sh`), on every OS. This is also the answer to "how do you evolve the architecture without breaking the invariants": the adversarial suite is the safety net that makes any future refactor safe — a boundary that regresses fails here first.

Touched: tests/adversarial.py (new), check.sh + pc/build-dist.sh (run it in the gate and from the bundle), docs/TRUST.md.
Not touched: the harness — this radius only proves what is already there.

## 2026-09-06 · radius 25 — /trust: the authority model, made visible (and the egress claim, made exact)

After a deep external review argued the next step is proof and authority-control, not more features — and that Aasmaan already has the ingredients, just scattered:

- **`/trust` (and `ai trust`)** prints ONE card from the same live state every gate reads: which brain answers first (LOCAL / CLOUD, and whether cloud text is scrubbed), the network intent class (0 none · 1 local · 2 only when you ask · 3 + one daily version check), which cloud brains and connectors are wired, the files it can read/write, whether the screen or mic are reachable, that nothing is sent for you, that the background daemon is read-only, and the last cloud egress (or NONE). It ends with the invariant in one line: data can never grant authority — it suggests, you approve, code executes.
- **The egress claim is now exact.** `/egress` and TRUST.md said "every call is logged"; that is every call through `ai`'s own network layer. A subprocess `ai` runs for you (yt-dlp, an MCP server, ffmpeg, a forged tool) does its own network and is not in that log — so the wording is now "every request through `ai`'s managed layer is logged; a subprocess is classified separately, by name, when you add it", stated on the trust card and in the egress footer.

This is the first slice of the review's roadmap; the adversarial test suite (prove the invariants) and a formal THREAT-MODEL.md follow. The full "trust kernel" refactor (one central capability object) is the right direction but will be incremental behind these tests, never a big-bang rewrite of the working gates.

Touched: ai.py (`trust_card`, `/trust`, `ai trust`, egress footer), tests/golden.py (+1 pin), docs/TRUST.md.
Not touched: the gates themselves (impact_gate, hands, route) — /trust only reads them.

## 2026-09-06 · radius 24 — a fresh-eyes pass: the first five minutes must not lie or crash

A zero-context reviewer installed the product as a new user would and used it with no key and no local model. The confirmed, user-losing findings:

- **`/help` crashed every time** (`TypeError: not enough arguments for format string`) — the help text contains `15% of 4200` and `10 ka 18%`, and it was rendered with `%`-formatting, so the literal percents were read as format specs. It now fills the one placeholder with `.replace`, never `%`. Pinned.
- **`ai help` / `ai -h` / `ai --help` were sent to a brain as a question** (and failed with a raw error when no key was set). They now print the same help. 
- **The "all failed" provider dump** — six providers' `KEY not set` plus a Python `urlopen` error — printed before the friendly line, reading like a crash to a normal person. When nothing is configured yet, that noise is suppressed (the kind "no brain — add a free key" line already follows); it still shows for a real keyed failure and always under `AI_DEBUG`, and is kept in `/why`.
- **Small talk was web-searched:** "kya haal hai", "kaise ho", "how are you" matched the freshness regex (`haal`, `abhi`) and went to DuckDuckGo — an egress surprise against the "nothing leaves the device" promise. A small-talk guard now short-circuits; a real time-sensitive query ("aaj ka sona bhav", "latest news") still fetches.
- **Landing-page honesty:** the trust table said "Never … editing `.bashrc`/`.zshrc`" unqualified, but Termux adds one PATH line — now says "on a PC (Termux adds one PATH line, shown first)". And "Python and Ollama are installed by you … only prints the command" now reads "only after you press Enter (Linux/macOS print the command; Windows offers to run winget)", matching what the installers actually do.

The reviewer also flagged a brand split (wizard/profile saying "Akasha") — verified NOT shipped: `build-dist.sh` rewrites every `Akasha`→`Aasmaan` in the bundle, and the shipped `dist/aasman` has zero occurrences. Installer-flow items (mark the wizard's current row; the cloud-only re-ask; by-design outcomes counted as warnings) are the next radius.

Touched: ai.py (`/help` render, `ai help` dispatch, `route` no-brain noise, `needs_web` small-talk guard), tests/golden.py (+2 pins), docs/index.html.
Not touched: installers, connectors, hands, reminders, greeting.

## 2026-09-06 · radius 23 — the setup does not ask what it already knows

A user on a Motorola: the wizard printed "motorola edge 50 neo, 7 cores, RAM…" and then asked "Ye device kya hai? 1 Android 2 iPhone 3 Linux" — asking for the platform it had just detected and is literally running inside. And Windows was missing from the list.

- The device step now **leads with the detected platform** (`Android (Termux)` inside Termux, `Mac` on Darwin, else `Linux`) as a confirmed fact — "✓ Android (Termux) — yahi"; **Enter keeps it**. The picker only appears as "badalna ho tabhi": `2` iPhone/iPad (client-only, can never be auto-detected because iOS cannot run this), `3` Linux/Mac.
- **Windows is named honestly:** a line says Windows does not use this wizard — `irm .../install.ps1 | iex` in PowerShell — instead of pretending it is one of the picker options.
- Option 3 relabelled "Linux / Mac" (the bash wizard runs on both; it never runs on Windows).

Touched: setup-wizard.sh (`s_device`, platform detection). Not touched: install.ps1 (already its own path), the harness, tests (the wizard replays still pass — option 1 is still Android).

## 2026-09-06 · radius 22 — the same family, hunted everywhere: a fix must never depend on the broken thing

Owner: "aisa issue aur kahin to nahi chhipa?" A root-cause audit of every install/update path (14 suspects, 9 cleared with evidence) found three more of the family that broke the Moto today:

- **`ai update` on Android** printed and ran the bare `curl … | bash` — curl can re-break after a Termux/openssl bump. It now checks that curl even runs (`curl --version`), upgrades with `apt` only if it does not (never `pkg`, which needs curl), then runs the same line. Pinned.
- **`install.sh` refused to start without curl** — so the git-clone route it already had was unreachable on a minimal Debian/Ubuntu (which ships neither curl nor wget). It now uses curl → wget → git, whichever exists, and says which to install otherwise. Verified here with curl removed from PATH: the tarball came through wget. Docs carry the `wget -qO- … | bash` line.
- **Fresh macOS**: `/usr/bin/python3` is Apple's stub that opens the "install Command Line Tools?" dialog and blocks. `pc-setup.sh` now checks `xcode-select -p` before running it, prints the one command, and every python probe has a timeout. (Unverified on hardware — no Mac here; the guard is a pre-check, not a behaviour change for Macs that already have the tools.)
- Cleared with evidence, no change: Windows Store-python stub (skipped by path), `ai.cmd` launcher (no ExecutionPolicy issue), user PATH via registry, no admin; Termux `/dev/tty` prompts under `curl | bash`; every pip install on Termux degrades with a fallback message; `termux-*` calls carry timeouts. Known-unknown: very old Windows 10 builds may fail the first `irm` on TLS 1.2 — documented in the FAQ, not coded around.

Touched: ai.py (`update_cmd`), install.sh (`fetch`, requirement check), pc-setup.sh (macOS stub guard, `_to` on the python probe), README, docs/index.html, docs/FAQ.md, tests/golden.py (+1 pin).
Not touched: install.ps1, installer stages, harness behaviour.

## 2026-09-06 · radius 21 — connectors: safe to say yes to, honest about what you do not have

Owner: "gmail ke MCP se connection jo tarika hai uspe safe feel karte hue guide karna hai … catalogue me nahi hai to custom ka process bata ke permission leke bana dena hai".

- **Every connector line and setup card now ends with the safety line:** token/password never shown in chat or on screen (hidden typing, `~/.ai-env` 0600), never sent to any other server — only to that connector's own process, which receives only that one credential — no step without your yes, and how to remove it (`/mcp rm`, `/keys rm`).
- **Home Assistant is ask-for-only** (`suggest:false` in the catalogue): it never appears in use-case suggestions or bucket searches; `/mcp find homeassistant` shows it with a "kya hai" line that says what it is and that it is only for people who already run one.
- **Unknown service → the custom process, spelled out:** you say what it should do → a brain fills one function inside a fixed stdio-MCP skeleton (stdlib only, no shell, keys only from env) → scan + preview → your yes → register + one test call. **`/mcp forge` now prints this plan and asks before anything is generated**; no tty and no `AI_YES` = nothing written.

Touched: connectors.json (one entry), ai.py (`mcp_find`, `_connector_line`, `connector_suggest_line`, `mcp_forge`), tests/golden.py (+2 pins).
Not touched: setup/verify flow, MCP protocol, keys.

## 2026-09-06 · radius 20 — a daily greeting, tailored on the device, one toggle

Owner: "ek greetings bhi toggle on/off wali rakho, every morning at 10 am, user ke hisaab se tailored … taki user ko special aur personal feel ho".

- **`/greet on|off`, `/greet at HH:MM` (default 10:00), `/greet city <name>`, `/greet brain on|off`, `/greet now`**; plain words "greeting on", "subah wali greeting band karo". Off by default; one hint line at first start.
- **Composed locally** from what the device already knows: salutation by time of day in your language with your name (`~/.ai-profile` owner), the date, the weather only if you named a city and the net is up (keyless Open-Meteo, attributed), today's reminders (radius 19), your lists, one tip about a hand or tool this install actually has. A brain adds ONE sentence only when one is reachable (local first) and is marked with its name; nothing is sent anywhere otherwise.
- **Once a day:** fires when `ai` starts after the set time, or from `ai daemon` as a notification (and spoken when voice is on); `~/.ai-greet.json` remembers the day.
- **`GREET_LINES` plug:** a function registered there adds a line; tomorrow's panchang/tithi (Dharma OS) lands through it without touching the rest (ROADMAP).

Touched: ai.py (`/greet` block, REPL start + daemon step + chat intent, MSG key, help), tests/golden.py (+2 pins), README, docs/FAQ.md, docs/ROADMAP.md.
Not touched: reminders store, hands, connectors, voice engine.

## 2026-09-06 · radius 19 — the OS's own endpoints: alarms, timers, reminders, calendar, on every platform

Owner: "alarms, reminders, calendars … jo jo endpoints open hote hain, same har platform ke liye". Hands, code-owned as before:

- **Android (any Termux, no add-on, no Shizuku):** `alarm_set` (Clock app, `SET_ALARM`), `alarm_dismiss` (asks), `timer` (`SET_TIMER`, rings with `ai` closed), `timer_dismiss`, `calendar_add` (`INSERT` event prefilled with your title — you pick the time and save; nothing silent), `alarms_show`, `calendar_app`.
- **macOS:** `remind_in`, `remind_at` (Reminders.app; "alarm" maps here — macOS has no alarm clock), `calendar_add` (one-hour event), `reminders_app`, `calendar_app`. Text travels as an argv item into `on run argv`, never inside the AppleScript.
- **Windows:** `remind_at` (Task Scheduler popup at HH:MM today; the text is read from a 0600 file, never placed on the command line), `remind_clear`, `clock_app` (`ms-clock:`), `calendar_app` (`outlookcal:`).
- **Linux:** `remind_at` (`systemd-run --user --on-calendar`), `remind_clear`; `timer` already existed.
- **Plain words and voice:** "alarm 6:30 baje", "7 pm ka alarm", "wake me up at 12 am", "timer 10 min chai", "meeting daal do 3 pm: dentist"; am/pm/subah/raat words set the hour.
- **`/remind` — one store for every platform** (`~/.ai-reminders.json`, 0600): "remind me at 10:30 chai", "kal 9 baje meeting yaad dilana", "raat 10 baje yaad dila do doodh", `/remind in 20 min call`. The OS endpoint is tried on top (marked `os` so nothing fires twice); otherwise an in-process timer fires it while `ai` is open and `ai daemon` fires what came due while it was closed — notification (argv/env, never a script string) and, with voice on, spoken. `/remind` lists, `/remind rm <id>`, `/remind clear`. A cancel word ("alarm hatao 6:30") never creates an entry.
- Typed values only reach templates: `h`/`m` are ranged ints; `{clock}`, `{mins_until}`, `{text_file}` are derived by code. `hands_check` still refuses text inside any script element.

Touched: ai.py (hands tables ×4, `_h_build` derived values, `hands_intent` am/pm, `/remind` block, REPL + voice + daemon hooks, help), tests/golden.py (+5 pins), docs/HANDS.md, docs/FAQ.md, README.
Not touched: existing hands, MCP, connectors, tuning, language.

## 2026-09-06 · radius 18 — the first Android command must not depend on the binary it is fixing

Second failure on the same Moto: `pkg upgrade -y` printed "No mirror or mirror group selected" and then the same `CANNOT LINK EXECUTABLE "curl"` — because `pkg` itself runs curl to pick a mirror. The one-line install now starts with `apt update && apt -y -o Dpkg::Options::=--force-confnew full-upgrade && apt -y install curl python` (apt fetches with its own code; `--force-confnew` answers the conffile prompts so the line never stalls), then the same `curl … | bash`. Changed in every place the line is printed: README, docs/index.html, docs/FAQ.md, install.sh hints, `ai pair` help and the Telegram /install text.

Touched: README, docs/index.html, docs/FAQ.md, install.sh (comments + the python-missing hint), ai.py (two text strings).
Not touched: installer logic, harness behaviour, tests (117/117 unchanged).

## 2026-09-06 · radius 17 — the login catalogue is vetted, not guessed

The research pass (khoji, `C-login-connectors.md` in the monorepo) checked every login connector against its own repo, docs and LICENSE file. Corrections landed as data:

- **Notion:** the official server takes `NOTION_TOKEN` directly (no header JSON); verify = `API-get-self`; a 403 means the page was never connected to the integration (the common miss), now named in the fix table.
- **Gmail:** the real env names are `MCP_EMAIL_SERVER_EMAIL_ADDRESS` / `MCP_EMAIL_SERVER_PASSWORD` (mapped from the values you type); Gmail needs no host settings; "Invalid credentials" with the real password is expected once 2-Step is on.
- **Todoist:** package corrected to `@ecfaria/todoist-mcp-server` (MIT confirmed three ways) with an honest warning: one-author, zero-review repo — built-in `/list` or a forged 40-line REST wrapper are the cautious paths.
- **Google Calendar:** `access_blocked` → add yourself as a test user; Termux gets the browser-hop recipe (termux-api, or paste the printed localhost URL — loopback works on the same device).
- **GitHub:** Termux has no Docker — the Go build line is printed instead.
- **Home Assistant:** the official built-in "Model Context Protocol Server" integration (Apache-2.0, HA core) replaces the third-party repo; Bearer token over streamable HTTP; endpoint path still unverified by a run.
- **Spotify** joins as a guided entry (own loopback OAuth, MIT; playback needs Premium, search does not).
- **Locked reasons are now the real ones:** Canva = remote OAuth 2.1 + dynamic client registration the client itself would have to speak (a generic bridge, `mcp-remote`, is under vetting); Google Photos = the only server claims MIT in its README but ships no LICENSE file, and Google removed library-read scopes in 2025.
- Cards print a `vet:` line (what was checked, when, and that we have not yet run it end to end) instead of a blanket "unverified".

Touched: connectors.json, ai.py (`_setup_card` vet line; verify probe passes a query only to search-like tools), README, docs/FAQ.md.
Not touched: setup/verify flow, MCP protocol code, keys, tests (117/117 unchanged).

## 2026-09-06 · radius 16 — CI run #5: one pin, not the product, was Windows-blind

`golden · windows` on run #5: 115/116, the only red was the pin "posix forged path has no .py suffix (Windows-only branch)" — it asserted posix behaviour while running on Windows, where `_forged_path` deliberately adds `.py` (Windows cannot exec a shebang-only file). The pin now expects `.py` exactly when `os.name == "nt"` and never otherwise, so it proves the branch on both platforms instead of failing on one. Install jobs and the other golden jobs were already green.

Touched: tests/golden.py (one pin).
Not touched: ai.py, installers, catalogue, docs.

## 2026-09-06 · radius 15 — login connectors are options, guided and verified

The owner overruled the "OAuth-only = locked" stance: a free service that needs your own account must stay an option — make the user aware, take their yes, guide the setup, then hand-hold the verification.

- **`/mcp setup <name>`** (Notion, Google Calendar, GitHub, Gmail app-password, Todoist, Home Assistant): an awareness card (account needed, what leaves the device and to whom, free, who runs the login page, number of steps), nothing without a yes, numbered steps Enter by Enter (`q` stops, progress kept), tokens typed hidden into `~/.ai-env`, file paths checked, install hint printed (you run it), provider written, then **`/mcp verify`**: connect, list tools, one read-only call; a failure prints the matching fix from the catalogue instead of a stack.
- **Credential isolation:** a connector's process receives the scrubbed environment plus ONLY the variables mapped for it (`env_map`); other keys never reach it. Pinned with a fake server that reports what it saw.
- **`mcp_ready` says "login pending: X not set — /mcp setup name"** instead of a generic "not ready".
- Catalogue: `login` blocks with steps/secrets/files/verify/fix per service; entries whose exact package or flag names come from documentation carry `unverified` and say so on the card (a research pass is confirming them). `locked` now holds only Canva, Google Photos and WhatsApp, each with its alternative and the reason.

Touched: ai.py (`mcp_setup`, `mcp_verify`, `_env_for`, `MCPStdio(env=)`, `mcp_ready` message, find/add carry `env_map`+`name`, intent regex), connectors.json, tests/golden.py (+1 pin), README, docs/FAQ.md.
Not touched: MCP protocol code, keys handling, hands, voice, language, experts.

## 2026-09-06 · radius 14 — the gate must be true on Windows too

CI run #4 on the live repo: every install job green (the pipefail root cause was real), `golden · ubuntu/macos` green, `golden · windows` red. The test file, not the product, used POSIX-only pieces: `sleep`, `echo`, `cat` as process stand-ins, `os.kill(pid, 0)` as a liveness probe (on Windows that call would terminate the process), and a console that cannot print ✓/✗ in cp1252. Every pin now spawns the running Python interpreter instead, checks `poll()`, and stdout is forced to UTF-8. Behaviours pinned are unchanged (116/116). If `golden · windows` is still red after this, the failure is real and the step's last lines are the next thing to read.

Touched: tests/golden.py only.

## 2026-09-06 · radius 13 — connectors: found, suggested, added, or forged

- **`connectors.json`** ships a vetted catalogue (research: 25 candidates, 12 kept — official reference servers, single-purpose permissive-licence servers, and three "real account" ones with warnings). No OAuth-only service is listed: this client has no browser flow, so `locked` carries the honest local alternative for Notion, Canva, Google Calendar/Photos, WhatsApp, Todoist instead of a dead end.
- **`/mcp find <service|use-case>`** and plain words ("pdf ka connector chahiye", "connect my email", "github wala jodo") resolve offline by keyword bucket; output = what leaves the device, licence, install line for this platform, tier, warning, and the exact `/mcp add` line. The installer's use-case (`AI_USE`) orders suggestions and `ai` names the fitting keyless ones once at start.
- **`/mcp add <catalogue name> [TOKEN=…]`** fills template tokens once at add time (a folder root must exist and may never be your whole home; a host must look like a host), prints the install hint (you run it), writes a code-owned argv provider, and picks the server's tool by hint when it is reachable.
- **`/mcp forge <what it should do>`**: a brain fills one function inside a fixed stdio-MCP skeleton; the file is scanned, previewed, and registered only if clean; attended only.
- **Lists**: `/list`, "shopping list me doodh" — built because no trustworthy server exists for the family bucket.
- **Audit fixes (research/connectors/B-tuning-knobs.md):** the `exemplars` knob is now consumed by the persona trimmer; `plan` is a registered impact action, so `/plan`'s gate is real, not a silent no-op.

Touched: ai.py (`connectors_cfg`, `connector_intent`, `mcp_find`, `mcp_add_catalogue`, `mcp_forge`, `lists_cmd`, chat routing, startup suggestion, `/list`, `capabilities()`), connectors.json (new), pc-setup.sh / install.ps1 / fold-all-setup.sh (copy the catalogue), build-dist.sh, tests/golden.py (+5 pins), README, docs/FAQ.md, docs/ARCHITECTURE.md.
Not touched: the MCP client itself, keys, hands, voice, language, experts.
Owner calls still open: app-password email for client mail; whether Home Assistant exists; local-only PDFs for client documents (the catalogue's `pdf` pick is local).

## 2026-09-06 · radius 12 — the tuning layer: the harness is what is tuned

The owner's framing, made concrete: whatever the model, the harness around it carries the tuning — in numbers, not in weights.

- **Per-tier knobs** (`TUNING`, `/tuning`): tiny ≤2.5B · small · mid · large · cloud, read off the brain that answers first. Applied where it matters: persona budget, KB budget, answer cap (`ask`, `run_agent`), brain demotion thresholds, short/deep thresholds, plan depth. A 1.7B phone brain now gets ~1.4k chars of persona and one exemplar; a cloud brain gets the full pack — same code.
- **`~/.ai-tuning.json`** overrides numbers only; strings, templates, argv and unknown keys are ignored and named at start (golden-pinned). This is the door for research to retune shipped installs without a code change.
- **`/usage [days]`**: real token counts from the brains themselves (Ollama eval counts, OpenAI `usage`, Gemini `usageMetadata`) per brain per day, in/out ratio, and a plain signal when the local brain was enough. The answer footer shows real in/out tokens when known instead of an estimate.
- **`/plan <goal>`**: rung-0 tools, hands and self-intents resolve without a brain; otherwise a strict JSON plan (≤ the tier's `plan_steps`) whose steps may only be `expert` / `do` / `hand` / `ask` / `tool0` with real names; shown, impact-gated, confirmed, then run step by step with the previous output passed as data. A `shell` step or an unknown expert is rejected.
- **Found by the smaller budgets, fixed for every budget:** six packs write their exemplars under `### 1 — title` headings, so the persona trimmer's "exemplar #1 always survives" promise held only at 4,500 chars — below that it kept the bare heading. The trimmer now merges a heading with its Q/A, shrinks prose repeatedly instead of once, and never lets the final cut land on the exemplars (pinned at tiny/small/mid).
- **`AI_USE`**: the installers' one question ("mostly for?") on all three platforms; `/agents` and `/capabilities` show the suggestion order; nothing is locked. Streaming to a local custom endpoint is no longer redacted (consistency with radius 11).

Touched: ai.py (`TUNING`/`tuning_load`/`model_tier`/`tier_now`/`knob`, `usage_note`/`usage_text`, `plan_cmd`/`_plan_parse`, `USE_MAP`/`use_suggest`, knob hooks in `agent_persona`/`expert_kb`/`ask`/`run_agent`/`brain_order`/`classify`, footer, `stream_call`, `/tuning /usage /plan`), pc-setup.sh, setup-wizard.sh, install.ps1, tests/golden.py (+5 pins), README, docs/FLAGS.md, docs/FAQ.md, docs/ARCHITECTURE.md.
Not touched: prompt templates (still code), keys, hands, voice, language, experts' content, serve/pair.

## 2026-09-06 · radius 11 — models and connectors attach by discovery

Answering the owner's question "jo bhi model user download kare — voice, image, chat — ya koi MCP connector — harness se attach hota hai?" with code instead of a promise.

- **Ollama:** what is installed is read from Ollama, classified chat / vision / embed by tag. Unset roles attach at start and are announced once; an explicit `AI_VISION_MODEL` / `AI_EMBED_MODEL` / `AI_LOCAL_MODEL` is never overridden; a pinned chat model that is not installed falls back to the largest installed one that fits RAM, with the `ollama pull` line. `/models`, and `/model <name>` warns when the name is not installed.
- **Any OpenAI-compatible endpoint** — `ai connect <url> [model] [key]` (LM Studio, llama.cpp server, Jan, vLLM, a gateway): lists the server's models, saves `AI_OAI_URL/MODEL/KEY` to `~/.ai-env`, pings it, and adds provider `custom`. Loopback/private = local: raw text, first in the order, allowed through `/net off`, footer says "tere device pe". Remote = cloud: redacted first, ordered before the local fallback.
- **MCP servers as `/do` rungs** — `/mcp add <name> <url|command> cap=<capability> tool=<tool> [arg=query] [key=ENV]`, `/mcp list|tools|rm`; streamable-HTTP and stdio clients in the stdlib (from the monorepo's `mcp_client.py`). The user's text travels as one JSON argument, never a shell; attended only (`AI_ATTENDED=0` refuses); child processes get the key-scrubbed environment; results are data.
- Voice engines already attached by presence; local image generation is still not a thing here (keyless Pollinations online only) — said plainly.
- What tuning means (README, FAQ): routing, cooldowns, context tiers, learned exemplars, cache — never weights.

Touched: ai.py (`ollama_models`, `_model_role`, `models_autoattach`, `models_text`, `custom_provider`, `_providers_refresh`, `connect_cmd`, MCP clients + `mcp_ready`/`mcp_run`/`mcp_cmd`, rung 1 branch in `do_capability`, `route()` local flag, `/models /connect /mcp`, `/model` check, `capabilities()`), tests/golden.py (+4 pins), README, docs/FLAGS.md, docs/FAQ.md, docs/ARCHITECTURE.md.
Not touched: the fixed cloud providers and their order, keys handling, hands, voice, language, experts, installers.

## 2026-09-06 · radius 10 — honest numbers

A recovery sweep compared every claim in these docs against the code. What was wrong is fixed here, nothing else.

- `ai.py` is ~5,000 lines, not "~3,700". The daily update check fetches a ~43-byte `VERSION`, not "60-byte". Local context is set by RAM tier (4k–32k, `AI_LOCAL_CTX` pins it), not "pinned to 16k". Android uninstall is a fixed list via `cleanup.sh`, the manifest-based uninstall is the PC installers'.
- Outbound identity disclosed in TRUST.md and made brand-true in code: keyless fetches send `User-Agent: aasmaan`; `/v1` responses carry `"id": "aasmaan-1"`. Nothing else identifies an install.

Touched: ai.py (three User-Agent strings, `/v1` id, one comment), README, docs/TRUST.md, docs/ARCHITECTURE.md.
Not touched: behaviour of any feature.

## 2026-09-06 · radius 9 — pairing: what each combination really unlocks

- **New page docs/PAIRING.md:** the host × client matrix (macOS / Windows / Linux / Android host; iPhone / Android / desktop-browser client), the browser law that decides it (on plain http a phone gives back typed text, a camera photo and a file — mic stream, notifications, share, clipboard read are HTTPS-only; iPhones never vibrate from a page; mobile screen-capture is unsupported), the same-phone localhost case that *is* a secure context, the Tailscale HTTPS rung, safety per cell, and the peer mode we deliberately did not build yet.
- **`ai pair` now adds the machine's MagicDNS name to the allowed Host list**, so a `tailscale serve` HTTPS front-end passes the DNS-rebinding guard instead of getting 403; it prints the `tailscale serve --bg <port>` line and the "never funnel" warning. Golden pin: the name is accepted, strangers are still refused.
- The one sentence, now in the CLI output, README, FAQ and this page: **the panel controls the computer at the other end, never the phone in your hand.**

Touched: ai.py (`_tailscale_dns`, `pair()` hosts + two lines), tests/golden.py (+1 pin), docs/PAIRING.md (new), README, docs/FAQ.md, docs/ROADMAP.md.
Not touched: serve auth, token handling, panel HTML, hands, voice, language, experts.
Unverified on real hardware: the exact `Host` header `tailscale serve` forwards (test recipe in PAIRING.md).

## 2026-09-06 · radius 8 — the product explains itself (19th pack, generated)

- **`aasmaan` is now an expert about Aasmaan.** `experts/aasmaan/PERSONA.md` is hand-written (three rules: shipped vs PLANNED, exact command every time, never state a measured fact the KB cannot know). `experts/aasmaan/KB.md` is **generated at every build** by `gen-selfkb.py` from README, WHY, TRUST, FAQ, ROADMAP, FLAGS, CHANGELOG and the command dispatcher — never hand-edited, so it cannot drift from the docs. Size caps (≤1800 chars/section, cheat-sheet ≤1100) match the runtime KB budget; a two-way command gate (dispatcher ∪ `KNOWN_CMDS` ∪ HELP, every command glossed) and a `VERSION` check fail the build on any mismatch.
- **Product questions route without `/agent`:** "kya ye offline chalta hai", "mera phone kaise judega", "kya kya planned hai", "Windows pe chalega?", "isme kitne experts hain" reach it through a third deterministic gate after self-intents and chat rules (which return measured state and always win). The user's own code or data ("mera script offline chalega?", "is file me bug", anything naming python/npm/docker…) never routes here.
- **With a brain:** the expert answers with `capabilities()` prefixed as trusted, measured fact, and warns when the KB's VERSION differs from the install. **With no brain, no key, no net:** `self_answer()` returns the best KB section and the commands in it (BM25 over sections; a question with no lexical hit gets "not in my KB" — never a bluff).
- Counts: 19/19 expert packs everywhere (installers, CI, build gates, docs) — 18 specialists plus the product.

Touched: ai.py (`self_kb_route`, `self_answer`, `self_kb_version_note`, gate 3 in `ask()`, `run_agent` prefix, `EXPERT_HINTS`), experts.json (+aasmaan), experts/aasmaan/{PERSONA,KB}.md, gen-selfkb.py (new), build-dist.sh (generation + VERSION gate + 19/19), pc-setup.sh, install.ps1, .github/workflows/ci.yml, tests/golden.py (+4 pins), README, docs/ARCHITECTURE.md, docs/ROADMAP.md, docs/index.html, CONTRIBUTING.md.
Not touched: the 18 specialist packs, provider ladder, hands, voice, language, keys, serve/pair.

## 2026-09-06 · radius 7 — voice: push-to-talk, the same rules as chat

Four defects found by reading the old code against the vendor sources, all fixed: `piper --output_raw` piped into a swallowed buffer (silent); `whisper-stt` called as if it took no recording; "band karo" mapped to `/quit`; background jobs had no cancel.

- **`v` / `/voice`** listens once (push-to-talk, never an always-on mic) and routes the words through the chat pipeline: stop-words → self-intents (typed gate kept) → device hands → plain-word commands → rung-0 tools → brain. Safe rows run; non-destructive rows ask **by voice** (haan/nahi, silence = no); `/quit /clear /keys /update /setup /net /bg ! /run /serve` always need a typed yes. `/voice on|off|stop|log on|status|notify`; `ai voice once` for the Android pinned notification (bol / ruk buttons, code-owned action strings).
- **Speech is one sentence per process**, so `/stop` / "ruk" lands after the current sentence on every platform (Android's engine cannot be cut mid-utterance). Engine follows the device and `/lang`: Android `say` wrapper or `termux-tts-speak` (`-l hi -n IN` for Hindi), macOS `say` (Lekha for Hindi if installed, says so if not), `spd-say`/`espeak-ng -v hi`, Windows System.Speech (warns: usually no Hindi voice), piper with a real player. `AI_TTS_ARGV` overrides for tests.
- **Listening ladder:** Termux:API STT (Google, English-only — documented), the setup-menu `whisper-stt` wrapper (records + transcribes), `arecord` + `whisper-cli`, Windows dictation. `/api/listen` uses the same ladder and refuses when voice is off.
- **Background jobs can be cancelled:** `/bg stop [id]`, and "ruk" cancels them; shell jobs register their process and are killed, other jobs are flagged (`job_cancelled()`) and marked cancelled — an already-running blocking call finishes on its own, and the report says so.
- Transcripts are not journalled by default (`/voice log on` opts in).

Touched: ai.py (`speak`, `listen_once`, `voice_once`, `voice_cmd`, `stop_speaking`, `job_cancel`, `/voice`, `/bg stop`, `hands_stop` also stops speech + jobs, `/api/listen`, `capabilities()`), tests/golden.py (+4 pins), README, docs/FAQ.md, docs/FLAGS.md, docs/HANDS.md.
Not touched: provider ladder, routing, keys, serve/pair auth, experts, installers, panel HTML (its mic button already calls `/api/listen`).

## 2026-09-06 · radius 6 — language: English by default, yours after that

- **Installers ask first** (`pc-setup.sh`, the Android wizard, `install.ps1`): `[1] English [2] Hinglish [3] हिन्दी`, Enter = English; stored as `AI_LANG` in `~/.ai-setup-profile`; scripted runs (`AI_YES=1`) never ask. Installer prompts and stage titles follow it. On Windows, Devanagari is offered only inside Windows Terminal (conhost cannot shape it) and applies to model answers only.
- **`ai` mirrors you when nothing is pinned:** deterministic stdlib detection (script block wins at ≥3 chars, else Hinglish marker words with every English collider removed); flips only when 2 of the last 3 plain messages agree, and prints the switch. Commands and pasted logs are not counted. `/lang en|hinglish|hi|auto` shows, pins or releases; `AI_LANG` in the profile wins over `/lang` and says so.
- **The model gets one precise sentence** per language in the system prompt (a definition and an exemplar for Hinglish, per the code-switching literature), instead of the old "answer in the user's language". Expert packs are not translated — their examples set the style, the sentence sets the language.
- **UI strings:** a `MSG` catalogue with `_t()`; ~20 visible core strings exist in English and Hinglish (startup tips, no-brain messages, unknown/suggested command, quit warning, first-cloud note, self-intent hints, stop). The rest stay Hinglish for now and the README says so. Command names, flags, env names and paths are never translated.
- Known and documented: Marathi/Nepali read as Hindi by script; a single "ok"/"update" is undecidable and therefore never flips anything.

Touched: ai.py (`detect_lang`, `lang_*`, `MSG`/`_t`, `/lang`, system-prompt line, `capabilities()`), lib/ux.sh (prompt language), pc-setup.sh (stage 0 + titles), setup-wizard.sh (step 0), install.ps1 (prompt + profile), fold-all-setup.sh (reads the profile), tests/golden.py (+3 pins), README, docs/FLAGS.md, docs/FAQ.md, CONTRIBUTING.md.
Not touched: provider ladder, hands, rung-0 tools, keys, serve/pair, experts. Voice does not follow `/lang` yet — that is the next radius.

## 2026-09-06 · radius 5 — useful before any brain (the keyless user)

Found by running the product as a user with no key and no model: `2+2 kitna hai` walled out with "all failed: local: Connection refused" while `/egress` worked perfectly — inverted for the person the product is for.

- **Rung 0 tools, answered before any brain, offline:** calc (`2+2`, `15% of 4200`, `4200 ka 15%`, `2^10`, `sqrt 144` — an allow-listed `ast` walk, never `eval`; names, attributes, calls and huge powers are refused), date/time, `time in <city>` (zoneinfo, fixed-offset fallback on Termux without tzdata), `N days from today`, `age <date>`, `days until <date>`, units (length, mass, volume, data, speed, time, area incl. bigha, temperature), `b64`/`b64d`/`sha256`/`md5`/`uuid`/`epoch`/`urlenc`/`json`, `pw <n>` (never journaled, never cached), `wa`/`upi`/`qr` link+QR makers (UPI: link only, nothing paid), `emi`/`sip`/`lumpsum` with the formula shown and calculator-only wording, and `mausam <city>` (Open-Meteo, keyless, CC BY 4.0 attribution printed every time).
- **`ai tour` / `/tour`:** six things run for real on this device in a minute, each printing the verb it used; net-only steps skip and say so.
- **Not shipped, on purpose:** translation through an unofficial endpoint (terms-of-service gamble); a dictionary API with no published rate limit.
- Startup tip and the no-brain message now name these instead of pointing at a dead end.

Touched: ai.py (`local_tool`, `calc`, `convert`, `weather`, `tour`, rung 0 in `ask()`, `/calc`, `/tour`, help + hints), tests/golden.py (+3 pins), README, docs/FAQ.md, docs/index.html.
Not touched: hands, provider ladder, routing, keys, serve/pair, experts, installers.

## 2026-09-06 · radius 4 — hands: your device, by plain words

- **New: device control** (`/hands`, `/hand <id>`, `/stop`, `/undo`, and plain words / voice: "awaaz 30", "pause", "next song", "battery", "say hello", "copy: …", "torch on", "screenshot le", "remind me in 10 min: chai"). First wave per platform: Android (deeplinks with no add-on; volume/TTS/notify/clipboard/torch/brightness with Termux:API; any app's music + DND with Shizuku), macOS (volume, Music.app, say, clipboard, notify, screenshot, caffeinate, Spotlight, sleep), Windows (media keys, say, clipboard, screenshot, battery, windows list, minimize, lock, Settings pages), Linux desktop (wpctl/pactl volume, MPRIS via busctl, notify-send, spd-say, clipboard, timer, lock), WSL2 (Windows clipboard/speech/browser only — honestly). Full table and the "OS does not allow" list: docs/HANDS.md.
- **Rules in code, pinned by golden:** code-owned templates, typed params, free text never inside a script element, every hand carries a risk letter and a brake, unattended runs read-only hands only, `X`-risk needs a terminal yes, hidden-not-broken when a need is unmet. Rung 0 of `/do`.
- **"band karo" no longer quits.** It is a stop-word ("ruk", "bas", "stop", "cancel") checked before every other rule; it kills what a hand started and pauses media. `/quit` is unchanged.
- Research behind it: nine per-platform reports (macOS, Windows, Linux, Android, pairing, language, raw user, voice, self-KB), commands read from vendor sources.

Touched: ai.py (HANDS engine + 4 commands + REPL order + rung 0 + CLI verbs + `capabilities()`), tests/golden.py (+7 pins), README, docs/HANDS.md (new), docs/ARCHITECTURE.md, docs/TRUST.md, docs/FAQ.md, docs/index.html.
Not touched: provider ladder, routing, keys, serve/pair, experts, installers, daemon (it gets the read-only gate for free).
Not yet verified on real hardware: every macOS and Windows hand (`conf: doc` / `unv` in the table) — first reports welcome.

## 2026-09-06 · radius 2 — what the bundle says about itself must be true

Three lies the published bundle was telling, found by agents reading the shipped files against the source.

- **docs/FLAGS.md documented a flag that does not exist.** The build's slug substitution ate the identifier `AI_REPO_SLUG` and shipped the repo slug spliced into the flag name. Substitution is now word-bounded and the "did the build eat an identifier" gate also scans docs, README and CHANGELOG, not just the installers.
- **The typo-suggester's command list claimed to be complete and was not** (`/auto /online /local /quit /q /exit` missing). Added, and a golden pin now derives the dispatcher's command literals from the source and fails on any asymmetry in either direction — the self-KB (next radius) will be generated from this list, so it has to be exact.
- **Bytecode (`__pycache__`) was in the public repo.** The build removes it after its own test runs; the monorepo ignores it under `dist/`.

Touched: ai.py (`KNOWN_CMDS`), build-dist.sh (sed + guard + cleanup), tests/golden.py (+1 pin), .gitignore.
Not touched: anything a user runs.

## 2026-09-06 · radius 1 — first run on a fresh device

Found by installing on a real phone (Moto, no root, no Shizuku) and by re-running the CI steps under GitHub's own shell.

- **Android first command** is now `pkg upgrade -y && pkg install -y curl python && curl … | bash`. A fresh Termux ships a `curl` that fails with a libcurl/SSL symbol error until the base packages are upgraded; the old command hit that wall on the very first line. The mirror-error path (`termux-change-repo`) is written next to the command. Updated in README, the docs site, FAQ, the `ai pair` Android help and the Telegram `/install` text — all five, same string.
- **CI `install` job (Linux + macOS) was red for a reason unrelated to the product:** the "install.sh refuses without python3" check pipes an *expected* exit 1 into grep, and GitHub runs steps with `pipefail`. The step now isolates that expected exit. `golden`, scripted install, `ai version`, `daemon --once` and uninstall all reproduce green locally on the public checkout.
- **`/do image` works as typed.** The startup tip and every recipe say `/do image <prompt>` while the capability's name is `image_generation`; typing the tip forged a tool named "image" and dead-ended a keyless user. A small alias table (`image`, `img`, `say`, `speak`, `search`, `web`, `fetch`, `read`) now resolves before the ladder. Golden pin: every alias target must exist in the map.
- **Cosmetic, but a first-run face:** installer banner no longer says "PC edition" (it is one bundle for phone and computer); the phone installer's summary box printed a literal `${AI_BRAND…}` instead of the name.

Touched: README, docs/index.html, docs/FAQ.md, ai.py (`CAP_ALIAS`, two help strings), install.sh (banner + hints), install.ps1 (comment), pc-setup.sh (uninstall title), lib/ux.sh, .github/workflows/ci.yml, tests/golden.py (+1 pin).
Not touched: provider ladder, routing, keys, serve/pair, experts, daemon, Windows installer logic.

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
