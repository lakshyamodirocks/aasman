#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  AASMAAN · ONE bootstrap for Android (Termux) · Linux · macOS · WSL2      (Windows: install.ps1)
#
#     curl -fsSL https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.sh | bash
#
#  Sirf bundle download karta hai (~/.local/share/aasmaan/app), phir device dekh ke sahi installer:
#    · Termux/Android  → setup-wizard.sh (RAM/battery/model tu chunta hai) → fold-all-setup.sh (7 stages,
#                        voice · floater · Shizuku · local brain · experts) → setup-menu (keys, guided)
#    · Linux/macOS/WSL → pc-setup.sh (7 stages, manifest uninstall, kabhi sudo/pip/rc-file nahi)
#  Dono har stage pe poochhte hain. git zaroori nahi (tarball → git → raw fallback). Python 3.8+ chahiye.
#  Termux: pehle  apt update && apt -y -o Dpkg::Options::=--force-confnew full-upgrade && apt -y install curl python
#  (F-Droid wala Termux; fresh curl upgrade se pehle toota hota hai, aur `pkg` khud curl se mirror chunta hai — isliye apt).
# ═══════════════════════════════════════════════════════════════
set -u
BRANCH="${AI_BRANCH:-main}"
REPO="${AASMAAN_REPO:-lakshyamodirocks/aasman}"   # AASMAAN_REPO: build-dist substitutes the literal lakshyamodirocks/aasman only — nothing else on this line
DEST="${AI_APP_DIR:-$HOME/.local/share/aasmaan/app}"
c(){ printf '\033[%sm%s\033[0m\n' "$1" "$2"; }
c 36 "  AASMAAN · bootstrap — Android/Termux · Linux · macOS · WSL2 ($REPO@$BRANCH)"
TERMUX=0; [ -d /data/data/com.termux/files ] && TERMUX=1
if [ $TERMUX = 1 ]; then
  c 36 "  device: Android / Termux"
  command -v python3 >/dev/null 2>&1 || { c 31 "  python nahi mila. Chalao:  apt update && apt -y full-upgrade && apt -y install python curl   phir dobara."; exit 1; }
else
  command -v python3 >/dev/null 2>&1 || { c 31 "  python3 nahi mila. apt/dnf/brew se 'python3' install karo, phir dobara. (Ye script khud install nahi karta — tera package manager tera hai.)"; exit 1; }
fi
# curl OR wget (minimal Debian/Ubuntu ships neither by default); with only git, the clone route still works
fetch(){ if command -v curl >/dev/null 2>&1; then curl -fsSL "$1" -o "$2"; elif command -v wget >/dev/null 2>&1; then wget -qO "$2" "$1"; else return 127; fi; }
command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1 || command -v git >/dev/null 2>&1 || { c 31 "  curl ya wget (ya git) chahiye:  apt install curl   /  dnf install curl   /  brew install curl"; exit 1; }
command -v tar  >/dev/null 2>&1 || { c 31 "  tar chahiye."; exit 1; }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
RAW="https://raw.githubusercontent.com/$REPO/$BRANCH"
SRC=""
# 1) tarball  2) git clone  3) raw per-file (FILES.txt) — some networks/proxies block github.com archives but not raw
URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"
echo "  download: $URL"
if fetch "$URL" "$TMP/src.tgz" 2>/dev/null && mkdir -p "$TMP/x" && tar -xzf "$TMP/src.tgz" -C "$TMP/x" 2>/dev/null; then
  SRC="$(find "$TMP/x" -mindepth 1 -maxdepth 1 -type d | head -1)"
elif command -v git >/dev/null 2>&1 && git clone -q --depth 1 -b "$BRANCH" "https://github.com/$REPO" "$TMP/g" 2>/dev/null; then
  echo "  (tarball blocked — git clone se liya)"; SRC="$TMP/g"
elif fetch "$RAW/FILES.txt" "$TMP/FILES.txt" 2>/dev/null; then
  echo "  (tarball + git blocked — raw files ek-ek karke; $(wc -l < "$TMP/FILES.txt") files)"
  mkdir -p "$TMP/r"; n=0
  while IFS= read -r f; do [ -n "$f" ] || continue; mkdir -p "$TMP/r/$(dirname "$f")"
    fetch "$RAW/$f" "$TMP/r/$f" || { c 31 "  fail: $f"; exit 1; }; n=$((n+1)); done < "$TMP/FILES.txt"
  cp "$TMP/FILES.txt" "$TMP/r/"; SRC="$TMP/r"; echo "  $n files"
else c 31 "  download fail — repo public hai? naam sahi hai? ($REPO) · net/proxy github.com ko rok raha ho to bhi yahi dikhta hai"; exit 1; fi
[ -f "$SRC/pc-setup.sh" ] && [ -f "$SRC/fold-all-setup.sh" ] || { c 31 "  bundle adhoora — ye repo Aasmaan ka bundle nahi lagta."; exit 1; }
mkdir -p "$DEST" && rm -rf "$DEST".new && cp -R "$SRC" "$DEST.new" && rm -rf "$DEST" && mv "$DEST.new" "$DEST"
c 32 "  bundle: $DEST  ($(cat "$DEST/VERSION" 2>/dev/null || echo 'no VERSION'))"
# stdin is the pipe when run via curl|bash — the installers read their prompts from /dev/tty, so this still works interactively.
if [ $TERMUX = 1 ]; then
  echo "  ab: (1) setup wizard — RAM/battery/model tu chunta hai  (2) phone installer, 7 stages  (3) setup-menu → G (keys, voice, tools)"; echo
  if [ ! -f "$HOME/.ai-setup-profile" ] && [ -f "$DEST/setup-wizard.sh" ]; then bash "$DEST/setup-wizard.sh" || c 33 "  (wizard skip — installer RAM-guess se chalega)"; fi
  exec bash "$DEST/fold-all-setup.sh" "$@"
fi
echo "  ab guided setup — har stage Enter se aage, q se ruk:"; echo
exec bash "$DEST/pc-setup.sh" "$@"
