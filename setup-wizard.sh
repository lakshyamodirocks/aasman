#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  AASMAAN · SETUP WIZARD  v2
#  Install se PEHLE. Kuch install nahi karta — sirf ~/.ai-setup-profile
#  likhta hai, jise installer chup-chaap follow karta hai.
#
#  v2 me kya badla (v1 ki shikayaton se):
#   · har jagah  b = peeche   ·  q = bahar   ·  ? = detail
#   · har option ka asar CHUNNE SE PEHLE dikhta hai (RAM · disk · 🔋)
#   · jo fit nahi hota wo CHHUPTA NAHI — nishaan lagta hai, wajah ke saath
#   · "fit nahi ho raha" pe tujhe 4 raaste milte hain, LITE pe dhakela
#     nahi jaata
#   · aakhir me review screen — koi bhi step 1-4 dabaa ke badal sakta hai
# ═══════════════════════════════════════════════════════════════
set -u
B=$'\033[1m'; D=$'\033[90m'; G=$'\033[32m'; R=$'\033[31m'; Y=$'\033[33m'
C=$'\033[36m'; M=$'\033[35m'; X=$'\033[0m'
PROFILE="$HOME/.ai-setup-profile"

HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
# shellcheck source=lib/probe.sh
if [ -r "$HERE/lib/probe.sh" ]; then . "$HERE/lib/probe.sh"
else
  probe_ram_mb(){ awk '/MemTotal/{print int($2/1024)}' /proc/meminfo 2>/dev/null; }
  probe_free_mb(){ awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo 2>/dev/null; }
  probe_disk_mb(){ df -Pm "${1:-$HOME}" 2>/dev/null | awk 'NR>1&&NF>=4{print $(NF-2);exit}'; }
  probe_cores(){ nproc 2>/dev/null || echo 1; }
  probe_device(){ getprop ro.product.model 2>/dev/null || uname -m; }
  num_or(){ case "${1:-}" in ''|*[!0-9]*) printf '%s' "$2";; *) printf '%s' "$1";; esac; }
fi

RAM=$(num_or "$(probe_ram_mb)" 0)
FREE=$(num_or "$(probe_free_mb)" 0)
DISK_RAW=$(probe_disk_mb "$HOME")      # "" = pata nahi chala
CORES=$(probe_cores); DEV=$(probe_device)
# what platform is this REALLY? (iOS can never run this script, so it is a manual pick only)
if [ -d /data/data/com.termux/files ]; then PLAT_DET=1; PLAT_DET_NAME="Android (Termux)"
elif [ "$(uname -s 2>/dev/null)" = Darwin ]; then PLAT_DET=3; PLAT_DET_NAME="Mac"
else PLAT_DET=3; PLAT_DET_NAME="Linux"; fi
DISK_KNOWN=yes; [ -z "$DISK_RAW" ] && DISK_KNOWN=no
DISK=$(num_or "$DISK_RAW" 0)

TTY=/dev/tty; ( exec 3</dev/tty ) 2>/dev/null || TTY=/dev/stdin

# ── choices (state) ─────────────────────────────────────────────
LANGC="${AI_LANG:-en}"   # step 0: en (default) | hinglish | hi
PLAT=${PLAT_DET:-1} INTENT=1 BRAIN=2 CTXI=3 ADV=0 MORE=0
EX_VOICE=0 EX_SCREEN=0 EX_FFMPEG=1 EX_PANEL=1 EX_PENTEST=0

# ── data tables ─────────────────────────────────────────────────
# brain: name | ollama-tag | weights MB | disk MB | KV MB per 1k ctx
brain_f(){ case "$1" in
  0) echo "koi nahi (sirf cloud)||0|0|0";;
  1) echo "qwen3:1.7b|qwen3:1.7b|1100|1400|35";;
  2) echo "qwen3:4b|qwen3:4b-instruct-2507-q4_K_M|2600|2600|70";;
  3) echo "qwen3:8b|qwen3:8b|5000|5000|130";;
esac; }
bf(){ brain_f "$1" | cut -d'|' -f"$2"; }
ctx_k(){ case "$1" in 1) echo 2;; 2) echo 4;; 3) echo 8;; 4) echo 16;; 5) echo 32;; esac; }

