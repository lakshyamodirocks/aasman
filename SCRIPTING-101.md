# Scripting-101 — Lakshya ke liye (Hinglish) #scripting #teach #tools

> Maqsad: "koi bhi cheez jo script ban sakti hai" — usse khud banana + samajhna. `ai` isko
> KB me padh ke tujhe teri bhasha me samjha sakta hai (`/kb build` ke baad `/kb scripting`).
> Aur jo khud banwana ho: `ai` me `/tool <naam> <kya kare>` — script ready milegी.

## 0. Script hoti kya hai
Ek text file jisme commands upar-se-neeche likhi hoti hain. Pehli line **shebang** batati hai
kis se chale:
- bash: `#!/data/data/com.termux/files/usr/bin/bash`
- python: `#!/data/data/com.termux/files/usr/bin/python3`
Phir `chmod +x file` karke `./file` se chalti hai. `~/.local/bin` me rakho to sirf naam se chalti hai.

## 1. Kab bash, kab python
- **bash** — files, commands ko jodna (ffmpeg, git, curl chain karna). Chhota glue.
- **python** — logic, data, JSON, loops, hisaab. 20+ line kaam.
Rule of thumb: "commands ko jodna" = bash; "sochna/ginna/parse" = python.

## 2. Bash — 6 cheezein kaafi hain
```bash
name="Lakshya"                 # variable (spaces mat do = ke around)
echo "namaste $name"           # print
for f in *.mp4; do echo "$f"; done   # loop over files
if [ -f "in.mp4" ]; then echo "hai"; fi   # condition
count=$(ls | wc -l)            # command ka output variable me
"$1"                           # pehla argument (script ko diya gaya)
```
Args: `$1 $2 …` = pehla, doosra argument. `$*` = saare. `$#` = kitne aaye.
Usage line hamesha do: `[ -z "$1" ] && { echo "usage: myscript <file>"; exit 1; }`

## 3. Python — 6 cheezein
```python
import sys, json                       # tools laao
q = sys.argv[1]                         # pehla argument
data = json.load(open("f.json"))        # JSON padho
for x in data: print(x)                 # loop
def f(a): return a*2                    # function
try: risky()
except Exception as e: print("err:", e) # error pakdo
```

## 4. Har achhi script me 4 aadatein
1. **Usage** — args na ho to kaise chalana hai bata ke `exit 1`.
2. **Validate** — file hai? number hai? pehle check.
3. **Errors dikhao** — chup-chaap fail mat ho; `echo`/`print` se batao.
4. **Chhota rakho** — ek script ek kaam. Bada kaam = chhote tools jodo.

## 5. `/tool` se khud banwao (offline-capable)
`ai` me:
```
/tool backup.sh   ~/ai-vault ko ek dated tar.gz me daal do
/tool count.py    ek folder me har extension ke kitne file hain wo ginno
```
`ai` router se code banega, `~/.local/bin/<naam>` me save + executable ho jayega, preview dikhega.
Naam `.py` pe khatam = python; warna bash. Ban-ne ke baad `/run <naam>` se chala ke `/explain` maang.
Seekhne ka tarika: banaya hua script khud padho — 10-15 line me pattern samajh aa jayega.

## 6. Roz kaam aane wale patterns (copy-samajh)
- **Batch rename:** `for f in *.JPG; do mv "$f" "${f%.JPG}.jpg"; done`
- **Sab jagah dhoondo:** `grep -rn "TODO" .`
- **JSON se field:** `python3 -c 'import json,sys;print(json.load(sys.stdin)["key"])'`
- **Time-stamp naam:** `id=$(date -u +%Y%m%dT%H%M%SZ)`
- **Safe temp file:** `f=$(mktemp)` … kaam … `rm -f "$f"`

> Agla kadam: `ai` me `/tool` se apni pehli 2-3 real cheezein banwa (jo tu roz haath se karta
> hai), phir wahi script khol ke padh. Banane + padhne se hi coding aati hai, ratne se nahi.
