#!/usr/bin/env bash
# Disk probe kis tareeqe se sach bolta hai is device pe — ye batata hai.
# Kuch badalta nahi. Output mujhe bhej dena.
set -u
D="${1:-$HOME}"
echo "== disk-doctor =="
echo "path      : $D"
echo "exists    : $([ -d "$D" ] && echo yes || echo NO)"
echo "TERMUX_VER: ${TERMUX_VERSION:-<not set>}"
echo
echo "-- 1. python3 shutil --"
command -v python3 >/dev/null 2>&1 \
  && python3 -c 'import sys,shutil;u=shutil.disk_usage(sys.argv[1]);print("free MB:",u.free//1048576,"| total MB:",u.total//1048576)' "$D" 2>&1 \
  || echo "python3 nahi hai"
echo
echo "-- 2. df -Pm (raw) --"; df -Pm "$D" 2>&1 | cat -A | sed -n '1,4p'
echo "   \$4      = $(df -Pm "$D" 2>/dev/null | awk 'NR==2{print $4}')"
echo "   \$(NF-2) = $(df -Pm "$D" 2>/dev/null | awk 'NR>1&&NF>=4{print $(NF-2);exit}')"
echo
echo "-- 3. df -Pk --"; df -Pk "$D" 2>/dev/null | awk 'NR>1&&NF>=4{print "   free MB:",int($(NF-2)/1024);exit}'
echo
echo "-- 4. stat -f --"; stat -f -c '%a %S' "$D" 2>&1 | awk 'NF==2{print "   free MB:",int($1*$2/1048576)}'
echo
echo "-- 5. which df --"; command -v df; df --version 2>&1 | head -1
echo
. "$(dirname "$0")/lib/probe.sh" 2>/dev/null && echo "== probe_disk_mb() bola: '$(probe_disk_mb "$D")' MB =="
