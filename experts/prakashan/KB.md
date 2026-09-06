# Prakashan — Publish-Formatting Knowledge Base

> SHODH | 2026-09-06. This file assumes Jhalak's and Prasar's KB.md as the source of truth for
> platform *limits* — this file is the **counting method** and the **exact per-platform
> mechanical pass**, so a small model (or a stdlib Python validator) executes it the same way
> every time.

## 1. The counting problem, stated precisely

Three different "lengths" exist for the same string, and they disagree the moment emoji or
Devanagari enter the text:

1. **Unicode code points** — what Python 3's `len(s)` counts. One code point per `\uXXXX`/
   `\UXXXXXXXX` value.
2. **UTF-16 code units** — what JavaScript's `.length` counts, and (per [MED, converging
   secondary sources, not confirmed against Meta's own source] Jhalak's KB.md §1) what
   Instagram's own web/app client appears to count against its caption/bio limits. An emoji
   outside the Basic Multilingual Plane (most modern emoji, e.g. 😀 U+1F600) is **1 code point**
   but **2 UTF-16 code units** (a surrogate pair) — this is the entire reason "an emoji counts as
   2 characters" gets reported.
3. **Grapheme clusters** — what a human actually perceives as one visible "character." This is
   the Unicode Standard's own UAX #29 definition, and it is where Devanagari and complex emoji
   diverge hardest from both of the above.

**No platform in this pack (Instagram, YouTube) publishes its own counting algorithm.** Every
number in this file's recommendation is therefore a **safe-conservative rule**, not a confirmed
platform mechanism — flagged as such, not hidden.

## 2. Devanagari — why this is usually wrong, made concrete

A Devanagari "letter" a reader sees is frequently **more than one Unicode code point**:
- A base consonant + a **virama** (् U+094D) to suppress the inherent vowel, often followed by
  another consonant to form a conjunct (e.g. स + ् + त = स्त, "st").
- A base consonant + a **dependent vowel sign / matra** (े, ा, ि, etc. — combining marks that
  attach to the preceding consonant).

Example: **नमस्ते** ("namaste") — a human reads this as roughly 4 visual units (न, म, स्, ते) but
it is **6 Unicode code points**: न, म, स, ्, त, े. `len("नमस्ते")` in Python returns **6**, not 4.
A naive "character count" run on Hinglish-Devanagari text will therefore **overcount** relative
to grapheme clusters — the opposite error direction from the emoji/surrogate-pair case above,
which **undercounts** if you use raw code-point length against a platform that counts UTF-16
units.

**Zero-width-joiner (ZWJ) emoji sequences** (👨‍👩‍👧‍👦, a "family" emoji) are the same shape of
problem: many code points joined by U+200D, one visual grapheme.

## 3. The safe-conservative rule (use this, don't guess)

Because no platform publishes its exact method, and undercounting risks a rejected/truncated
post while overcounting only risks being overly cautious: **when code-point count, UTF-16-unit
count, and grapheme-cluster count disagree, report the HIGHEST of the three as "the number to
respect against the limit," and separately report the grapheme count as "what a human perceives"
if they differ by more than a few units.** Never silently pick the smallest number because it's
the one that lets a caption "fit."

## 4. Exact recipe (stdlib-first Python, per Rachaka's own stdlib rule)

```python
def codepoint_length(s: str) -> int:
    return len(s)                              # Python 3 native

def utf16_unit_length(s: str) -> int:
    return len(s.encode('utf-16-le')) // 2      # approximates JS .length / IG's likely counter

def hashtag_count(caption: str) -> int:
    import re
    return len(re.findall(r'(?<!\w)#\w+', caption, flags=re.UNICODE))
```

For a true grapheme-cluster count (needed only when Devanagari/complex-emoji text sits within
~10% of a hard limit — Prakashan's own "recompute a second way" rule): Python's stdlib has **no**
grapheme-cluster segmenter. The correct tool is the `regex` module's `\X` pattern (matches one
extended grapheme cluster) — this is a **justified, not casual, new pip dependency** (no stdlib
equivalent exists, same "genuine-dep" bar this org already applies to whisper.cpp/tree-sitter):

```python
import regex
def grapheme_length(s: str) -> int:
    return len(regex.findall(r'\X', s))
```

If `regex` isn't installed and the text is near a limit: fall back to reporting BOTH
`codepoint_length` and `utf16_unit_length`, say which is higher, and flag "grapheme count not
computed — install `regex` for precision" rather than silently treating code-point count as safe.

## 5. Exact mechanical checklist — Instagram (run every field, every time)

1. **Hashtags**: extract every `#word` token from the caption (see `hashtag_count` above,
   counting caption+any pinned comment hashtags together). **Hard-fail at >5** (Jhalak KB.md §2 —
   the enforced 2025-12-19 cap, not the stale "30" in the static help article).
