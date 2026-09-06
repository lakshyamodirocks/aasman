# ═══════════════════════════════════════════════════════════════
#  AASMAAN · PC edition · Windows installer (native, no WSL, no admin)
#
#  Ek command (PowerShell, normal user, koi admin nahi):
#     irm https://raw.githubusercontent.com/lakshyamodirocks/aasman/main/install.ps1 | iex
#
#  Usool — TERA PC TERA HAI:
#    · sirf tere user folder me likhta hai:  %LOCALAPPDATA%\Aasmaan  aur  %USERPROFILE%\.ai-*
#    · har likhi file manifest me;  $env:AI_UNINSTALL=1; irm ... | iex   se EXACTLY wahi hatta hai
#    · Python / Ollama khud install NAHI karta — official winget command dikhata hai, poochhta hai
#    · PATH me apna ek folder tabhi jodta hai jab tu Enter dabaye (uninstall wapas hata deta hai)
#    · hardware sirf ADAPT karne ke liye dekhta hai: kam RAM = chhota model ya sirf cloud, install phir bhi hota hai
#
#  Status: Windows pe abhi tak sirf padha gaya hai, chala nahi (dev box Linux hai) — pehla run = pehla test.
#  PowerShell 5.1 (Windows 10/11 default) compatible rakha hai: koi ?? / ternary / pwsh-7 syntax nahi.
# ═══════════════════════════════════════════════════════════════
$ErrorActionPreference = "Stop"
$Repo   = if ($env:AI_lakshyamodirocks/aasman) { $env:AI_lakshyamodirocks/aasman } else { "lakshyamodirocks/aasman" }   # owner/name — build-dist.sh isse bharta hai (AI_REPO = a PATH inside ai.py, alag cheez)
$Branch = if ($env:AI_BRANCH) { $env:AI_BRANCH } else { "main" }
$Auto   = ($env:AI_YES -eq "1")
$Base   = Join-Path $env:LOCALAPPDATA "Aasmaan"
$App    = Join-Path $Base "app"
$BinDir = Join-Path $Base "bin"
$Manifest = Join-Path $Base "manifest.txt"
$Home_  = $env:USERPROFILE
$Total  = 7; $script:N = 0

function Hr { "  " + ("─" * 44) }
function Stage([string]$title, [string]$what, [string]$why) {
  $script:N++
  Write-Host ""; Write-Host ("  Stage {0}/{1}  {2}" -f $script:N, $Total, $title) -ForegroundColor Magenta
  Write-Host (Hr); if ($what) { Write-Host "  $what" -ForegroundColor DarkGray }
  if ($Auto) { return $true }
  while ($true) {
    $r = Read-Host "  [Enter] karo   [?] kyun   [q] ruk ja"
    if ($r -eq "" -or $r -eq "y") { return $true }
    if ($r -eq "q") { Write-Host "  ruk gaye. Jitna hua wo saved hai — dobara chalao to wahin se aage." -ForegroundColor Green; exit 0 }
    if ($r -eq "?") { Write-Host "  $why" -ForegroundColor DarkGray }
  }
}
function StageOpt([string]$title, [string]$what, [string]$why) {
  $script:N++
  Write-Host ""; Write-Host ("  Stage {0}/{1}  {2}" -f $script:N, $Total, $title) -ForegroundColor Magenta
  Write-Host (Hr); if ($what) { Write-Host "  $what" -ForegroundColor DarkGray }
  if ($Auto) { return $false }   # scripted runs never install third-party software
  while ($true) {
    $r = Read-Host "  [Enter] haan   [s] skip   [?] kyun   [q] ruk ja"
    if ($r -eq "" -or $r -eq "y") { return $true }
    if ($r -eq "s" -or $r -eq "n") { Write-Host "  — skip" -ForegroundColor DarkGray; return $false }
    if ($r -eq "q") { exit 0 }
    if ($r -eq "?") { Write-Host "  $why" -ForegroundColor DarkGray }
  }
}
function Ok([string]$m)   { Write-Host "    ✓ $m" -ForegroundColor Green }
function Warn([string]$m) { Write-Host "    ⚠ $m" -ForegroundColor Yellow }
function Mf([string]$p)   { New-Item -ItemType Directory -Force -Path $Base | Out-Null
  if (-not (Test-Path $Manifest) -or -not ((Get-Content $Manifest) -contains $p)) { Add-Content -Path $Manifest -Value $p } }
