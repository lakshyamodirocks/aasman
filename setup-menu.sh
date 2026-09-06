#!/data/data/com.termux/files/usr/bin/bash
# setup-menu.sh — interactive setup for the Fold AI stack (Termux).
# One menu to wire: AI-brain keys, voice chat, video edit, video generation, pentest, attach/MCP.
# HONEST by design: it says clearly what runs LOCALLY on the Fold (CPU only, no GPU) and
# what can ONLY run in the CLOUD. Nothing here spends your Claude weekly limit.
# Run:  bash setup-menu.sh     (or after fold-all-setup.sh:  setup-menu)
set -u
BIN="$HOME/.local/bin"; mkdir -p "$BIN"
ENVF="$HOME/.ai-env"; touch "$ENVF"; chmod 600 "$ENVF"
BRC="$HOME/.bashrc"

# PATH only. NEVER source ~/.ai-env from .bashrc: that exports every API key into every
# shell and every child process (round2 G finding, CRITICAL). `ai` reads ~/.ai-env itself.
grep -q '\.local/bin' "$BRC" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BRC"
# self-heal: remove the hook older versions of this menu wrote
sed -i '/ai-env.*set -a.*set +a/d' "$BRC" 2>/dev/null || true
# keys stay in the FILE; this menu greps them from there (setkey) and does not need them exported

c(){ printf '\033[%sm%s\033[0m\n' "$1" "$2"; }         # color echo
have(){ command -v "$1" >/dev/null 2>&1; }
setkey(){ # setkey VAR "prompt" — store into ~/.ai-env (persists), no echo of the value
  local var="$1" prompt="$2" val cur; cur="$(grep -m1 "^export $var=" "$ENVF" | sed 's/^[^=]*=//')"
  [ -n "$cur" ] && c 33 "  $var already set (leave blank to keep)"
  printf '  %s: ' "$prompt"; read -rs val; echo   # -s: key never echoed to the screen
  [ -z "$val" ] && { c 90 "  kept."; return; }
  sed -i "/^export $var=/d" "$ENVF"
  printf 'export %s=%q\n' "$var" "$val" >> "$ENVF"
  export "$var=$val"; c 32 "  $var saved to ~/.ai-env"
}

menu_guided(){
  c 35 "== GUIDED — router + tools ek baar me on, kuch miss na ho =="
  echo "3 zaroori steps chalate hain (baaki optional, menu me alag). Har key OPTIONAL — blank+Enter = skip."
  echo; c 36 "STEP 1/3 — Brain keys  (chat router on)"; menu_keys
  echo; c 36 "STEP 2/3 — Tool APIs   (/do tool-router on)"; menu_toolapis
  echo; c 36 "STEP 3/3 — Remote access (Moto se pahunch)"; menu_remote
  echo; c 36 "-- ab kya set hai --"; menu_status
  echo; c 32 "Zaroori ho gaya. Optional jab chahe:  2)Voice  3)Video-edit  4)Video-gen  5)Pentest  7)Panel"
  c 90 "Test abhi:  ai   ->  hello   ·   /do list"
}