RUNTIME_MB=350          # ollama process khud
fit_brain(){ if [ "$RAM" -ge 12000 ]; then echo 3; elif [ "$RAM" -ge 7000 ]; then echo 2; elif [ "$RAM" -ge 4000 ]; then echo 1; else echo 0; fi; }
small_brain(){ if [ "$RAM" -ge 4000 ]; then echo 1; else echo 0; fi; }
batt_of(){ case "$1" in 0) echo "na ke barabar";; 1) echo "halka";; 2) echo "dhyan rakhna — lambi chat me phone garam";; *) echo "bhaari — charger pe behtar";; esac; }
need_ram(){ # need_ram <brain> <ctxi>
  local b=$1 c=$2 w kv k
  [ "$b" = 0 ] && { echo 90; return; }
  w=$(bf "$b" 3); kv=$(bf "$b" 5); k=$(ctx_k "$c")
  echo $(( w + kv*k + RUNTIME_MB ))
}
need_disk(){ local b=$1 t; t=$(bf "$b" 4); t=$((t+125))     # core + base pkgs
  [ "$EX_VOICE"  = 1 ] && t=$((t+620))
  [ "$EX_FFMPEG" = 1 ] && t=$((t+80))
  [ "$EX_PENTEST" = 1 ] && t=$((t+300))
  [ "$b" != 0 ] && t=$((t+350))                             # ollama runtime
  echo "$t"; }

bar(){ local u=$1 t=$2 w=${3:-16} f i p
  [ "$t" -le 0 ] && t=1; f=$(( u*w/t )); p=$(( u*100/t ))
  [ "$f" -gt "$w" ] && f=$w; [ "$f" -lt 0 ] && f=0
  printf '%s[' "$D"
  for ((i=0;i<w;i++)); do
    if [ $i -lt $f ]; then
      if [ $p -ge 90 ]; then printf '%s█' "$R"; elif [ $p -ge 65 ]; then printf '%s█' "$Y"; else printf '%s█' "$G"; fi
    else printf '%s·' "$D"; fi
  done; printf '%s]%s' "$D" "$X"; }

fitmark(){ # fitmark <need_mb>  -> RAM ke hisaab se nishaan
  local n=$1
  if [ "$n" -le "$FREE" ]; then printf '%s✅ ab bhi fit%s' "$G" "$X"
  elif [ "$n" -le "$RAM" ]; then printf '%s⚠️  fit, par app band honge%s' "$Y" "$X"
  else printf '%s⛔ is phone se bada%s' "$R" "$X"; fi; }

hdr(){ clear 2>/dev/null
  printf '%s╭──────────────────────────────────────────────╮%s\n' "$M" "$X"
  printf '%s│%s  %s🧭 AASMAAN · SETUP%s   %sstep %s/5%s\n' "$M" "$X" "$B" "$X" "$D" "$1" "$X"
  printf '%s╰──────────────────────────────────────────────╯%s\n' "$M" "$X"
  case "$1" in 1|2) :;; *) crumb;; esac; }

crumb(){ local bn; bn=$(bf "$BRAIN" 1)
  printf '  %sabhi tak:%s %s · ctx %sk · RAM ~%s MB%s\n' \
    "$D" "$X$D" "$bn" "$(ctx_k "$CTXI")" "$(need_ram "$BRAIN" "$CTXI")" "$X"; }

foot(){ printf '\n  %s[b] peeche   [q] bahar   [?] detail%s\n' "$D" "$X"; }
askk(){ printf '\n  %s>%s ' "$C" "$X"; read -r REPLY <"$TTY" || REPLY="q"; }
bye(){ printf '\n  %skuch nahi likha. jab mann kare dobara chala lena.%s\n\n' "$D" "$X"; exit 0; }
pause(){ printf '\n  %sEnter…%s ' "$D" "$X"; read -r _ <"$TTY" || true; }

# ═══ STEP 1 · device ════════════════════════════════════════════
s_lang(){
  clear 2>/dev/null; printf '%s  ─── setup wizard ───%s\n' "$D" "$X"
  printf '\n%s  0️⃣  Language / भाषा%s   %s(Enter = English · badal sakte ho baad me: /lang)%s\n\n' "$B" "$X" "$D" "$X"
  printf '  %s1%s English\n  %s2%s Hinglish  %s(Hindi, Roman letters — jaise ye line)%s\n  %s3%s हिन्दी  %s(Devanagari — model ke jawab; installer text Hinglish)%s\n' "$C" "$X" "$C" "$X" "$D" "$X" "$C" "$X" "$D" "$X"
  printf '\n  %s[q] bahar%s' "$D" "$X"; askk
  case "$REPLY" in
    q|Q) bye ;;
    2) LANGC=hinglish;; 3) LANGC=hi;; 1|'') LANGC=en;; *) return 0;;
  esac; export AI_LANG="$LANGC"; STEP=1; return 0; }
