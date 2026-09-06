# Pairing — what each phone × computer pair can and cannot do

`ai pair` on a computer prints a QR; a phone scans it and opens **that computer's** `ai` panel over your own Wi-Fi or Tailscale, token-locked. This page is the honest map of what that unlocks, per combination, and the one sentence to keep in mind:

> **The panel controls the computer at the other end, never the phone in your hand.** A web page — on http or https, on any phone — cannot change the phone's volume, control music in Spotify, take the phone's screenshot, or lock it. Device control of the phone itself needs a full Android install (Termux), where `ai` runs *on* the phone.

## The browser law (decides every cell)

On plain-LAN http, a phone browser can hand the computer exactly three things: **typed text**, a **camera photo** (`<input capture>`), and a **file**. The mic stream, notifications, Web Share, geolocation, clipboard read and wake-lock are **HTTPS-only** by browser rule. Two facts worth knowing cold: iPhones never vibrate from a web page (Safari does not implement it), and screen-capture from a mobile browser is unsupported outright, not merely blocked.

Two free workarounds cover most of it with zero code: **keyboard dictation** (iOS keyboard mic, Gboard voice typing — on-device on Pixel 6+) works in the panel's text box on plain http; and the panel's 🎤 button uses the **host's** mic, which is exactly right when the host is the laptop on your desk.

## The matrix

Same in every cell: ask with a streaming answer, background jobs with a live badge, upload text to context or an image to a vision brain, tasks, tags, history, logs, mode/route/model switching, feedback, and the `/v1/chat/completions` shim for OpenAI-shaped apps. The differences:

| Host → / Client ↓ | macOS | Windows | Linux desktop | Android (Termux) |
|---|---|---|---|---|
| **iPhone (Safari)** | host hands: volume, Music.app, say, notify, screenshot, caffeinate · client gives text/photo/file · Add to Home Screen | host hands: media keys, say, clipboard, screenshot, lock · Defender prompt: allow *Private* · client as left | host hands: volume, MPRIS music, notify, spd-say, lock, timer · client as left | host hands on the **phone that runs `ai`**: volume, TTS, torch, notify, clipboard (Termux:API), any app's music + DND (Shizuku) · the iPhone is a screen for it |
| **Android (Chrome)** | as above + Chrome "Add to Home screen" shortcut (no install prompt on http) + Gboard voice typing | as above | as above | **same phone:** `http://127.0.0.1:8765` *is* a secure context — full mic, clipboard, notifications in the browser too |
| **Mac/PC browser** | as above; a desktop browser can be told to treat the origin as secure (`chrome://flags`) for a real mic | as above | as above | the laptop borrows the phone's local model — usually the weaker brain |

Hands per platform, and what the OS refuses (screen cast, for one): [HANDS.md](HANDS.md).

## The HTTPS rung (Tailscale)

Enable MagicDNS and HTTPS in the Tailscale admin, then on the host: `tailscale serve --bg 8765`. The panel is now `https://<machine>.<tailnet>.ts.net/?t=<token>` — a secure context, so the client's own mic, notifications and share sheet work. `ai pair` already puts the machine's MagicDNS name into the allowed Host list so the rebinding guard accepts the proxied request. Two honest notes: enabling HTTPS publishes machine names to a public certificate-transparency ledger (Tailscale says so); and **never use `tailscale funnel`** — that is the public internet with your token in the URL. Unverified by us on a real iPhone: whether the forwarded `Host` header is exactly the MagicDNS name (report it if the panel answers 403). The official Tailscale Android app has no CLI, so a phone host cannot run `serve`.

## Safety per cell

- The token in the QR **is the seat**: same memory, files, settings, keys for everyone who scans it. No family profiles yet. Never post the QR in a group.
- PC hosts on LAN http: unencrypted on the wire; anyone on that Wi-Fi who sees the URL owns the seat. Home Wi-Fi: fine. Café, hostel, office: use Tailscale.
- Phone host: the phone is a server — keep `termux-wake-lock` on and battery *Unrestricted*, or it dies mid-conversation. Any app on that phone with internet permission can reach `127.0.0.1:8765`; the token, `Content-Type` and Origin checks are what stand in the way.
- Revoking: remove `AI_SERVE_TOKEN` from `~/.ai-env` (`ai keys rm AI_SERVE_TOKEN`); the running server reads it live.
- There is no shell over HTTP, and there never will be; `/do` over the panel needs `AI_SERVE_TOOLS=1` on the host.

## Two full installs (phone `ai` ⟷ laptop `ai`) — planned

`ai pair --peer <url>`, `ai peer ask <name> <q>`, `ai peer send <name> <file>` — a peer is a seat, not a channel: whoever holds the token can ask anything and spend your keys. Off the v1 list until per-peer capabilities exist; the vault is plain files, so `rsync` over Tailscale SSH already syncs memory today with no code.
