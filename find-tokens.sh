#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  AASMAAN · FIND-TOKENS — is ghar me kaun se token/key kahan pade hain.
#
#    bash find-tokens.sh            # MASKED (screenshot-safe) — default
#    bash find-tokens.sh --reveal   # poori value (Termux me type karne ke liye)
#
#  MASKED me sirf pehle 12 char dikhte hain. --reveal tab hi chalao jab
#  screen tere alawa koi na dekh raha ho — aur uska screenshot mat lena.
#  Ye script kuch bhejti nahi, kuch badalti nahi. Sirf padhti hai.
# ═══════════════════════════════════════════════════════════════
set -u
B=$'\033[1m'; D=$'\033[90m'; G=$'\033[32m'; R=$'\033[31m'; Y=$'\033[33m'; C=$'\033[36m'; X=$'\033[0m'

REVEAL=no
for a in "$@"; do case "$a" in
  --reveal) REVEAL=yes ;;
  -h|--help) sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
esac; done

WHERE="linux"
if [ -n "${TERMUX_VERSION:-}" ] || [ -d /data/data/com.termux ]; then WHERE="TERMUX"
elif [ -r /etc/debian_version ] && [ "$(id -un 2>/dev/null)" = droid ]; then WHERE="DEBIAN-VM"
elif [ -r /etc/debian_version ]; then WHERE="DEBIAN"; fi

# token shapes worth finding
PAT='github_pat_[A-Za-z0-9_]{22,}|gh[pousr]_[A-Za-z0-9]{20,}|gsk_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9_-]{20,}|AIza[A-Za-z0-9_-]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|glpat-[A-Za-z0-9_-]{15,}'

mask(){ local t="$1"; [ "$REVEAL" = yes ] && { printf '%s' "$t"; return; }
        printf '%s…(%d char)' "${t:0:12}" "${#t}"; }

FOUND=0
hit(){ # hit <where> <token> <note>
  FOUND=$((FOUND+1))
  printf '  %s●%s %-34s %s%s%s\n' "$G" "$X" "$(mask "$2")" "$D" "$3" "$X"
  printf '    %s↳ %s%s\n' "$D" "${1/#$HOME/\~}" "$X"
}

scan(){ # scan <file> <note>
  [ -r "$1" ] || return 0
  local t
  while IFS= read -r t; do [ -n "$t" ] && hit "$1" "$t" "$2"; done \
    < <(grep -aoE "$PAT" "$1" 2>/dev/null | sort -u)
}

printf '%s╭──────────────────────────────────────────────────────╮%s\n' "$C" "$X"
printf '%s│%s  %s🔑 TOKEN FINDER%s   %sghar: %s   mode: %s%s\n' "$C" "$X" "$B" "$X" "$D" "$WHERE" \
       "$([ "$REVEAL" = yes ] && echo 'REVEAL ⚠' || echo 'MASKED (safe)')" "$X"
printf '%s╰──────────────────────────────────────────────────────╯%s\n' "$C" "$X"
[ "$REVEAL" = yes ] && printf '  %s⚠ Poori values dikh rahi hain — SCREENSHOT MAT LENA.%s\n' "$R" "$X"

printf '\n%s1. env / config files%s\n' "$Y" "$X"
for f in "$HOME/.ai-env" "$HOME/.ai-env.bak" "$HOME/.ai-setup-profile" "$HOME/.netrc" \
         "$HOME/.env" "$HOME/.profile" "$HOME/.bashrc" "$HOME/.zshrc"; do scan "$f" "env file"; done
for f in "$HOME"/aasmaan-backup/*; do [ -f "$f" ] && scan "$f" "backup"; done

printf '\n%s2. git credential store%s\n' "$Y" "$X"
for f in "$HOME/.git-credentials" "$HOME/.config/git/credentials" \
         "$HOME/.gitconfig" "$HOME/.config/git/config"; do scan "$f" "git creds"; done

printf '\n%s3. clone ke remote URL me (yahi sabse aam jagah hai)%s\n' "$Y" "$X"
GITHIT=0
while IFS= read -r gc; do
  scan "$gc" "repo remote"
  if grep -aqE 'https://[^/@[:space:]]+@' "$gc" 2>/dev/null; then
    GITHIT=1
    printf '  %s●%s %s me embedded credential hai%s\n' "$G" "$X" "${gc/#$HOME/\~}" "$X"
    if [ "$REVEAL" = yes ]; then grep -aoE 'https://[^/@[:space:]]+@[^[:space:]]+' "$gc" | sed 's/^/    /'
    else grep -aoE 'https://[^/@[:space:]]+@' "$gc" | sed -E 's|https://(.{0,12}).*|    https://\1…@ (chhupa hua)|'; fi
    FOUND=$((FOUND+1))
  fi
done < <(find "$HOME" -maxdepth 4 -path '*/.git/config' 2>/dev/null)
[ "$GITHIT" = 0 ] && printf '  %skisi clone ke remote me embedded token nahi mila%s\n' "$D" "$X"

printf '\n%s4. gh CLI%s\n' "$Y" "$X"
scan "$HOME/.config/gh/hosts.yml" "gh CLI login"

printf '\n%s5. GitHub Actions self-hosted runner%s\n' "$Y" "$X"
RH=0
for d in "$HOME/actions-runner" "$HOME/runner" "$HOME/_work/../actions-runner"; do
  [ -d "$d" ] || continue; RH=1
  printf '  %srunner mila:%s %s\n' "$B" "$X" "${d/#$HOME/\~}"
  for f in "$d/.credentials" "$d/.runner" "$d/.credentials_rsaparams" "$d/.env"; do
    [ -f "$f" ] && printf '    %s· %s  %s(runner ka apna credential — ye clone ke KAAM KA NAHI)%s\n' "$D" "$(basename "$f")" "$D" "$X"
  done
done
[ "$RH" = 0 ] && printf '  %sis ghar me runner install nahi hai%s\n' "$D" "$X"

printf '\n%s6. shell history%s\n' "$Y" "$X"
HH=0
for f in "$HOME/.bash_history" "$HOME/.zsh_history" "$HOME/.python_history" "$HOME/.local/share/fish/fish_history"; do
  [ -r "$f" ] || continue
  n=$(grep -acE "$PAT" "$f" 2>/dev/null | head -1); case "${n:-0}" in ''|*[!0-9]*) n=0;; esac
  [ "$n" -gt 0 ] && { HH=1; scan "$f" "HISTORY me pada hai — ise ROTATE karna"; }
done
[ "$HH" = 0 ] && printf '  %shistory me koi token nahi%s\n' "$D" "$X"

printf '\n%s──────────────────────────────────────────────%s\n' "$D" "$X"
if [ "$FOUND" -eq 0 ]; then
  printf '  %sIs ghar me koi token nahi mila.%s\n' "$Y" "$X"
  printf '  %sMatlab git token yahan tha hi nahi — naya banana padega (neeche dekho).%s\n\n' "$D" "$X"
else
  printf '  %s%d jagah token mila.%s\n' "$B" "$FOUND" "$X"
  [ "$REVEAL" = no ] && printf '  %sValue chahiye (Termux me type karne ko):%s bash %s --reveal\n\n' "$D" "$X" "$0"
fi
printf '  %sgithub_pat_… = fine-grained PAT (clone ke liye YAHI chahiye)%s\n' "$D" "$X"
printf '  %sghp_…        = classic PAT (ye bhi chalega)%s\n' "$D" "$X"
printf '  %srunner ka .credentials = clone ke kaam ka NAHI%s\n\n' "$D" "$X"
