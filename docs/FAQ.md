# FAQ

**Termux kahan se lein?**
Sirf F-Droid se: https://f-droid.org/packages/com.termux/ (F-Droid khud: https://f-droid.org/). Play Store wala purana aur toota hua hai. Add-ons bhi F-Droid se: Termux:API (mic/TTS), Termux:Boot (reboot pe chalu).

**Pehli command pe curl ka error (libcurl / SSL symbol) aaya?**
Fresh Termux ka curl tab tak toota hai jab tak base packages upgrade na hon — aur `pkg` khud usi curl se mirror chunta hai, isliye `pkg upgrade` bhi wahi error deta hai (Moto pe dono dekhe). Isliye command `apt update && apt full-upgrade` se shuru hoti hai (apt curl nahi use karta). Mirror / "unable to resolve" error aaye to `termux-change-repo` chalao (Enter, Enter), phir wahi command dobara.

**Linux pe `curl: command not found` / Mac pe python3 ne dialog khol diya / Windows pe pehli `irm` hi fail?**
Minimal Debian/Ubuntu me curl hota hi nahi: `wget -qO- …/install.sh | bash` wahi script hai (installer khud curl → wget → git me se jo mile use leta hai). Fresh Mac ka `/usr/bin/python3` Apple ka stub hai — installer ab use chalaye bina bolta hai `xcode-select --install` (ek baar), phir dobara. Windows: `irm` bahut purane Windows 10 build pe TLS 1.2 ke bina fail ho sakta hai — Windows update karo; Windows 10/11 current builds pe ye nahi hota (Windows path abhi tak sirf CI pe chala hai, asli machine pe pehla run = pehla test). Android update: `ai update` pehle check karta hai curl chalta hai ya nahi, toota ho to apt se pehle theek karta hai (pkg nahi — pkg khud curl maangta hai).

**Alarm, timer, reminder, calendar — chalega?**
Haan, har platform pe, bina account: "alarm 6:30 baje", "timer 10 min chai", "remind me at 10:30 chai", "kal 9 baje meeting yaad dilana", "meeting daal do 3 pm: dentist". Android pe Clock/Calendar app khud kaam karte hain (`am` intents, koi add-on nahi), Mac pe Reminders/Calendar.app, Windows pe Task Scheduler ka popup aur Clock/Calendar app, Linux pe systemd timer. Aur `/remind` sab jagah ka floor hai: OS na le to `ai` khula hone pe ya `ai daemon` se notification + awaaz. `/remind` = list, `/remind rm <id>` = hatao.

**Setup ne mera phone pehchan liya, phir bhi device kyun poochha?**
Ab nahi poochhta — wizard detected platform dikhata hai ("✓ Android (Termux) — yahi") aur Enter se aage. Sirf tab picker aata hai jab tujhe badalna ho (iPhone client, ya Linux/Mac). iPhone kabhi auto-detect nahi hota kyunki iOS ye chala hi nahi sakta. Windows apne installer se (`irm …/install.ps1 | iex`), ye wizard nahi.

**Roz subah ek greeting?**
`/greet on` — roz 10:00 pe (`/greet at 07:30` se badlo) ek greeting jo is device pe banti hai: tera naam (`~/.ai-profile`), teri language, din, mausam (`/greet city Jaipur` do to, net ho to — keyless Open-Meteo), aaj ke reminders, teri lists, ek tip. Koi brain ho to ek line uski bhi (`/greet brain off` se band). `ai` khulte hi ya `ai daemon` se notification (voice on ho to bol ke). Default off — tu on karta hai. Kal isi me panchang/tithi ki line judegi (ROADMAP).

**Bol ke chalega? Wake word hai?**
Push-to-talk: `v` ya `/voice` ek baar sunta hai, phir wahi rules jo typed chat ke hain — safe commands turant, baaki bol ke haan/nahi, aur `/quit /clear /keys /update /setup /net` sirf typed haan. Wake word nahi (hamesha-on mic = kamre me koi bhi operator ban jaata hai); Android pe `ai voice notify` ek pinned bol/ruk notification deta hai. Android ka built-in STT sirf English samajhta hai — offline Hindi ke liye setup-menu → 2 (whisper).

