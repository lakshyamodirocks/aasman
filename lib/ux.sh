# fold-node/termux/lib/ux.sh — guided/staged install UX. source this.
# Ek hi Y ke baad avalanche nahi — har stage ka banner, kya-hoga, aur ruk ke aage.
#
#  stage      "title" "what"  "why"     → mandatory; pause; [Enter] aage · [q] ruk ja
#  stage_opt  "title" "what"  "size/why"→ optional; return 0=karo 1=skip; [s] skip bhi
#  substage   "title"                    → chhota sub-header, pause nahi
#  ok / warn / skp / info "msg"          → line-item
#  runv "label" cmd...                   → command chalao, tick/cross dikhao (output chhupa)
#
#  AI_YES=1    → poora auto, koi pause nahi (phase-1 / scripted)
#  AI_STAGED=0 → pause off par banners on

_UXB=$'\033[1m'; _UXD=$'\033[90m'; _UXG=$'\033[32m'; _UXR=$'\033[31m'
_UXY=$'\033[33m'; _UXC=$'\033[36m'; _UXM=$'\033[35m'; _UXX=$'\033[0m'
_UXHR="────────────────────────────────────────────"
: "${STAGE_TOTAL:=7}"; STAGE_N=0
UX_TTY=/dev/tty; ( exec 9</dev/tty ) 2>/dev/null || UX_TTY=/dev/stdin
_ux_interactive(){ [ "${AI_YES:-0}" != "1" ] && [ "${AI_STAGED:-1}" = "1" ] && [ -r "$UX_TTY" ]; }

_ux_bar(){ local n=$1 t=$2 i; printf '%s' "$_UXD"
  for ((i=1;i<=t;i++)); do [ "$i" -le "$n" ] && printf '●' || printf '○'; done; printf '%s' "$_UXX"; }

_ux_banner(){ # <title> <what>
  STAGE_N=$((STAGE_N+1))
  printf '\n%s╭%s╮%s\n' "$_UXM" "$_UXHR" "$_UXX"
  printf '%s│%s  %sStage %s/%s%s   %s\n' "$_UXM" "$_UXX" "$_UXB" "$STAGE_N" "$STAGE_TOTAL" "$_UXX" "$(_ux_bar "$STAGE_N" "$STAGE_TOTAL")"
  printf '%s│%s  %s%s%s\n' "$_UXM" "$_UXX" "$_UXB" "$1" "$_UXX"
  printf '%s╰%s╯%s\n' "$_UXM" "$_UXHR" "$_UXX"
  [ -n "${2:-}" ] && printf '  %s%s%s\n' "$_UXD" "$2" "$_UXX"; }

_ux_stop(){ printf '\n  %sruk gaye. Jitna hua wo saved hai — dobara chalane pe wahin se aage%s\n' "$_UXG" "$_UXX"
  printf '  %s(installer idempotent hai):%s  bash fold-node/termux/fold-all-setup.sh\n\n' "$_UXD" "$_UXX"; exit 0; }

stage(){ _ux_banner "$1" "${2:-}"
  _ux_interactive || { printf '\n'; return 0; }
  while :; do
    printf '\n  %s[Enter] karo%s   %s[?] kyun%s   %s[q] ruk ja%s  ' "$_UXG" "$_UXX" "$_UXD" "$_UXX" "$_UXD" "$_UXX"
    IFS= read -r r <"$UX_TTY" || r=q
    case "$r" in
      ''|y|Y) printf '\n'; return 0;;
      q|Q) _ux_stop;;
      '?') printf '\n  %s%s%s\n' "$_UXD" "${3:-${2:-detail abhi nahi likhi}}" "$_UXX";;
      *) :;;
    esac
  done; }

stage_opt(){ _ux_banner "$1" "${2:-}"
  [ -n "${3:-}" ] && printf '  %s%s%s\n' "$_UXY" "$3" "$_UXX"
  _ux_interactive || { printf '\n'; return 0; }
  while :; do
    printf '\n  %s[Enter] install%s   %s[s] skip%s   %s[?] kyun%s   %s[q] ruk ja%s  ' \
      "$_UXG" "$_UXX" "$_UXY" "$_UXX" "$_UXD" "$_UXX" "$_UXD" "$_UXX"
    IFS= read -r r <"$UX_TTY" || r=s
    case "$r" in
      ''|y|Y) printf '\n'; return 0;;
      s|S|n|N) printf '  %s— skip (baad me setup-menu se bhi ho jayega)%s\n\n' "$_UXD" "$_UXX"; return 1;;
      q|Q) _ux_stop;;
      '?') printf '\n  %s%s%s\n' "$_UXD" "${3:-${2}}" "$_UXX";;
      *) :;;
    esac
  done; }

substage(){ printf '\n  %s┈ %s%s\n' "$_UXC" "$1" "$_UXX"; }
ok(){   printf '    %s✓%s %s\n' "$_UXG" "$_UXX" "$*"; }
warn(){ printf '    %s⚠%s %s\n' "$_UXY" "$_UXX" "$*"; }
skp(){  printf '    %s—%s %s%s%s\n' "$_UXD" "$_UXX" "$_UXD" "$*" "$_UXX"; }
info(){ printf '    %s·%s %s%s%s\n' "$_UXD" "$_UXX" "$_UXD" "$*" "$_UXX"; }

runv(){ local label="$1"; shift
  printf '    %s…%s %s' "$_UXC" "$_UXX" "$label"
  if "$@" >/dev/null 2>&1; then printf '\r    %s✓%s %s   \n' "$_UXG" "$_UXX" "$label"; return 0
  else printf '\r    %s✗%s %s   \n' "$_UXR" "$_UXX" "$label"; return 1; fi; }

ux_summary(){
  printf '\n%s╭%s╮%s\n' "$_UXG" "$_UXHR" "$_UXX"
  printf '%s│%s  %s✅ Aasmaan ready%s\n' "$_UXG" "$_UXX" "$_UXB" "$_UXX"
  printf '%s╰%s╯%s\n' "$_UXG" "$_UXHR" "$_UXX"
  local l; for l in "$@"; do printf '  %s\n' "$l"; done; printf '\n'; }
