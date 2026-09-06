#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  PC EDITION · setup — Linux / macOS / WSL2.   (Windows native: use WSL2, see README)
#
#  Iska ek hi usool: TERA SETUP TERA HAI. Ye script:
#    · sirf $HOME ke andar likhta hai, aur jo likhta hai uski LIST rakhta hai (manifest)
#    · kabhi ~/.bashrc / ~/.zshrc / PATH nahi chhedta — line dikhata hai, tu chahe to daale
#    · kabhi sudo / pip install / curl|sh khud nahi chalata — official command dikhata hai, poochhta hai
#    · tere existing Ollama / models / keys ko reuse karta hai, dobara install nahi
#    · --uninstall se EXACTLY wahi hataata hai jo isne banaya tha, aur kya hataya wo dikhata hai
#
#     bash akasha-fold/pc/pc-setup.sh              # guided, staged (Enter = aage, q = ruk)
#     bash akasha-fold/pc/pc-setup.sh --uninstall  # manifest ke hisaab se saaf
#     AI_YES=1 bash akasha-fold/pc/pc-setup.sh     # scripted (tests) — koi pause nahi
# ═══════════════════════════════════════════════════════════════
set -u
SELFDIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# Do layouts: (1) public BUNDLE — sab kuch isi folder me (build-dist.sh banata hai);
#             (2) monorepo — fold-node/termux ke andar se.
if [ -f "$SELFDIR/ai.py" ]; then
  SRC_AI="$SELFDIR/ai.py"; SRC_LIB="$SELFDIR/lib"; SRC_EXPERTS="$SELFDIR/experts.json"; SRC_PACKS="$SELFDIR/experts"
  SRC_TOOLS="$SELFDIR/tools-routing.json"; SRC_PANEL="$SELFDIR/panel.html"; SRC_BOARD="$SELFDIR/whiteboard.html"
else
  ROOT="$(cd "$SELFDIR/../.." && pwd)"; TX="$ROOT/fold-node/termux"
  SRC_AI="$TX/ai-termux.py"; SRC_LIB="$TX/lib"; SRC_EXPERTS="$TX/experts.json"; SRC_PACKS="$TX/experts"
  SRC_TOOLS="$ROOT/fold-node/tools-routing.json"; SRC_PANEL="$TX/panel.html"; SRC_BOARD="$ROOT/fold-node/akasha-whiteboard.html"
  [ -f "$ROOT/akasha-fold/lib/probe.sh" ] && PROBE="$ROOT/akasha-fold/lib/probe.sh"
fi
. "$SRC_LIB/ux.sh"; . "${PROBE:-$SRC_LIB/probe.sh}"
STAGE_TOTAL=7; export AI_BRAND="${AI_BRAND:-Aasmaan}"
# ── stage 0: language. English by default; Enter keeps it; the choice lives in ~/.ai-setup-profile as AI_LANG
# (read by 'ai' at every start). Re-runs keep the earlier answer; AI_YES/scripted runs never ask.
PROF0="$HOME/.ai-setup-profile"; _pl="$(grep -m1 '^AI_LANG=' "$PROF0" 2>/dev/null | cut -d= -f2)"
export AI_LANG="${AI_LANG:-${_pl:-}}"
if [ -z "$AI_LANG" ] && [ "${AI_YES:-0}" != "1" ] && [ -r "${UX_TTY:-/dev/tty}" ]; then
  printf '\n  Language / भाषा:   [1] English   [2] Hinglish   [3] हिन्दी      Enter = English\n  > '
  IFS= read -r _l <"${UX_TTY:-/dev/tty}" || _l=1
  case "$_l" in 2) AI_LANG=hinglish;; 3) AI_LANG=hi;; *) AI_LANG=en;; esac; export AI_LANG