s_device(){
  hdr 1
  printf '\n  📱 %s%s%s   %s%s cores%s\n' "$B" "$DEV" "$X" "$D" "$CORES" "$X"
  printf '  🧠 RAM   %s%s MB%s total · %s%s MB%s abhi khaali  ' "$B" "$RAM" "$X" "$B" "$FREE" "$X"
  bar $((RAM-FREE)) "$RAM" 14; printf '\n'
  if [ "$DISK_KNOWN" = yes ]; then
    printf '  💽 Disk  %s%s MB%s free\n' "$B" "$DISK" "$X"
  else
    printf '  💽 Disk  %s? pata nahi chala%s %s(probe fail — install rukega nahi,\n' "$Y" "$X" "$D"
    printf '            bas jagah ka hisaab nahi dikha paunga)%s\n' "$X"
  fi
  printf '\n%s  1️⃣  Device%s   %s(mil gaya — badalna ho tabhi kuch dabao)%s\n\n' "$B" "$X" "$D" "$X"
  printf '  %s✓ %s%s   %s— yahi, ispe pura system chalega%s\n\n' "$G" "$PLAT_DET_NAME" "$X" "$D" "$X"
  printf '  %s[Enter]%s yahi rakho    ya badlo:  %s2%s 🍎 iPhone/iPad %s(client-only)%s   %s3%s 🐧 Linux/Mac\n' "$C" "$X" "$C" "$X" "$D" "$X" "$C" "$X"
  printf '  %s(Windows? ye wizard nahi — PowerShell me:  irm .../install.ps1 | iex)%s\n' "$D" "$X"
  foot; askk
  case "$REPLY" in
    q|Q) bye ;;
    b|B) return 0 ;;
    '?') printf '\n  %s%s detect hua (getprop/uname se). Android=Termux me native.\n  iOS pe ollama chalta hi nahi — wahan phone sirf screen banta hai, compute kisi Android/Linux/Mac pe.\n  Windows apne installer (install.ps1) se, PowerShell me.%s\n' "$D" "$PLAT_DET_NAME" "$X"; pause; return 0 ;;
    1) PLAT=1; STEP=2; return 0 ;;
    2) PLAT=2
       printf '\n  %s🍎 iOS pe ye NATIVE nahi chalta%s — ollama iOS pe hai hi nahi,\n' "$Y" "$X"
       printf '  aur iOS downloaded code chalane nahi deta.\n\n'
       printf '  %siPhone client ban sakta hai (ye already ready hai):%s\n' "$B" "$X"
       printf '    🌐 Safari → http://<fold-ip>:8765   (Tailscale pe)\n'
       printf '    ⌨️  Blink / Termius → SSH\n'
       printf '    🔌 /v1 OpenAI shim → koi bhi iOS AI app isko backend bana le\n'
       pause; PLAT=1; STEP=2; return 0 ;;
    3) PLAT=3; STEP=2; return 0 ;;
    '') PLAT=${PLAT_DET:-1}; STEP=2; return 0 ;;
    *) return 0 ;;
  esac; }

# ═══ STEP 2 · intent ════════════════════════════════════════════
s_intent(){
  hdr 2
  printf '\n%s  2️⃣  Kya chahiye?%s   %s(yahi setup tay karta hai — baad me badal sakte ho)%s\n\n' "$B" "$X" "$D" "$X"
  printf '  %s1%s 🧠 Private AI            %ssab is device pe, offline bhi%s\n' "$C" "$X" "$D" "$X"
  printf '  %s2%s 💬 Quick assistant       %shalka: chat, hisaab, yaad, links%s\n' "$C" "$X" "$D" "$X"
  printf '  %s3%s 🎙  Voice + phone control %sbol ke chalao, alarm, torch, awaaz%s\n' "$C" "$X" "$D" "$X"
  printf '  %s4%s 💻 Coding                %sbada brain, lamba context%s\n' "$C" "$X" "$D" "$X"
  printf '  %s5%s 🎬 Content               %svideo/audio tools + images%s\n' "$C" "$X" "$D" "$X"
  printf '  %s6%s 🔬 Sab kuch              %spoora stack%s\n' "$C" "$X" "$D" "$X"
  foot; askk
  case "$REPLY" in
    q|Q) bye;; b|B) STEP=1; return 0;;
    '?') printf '\n  %sEk sawaal, 70%% setup: brain ka size, context, voice/tools — sab isse. Kuch lock nahi hota,\n  agli screen pe [a]dvanced se khud bhi chun sakte ho, aur baad me setup-menu se.%s\n' "$D" "$X"; pause; return 0;;
    1|2|3|4|5|6|'') INTENT=${REPLY:-1}
       EX_VOICE=0 EX_FFMPEG=0 EX_PANEL=1 EX_PENTEST=0
       case "$INTENT" in
         1) BRAIN=$(fit_brain); CTXI=3;;
         2) BRAIN=$(small_brain); CTXI=2;;
         3) BRAIN=$(fit_brain); CTXI=3; EX_VOICE=1;;
         4) BRAIN=$(fit_brain); CTXI=4;;
         5) BRAIN=$(fit_brain); CTXI=3; EX_FFMPEG=1;;
         6) BRAIN=$(fit_brain); CTXI=4; EX_VOICE=1; EX_FFMPEG=1;;
       esac
       ADV=0; STEP=3; return 0;;
    *) return 0;;
  esac; }

