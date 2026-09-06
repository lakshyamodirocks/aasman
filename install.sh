#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
#  AASMAAN · PC edition · Linux / macOS / WSL2 bootstrap
#
#     curl -fsSL https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.sh | bash
#
#  Ye sirf bundle download karta hai (~/.local/share/aasmaan/app) aur pc-setup.sh chalata hai —
#  jo har stage pe poochhta hai, kabhi sudo/pip/rc-file nahi chhedta, aur --uninstall rakhta hai.
#  git chahiye nahi: tarball se. Python 3.8+ chahiye (ye script Python install NAHI karta).
# ═══════════════════════════════════════════════════════════════
set -u
REPO="${AI_REPO:-lakshyamodirocks/aasman}"; BRANCH="${AI_BRANCH:-main}"
DEST="${AI_APP_DIR:-$HOME/.local/share/aasmaan/app}"
c(){ printf '\033[%sm%s\033[0m\n' "$1" "$2"; }
c 36 "  AASMAAN · PC edition — bootstrap ($REPO@$BRANCH)"
command -v python3 >/dev/null 2>&1 || { c 31 "  python3 nahi mila. apt/dnf/brew se 'python3' install karo, phir dobara. (Ye script khud install nahi karta — tera package manager tera hai.)"; exit 1; }
command -v curl >/dev/null 2>&1 || { c 31 "  curl chahiye."; exit 1; }
command -v tar  >/dev/null 2>&1 || { c 31 "  tar chahiye."; exit 1; }
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
RAW="https://raw.githubusercontent.com/$REPO/$BRANCH"
SRC=""
# 1) tarball  2) git clone  3) raw per-file (FILES.txt) — some networks/proxies block github.com archives but not raw
URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"
echo "  download: $URL"
if curl -fsSL "$URL" -o "$TMP/src.tgz" 2>/dev/null && mkdir -p "$TMP/x" && tar -xzf "$TMP/src.tgz" -C "$TMP/x" 2>/dev/null; then
  SRC="$(find "$TMP/x" -mindepth 1 -maxdepth 1 -type d | head -1)"
elif command -v git >/dev/null 2>&1 && git clone -q --depth 1 -b "$BRANCH" "https://github.com/$REPO" "$TMP/g" 2>/dev/null; then
  echo "  (tarball blocked — git clone se liya)"; SRC="$TMP/g"
elif curl -fsSL "$RAW/FILES.txt" -o "$TMP/FILES.txt" 2>/dev/null; then
  echo "  (tarball + git blocked — raw files ek-ek karke; $(wc -l < "$TMP/FILES.txt") files)"
  mkdir -p "$TMP/r"; n=0
  while IFS= read -r f; do [ -n "$f" ] || continue; mkdir -p "$TMP/r/$(dirname "$f")"
    curl -fsSL "$RAW/$f" -o "$TMP/r/$f" || { c 31 "  fail: $f"; exit 1; }; n=$((n+1)); done < "$TMP/FILES.txt"
  cp "$TMP/FILES.txt" "$TMP/r/"; SRC="$TMP/r"; echo "  $n files"
else c 31 "  download fail — repo public hai? naam sahi hai? ($REPO) · net/proxy github.com ko rok raha ho to bhi yahi dikhta hai"; exit 1; fi
[ -f "$SRC/pc-setup.sh" ] || { c 31 "  bundle me pc-setup.sh nahi — ye repo Aasmaan ka PC bundle nahi lagta."; exit 1; }
mkdir -p "$DEST" && rm -rf "$DEST".new && cp -R "$SRC" "$DEST.new" && rm -rf "$DEST" && mv "$DEST.new" "$DEST"
c 32 "  bundle: $DEST  ($(cat "$DEST/VERSION" 2>/dev/null || echo 'no VERSION'))"
echo "  ab guided setup — har stage Enter se aage, q se ruk:"; echo
# stdin is the pipe when run via curl|bash — pc-setup.sh reads its prompts from /dev/tty, so this still works interactively.
exec bash "$DEST/pc-setup.sh" "$@"