menu_shizuku(){
  c 36 "== Shizuku / rish — Android ke 'haath' (no root) =="
  echo "Screen-sight (/do screen), calendar-read, settings — sab ise chahiye. Root nahi lagta."
  echo
  echo "  1) Shizuku app install karo (F-Droid ya Play Store) — ek baar."
  echo "  2) App me: 'Start via Wireless debugging' (Android 11+) ya PC-pairing (purane)."
  echo "  3) rish laao aur PATH me daalo:"
  if command -v rish >/dev/null 2>&1 || [ -x "$HOME/rish" ]; then
    c 32 "  rish already mila — test:"
    if timeout 12 rish -c id 2>/dev/null | grep -q "uid=2000"; then c 32 "  ✔ rish LIVE (uid=2000). Tier 2 unlocked — ab:  ai  ->  /do screen"
    else c 33 "  rish hai par jawab nahi — Shizuku app khol ke restart karo, phir wapas."; fi
  else
    echo "     Shizuku app -> 'Use Shizuku in terminal apps' -> uska rish script"
    echo "     ~/.local/bin/rish me copy karo (chmod +x). Guide: fold-node/SHIZUKU_SETUP.md"
    c 90 "  install ke baad ye menu dobara chala ke test kar lena."
  fi
}
menu_remote(){
  c 36 "== Remote access — Moto se Fold ka AI (Tailscale bridge) =="
  echo "Android pe Tailscale ek APP se chalta hai (Termux me tailscaled ko TUN/root chahiye — nahi hai)."
  echo "Toh: Fold pe Tailscale app -> tailnet IP -> 'ai serve' usi IP pe bind -> Moto browser se open."
  echo
  c 33 "STEP 1 (ek baar, tere haath se):"
  echo "  Fold pe Tailscale app install karo (Play Store / F-Droid) aur WAHI account se login:"
  echo "     <tera Tailscale login email>   (doosre devices jis tailnet me hain, wahi account)"
  echo "  App me Connect ON rakho."
  printf 'Tailscale app connected hai? [y/N] '; read -r yn
  [ "$yn" != y ] && { c 90 "theek — app connect karke dobara: setup-menu -> R"; return; }

  c 33 "STEP 2 — Fold ka tailnet IP:"
  TSIP="$(ip -4 addr 2>/dev/null | grep -o '100\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' | head -1)"
  if [ -n "$TSIP" ]; then c 32 "  auto-detected: $TSIP"
  else
    c 90 "  auto-detect nahi hua (Android interface chhupa sakta hai) — Tailscale app me dikh raha IP daal:"
    printf '  Fold ka tailscale IP (100.x.x.x): '; read -r TSIP
  fi
  case "$TSIP" in 100.*) : ;; *) c 31 "  '$TSIP' tailscale IP nahi lagta — chhod raha hoon."; return ;; esac
  sed -i "/^export AI_SERVE_HOST=/d" "$ENVF"; printf 'export AI_SERVE_HOST=%q\n' "$TSIP" >> "$ENVF"
  export AI_SERVE_HOST="$TSIP"; c 32 "  AI_SERVE_HOST=$TSIP saved"

  c 33 "STEP 3 — panel ka secret (Tailscale ke upar ek aur tala):"
  TOK="$(grep -m1 '^export AI_SERVE_TOKEN=' "$ENVF" | sed 's/^[^=]*=//' | tr -d \"\')"
  if [ -z "$TOK" ]; then
    TOK="$( (head -c 18 /dev/urandom | base64 2>/dev/null || date +%s%N) | tr -dc 'A-Za-z0-9' | cut -c1-22 )"
    sed -i "/^export AI_SERVE_TOKEN=/d" "$ENVF"; printf 'export AI_SERVE_TOKEN=%q\n' "$TOK" >> "$ENVF"
    export AI_SERVE_TOKEN="$TOK"; c 32 "  naya token banaya"
  else c 90 "  token pehle se hai (reuse)"; fi

  cat > "$BIN/panel" <<'PEOF'
#!/data/data/com.termux/files/usr/bin/bash
# panel -> start the Akasha web panel on the Tailscale IP and print the Moto URL.
# read ONLY the three panel settings from ~/.ai-env — never export every API key into
# this process (round2 G). `ai serve` loads its own keys itself.
_v(){ grep -m1 "^export $1=" "$HOME/.ai-env" 2>/dev/null | sed "s/^[^=]*=//; s/^['\"]//; s/['\"]\$//"; }
H="${AI_SERVE_HOST:-$(_v AI_SERVE_HOST)}"; H="${H:-127.0.0.1}"
P="${AI_SERVE_PORT:-$(_v AI_SERVE_PORT)}"; P="${P:-8765}"
T="${AI_SERVE_TOKEN:-$(_v AI_SERVE_TOKEN)}"
echo "Moto pe kholo:  http://$H:$P/${T:+?t=$T}"
[ "$H" = "127.0.0.1" ] && echo "(localhost bind — remote ke liye: setup-menu -> R)"
exec ai serve "$P"
PEOF
  chmod +x "$BIN/panel"
  echo
  c 32 "Ho gaya. Fold pe chalao:  panel"
  c 32 "Moto browser me kholo:   http://$TSIP:8765/?t=$TOK"
  c 90 "Tailscale hi auth boundary hai; token ek extra tala. Kabhi 0.0.0.0 pe bind mat karna."
}