fi
AI_LANG="${AI_LANG:-en}"; export UX_LANG="$AI_LANG"
t(){ case "$1" in   # t <key> — stage titles in the chosen language (Hinglish is today's text; hi reads the same)
  machine) [ "$AI_LANG" = en ] && printf 'Your machine' || printf 'Teri machine';;
  machine.what) [ "$AI_LANG" = en ] && printf 'OS · RAM · GPU · Python · Ollama — only LOOKS, changes nothing' || printf 'OS · RAM · GPU · Python · Ollama — sirf DEKHTA hai, kuch badalta nahi';;
  brain) printf 'Local brain (Ollama)';;
  install) [ "$AI_LANG" = en ] && printf "'ai' install" || printf "'ai' install";;
  keys) printf 'Cloud brains (free keys)';;
  keys.what) [ "$AI_LANG" = en ] && printf 'Groq · Cerebras · Gemini · OpenRouter — all optional, all free tier' || printf 'Groq · Cerebras · Gemini · OpenRouter — sab optional, sab free tier';;
  path) [ "$AI_LANG" = en ] && printf 'PATH (your call)' || printf 'PATH (tera faisla)';;
  path.what) [ "$AI_LANG" = en ] && printf 'I do NOT touch ~/.bashrc / ~/.zshrc' || printf 'Main ~/.bashrc / ~/.zshrc NAHI chhedta';;
  daemon) printf 'Daemon (optional)';;
  proof) printf 'Proof';;
  proof.what) [ "$AI_LANG" = en ] && printf 'ai version · agents list · one daemon tick' || printf 'ai version · agents list · daemon ek tick';;
  *) printf '%s' "$1";; esac; }
BIN="${AI_BIN_DIR:-$HOME/.local/bin}"
# macOS has no `timeout` (coreutils' is `gtimeout`); never let a proof step hang, never fail for lack of the tool
_to(){ if command -v timeout >/dev/null 2>&1; then timeout "$@"; elif command -v gtimeout >/dev/null 2>&1; then gtimeout "$@"; else shift; "$@"; fi; }
MANIFEST="$HOME/.ai-pc-manifest"           # har install ki gayi file/dir ki list — uninstall isi se

# ── manifest: jo bhi likho, likh ke batao ───────────────────────────────────
mf(){ grep -qxF "$1" "$MANIFEST" 2>/dev/null || printf '%s\n' "$1" >> "$MANIFEST"; }
put(){ # put <src> <dst> [mode]  — copy + manifest
  mkdir -p "$(dirname "$2")" && install -m "${3:-644}" "$1" "$2" && mf "$2"; }