**Hindi / Hinglish me chalega?**
Haan. Installer pehle language poochhta hai (Enter = English). Nahi chuna to jo tu likhta hai wahi mirror hota hai — last 3 me se 2 Hinglish to Hinglish, aur bata ke switch karta hai. `/lang en|hinglish|hi|auto` se pin. Model usi language me jawab deta hai; commands/paths waise ke waise. UI ke ~20 strings English/Hinglish dono me hain, baaki abhi Hinglish. Devanagari sirf model ke jawab me (Windows console me installer text nahi).

**Kya ye bina kisi account / API key ke chalta hai?**
Haan. Bina brain ke bhi: `2+2`, `15% of 4200`, `date`, `time in Boston`, `5 km in miles`, `age 16 Nov 1994`, `emi/sip`, links/QR, device hands — `ai tour` 60 sec me dikha deta hai. Aur Ollama + local model = zero account, zero key, zero net. Chat, 18 experts, memory, KB, sab. Net ho to keyless tools bhi (DuckDuckGo search, scrape, Pollinations images). Cloud key sirf tab jab tum khud daalo.

**Kitna achha likhega / kaam karega?**
Brain jitna, utna. 16 GB RAM pe `qwen2.5-coder:7b` chhote functions, tracebacks, algorithms, tests theek karta hai. 8 GB pe 3B basic. Phone pe 4B helper hai, coder nahi. Poore project ka refactor: nahi, wo Claude Code / Codex ka kaam hai. Ye ek file hai jo brains ko host karti hai; wo hone ka natak nahi karti.

**Mera data kahan jaata hai?**
Local brain: kahin nahi. Cloud brain (tumhari key): scrub ke baad us provider ko. Baaki sab `~/` me files. Poori list: [TRUST.md](TRUST.md).

**Gmail / Notion / Sheets / Canva jod sakta hoon?**
Jo bina browser-login ke chalte hain, haan: `/mcp find <naam>` ya bas likho "sheets ka connector chahiye" — catalogue batata hai kya device se bahar jaata hai, install line, aur exact `/mcp add` line. Notion, Google Calendar, GitHub, Gmail, Todoist, Spotify, Home Assistant jaise login wale bhi option hain: `/mcp setup notion` pehle batata hai kya chahiye, kya data kahan jaayega, free hai; tu haan bole to step-by-step guide, token hidden typing se `~/.ai-env` me, phir ek read-only call se verify. Sirf Canva (remote OAuth jo client ko khud bolna padta hai), Google Photos (ek hi server, LICENSE file hi nahi) aur WhatsApp ka abhi raasta nahi — wajah aur local alternative `/mcp find` batata hai. Har card ke neeche likha hai hum kya kabhi nahi karte (token screen pe nahi, kisi aur server ko nahi, tere haan ke bina kuch nahi, hatana ek line). Kuch na mile to custom: `/mcp forge <ye kya kare>` pehle 3-step plan dikhata hai, tera haan leta hai, phir ek chhota MCP server likh ke, scan karke, preview dikha ke jodta hai. Home Assistant jaisi cheez (apna smart-home server) sirf naam se milti hai, suggest kabhi nahi hoti.

**"Tuning" ka matlab yahan kya hai? Model train hota hai?**
Nahi — weights kabhi nahi chhede jaate. Tuning = harness: model ke tier (1.7B phone vs cloud) ke hisaab se persona/KB/jawab ka budget, routing (kaun pehle, kab demote), seekhe hue examples (`/trace`), cache, aur `/plan` jo kaam ko steps me todta hai. `/tuning` sab knobs dikhata hai; `~/.ai-tuning.json` me sirf numbers badal sakte ho. `/usage` batata hai kitne tokens kahan gaye.

**LM Studio / llama.cpp / koi aur local server hai — jud jayega?** 
Haan: `ai connect http://localhost:1234` (LM Studio) — server ke models list hote hain, ek chun ke brain ban jaata hai; local address = raw text, `/net off` me bhi chalta hai. Ollama ke naye models apne aap dikhte hain (`/models`) aur khali roles (vision/embed) apne aap attach ho jaate hain. MCP server: `/mcp add`. Model weights kabhi nahi chhede jaate — "tuning" = routing, context, cache, seekhe hue examples.