function RefreshPath { $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User") }
function FindPython {
  # 'py' launcher pehle (python.org installer deta hai). 'python' naam Microsoft Store ka stub bhi ho sakta hai jo Store kholta hai — use WindowsApps path se pehchan ke skip karo.
  foreach ($c in @(@("py","-3"), @("python"), @("python3"))) {
    $cmd = Get-Command $c[0] -ErrorAction SilentlyContinue
    if (-not $cmd) { continue }
    if ($cmd.Source -like "*WindowsApps*") { continue }
    try { $v = & $c[0] $c[1..($c.Length-1)] -c "import sys;print('%d.%d'%sys.version_info[:2])" 2>$null
          if ($v -match '^3\.(8|9|1\d)$' -or $v -match '^3\.[2-9]\d') { return @{ Exe = $c; Ver = $v } } } catch {}
  }
  return $null
}

# ── uninstall ────────────────────────────────────────────────────────────────
if ($env:AI_UNINSTALL -eq "1") {
  Write-Host "  Aasmaan · uninstall" -ForegroundColor White
  if (-not (Test-Path $Manifest)) { Write-Host "  manifest nahi mila — install hua hi nahi tha, ya pehle hi hat gaya."; exit 0 }
  Write-Host "  ye hatega (sirf ye — tere Ollama models, keys-file, vault NAHI):"; Get-Content $Manifest | ForEach-Object { "    $_" }
  Write-Host "  $Home_\.ai-env (keys) aur $Home_\ai-vault (memory) rakhe jaate hain — hataane ho to khud."
  if (-not $Auto) { $r = Read-Host "  [Enter] hatao   [q] rehne do"; if ($r -eq "q") { exit 0 } }
  if ((Get-Content $Manifest) -contains "task:Aasmaan-daemon") { & schtasks /Delete /TN "Aasmaan-daemon" /F | Out-Null; Write-Host "  - Task Scheduler: Aasmaan-daemon removed" }
  foreach ($p in Get-Content $Manifest) { if (($p -like "$Home_*" -or $p -like "$Base*") -and (Test-Path $p)) { Remove-Item -Recurse -Force $p; Write-Host "  - $p" } }
  $up = [Environment]::GetEnvironmentVariable("Path","User")
  if ($up -and $up.Split(";") -contains $BinDir) { [Environment]::SetEnvironmentVariable("Path", (($up.Split(";") | Where-Object { $_ -ne $BinDir }) -join ";"), "User"); Write-Host "  - PATH entry ($BinDir) removed" }
  $rt = @(".ai-daemon.json",".ai-update.json",".ai-chat.json",".ai-cache.jsonl",".ai-device.json",".ai-metrics.json",".ai-kb.jsonl",".ai-brains.json",".ai-jobs.json",".ai-tasks.json",".ai-traces.jsonl",".ai-wishes.jsonl",".ai-feedback.jsonl",".ai-corpus.jsonl",".ai-profile",".ai-private-names") | ForEach-Object { Join-Path $Home_ $_ } | Where-Object { Test-Path $_ }
  if ($rt) { Write-Host "  'ai' ki runtime files (chat state, cache — koi key/memory nahi):"; $rt | ForEach-Object { "    $_" }
    $r = if ($Auto) { "" } else { Read-Host "  [Enter] ye bhi hatao   [k] rakho" }
    if ($r -ne "k") { $rt | ForEach-Object { Remove-Item -Force $_ }; Write-Host "  - runtime files removed" } }
  Remove-Item -Force $Manifest -ErrorAction SilentlyContinue
  if ((Get-ChildItem $Base -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) { Remove-Item -Force $Base -ErrorAction SilentlyContinue }
  Write-Host "  done. Ollama aur uske models tere hain — unhe chhua nahi (Settings > Apps se hatate hain)."; exit 0
}

# ── stage 1: teri machine (sirf dekhta hai) ──────────────────────────────────
Stage "Teri machine" "Windows · RAM · GPU · Python · Ollama — sirf DEKHTA hai, kuch badalta nahi" "Aage ke faisle (kaunsa local model) isi pe tikte hain. Is stage me kuch install nahi hota." | Out-Null
$os  = Get-CimInstance Win32_OperatingSystem
$ram = [int]((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB)
$freeDisk = [int]((Get-PSDrive -Name $Home_.Substring(0,1)).Free / 1MB)
$gpu = (Get-CimInstance Win32_VideoController | Select-Object -First 1).Name
$vram = 0
if (Get-Command nvidia-smi -ErrorAction SilentlyContinue) { try { $vram = [int](& nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits 2>$null | Select-Object -First 1) } catch {} }
$py = FindPython
$oll = Get-Command ollama -ErrorAction SilentlyContinue; $ollUp = $false; $ollModels = ""
try { $t = Invoke-RestMethod -Uri "http://127.0.0.1:11434/api/tags" -TimeoutSec 2; $ollUp = $true; $ollModels = ($t.models | ForEach-Object { $_.name }) -join " " } catch {}
Write-Host ("  {0,-9} {1} ({2})" -f "OS:", $os.Caption, $os.OSArchitecture)
Write-Host ("  {0,-9} {1} MB" -f "RAM:", $ram)
Write-Host ("  {0,-9} {1} MB free on {2}:" -f "Disk:", $freeDisk, $Home_.Substring(0,1))
Write-Host ("  {0,-9} {1}{2}" -f "GPU:", $gpu, $(if ($vram) { " · $vram MB VRAM" } else { "" }))
Write-Host ("  {0,-9} {1}" -f "Python:", $(if ($py) { "$($py.Ver) ($($py.Exe -join ' '))" } else { "nahi mila" }))
Write-Host ("  {0,-9} {1}" -f "Ollama:", $(if ($oll) { "installed" + $(if ($ollUp) { ", running · models: " + $(if ($ollModels) { $ollModels } else { "(none yet)" }) } else { ", not running" }) } else { "nahi hai (optional — cloud free brains bina iske bhi chalte hain)" }))

# ── stage 2: Python (official, winget, user scope) ──────────────────────────
if (-not $py) {
  if (StageOpt "Python 3 chahiye" "Official Python (python.org) winget se, sirf tere user ke liye — admin nahi" "Command: winget install -e --id Python.Python.3.12 --scope user. Ye Microsoft ka package manager hai, Windows 10/11 me built-in. Kuch aur nahi chhedta.") {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) { Warn "winget nahi mila. Python yahan se lo: https://www.python.org/downloads/windows/  ('Add python.exe to PATH' tick karo), phir dobara."; exit 1 }
    Write-Host "  chal raha hai:  winget install -e --id Python.Python.3.12 --scope user"
    & winget install -e --id Python.Python.3.12 --scope user --accept-package-agreements --accept-source-agreements
    RefreshPath; $py = FindPython
    if (-not $py) { Warn "Python install ke baad bhi nahi dikha — ye PowerShell band karke nayi kholo, phir wahi command dobara."; exit 1 }
    Ok "Python $($py.Ver)"
  } else { Warn "Python ke bina 'ai' nahi chalta. Install karke dobara chalao."; exit 1 }
} else { $script:N++; Ok "Python $($py.Ver) pehle se hai — stage 2 skip" }

# ── stage 3: local brain (Ollama) — adapt, depend nahi ──────────────────────
function PickModel {
  if     ($vram -ge 15000) { "qwen2.5-coder:32b" }     # 16-24 GB VRAM · 20 GB download
  elseif ($vram -ge 11000) { "qwen2.5-coder:14b" }     # 12 GB VRAM · 9 GB
  elseif ($vram -ge 5500)  { "qwen2.5-coder:7b" }      # 6-8 GB VRAM · 4.7 GB
  elseif ($ram  -ge 30000) { "qwen3-coder:30b" }       # CPU 32 GB+ · 19 GB (MoE, 3.3B active)
  elseif ($ram  -ge 14000) { "qwen2.5-coder:7b" }      # CPU 16 GB
  elseif ($ram  -ge 7000)  { "qwen2.5-coder:3b" }      # CPU 8 GB · 1.9 GB
  elseif ($ram  -ge 3500)  { "qwen2.5-coder:1.5b" }    # CPU 4 GB · 1 GB
  else { "" }
}
$model = PickModel
$what = if ($model) { "Offline code-model tere hardware ke hisaab se: $model" } else { "RAM kam hai — local model skip, cloud free brains use honge (sab kaam phir bhi chalega)" }
if (StageOpt "Local brain (Ollama)" $what "Ollama tere user folder me install hota hai (admin nahi), PATH me 'ollama' jodta hai, login pe tray icon ke saath background me chalta hai. Ye script use khud install nahi karta — official command dikhata hai. Context 16k pin hota hai (Ollama ka default 4k coding ke liye kam hai).") {
  if (-not $oll) {
    Write-Host "  Official install — do raaste (dono ollama.com ke apne):"
    Write-Host "     1) winget install -e --id Ollama.Ollama"
    Write-Host "     2) https://ollama.com/download/windows  (OllamaSetup.exe)"
    $r = if ($Auto) { "s" } else { Read-Host "  [Enter] winget wala chalao   [s] khud karunga" }
    if ($r -ne "s") {
      if (Get-Command winget -ErrorAction SilentlyContinue) { & winget install -e --id Ollama.Ollama --accept-package-agreements --accept-source-agreements; RefreshPath; $oll = Get-Command ollama -ErrorAction SilentlyContinue }
      else { Warn "winget nahi — link 2 se install karo, phir dobara chalao." }
    }
    if ($oll) { Ok "ollama mil gaya. Model pull ke liye ye script dobara chalao (ya khud:  ollama pull $model)" }
  } elseif (-not $ollUp) { Warn "ollama hai par chal nahi raha — Start menu se 'Ollama' kholo, phir dobara." }
  elseif ($model) {
    if ((" $ollModels ") -like "* $model *") { Ok "$model pehle se hai — pull skip" }
    else {
      Write-Host "  pull hoga: $model  (disk free: $freeDisk MB). Tere baaki models ko chhua nahi jayega."
      $r = if ($Auto) { "s" } else { Read-Host "  [Enter] pull   [s] skip" }
      if ($r -ne "s") { & ollama pull $model }
    }
  }
}

# ── stage 4: files — sirf tere user folder me, manifest ke saath ────────────
Stage "'ai' install" "ek Python file → $App\ai.py · 18 experts + packs → $Home_\.ai-experts* · shim → $BinDir\ai.cmd" "Zero dependencies: stdlib Python. Koi pip, koi venv, koi admin nahi. Har file manifest me." | Out-Null
New-Item -ItemType Directory -Force -Path $App, $BinDir | Out-Null
$srcDir = $null
if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot "ai.py"))) { $srcDir = $PSScriptRoot }
else {
  $zip = Join-Path $env:TEMP "aasmaan.zip"; $ex = Join-Path $env:TEMP "aasmaan-src"
  $url = "https://github.com/$Repo/archive/refs/heads/$Branch.zip"; $raw = "https://raw.githubusercontent.com/$Repo/$Branch"
  if (Test-Path $ex) { Remove-Item -Recurse -Force $ex }
  Write-Host "  download: $url"
  try { Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing; Expand-Archive -Path $zip -DestinationPath $ex -Force
        $srcDir = (Get-ChildItem $ex -Directory | Select-Object -First 1).FullName }
  catch {
    # zip blocked (some proxies block github.com archives, not raw): raw per-file via FILES.txt
    Write-Host "  (zip blocked — raw files ek-ek karke)"
    $list = (Invoke-WebRequest -Uri "$raw/FILES.txt" -UseBasicParsing).Content -split "`n" | Where-Object { $_.Trim() -ne "" }
    $srcDir = Join-Path $ex "raw"; New-Item -ItemType Directory -Force -Path $srcDir | Out-Null
    foreach ($f in $list) { $f = $f.Trim(); $dst = Join-Path $srcDir $f; New-Item -ItemType Directory -Force -Path (Split-Path $dst) | Out-Null
      Invoke-WebRequest -Uri "$raw/$f" -OutFile $dst -UseBasicParsing }
    Write-Host ("  {0} files" -f $list.Count)
  }
}
Copy-Item (Join-Path $srcDir "ai.py") (Join-Path $App "ai.py") -Force; Mf (Join-Path $App "ai.py")
foreach ($f in @("experts.json","tools-routing.json","panel.html","whiteboard.html","VERSION","README.md","LICENSE","install.ps1")) { $s = Join-Path $srcDir $f; if (Test-Path $s) { Copy-Item $s (Join-Path $App $f) -Force; Mf (Join-Path $App $f) } }
Copy-Item (Join-Path $srcDir "experts.json") (Join-Path $Home_ ".ai-experts.json") -Force; Mf (Join-Path $Home_ ".ai-experts.json")
if (Test-Path (Join-Path $srcDir "tools-routing.json")) { Copy-Item (Join-Path $srcDir "tools-routing.json") (Join-Path $Home_ ".ai-tools.json") -Force; Mf (Join-Path $Home_ ".ai-tools.json") }
if (Test-Path (Join-Path $srcDir "panel.html")) { Copy-Item (Join-Path $srcDir "panel.html") (Join-Path $Home_ ".ai-panel.html") -Force; Mf (Join-Path $Home_ ".ai-panel.html") }
$packs = 0; $pk = Join-Path $Home_ ".ai-experts"
Get-ChildItem (Join-Path $srcDir "experts") -Directory | ForEach-Object { $d = Join-Path $pk $_.Name; New-Item -ItemType Directory -Force -Path $d | Out-Null; Copy-Item (Join-Path $_.FullName "*.md") $d -Force; $packs++ }
Mf $pk
$pyCmd = ($py.Exe -join " ")
Set-Content -Path (Join-Path $BinDir "ai.cmd") -Value "@echo off`r`n$pyCmd `"%LOCALAPPDATA%\Aasmaan\app\ai.py`" %*" -Encoding ASCII; Mf (Join-Path $BinDir "ai.cmd")
$prof = Join-Path $Home_ ".ai-setup-profile"
if ($model -and -not (Test-Path $prof)) { Set-Content -Path $prof -Value "AI_TIER=PC`nAI_LOCAL_MODEL=$model`nAI_LOCAL_CTX=16384" -Encoding ASCII; Mf $prof }
# /setup inside 'ai' re-runs this installer from the app copy; /update re-fetches from the repo
$setupCmd = "AI_SETUP_CMD=powershell -NoProfile -ExecutionPolicy Bypass -File `"$App\install.ps1`""
$keep = @(); if (Test-Path $prof) { $keep = Get-Content $prof | Where-Object { $_ -notmatch '^AI_SETUP_CMD=' } }
Set-Content -Path $prof -Value ($keep + $setupCmd) -Encoding ASCII; Mf $prof
Ok "ai.py ($((Get-Content (Join-Path $App 'ai.py')).Count) lines, one file — Notepad me khol ke poora padh sakte ho)"
Ok "18 experts · $packs packs (persona + KB)"

