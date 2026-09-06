# Hands — your device, by plain words

`ai` can act on the device it runs on: volume, music, clipboard, notifications, torch, screenshots, "remind me in 10 minutes", opening a link or an app. In chat, by voice (the panel's mic and the terminal's voice input land in the same place), or by command. This page is the exact list: what ships per platform, what is hidden until you install an add-on, and what the operating system simply does not allow.

```
/hands                 what THIS device can do right now (measured, not promised)
/hand volume_set 30    run one by name
awaaz 30               the same, by plain words — "pause", "next song", "battery", "say hello", "copy: text"
/stop  ·  ruk / bas    the brake: kills anything a hand started, pauses media
/undo                  the last state change back (volume, mute, torch…)
```

## The rules every hand obeys (enforced in code, pinned by tests)

- **Code-owned templates.** Every command line is a template inside `ai.py`, never read from a file. Data cannot reshape a command.
- **Typed parameters.** Numbers have ranges, choices are enumerated, text has a length cap, links must be `http(s)`.
- **Text never enters a script.** On macOS (`osascript -e`), Windows (`-Command`) and Shizuku (`rish -c`) the script is a shell of its own, so only numbers and enumerated words may be embedded in it. Free text is passed as its own argument or over stdin. A hand that breaks this rule fails to load.
- **Every hand has a brake.** A risk letter, plus an undo (state hands capture the prior value first) or a stop (process hands are tracked by pid). `R` reads only · `S` safe, undoable · `X` asks first · `D` not reversible, asks first.
- **Unattended = read-only.** The daemon runs with `AI_ATTENDED=0`; there only `R` hands run. `X`/`D` hands need a terminal to say yes in — over the web panel or a pipe they refuse and tell you the command.
- **Hidden, not broken.** A hand whose need is missing (Termux:API, Shizuku, a desktop session, PowerShell 5.1) does not appear, and `/hands` says why.
- **Clipboard reads are redacted** the same way chat is before anything is printed or stored.

## What ships (first wave)

| | Android · Termux | macOS | Windows 10/11 | Linux desktop | WSL2 |
|---|---|---|---|---|---|
| volume set / read / mute | Termux:API | ✓ | up/down/mute (media keys) | wpctl → pactl → amixer | — |
| music play / pause / next / previous | **any app** via Shizuku (`cmd media_session`) | Music.app | media keys | any MPRIS player via `busctl` | — |
| what is playing | Shizuku | Music.app | — | — | — |
| speak text (`say …`) | Termux:API TTS | `say` | System.Speech | `spd-say` / `espeak-ng` | System.Speech via Windows |
| notification | Termux:API | ✓ | — (planned) | `notify-send` | — |
| clipboard get / put | Termux:API | ✓ | ✓ | `wl-copy`/`xclip`/`xsel` if present | `clip.exe` / PowerShell |
| battery | Termux:API | ✓ | ✓ (empty = desktop) | `/sys` | says "none" honestly |
| screenshot to Pictures | — (Shizuku `screencap` planned) | ✓ (one Screen Recording prompt) | ✓ | — (portal dialog; planned) | — |
| open link / app | ✓ (any app that handles it) | ✓ | ✓ | `xdg-open` | Windows browser |
| Spotify / YouTube search, WhatsApp chat (nothing is sent) | ✓ deeplinks, no add-on needed | — | — | — | — |
| torch · vibrate · toast · brightness | Termux:API | — | — | — | — |
| do-not-disturb | Shizuku (asks first) | — | opens the Settings page | — | — |
| stay awake / wake lock | ✓ | `caffeinate` | — | — | — |
| lock / sleep | — | sleep (asks first) | lock (asks first) | lock (asks first) | — |
| alarm at HH:MM | ✓ Clock app via `am` (no add-on) | Reminders.app | opens the Clock app | `systemd-run --on-calendar` | — |
| timer / remind me in N min | ✓ Clock app timer | Reminders.app | Task Scheduler popup (today) | `systemd-run --on-active` | — |
| remind me at HH:MM | ✓ (alarm) | Reminders.app | Task Scheduler popup (today) | `systemd-run --on-calendar` | — |
| calendar event | ✓ prefilled in the Calendar app, you save | Calendar.app (one hour) | opens the Calendar app | — | — |
| open alarms / calendar | ✓ | ✓ | ✓ (`ms-clock:`, `outlookcal:`) | — | — |
| find files by name | — | Spotlight | — (Search index planned) | — | — |
| windows list / minimize all | — | — | ✓ | — | — |

**`/remind` is the floor under all of these.** "remind me at 10:30 chai", "kal 9 baje meeting yaad dilana", "7 pm dawai" or `/remind in 20 min call` go into `~/.ai-reminders.json` on every platform. The OS endpoint is tried on top (an Android alarm, a Reminders.app entry, a Task Scheduler popup, a systemd timer) so it fires even when `ai` is closed; when none exists or it refuses, `ai` fires it while open (an in-process timer) and `ai daemon` fires whatever came due while it was closed — as a notification and, with voice on, spoken. `/remind` lists, `/remind rm <id>` removes. The text never enters a shell: Android and macOS get it as one argv item, Windows reads it from a 0600 file, notifications carry it as an argument or an environment variable.

**Android tiers.** No add-on: links, deeplinks, wake lock. **Termux:API** (F-Droid, same signature as Termux — a mismatch makes every call hang, which is why the probe is a real call with a timeout): volume, TTS, notifications, clipboard, torch, battery, brightness. **Shizuku + rish** (no root): music control of *any* app, what is playing, do-not-disturb.

## What the OS does not allow — and we do not fake

- **Screen cast / mirror to a TV**: no scriptable path on Android, Windows or Linux; macOS has no AirPlay CLI. Windows and Android get a one-tap handoff to the Cast settings page. Nothing more is possible without a human tap, so nothing more is promised.
- **Trackpad gestures, global media keys on macOS, Bluetooth toggles, Night Light on Windows, default audio device switch**: no public API. Where a Settings page exists, the hand opens it.
- **Stopping Android TTS mid-sentence**: the engine lives in the Termux:API app and cannot be cut mid-utterance, so `ai` speaks one sentence per process and `/stop` lands after the current sentence (the same on every platform); as a last resort `/stop` also stops the Termux:API service.
- **A paired phone controlling itself**: the web panel controls the *computer* it is paired to, never the phone in your hand (browser pages cannot touch volume, torch or media).

## Verification status

`conf` in the table inside `ai.py`: `run` = executed by us on that platform (Linux `say`, `battery`), `doc` = built from the vendor's own documentation or source, `unv` = unverified on real hardware (the Windows media-key hands, WSL speech). `/hands` marks the `unv` ones. Windows and macOS have not run on a physical machine of ours yet — your first `/hands` is a real test; please report what worked.

Research behind this page (per platform, with sources) lives in the maintainer's monorepo and will be linked from the changelog as it is published.