menu_keys(){
  c 36 "== AI brain keys =="
  echo "All free tiers. They do NOT touch your Claude weekly limit. Get each key, paste below."
  echo "  gemini      -> https://aistudio.google.com/apikey"
  echo "  groq        -> https://console.groq.com/keys"
  echo "  openrouter  -> https://openrouter.ai/keys"
  echo "  cerebras    -> https://cloud.cerebras.ai  (API keys)"
  echo "  mistral     -> https://console.mistral.ai/api-keys"
  echo "  nvidia      -> https://build.nvidia.com  (no-card free credits, 80+ models)"
  echo
  setkey GEMINI_API_KEY     "Gemini key"
  setkey GROQ_API_KEY       "Groq key"
  setkey OPENROUTER_API_KEY "OpenRouter key"
  setkey CEREBRAS_API_KEY   "Cerebras key"
  setkey MISTRAL_API_KEY    "Mistral key"
  setkey NVIDIA_API_KEY     "NVIDIA NIM key"
  echo; c 32 "Done. New shells load these automatically. This shell: run  source ~/.ai-env"
  c 90 "Test now:  ai   then type a question (auto-router picks a free brain)."
}

menu_voice(){
  c 36 "== Voice chat (speak to the AI, hear it back) =="
  echo "LOCAL on the Fold — no key, no cloud bill. Two layers:"
  echo "  STT (your voice -> text): termux-speech-to-text"
  echo "  TTS (AI text -> voice):   termux-tts-speak"
  echo "Both come from the Termux:API app + the termux-api package."
  echo
  echo "1) Install: F-Droid app 'Termux:API' (must match your Termux build), then here:"
  printf '   install termux-api package now? [y/N] '; read -r yn
  [ "$yn" = y ] && pkg install -y termux-api
  echo
  echo "2) Wiring a talk loop into 'ai':"
  cat > "$BIN/say" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# say "text" -> speak text.  say < file -> speak a file.  Degrades, never errors out.
txt="$*"; [ -z "$txt" ] && txt="$(cat)"
command -v termux-tts-speak >/dev/null 2>&1 && { printf '%s' "$txt" | termux-tts-speak; exit 0; }
command -v espeak        >/dev/null 2>&1 && { printf '%s' "$txt" | espeak >/dev/null 2>&1; exit 0; }
printf '[say] no TTS engine (setup-menu -> 2 for Termux:API) — text form:\n%s\n' "$txt"
EOF
  cat > "$BIN/listen" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# listen -> prints what you said. Ladder: Termux:API STT -> offline whisper-stt -> typed input.
command -v termux-speech-to-text >/dev/null 2>&1 && { termux-speech-to-text; exit 0; }
command -v whisper-stt          >/dev/null 2>&1 && { whisper-stt; exit 0; }
printf '[listen] no mic path yet (setup-menu -> 2). Type instead: ' >&2; read -r l; printf '%s\n' "$l"
EOF
  cat > "$BIN/talk" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# talk -> ask by voice, hear the answer. Ctrl-C to stop. Uses 'listen'/'say', so it
# inherits their ladders: no Termux:API just means typed input + printed answer, not a dead end.
while true; do
  echo "[talk] listening... (speak now)"
  q="$(listen)"
  if [ -z "$q" ]; then
    empties=$((${empties:-0}+1))
    echo "[talk] nothing heard ($empties)"
    [ "$empties" -ge 3 ] && { echo "[talk] mic/STT nahi chal raha lagta — nikal raha hoon. setup-menu -> 2 se voice set karo."; break; }
    sleep 1; continue
  fi
  empties=0
  echo "you: $q"
  out="$(ai "$q")"; echo "$out"
  # speak the answer, minus the trailing [brain · time · tok] telemetry line
  printf '%s' "$out" | sed '/^\[.*tok]$/d' | say
done
EOF
  chmod +x "$BIN/say" "$BIN/listen" "$BIN/talk"
  c 32 "Wired: say / listen / talk  (in ~/.local/bin). These also power the panel's 🎤 / 🔊."
  echo
  c 90 "Quick path above uses Google (needs net). Want FULLY OFFLINE Hindi+English voice?"
  printf 'install offline voice (whisper.cpp small STT + piper Hindi TTS, ~620MB build)? [y/N] '; read -r yn
  [ "$yn" = y ] && menu_voice_offline
}

