# Vaani — KB (on-device voice stack that actually works on Termux)

> Grounded in `fold-node/research/cherry-pick/06-voice-speaker-id.md` (KHOJI's 18-candidate
> scan) and this repo's own shipped code (`termux/ai-termux.py`, `termux/setup-menu.sh`).
> Vaani dispatches to an engine — it never claims to BE the engine.

## 1. The proven stack — what's actually DEPEND-verdict, why

- **whisper.cpp** (MIT) — STT. Pure C/C++ (ggml), compiles clean against Bionic, no glibc
  wall. `small` model ~466MB, `tiny` 75MB. Hindi quality is a real, honest ceiling: noticeably
  rougher than English at `small` tier — not a prompt-fixable thing. github.com/ggml-org/whisper.cpp
- **vosk-api** (Apache-2.0) — STT alt, Kaldi C++ core, official Android target, Hindi small
  model 42MB (WER **20.89–24.72**, the only citable number — from alphacephei.com, don't quote
  a Whisper WER, none survives audit). Also ships **`vosk-model-spk-0.4`, 13MB**, reusing the
  SAME Kaldi runtime for speaker embeddings — the single highest-leverage pattern in the whole
  scan (one runtime, not two heavy ones).
- **piper** (MIT engine) — TTS, real Hindi voices `hi_IN-pratham-medium` /
  `hi_IN-priyamvada-medium` (~60–75MB each). **Note: upstream `rhasspy/piper` was archived by
  its owner Oct 2025** — engine+voices stay MIT, use the community compile recipe
  (`gyroing/piper-tts-for-termux`, source-compiles onnxruntime+piper+espeak-ng for Bionic) as
  reference, never vendor its GPL-flavoured install scripts wholesale.
- **Kokoro** (Apache-2.0 weights, 82M params, ONNX) — newer, **Hindi is one of its 9 built-in
  accent groups** — CAUTION, not yet DEPEND: same onnxruntime-on-Bionic caveat as sherpa-onnx,
  unverified compile on this exact device (`11-bionic-workarounds.md` §Route1 reopens this,
  still needs the on-device test).
- **Termux:API floor** — `termux-tts-speak` / `termux-speech-to-text`: the guaranteed rung when
  nothing offline-heavier is installed. Needs the Termux:API app (F-Droid, matching Termux
  build) + `pkg install termux-api`.

## 2. Exact invocations — verified from this repo's own shipped scripts, not memory

TTS ladder (`$BIN/say`, `termux/setup-menu.sh`):
```bash
say "hello"          # kokoro-tts -> piper -> termux-tts-speak -> plain text (never silent)
```
STT ladder (`$BIN/listen`, `$BIN/whisper-stt`):
```bash
listen                # termux-speech-to-text -> whisper-stt -> typed input
whisper-stt            # records ~6s via termux-microphone-record, transcribes offline:
                        #   "$CLI" -m "$W/models/ggml-small.bin" -f "$f" -nt -l auto
```
Full voice loop: `talk` (wraps `listen`/`ai`/`say`, degrades to typed input if mic path missing,
exits after 3 empty reads with an honest Hinglish message rather than looping forever).
In-process fallback (`ai-termux.py`): `speak(text)` tries `termux-tts-speak` → `espeak` →
`piper --output_raw`, in that order, before falling back to printed text.
Setup: `menu_voice_offline` in `setup-menu.sh` clones `ggml-org/whisper.cpp`, builds it,
downloads the `small` model, and pulls the two Hindi piper voices from
`huggingface.co/rhasspy/piper-voices` — ~620MB total, explicitly flagged in the script itself
as **untested by the author on real ARM hardware** ("run it and check").

## 3. Speaker ID — enrol-then-identify (from 06-voice-speaker-id.md §4)