# ── uninstall: manifest me jo hai, sirf wahi ─────────────────────────────────
if [ "${1:-}" = "--uninstall" ]; then
  printf '%suninstall (Linux / macOS / WSL2)%s\n' "$_UXB" "$_UXX"
  [ -f "$MANIFEST" ] || { echo "  manifest nahi mila ($MANIFEST) — is machine pe install hua hi nahi tha, ya pehle hi hat gaya."; exit 0; }
  echo "  ye hatega (sirf ye — tere models, keys-file, vault NAHI):"
  sed 's/^/    /' "$MANIFEST"
  printf '  ~/.ai-env (teri keys) aur ~/ai-vault (teri memory) JAAN-BOOJH ke rakhe jaate hain. Hatane ho to khud: rm -rf ~/.ai-env ~/ai-vault\n'
  if _ux_interactive; then printf '\n  [Enter] hatao   [q] rehne do  '; IFS= read -r r <"$UX_TTY" || r=q; [ "$r" = q ] && exit 0; fi
  grep -q 'aasmaan-daemon.service' "$MANIFEST" && systemctl --user disable --now aasmaan-daemon.service >/dev/null 2>&1 && echo "  - daemon service stopped"
  grep -q 'com.aasmaan.daemon.plist' "$MANIFEST" && launchctl unload "$HOME/Library/LaunchAgents/com.aasmaan.daemon.plist" >/dev/null 2>&1 && echo "  - LaunchAgent unloaded"
  while IFS= read -r f; do
    case "$f" in "$HOME"/*) [ -e "$f" ] && { rm -rf "$f"; echo "  - $f"; } ;; *) echo "  ? skipped (outside HOME): $f";; esac
  done < "$MANIFEST"
  rm -f "$MANIFEST"
  # runtime files jo 'ai' ne chalte-chalte banayi (manifest me nahi — install ne nahi likhi thi). Dikhao, poochho.
  RT=""; for f in .ai-daemon.json .ai-update.json .ai-egress.log .ai-first-cloud .ai-telegram.json .ai-chat.json .ai-cache.jsonl .ai-device.json .ai-metrics.json .ai-kb.jsonl .ai-brains.json .ai-jobs.json .ai-tasks.json .ai-traces.jsonl .ai-wishes.jsonl .ai-feedback.jsonl .ai-corpus.jsonl .ai-profile .ai-private-names; do [ -e "$HOME/$f" ] && RT="$RT $HOME/$f"; done
  if [ -n "$RT" ]; then
    echo "  'ai' ki runtime files (chat state, cache, metrics — koi key/memory nahi):"; for f in $RT; do echo "    $f"; done
    r=""; if _ux_interactive; then printf '  [Enter] ye bhi hatao   [k] rakho  '; IFS= read -r r <"$UX_TTY" || r=k; fi
    [ "$r" = k ] || { rm -f $RT; echo "  - runtime files removed"; }
  fi
  echo "  done. Ollama aur uske models tere hain — unhe chhua nahi. Bache: ~/.ai-env (keys), ~/ai-vault (memory) — tere."; exit 0
fi

# ── stage 1: ye machine kya hai ──────────────────────────────────────────────
stage "$(t machine)" "$(t machine.what)" \
  "Aage ke har faisle (kaunsa local model, GPU use hoga ya nahi) isi report pe tikte hain. Kuch install nahi hota is stage me."
OS="$(uname -s 2>/dev/null || echo ?)"; ARCH="$(uname -m 2>/dev/null || echo ?)"
WSL=0; grep -qi microsoft /proc/version 2>/dev/null && WSL=1
case "$OS" in
  Linux)  RAM=$(probe_ram_mb); FREE=$(probe_free_mb);;
  Darwin) RAM=$(( $(sysctl -n hw.memsize 2>/dev/null || echo 0) / 1048576 )); FREE="";;
  *)      RAM=""; FREE="";;
esac
DISK=$(probe_disk_mb "$HOME")
GPU="none detected"; VRAM=""
if command -v nvidia-smi >/dev/null 2>&1; then
  GPU="NVIDIA $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)"
  VRAM=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>/dev/null | head -1)
elif command -v rocm-smi >/dev/null 2>&1; then GPU="AMD (rocm-smi present)"
elif [ "$OS" = Darwin ] && [ "$ARCH" = arm64 ]; then GPU="Apple Silicon (unified memory = RAM)"; VRAM="$RAM"
elif ls /sys/class/drm/card*/device/vendor >/dev/null 2>&1; then
  for v in /sys/class/drm/card*/device/vendor; do case "$(cat "$v" 2>/dev/null)" in 0x1002) GPU="AMD (drm)";; 0x8086) GPU="Intel (drm)";; 0x10de) GPU="NVIDIA (driver missing?)";; esac; done
fi
PY="$(command -v python3 || true)"; PYV="$("$PY" -c 'import sys;print("%d.%d"%sys.version_info[:2])' 2>/dev/null || echo none)"
OLL="$(command -v ollama || true)"; OLL_UP=0; OLL_MODELS=""
if [ -n "$OLL" ]; then
  if "$PY" - <<'PY' 2>/dev/null; then OLL_UP=1; OLL_MODELS="$(ollama list 2>/dev/null | awk 'NR>1{print $1}' | tr '\n' ' ')"; fi
