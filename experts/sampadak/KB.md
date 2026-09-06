# Sampadak — Knowledge Base (video editing: cut/trim/scale/overlay)

## 1. What Sampadak actually is
Sampadak cuts and reshapes EXISTING footage — it never generates video from
nothing (that's `video_generation`, cloud-only, paid, see §4). Its real tool
is `vedit`, the same wrapper Naad uses, wired as the `video_edit` capability
(`tools-routing.json` → `ffmpeg_local`). Eight named ops on the video side —
run `vedit` alone to print usage if unsure of a name.

## 2. The exact recipes (verified against ffmpeg's own filter docs)
Source: `fold-node/research/toolkit-vetting-2026.md` §4 + the live wrapper,
`fold-node/termux/setup-menu.sh` lines 303-318. Primary filter reference:
https://ffmpeg.org/ffmpeg-filters.html

```
vedit cut in.mp4 00:00:10 00:00:25 out.mp4
  -> ffmpeg -i in.mp4 -ss 00:00:10 -to 00:00:25 -c copy out.mp4
  -c copy = no re-encode (fast, lossless); may be a few frames imprecise at
  keyframe boundaries -- acceptable for a trim, not for frame-exact editing.

vedit mp3 in.mp4 out.mp3
  -> ffmpeg -i in.mp4 -vn -q:a 2 out.mp3        (extract audio only)

vedit shrink in.mp4 out.mp4
  -> ffmpeg -i in.mp4 -vcodec libx264 -crf 28 out.mp4
  CRF 28 = noticeably compressed but watchable; lower CRF = bigger+cleaner,
  higher = smaller+worse. Use when a file is too big to send (see §5 WhatsApp caps).

vedit gif in.mp4 out.gif
  -> ffmpeg -i in.mp4 -vf "fps=10,scale=480:-1:flags=lanczos" out.gif

vedit vertical in.mp4 out.mp4
  -> ffmpeg -i in.mp4 -vf "crop=ih*9/16:ih,scale=1080:1920" -c:a copy out.mp4
  Centre-crops to a 9:16 region sized off the source HEIGHT, then scales to a
  clean 1080x1920 -- exactly the shape Reels/Shorts need. If the source is
  ALREADY narrower than 9:16, swap the crop expression to `crop=iw:iw*16/9`
  first (a portrait-shot source needs height-based cropping instead).

vedit subs in.mp4 caps.srt out.mp4
  -> s=$(escape colons in caps.srt path)
     ffmpeg -i in.mp4 -vf "subtitles=${s}:force_style='FontSize=24,
       PrimaryColour=&HFFFFFF&'" -c:a copy out.mp4
  Needs libass (bundled in Termux's own ffmpeg build). Colons in the SUBTITLE
  FILE'S PATH must be escaped (`\\:`) or the filtergraph mis-parses -- vedit
  does this automatically, don't hand-escape it yourself on top.

vedit thumb in.mp4 out.jpg [00:00:03]
  -> with timestamp: ffmpeg -ss 00:00:03 -i in.mp4 -frames:v 1 -y out.jpg
     (fast seek: -ss BEFORE -i)
  -> without:         ffmpeg -i in.mp4 -vf thumbnail -frames:v 1 -y out.jpg
     ("smart" most-representative-frame pick, slower, no seek needed)

vedit join out.mp4 clip1.mp4 clip2.mp4 [clip3.mp4 ...]
  -- OUTPUT FIRST, then 2+ input clips --
  -> builds a concat list, then:
     ffmpeg -f concat -safe 0 -i list.txt -c copy -y out.mp4
  -> if that fails (codecs/res/fps differ): automatically re-encodes instead
     ("[vedit] codecs differ -> re-encoding (slower, always works)")
  Never manually force -c copy yourself on mismatched clips -- vedit already
  tries the fast path and falls back; forcing it just produces a broken file.
```

## 3. Free vs paid — the honest table
| Path | Cost | Offline | Notes |
|---|---|---|---|
| `vedit` (all 8 ops above) | Free | ✅ Yes | Fully wired, always the default for editing existing footage |
| Local video GENERATION | N/A | N/A | **Confirmed CPU-infeasible, full stop** — a single still image already takes 10+ min on this hardware; video diffusion is 10-100x that per frame, no credible offline ARM path exists [GROUNDED, `fold-node/research/offline-tools-vetting-2026.md` §3] |
| **fal.ai** (`FAL_KEY`, `invoke: vgen`) | ~$0.05/s (Wan 2.5) | ❌ Cloud | Cheapest surveyed, our default video_generation entry |
| Kling (`KLING_API_KEY`) | ~$0.075/s | ❌ Cloud | Best quality/price per our own routing note; Chinese vendor — flag as a privacy consideration |
| Replicate (`REPLICATE_API_TOKEN`) | Model-dependent | ❌ Cloud | Broad catalog, our fallback |
[GROUNDED, `fold-node/tools-routing.json` `video_generation` ladder + pricing notes,
cross-checked with `fold-node/research/offline-tools-vetting-2026.md` §3, §5]

## 4. Video generation — the one thing Sampadak must never attempt locally
If asked to GENERATE (not edit) video: say plainly it's cloud-only and paid.
Our wired script is `vgen "a prompt"` (`fold-node/termux/setup-menu.sh` line
346-360) — it prints "[vgen] CLOUD job... this costs money on Replicate, not
your Claude limit" before submitting, on purpose, so the cost is never a
surprise. Sampadak should surface that same warning, every time, no exceptions.

## 5. Indian-context specifics
- **`vertical` (9:16, 1080x1920) is the direct Reels/Shorts requirement** —
  this is the single most-used op for Jhalak/Prasar's format needs.
- **WhatsApp media limits** [flagged UNVERIFIED against WhatsApp's own FAQ —
  the official help-center page did not load via fetch this session; sourced
  from secondary trackers instead]: video sent inline via the gallery caps
  around **16MB** and gets re-encoded to roughly 480p (720p with the HD
  toggle); sending "as a document" preserves quality up to ~2GB [secondary:
  filesize.org/limits/whatsapp, usecarly.com/blog/whatsapp-file-size-limit].
  If a clip is meant for WhatsApp sharing and looks large, run `vedit shrink`
  (CRF 28) first, or advise sending as a document instead of gallery media.
  Status video length was reported raised to **90 seconds** in a mid-2025
  update [secondary source only, green-api.com — **could not confirm on
  WhatsApp's own help center this session, treat as UNVERIFIED**]; a much
  older report also shows a 15-second India-specific status limit
  (techradar.com, 2019) — the two claims may both be stale. Don't quote either
  as current fact; say "check WhatsApp's own current status length before
  relying on this."
- **Devanagari subtitles via `subs`** — ffmpeg's `subtitles` filter uses
  libass, which is bundled in Termux's official ffmpeg build [GROUNDED,
  `termux/termux-packages/packages/ffmpeg/build.sh`, cited in
  `toolkit-vetting-2026.md` §4]. Rendering quality depends on the SRT file's
  own font settings and whatever Devanagari-capable font libass finds on the
  system — **not independently verified this session which font ships by
  default on a stock Termux install**; if Hindi subtitle glyphs render as
  boxes/tofu, the fix is installing a Devanagari font (e.g. Noto Sans
  Devanagari) and pointing `force_style='FontName=...'` at it — flag this as
  the likely fix rather than a dead end.

## 6. Known traps on a phone
- **RAM/thermal on re-encodes** — `shrink`/`vertical`/`join`(re-encode path)/
  `subs` all re-encode video, the heaviest ops in this set. Real cost per the
  on-device inference research: sustained CPU work throttles a phone's
  performance cores measurably within minutes [GROUNDED, arXiv:2410.03613,
  cited in `fold-node/research/cherry-pick/05-ondevice-inference.md` — this
  number is for LLM inference specifically, but the same thermal mechanism
  (sustained CPU load) applies to video re-encoding; flag the pattern, don't
  quote the LLM-specific tok/s numbers for ffmpeg]. Warn on a long/heavy job:
  "yeh phone garam ho sakta hai, thoda time lagega."
- **`termux-setup-storage`** must have run once for `/sdcard`/shared storage
  paths to be visible to Termux at all — first thing to check if a file
  "doesn't exist."
- **Never overwrite the source file in place without saying so first** —
  even a "just fix this video" ask gets a one-line heads-up before an in-place op.
- **`cut`'s `-c copy` can land a few frames off** at non-keyframe boundaries —
  fine for a rough trim, not for frame-exact cuts; say so if precision is asked for.
- **Colons in subtitle-file PATHS** need escaping in the ffmpeg filter arg —
  `vedit subs` already does this automatically; don't hand-escape on top of it.

## 7. Cheat-sheet (hand to the model verbatim)
```
8 named ops: cut / mp3 / shrink / gif / vertical / subs / thumb / join.
  Unsure of exact syntax? Run `vedit` alone -- it prints usage.
vertical = 9:16 crop+scale (1080x1920), the Reels/Shorts op.
join = OUTPUT FIRST, then 2+ input clips; auto re-encodes if codecs differ --
  never force -c copy yourself on mismatched clips.
subs = colons in the .srt path get escaped automatically, don't double-escape.
thumb = timestamp given -> fast seek; no timestamp -> "smart" frame, slower.
GENERATE video (not edit) -> say plainly: cloud-only, paid (fal ~$0.05/s,
  Kling ~$0.075/s, Replicate) -- never attempt it locally, no exceptions.
Never overwrite the source file in place without a heads-up first.
```

## 8. The ladder when the best tool is absent
`video_edit` rung 1: `ffmpeg_local` → `vedit` — **real, offline, already
wired with 8 verified recipes** (per `EXPERT-PACK.md` BLUNT ASSESSMENT: GOOD,
upgraded once named recipes shipped — "the residual risk moved from
hallucinated filter flags to picked-the-wrong-recipe-name — much cheaper to
get wrong"). `video_generation` has **no offline rung at all** — below
cloud-paid there is nothing; Sampadak says this plainly rather than trying a
local workaround that is confirmed not to work (§1, §4).

## Sources
- `fold-node/research/toolkit-vetting-2026.md` §4 (ffmpeg recipes, verified against ffmpeg.org)
- https://ffmpeg.org/ffmpeg-filters.html
- `fold-node/termux/setup-menu.sh` lines 266-360 (`menu_vedit`, `menu_vgen` — the real scripts)
- `fold-node/tools-routing.json` (`video_edit` → `ffmpeg_local`; `video_generation` ladder)
- `fold-node/research/offline-tools-vetting-2026.md` §2-3 (CPU-infeasibility of local video/image gen)
- `fold-node/research/cherry-pick/05-ondevice-inference.md` (thermal-throttling mechanism, arXiv:2410.03613)
- WhatsApp limits: UNVERIFIED primary source, secondary trackers cited inline (§5)
