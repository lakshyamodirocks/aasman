# Jhalak — Instagram Knowledge Base

> SHODH | fetched 2026-09-06. Primary = Meta's own help.instagram.com, about.instagram.com,
> creators.instagram.com, transparency.meta.com. Where only converging secondary sources exist
> (no primary confirmed this session), marked **[MED]**/**[SECONDARY]** — never presented as fact.
> **VOLATILE** = Meta changed this in the last 12 months; expect it to move again.

## 1. Hard limits (counted values, not vibes)

| Field | Limit | Source |
|---|---|---|
| Caption | 2,200 characters | [MED-secondary, converging char-counter tools; no single help.instagram.com page states this number in the text this session could fetch] |
| Caption preview before "…more" | ~125 characters | [MED-secondary] |
| Bio | 150 characters, unchanged since 2016 | [MED-secondary, multiple converging] |
| Bio links | up to 5 (as of July 2026); a link-in-bio page in one slot makes it effectively unlimited | [MED-secondary, converging 2026 guides] |
| Story link sticker | 1 per Story slide, no follower minimum | [MED-secondary] |
| Hashtags — **VOLATILE, conflicting sources, read carefully** | see §2 | mixed |

**Character-counting caveat (matters for Prakashan too):** secondary sources report an emoji
"counts as 2 characters" against the caption/bio limit — consistent with a client that counts
UTF-16 code units rather than visible characters. **[MED, not confirmed against Meta's own
docs this session]** — treat as the safe assumption, not a verified fact.

## 2. Hashtags — the conflict, stated plainly

- **help.instagram.com's own "Use hashtags on Instagram" article** — search-result snippet of
  this page states *"You can use up to 30 tags on a post."* **Adversarial catch, self-corrected:**
  a direct `WebFetch` of `help.instagram.com/351460621611097` this session returned an EMPTY page
  shell (the article is client-rendered; the fetcher only saw a bare "Help Center" header, no
  body text) — so despite an earlier draft of this file citing that quote as "direct fetch,
  GROUNDED," it is **not** independently confirmed by this session's own fetch. Downgraded
  honestly to **[MED-secondary — search-snippet only, not verified by direct fetch]**.
- **What IS independently confirmed:** Instagram's official `@creators` account and Adam Mosseri
  (head of Instagram) announced on **2025-12-19** that every post and Reel is capped at
  **5 hashtags** — hashtags beyond the 5th are ignored; splitting between caption and comment does
  not add slots. [MED-HIGH — official-account announcement, reported converging across Social
  Media Today, TechBuzz, and 6+ 2026 creator-tool guides — still secondary reporting OF a primary
  announcement, not a fetch of the announcement itself]
- **Working rule for this product: enforce 5, always**, regardless of which of the two numbers
  above is "more current" — going over 5 wastes effort even if the platform silently ignores
  rather than blocks the extras, and the Dec-2025 cap is the more recently and more widely
  reported figure.
- Numbers are allowed in hashtags; spaces and symbols (`$ %`) are not. [MED-secondary,
  search-snippet — same unresolved direct-fetch gap as above, flagged not hidden]
- Hashtagged posts only appear on hashtag pages if the account is public. [GROUNDED, help.instagram.com]

## 3. Reels specs

| | |
|---|---|
| Aspect ratio / resolution | 9:16, 1080×1920 for full-screen Reels-tab playback | [MED-secondary, converging 2026 guides] |
| In-app recording length | up to 3 minutes on most accounts; some still capped at 90s (gradual rollout) | [MED-secondary] |
| Upload-from-gallery length | up to 20 minutes, ~4GB | [MED-secondary; the 4GB figure is Meta's **ads-spec** number, not a confirmed organic-post cap] |
| **Algorithmic reach cliff** | Instagram states directly: Reels over 3 minutes "will not be recommended to new audiences" | [MED-secondary, widely quoted; not independently fetched from Meta's own copy this session] |
| Safe zone | keep key text/logos out of top ~220px and bottom ~450–455px of a 1080×1920 frame (roughly top 14% / bottom 35% / sides 6%) | [MED-secondary] |
| Cover image | Meta's own recommended cover size is 420×654px; uploading at 1080×1920 gives a sharper result | [MED-secondary] |
| Format | MP4, H.264, AAC audio, 30fps | [MED-secondary] |

## 4. Trial Reels — correction to earlier org assumption

Officially launched 2024-12-10 (about.fb.com / creators.instagram.com, both fetched this
session) [GROUNDED]. Non-followers see the Reel first; creator sees engagement metrics after
~24h and a share/no-share signal at 72h; can auto-share to followers if it clears an internal
performance bar. **Eligibility, corrected:** expanded in early 2026 to **professional (business/
creator) accounts with at least 1,000 followers** — personal accounts are NOT eligible.
[MED-secondary, not stated in the two primary pages fetched directly, which said only "all
eligible creators... see Help Center for eligibility" — flag as [MED] not [GROUNDED] until a
direct Help Center eligibility page is fetched.] **Do not tell a brand-new/small account it can
use Trial Reels without checking current eligibility first.**

## 5. What Instagram itself says ranks content (official, fetched)

Source: about.instagram.com/blog/announcements/instagram-ranking-explained (2023-05-31,
[GROUNDED, direct fetch] — Meta has not republished a newer version this session found; treat
the ORDER as durable, the exact wording as possibly refreshed since).

**Feed**, in rough order: (1) your own past activity — likes/shares/saves/comments; (2) post
info — likes/comments/shares/saves count, post time, location; (3) creator info — how often
you've interacted with them recently; (4) mutual interaction history.

**Reels**, in rough order: (1) your own past Reels activity; (2) your interaction history with
that creator; (3) Reel info — audio, visuals, popularity; (4) creator info — followers,
engagement level. Instagram explicitly **deprioritizes**: low-resolution or watermarked Reels,
muted or bordered Reels, majority-text Reels, and Reels already posted elsewhere on Instagram.

## 6. Engagement bait and demotion — official, from Meta's Transparency Center

[GROUNDED, transparency.meta.com/features/approach-to-ranking/content-distribution-guidelines/
engagement-bait, fetched directly] — Meta's exact definition: *"Posts that explicitly request
engagement (such as votes, shares, comments, tags, likes or other reactions) for purposes other
than a specific call to action."* Named categories: **vote baiting** ("Comment YES if you
agree"), **tag baiting** ("tag a friend who..."), **share baiting**, **comment baiting**
("comment a specific word/emoji to unlock..."). **Exempt:** genuine asks tied to a real cause —
missing persons, disaster info, fundraising, petitions.

Also demoted [MED-secondary, converging off Meta's public Transparency Center pages]:
sensationalized-claim clickbait, content already debunked by fact-checkers, and **visibly
watermarked reposts** — a visible TikTok/YouTube logo burned into a video signals it was ported
over rather than made for Instagram, and gets reduced reach.

## 7. Scheduling

Native in-app scheduling exists (rolled out ~March 2026): schedule directly from the
Post/Reel composer, or via Meta Business Suite, or a third party. Up to **25 posts/day**, up to
**75 days ahead**. **Private accounts cannot schedule.** Licensed trending-audio tracks
sometimes can't attach to a scheduled Reel — creators who need trending audio often post
manually instead. [MED-secondary, converging 2026 guides, not independently fetched from a
single Meta page this session]

## 8. Community-guideline traps (what actually gets a post buried or removed)

- Engagement-bait phrasing (§6) — reach cut, not removal, but real and automatic.
- Buying followers/likes/comments — explicit ToS violation, account-level risk, not just a post.
- Visible cross-platform watermark — demoted (§6); re-render clean before cross-posting (Sampadak's job).
- Contests/giveaways without following the platform's own promotion guidelines — flagged as
  "content people broadly tell us they dislike," same bucket as engagement bait [MED-secondary].
- Hashtag-stuffing past 5 — no longer a growth tactic, may read as spammy to a human reviewer
  even though the platform just silently ignores the extras (§2).
- Posting to a private account and expecting hashtag/Explore discovery — structurally impossible;
  hashtag pages only show public posts (§2).

## 9. India creator context

- Reels leads short-form format *preference* in India per an IPSOS-cited industry aggregation,
  but YouTube Shorts usage is growing fast and closing the gap in several categories.
  [MED-secondary, not a Meta or Google primary source]
- Regional-language content (Tamil/Telugu/Bengali/Punjabi etc.) is growing roughly 3x faster
  than English-language content on YouTube in India [GROUNDED-adjacent — Google's own India
  blog, blog.google/intl/en-in, via search this session, not independently re-fetched — treat as
  [MED-HIGH]]. The same pattern is widely assumed to hold on Instagram Reels but **no Meta-India
  primary source was found confirming an Instagram-specific number this session** — [UNVERIFIED
  for Instagram specifically].
- Hinglish (code-switched Hindi-English, Latin or Devanagari script) captions are common practice
  in Indian creator content; no platform-published rule treats Hinglish differently from any
  other caption — this is a content/audience choice, not a mechanic.
- **WhatsApp-forward virality:** widely observed anecdotally that Reels/video content spreads via
  WhatsApp Status/forwards in India outside any platform's own analytics — **[UNVERIFIED, no
  Meta-published metric exists for this]**. Never claim a specific WhatsApp-driven reach number;
  it cannot be measured from Instagram's own Insights.

## 10. Cheat sheet (hand this to the model verbatim)

1. Hashtags: exactly ≤5, chosen for topic relevance. Never write "up to 30" — that's stale.
2. Caption ≤2,200 chars; put the actual hook + CTA in the first ~125 chars (that's all shown
   before "…more").
3. Bio ≤150 chars. Bio links: up to 5 slots (a link-in-bio page in one slot = unlimited beyond).
4. Reel: 9:16, 1080×1920, MP4/H.264. Keep it ≤3 min for full algorithmic reach to non-followers.
5. Safe zone: nothing important in the top ~220px or bottom ~450px of a 1080×1920 frame.
6. Never write engagement-bait phrasing: no "comment X if…", "tag 3 friends", "type YES below" —
   Meta's own Transparency Center names these exact patterns as demoted.
7. Never suggest buying followers/engagement — ToS violation, account-level risk.
8. Never hand over a file with a visible TikTok/YouTube watermark burned in — flag for a clean
   re-render first.
9. Trial Reels needs a professional account with ≥1,000 followers [MED] — don't promise it to a
   brand-new or personal account without checking current eligibility.
10. Native scheduling: up to 25/day, 75 days out, in-app or Business Suite; private accounts
    can't schedule; trending audio may not attach to a scheduled Reel.
11. Every caption ends with one specific, genuine question — not a vote-bait phrasing (see #6).
12. State every count you gave — never say "should be under the limit" without the number.
13. Whatever a number's confidence tag says in this file, keep it when you repeat the fact —
    don't upgrade a [MED] to a flat claim just because it's convenient.

## Ladder (unchanged from `experts.json`)

`caps`: `research`, `brain_only`. `needs`: no Instagram posting-API wired (Meta app + review not
set up). `fallback`: hand back a ready-to-post package (caption + ≤5 hashtags + file path);
posting itself is rung 3 — manual, by hand — until a Graph API key + Tester-role setup exists
(see `fold-node/SOCIAL-PIPELINE.md` §3 for the exact automation path when that's built).

## Sources (fetched or searched this session, 2026-09-06)

**Directly WebFetched (highest confidence):** about.instagram.com/blog/announcements/
instagram-ranking-explained · creators.instagram.com/blog/instagram-trial-reels ·
transparency.meta.com/.../engagement-bait.
**Attempted WebFetch, page returned empty/JS-shell content — NOT confirmed by direct fetch
despite an earlier draft of this file claiming otherwise (self-caught, see §2):**
help.instagram.com/351460621611097 — everything sourced from it here is search-snippet-only,
[MED-secondary], not [GROUNDED].
**Search-tool summaries only:** about.fb.com/news/2024/12/trial-reels..., blog.google/intl/en-in/...
**Secondary/converging creator-tool guides (MED):** multiple 2026 sites, named inline above.
