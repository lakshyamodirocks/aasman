# Chitrakar — Knowledge Base (image-generation dispatcher)

## 1. What Chitrakar actually is
Chitrakar never renders a pixel. Local diffusion on this hardware is
**confirmed CPU-infeasible**: a quantized (Q8_0) Stable Diffusion run on a
standalone ARM CPU measured **~625s (~10.4 min) per image**
[GROUNDED, arXiv:2412.05781, cited in `fold-node/research/offline-tools-vetting-2026.md` §2].
So every ask becomes one dispatcher line: `/do image_generation "<prompt>"`.
The router tries a real paid provider first, then the keyless floor. Chitrakar's
entire job is writing that prompt well.

## 2. The ladder (from `tools-routing.json`, live)
`image_generation`: `together` → `fal` → `stability` → `replicate` → `pollinations_builtin`.
- **together** (`TOGETHER_API_KEY`) — FLUX.1-schnell, ~$0.002–0.003/image, cheapest paid.
- **fal** (`FAL_KEY`) — also does video; ~$0.05/s if the ask is video, not image.
- **stability** (`STABILITY_API_KEY`) — native SD control.
- **replicate** (`REPLICATE_API_TOKEN`) — broad model catalog.
- **pollinations_builtin** — **the permanent floor. No key, no signup, always tried last.**
None of the paid ones are wired to a script yet (`invoke: manual` in `tools-routing.json`)
except `fal`/`replicate` (`invoke: vgen`) — so today, without a key set, Chitrakar's
line always lands on Pollinations.

## 3. Pollinations — exact shape, verified against the primary doc
[GROUNDED — github.com/pollinations/pollinations/blob/master/APIDOCS.md, fetched 2026-09-06]
```
GET https://image.pollinations.ai/prompt/{url-encoded-prompt}
    ?width=1024&height=1024&model=flux&seed=<int>&nologo=true&enhance=false&private=false
```
- `model`: `flux` (default) or `turbo`.
- **Rate limit, anonymous/keyless: 1 request per 15 seconds.** Registered ("Seed" tier,
  free signup): 1/5s. Do not fire two prompts back-to-back and call the second one "stuck."
- **Correction to a common assumption — flag this, don't skip it:** `nologo=true`
  is documented as *"remove the Pollinations watermark (needs account)"*. Passing it
  while fully anonymous may not actually remove the watermark — our harness's own
  `imagegen()` in `ai-termux.py` sends `nologo=true` unconditionally with no account,
  so **the watermark may still appear**. [P(IK) < 0.85 — not independently re-tested
  this session; tell the user plainly if a watermark shows up rather than insisting
  the param "should have" worked.]
- Our exact wired call (`ai-termux.py:650-668`, `imagegen()`): builds the URL above,
  downloads with a 120s timeout, rejects any response under 800 bytes as a failed
  generation (server returned an empty/error image), saves to `~/ai-out/img-<ts>.jpg`.
  Chitrakar never touches this code — it only ever emits the `/do` line; the router
  runs it and reports back the real path.

## 4. Free vs paid — the honest table
| Tier | Cost | Quality | Key needed |
|---|---|---|---|
| Pollinations (floor) | Free, keyless | Decent, watermark-risk if unregistered | None |
| Together FLUX-schnell | ~$0.002–0.003/img | Better, fast | `TOGETHER_API_KEY` |
| fal / Replicate | Model-dependent | Broad catalog | `FAL_KEY` / `REPLICATE_API_TOKEN` |
| Stability | Model-dependent | SD-native control | `STABILITY_API_KEY` |
Local Stable Diffusion (stable-diffusion.cpp, MIT): **exists, technically runs, but
10+ min/image — INSPIRE-only, never recommend as a live path** [GROUNDED, same source as §1].

## 5. Indian-context specifics
- **Hindi/Devanagari text INSIDE a generated image is a known weak spot across
  diffusion models generally** (garbled/illegible glyphs is the industry-wide failure
  mode for any non-Latin script in text-in-image generation) — **not independently
  benchmarked for Flux/Turbo specifically this session; treat as UNVERIFIED-but-expect-bad**.
  Practical fix: generate the image WITHOUT embedded text, then burn Hindi captions
  separately via `sampadak`'s `vedit subs` (ffmpeg + libass, real Devanagari rendering)
  or overlay text in a phone editor — never promise readable Hindi text baked into
  a Pollinations/Flux image.
- **Aspect ratios that matter here:** 1024×1024 (square, default) covers WhatsApp
  status/DP fine; for Reels/Shorts the image still needs `sampadak`'s `vertical`
  crop (1080×1920) after generation — Chitrakar doesn't control output aspect ratio
  beyond `width`/`height`, so request those explicitly in the URL if a non-square
  shape is needed (e.g. `width=1080&height=1920`).
- **Real, identifiable person's photoreal likeness** — flag this as a different,
  higher risk class before writing the prompt at all (deepfake/consent risk), same
  as PERSONA.md's refusal line.

## 6. Known traps on a phone
- **No network → no image, full stop.** There is no offline image path (§1)
  — say so plainly, never suggest "try local" as a fallback.
- **Anonymous rate limit (1/15s)** — retries too fast look like failures; wait.
- **`~/ai-out` fills up** on a low-storage phone if many images are generated —
  worth a periodic cleanup reminder, not Chitrakar's job to enforce.
- Large prompts get truncated by the harness at 400 chars before URL-encoding
  (`p[:400]` in `imagegen()`) — keep prompts well under that anyway (see §7).

## 7. Cheat-sheet (hand to the model verbatim)
```
Prompt order, always: SUBJECT -> STYLE -> LIGHTING/MOOD -> COMPOSITION -> ASPECT RATIO
Keep it under ~40 words. Longer does not help a keyless generator.
Never say "here is your image" -- you only output:
  /do image_generation "<the prompt>"
Real person + photoreal likeness in the ask -> flag it BEFORE writing the prompt.
Hindi/Devanagari text baked INTO the image -> warn it will likely render garbled;
  suggest generating clean + adding text via subs/overlay instead.
Square (1024x1024) is the safe default; for reels say so and note vertical crop
  happens after, in sampadak.
```

## 8. The ladder when the best tool is absent
Rung 1 (paid provider) → rung 2 (**Pollinations, the permanent floor — always
reachable if network is up**) → below that: **there is no rung 3/4 for image itself**
— local generation is confirmed infeasible (§1), so "no network" genuinely means
"no image today," and Chitrakar says that in plain words instead of pretending a
local option exists. This is the one capability in the CREATE group with a hard
floor rather than a graceful brain-only degrade.

## Sources
- https://github.com/pollinations/pollinations/blob/master/APIDOCS.md (fetched 2026-09-06)
- `fold-node/research/offline-tools-vetting-2026.md` §2 (stable-diffusion.cpp ARM benchmark, arXiv:2412.05781)
- `fold-node/tools-routing.json` (`image_generation` ladder, provider keys/pricing notes)
- `fold-node/termux/ai-termux.py` lines 650-668 (`imagegen()`, our exact wired call)
- `fold-node/EXPERT-PACK.md` §3 (grounding note, BLUNT ASSESSMENT row on chitrakar)
