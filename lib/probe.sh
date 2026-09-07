# aasmaan/lib/probe.sh — device probes. source this; sets nothing until called.
# Har probe ke kai tareeqe hain, aur PATA-NAHI ko kabhi 0 nahi banate.
# "" = pata nahi chala (alag baat), "0" = sach me zero.

# Override hooks — testing ke liye, aur agar kisi device pe probe jhoot bole to.
#   AKASHA_DISK_MB=  AKASHA_RAM_MB=  AKASHA_FREE_MB=   ("none" = pata-nahi simulate)
_ovr(){ case "${1:-}" in "") return 1;; none) printf ''; return 0;; *) printf '%s' "$1"; return 0;; esac; }

probe_disk_mb(){ # echo free MB at $1 (default $HOME), or "" if unknowable
  local d="${1:-$HOME}" v=""
  _ovr "${AKASHA_DISK_MB:-}" && return 0
  # 1) python — sabse bharosemand, aur installer python install karta hi hai
  if command -v python3 >/dev/null 2>&1; then
    v=$(python3 -c 'import sys,shutil;print(shutil.disk_usage(sys.argv[1]).free//1048576)' "$d" 2>/dev/null)
    case "$v" in ''|*[!0-9]*) v="" ;; *) printf '%s' "$v"; return 0 ;; esac
  fi
  # 2) df -Pm, NF-2 se (lamba device-name column shift kar deta hai)
  v=$(df -Pm "$d" 2>/dev/null | awk 'NR>1 && NF>=4 {print $(NF-2); exit}')
  case "$v" in ''|*[!0-9]*) v="" ;; *) printf '%s' "$v"; return 0 ;; esac
  # 3) df -Pk (kuch df -m nahi maante)
  v=$(df -Pk "$d" 2>/dev/null | awk 'NR>1 && NF>=4 {print int($(NF-2)/1024); exit}')
  case "$v" in ''|*[!0-9]*) v="" ;; *) printf '%s' "$v"; return 0 ;; esac
  # 4) stat -f (GNU aur busybox dono me alag flags — dono try)
  v=$(stat -f -c '%a %S' "$d" 2>/dev/null | awk 'NF==2{print int($1*$2/1048576)}')
  case "$v" in ''|*[!0-9]*) v="" ;; *) printf '%s' "$v"; return 0 ;; esac
  printf ''            # sab fail — pata nahi
}

probe_ram_mb(){ _ovr "${AKASHA_RAM_MB:-}" && return 0
  awk '/MemTotal/{print int($2/1024); found=1} END{if(!found) print ""}' /proc/meminfo 2>/dev/null; }
probe_free_mb(){ _ovr "${AKASHA_FREE_MB:-}" && return 0
  awk '/MemAvailable/{print int($2/1024); found=1} END{if(!found) print ""}' /proc/meminfo 2>/dev/null; }
probe_cores(){ nproc 2>/dev/null || echo 1; }
probe_device(){ getprop ro.product.model 2>/dev/null || uname -m 2>/dev/null || echo "?"; }

# num_or <value> <fallback>  — "" ya non-number ko fallback bana deta hai
num_or(){ case "${1:-}" in ''|*[!0-9]*) printf '%s' "$2";; *) printf '%s' "$1";; esac; }
