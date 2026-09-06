# VYUH — Knowledge Base (decomposition method for a small model)

**Core principle:** paraphrasing a request into a smaller/cleaner brief is how parts get
silently dropped. Never summarize the ask before decomposing it — decompose the ask AS GIVEN,
then summarize the plan.

This is a METHOD base — the decomposition procedure IS the training, not platform facts.

---

## 1. Step one, always: extract every atomic sub-clause VERBATIM

Owner's own standing rule (CLAUDE.md rule 4, "Decomposition & Research Discipline"):
> "Literal sub-element coverage: extract EVERY atomic sub-clause of a multi-part request
> VERBATIM into a checklist; map each to a work-item; verify each is covered before
> delivering. Never paraphrase a request into a narrower brief."

**How to do this mechanically:**
1. Re-read the request sentence by sentence. Every "and", every comma-separated item, every
   clause that could stand alone as its own instruction — pull it out as its own checklist
   line, in the requester's own words, not your summary of it.
2. Number each one. This becomes the checklist you verify against before calling anything
   "done."
3. Before starting work, re-read the checklist against the original request one more time —
   did paraphrasing sneak a narrower brief in anywhere? If a line reads easier than the
   original but means less, fix it back to the literal clause.

## 2. "Examples are not the spec"

Owner's standing rule (`fold-node/CLAUDE.md`):
> "Jab bhi wo kuch cheezein list kare, wo list concept ka SAMPLE hai, uski boundary nahi. Intent
> samjho, phir poora concept cover karo — jo already pata hai unke baare mein use karke — aur
> bolo kaunse parts ADD kiye aur kyun."

Two real failures this rule exists to prevent:
- Asked for "12 experts: coding, UI/UX, image, voice, video, IG, YT, marketing, SEO,
  posting, OSINT" → built exactly those 12, missed research/writing/analytics/finance/
  coaching/planning — work he actually does daily. Fixed by adding 6 more.
- Asked "instagram reel link daalu to context nikale" → built IG+YT+GitHub-only extraction;
  the actual concept was ANY source → context (PDFs, local audio/video, plain files too).

**Operational rule:** when a request lists items, ask "is this list illustrating a concept, or
is it a closed boundary?" If it's illustrating a concept, cover the whole concept and NAME what
you added beyond the literal list and why. This does NOT license scope-creep — never silently
widen an irreversible or costly action; only add what the concept plainly implies.

## 3. Never drop a part for being hard — extract the buildable slice

Owner's rule: "No feasibility pre-filter / buildable-slice rule — never drop a part because it
seems hard or cloud/hardware-locked. Research it, then extract the part buildable offline in
own code. One part out of reach ≠ discard the whole idea. Build the patterns, not the
products."

**Mechanically:** for each checklist item, ask "can this run here, with what we have?" If no —
don't delete the item. Write what WOULD make it possible (a key, an API, a device), and
separately extract the smallest piece of the same idea that IS buildable now (a local pattern,
a stub, an offline equivalent). Ship that slice; note the blocked part as blocked, not silently
dropped.

## 4. Impact-radius thinking — before / during / after

For anything non-trivial, before sequencing work, ask three questions:
- **Before:** what already exists that this touches, depends on, or could break? (files,
  running processes, other agents' in-flight work, data shape)
- **During:** what else changes as a side-effect while this is being built? (a storage-key
  bump needs a cleanup step; a new file needs an index entry; a new capability needs a
  routing-table line)
- **After:** what does this unlock, or what does someone now expect to also work, that didn't
  before? (a new `/do` capability implies a fallback rung; a new expert implies a routing-table
  entry and a place in `experts.json`)

This is the same shape as the owner's "CONNECTION PASS" habit (CLAUDE.md): what pattern is
this an instance of, what does it combine with, what does it unlock, what would obviously be
wanted next but wasn't asked.

## 5. Dependency ordering, not ease ordering

Sequence work items by what BLOCKS what, never by what's quickest to knock out first.
**Name the load-bearing step up front:** which single step, if it turns out wrong, makes every
downstream step wasted effort? That step gets verified FIRST, even if it's the hardest one —
finding out it's wrong on step 1 costs one step; finding out on step 8 costs eight.

## 6. Every item needs a stated "done" and an owner of the unknown

- Each checklist item gets one clear sentence: what does "done" for THIS item look like,
  concretely (not "improve X" but "X returns Y for input Z").
- **Say what you do NOT know**, explicitly, rather than silently assuming a default: "I don't
  know if this needs to run offline or can assume network — assuming network unless told
  otherwise" is honest; silently picking one and not saying so is not.
- A plan with an unstated assumption baked in is not a complete plan — it's a guess wearing a
  plan's clothes.

---

## CHEAT-SHEET (read every time, before planning)

1. Pull every atomic sub-clause out VERBATIM into a numbered checklist first — no summarizing.
2. Re-check: did paraphrasing narrow anything? Fix it back to the literal clause.
3. Is a list in the request a SAMPLE of a concept or its BOUNDARY? If sample, cover the
   concept, name what you added.
4. Nothing hard gets dropped — research it, extract the buildable slice, note the blocked part.
5. Before/during/after: what does this touch, what changes as a side-effect, what does it
   unlock next?
6. Order by dependency — what blocks what — never by ease.
7. Name the one step that, if wrong, wastes everything after it. Verify that one first.
8. Every item gets a concrete "done" sentence.
9. State what you don't know rather than silently assuming it.
10. Never silently widen scope into something irreversible or costly — added scope must be
    named, not snuck in.
11. Before declaring the plan complete: re-read the ORIGINAL request one more time against your
    checklist, clause by clause.

## NO-DEAD-END LADDER

- **Request is vague/ambiguous about scope** → don't guess silently; state the literal
  clauses you found, state the concept you think they sample, and ask ONE clarifying question
  if the ambiguity is large enough to change the plan's shape.
- **A sub-clause needs hardware/access this device doesn't have** → don't drop it. Say what's
  blocked and why, extract the buildable slice, sequence the slice into the plan, flag the
  blocked part as an open item, not a silent omission.
- **No brain/model available at all** → the method still works by hand: literal clause
  extraction is mechanical (re-reading + listing), so a plain checklist can be built without
  any reasoning model at all — this is explicitly the stated fallback.
- **Plan reviewed and a clause was found missing after the fact** → never call the plan
  complete while a clause is known-dropped. Reopen, add it, re-sequence if it changes
  dependencies — a plan that pretends completeness with a known gap is worse than an honest
  partial plan.

## SOURCES

- Owner's decomposition rule — `CLAUDE.md`, rule 4
  ("Decomposition & Research Discipline")
- "Examples are not the spec" — `fold-node/CLAUDE.md`, standing rule
- CONNECTION PASS habit — `CLAUDE.md`, rule 4 sub-point
- Least-to-most / problem decomposition (compositional generalization gains) — Zhou et al.,
  ICLR 2023: https://openreview.net/pdf?id=_nGgzQjzaRy
