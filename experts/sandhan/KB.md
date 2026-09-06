# Sandhan — KB (SEO base, fragile-by-design)

> Sourced 2026-09-06. This domain is explicitly the most volatile of the three (per EXPERT-PACK.md
> BLUNT ASSESSMENT: "no dedicated research exists, ranking rules change faster than any model's
> training stays current"). Every claim below is tagged with WHERE it comes from — Google/Bing's
> own docs, or third-party ("folklore" until checked). **Rule for this expert: never state a
> ranking-factor claim without saying which bucket it's in.**

## 1. Evergreen technical basics [GROUNDED — primary, stable for years]

These do not churn quarter to quarter; safe to state without a fresh check:
- One clear, unique `<title>` per page; one meta description (Google may rewrite it in the
  snippet, but it should still exist and be accurate).
- Descriptive `alt` text on meaningful images (accessibility + image search).
- An XML sitemap, submitted via Search Console; a clean `robots.txt` that doesn't block content
  you want indexed.
- Fast load time, mobile-friendly layout, HTTPS, crawlable links (real `<a href>`, not JS-only).
- Unique, genuinely useful content per page — not spun/duplicate text.

## 2. Core Web Vitals — verified against Google's OWN page [GROUNDED, primary]

Source: developers.google.com/search/docs/appearance/core-web-vitals (fetched 2026-09-06).
Current thresholds, **exactly as the page states them today**:
- **LCP (Largest Contentful Paint):** within **2.5 seconds** of the page starting to load.
- **INP (Interaction to Next Paint):** less than **200 milliseconds**.
- **CLS (Cumulative Layout Shift):** less than **0.1**.
The page's own words on ranking: Core Web Vitals "along with other page experience aspects,
aligns with what our core ranking systems seek to reward" — i.e. a supporting signal among many,
not stated as a dominant ranking factor.

**Adversarial catch, worth naming explicitly (this is exactly the failure mode this expert exists
to avoid):** several 2026 SEO-agency blogs (capsicummediaworks.com, ideafueled.com, techvedhas.com)
claim "LCP threshold tightened from 2.5s to 2.0s in Google's March 2026 core update." **Fetched
Google's own Core Web Vitals doc directly on 2026-09-06 — it states 2.5s, with no mention of any
2026 change.** Verdict: that "2.0s" claim is **UNVERIFIED / likely folklore** — probably a
misreading of Google's separate "good LCP" internal target range or an unrelated tool's own
threshold, repeated across secondary blogs without a primary citation. **Never repeat the 2.0s
number as fact** — this is the textbook case of exactly the rot this KB warns about.
INP replaced FID in **March 2024** — that one IS a confirmed, dated, real change (multiple
converging secondary sources plus Google's own historical announcement), unlike the 2.0s claim.

## 3. Structured data — what's real, what's retired [GROUNDED, primary, dated]

Source: developers.google.com/search/docs/appearance/structured-data/intro-structured-data
(page dated last-updated 2025-12-10 UTC, fetched 2026-09-06).
- JSON-LD is Google's recommended format ("easiest to implement and maintain").
- **Do not** mark up invisible/hidden content, and don't create pages solely to hold structured
  data — this breaks Google's structured-data guidelines and can cost eligibility.
- Use the Rich Results Test to validate during development.
- **Types that still matter (still eligible for rich results as of this check):** Article,
  Product, Review, LocalBusiness, Event, JobPosting, Breadcrumb, Recipe, VideoObject.
- **Confirmed retirements (primary-sourced):**
  - **FAQPage rich result:** retired from Google Search results as of **May 7, 2026** (announced
    8 May 2025, removed from docs 15 June 2026 per Google's own changelog). **The schema markup
    itself is NOT deprecated** — leaving it on a page causes no error, it just no longer produces
    a rich result. Don't tell a client to rip it out in a panic; just don't expect the visual perk.
  - **HowTo rich result:** deprecated on desktop **September 2023** (after an earlier mobile
    limitation) — no longer shown on any device. Old news, but still gets asked about — say so
    plainly if a client references an old guide.
  - Google announced retirement of 7 more types on **12 June 2025**: Book Actions, Course Info,
    ClaimReview, Estimated Salary, Learning Video, Special Announcement, Vehicle Listing
    (secondary-sourced, SearchEngineJournal — treat the list as MED confidence until you fetch
    Google's own changelog for a client who actually uses one of these).

## 4. AI Overviews / AI Mode — verified against Google's OWN guidance [GROUNDED, primary, dated]

Source: developers.google.com/search/docs/appearance/ai-features (last updated **2025-12-10 UTC**,
fetched 2026-09-06). This is the single most important 2025-26 change and the most-hyped by SEO
blogs — so it's the one most worth quoting verbatim rather than paraphrasing:
> "There are no additional requirements to appear in AI Overviews or AI Mode, nor other special
> optimizations necessary... You don't need to create new machine readable files, AI text files,
> or markup to appear in these features. There's also no special schema.org structured data that
> you need to add."
What Google DOES say to do: follow existing fundamentals (crawlable robots.txt, helpful
people-first content, good page experience, keep important content in real text not just images,
structured data that matches visible content). `nosnippet`/`data-nosnippet`/`max-snippet`/
`noindex` still control AI-feature inclusion, same as classic snippets.
**Separate Google blog claim (developers.google.com/search/blog/2025/05):** AI Overview clicks
are reportedly "higher quality" (more time on site) — this is Google's own claim about its own
product, treat as MED confidence (self-reported, not independently audited) even though it's a
primary source.
**Practical read for sandhan's persona:** "AEO/GEO" (AI-engine-optimization / generative-engine
optimization) as a *separate discipline requiring new markup* is, per Google's own primary
statement, **not true** — it's the same SEO fundamentals. Say this directly when a client asks to
buy "AI SEO" services distinct from normal SEO.

## 5. Bing — what's actually primary-sourced [PARTIAL — flagged honestly]

Bing does not maintain as centralized/citable a documentation hub as Google's Search Central.
Bing's own Webmaster Guidelines exist at bing.com/webmasters/help — **attempted direct fetch
2026-09-06, page did not yield extractable ranking-factor text this session; treat Bing specifics
below as MED confidence, aggregated-secondary, not independently primary-verified this run.**
Commonly repeated (multiple SEO-agency sources, converging but not primary-confirmed): Bing gives
relatively more weight to exact-match keywords and social signals (LinkedIn specifically, given
Microsoft ownership) than Google does; backlinks from aged/.edu/.gov domains matter more than raw
volume; site speed and HTTPS matter as with Google. **Do not present these as confirmed facts to
a client** — say "commonly reported, not independently verified against Bing's own docs this
session" if it comes up, and re-check bing.com/webmasters/help directly before relying on it.

## 6. The "fragile" warning, made explicit

Which of THIS FILE's own answers are most likely to rot first, ranked:
1. **Any specific number** (LCP/INP/CLS thresholds, retirement dates) — Google changes these with
   no advance notice pattern; re-verify before quoting to anyone beyond a casual mention.
2. **"What still gets rich results"** — the retirement list (§3) is a snapshot; Google has retired
   7+ types in the 12 months before this file was written. Assume more will go.
3. **AI Overview/AI Mode guidance** (§4) — this is the newest, fastest-moving area; the May 2026
   "generative AI optimization guide" itself may be updated again within months.
4. **Least fragile:** the evergreen basics (§1) — these haven't meaningfully changed in years and
   are the safe fallback when nothing else can be verified.
**Rule: before asserting anything in buckets 1-3 to a real client, run `/do research` fresh and
say you did.** This file is a starting KB, not a permanent oracle.

## 7. Cheat-sheet

1. Evergreen basics (title/meta/alt/sitemap/speed) — safe to state without checking.
2. LCP 2.5s / INP 200ms / CLS 0.1 — verified 2026-09-06 against Google's own page; re-verify if
   this file is more than a few months old when read.
3. The "LCP now 2.0s" claim floating on SEO blogs — checked against primary source, NOT confirmed.
   Don't repeat it as fact.
4. FAQPage/HowTo rich results are dead in the SERP; the schema markup itself is harmless to leave.
5. AI Overviews need NO special markup — this is Google's own stated position, not a guess.
6. "AEO/GEO as separate from SEO" — Google's own docs say no, it's the same fundamentals.
7. Bing specifics are MED-confidence secondary — flag this every time, don't upgrade it silently.
8. Self-check before every ranking-factor sentence: is this dated 2026-09-06 or earlier from a
   primary source, or is it something I "just know"? If the latter — say unverified, don't assert.

## 8. No-dead-end ladder

1. **Online, `/do research` works** → check the specific claim fresh (Google Search Central
   changelog: developers.google.com/search/updates is the single best page to check first — it
   lists every doc change with a date).
2. **Online, `/do scrape` works, research degraded** → fetch the client's actual page, check
   title/meta/alt-text/structured-data presence directly — that's a real check even without a
   research call.
3. **Fully offline** → answer from this KB, state its date (2026-09-06) explicitly, and flag
   which section (per §6) is most likely to have moved since.
4. **A ranking-factor question this KB doesn't cover** → say "unverified — check current Google
   Search Central docs" in those words. Never guess a plausible-sounding ranking rule.

## Sources
- developers.google.com/search/docs/appearance/core-web-vitals (fetched 2026-09-06)
- developers.google.com/search/docs/appearance/structured-data/intro-structured-data (last
  updated 2025-12-10 UTC per page; fetched 2026-09-06)
- developers.google.com/search/docs/appearance/structured-data/faqpage (changelog entries 8 May
  2025 / 15 Jun 2026; fetched 2026-09-06)
- developers.google.com/search/docs/appearance/ai-features (last updated 2025-12-10 UTC; fetched
  2026-09-06)
- developers.google.com/search/blog/2025/05/succeeding-in-ai-search
- developers.google.com/search/blog/2026/05/a-new-resource-for-optimizing
- developers.google.com/search/updates (Google's own changelog — check this first for anything new)
- searchenginejournal.com/google-is-not-diminishing-the-use-of-structured-data-in-2026 (secondary,
  7-type retirement list, MED confidence)
- bing.com/webmasters/help (primary location — not independently fetched successfully this
  session; Bing specifics in §5 are secondary/aggregated, flagged accordingly)