# ═══ STEP 3 · local brain ═══════════════════════════════════════
s_recommend(){
  hdr 3
  local need dn bt nm; need=$(need_ram "$BRAIN" "$CTXI"); dn=$(need_disk "$BRAIN"); bt=$(batt_of "$BRAIN"); nm=$(bf "$BRAIN" 1)
  printf '\n%s  3️⃣  Recommended setup%s   %s(tere %s MB RAM ke hisaab se)%s\n\n' "$B" "$X" "$D" "$RAM" "$X"
  if [ "$BRAIN" = 0 ]; then
    printf '  %s🧠 Local brain:%s koi nahi — %scloud/keyless rungs chalenge; RAM 4 GB se kam hai%s\n' "$B" "$X" "$Y" "$X"
  else
    printf '  %s🧠 Local brain:%s %s   %s~%s MB download · offline chalega%s\n' "$B" "$X" "$nm" "$D" "$(bf "$BRAIN" 4)" "$X"
    printf '  %s🪟 Yaad (context):%s %sk tokens   %s(≈ %s A4 page ki baat)%s\n' "$B" "$X" "$(ctx_k "$CTXI")" "$D" "$(( $(ctx_k "$CTXI") * 3 ))" "$X"
  fi
  printf '  %s🔋 Battery:%s %s   %s(local AI bolte/soch-te waqt hi battery leta hai)%s\n' "$B" "$X" "$bt" "$D" "$X"
  printf '\n  %sStorage budget%s   app+base 125 MB' "$B" "$X"
  [ "$BRAIN" != 0 ] && printf ' · model %s MB' "$(bf "$BRAIN" 4)"
  [ "$EX_VOICE" = 1 ] && printf ' · voice 620 MB'; [ "$EX_FFMPEG" = 1 ] && printf ' · video tools 80 MB'
  printf '   = %s~%s MB%s' "$B" "$dn" "$X"
  if [ "$DISK_KNOWN" = yes ]; then [ "$dn" -le "$DISK" ] && printf '  %s✅ %s MB free%s\n' "$G" "$DISK" "$X" || printf '  %s⛔ sirf %s MB free%s\n' "$R" "$DISK" "$X"; else printf '\n'; fi
  printf '  %sRAM%s  ~%s MB of %s MB  ' "$B" "$X" "$need" "$RAM"; bar "$need" "$RAM" 14; printf '  %s\n' "$(fitmark "$need")"
  printf '\n  %s[Enter]%s yahi rakho    %s[a]%s advanced — model/context khud chuno    %s[b]%s peeche   %s[q]%s bahar\n' "$C" "$X" "$C" "$X" "$D" "$X" "$D" "$X"
  askk
  case "$REPLY" in
    q|Q) bye;; b|B) STEP=2; return 0;;
    a|A) ADV=1; return 0;;
    '?') printf '\n  %sModel ke naam (qwen3:4b waghera) advanced me hain — yahan sirf size aur asar. Sab baad me badal sakte ho: setup-menu, ya /model.%s\n' "$D" "$X"; pause; return 0;;
    1|2|3|4) BRAIN=$((REPLY-1)); ADV=2; STEP=4; [ "$BRAIN" = 0 ] && STEP=5; return 0;;
    '') STEP=5; return 0;;
    *) return 0;;
  esac; }
