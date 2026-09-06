# Ankak — KB (stdlib-only analysis toolkit)

> Sourced 2026-09-06. Bionic wall = no pandas/numpy on this device (per fold-node constraints) —
> everything here is `csv`, `statistics`, `sqlite3` from Python's own stdlib. Function names and
> signatures verified against docs.python.org/3/library/statistics.html (fetched 2026-09-06), not
> recalled from memory. The house rule this whole file serves: **never state a number not computed
> from the data in hand — show the computation** (per `fold-node/research/cherry-pick/09-usage-
> meter.md`'s own number-discipline pattern: read the exact field, never estimate, label the source).

## 1. The toolkit — verified stdlib functions

`import csv, statistics, sqlite3` — nothing else needed for everything below.

### Central tendency & spread (`statistics` module — Python 3.8+, `quantiles` needs 3.8+)
| Function | What it computes | Plain-language |
|---|---|---|
| `statistics.mean(data)` | arithmetic average | "typical value if everything were split evenly" |
| `statistics.median(data)` | middle value (avg of two middles if even count) | "the middle one — half above, half below" |
| `statistics.mode(data)` | single most-common value | "the value that showed up most" |
| `statistics.stdev(data)` | **sample** standard deviation | "how spread out, treating this as a sample of a bigger population" |
| `statistics.pstdev(data)` | **population** standard deviation | "how spread out, treating this as the WHOLE population" (use when you have ALL the data, e.g. all 30 days of a month, not a sample of days) |
| `statistics.quantiles(data, n=4)` | cut points (n=4 → quartiles, n=100 → percentiles) | "value at the X% mark" — e.g. `quantiles(data, n=100)[89]` ≈ the 90th percentile |
| `statistics.variance(data)` | stdev squared (sample) | rarely reported directly — stdev is more readable |

**Rule for choosing stdev vs pstdev:** if the numbers ARE everything you care about (all 30 posts
this month) → `pstdev`. If they're a SAMPLE standing in for more (10 posts as a proxy for "how
this account generally performs") → `stdev`. When unsure, say which you used and why.

### Reading data (`csv` module — no pandas)
```python
import csv
with open("data.csv", newline="", encoding="utf-8") as f:
    rows = list(csv.DictReader(f))   # list of dicts, keys = header row
```
`csv.DictReader` gives you dicts keyed by column name — no numpy dtype guessing, no silent type
coercion. Every value comes in as a **string** — cast explicitly (`float(row["views"])`) and
catch `ValueError` for blank/malformed cells rather than letting them crash or silently become 0.

### Storing/querying (`sqlite3` — for when data spans multiple files/sessions)
```python
import sqlite3
con = sqlite3.connect("metrics.db")
con.execute("CREATE TABLE IF NOT EXISTS posts (date TEXT, views INTEGER, platform TEXT)")
con.executemany("INSERT INTO posts VALUES (?,?,?)", rows)
con.commit()
# aggregate WITHOUT pandas: SQL does the group-by
cur = con.execute("SELECT platform, AVG(views) FROM posts GROUP BY platform")
```
Use SQL `GROUP BY`/`AVG`/`SUM` for aggregation across many rows instead of hand-rolling loops —
it's stdlib, it's exact, and it scales past what a Python loop comfortably holds in memory on a
phone.

## 2. Week-over-week (WoW) — the exact method

WoW is a ratio, always show both raw numbers and the ratio:
```
this_week = sum(views for last 7 days)
last_week = sum(views for the 7 days before that)
wow_pct = (this_week - last_week) / last_week * 100   # guard: last_week == 0 → "no baseline, can't compute %"
```
**Never** compare unequal windows (6 days vs 7) and call it WoW — pad or trim explicitly, and say
which you did. **Never** report a WoW % without also stating `n` (how many data points went into
each side) — a WoW jump from `n=2` posts is noise, not a trend.

## 3. Simple attribution — what stdlib CAN honestly do

True multi-touch attribution needs data this toolkit doesn't have (cross-channel identity
resolution). What's honestly doable with `csv`+`statistics`+`sqlite3`:
- **Last-touch, from a UTM/source column:** `GROUP BY source` on the conversions table — tells you
  which recorded source touched last, nothing about earlier touches. Say "last-touch only" every
  time you report this, never call it "attribution" bare.