1. **Enrol:** record 3–5 utterances (5–10s) per person via `termux-microphone-record`, run
   each through `vosk-model-spk-0.4` to get an x-vector, average into one centroid per person.
   Store `{name, centroid_vector, enrolled_at, consent_flag}` — **local only, never off-device.**
2. **Identify:** extract an x-vector from new audio, cosine-similarity against every stored
   centroid; threshold starts ~0.75, **tune per-device** — this number is a starting point,
   not a verified constant.
3. **EER (equal-error-rate) for `vosk-model-spk-0.4` is UNVERIFIED** — no published number
   found. Never quote an accuracy figure for speaker-ID; say "untested on our own enrolled
   voices" until someone actually measures a held-out set.
4. **Consent is a legal, not cosmetic, requirement** — a voiceprint is a biometric identifier
   (GDPR Art. 9(2) territory even fully offline). Any enrol flow needs an explicit consent
   screen and a delete-my-voiceprint action from day one.
5. Full diarization (who-spoke-when in one recording) is a **harder, separate** ask than
   verification-against-enrolled-voices — needs VAD + change-point detection first. Don't
   conflate the two capabilities when a user asks for one or the other.

## 4. Calibration — what it concretely means here, honestly

"Calibration" is not a magic word — it's two specific, measurable things: (a) the speaker-ID
cosine-similarity **threshold** (§3.2, tune per device with real held-out samples, not a
default assumed to be right), and (b) STT confidence thresholds if the engine reports them
(whisper.cpp reports per-segment confidence; vosk reports word-level confidence — use these to
decide when to say "not sure I heard that" instead of silently acting on a bad transcript).
Real projects (rhasspy wake-word docs, MycroftAI/mycroft-precise) calibrate wake-word/False-
accept thresholds against **their own recorded data**, not a number copied from a paper.

## 5. Latency — honestly UNVERIFIED until measured

Local inference on phone CPU is a real 10–60+ second wait for anything non-trivial (per
THEME-SYSTEM.md §4's own framing, built around Nielsen's response-time thresholds). No
whisper.cpp/piper/vosk latency number for THIS device exists yet — never quote a "should take
X seconds" figure from memory. Say "depends on device, untested here" and let the waiting-state
UI (rotating status copy, elapsed-time counter, §4.2/4.3 THEME-SYSTEM.md) carry the wait
honestly instead of a fabricated ETA.

## 6. Profile switching — voice SUGGESTS, never silently switches

Per round-2 item C (family profiles) and the org's own trust-first standing rule: detecting a
different voice mid-session is a **prompt** ("lagta hai koi aur bol raha hai — profile switch
karun?"), never an automatic silent switch. A wrong silent switch could expose one person's
private context/memory to another — this is a trust-boundary decision, not a convenience
shortcut, and it needs the user's explicit yes every time.

## 7. Privacy — the one non-negotiable

**Audio never leaves the phone.** Every engine listed here (whisper.cpp, vosk, piper, Kokoro,
Termux:API) runs fully on-device once installed. If ever asked to route STT/TTS through a
cloud API "for better quality," that is a DIFFERENT product decision requiring explicit
opt-in and CEO sign-off — never the default, per the org's offline-first house rule.

## 8. Sources
- `fold-node/research/cherry-pick/06-voice-speaker-id.md` (full candidates table, WER numbers, consent/GDPR)
- `fold-node/termux/ai-termux.py` (`speak()`, `voice_in()`, `voice_out()`)
- `fold-node/termux/setup-menu.sh` (`say`/`listen`/`talk`/`whisper-stt` scripts, `menu_voice_offline`)
- https://github.com/ggml-org/whisper.cpp · https://github.com/alphacep/vosk-api · https://alphacephei.com/vosk/models
- https://github.com/rhasspy/piper · https://github.com/gyroing/piper-tts-for-termux
- https://huggingface.co/onnx-community/Kokoro-82M-v1.0-ONNX
- https://rhasspy.readthedocs.io/en/latest/wake-word/ (calibration reference)
