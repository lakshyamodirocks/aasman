# Prasar — YouTube Knowledge Base

> SHODH | fetched 2026-09-06. Primary = support.google.com/youtube (YouTube Help), Google's own
> India blog. Secondary/converging noted **[MED]**. **VOLATILE** = policy changed within 12mo.

## 1. Hard limits (counted values)

| Field | Limit | Source |
|---|---|---|
| Title | 100 characters max; only ~60 shown in search/suggested results | Max=[MED-secondary, no single support.google.com page with the literal number was fetched this session]; the ~60-visible figure is [MED-secondary] |
| Description | **5,000 characters max** | [GROUNDED — fetched support.google.com/youtube/answer/12948449] |
| Description visible before "Show more" | first few lines / ~150-160 chars | [GROUNDED for "first few lines" wording, fetched; the exact char count ~150-160 is [MED-secondary]] |
| Tags | 500 characters total across ALL tags combined, including the commas/quotes between multi-word tags | [MED-secondary, converging across multiple 2026 tag-guide sites; no support.google.com page with this exact figure was fetched this session — flag as the weakest-grounded number in this file] |
| Chapters | first stamp must be `00:00`; minimum 3 timestamps; minimum 10 seconds per chapter; ascending order | [GROUNDED via search summary of support.google.com/youtube/answer/9884579 — recommend a direct fetch before treating the "10 seconds" figure as final] |
| Thumbnail | 1280×720 (16:9), min width 640px; keep under 2MB for safety | [MED-secondary]. A 2026 expansion to a 50MB cap (4K thumbnails for smart-TV surfaces) is reported but rolling out unevenly — [MED-secondary, not confirmed for this account] |
| Thumbnail requires | a verified channel to use a custom (non-auto-picked) thumbnail | [MED-secondary] |

## 2. Shorts — the eligibility rule that changed in 2024, still current 2026

[GROUNDED — fetched support.google.com/youtube/answer/15424877 directly]: **any video with a
square or vertical aspect ratio, up to 3 minutes long**, is automatically categorized as a Short.
This applies to standard channels for uploads made on or after **2024-10-15**; Official Artist
Channels got the same rule for uploads from **2025-12-08**. **Consequence that matters for
Sampadak's `vertical` recipe:** a vertical or square video that was meant as a regular long-form
upload will get auto-classified as a Short unless it's rendered at a wider aspect ratio (16:9)
instead — this is a real, easy mistake, not a hypothetical.

Monetization for Shorts specifically requires the general YPP bar: **1,000 subscribers + 10
million qualified Shorts views in the last 90 days**, OR **1,000 subscribers + 4,000 watch hours
in the last 12 months** [MED-HIGH — surfaced via search of support.google.com/youtube/answer/72851
and related YPP pages, not independently re-fetched with a direct WebFetch this session]. Shorts
carrying an active copyright claim over 1 minute are blocked from monetization globally
[MED-secondary].

## 3. AI-disclosure ("altered or synthetic content" label) — the exact boundary

[GROUNDED — fetched support.google.com/youtube/answer/14328491 directly]. **Requires disclosure**
(realistic content that could mislead about a real person/event): AI-generated music presented as
real; making it look like someone gave advice they didn't give; AI-generated extra footage of a
real place inserted into real footage; depicting a real public figure doing something they didn't
do. **Does NOT require disclosure**: caption generation, beauty filters, color/lighting
adjustment, **cloning one's own voice for a voiceover or dub**, non-realistic animation (even of
a real-world object like a missile, in a fully animated video), gameplay footage.

**Correction/precision for Prasar's own persona claim:** the confirmed exemption is specifically
"cloning **one's own** voice." A **generic synthetic TTS voice that is not a clone of any real
person** (e.g. Piper's default voices) falls even further from the "realistic depiction of a real
person" trigger and by the same logic should not need disclosure — but this exact case (a
non-cloned, generic synthetic voice) is **not named explicitly** in the fetched policy text.
[INFERRED from the stated boundary, not itself GROUNDED — flag this precision gap rather than
stating the broader claim as flatly confirmed.]

## 4. Community Guidelines enforcement (official)

[MED-HIGH — surfaced via search of support.google.com/youtube/answer/185111, not independently
re-fetched with a direct WebFetch this session]: first violation = a **warning**. Second = a
**strike**. One active strike = no uploads/livestreams/Stories/custom thumbnails/posts for **one
week**. Strikes expire after **90 days**. **Three strikes within 90 days = channel termination.**
Appeal window: 6 months for a warning/strike, 1 year for a content removal.

## 5. What YouTube itself says gets a video recommended (official)