- **Before/after a single change:** if exactly ONE variable changed (new caption style, new post
  time) between two windows, compare mean/median before vs after WITH the sample sizes shown. If
  more than one thing changed at once, say "can't attribute — N things changed together" rather
  than picking one to credit.
- **Correlation, not causation:** `statistics.correlation(x, y)` (Python 3.10+) gives Pearson r
  between two numeric series (e.g. hashtag count vs views) — report the r value AND say plainly
  "correlation, not proof of cause" every single time it's used.

## 4. Percentiles in plain language

"Your best-performing post is at the 90th percentile" = "9 out of 10 of your posts did worse than
this one." Compute with `statistics.quantiles(sorted_data, n=100, method='inclusive')[89]` (index
89 = the 90th percentile cut, 0-indexed) — **always sort first**, `quantiles` does NOT sort for you
per the stdlib docs' own contract on ordered input assumptions; verify by testing on a known list
before trusting it silently.

## 5. Number discipline (the house rule, applied to analytics)

Same discipline as `fold-node/research/cherry-pick/09-usage-meter.md`: read the exact field from
the data, never estimate, and label degraded/inferred numbers explicitly.
- **Denominator always stated:** "5,000 views" means nothing alone — "5,000 views over 7 days,
  across 4 posts" is a number.
- **Sample size always stated:** n=3 is not a trend, say so; there's no stdlib formula that makes
  n=3 statistically meaningful — don't dress it up with a percentage that implies more confidence
  than the sample supports.
- **One variable at a time:** if caption length, posting time, AND hashtag count all changed
  between two posts, don't credit the view-count difference to any one of them.
- **Show the computation, every time** — the arithmetic itself is the proof; a bare conclusion
  ("performance improved") without the numbers behind it is not an answer here.

## 6. Cheat-sheet

1. `csv.DictReader` → list of dicts, cast types explicitly, catch `ValueError` on bad cells.
2. `statistics.mean/median/mode` for center; `pstdev` if you have ALL the data, `stdev` if it's a sample.
3. `quantiles(sorted_data, n=100)` for percentiles — sort first, don't assume it sorts for you.
4. WoW = `(this_week - last_week) / last_week * 100`, guard divide-by-zero, state n on both sides.
5. `sqlite3` + `GROUP BY`/`AVG` beats a hand-rolled loop once data spans multiple files.
6. Attribution here = last-touch only, or single-variable before/after — never claim more.
7. `correlation(x, y)` (3.10+) → report r AND "not causation," always paired.
8. Self-check: did I show the arithmetic, or just the conclusion? If just the conclusion, redo it.
9. Self-check: is n big enough to call this a trend? If not, say "sample too small" out loud.

## 7. No-dead-end ladder

1. **Data file or `/attach` present** → read it with `csv`, compute the real number, show the math.
2. **No data file, but the user describes numbers in text** → ask for the actual file/`/attach`
   rather than computing from remembered/pasted-summary numbers — a summary can drop the
   denominator silently.
3. **Data present but the specific stat asked for isn't computable from stdlib alone** (e.g. true
   multi-touch attribution, seasonal decomposition) → say plainly "stdlib can't do this properly,
   here's the honest approximation and its limit" rather than faking a sophisticated-looking number.
4. **No data at all** → "Data na ho to number mat bolo — batao kaunsa ek number laana hai aur kahan
   se" (per the expert's own house checklist in experts.json). Never fill the gap with a plausible
   guess.

## Sources
- docs.python.org/3/library/statistics.html (fetched 2026-09-06 — function list, signatures,
  Python-version gating for `quantiles`/`correlation`/`linear_regression` confirmed here)
- docs.python.org/3/library/csv.html, docs.python.org/3/library/sqlite3.html (stdlib, standard
  reference, not independently re-fetched this session — behavior is stable/well-known stdlib API)
- fold-node/research/cherry-pick/09-usage-meter.md (in-house number-discipline pattern this file
  extends: read exact fields, never estimate, label degraded numbers)
- fold-node/termux/experts.json — `ankak`'s existing persona/checklist (base this file builds on,
  not duplicated verbatim here)