s_brain(){ if [ "$ADV" != 0 ]; then s_brain_adv; else s_recommend; fi; }
s_brain_adv(){
  hdr 3
  printf '\n%s  3️⃣  Advanced — local brain khud chuno%s\n' "$B" "$X"
  printf '  %sRAM ka andaaza abhi ke ctx (%sk) pe hai. Cloud brains har haal me chalte hain.%s\n\n' "$D" "$(ctx_k "$CTXI")" "$X"
  local i n need dsk
  for i in 0 1 2 3; do
    n=$(bf "$i" 1); need=$(need_ram "$i" "$CTXI"); dsk=$(bf "$i" 4)
    printf '  %s%s%s %-12s ' "$C" "$((i+1))" "$X" "$n"
    bar "$need" "$RAM" 14
    printf ' %s%5s MB%s RAM\n' "$B" "$need" "$X"
    printf '       %s💽 %s MB disk · 🔋 %s · %s%s\n' "$D" "$dsk" \
      "$(case $i in 0) echo 'na ke barabar';; 1) echo 'halka';; 2) echo 'dhyan rakhna';; *) echo 'bhaari';; esac)" \
      "$(fitmark "$need")" "$X"
  done
  printf '\n  %s💡 tere %s MB RAM pe%s: ' "$D" "$RAM" "$X"
  if   [ "$RAM" -ge 12000 ]; then printf '%sqwen3:8b tak jaa sakta hai%s\n' "$G" "$X"
  elif [ "$RAM" -ge 7000  ]; then printf '%sqwen3:4b sweet spot hai%s\n' "$G" "$X"
  elif [ "$RAM" -ge 4000  ]; then printf '%sqwen3:1.7b theek rahega%s\n' "$G" "$X"
  else                            printf '%scloud-only best hai%s\n' "$Y" "$X"; fi
  foot; askk
  case "$REPLY" in
    q|Q) bye;; b|B) [ "$ADV" = 2 ] && STEP=2; ADV=0; return 0;;
    '?') printf '\n  %sqwen3:1.7b — tez, halka, seedhe kaam.\n  qwen3:4b   — soch behtar, phone garam hoga lambi chat me.\n  qwen3:8b   — sabse acha, par 8GB+ khaali RAM chahiye.\n  koi nahi   — sab kuch cloud se; offline pe keyless builtins chalte hain.%s\n' "$D" "$X"; pause; return 0;;
    1|2|3|4) BRAIN=$((REPLY-1)); STEP=4; [ "$BRAIN" = 0 ] && STEP=5; return 0;;
    '') STEP=4; [ "$BRAIN" = 0 ] && STEP=5; return 0;;
    *) return 0;;
  esac; }

# ═══ STEP 4 · context ═══════════════════════════════════════════
s_ctx(){
  hdr 4
  printf '\n%s  4️⃣  Context window — kitna yaad rakhe?%s\n' "$B" "$X"
  printf '  %sBada ctx = lambi baat yaad, par har token RAM leta hai.%s\n\n' "$D" "$X"
  local i k need
  for i in 1 2 3 4 5; do
    k=$(ctx_k "$i"); need=$(need_ram "$BRAIN" "$i")
    printf '  %s%s%s %-5s ' "$C" "$i" "$X" "${k}k"
    bar "$need" "$RAM" 14
    printf ' %s%5s MB%s  %s\n' "$B" "$need" "$X" "$(fitmark "$need")"
  done
  printf '\n  %sroughly: 8k ≈ 25 A4 page ki baat · 32k ≈ ek chhoti kitaab%s\n' "$D" "$X"
  foot; askk
  case "$REPLY" in
    q|Q) bye;; b|B) STEP=3; return 0;;
    '?') printf '\n  %sctx bharne pe purani baatein girti hain (bhoolta hai).\n  RAM ka jo hissa ctx leta hai use KV-cache kehte hain — wo\n  model ke size ke saath badhta hai, isliye 8b pe 32k mehnga hai.%s\n' "$D" "$X"; pause; return 0;;
    1|2|3|4|5) CTXI=$REPLY; STEP=5; return 0;;
    '') STEP=5; return 0;;
    *) return 0;;
  esac; }