**Python / Ollama install karna padega?**
Haan, aur wo tum karoge, official installer se. Script sirf command dikhati hai (`winget install Ollama.Ollama`, `brew install ollama`, Ollama ki Linux script) aur Enter pe chalati hai. Pehle se ho to reuse.

**Mere paas GPU nahi hai / RAM kam hai.**
Install phir bhi poora hota hai. Model chhota chunta hai (1.5B/3B) ya skip karta hai; memory, KB, keyless tools milte hain; free cloud key baad me add kar sakte ho.

**Update kaise hoga?**
`ai` start pe ek line: "update available … chalao: …". Tum `ai update` (ya `/update`) chalao — poochhega, phir fresh download + reinstall; keys aur memory rehte hain. Khud kabhi nahi karta.

**"update yourself" chat me likha to?**
Rule-table pakadti hai (model nahi), command suggest karti hai, y/N poochhti hai. Isi tarah "agents dikhao", "go offline", "remember: …", "what can you do".

**Phone / laptop ko control kar sakta hai? (volume, music, torch…)**
Haan — `/hands` dikhata hai is device pe abhi kya kya chal sakta hai. Plain words chalte hain ("awaaz 30", "pause", "battery", "say hello"), voice se bhi. "ruk" / `/stop` brake hai, `/undo` wapas. Android pe Termux:API (F-Droid) se volume/TTS/torch milte hain, Shizuku se kisi bhi app ka music control. Poori list: docs/HANDS.md.

**Screen cast / TV pe mirror kyun nahi?**
Kisi bhi OS me iske liye script ka raasta nahi hai (Android, Windows, Linux — koi public API nahi; macOS pe AirPlay ka CLI nahi). Isliye promise nahi karte: Windows/Android pe Cast settings page khol dete hain, baaki tap tumhara.

**Paired phone se apne phone ka volume/music control hoga?**
Nahi — panel us computer ko chalata hai jispe `ai pair` chala, phone ko nahi (browser phone ka volume/music/torch chhoo hi nahi sakta). Phone khud control karna ho to phone pe poora install (Termux) — phir `/hands`. Har combination kya deta hai: docs/PAIRING.md.

**Screenshot se error debug ho sakta hai?**
`/attach shot.png` → preview + kaun sa brain dekh sakta hai. Vision ke liye Gemini free key ya local `gemma3:4b` (`AI_VISION_MODEL`). Na ho to saaf mana karega.

**Uninstall?**
Windows: `$env:AI_UNINSTALL=1; irm …/install.ps1 | iex`. Linux/macOS: `pc-setup.sh --uninstall`. Android: `cleanup.sh` (pehle dry-run). Sab manifest se: wahi hatata hai jo isne likha; keys aur memory chhod deta hai.

**Windows pe test hua hai?**
CI (GitHub Actions) Windows pe install + `ai version` + daemon chalata hai — badge dekho. Physical Windows machine pe abhi tak first-hand nahi. Toota to issue kholo; `ai version` ka output saath me.

**iOS?**
Do raaste, dono bina hamare server ke. (1) **Sabse aasan:** apne Mac/PC pe `ai pair` chalao, iPhone se QR scan karo — iPhone us computer ke `ai` ka panel kholta hai (Safari → Add to Home Screen = app jaisa). Apna Wi-Fi ya Tailscale. (2) a-Shell jaise terminal app me `ai.py` (stdlib hai, chal jaata hai), brain phir bhi tumhare PC ka Ollama ya tumhari key — kyunki iOS pe koi app on-device model ko HTTP pe nahi deta. [ROADMAP.md](ROADMAP.md).

**Naam ka matlab?**
Aasmaan = आसमान = sky. Har Hindi/Urdu bolne wale ka roz ka shabd. Sanskrit me wahi "Akasha" hai.

**Kaun bana raha hai, kyun?**
Lakshya Sunderwani, Jaipur. Kyun: free AI sabke paas ho, phone-first, bharose ke saath, bina kisi ke server ke. Feedback weekly padha jaata hai, severity se tag hota hai, top rank turant.
