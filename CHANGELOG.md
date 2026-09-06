# Changelog

Every published version is a line in `VERSION` (`date sha repo`). Installed copies see the newest one at the next start and offer `ai update`. Newest first.

Changes ship as **impact radii**: one commit per concern, each entry names what it touched and what it deliberately did not, so a fix in one place cannot quietly break another. (How this works: CONTRIBUTING.md → "How changes ship".)

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