menu_voice_offline(){
  c 36 "== Offline voice (whisper.cpp + piper) — Hindi/Hinglish/English =="
  c 90 "Heavy: builds whisper.cpp + pulls the 'small' model (~466MB) and 2 Hindi piper voices (~150MB)."
  c 90 "Hindi STT at 'small' is usable, not perfect (known limit). I cannot test this on your ARM device — run it and check."
  # STT: whisper.cpp (MIT, ARM-first)
  pkg install -y git cmake clang make termux-api 2>/dev/null
  if [ ! -d "$HOME/whisper.cpp" ]; then
    git clone --depth 1 https://github.com/ggml-org/whisper.cpp "$HOME/whisper.cpp" \
      && ( cd "$HOME/whisper.cpp" && cmake -B build && cmake --build build --config Release \
           && sh ./models/download-ggml-model.sh small )
  else c 90 "  whisper.cpp already cloned"; fi
  # TTS: piper (MIT archived build) — try pip, else point to the release binary
  pip install --quiet piper-tts 2>/dev/null && c 32 "  piper-tts installed" || c 33 "  pip piper-tts failed — grab the aarch64 binary from github.com/rhasspy/piper/releases"
  mkdir -p "$HOME/piper-voices"
  for v in hi_IN-pratham-medium hi_IN-priyamvada-medium; do
    base="https://huggingface.co/rhasspy/piper-voices/resolve/main/hi/hi_IN/${v%%-*}/medium"
    for ext in onnx onnx.json; do
      [ -f "$HOME/piper-voices/$v.$ext" ] || curl -fsSL "$base/$v.$ext" -o "$HOME/piper-voices/$v.$ext" 2>/dev/null
    done
  done
  # offline STT wrapper: record 6s via Termux:API, transcribe with whisper.cpp
  cat > "$BIN/whisper-stt" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# whisper-stt -> record ~6s from the mic (Termux:API) and print offline transcription (whisper.cpp).
W="$HOME/whisper.cpp"; CLI="$W/build/bin/whisper-cli"; [ -x "$CLI" ] || CLI="$W/build/bin/main"; [ -x "$CLI" ] || CLI="$W/main"
M="$W/models/ggml-small.bin"
command -v termux-microphone-record >/dev/null 2>&1 || { echo "need Termux:API (mic)"; exit 1; }
[ -x "$CLI" ] || { echo "whisper.cpp not built (setup-menu -> Voice -> offline)"; exit 1; }
f="$(mktemp).wav"; termux-microphone-record -f "$f" -l 6 >/dev/null 2>&1; sleep 6; termux-microphone-record -q >/dev/null 2>&1
"$CLI" -m "$M" -f "$f" -nt -l auto 2>/dev/null | tr -s ' \n' ' ' | sed 's/^ *//'; rm -f "$f"
EOF
  # optional, newer + better Hindi than piper (Apache-2.0, 82M, Termux ports exist).
  # Non-fatal by design: if onnxruntime won't build on this device, 'say' just uses the next rung.
  printf 'also try Kokoro TTS (newer, better Hindi, ~350MB, may fail to build)? [y/N] '; read -r ky
  case "$ky" in [yY]*) pip install --quiet kokoro-onnx soundfile 2>/dev/null \
      && c 32 "  kokoro-onnx installed" || c 33 "  kokoro-onnx unavailable on this device — piper stays primary (nothing broken)";; esac
  # offline TTS: 'say' is a 4-rung ladder — kokoro -> piper -> Termux TTS -> printed text. Never silent.
  cat > "$BIN/say" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# say "text" -> speak. Ladder: kokoro (best Hindi) -> piper (offline) -> Termux TTS -> plain text.
txt="$*"; [ -z "$txt" ] && txt="$(cat)"
play_wav(){ if command -v termux-media-player >/dev/null 2>&1; then termux-media-player play "$1" >/dev/null 2>&1
            elif command -v play >/dev/null 2>&1; then play -q "$1" >/dev/null 2>&1
            else return 1; fi; }
if command -v kokoro-tts >/dev/null 2>&1; then
  out="$(mktemp).wav"; printf '%s' "$txt" | kokoro-tts --output "$out" >/dev/null 2>&1 && play_wav "$out" && { rm -f "$out"; exit 0; }
  rm -f "$out"
fi
V="$HOME/piper-voices/hi_IN-pratham-medium.onnx"
if command -v piper >/dev/null 2>&1 && [ -f "$V" ]; then
  out="$(mktemp).wav"; printf '%s' "$txt" | piper -m "$V" -f "$out" >/dev/null 2>&1 && play_wav "$out" && { rm -f "$out"; exit 0; }
  rm -f "$out"
fi
command -v termux-tts-speak >/dev/null 2>&1 && { printf '%s' "$txt" | termux-tts-speak; exit 0; }
printf '[say] no audio engine on this device — text form:\n%s\n' "$txt"
EOF
  chmod +x "$BIN/whisper-stt" "$BIN/say"
  c 32 "Offline voice wired: whisper-stt (STT) + say now prefers piper Hindi (offline)."
  c 90 "The panel 🎤 auto-uses whisper-stt if present. Test:  whisper-stt   and   say \"namaste, kaise ho\""
}