[MED-HIGH — surfaced via search of support.google.com/youtube/answer/16089387, /16533387,
/141805, summarized from search-tool output, none individually re-fetched with a direct WebFetch
this session]: YouTube explicitly reframes "beating the algorithm" as **serving what the specific
audience already watches and enjoys** — viewer-satisfaction surveys are folded in alongside raw
watch time, not watch time alone. Concrete, official levers named: **session continuation**
(playlists, end screens, "watch next" CTAs, content series that keep a viewer watching past one
video), and **channel depth** — a new viewer who finds one good video and then finds a library of
other high-quality videos is a stronger recommendation signal than one video in isolation.

## 6. Description-writing guidance (official)

[GROUNDED, fetched support.google.com/youtube/answer/12948449]: front-load the first few lines
because that's what's visible before "Show more." Pick **1-2 main keywords** that genuinely
describe the video and put them in both title and description; YouTube points creators to its own
Analytics "Research" tab and Google Ads Keyword Planner for real (not guessed) keyword signals —
this is the same discipline Sandhan's persona should be applying, cross-referenced here since
Prasar's title/description work and Sandhan's SEO pass overlap.

## 7. India creator context

- Regional-language content (Tamil, Telugu, Bengali, Punjabi, etc.) is growing roughly **3x
  faster** than English-language content on YouTube India, and regional-language watch time is
  now **over 60%** of total India watch time. [MED-HIGH — Google's own India blog,
  blog.google/intl/en-in, via search this session, not independently re-fetched — the number is
  Google's own claim about its own platform, treat as strong but not re-verified]
- The Hindi-content space is described (by industry commentary, not YouTube itself) as
  increasingly saturated/production-value-competitive, while creators in Odia, Assamese, Kannada
  etc. are described as finding faster-growing, less-contested audiences with lower production
  cost. [SECONDARY, industry commentary, not a YouTube-published fact — present as an observation,
  not a platform rule]
- Indian YouTube creator ad revenue: ~$1.9B in 2025, ~44% YoY growth, projected to cross $2.6B by
  end of 2026. [SECONDARY, industry-aggregator figures — not from YouTube's own investor/creator
  reporting this session, flag accordingly]
- Reels vs Shorts in India: Reels leads short-form *preference* per an IPSOS-cited aggregation;
  Shorts usage is growing fast and closing the gap in specific categories (education, evergreen
  content — Shorts' searchability/longevity is the cited reason). [MED-secondary, not a platform
  primary source]

## 8. Cheat sheet (hand this to the model verbatim)

1. Title ≤100 chars hard limit; write for the ~60 visible in search — front-load the real keyword.
2. Description ≤5,000 chars; put the actual 2-3 real sentences (not filler) in the first few
   lines — that's all that's visible before "Show more."
3. Tags: keep the total across all tags ≤500 chars including separators — count it, don't guess.
4. Any square/vertical video ≤3 minutes auto-becomes a Short — use 16:9 if that's NOT wanted.
5. Chapters: first stamp `00:00`, ≥3 stamps, each chapter ≥10 sec, ascending order.
6. Thumbnail: 1280×720, min width 640px, keep <2MB unless the account is confirmed on the newer
   50MB/4K rollout; avoid the bottom-right corner (duration badge sits there).
7. AI-disclosure toggle: turn ON only for realistic depictions that could mislead about a real
   person/event/advice/place. Turn it OFF (not needed) for captions, filters, own-voice cloning,
   non-realistic animation, gameplay. A generic non-cloned synthetic voice is very likely also
   exempt but say "likely, not explicitly confirmed" rather than stating it flat.
8. Community Guidelines: warning → strike → 1-week freeze per strike → 3 strikes/90 days =
   termination. Never treat a first flag as harmless; it's already a warning on the record.
9. Never reuse the identical file already posted to Instagram — confirm a 16:9-or-vertical,
   platform-adapted render exists (Sampadak's job) before handing off.
10. Recommendation signals YouTube itself names: session continuation (playlists/end
    screens/series) and channel depth — recommend these, not vague "post more" advice.
11. Zero-subscriber channels are not structurally blocked from Shorts recommendation — the seed
    test applies regardless of subscriber count; say so if the human sounds discouraged.
12. State every count computed — never say a field "should fit."

## Ladder (unchanged from `experts.json`)

`caps`: `research`, `brain_only`. `needs`: no YouTube posting-API wired (Data API OAuth not set
up). `fallback`: hand back the ready-to-upload package (title + description + tags + file);
upload itself is rung 3 — manual, via studio.youtube.com — until OAuth exists (see
`fold-node/SOCIAL-PIPELINE.md` §3 for the Testing-mode-vs-verified-app tradeoff when that's built).

## Sources (fetched or searched this session, 2026-09-06)

**Directly WebFetched this session (highest confidence):** support.google.com/youtube/answer/
12948449, /14328491, /15424877.
**Search-tool summaries only, not independently WebFetched (MED-HIGH, not GROUNDED):**
support.google.com/youtube/answer/185111, /72851, /16089387, /16533387, /141805,
blog.google/intl/en-in.
**Secondary/converging creator-tool guides (MED):** multiple 2026 tag/thumbnail-guide sites,
named inline where used.
