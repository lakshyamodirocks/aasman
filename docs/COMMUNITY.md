# Community

Two rooms for humans, one place for anything that must not get lost.

| | Where | For |
|---|---|---|
| **Telegram** | https://t.me/+iF1WcRNqpAk0ODQ1 | quick questions, "did this work on your phone?", Hinglish welcome |
| **Discord** | https://discord.gg/j8njkbbNY | longer threads, show-and-tell, per-device channels |
| **GitHub issues** | https://github.com/lakshyamodirocks/aasman/issues/new/choose | bugs and feedback that must be tracked (templates ask for `ai version`) |
| **Private advisory** | https://github.com/lakshyamodirocks/aasman/security/advisories/new | anything that could leak data or run code it should not |

## Rules (same in both rooms)

1. **Never paste a key, token, or password.** Not even "masked" — crop screenshots first. Mods delete on sight, no warning needed.
2. **Be specific.** Device, `ai version` output, what you typed, what you saw. A screenshot with the key lines cropped beats a paragraph.
3. **Respect the maintainer's time and each other's.** No spam, no promo, no "any update?" pings. Feedback is read weekly and tagged; the top rank gets immediate attention.
4. **This is a beta.** If something reads stale, say so with a link — that is the feedback loop working, not a failure.
5. **Finance, health, legal**: the experts here explain, they do not advise. Nobody in these rooms is your adviser either.

## The helper bot (Telegram)

The maintainer runs `ai telegram` on his own device — there is no server. It only answers in this group and only to fixed commands:

- `/install` — the one-command install for Android / Linux-macOS / Windows
- `/faq` — the short answers
- `/version` — which version is live
- `/feedback <text>` — lands in the maintainer's feedback file with who/when; goes into the weekly vetting
- `/capabilities` — what the bot's own install can do right now

Free-text answers are **off by default** (`TELEGRAM_QA=1` turns them on, rate-limited, scrubbed, and always unattended: the bot can never run a command or forge a tool). Chat text is treated as untrusted input, never as instructions.

## How feedback flows

Telegram `/feedback`, Discord threads, and GitHub issues all end up in the same weekly vetting. Each item gets three tags — **importance**, **sequence** (what must come first), **severity** — and the top-ranked item is looked at immediately. Fixes ship as a new `VERSION`; every installed copy shows the update line at its next start.