menu_panel(){
  c 36 "== Control panel (floating GUI in the browser) =="
  echo "A phone-friendly panel: chat, file upload, model/route control, status, brain answer-rates,"
  echo "pending tasks, history, logs, and your #hashtags as tap-chips (no more remembering them)."
  command -v ai >/dev/null 2>&1 || { c 31 "'ai' not installed — run fold-all-setup.sh first"; return; }
  echo
  echo "Launch it with:   ai serve        (then open the URL on the phone browser)"
  echo "Default binds 127.0.0.1:8765 (this device only) — the panel has NO login."
  c 31 "  WARNING: AI_SERVE_HOST=0.0.0.0 exposes your chats/journal/logs to EVERYONE on the Wi-Fi."
  echo "  For remote access bind the Tailscale IP instead (Tailscale = the auth boundary):"
  echo "     AI_SERVE_HOST=<your-tailscale-ip> ai serve"
  echo "  Extra lock (any bind): put AI_SERVE_TOKEN=<secret> in ~/.ai-env -> /api/* needs ?t=<secret>"
  echo
  c 90 "NOTE: this is a floating button INSIDE the page (works everywhere, no permissions)."
  c 90 "A button that floats OVER other apps (like AssistiveTouch) needs a native Android app or"
  c 90 "Tasker/AutoTools overlay — that's a separate build; the browser panel is the no-friction version."
  printf 'launch the panel now? [y/N] '; read -r yn
  [ "$yn" = y ] && { c 32 "starting… open the printed URL on your phone. Ctrl-C to stop."; ai serve; }
}

menu_vedit(){
  c 36 "== Video / audio EDIT (ffmpeg) =="
  echo "LOCAL on the Fold — real, works on CPU. Cut, convert, compress, extract audio, gif, etc."
  printf 'install ffmpeg now? [y/N] '; read -r yn
  [ "$yn" = y ] && pkg install -y ffmpeg
  cat > "$BIN/vedit" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# vedit — short-form video/audio toolkit over ffmpeg.
# Recipes below are the ones vetted against ffmpeg's own filter docs
# (fold-node/research/toolkit-vetting-2026.md §4) — not guessed flags.
usage(){ cat <<'U'
vedit — ffmpeg recipes for short-form (reels/shorts)

  BASIC
    vedit cut in.mp4 00:00:05 00:00:20 out.mp4   trim between timestamps
    vedit mp3 in.mp4 out.mp3                     extract audio
    vedit shrink in.mp4 out.mp4                  compress (CRF 28)
    vedit gif in.mp4 out.gif                     gif (10fps, 480w)

  SHORT-FORM
    vedit vertical in.mp4 out.mp4                centre-crop to 9:16, scale 1080x1920
    vedit subs in.mp4 caps.srt out.mp4           burn subtitles (libass)
    vedit thumb in.mp4 out.jpg [HH:MM:SS]        thumbnail (smart frame, or a timestamp)
    vedit join out.mp4 a.mp4 b.mp4 ...           concat (no re-encode; falls back if codecs differ)

  AUDIO
    vedit duck voice.wav music.wav out.m4a       music ducks under the voice (sidechain)
    vedit loud in.wav out.wav                    2-pass loudnorm to -16 LUFS (social default)
    vedit desilence in.wav out.wav               cut dead air throughout, not just the start

  anything else -> passed straight to ffmpeg
U
}
command -v ffmpeg >/dev/null 2>&1 || { echo "ffmpeg not installed:  pkg install ffmpeg   (or setup-menu -> Video edit)"; exit 1; }
[ $# -eq 0 ] && { usage; exit 0; }
case "${1:-}" in
  -h|--help|help) usage ;;
  cut)    ffmpeg -i "$2" -ss "$3" -to "$4" -c copy "$5" ;;
  mp3)    ffmpeg -i "$2" -vn -q:a 2 "$3" ;;
  shrink) ffmpeg -i "$2" -vcodec libx264 -crf 28 "$3" ;;
  gif)    ffmpeg -i "$2" -vf "fps=10,scale=480:-1:flags=lanczos" "$3" ;;
  vertical) ffmpeg -i "$2" -vf "crop=ih*9/16:ih,scale=1080:1920" -c:a copy "$3" ;;
  subs)   # colons inside a filter arg must be escaped, else the filtergraph mis-parses
          s=$(printf '%s' "$3" | sed 's/:/\\:/g')
          ffmpeg -i "$2" -vf "subtitles=${s}:force_style='FontSize=24,PrimaryColour=&HFFFFFF&'" -c:a copy "$4" ;;
  thumb)  if [ -n "${4:-}" ]; then ffmpeg -ss "$4" -i "$2" -frames:v 1 -y "$3"    # -ss BEFORE -i = fast seek
          else ffmpeg -i "$2" -vf thumbnail -frames:v 1 -y "$3"; fi ;;
  join)   out="$2"; shift 2; L=$(mktemp)
          for f in "$@"; do printf "file '%s'\n" "$(cd "$(dirname "$f")" && pwd)/$(basename "$f")" >> "$L"; done
          # -c copy needs identical codec/res/fps; if it fails, re-encode instead of giving up
          ffmpeg -f concat -safe 0 -i "$L" -c copy -y "$out" 2>/dev/null || \
          { echo "[vedit] codecs differ -> re-encoding (slower, always works)"; ffmpeg -f concat -safe 0 -i "$L" -y "$out"; }
          rm -f "$L" ;;
  duck)   # sidechaincompress: input1 = audio to compress (music), input2 = trigger (voice)
          ffmpeg -i "$2" -i "$3" -filter_complex \
            "[1:a][0:a]sidechaincompress=threshold=0.05:ratio=8:attack=5:release=250[d];[0:a][d]amix=inputs=2:duration=first" \
            -c:a aac -y "$4" ;;
  loud)   J=$(ffmpeg -i "$2" -af loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json -f null - 2>&1 | sed -n '/{/,/}/p')
          g(){ printf '%s' "$J" | grep -o "\"$1\"[^,]*" | grep -o '[-0-9.]*$'; }
          # loudnorm can silently change the sample rate -> pin -ar on the output
          ffmpeg -i "$2" -af "loudnorm=I=-16:TP=-1.5:LRA=11:measured_I=$(g input_i):measured_TP=$(g input_tp):measured_LRA=$(g input_lra):measured_thresh=$(g input_thresh):linear=true" -ar 48000 -y "$3" ;;
  desilence) # stage 1 trims leading silence; stage 2 (stop_periods=-1) repeats for EVERY gap
          ffmpeg -i "$2" -af "silenceremove=start_periods=1:start_duration=0:start_threshold=-45dB:detection=peak,silenceremove=stop_periods=-1:stop_duration=0.5:stop_threshold=-45dB:detection=peak" -y "$3" ;;
  *)      ffmpeg "$@" ;;