# ═══ STEP 5 · extras (toggle) ═══════════════════════════════════
s_extras(){
  while :; do
    hdr 5
    printf '\n%s  5️⃣  Aur kya chahiye?%s  %s(number = on/off · Enter = aage · sab baad me setup-menu se bhi)%s\n\n' "$B" "$X" "$D" "$X"
    mk(){ [ "$1" = 1 ] && printf '%s[✓]%s' "$G" "$X" || printf '%s[ ]%s' "$D" "$X"; }
    printf '  %s1%s %s 🎤 Voice — bol ke baat, jawab awaaz me   %s+620 MB · 🔋 sirf bolte waqt%s\n' "$C" "$X" "$(mk $EX_VOICE)"  "$D" "$X"
    printf '  %s2%s %s 🎬 Video/audio tools — cut, subs, thumb  %s+80 MB · 🔋 sirf render pe%s\n' "$C" "$X" "$(mk $EX_FFMPEG)" "$D" "$X"
    printf '  %s3%s %s 🌐 Web panel — browser me whiteboard    %s+0 MB%s\n' "$C" "$X" "$(mk $EX_PANEL)"  "$D" "$X"
    if [ "$MORE" = 1 ]; then
      printf '  %s4%s %s 👁  Screen reading — jo screen pe hai use padhe %s(Shizuku: ek Android setup step, bina root) · +0 MB%s\n' "$C" "$X" "$(mk $EX_SCREEN)" "$D" "$X"
      printf '  %s5%s %s 🛡  Pentest kit — apne device/lab ke liye   %s+300 MB · advanced%s\n' "$C" "$X" "$(mk $EX_PENTEST)" "$D" "$X"
    else printf '  %s[m]%s aur (screen reading, pentest kit)\n' "$D" "$X"; fi
    local dn; dn=$(need_disk "$BRAIN")
    printf '\n  %skul disk:%s %s%s MB%s' "$D" "$X" "$B" "$dn" "$X"
    if [ "$DISK_KNOWN" = yes ]; then
      if [ "$dn" -le "$DISK" ]; then printf '  %s✅ %s MB free me fit%s\n' "$G" "$DISK" "$X"
      else printf '  %s⛔ sirf %s MB free hai%s\n' "$R" "$DISK" "$X"; fi
    else printf '  %s(free space pata nahi — hisaab nahi laga sakta)%s\n' "$Y" "$X"; fi
    foot; askk
    case "$REPLY" in
      q|Q) bye;;  b|B) STEP=3; [ "$ADV" = 1 ] && [ "$BRAIN" != 0 ] && STEP=4; return 0;;
      '?') printf '\n  %sScreen reading / Web panel disk nahi lete — wo andar hain, ye sirf unka setup step on karta hai.\n  Pentest kit sirf apne device ya lab pe.%s\n' "$D" "$X"; pause;;
      m|M) MORE=$((1-MORE));;
      1) EX_VOICE=$((1-EX_VOICE));;   2) EX_FFMPEG=$((1-EX_FFMPEG));;  3) EX_PANEL=$((1-EX_PANEL));;
      4) [ "$MORE" = 1 ] && EX_SCREEN=$((1-EX_SCREEN));;  5) [ "$MORE" = 1 ] && EX_PENTEST=$((1-EX_PENTEST));;
      '') STEP=6; return 0;;
      *) :;;
    esac
  done; }

# ═══ fit-check — dhakela nahi jaata, raaste diye jaate hain ═════
s_fitcheck(){
  local need dn; need=$(need_ram "$BRAIN" "$CTXI"); dn=$(need_disk "$BRAIN")
  local ram_bad=0 disk_bad=0
  [ "$need" -gt "$FREE" ] && [ "$need" -gt 200 ] && ram_bad=1
  [ "$DISK_KNOWN" = yes ] && [ "$dn" -gt "$DISK" ] && disk_bad=1
  [ "$ram_bad" = 0 ] && [ "$disk_bad" = 0 ] && { STEP=7; return 0; }

  hdr "5"
  printf '\n  %s⚠️  Jo chuna hai wo tight hai%s\n\n' "$Y" "$X"
  [ "$ram_bad" = 1 ]  && printf '  🧠 RAM  : chahiye %s%s MB%s · abhi khaali %s%s MB%s  %s(total %s)%s\n' "$B" "$need" "$X" "$B" "$FREE" "$X" "$D" "$RAM" "$X"
  [ "$disk_bad" = 1 ] && printf '  💽 Disk : chahiye %s%s MB%s · free %s%s MB%s\n' "$B" "$dn" "$X" "$B" "$DISK" "$X"
  printf '\n  %sTera phone, teri marzi. Kya karein?%s\n\n' "$D" "$X"
  printf '  %s1%s 🧠 chhota brain chunu        %s(step 3 pe wapas)%s\n' "$C" "$X" "$D" "$X"
  printf '  %s2%s 🪟 chhota context chunu      %s(step 4 pe wapas)%s\n' "$C" "$X" "$D" "$X"
  printf '  %s3%s 🎛  extras kam karu           %s(step 5 pe wapas)%s\n' "$C" "$X" "$D" "$X"
  printf '  %s4%s ▶️  phir bhi chalao           %s(chalega, phone doosri apps band karega)%s\n' "$C" "$X" "$D" "$X"
  printf '  %s5%s 🤖 tu hi sabse bada fit chun de   %s(Enter = yahi)%s\n' "$C" "$X" "$D" "$X"
  foot; askk
  case "$REPLY" in
    q|Q) bye;;  b|B|3) STEP=5; return 0;;
    1) STEP=3; return 0;;  2) STEP=4; return 0;;
    4) STEP=7; return 0;;
    5|'') local b c; for b in 3 2 1 0; do for c in 5 4 3 2 1; do
         if [ "$(need_ram "$b" "$c")" -le "$FREE" ]; then BRAIN=$b; CTXI=$c
            printf '\n  %s→ chuna: %s @ %sk (%s MB)%s\n' "$G" "$(bf "$b" 1)" "$(ctx_k "$c")" "$(need_ram "$b" "$c")" "$X"
            pause; STEP=6; return 0; fi
       done; done
       BRAIN=0; CTXI=3; printf '\n  %s→ cloud-only pe rakha (kuch bhi local fit nahi hua)%s\n' "$Y" "$X"; pause; STEP=6; return 0;;
    *) return 0;;
  esac; }