import urllib.request;urllib.request.urlopen("http://127.0.0.1:11434/api/tags",timeout=2)
PY
fi
printf '  %-10s %s %s%s\n' "OS:" "$OS" "$ARCH" "$( [ $WSL = 1 ] && echo '(WSL2)')"
printf '  %-10s %s MB total · %s MB free now\n' "RAM:" "${RAM:-?}" "${FREE:-?}"
printf '  %-10s %s MB free in HOME\n' "Disk:" "${DISK:-?}"
printf '  %-10s %s%s\n' "GPU:" "$GPU" "${VRAM:+ · $VRAM MB}"
printf '  %-10s %s\n' "Python:" "${PYV} ${PY:+($PY)}"
printf '  %-10s %s\n' "Ollama:" "$( [ -n "$OLL" ] && echo "installed$( [ $OLL_UP = 1 ] && echo ', running · models: '"${OLL_MODELS:-(none yet)}" )" || echo 'not installed (optional — cloud free rungs bina iske bhi chalte hain)')"
case "$PYV" in none|2.*|3.[0-7])
  if [ "$OS" = Darwin ]; then warn "Python 3.8+ chahiye. Mac pe sabse aasan:  xcode-select --install   (Apple ka apna, ~2 min)  ya python.org/downloads se installer. Phir ye script dobara."
  else warn "Python 3.8+ chahiye. Ye script Python install NAHI karta (tera package manager tera hai): apt/dnf/pacman se python3 lo, phir dobara."; fi; exit 1;; esac
[ "$OS" = Linux ] || [ "$OS" = Darwin ] || { warn "Sirf Linux/macOS/WSL2 — Windows native ke liye WSL2 kholo aur wahi se chalao."; exit 1; }

# ── stage 2: local brain — tera Ollama, ya official command (tu chalayega) ──
# Tiers from research/pc/A-local-inference-pc.md §4 (license-gated: Apache-2.0 only; sizes = Ollama download).
# Hardware ADAPT karne ke liye hai, DEPEND karne ke liye nahi: kam RAM = chhota model ya sirf cloud, install phir bhi hota hai.
pick_model(){ local v="${VRAM:-0}" r="${RAM:-0}"; v=$(num_or "$v" 0); r=$(num_or "$r" 0)
  if   [ "$OS" = Darwin ] && [ "$ARCH" = arm64 ]; then
       if [ "$r" -ge 30000 ]; then echo "qwen3-coder:30b"; elif [ "$r" -ge 17000 ]; then echo "qwen2.5-coder:14b"; elif [ "$r" -ge 14000 ]; then echo "qwen2.5-coder:7b"; else echo "qwen2.5-coder:3b"; fi
  elif [ "$v" -ge 15000 ]; then echo "qwen2.5-coder:32b"     # 16-24 GB VRAM · 20 GB
  elif [ "$v" -ge 11000 ]; then echo "qwen2.5-coder:14b"     # 12 GB VRAM · 9 GB
  elif [ "$v" -ge 5500  ]; then echo "qwen2.5-coder:7b"      # 6-8 GB VRAM · 4.7 GB
  elif [ "$r" -ge 30000 ]; then echo "qwen3-coder:30b"       # CPU 32 GB+ · MoE 3.3B active · 19 GB
  elif [ "$r" -ge 14000 ]; then echo "qwen2.5-coder:7b"      # CPU 16 GB · 4.7 GB
  elif [ "$r" -ge 7000  ]; then echo "qwen2.5-coder:3b"      # CPU 8 GB · 1.9 GB
  elif [ "$r" -ge 3500  ]; then echo "qwen2.5-coder:1.5b"    # CPU 4 GB · 1 GB
  else echo ""; fi; }
