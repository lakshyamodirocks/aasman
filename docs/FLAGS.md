# Every switch, in one place

Aasmaan is configured by environment variables (put them in `~/.ai-env` as `export NAME=value`, or set them in the shell). Defaults are what a fresh install gets. "Wrong value" says what happens if you set junk — this program prefers to fail loud, and the rows marked *silent* are the ones still on the list to fix. Line numbers refer to `ai.py` at the time of writing.

**Doc'd** = where a user can find it today (`—` = nowhere; **37 of 48**). **Wrong value** = what a junk setting does.

| Flag | Default | What it changes | Doc'd | Wrong value |
|---|---|---|---|---|
| `AI_BRAND` | `Aasmaan` | product name in UI/panel/manifest (:13) | — | silent |
| `AI_VAULT` | `~/ai-vault` | notes/journal/KB root (:45) | — | silent — new empty vault, old notes look "lost" |
| `AI_PROFILE` | `~/.ai-profile` | path to the owner-identity JSON (:68) | — | silent — falls back to generic "You" |
| `OLLAMA_HOST` | `http://localhost:11434` | local brain endpoint (:47) | — | loud (local fails, router moves on) |
| `AI_LOCAL_MODEL` | `qwen3:4b-instruct-2507-q4_K_M` | local model tag (:64) | pc-setup, install.ps1, wizard | loud (Ollama 404 per call) |
| `AI_LOCAL_CTX` | auto by RAM (4k–32k) | forces `num_ctx` (:130) | pc-setup, install.ps1, wizard | **silent** — non-digit ignored, no warning |
| `AI_VISION_MODEL` | unset | vision model for Ollama; also *enables* the local vision path (:139,:148) | README, FAQ | loud (Ollama error) |
| `AI_EMBED_MODEL` | `nomic-embed-text` | embedder for cache/KB (:170) | — | **silent** — degrades to BM25 only |
| `AI_EMBED_TIMEOUT` | `4` | embed timeout, s (:175) | — | loud (`ValueError` at import) |
| `AI_TIMEOUT` | `150` | HTTP timeout, every brain call (:48) | — | loud (`ValueError` at import) |
| `AI_PRIVACY` | `1` | **`0` disables `redact()` on every cloud send** (:200,:300,:1394) | — | **silent** — anything but `"0"` = on |
| `AI_FORCE_OFFLINE` | unset | `1` → `net_up()` False (:258). **Not a network switch — F2** | pc-setup, install.ps1 | **silent + misleading** |
| `AI_AUTOWEB` | unset (on) | `0` disables auto web-search (:1375) | — | **silent** — only `"0"` disables |
| `AI_CACHE_SIM` | `0.92` | cosine threshold for a cache hit (:405) | — | loud (`ValueError`) |
| `AI_CORPUS` | `~/.ai-corpus.jsonl` | Q&A archive path (:462) | — | silent |
| `AI_CORPUS_MAX_MB` | `64` | archive rotate size (:464) | — | loud (`ValueError`) |
| `AI_TRACES` | `~/.ai-traces.jsonl` | `/do` exemplar store (:1033) | — | silent |
| `AI_TRACE_MAX` | `400` | rows kept (:1034) | — | loud (`ValueError`) |
| `AI_TRACE_BUDGET` | `700` | chars of exemplars glued into a forge prompt (:1035) | — | loud (`ValueError`) |
| `AI_TRACE_DEBUG` | unset | `1` prints the exemplar block (:2312) | — | silent |
| `AI_PERSONA_CHARS` | `4500` | expert-persona budget (:1296) | — | silent (`or 4500`) |
| `AI_REPO` | auto (install dir) | where experts/agents/panel are found (:1147) | install.ps1 | **silent** — packs vanish, `/agents` empty |
| `AI_REPO_SLUG` | from `VERSION` | slug for update-check + `/install` text (:2542) | — | **silent** — update check quietly dies |
| `AI_SETUP_CMD` | `""`→update cmd | the command `/setup` runs (:2574) | pc-setup, install.ps1 | **loud, and dangerous — runs what you put** |
| `AI_UPDATE_CHECK` | `1` | `0` disables the daily `VERSION` GET (:2581) | README, SECURITY, TRUST, ARCH | silent (only `"0"`) |
| `AI_OAI_URL` | unset | an OpenAI-compatible chat endpoint (base or `/v1/chat/completions`) → provider `custom`; loopback/private = local, else cloud | README | loud (ping fails, ladder moves on) |
| `AI_OAI_MODEL` | unset | model id on that server (`ai connect` lists them) | README | loud |
| `AI_OAI_KEY` | unset | bearer key for that server, if it wants one | README | loud (401) |
| `AI_VOICE` | `1` | `0` = voice off at start: no TTS, no mic, `/api/listen` refuses | README | silent (only `"0"`) |
| `AI_TTS_ARGV` | unset | JSON argv that replaces the TTS engine (reads one sentence from stdin) — tests / odd setups | FLAGS | loud (bad JSON ignored, engine ladder used) |
| `AI_PIPER_MODEL` | unset (searched in `~/.local/share/piper`, `~/piper-voices`) | path to a piper `.onnx` voice | FLAGS | silent (falls to the next engine) |
| `AI_LANG` | unset (→ `en`, then auto-mirror) | `en` / `hinglish` / `hi` pins the answer language + the translated UI strings; written by the installers, `/lang` shows/changes it | README, FAQ | silent (unknown value = not pinned, auto-mirror) |
| `AI_ATTENDED` | `1` | **`0` hard-blocks forge + shell** (:1640; forced 0 by daemon :2608, telegram :2849) | README, SECURITY, TRUST, ARCH | silent (only `"0"`) |
| `AI_AUTOFORGE` | `1` | `0` disables rung-5 tool forging (:1639) | — | silent |
| `AI_WISH_BATCH` | `3` | wishes granted per `/wish run` (:1611) | — | loud (`ValueError`) |
| `AI_ARG_MAX` | `4096` | permit(): max chars per argv element (:1791) | — | silent (`or 4096`) |
| `AI_ARGV_MAX` | `65536` | permit(): max chars per command line (:1792) | — | silent (`or 65536`) |
| `AI_PATH_ROOTS` | vault + media dirs | **widens where `/do` may READ** (:1826) | — | **silent** — bad path dropped |
| `AI_OUT_ROOTS` | `AI_OUT` | **widens where `/do` may WRITE** (:1831) | — | **silent** |
| `AI_OUT` | `~/ai-out` | default output dir (:567,:687,:749,:1826,:1831) | — | silent |
| `AI_ALLOW_HTTP` | unset | `1` lets `/do` fetch plain `http://` (:1932) | — | silent |
| `AI_ALLOW_INTERNAL` | unset | **`1` lets `/do` fetch loopback/private/tailnet — kills the SSRF guard** (:1939) | — | silent |
| `AI_SERVE_PORT` | `8765` | panel port (:3009,:3626) | setup-menu | loud (bind error) |
| `AI_SERVE_HOST` | `127.0.0.1` | panel bind address (:3333,:3390) | setup-menu | loud (refuses non-loopback without a token, :3390) |
| `AI_SERVE_HOSTS` | `""` | extra Host values the rebind guard accepts (:3334) | — | **silent** — panel 403s, no reason given |
| `AI_SERVE_TOKEN` | `""` (**no auth**) | if set, every `/api/*` + `/v1/*` needs it (:3411) | README, setup-menu | silent — **unset = open, F3** |
| `AI_SERVE_TOOLS` | unset | **`1` lets HTTP callers run `/do`, which dispatches through a shell** (:3511) | — | silent |
| `TELEGRAM_BOT_TOKEN` | `""` | bot token; empty = gateway off (:2802) | — | loud (`ai telegram` refuses) |
| `TELEGRAM_ALLOWED_CHATS` | `""` | fail-closed chat allowlist (:2803) | — | **silent** — bot answers nobody |
| `TELEGRAM_OWNER_ID` | `""` | owner's private chat, always allowed (:2804) | — | silent |
| `TELEGRAM_QA` | `0` | `1` = free-text Q&A on (spends your keys) (:2805) | docs/COMMUNITY | silent |
| `TELEGRAM_QA_PER_HOUR` | `6` | per-user rate limit (:2805) | — | silent (`or 6`) |
| `TELEGRAM_API` | `https://api.telegram.org` | API base (:2806) | — | **silent — points your bot token at any host you name** |
| `TELEGRAM_ANNOUNCE_CHAT` | `""` | `ai announce` target (:2885) | — | loud |
| `DISCORD_WEBHOOK_URL` | `""` | `ai announce` webhook (:2885) | — | loud |

`AI_PRIVACY` · `AI_ALLOW_INTERNAL` · `AI_SERVE_TOOLS` · `AI_AUTOFORGE` · `AI_PATH_ROOTS`/`AI_OUT_ROOTS` · `TELEGRAM_API` each remove a safety property with **one undocumented env var and no runtime warning** → F6.

Keys (`*_API_KEY`, `*_TOKEN`, `AI_SERVE_TOKEN`) are read from `~/.ai-env` and never handed to child processes. `/keys` lists which are set (masked).