esac
EOF
  chmod +x "$BIN/vedit"
  c 32 "Wired: vedit  (run 'vedit' with no args to see examples)."
}

menu_vgen(){
  c 36 "== Video GENERATION (text/image -> video) =="
  c 31 "HONEST: the Fold is CPU-only (no GPU). Generating video LOCALLY is not realistic here."
  echo "So this is CLOUD-ONLY. You pay the provider (not your Claude limit). Options:"
  echo "  Replicate  -> https://replicate.com/account/api-tokens  (many video models)"
  echo "  fal.ai     -> https://fal.ai/dashboard/keys"
  echo
  printf 'wire the Replicate cloud path? [y/N] '; read -r yn
  [ "$yn" != y ] && { c 90 "skipped."; return; }
  setkey REPLICATE_API_TOKEN "Replicate token"
  cat > "$BIN/vgen" <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# vgen "a prompt"  -> submit a text->video job to Replicate (CLOUD, costs money, not local).
# Set the model with VGEN_MODEL (default is a text->video model; check replicate.com for current ids).
[ -z "${REPLICATE_API_TOKEN:-}" ] && { echo "no REPLICATE_API_TOKEN (setup-menu -> Video generation)"; exit 1; }
[ $# -lt 1 ] && { echo 'usage: vgen "your prompt"'; exit 1; }
MODEL="${VGEN_MODEL:-minimax/video-01}"
echo "[vgen] CLOUD job to $MODEL (this costs money on Replicate, not your Claude limit)"
curl -s -X POST "https://api.replicate.com/v1/models/$MODEL/predictions" \
  -H "Authorization: Bearer $REPLICATE_API_TOKEN" \
  -H "Content-Type: application/json" -H "Prefer: wait" \
  -d "{\"input\":{\"prompt\":$(python3 -c 'import json,sys;print(json.dumps(sys.argv[1]))' "$*")}}" \
  | python3 -c 'import json,sys;d=json.load(sys.stdin);print(d.get("output") or d.get("error") or d)'
EOF
  chmod +x "$BIN/vgen"
  c 32 "Wired: vgen \"prompt\"  (CLOUD, costs money). Check replicate.com for the current model id; set VGEN_MODEL to change it."
}

menu_pentest(){
  c 36 "== Pentest toolkit (authorized use only) =="
  echo "For YOUR OWN devices / CTF / lab. Installs nmap, sqlmap, nikto, hydra, and Go recon tools."
  printf 'install now? [y/N] '; read -r yn
  [ "$yn" != y ] && { c 90 "skipped."; return; }
  pkg install -y nmap sqlmap nikto hydra python golang git
  pip install --quiet requests dnspython 2>/dev/null
  export GOBIN="$BIN"
  for t in github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest \
           github.com/projectdiscovery/httpx/cmd/httpx@latest \
           github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest; do
    echo "  go install $t"; go install "$t" 2>/dev/null && c 32 "    ok" || c 33 "    skipped (needs network / time)"
  done
  c 32 "Pentest tools attempted. Authorized targets only."
}

menu_toolapis(){
  c 36 "== Tool APIs (research / image / audio / scrape) + MCP =="
  echo "Ye /do TOOL-router ko power dete hain (brain-router se alag; brain keys option 1 me)."
  echo "Sab OPTIONAL — jo chahiye wo daalo, baaki blank + Enter se skip. Keys ~/.ai-env me save."
  echo
  c 36 "-- Research (free, no card) --"
  echo "  Tavily: https://app.tavily.com   ·   Exa: https://exa.ai/api"
  setkey TAVILY_API_KEY "Tavily key"
  setkey EXA_API_KEY    "Exa key"
  c 36 "-- Scrape --"
  echo "  Jina Reader: NO key (https://r.jina.ai/<url>).   Firecrawl: https://firecrawl.dev (1000 free once)"
  setkey FIRECRAWL_API_KEY "Firecrawl key (optional)"
  echo "  Jina free key (keyless ~20 RPM -> ~500 RPM): https://jina.ai/reader"
  setkey JINA_API_KEY "Jina key (optional, free)"
  c 36 "-- Image gen (cloud — Fold CPU pe local nahi) --"
  echo "  Together (~\$0.002/img): https://api.together.ai   ·   fal: https://fal.ai/dashboard/keys"
  setkey TOGETHER_API_KEY "Together key"
  setkey FAL_KEY          "fal key (image + video)"
  c 36 "-- Video gen (cloud) --"
  echo "  Replicate: https://replicate.com/account/api-tokens"
  setkey REPLICATE_API_TOKEN "Replicate token"
  c 36 "-- Audio overview / voice (paid) --"
  echo "  ElevenLabs GenFM: https://elevenlabs.io/app/settings/api-keys"
  setkey ELEVENLABS_API_KEY "ElevenLabs key (optional)"
  echo
  c 32 "Done. Test:  ai  ->  /do list  ·  /do research <q>  ·  /do image <prompt>  ·  /do scrape <url>"
  c 90 "NotebookLM (video/audio overview) ka koi API nahi -> /do video_overview steps deta (manual)."
  echo
  c 36 "-- MCP (tools, NOT chat brains) --"
  echo "9 official MCP servers mile: Firecrawl, Exa, Tavily, ElevenLabs, Perplexity, Replicate, Jina, Deepgram, Browserless."
  echo "Setup inhe AUTO-WIRE nahi karta: (1) koi MCP client abhi wired nahi (catalog-only), (2) RAKSHA"
  echo "security-scan pending har server ke install-script ka. Chahiye to bol — main safe tarike se ek MCP"
  echo "client (ollmcp/MCPHost) + scan-ke-baad wiring kar dunga. Tab tak /do ke local+API providers use kar."
  echo
  c 90 "Bonus — files: 'ai' me  /attach <file>  se koi text file agli baaton ka context ban jaati hai."
}

menu_mcp(){
  c 36 "== Attach files + MCP =="
  echo "ATTACH is already built into 'ai':"
  echo "  ai   then:  /attach ~/notes.md     -> that file becomes context for the next questions"
  echo "  (text files only; images need a vision model)"
  echo
  echo "MCP: MCP is a TOOL protocol, not a chat brain. It gives a client tools (files, search,"
  echo "browsers, apps) — it is NOT another model you route to. 'ai' here is a plain terminal"
  echo "client, so MCP servers don't plug into its router. If you want MCP tools, run them from a"
  echo "full MCP client (Claude Code / Claude Desktop) on the Moto — not from this Fold terminal."
  c 90 "Bottom line: /attach for files here; MCP lives on the Moto client, by design."
}

menu_status(){
  c 36 "== Status =="
  for v in GEMINI_API_KEY GROQ_API_KEY OPENROUTER_API_KEY CEREBRAS_API_KEY MISTRAL_API_KEY GITHUB_TOKEN REPLICATE_API_TOKEN; do
    if grep -q "^export $v=" "$ENVF"; then c 32 "  [set]   $v"; else c 90 "  [ ]     $v"; fi
  done
  echo
  for cmd in ai ollama ffmpeg termux-tts-speak termux-speech-to-text nmap say listen talk vedit vgen; do
    if have "$cmd"; then c 32 "  [ok]    $cmd"; else c 90 "  [ ]     $cmd"; fi
  done
}

menu_findtokens(){
  c 36 "== Token finder — kaun sa token kahan pada hai =="
  local FT=""
  for p in "$HOME/akasha-src/akasha-fold/find-tokens.sh" "$(dirname "$0")/../../akasha-fold/find-tokens.sh"; do
    [ -f "$p" ] && { FT="$p"; break; }
  done
  [ -z "$FT" ] && { c 31 "  find-tokens.sh nahi mila — git -C ~/akasha-src pull"; return; }
  bash "$FT" || true
  echo
  echo "  Value dekhni ho (screenshot mat lena):  bash $FT --reveal"
}

menu_cleanup(){
  c 36 "== Cleanup — test/command ka malba hatao =="
  local CL=""
  for p in "$HOME/akasha-src/akasha-fold/cleanup.sh" "$(dirname "$0")/../../akasha-fold/cleanup.sh"; do
    [ -f "$p" ] && { CL="$p"; break; }
  done
  if [ -z "$CL" ]; then
    c 31 "  cleanup.sh nahi mila."
    echo "  repo pull karo:  git -C ~/akasha-src pull"
    return
  fi
  echo "  Pehle DRY-RUN — kuch delete nahi hoga, sirf dikhega:"
  echo
  bash "$CL" || true
  echo
  echo "  Sach me hatana ho:      bash $CL --yes"
  echo "  Ollama blobs / ai-out:  bash $CL --deep"
  echo "  History se key hatao:   bash $CL --scrub-history"
}

while true; do
  echo
  c 35 "==== Fold AI setup ===="
  echo "  G) GUIDED             (recommended first — router + tools, kuch miss na ho)"
  echo "  R) Remote access      (Tailscale: Moto se Fold ka panel/board/voice)"
  echo "  S) Shizuku / rish     (screen-sight + settings, no root — one-time pairing)"
  echo "  1) AI brain keys      (free tiers; no Claude-limit cost)   LOCAL router"
  echo "  2) Voice chat         (talk + hear)                        LOCAL"
  echo "  3) Video / audio edit (ffmpeg)                             LOCAL"
  echo "  4) Video generation   (text -> video)                      CLOUD ONLY (no GPU here)"
  echo "  5) Pentest toolkit    (authorized use)                     LOCAL"
  echo "  6) Tool APIs + MCP    (research/image/audio/scrape keys -> /do)  tool-router"
  echo "  7) Control panel      (floating GUI: chat/upload/status/tasks)  LOCAL"
  echo "  8) Status             (what's set / installed)"
  echo "  9) Attach + MCP info  (how /attach and MCP work)"
  echo "  C) Cleanup            (2 din ke test ka malba — dry-run pehle)"
  echo "  T) Token finder       (kaun sa API-key / git token kahan pada hai)"
  echo "  0) Quit"
  printf 'pick: '; read -r ch
  case "$ch" in
    g|G) menu_guided ;;
    r|R) menu_remote ;;
    s|S) menu_shizuku ;;
    1) menu_keys ;;
    2) menu_voice ;;
    3) menu_vedit ;;
    4) menu_vgen ;;
    5) menu_pentest ;;
    6) menu_toolapis ;;
    7) menu_panel ;;
    8) menu_status ;;
    9) menu_mcp ;;
    c|C) menu_cleanup ;;
    t|T) menu_findtokens ;;
    0|q) c 90 "bye. new shells auto-load ~/.ai-env; run 'ai' to chat, 'ai serve' for the panel."; exit 0 ;;
    *) c 31 "pick G, R, S, C, T or 0-9" ;;
  esac
done
