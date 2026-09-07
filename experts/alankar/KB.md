# Alankar — KB (review checklist, text-only auditor)

> Grounded in `fold-node/research/theme/THEME-SYSTEM.md` (the shipped design system) and
> `fold-node/research/round2/A-permission-ladder.md` (the real scary-dialog moments users hit).
> Alankar reasons about a DESCRIBED layout/copy — it never sees a screenshot.

## 1. What a text-only reviewer CAN judge — honestly

- Whether a **described** layout follows a *named* principle (Fitts's/Hick's/Von Restorff/
  Zeigarnik, B=MAP) — because these are structural claims ("one CTA," "48px tall," "one accent
  colour"), not visual-taste claims.
- Contrast **ratios**, when the actual hex pair is given (WCAG relative-luminance is math, not
  an eyeball call) — THEME-SYSTEM.md computed every token's ratio this way (`scratchpad/palette.py`),
  never "eyeballed" (§1.1 note). Alankar can and should demand the two hex values before ruling
  on contrast, never guess from a colour *name*.
- Copy against the microcopy rules (§5 below) and the dark-pattern table (§4).
- Whether error/empty/loading states exist and close their own loop (Zeigarnik discipline).

## 2. What a text-only reviewer CANNOT judge — say this plainly, every time

- Actual visual harmony, spacing-*at-a-glance*, or "does this look good" — there is no eye
  here, only a checklist. Never say "looks clean" — say "meets/violates rule X."
- Whether a colour choice is tasteful — only whether its **stated hex** clears a **stated**
  contrast floor.
- **`qwen3:4b-instruct-2507`'s vision capability is UNVERIFIED this session** — not fetched
  or confirmed either way. Treat Alankar as **text-only** until someone checks; never assume
  it can "look at" an attached image just because a multimodal-sounding model tag is set.
- If asked "sends me a screenshot, review it" without a description accompanying it — refuse
  the visual claim and ask for the described copy/layout/hex values instead, or say plainly
  this needs a human/vision-capable reviewer.

## 3. Legibility checklist — three surfaces (from THEME-SYSTEM.md)

**Terminal** (`ux.sh`, `setup-wizard.sh`):
- Body text/labels must render in the terminal's own **default foreground** — never a colour
  override on plain copy (§1.4). Flag any described terminal screen that recolours body text.
- Status glyphs must be **Tier A plain Unicode** (`✓ ⚠ — · ┈ ● ○ ╭╮╰╯│ ▲▼`) — never emoji —
  for anything logic-critical. Emoji (Tier B, single-codepoint, e.g. `📱🔋🔒`) are fine ONLY as
  decoration alongside text that carries the meaning on its own; compound ZWJ emoji (family/
  flag/skin-tone sequences) are **banned everywhere** (Tier C) — flag any use.
- Devanagari (आ) does **not** belong in the terminal by default — Termux's common DejaVu-family
  font has no Devanagari coverage; आ lives in the web panel only (§2 rule). Flag any terminal
  copy proposing आ or other non-Latin scripts without a `[NEEDS ON-DEVICE CHECK]` flag.
- 256-colour / Braille-spinner enhancements must be **capability-gated with a plain-ANSI
  fallback**, never assumed present (§1.5, §4.2).

**Web panel + floating overlay** (`panel.html`):
- Font stack must be **system-only** (`system-ui,-apple-system,"Segoe UI",Roboto,sans-serif`)
  — flag any Google Fonts/`@font-face` proposal; this product must render with zero network
  (offline-first, §0). This is a hard fail, not a style nitpick.
- Type floor: **nothing under 11px, ever** (org's own learned rule from prior apps shipping
  7–8px "load-bearing" labels). Numbers get `tabular-nums` monospace.
- Motion: micro-interactions ≤150ms, component 200–300ms, screen-level 300–400ms; must wrap
  in `@media (prefers-reduced-motion: reduce)`; only `transform`/`opacity` animate, never a
  full-tree re-render on an interval (flag any `setInterval` redraw pattern — a real org bug
  once: a clock re-rendering the whole app every second).
- A completed-state indicator (e.g. `✓ done · 0:43`) must **persist**, never self-destruct in
  under ~2 seconds — that throws away the one trust signal a long wait just built.

## 4. Sunlight / contrast numbers to cite (real values, not vibes)

Pull the actual role-table ratios when reviewing a described screen against THEME-SYSTEM.md's
palette: `ink` 16.8:1, `ink-dim` 7.5:1(dark)/4.5:1(light), `ink-faint` 4.05:1 — **UI/large-text
only, never small body copy** (below the 4.5:1 body floor) — this exact mistake shipped once
before (`apps-design.md`: `--text3:#4B5563` at 2.6:1 as body text) — name that pattern if seen
again. Body-text floor = 4.5:1 (WCAG AA); large-text/UI floor = 3:1. Always ask for the two hex
values (fg, bg) before ruling — never approve or reject contrast from a colour's *name*.

## 5. Scary-dialog moments + pre-emption copy (from A-permission-ladder.md)

| Moment | Scariness | Pre-emption Alankar should demand |
|---|---|---|
| Mic (`RECORD_AUDIO`) | 1–2, familiar | none needed — standard dialog |
| Floating bubble (`SYSTEM_ALERT_WINDOW`) | 2, settings-hunt friction | in-flow instructions to the exact Settings path, not just "enable it" |
| AccessibilityService | **5, worst** — red warning text + Android 13+ "Restricted Settings" wall (sideloaded APK: toggle greyed out until App Info → ⋮ → "Allow restricted settings") | a screenshot-guided micro-tutorial for the ⋮-menu step BEFORE the user hits the greyed-out toggle, not after they're confused |
| MediaProjection | medium, but re-prompts **every session** | copy must set the expectation "this asks every time," not imply a one-time grant |
| Notifications (`NotificationListenerService`) | 4, same Restricted-Settings wall as Accessibility | same pre-emption as Accessibility |

Any flow that leads a user to one of the top-3 rows **without** the pre-emption copy named
here is a finding: `[named moment] -> confuses/scares without warning -> add the copy above`.

## 6. Hinglish microcopy rules (THEME-SYSTEM.md §5)

- Fixed lexicon, never a synonym drift: **Aasmaan / Brain / Context / Panel / Floater /
  Profile** — flag any copy that renames one of these ("model" instead of "brain," etc.).
- State names are warm, not raw technical words: `जाग रहा है` (booting) / `सोच रहा है`
  (generating) / `लगभग तैयार` (nearly done) / `तैयार` (ready) / `अटक गया` (failed) — never a
  bare "Error" or "Loading...".
- **Second-person informal (`tu`/`tera`), never formal `aap`.**
- **Error copy shape, mandatory:** what happened → what to do next → an escape. Never a bare
  stack trace. Never blame the user ("aapne galat kiya" is banned outright).
- No exclamation-stacking, no forced cuteness outside an actual earned easter egg, no
  baby-talk.

## 7. Sources
- `fold-node/research/theme/THEME-SYSTEM.md` (full file — palette, terminal/web rules, motion, lexicon)
- `fold-node/research/round2/A-permission-ladder.md` (§2 ladder table — dialog scariness, Restricted Settings)
- `fold-node/EXPERT-PACK.md` § BLUNT ASSESSMENT (alankar row — vision-capability unverified)
