#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  AASMAAN · CLEANUP — 2 din ke test/command ka malba saaf karo.
#
#  DRY-RUN by default: sirf DIKHATA hai, kuch delete nahi karta.
#    bash cleanup.sh              # dekho kya hatega
#    bash cleanup.sh --yes        # sach me hatao (phir bhi poochega)
#    bash cleanup.sh --deep       # + ollama blobs & ai-out bhi list me
#    bash cleanup.sh --scrub-history   # shell history se key-jaisi lines hatao
#
#  Keys / vault / backup / setup-profile KABHI nahi chhute — aur unke
#  ANDAR ka kuch bhi nahi (prefix-safe). Poori KEEP list chalte waqt dikhti hai.
# ═══════════════════════════════════════════════════════════════
set -u
B=$'\033[1m'; D=$'\033[90m'; G=$'\033[32m'; R=$'\033[31m'; Y=$'\033[33m'; C=$'\033[36m'; X=$'\033[0m'

GO=no; DEEP=no; SCRUB=no
for a in "$@"; do case "$a" in
  --yes) GO=yes ;;
  --deep) DEEP=yes ;;
  --scrub-history) SCRUB=yes ;;
  -h|--help) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) printf '%s?? anjaan option: %s%s\n' "$Y" "$a" "$X" ;;
esac; done

# ---- kaun se ghar me hain? (Termux aur Debian-VM alag duniya hain) -----------
WHERE="linux"
if [ -n "${TERMUX_VERSION:-}" ] || [ -d /data/data/com.termux ]; then WHERE="TERMUX"
elif [ -r /etc/debian_version ] && [ -e /dev/socket/qemud ] 2>/dev/null; then WHERE="DEBIAN-VM"
elif [ -r /etc/debian_version ] && [ "$(id -un 2>/dev/null)" = droid ]; then WHERE="DEBIAN-VM"
fi

# ---- NEVER touch: ye paths aur inke andar ka sab kuch -----------------------
# --uninstall: hata do jo installer ne likha (keys ~/.ai-env, memory ~/ai-vault, akasha-backup REHTE hain). Termux app
# uninstall = sab kuch gaya; ye sirf 'ai' ko hataata hai aur Termux ko waise chhod deta hai jaise pehle tha.
if [ "${1:-}" = "--uninstall" ]; then
  echo "ye hatega (keys, memory, backup NAHI):"
  RM=( "$HOME/.local/bin/ai" "$HOME/.local/bin/VERSION" "$HOME/.local/bin/setup-menu" "$HOME/.local/bin/screen-dump" "$HOME/.local/bin/vault-backup"
       "$HOME/.local/bin/vedit" "$HOME/.local/bin/say" "$HOME/.local/bin/listen" "$HOME/.local/bin/talk" "$HOME/.local/bin/whisper-stt" "$HOME/.local/bin/__pycache__"
       "$HOME/.ai-experts.json" "$HOME/.ai-experts" "$HOME/.ai-tools.json" "$HOME/.ai-panel.html" "$HOME/.ai-whiteboard.html" "$HOME/.ai-setup-profile" "$HOME/.ai-profile"
       "$HOME/.ai-device.json" "$HOME/.ai-chat.json" "$HOME/.ai-cache.jsonl" "$HOME/.ai-metrics.json" "$HOME/.ai-kb.jsonl" "$HOME/.ai-brains.json" "$HOME/.ai-daemon.json" "$HOME/.ai-update.json" "$HOME/.ai-egress.log" "$HOME/.ai-first-cloud" "$HOME/.ai-telegram.json"
       "$HOME/.termux/boot/akasha-boot.sh" "$HOME/wd.sh" "$HOME/.local/share/aasmaan" "$HOME/ai-vault/reference" )
  for f in "${RM[@]}"; do [ -e "$f" ] && echo "  $f"; done
  echo "  + ~/.bashrc se PATH wali line · phantom-process settings wapas default (rish ho to)"
  if [ "${AI_YES:-0}" != 1 ]; then printf '[Enter] hatao   [q] rehne do  '; read -r r </dev/tty || r=q; [ "$r" = q ] && exit 0; fi
  for f in "${RM[@]}"; do [ -e "$f" ] && rm -rf "$f" && echo "  - $f"; done
  sed -i '/export PATH=.*\.local\/bin.*go\/bin/d' "$HOME/.bashrc" 2>/dev/null || true
  command -v termux-wake-unlock >/dev/null 2>&1 && termux-wake-unlock 2>/dev/null || true
  [ -x "$HOME/rish" ] && "$HOME/rish" -c "settings delete global settings_enable_monitor_phantom_procs; device_config delete activity_manager max_phantom_processes" >/dev/null 2>&1 || true
  echo "done. Bache: ~/.ai-env (keys), ~/ai-vault (memory), ~/akasha-backup. Poora Termux hataana ho to app uninstall."; exit 0