# ── stage 5: keys — env me pehle se hain to REUSE; naye ek 0600-jaisi file me ─
Stage "Cloud brains (free keys)" "Groq · Cerebras · Gemini · OpenRouter — sab optional, sab free tier; blank + Enter = skip" "Keys $Home_\.ai-env me — sirf tera user padh sakta hai (icacls). 'ai' khud padhta hai; koi system env var nahi banta." | Out-Null
$envf = Join-Path $Home_ ".ai-env"
if (-not (Test-Path $envf)) { New-Item -ItemType File -Path $envf | Out-Null }
& icacls $envf /inheritance:r /grant:r "$($env:USERNAME):(R,W)" | Out-Null
function SetKey([string]$var, [string]$what, [string]$url) {
  if ([Environment]::GetEnvironmentVariable($var)) { Ok "$var tere env me pehle se hai — wahi use hoga"; return }
  if ((Get-Content $envf) -match "^export $var=") { Ok "$var .ai-env me hai"; return }
  if ($Auto) { return }
  $sec = Read-Host "  $what ($url) — blank = skip" -AsSecureString
  $val = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
  if ($val) { Add-Content -Path $envf -Value "export $var=$val"; Ok "$var saved" }
}
SetKey "GROQ_API_KEY" "Groq (fast, free)" "console.groq.com"
SetKey "CEREBRAS_API_KEY" "Cerebras (fast, free)" "cloud.cerebras.ai"
SetKey "GEMINI_API_KEY" "Gemini (free tier)" "aistudio.google.com"
SetKey "OPENROUTER_API_KEY" "OpenRouter (free models)" "openrouter.ai/keys"