# ═══ STEP 6 · review ════════════════════════════════════════════
s_review(){
  local need dn bt; need=$(need_ram "$BRAIN" "$CTXI"); dn=$(need_disk "$BRAIN")
  case "$BRAIN" in 0) bt="🔋 ○○○○  na ke barabar";; 1) bt="🔋🔋 ○○○  halka";;
                   2) bt="🔋🔋🔋 ○○  dhyan rakhna";; *) bt="🔋🔋🔋🔋 ○ bhaari";; esac
  clear 2>/dev/null
  printf '%s╭──────────────────────────────────────────────╮%s\n' "$M" "$X"
  printf '%s│%s  %s✅ Tera setup — ek baar dekh le%s\n' "$M" "$X" "$B" "$X"
  printf '%s╰──────────────────────────────────────────────╯%s\n' "$M" "$X"
  printf '\n  %s1%s  Device      %s%s%s\n' "$C" "$X" "$B" "$(case $PLAT in 3) echo "Linux";; *) echo "Android · Termux";; esac)" "$X"
  printf '  %s2%s  Kaam         %s%s%s\n' "$C" "$X" "$B" "$(case $INTENT in 1) echo "private AI";; 2) echo "quick assistant";; 3) echo "voice + phone control";; 4) echo "coding";; 5) echo "content";; *) echo "sab kuch";; esac)" "$X"
  printf '  %s3%s  Local brain  %s%s%s\n' "$C" "$X" "$B" "$(bf "$BRAIN" 1)" "$X"
  if [ "$BRAIN" = 0 ]; then printf '  %s4%s  Context      %s—  %s(cloud brains apna ctx khud laate hain)%s\n' "$C" "$X" "$D" "$D" "$X"
  else printf '  %s4%s  Context      %s%sk tokens%s\n' "$C" "$X" "$B" "$(ctx_k "$CTXI")" "$X"; fi
  printf '  %s5%s  Extras       ' "$C" "$X"
  [ "$EX_VOICE" = 1 ] && printf '🎤 '; [ "$EX_SCREEN" = 1 ] && printf '👁 '
  [ "$EX_FFMPEG" = 1 ] && printf '🎬 '; [ "$EX_PANEL" = 1 ] && printf '🌐 '
  [ "$EX_PENTEST" = 1 ] && printf '🛡 '
  [ $((EX_VOICE+EX_SCREEN+EX_FFMPEG+EX_PANEL+EX_PENTEST)) = 0 ] && printf '%skuch nahi%s' "$D" "$X"
  printf '\n\n      RAM        ~%s%s MB%s  ' "$B" "$need" "$X"; bar "$need" "$RAM" 16
  printf '  %s\n' "$(fitmark "$need")"
  if [ "$DISK_KNOWN" = yes ]; then printf '      Disk       ~%s%s MB%s of %s MB free\n' "$B" "$dn" "$X" "$DISK"
  else printf '      Disk       ~%s%s MB%s %s(free space pata nahi chala)%s\n' "$B" "$dn" "$X" "$Y" "$X"; fi
  printf '      Battery    %s\n' "$bt"
  printf '\n  %sbadalna ho to uska number dabao (1-5) · Enter = likh do · q = bahar%s\n' "$D" "$X"
  askk
  case "$REPLY" in
    q|Q) bye;;
    1) STEP=1;; 2) STEP=2;; 3) STEP=3;;
    4) [ "$BRAIN" = 0 ] && STEP=3 || STEP=4;;
    5) STEP=5;;
    b|B) STEP=5;;
    '') STEP=7;;
    *) :;;
  esac; return 0; }