2. **Caption**: compute `utf16_unit_length` (the conservative assumption for IG's counter) —
   must be **≤2,200**. If within 200 of the limit, also compute `codepoint_length` and report
   both; state the one you're trusting and why.
3. **First-125-visible check**: slice the first 125 units (by the same counting method) and
   confirm the actual hook/question/CTA is inside that slice — content after it is invisible
   until "…more" is tapped.
4. **Bio**: `utf16_unit_length` ≤150.
5. **Bio links**: count entries ≤5.
6. **Video shape** (if a Reel): confirm 9:16 / 1080×1920 and runtime ≤3 min for full
   non-follower reach eligibility (20 min/4GB is the hard upload ceiling, not the reach-optimal
   target — state both numbers, don't conflate them).
7. **Engagement-bait scan**: regex/keyword check for vote-baiting ("comment yes/no", "type X"),
   tag-baiting ("tag 3 friends"), share-baiting phrasing — flag for the human, per Jhalak's
   refusal boundary, before packaging.
8. **Watermark check**: if the source file came from another platform, ask explicitly whether it
   still carries a visible TikTok/YouTube watermark — don't assume Sampadak already stripped it.

## 6. Exact mechanical checklist — YouTube

1. **Title**: `utf16_unit_length` ≤100 (hard limit); separately report whether it's ≤60 (visible
   in search/suggested) and flag if not.
2. **Description**: ≤5,000 chars; confirm the first ~150-160 characters (by the counting method)
   contain real content, not a repeated title or filler.
3. **Tags**: build the exact string that will be submitted (comma-joined, quoted if a tag has a
   space) and count its total length — must be ≤500. Report the count of the ACTUAL joined
   string, not the sum of individual tag lengths (commas and quote marks count).
4. **Chapters** (if used): first stamp is exactly `00:00`; count of stamps ≥3; compute the gap
   between each consecutive stamp and confirm every gap ≥10 seconds; confirm ascending order.
5. **Shorts classification check**: if the render is square/vertical AND ≤3:00 runtime, state
   explicitly "this will auto-classify as a Short" — if that's not the intent, flag it before
   upload (Prasar KB.md §2).
6. **Thumbnail**: confirm 1280×720 (16:9), width ≥640px, file size — report actual bytes, not
   "should be fine"; flag if the account's known 2MB-vs-50MB tier hasn't been confirmed.
7. **AI-disclosure**: apply Prasar KB.md §3's exact boundary — state which named category the
   content falls into (own-voice-clone / caption-only / filter / non-realistic animation = no
   disclosure; realistic depiction of a real person/event/advice/place = disclosure) rather than
   a blanket yes/no.

## 7. Cross-platform packaging rules

- Confirm the target platform explicitly before running either checklist — never run the
  Instagram checklist against a YouTube field or vice versa.
- Filenames: lowercase, hyphens not spaces, no double-encoding of the platform name. If the
  filename would contain Devanagari or combining marks, ASCII-transliterate it — some
  Termux/Android sync paths mishandle combining-mark filenames; this is a house filesystem
  convention, not a platform requirement, and should be stated as such.
- When packaging content that originated in Hinglish/Devanagari script, run the grapheme-count
  check (§4) before finalizing any near-limit field — this is the single highest-risk spot for a
  silent miscount, and it is Lakshya's actual daily-use case (Hinglish captions), not an edge case.

## 8. Cheat sheet (hand this to the model verbatim)

1. Never estimate — always compute and STATE the number (codepoint AND utf16-unit count when
   they might differ; grapheme count too if Devanagari/complex-emoji and near a limit).
2. Devanagari text has MORE code points than visible characters (virama + matra composition) —
   a raw `len()` will overcount vs. what a human sees. Emoji outside the BMP have FEWER code
   points than UTF-16 units — a raw `len()` will undercount vs. what IG's client likely counts.
   These two errors point in OPPOSITE directions — never assume one correction fixes both.
3. When in doubt near a hard limit, trust the HIGHER of code-point/UTF-16-unit count — never the
   lower, because undercounting is what gets a post truncated or rejected.
4. Instagram hashtags: hard-fail at >5. YouTube title: hard-fail at >100 (soft target ≤60
   visible). YouTube description: hard-fail at >5,000. YouTube tags: hard-fail at >500 combined.
5. If a count is within 10% of any limit, recompute it a second, different way (word-by-word or
   codepoint-vs-utf16-unit) before finalizing — this is the rule that catches the miscounts.
6. This entire job is more reliable as a deterministic script than an LLM's mental count — when
   `format_check.py` (per `fold-node/SOCIAL-PIPELINE.md` §5) exists, run it and report its output
   verbatim rather than re-counting by "reasoning."
7. State the platform explicitly before applying any rule — Instagram and YouTube limits must
   never cross-contaminate.
8. Package what Jhalak/Prasar/Vipanan drafted — never originate new creative copy here.

## Ladder (unchanged from `experts.json`)

`caps`: `brain_only`. `needs`: none — pure counting/formatting. `fallback`: this job is better as
a deterministic Python validator (`len()`/`encode('utf-16-le')`/`regex \X`) than an LLM's count —
build `format_check.py` alongside the persona, per `fold-node/SOCIAL-PIPELINE.md` §5, and treat
that script's output as authoritative over the model's own arithmetic once it exists.

## Sources

Unicode Standard Annex #29 (grapheme cluster boundaries — foundational spec, not independently
re-fetched this session, treated as established computer-science fact, not a claim needing a
live URL). Python 3 `str`/`len()` semantics — language reference, same treatment. UTF-16
surrogate-pair mechanics — same. Platform-specific limit numbers are sourced in Jhalak's and
Prasar's KB.md files (§1 of each) and not re-derived here — this file is the counting-method
layer underneath those numbers, per the task's own framing.