# ── stage 6: daemon (optional) — Task Scheduler, logon pe, sirf tera user ────
if (StageOpt "Daemon (optional)" "har 30 min: update-check · brains ping · pending wishes · vault re-index → ~\.ai-daemon.json" "Windows Task Scheduler me ek logon task (sirf tera user, admin nahi). Unattended = koi forge/shell nahi (code me gate). Uninstall hata deta hai. Skip karo to 'ai daemon' haath se chalta hai. [Windows pe abhi untested]") {
  $tr = "`"$($py.Exe[0])`" " + $(if ($py.Exe.Length -gt 1) { ($py.Exe[1..($py.Exe.Length-1)] -join " ") + " " } else { "" }) + "`"$App\ai.py`" daemon --interval=30"
  & schtasks /Create /TN "Aasmaan-daemon" /SC ONLOGON /TR $tr /F | Out-Null
  if ($LASTEXITCODE -eq 0) { Ok "Task Scheduler: Aasmaan-daemon (logon)"; Mf "task:Aasmaan-daemon" } else { Warn "schtasks fail — haath se: ai daemon" }
}

# ── stage 7: PATH (tera faisla) + proof ─────────────────────────────────────
Stage "PATH + proof" "ek folder ($BinDir) tere USER PATH me — tabhi jab tu haan bole; uninstall wapas hata deta hai" "Windows pe 'ai' naam se chalane ka yahi ek tareeka hai. System PATH nahi, sirf user PATH. Ya phir poore path se chalao: $BinDir\ai.cmd" | Out-Null
$up = [Environment]::GetEnvironmentVariable("Path","User")
if ($up -and ($up.Split(";") -contains $BinDir)) { Ok "PATH me pehle se hai" }
else {
  $r = if ($Auto) { "" } else { Read-Host "  [Enter] PATH me jodo   [n] nahi, poore path se chalaunga" }
  if ($r -ne "n") { [Environment]::SetEnvironmentVariable("Path", ($(if ($up) { "$up;" } else { "" }) + $BinDir), "User"); RefreshPath; Ok "PATH me juda (nayi PowerShell/CMD window me 'ai' chalega)" }
  else { Warn "theek hai — chalao:  $BinDir\ai.cmd" }
}
& $py.Exe[0] $py.Exe[1..($py.Exe.Length-1)] -m py_compile (Join-Path $App "ai.py"); Ok "ai.py compiles on Python $($py.Ver)"
$env:AI_FORCE_OFFLINE = "1"
& $py.Exe[0] $py.Exe[1..($py.Exe.Length-1)] (Join-Path $App "ai.py") version 2>&1 | ForEach-Object { "    $_" }
$out = "/agents`n/quit`n" | & $py.Exe[0] $py.Exe[1..($py.Exe.Length-1)] (Join-Path $App "ai.py") 2>&1 | Out-String
$n = ([regex]::Matches(($out -split "`n" | Where-Object { $_ -match "agents:" }), "[a-z]+\*")).Count
Remove-Item Env:AI_FORCE_OFFLINE
if ($n -ge 18) { Ok "$n/18 expert packs load hote hain (offline, bina brain ke)" } else { Warn "packs load nahi hue ($n/18) — 'ai' me /agents chala ke dekho. Output:`n$out" }
Write-Host ""; Write-Host "  ✅ Aasmaan ready" -ForegroundColor Green
Write-Host "  chalao (nayi window):  ai"
Write-Host "  code:   /agent rachaka <paste traceback>   ·  /ctx <file>   ·  /do forge <tool naam>"
Write-Host "  hataana:  `$env:AI_UNINSTALL=1; irm https://raw.githubusercontent.com/$Repo/$Branch/install.ps1 | iex"