# ═══ STEP 7 · write ═════════════════════════════════════════════
s_write(){
  local need dn; need=$(need_ram "$BRAIN" "$CTXI"); dn=$(need_disk "$BRAIN")
  local tn; case "$BRAIN" in 0) tn=LITE;; 1) tn=BALANCED;; 2) tn=FULL;; *) tn=MAX;; esac
  local ctxv=0; [ "$BRAIN" != 0 ] && ctxv=$(( $(ctx_k "$CTXI") * 1024 ))
  cat > "$PROFILE" <<EOF
# aasmaan setup profile — $(date -u +%FT%TZ) · wizard v2
# Installer ise padh ke chalta hai. Haath se badal sakte ho, ya:  bash setup-wizard.sh
AI_LANG=$LANGC
AI_USE=$(case $INTENT in 1) echo private;; 4) echo code;; 5) echo content;; *) echo chat;; esac)
AI_TIER=$tn
AI_LOCAL_MODEL=$(bf "$BRAIN" 2)
AI_LOCAL_CTX=$ctxv
AI_WANT_VOICE=$EX_VOICE
AI_WANT_SCREEN=$EX_SCREEN
AI_WANT_FFMPEG=$EX_FFMPEG
AI_WANT_PANEL=$EX_PANEL
AI_WANT_PENTEST=$EX_PENTEST
AI_DEVICE_RAM_MB=$RAM
AI_PLANNED_RAM_MB=$need
AI_PLANNED_DISK_MB=$dn
EOF
  chmod 600 "$PROFILE"
  printf '\n  %s✔ likh diya:%s %s\n' "$G" "$X" "$PROFILE"
  printf '  %stier=%s · brain=%s · ctx=%s%s\n' "$D" "$tn" "$(bf "$BRAIN" 1)" "$ctxv" "$X"
  local done_n=2 tot=6; [ "$BRAIN" != 0 ] && done_n=$((done_n+1)); [ "$EX_VOICE" = 1 ] && done_n=$((done_n+1))
  local pct=$(( done_n*100/tot )) f=$(( done_n*20/tot )) i
  printf '\n  %sSetup%s  ' "$B" "$X"; for i in $(seq 1 20); do [ "$i" -le "$f" ] && printf '█' || printf '░'; done; printf '  %s%%\n' "$pct"
  printf '  %s✓%s core (offline tools, memory, hands)   %s✓%s language\n' "$G" "$X" "$G" "$X"
  [ "$BRAIN" != 0 ] && printf '  %s✓%s local brain (%s)\n' "$G" "$X" "$(bf "$BRAIN" 1)" || printf '  %s○%s local brain — baad me: setup-menu → brain\n' "$D" "$X"
  [ "$EX_VOICE" = 1 ] && printf '  %s✓%s voice\n' "$G" "$X" || printf '  %s○%s voice — baad me: setup-menu → 2\n' "$D" "$X"
  printf '  %s○%s phone controls (Termux:API / Shizuku) — jab chahiye tab, setup-menu\n  %s○%s computer pairing — ai pair\n' "$D" "$X" "$D" "$X"
  printf '  %s○%s home-screen shortcut — installer ki aakhri stage poochhegi (Termux:Widget se ek tap)\n' "$D" "$X"
  printf '\n  %sAb installer khud chalega%s (har stage pe poochhega). Baad me kabhi bhi:  %sai doctor%s  (sab check)  ·  %sai tour%s  (60 sec me dikhata hai)\n' "$B" "$X" "$C" "$X" "$C" "$X"
  printf '  %sye choices badalni ho:%s  bash %s/setup-wizard.sh   %s(ya setup-menu)%s\n\n' "$D" "$X" "$HERE" "$D" "$X"; }

# ═══ main loop ══════════════════════════════════════════════════
STEP=0
while :; do
  case $STEP in
    0) s_lang ;;
    1) s_device ;;  2) s_intent ;;  3) s_brain ;;
    4) s_ctx ;;     5) s_extras ;;
    6) s_fitcheck; [ "$STEP" = 7 ] && { STEP=6; s_review; } ;;
    7) s_write; break ;;
    *) break ;;
  esac
done
