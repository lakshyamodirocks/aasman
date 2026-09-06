# FAQ

**Kya ye bina kisi account / API key ke chalta hai?**
Haan. Ollama + local model = zero account, zero key, zero net. Chat, 18 experts, memory, KB, sab. Net ho to keyless tools bhi (DuckDuckGo search, scrape, Pollinations images). Cloud key sirf tab jab tum khud daalo.

**Kitna achha likhega / kaam karega?**
Brain jitna, utna. 16 GB RAM pe `qwen2.5-coder:7b` chhote functions, tracebacks, algorithms, tests theek karta hai. 8 GB pe 3B basic. Phone pe 4B helper hai, coder nahi. Poore project ka refactor: nahi, wo Claude Code / Codex ka kaam hai. Ye ek file hai jo brains ko host karti hai; wo hone ka natak nahi karti.

**Mera data kahan jaata hai?**
Local brain: kahin nahi. Cloud brain (tumhari key): scrub ke baad us provider ko. Baaki sab `~/` me files. Poori list: [TRUST.md](TRUST.md).

**Python / Ollama install karna padega?**
Haan, aur wo tum karoge, official installer se. Script sirf command dikhati hai (`winget install Ollama.Ollama`, `brew install ollama`, Ollama ki Linux script) aur Enter pe chalati hai. Pehle se ho to reuse.

**Mere paas GPU nahi hai / RAM kam hai.**
Install phir bhi poora hota hai. Model chhota chunta hai (1.5B/3B) ya skip karta hai; memory, KB, keyless tools milte hain; free cloud key baad me add kar sakte ho.

**Update kaise hoga?**
`ai` start pe ek line: "update available … chalao: …". Tum `ai update` (ya `/update`) chalao — poochhega, phir fresh download + reinstall; keys aur memory rehte hain. Khud kabhi nahi karta.

**"update yourself" chat me likha to?**
Rule-table pakadti hai (model nahi), command suggest karti hai, y/N poochhti hai. Isi tarah "agents dikhao", "go offline", "remember: …", "what can you do".

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