fi
KEEP=( "$HOME/.ai-env" "$HOME/akasha-backup" "$HOME/ai-vault" "$HOME/.ai-setup-profile"
       "$HOME/.ai-experts.json" "$HOME/.ai-experts" "$HOME/.ai-tools.json" "$HOME/.ai-private-names"
       "$HOME/.termux/boot/akasha-boot.sh" "$HOME/akasha-src" "$HOME/.ssh" "$HOME/.gitconfig" )

# prefix-safe: ~/akasha-backup/kuch/bhi bhi bachega, sirf exact match nahi
is_kept(){ local p="$1" k; for k in "${KEEP[@]}"; do
    [ "$p" = "$k" ] && return 0
    case "$p" in "$k"/*) return 0 ;; esac
  done; return 1; }
sz(){ du -sh "$1" 2>/dev/null | cut -f1; }

CAND=()
show(){ # show <path> <why>
  [ -e "$1" ] || return 0
  is_kept "$1" && return 0
  local s; s=$(sz "$1")
  printf '  %s✗%s %-40s %6s  %s%s%s\n' "$R" "$X" "${1/#$HOME/\~}" "${s:-?}" "$D" "$2" "$X"
  CAND+=("$1")
}

MODE_TXT="DRY-RUN — kuch delete NAHI hoga"; [ "$GO" = yes ] && MODE_TXT="DELETE mode — sach me hatega"
printf '%s╭──────────────────────────────────────────────────────╮%s\n' "$C" "$X"
printf '%s│%s  %s🧹 AASMAAN CLEANUP%s   %sghar: %s%s\n'  "$C" "$X" "$B" "$X" "$D" "$WHERE" "$X"
printf '%s│%s  %s%s%s\n' "$C" "$X" "$D" "$MODE_TXT" "$X"
printf '%s╰──────────────────────────────────────────────────────╯%s\n' "$C" "$X"
printf '  %sNOTE: Termux aur Debian-VM alag filesystem hain — jis me malba%s\n' "$D" "$X"
printf '  %ssaaf karna hai, usi me ye script chalao. Abhi: %s%s%s\n' "$D" "$B$WHERE" "$D" "$X"

printf '\n%s🔒 Ye kabhi nahi chhuenge (aur inke andar ka sab kuch):%s\n' "$G" "$X"
for k in "${KEEP[@]}"; do [ -e "$k" ] && printf '  %s✓%s %-40s %s(%s)%s\n' "$G" "$X" "${k/#$HOME/\~}" "$D" "$(sz "$k")" "$X"; done

printf '\n%s🗑  Hatane layak (2 din ke test ka malba):%s\n' "$Y" "$X"
show "$HOME/wd.sh"                "purana VM watchdog — yahi terminal front pe laata tha"
show "$HOME/wd.log"               "uska log"
show "$HOME/wd.out"               "uska output"
show "$HOME/vm-watchdog.sh"       "watchdog ki purani copy"
show "$HOME/.ai-cache.jsonl"      "answer cache — dobara ban jayega"
show "$HOME/.ai-kb.jsonl"         "KB index — /kb build se dobara ban jayega"
show "$HOME/.ai-metrics.json"     "brain metrics — dobara ban jayega"
show "$HOME/.ai-jobs.json"        "purane background job ke results"
show "$HOME/.ai-brains.json"      "canary ka purana result"
show "$HOME/.ai-wishes.jsonl"     "wish-queue — offline me bani, ab bekaar"
show "$HOME/.ai-impact.json"      "impact-radius ka purana lock state"
for d in "$HOME"/*.tmp "$HOME"/.ak.tmp "$HOME"/nohup.out "$HOME"/core.* "$HOME"/*.bak; do show "$d" "temp/junk"; done
while IFS= read -r p; do show "$p" "python cache"; done < <(find "$HOME" -maxdepth 4 -name __pycache__ -type d 2>/dev/null)
while IFS= read -r p; do show "$p" "purana bada log"; done < <(find "$HOME" -maxdepth 2 -name "*.log" -size +1M 2>/dev/null)

if [ "$DEEP" = yes ]; then
  printf '\n%s🌊 --deep (ye dobara banane/download karne padenge):%s\n' "$Y" "$X"
  show "$HOME/ai-out"               "generated images/files — PEHLE DEKH LO"
  show "$HOME/.ollama/models/blobs" "ollama model blobs — dobara pull karna padega (GBs)"
else
  for p in "$HOME/ai-out" "$HOME/.ollama/models/blobs"; do
    [ -e "$p" ] && printf '  %s•%s %-40s %6s  %sbacha liya — hatana ho to --deep%s\n' "$D" "$X" "${p/#$HOME/\~}" "$(sz "$p")" "$D" "$X"
  done
fi

# ---- shell history: kya usme keys pade hain? --------------------------------
HIST_HITS=0; HIST_FILES=()
for h in "$HOME/.bash_history" "$HOME/.zsh_history" "$HOME/.python_history"; do
  [ -r "$h" ] || continue
  n=$(grep -ciE '(api[_-]?key|token|secret|passwd|password|bearer|gsk_|sk-|ghp_|github_pat)' "$h" 2>/dev/null | head -1)
  case "${n:-0}" in ''|*[!0-9]*) n=0 ;; esac
  [ "$n" -gt 0 ] && { HIST_FILES+=("$h"); HIST_HITS=$((HIST_HITS+n)); }
done
if [ "$HIST_HITS" -gt 0 ]; then
  printf '\n%s⚠  SHELL HISTORY me %d line key-jaisi dikhi:%s\n' "$R" "$HIST_HITS" "$X"
  for h in "${HIST_FILES[@]}"; do printf '     %s\n' "${h/#$HOME/\~}"; done
  printf '  %sAgar tune kabhi terminal me key type ki thi, wo plain-text padi hai.%s\n' "$D" "$X"
  if [ "$SCRUB" = yes ]; then
    for h in "${HIST_FILES[@]}"; do
      cp -a "$h" "$h.pre-scrub" 2>/dev/null && chmod 600 "$h.pre-scrub" 2>/dev/null
      grep -viE '(api[_-]?key|token|secret|passwd|password|bearer|gsk_|sk-|ghp_|github_pat)' "$h" > "$h.new" 2>/dev/null \
        && mv "$h.new" "$h" && chmod 600 "$h" \
        && printf '  %s✓ scrub kiya%s %s %s(backup: %s.pre-scrub — usko bhi baad me hata dena)%s\n' "$G" "$X" "${h/#$HOME/\~}" "$D" "${h/#$HOME/\~}" "$X"
    done
  else
    printf '  %sHatane ko:%s bash %s --scrub-history\n' "$B" "$X" "$0"
  fi
fi

if [ ${#CAND[@]} -eq 0 ]; then
  printf '\n  %s✔ Malba kuch nahi — pehle se saaf hai.%s\n\n' "$G" "$X"; exit 0
fi

printf '\n  %s%d cheezein mili.%s\n' "$B" "${#CAND[@]}" "$X"
if [ "$GO" != yes ]; then
  printf '\n  %sKuch delete NAHI hua. Upar ki list padh lo.%s\n' "$D" "$X"
  printf '  %sSach me hatana ho:%s  bash %s --yes\n' "$B" "$X" "$0"
  printf '  %sKisi ek ko bachana ho to pehle use kahin move kar lo.%s\n\n' "$D" "$X"
  exit 0
fi

printf '\n  %sSach me delete karu? [y/N]%s ' "$R" "$X"
read -r ok </dev/tty 2>/dev/null || ok=n
case "${ok:-n}" in [yY]*) ;; *) printf '  %skuch nahi hataya.%s\n\n' "$D" "$X"; exit 0;; esac
FAIL=0
for p in "${CAND[@]}"; do
  if is_kept "$p"; then printf '  %s⊘ skip (KEEP)%s %s\n' "$Y" "$X" "${p/#$HOME/\~}"; continue; fi
  if rm -rf "$p" 2>/dev/null; then printf '  %s✓ hataya%s %s\n' "$G" "$X" "${p/#$HOME/\~}"
  else printf '  %s✗ nahi hata%s %s\n' "$R" "$X" "${p/#$HOME/\~}"; FAIL=$((FAIL+1)); fi
done
printf '\n  %s✔ Saaf. Keys / vault / backup / akasha-src — sab surakshit.%s\n' "$G" "$X"
[ "$FAIL" -gt 0 ] && printf '  %s%d cheez nahi hat payi (permission?).%s\n' "$Y" "$FAIL" "$X"
printf '\n'
