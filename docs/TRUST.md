# Trust — what leaves your device, what never does

Read this in two minutes. Every claim below can be checked in `ai.py` by searching the word in **bold**.

## Leaves the device only when *you* cause it

| Your action | What is sent | To whom | Scrubbed? |
|---|---|---|---|
| ask a question, local brain available | your text | Ollama on **this** device (`localhost:11434`) | no need — it never leaves |
| ask a question, cloud brain | your text | the provider whose key *you* added (Groq, Gemini, Cerebras, OpenRouter, …) | **yes** — `redact()`: emails, phones, PAN, UPI, IFSC, account/Aadhaar-shaped numbers, API keys, private IPs, your home path, names in `~/.ai-private-names` |
| `/do research`, a time-sensitive question | the search query | DuckDuckGo (keyless) | **yes**, same scrub |
| `/do scrape <url>` | the URL | that site | — |
| `/do image <prompt>` | the prompt | Pollinations (keyless) | **yes** |
| `/attach shot.png` then ask | the image | only a brain that can see (Gemini with your key, or a local vision model) | image is not scrubbed — attach what you would show |
| daily update check | nothing about you; a GET of a ~43-byte `VERSION` file | GitHub (this repo) | opt out: `AI_UPDATE_CHECK=0` |

Everything else — memory, KB index, chat state, cache, metrics, expert packs, keys — is a file in your home folder. Nothing syncs.

**Every one of those calls is logged where you can read it.** `~/.ai-egress.log` gets one line per outbound call (time, local/CLOUD, method, host/path, bytes out); `/egress` shows it. Query strings and bodies are never written there.

## Never

- **No server of ours.** There is nothing to host, so nothing to breach on our side.
- **No telemetry.** No crash reports, no "anonymous usage", no pings. The word `analytics` does not appear in the code.
- **No silent installs.** Python and Ollama are installed by you from official installers; every stage waits for Enter.
- **No key exports.** Keys are read from `~/.ai-env` by `ai` itself (`_load_env`); they are not put in your shell or handed to child processes.
- **No unattended action.** The daemon runs with `AI_ATTENDED=0`; forging tools and shell execution are hard-blocked there.
- **No text inside a script.** Device hands (docs/HANDS.md) are code-owned templates; free text is only ever its own argument or stdin, never embedded in an `osascript`/`-Command`/`rish -c` script. A hand that violates this fails to load (`hands_check`), and the daemon may only use read-only hands.
- **No fake results.** If a test did not run, it says so. If no brain can see your image, it says so instead of guessing.

What the outbound requests identify themselves as: keyless fetches (search, scrape, links) send `User-Agent: aasmaan` (or `Mozilla/5.0 (Android) aasmaan` where a site refuses bare agents); `/v1` responses carry `"id": "aasmaan-1"`. That is the whole fingerprint — no install id, no device id.

## Verify it yourself

```
ai version              # sha256 of the file you are running — compare with the repo
grep -n "urllib.request" ai.py     # every network call
grep -n "def redact" ai.py         # the scrub
grep -n "AI_ATTENDED" ai.py        # the unattended gate
/capabilities           # what this install can do right now (keyed brains, alive brains, vision)
/why                    # which brain answered your last question, and why
/egress                 # the runtime log: every network call this install ever made — when, local or CLOUD, host/path, bytes out (never the query or body)
```

Airplane-mode test: turn networking off, run `ai`, ask something. The local brain answers; `/memory` and `/kb` work; nothing errors about a missing server, because there is none.

## Honest limits

- Free cloud tiers are third parties under their own terms; the scrub reduces what they see, it cannot make them yours. Prefer the local brain for anything private — that is the default when it exists.
- Android without root has no sandbox; generated tools are scanned and gated, not sandboxed.
- Keys are file-protected (`0600` / `icacls`), not hardware-protected yet. See ROADMAP.