MODEL="$(pick_model)"
if stage_opt "Local brain (Ollama)" "Offline code-model tere hardware ke hisaab se: ${MODEL:-koi nahi (RAM kam) — cloud rungs use honge}" \
   "Ollama ek background service laata hai (Linux: systemd unit + apna user, sudo; macOS: menu-bar app, user-space). Ye script use install NAHI karta — official command dikhata hai, tu chalata hai. Pehle se hai to wahi use hoga. Context 16k pin hota hai (Ollama ka default 4k coding ke liye kam hai)."; then
  if [ -z "$OLL" ]; then
    echo "  Official install (ollama.com/download) — ye TU chalayega, main nahi:"
    case "$OS" in
      Darwin) echo "     https://ollama.com/download/mac   → Ollama.app (menu-bar icon; pehli baar 'ollama' command install karne ka dialog aayega — Allow)"
              echo "     (developer ho to:  brew install ollama)";;
      Linux)  echo "     curl -fsSL https://ollama.com/install.sh | sh    # sudo + systemd service + 'ollama' user banata hai; padh lo: github.com/ollama/ollama/blob/main/docs/linux.mdx"
              echo "     (bina root / bina boot-service: tarball \$HOME me nikaal ke  'ollama serve'  haath se — docs/linux.mdx 'Manual install')";;
    esac
    echo "  Install karke dobara ye script chalao — ye stage tab model pull karega."
  elif [ $OLL_UP = 0 ]; then
    warn "ollama hai par chal nahi raha. Chalao:  ollama serve   (ya macOS app kholo), phir dobara."
  elif [ -n "$MODEL" ]; then
    if echo " $OLL_MODELS " | grep -q " $MODEL "; then ok "$MODEL pehle se hai — pull skip"
    else
      echo "  pull hoga: $MODEL  (size disk pe jayegi — free: ${DISK:-?} MB). Tere baaki models ko chhua nahi jayega."
      if _ux_interactive; then printf '  [Enter] pull   [s] skip  '; IFS= read -r r <"$UX_TTY" || r=s; else r=s; fi
      [ "$r" = s ] || runv "ollama pull $MODEL" ollama pull "$MODEL"
    fi
  fi
fi

# ── stage 3: 'ai' + experts + packs — sirf $HOME ke andar, manifest ke saath ─
stage "'ai' install" "ek Python file → $BIN/ai · 19 experts + packs (18 specialists + Aasmaan itself) → ~/.ai-experts* · tool router → ~/.ai-tools.json" \
  "Zero dependencies: stdlib Python. Koi pip nahi, koi venv nahi, koi sudo nahi. Har file manifest me — --uninstall se wahi hategi."
