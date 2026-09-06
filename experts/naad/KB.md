# Naad — Knowledge Base (audio layering: voiceover, background, mixing)

## 1. What Naad actually is
Naad mixes audio ONTO existing video/audio — never cuts the picture (that's
`sampadak`) and never generates raw speech itself (that's `vaani`). Its real
tool is `vedit`, a thin bash wrapper over `ffmpeg` (`fold-node/termux/setup-menu.sh`
`menu_vedit`, wired as the `audio_overlay` capability in `tools-routing.json`).
Three named recipes only — never freehand a `filter_complex` graph outside them.

## 2. The exact recipes (verified against ffmpeg's own filter docs)
Source: `fold-node/research/toolkit-vetting-2026.md` §4 (KHOJI's own citation:
"verified against ffmpeg.org filter docs") + our live wrapper,
`fold-node/termux/setup-menu.sh` lines 319-328. Primary filter docs:
https://ffmpeg.org/ffmpeg-filters.html#sidechaincompress and `#loudnorm`.

```
vedit duck voice.wav music.wav out.m4a
  -> ffmpeg -i voice.wav -i music.wav -filter_complex \
     "[1:a][0:a]sidechaincompress=threshold=0.05:ratio=8:attack=5:release=250[d];
      [0:a][d]amix=inputs=2:duration=first" -c:a aac -y out.m4a
  Order matters: sidechaincompress's FIRST input is compressed, SECOND is the
  trigger. We compress music[1] using voice[0] as the trigger -> music ducks
  under speech automatically.

vedit loud in.wav out.wav
  -> pass 1 (measure): ffmpeg -i in.wav -af loudnorm=I=-16:TP=-1.5:LRA=11:
       print_format=json -f null -
  -> pass 2 (apply):   ffmpeg -i in.wav -af loudnorm=I=-16:TP=-1.5:LRA=11:
       measured_I=<v>:measured_TP=<v>:measured_LRA=<v>:measured_thresh=<v>:
       linear=true -ar 48000 -y out.wav
  Target -16 LUFS = the short-form/social default (EBU R128 broadcast is -23,
  too quiet for phone speakers). loudnorm can silently change sample rate --
  vedit already pins -ar 48000 on output; don't drop that flag.

vedit desilence in.wav out.wav
  -> ffmpeg -i in.wav -af "silenceremove=start_periods=1:start_duration=0:
     start_threshold=-45dB:detection=peak,silenceremove=stop_periods=-1:
     stop_duration=0.5:stop_threshold=-45dB:detection=peak" -y out.wav
  Two chained silenceremove stages: stage 1 trims LEADING silence only, stage 2
  (stop_periods=-1) repeats for EVERY internal gap >=0.5s. One silenceremove
  call alone only handles the start -- this is why it's two stages, not a bug.
```
`vedit` with no args prints its own usage — run it first if unsure of a recipe name.

## 3. The TTS half — dispatch to Vaani, don't own the engine
Naad supplies the mix; `vaani` supplies the voice. Default: **Piper**, offline,
MIT (archived Oct 2025 but frozen-working). Exact CLI our harness already runs
(`fold-node/termux/setup-menu.sh` line 234-235):
```
printf '%s' "$txt" | piper -m "$HOME/piper-voices/hi_IN-pratham-medium.onnx" -f out.wav
```
[GROUNDED — `-m <model>` / `-f <output.wav>` flags confirmed against the active
fork's own CLI doc, github.com/OHF-Voice/piper1-gpl/blob/main/docs/CLI.md,
fetched 2026-09-06; note the NEW fork's CLI takes text as a quoted positional
arg after `--` rather than stdin — our wrapper uses the OLDER archived
rhasspy/piper's stdin behavior, which is what we actually ship]. Hindi voices
that exist on HuggingFace's `rhasspy/piper-voices` repo: **pratham, priyamvada,
rohan** [GROUNDED, huggingface.co/rhasspy/piper-voices/tree/main/hi/hi_IN,
fetched 2026-09-06] — our setup script currently only auto-pulls
`pratham`+`priyamvada` at `medium` quality (~150MB total for both); `rohan`
exists upstream but isn't in our pull list yet, flag if asked for a male-voice
alternative beyond pratham.

## 4. Free vs paid — the honest table
| Path | Cost | Offline | Notes |
|---|---|---|---|
| `vedit` (ffmpeg) | Free | ✅ Yes | Fully wired, this is the default for ALL mixing |
| Piper/whisper.cpp/Kokoro (voice) | Free | ✅ Yes | Vaani's engines, dispatched here for narration |
| **ElevenLabs GenFM** (`POST /v1/studio/podcasts`) | **Paid only — no free API tier at all** [GROUNDED, elevenlabs.io/pricing/api] | ❌ Cloud | Only for a two-host "podcast" feel; real substitute for NotebookLM Audio Overview, which has **zero API at any personal tier** [GROUNDED, `fold-node/research/capability-providers-routing-2026.md` §1] |
For "make me a podcast from these documents": NotebookLM itself is manual/
browser-only, forever — say so, don't imply automation exists. Offer the honest
choice: pay for ElevenLabs GenFM, or go fully offline (Vaani voiceover +
`vedit duck`/`loud`).

## 5. Indian-context specifics
- **Reels/Shorts audio default: `loud` to -16 LUFS** after any voiceover mix —
  phone speakers and WhatsApp/Instagram playback are quiet-normalized, -16 is
  the accepted short-form target, not the broadcast -23.
- **WhatsApp media limits** [UNVERIFIED against WhatsApp's own FAQ this session
  — the page did not load via fetch; sourced from secondary trackers instead,
  flag accordingly]: video sent inline via gallery caps around **16MB** and gets
  re-encoded (~480p, 720p with HD toggle); sending "as a document" preserves
  quality up to ~2GB [secondary sources: filesize.org/limits/whatsapp,
  usecarly.com/blog/whatsapp-file-size-limit]. Status video length reported as
  raised to **90 seconds** in a mid-2025 rollout [secondary source only,
  green-api.com/en/blog/2025/whatsapp-increases-status-length-to-90-seconds —
  **could not confirm on whatsapp.com's own FAQ this session, treat as
  UNVERIFIED**]. Practical rule until re-verified: keep a WhatsApp-bound clip
  well under these numbers and re-encode with `sampadak`'s `shrink` if in doubt.
- **Hindi voiceover** — use Piper's `hi_IN-pratham-medium`/`hi_IN-priyamvada-medium`
  via Vaani; know going in that Whisper-family STT (if transcribing Hindi back)
  is noticeably rougher than English at the `small` tier — not Naad's problem to
  fix, but worth knowing if a round-trip (voice -> transcript -> re-edit) is asked for.

## 6. Known traps on a phone
- **Confirm the input actually HAS the audio track being touched** before
  writing a `duck`/`loud`/`desilence` command — a silent/video-only file will
  make `ffmpeg` fail confusingly otherwise.
- **loudnorm's silent sample-rate change** — always let `vedit` pin `-ar 48000`;
  don't strip that flag "to make the command shorter."
- **Paths with spaces/colons** need care in shell — `vedit` itself is the safe
  wrapper; if a path is unusual (spaces, Devanagari filename — both fine per
  our path validator, see `ai-termux.py` `_RX_PATHCHAR`, unicode-aware), quote it.
- **`termux-setup-storage`** must have been run once for the phone's file picker
  to expose `/sdcard`/shared storage to Termux at all — if a file "doesn't
  exist" that the user swears is on their phone, this is the first thing to ask.
- RAM/thermal: `ffmpeg` audio-only filters (`duck`/`loud`/`desilence`) are far
  cheaper than video re-encodes — safe to run repeatedly without the heat
  concerns `sampadak`'s video ops carry.

## 7. Cheat-sheet (hand to the model verbatim)
```
Three named ops ONLY: duck (music under voice) / loud (2-pass -16 LUFS) /
  desilence (cut all dead air, not just the start).
duck order: vedit duck <voice> <music> <out> -- voice is input1, music input2.
loud/desilence: vedit <op> <infile> <outfile>.
Never invent a filter_complex outside these three -- if the ask needs one,
  say "yeh named recipe se bahar hai, main pattern se draft karta hoon,
  test karke confirm karna" and hand back a DRAFT, not a confident answer.
Confirm the input file's audio track exists before writing any command.
Podcast-from-documents ask -> NotebookLM has no API ever; offer ElevenLabs
  GenFM (paid) or Vaani+vedit (free, offline) -- both, honestly, not silently
  picking one.
```

## 8. The ladder when the best tool is absent
Rung 1: `ffmpeg_local` → `vedit` — **real, offline, already wired**, one of the
best-supported capabilities in the whole pack (per `EXPERT-PACK.md` BLUNT
ASSESSMENT: upgraded to GOOD once named recipes shipped). Outside the 3 named
recipes → rung 4: the local brain drafts a new `ffmpeg` command from the
pattern shown in §2 — hand it back explicitly labelled **DRAFT / untested**,
never as a confident answer, since a wrong filter flag here is a silent-failure
risk (ffmpeg often exits 0 on a malformed filter with no output changed).
Never claim "I can't" — the honest floor is always "here's a draft command, test it."

## Sources
- `fold-node/research/toolkit-vetting-2026.md` §4 (ffmpeg recipes, verified against ffmpeg.org)
- https://ffmpeg.org/ffmpeg-filters.html#sidechaincompress · #loudnorm
- `fold-node/termux/setup-menu.sh` lines 266-334 (`menu_vedit`, the real `vedit` script)
- `fold-node/tools-routing.json` (`audio_overlay` → `ffmpeg_local`; `tts`/`audio_overview` ladders)
- `fold-node/research/capability-providers-routing-2026.md` §1-2 (NotebookLM no-API finding, ElevenLabs GenFM)
- https://github.com/OHF-Voice/piper1-gpl/blob/main/docs/CLI.md (fetched 2026-09-06)
- https://huggingface.co/rhasspy/piper-voices/tree/main/hi/hi_IN (fetched 2026-09-06)
- WhatsApp limits: UNVERIFIED primary, secondary trackers cited inline (§5)
