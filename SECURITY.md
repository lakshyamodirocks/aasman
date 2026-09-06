# Security

## What this program promises

- **Nothing leaves your device that you did not type, attach, or explicitly send with `/do`.** Every outbound call in `ai.py` is a `urllib.request` you can grep; each goes to your local Ollama, a provider *you* keyed, or a keyless public endpoint you invoked.
- **Cloud-bound text is scrubbed first** (emails, phones, PAN, UPI, IFSC, account numbers, Aadhaar-shaped numbers, API keys, private IPs, your home path, names you list in `~/.ai-private-names`). The local brain sees raw text; it never leaves the device.
- **Keys live in `~/.ai-env`, readable only by you, never handed to child processes.** Every subprocess (a `/run` command, a generated tool, ffmpeg…) gets a scrubbed environment; pinned by a test. No shell rc file is edited.
- **Every outbound call is logged** in `~/.ai-egress.log` (time, local/CLOUD, host/path, bytes out; never the query or body). `/egress` shows it.
- **Generated tools are scanned before they run.** Anything touching destructive surfaces asks you first and is not registered until you say yes.
- **Unattended = no action.** The daemon runs with `AI_ATTENDED=0`, which hard-blocks tool forging and shell execution.
- **No telemetry, no server of ours.** The only automatic network call is an optional once-a-day GET of this repo's 60-byte `VERSION` file (opt out: `AI_UPDATE_CHECK=0`).

## Reporting a vulnerability

Please **do not** open a public issue. Use a private advisory: https://github.com/lakshyamodirocks/aasman/security/advisories/new

Include: `ai version` output, device, and steps. You will get a reply within 7 days. Fixes ship as a new `VERSION`; every installed copy shows the update line at the next start.

## Known limits (stated, not hidden)

- On Android without root there is no sandbox: `proot` is not a boundary. Mitigations shrink the surface (pinned model files, size caps, timeouts); they do not stop code execution in a compromised subprocess.
- `~/.ai-env` is a file with permissions, not a hardware keystore. On Android the plan is `termux-keystore` wrapping; on PCs an OS keychain is on the roadmap.
- The Windows installer adds one folder to your **user** PATH only if you press Enter; uninstall removes it.
- Free cloud tiers are third parties with their own terms. The privacy scrub reduces what they see; it cannot make them yours.