mkdir -p "$BIN"
{ echo '#!/usr/bin/env python3'; if head -1 "$SRC_AI" | grep -q '^#!'; then tail -n +2 "$SRC_AI"; else cat "$SRC_AI"; fi; } > "$BIN/ai.tmp" && chmod 755 "$BIN/ai.tmp" && mv "$BIN/ai.tmp" "$BIN/ai" && mf "$BIN/ai" && ok "$BIN/ai ($(wc -l < "$BIN/ai") lines, one file — padh lo, sab dikhta hai)"
put "$SRC_EXPERTS" "$HOME/.ai-experts.json" && ok "19 experts (~/.ai-experts.json — 18 specialists + aasmaan)"
np=0; for d in "$SRC_PACKS"/*/; do e=$(basename "$d"); [ -f "$d/PERSONA.md" ] || continue
  for f in "$d"/*.md; do put "$f" "$HOME/.ai-experts/$e/$(basename "$f")"; done; np=$((np+1)); done
mf "$HOME/.ai-experts"; ok "$np expert packs (persona + KB) → ~/.ai-experts/"
[ -f "$SRC_TOOLS" ] && put "$SRC_TOOLS" "$HOME/.ai-tools.json" && ok "tool router (~/.ai-tools.json)"
[ -f "$SRC_PANEL" ] && put "$SRC_PANEL" "$HOME/.ai-panel.html" && ok "web panel (ai serve)"
[ -f "$SELFDIR/VERSION" ] && put "$SELFDIR/VERSION" "$BIN/VERSION"   # 'ai version' + update-check read it beside 'ai'
[ -f "$SRC_BOARD" ] && put "$SRC_BOARD" "$HOME/.ai-whiteboard.html"
[ -n "$MODEL" ] && { grep -q '^AI_LOCAL_MODEL=' "$HOME/.ai-setup-profile" 2>/dev/null || { printf 'AI_TIER=PC\nAI_LOCAL_MODEL=%s\nAI_LOCAL_CTX=16384\n' "$MODEL" > "$HOME/.ai-setup-profile"; mf "$HOME/.ai-setup-profile"; }; }
# /setup inside 'ai' re-runs THIS script; /update re-fetches from the repo. Recorded, not guessed.
PROF="$HOME/.ai-setup-profile"; touch "$PROF"; grep -v '^AI_SETUP_CMD=\|^AI_LANG=' "$PROF" > "$PROF.tmp" 2>/dev/null; printf 'AI_SETUP_CMD=bash %q\nAI_LANG=%s\n' "$SELFDIR/pc-setup.sh" "$AI_LANG" >> "$PROF.tmp"; mv "$PROF.tmp" "$PROF"; mf "$PROF"

# ── stage 4: keys — jo env me pehle se hain unhe REUSE, naye 0600 file me ────
stage "$(t keys)" "$(t keys.what)" \
  "Keys ~/.ai-env (0600) me jaati hain — 'ai' khud padhta hai, koi shell rc nahi chhedta, child process ko nahi milti. Jo key tere env me PEHLE se hai use dobara nahi poochhta."
ENVF="$HOME/.ai-env"; touch "$ENVF"; chmod 600 "$ENVF"
setkey(){ local var=$1 what=$2 url=$3 val
  if [ -n "${!var:-}" ]; then ok "$var tere env me pehle se hai — wahi use hoga (file me copy nahi)"; return; fi
  grep -q "^export $var=" "$ENVF" && { ok "$var ~/.ai-env me hai"; return; }
  _ux_interactive || return 0
  printf '  %s (%s) — blank = skip: ' "$what" "$url"; IFS= read -rs val <"$UX_TTY"; echo
  [ -n "$val" ] && { printf 'export %s=%q\n' "$var" "$val" >> "$ENVF"; ok "$var saved (0600)"; }; }
setkey GROQ_API_KEY     "Groq (fast, free)"      "console.groq.com"
setkey CEREBRAS_API_KEY "Cerebras (fast, free)"  "cloud.cerebras.ai"
setkey GEMINI_API_KEY   "Gemini (free tier)"     "aistudio.google.com"
setkey OPENROUTER_API_KEY "OpenRouter (free models)" "openrouter.ai/keys"
# ~/.ai-env jaan-boojh ke manifest me NAHI — uninstall teri keys kabhi nahi hataata.

# ── stage 5: PATH — kuch nahi badalta; line dikhata hai ──────────────────────
stage "$(t path)" "$(t path.what)" \
  "Bahut installers chupke rc file me line daal dete hain — hum nahi. Ek line dikha raha hoon; daalni ho to tu daal, warna poore path se chala."
case ":$PATH:" in *":$BIN:"*) ok "$BIN pehle se PATH me hai — 'ai' seedha chalega";;
  *) warn "$BIN PATH me nahi. Do raaste:"
     echo "     1) abhi ke liye:        $BIN/ai"
     echo "     2) hamesha ke liye, apni shell file me KHUD ye line daalo ($( [ "$OS" = Darwin ] && echo '~/.zshrc' || echo '~/.bashrc, zsh ho to ~/.zshrc' )):"
     echo "          export PATH=\"$BIN:\$PATH\"";;
esac

# ── stage 6: daemon (optional) — awareness rakhta hai, kaam nahi karta ────────
if stage_opt "Daemon (optional)" "har 30 min: update-check · brains ping · pending wishes · vault re-index → ~/.ai-daemon.json ('ai' aur model isse padhte hain)" \
   "Unattended = koi forge/shell/vendor-CLI nahi (code me gate hai). Linux: systemd --user unit (tere user ke andar, sudo nahi). macOS: LaunchAgent plist. Dono manifest me, --uninstall hata deta hai. Skip karo to  'ai daemon'  haath se bhi chalta hai."; then
  if [ "$OS" = Linux ] && command -v systemctl >/dev/null 2>&1 && systemctl --user show-environment >/dev/null 2>&1; then
    U="$HOME/.config/systemd/user/aasmaan-daemon.service"; mkdir -p "$(dirname "$U")"
    printf '[Unit]\nDescription=Aasmaan daemon (awareness only, unattended-safe)\n[Service]\nExecStart=%s %s daemon --interval=30\nEnvironment=AI_ATTENDED=0\nEnvironment=PATH=%s:/usr/local/bin:/usr/bin:/bin\nRestart=on-failure\nRestartSec=30\nNice=10\n[Install]\nWantedBy=default.target\n' "$PY" "$BIN/ai" "$(dirname "$PY")" > "$U"; mf "$U"
    systemctl --user daemon-reload && systemctl --user enable --now aasmaan-daemon.service >/dev/null 2>&1 && ok "systemd --user: aasmaan-daemon enabled (status: systemctl --user status aasmaan-daemon)" || warn "unit likha, enable fail — 'systemctl --user enable --now aasmaan-daemon' khud chalao"
  elif [ "$OS" = Darwin ]; then
    PL="$HOME/Library/LaunchAgents/com.aasmaan.daemon.plist"; mkdir -p "$(dirname "$PL")"
    printf '<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n<plist version="1.0"><dict>\n<key>Label</key><string>com.aasmaan.daemon</string>\n<key>ProgramArguments</key><array><string>%s</string><string>%s</string><string>daemon</string><string>--interval=30</string></array>\n<key>EnvironmentVariables</key><dict><key>AI_ATTENDED</key><string>0</string><key>PATH</key><string>%s:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string></dict>\n<key>RunAtLoad</key><true/><key>KeepAlive</key><true/><key>ThrottleInterval</key><integer>60</integer>\n<key>StandardErrorPath</key><string>%s/.ai-daemon.err</string>\n</dict></plist>\n' "$PY" "$BIN/ai" "$(dirname "$PY")" "$HOME" > "$PL"; mf "$PL"
    launchctl unload "$PL" >/dev/null 2>&1; launchctl load "$PL" >/dev/null 2>&1
    if launchctl list 2>/dev/null | grep -q com.aasmaan.daemon; then ok "LaunchAgent loaded (com.aasmaan.daemon) · log: ~/.ai-daemon.err"; else warn "plist likha, load nahi hua — 'launchctl load $PL' khud chalao"; fi
  else warn "is system pe user-service nahi mila — haath se:  $BIN/ai daemon"; fi
fi

# ── stage 7: proof — chala ke dikhao, maan ke nahi ───────────────────────────
stage "$(t proof)" "$(t proof.what)" "Install 'ho gaya' tab hai jab chal ke dikhe."
runv "ai compiles on this Python ($PYV)" "$PY" -m py_compile "$BIN/ai"; rm -rf "$BIN/__pycache__"
case "$SELFDIR" in "$HOME"/.local/share/aasmaan*) mf "$HOME/.local/share/aasmaan";; esac    # the downloaded bundle is ours to remove too
AI_FORCE_OFFLINE=1 "$BIN/ai" version 2>/dev/null | sed 's/^/    /' | head -4
n=$(printf '/agents\n/quit\n' | AI_FORCE_OFFLINE=1 _to 60 "$BIN/ai" 2>/dev/null | grep 'agents:' | grep -o '[a-z]*\*' | wc -l)
[ "$n" -ge 19 ] && ok "$n/19 expert packs load hote hain (offline, bina brain ke)" || warn "packs load nahi hue ($n/19) — 'ai' ke andar /agents chala ke dekho"
AI_FORCE_OFFLINE=1 _to 60 "$BIN/ai" daemon --once >/dev/null 2>&1 && [ -f "$HOME/.ai-daemon.json" ] && ok "daemon: one tick ran, state written (~/.ai-daemon.json)" || warn "daemon tick failed — 'ai daemon --once' chala ke dekho"
ux_summary \
  "chalao:  $BIN/ai        (offline bhi: /memory /kb /agent rachaka <code sawaal>)" \
  "code:    /agent rachaka <paste traceback>   ·  /do forge <tool naam>  ·  /ctx <file>" \
  "hataana: bash $SELFDIR/pc-setup.sh --uninstall   (manifest: $MANIFEST)"
