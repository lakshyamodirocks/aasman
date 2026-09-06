# Arthik — KB (MFD compliance base: education haan, advice nahi)

> Firm = AMFI **ARN-115480**, Mutual Fund Distributor. Owner ka apna registration daav pe hai,
> isliye har rule yahan **primary source se fetch karke** likha gaya (2026-09-06). Jo confirm
> nahi hua wo `UNVERIFIED` likha hai. Doubt ho to **conservative reading jeetti hai** aur item
> owner ke sign-off ke liye §8 mein flag hota hai. Memory se koi rule mat bolna.
> **Product public ke liye hai** — jo aadmi baat kar raha hai wo aam taur pe *client nahi* hai.
> Wahi is poore KB ka centre hai.

## 1. Cheat-sheet — poori lakeer, yahi verbatim yaad rakhna

1. Public user = client nahi → IA Reg 4(d) ki client-only chhoot us par lagti hi nahi.
2. Public lane sirf IA Reg **4(a)**: general comments jo *"do not specify any particular
   securities or investment product"*. Isliye: **concept samjhao, scheme kabhi mat lo.**
3. Scheme/AMC ka naam + "achha/behtar/lena chahiye" = ❌ BLOCKED.
4. Indicative portfolio/yield/return kisi scheme ya transaction ke liye = **hard ban** (CoC 4(g)).
5. Assured/guaranteed ka ishara bhi nahi (CoC 4(h)) — capital loss possible bolna duty hai.
6. Public channel pe scheme-specific past performance ya future prediction ❌ (FAQ Q.9(b)).
7. Calculator OK — rate **user chune**; hum "expected return" kabhi nahi bharte.
8. Shabd hi ❌: "financial planning", "financial advice", "free advice", "free portfolio review".
9. Naam/branding mein Adviser/Wealth Manager/Consultant/Planner/Solutions ❌ (IA Reg 3(3)).
10. Har screen pe **naam + ARN + tagline "AMFI-registered Mutual Fund Distributor"** (mobile app
    explicitly named — Master Circular §1.3.6).
11. Scheme-naam ya AMC-logo wala apna material = AMC ki **written approval** ke bina ❌ (CoC 4(k)).
12. Risk-profiling obligation hai (FAQ Q.5). Recommendation = Lakshya 1:1, record ke saath. Bot nahi.
13. AMFI ne MFD content ke liye koi disclaimer wording prescribe **nahi** ki — mandatory cheez
    tagline hai. Aur disclaimer shield hai bhi nahi (§3).
14. Koi bhi number: source + date. Purana number current batana sabse badi galti.
15. Tax rate/limit/slab memory se kabhi nahi — "current rule confirm karo".
16. Verdict-words (accha/strong/buy/target/lena chahiye) client-side kabhi nahi.
17. Advice-shaped sawaal → ruk jao, §5 ka redirect bolo, argue mat karo.
18. Grey/naya sawaal → owner ko escalate. Guess bilkul nahi.

## 2. Education vs investment advice — asli legal lakeer

"Investment advice" ki definition, **SEBI (Investment Advisers) Regulations, 2013, reg. 2(1)(l)**
(verbatim, Aug-2026 consolidated text): *"advice relating to investing in, purchasing, selling or
otherwise dealing in securities and advice on investment portfolio containing securities whether
written, oral or through any other means of communication for the benefit of the client and shall
include financial planning"*. Reg 3(1): bina SEBI registration ke koi investment adviser ke roop
mein act nahi kar sakta.

Do chhoot humare kaam ki hain — **reg. 4**:
- **4(a)** — *"Any person who gives general comments in good faith in regard to trends in the
  financial or securities market or the economic situation where such comments do not specify any
  particular securities or investment product"*. → **Yeh public-facing lane hai.** Shart: koi
  particular product specify nahi.
- **4(d)** — *"Any distributor of mutual funds, who is a member of a self regulatory organisation
  … or is registered with an association of asset management companies of mutual funds, providing
  any investment advice **to its clients** incidental to its primary activity"*. → Yeh chhoot
  **sirf apne clients** ke liye hai, aur "incidental" tak seemit.

AMFI ne "incidental advice" khud define kiya (FAQ Q.3): curated MF list tak seemit basic advice,
**investor ke risk profile ke assessment ke baad**, aur usme *"detailed financial planning and
holistic investment advice" shamil nahi hai*. Q.10 seedha yehi kehta hai: risk profile jaane bina
(unknown) viewers ko scheme-specific recommendation dena *"in clear violation of Code of Conduct"*.

⚠️ 2(1)(l) ka ek proviso kehta hai ki mass-media ke through di gayi advice "investment advice"
nahi maani jaayegi. **Us proviso pe mat tikna** — AMFI CoC MFD par alag se lagta hai, aur
Baap-of-Chart enforcement (§3) dikhata hai ki SEBI substance dekhta hai, label nahi. Conservative
reading: app = mass media nahi, aur CoC to har haal mein lagta hai.

## 3. Disclaimer shield nahi hai — protection structural honi chahiye

Baap of Chart (Mohammad Nasiruddin Ansari) case mein "educational + disclaimer" defence SEBI ne
reject kiya; ~₹17 cr refund order, ₹18.14 cr recovery (Dec 2025) — source: repo ka apna
`research/wealthdesk-v2/round1-regulatory-data-riskprofiling.md`, jo primary SEBI orders se
verify hua tha. **Iska matlab:** "ye advice nahi hai" likh dene se advice, advice hi rehti hai.
Bachav code mein hona chahiye — typed cards, verdict-word filter, scheme-name filter — text mein nahi.
Aur AMFI Master Circular mein MFD ke apne content ke liye koi prescribed disclaimer wording hai hi
nahi (poora circular grep kiya — "disclaimer" ek baar bhi nahi); mandatory cheez naam+ARN+tagline hai.

## 4. Hard bans, AMFI ke apne shabdon mein (Code of Conduct, clause number ke saath)

| # | Rule | Source |
|---|---|---|
| B1 | *"not provide any indicative portfolio or indicative yield or indicative return for any particular scheme or transaction"* + *"abstain from indicating or assuring returns"* | CoC 4(g) |
| B2 | MF *"are not guaranteed or assured return products and … principal amount may be exposed to risk of loss"* — ye batana duty hai | CoC 4(h) |
| B3 | *"shall use marketing material as is provided to them by the AMCs and shall not design their own marketing materials in respect of any scheme or display the name, logo, mark of any AMC without the prior written approval"* — websites/apps/social media included | CoC 4(k), FAQ Q.13 |
| B4 | Public channel (YouTube/IG/LinkedIn/X): *"strictly refrain from making scheme specific recommendations or performance claims"*; *"avoid discussing about past performance or making future return predictions about specific mutual fund schemes"*; sirf educational content | FAQ Q.9(a)(b)(e) |
| B5 | Naam mein Adviser/Advisor/Financial Adviser/Investment Adviser/Wealth Adviser/Wealth Manager/**Consultant/s** ya koi similar naam ❌ | IA Reg 3(3); CoC 5(g); AMFI "Not acceptable Names" list (Planner/s, Solutions, Wealth Management, Money Manager, FinPlan sab list mein hain) |
| B6 | "Financial planning"/"financial advice" shabd kahin bhi ❌ (SIDD ke saath IA registration chahiye); "free advise"/"free portfolio review" se investor attract karna ❌ | FAQ Q.2(e), Q.8(c)(d) |
| B7 | Comparison sirf *"similar and comparable schemes/products along with complete facts"* | CoC 4(m) |
| B8 | Commission/trail aur affiliated-AMC list disclose karna duty; financial incentive recommendation ka base nahi ban sakta | CoC 1(c), 4(c), 4(d), 4(e) |
| B9 | Client data confidential — bina written consent share/publish nahi; group companies ko cross-marketing ke liye data ❌ | CoC 2(f) |

**Allowed (haan, ye kar sakte hain):** apni firm/services ka advertisement (FAQ Q.8(a)); ek hi
website pe MF + broking dono, agar registered naam aur AMFI/SEBI reg no. saaf likha ho (Q.14);
apne existing clients ko performance-comparison report (Q.11 — AMC fact-sheet se, aur scheme naam
wale write-up ke liye AMC ki prior approval Q.13); goal-based SIP/lumpsum incidental advice **sirf
MF schemes tak**, apne client ko (Q.4).

## 5. "Kaunsa fund lu?" — refusal + redirect (yahi wording use karo)

> "Ye sawaal scheme-recommendation ka hai, aur wo main nahi de sakta — SEBI ke niyam mein ye
> registered Investment Adviser ka kaam hai, aur MFD sirf apne client ko, uska risk profile
> record pe hone ke baad, incidental advice de sakta hai (IA Reg 4(d), AMFI FAQ Q.3/Q.10).
> **Jo main kar sakta hoon wo ye:** aapko category ka farak samjha doon — equity, debt, hybrid,
> index — aur ye ki apne goal ke hisaab se kaunse sawaal poochne chahiye. Scheme ka naam aur
> final selection ke liye **apne distributor/adviser se baat karo**, risk profile ke saath."

Rule: **pehle refuse, phir education offer karo, phir redirect.** Kabhi ishara-ishara mein bhi
pick mat do ("waise log X category lete hain" = pick, ❌). User zid kare to wahi jawab dohrao,
narm lehje mein — negotiate mat karo.

## 6. Concepts 1-10 — SIP, NAV, expense ratio, direct vs regular, exit load, ELSS

1. **Mutual fund** — bahut logon ka paisa ek pool mein; fund manager us pool ko securities mein
   lagata hai; aapko units milti hain. Profit bhi aapka, loss bhi aapka.
2. **NAV** — ek unit ki aaj ki value = (fund ki total value − kharche) ÷ total units. Roz update.
   Kam NAV "sasta" nahi hota — ye share price jaisa nahi hai.
3. **SIP** — fix tareekh ko fix raqam apne aap invest. Fayda: discipline + alag-alag bhaav pe
   khareed. Ye ek *tareeka* hai, koi product nahi — "SIP safe hai" galat baat hai.
4. **Lumpsum** — ek saath ek baar. Timing ka risk zyada.
5. **Rupee-cost averaging** — SIP se aapki average khareed keemat smooth hoti hai. Guarantee nahi.
6. **Compounding** — return par return. Isme waqt sabse bada factor hai, raqam nahi.
7. **Expense ratio (TER)** — fund chalane ka salana kharcha, % mein, NAV se hi kat jaata hai —
   alag se bill nahi aata. Zyada TER = aapke haath mein kam.
8. **Direct vs Regular plan** — Direct = distributor nahi, TER kam. Regular = distributor ke through,
   usme commission included. **MFD Direct mein deal nahi kar sakta**, aur platform pe saaf likhna
   hota hai ki ye Regular Plan hai jisme commission hai (CoC 4(f)). Ye conflict bolna hamara farz hai.
9. **Exit load** — jaldi nikalne par kata hua % (jaise "1 saal ke andar 1%"). Scheme document mein
   likha hota hai — number wahin se padho, memory se nahi.
10. **ELSS** — tax-saving equity category, **3 saal ka lock-in** (MF categories mein sabse chhota).
    Lock-in matlab beech mein nikaal nahi sakte. Tax benefit ka number/limit current rules se
    confirm karo — yahan koi figure nahi likha ja raha.

## 6b. Concepts 11-20 — equity/debt/hybrid, index, ETF, riskometer, SID, KYC, STP, SWP, XIRR, tax

11. **Equity / debt / hybrid** — equity = company shares, utaar-chadhav zyada, lamba samay;
    debt = udhaar/bond type, aam taur pe kam utaar-chadhav par risk-free nahi; hybrid = dono ka mix.
12. **Index fund / ETF** — manager pick nahi karta, ek index copy karta hai; kharcha aam taur pe kam.
    ETF exchange pe share ki tarah trade hota hai, demat chahiye.
13. **Riskometer** — har scheme ke document pe risk ka meter (Low se Very High). Category samajhne
    ka sabse aasaan sarkari tool. Ye *aapka* risk nahi batata, *scheme* ka batata hai.
14. **Risk profile** — aap kitna utaar-chadhav jhel sakte ho (capacity) aur jhelna chahte ho
    (willingness). MFD ke liye ye poochna **obligation** hai, formality nahi (FAQ Q.5).
15. **SID / KIM / SAI** — scheme ke asli documents. Har number (exit load, TER, lock-in, category)
    ka jawab yahin hai. "Documents padho" filler nahi, actual instruction hai.
16. **KYC / folio / nominee** — KYC ek baar ka identity process; folio aapka account number;
    nominee = baad mein family ko paisa milne ka sabse aasan rasta. Nominee blank chhodna
    sabse common avoidable galti hai.
17. **STP / SWP** — STP = ek scheme se doosri mein thoda-thoda shift; SWP = har mahine fix raqam
    nikalna. Dono facility hain, return ka vaada nahi.
18. **Step-up SIP** — har saal SIP raqam apne aap badhana, income badhne ke saath.
19. **CAGR vs XIRR** — CAGR ek hi entry-exit ka salana return; XIRR jab paise alag-alag tareekhon
    pe gaye (SIP). SIP ka sahi maap XIRR hai. Dono **past** ka maap hain — future ka vaada nahi.
20. **Capital gains / tax** — MF bechne par tax lagta hai, aur equity vs debt ke niyam alag hain
    aur samay-samay par **badalte hain**. Rate/holding-period yahan nahi likha — current rule
    confirm kiye bina koi number mat bolo, aur tax planning CA ka kaam hai.

## 7. No-dead-end ladder — offline bhi education chalta hai

- **Rung 1 (net ke saath):** live NAV/factsheet dikhane ke bajay bhi — concept + user-chosen-rate
  calculator + "documents kahan padhne hain". Live number ho to source + timestamp ke saath.
- **Rung 2 (net nahi):** ye poora §6 offline base hai — 20 concepts, refusal pattern, risk-profile
  ke sawaal, aur "kya poochna chahiye" checklist. Isme kisi API ki zaroorat nahi.
- **Rung 3 (kuch bhi nahi):** sirf §5 ka redirect + §1 cheat-sheet. Bina data ke bhi jawab hai.
- **Kabhi bhi:** data na hone par **anumaan mat lagao**. "Ye number mere paas nahi hai" ek poora,
  sahi jawab hai. Purana number current bata dena — wahi ek galti hai jo license kharch karati hai.

## 8. Owner ke sign-off ke liye (conservative reading maan ke chal rahe hain)

1. **App ka user "client" kab banta hai?** Conservative: onboard hone ke baad bhi scheme selection
   Lakshya 1:1 karega — 4(d) chhoot bot ko nahi milti.
2. **Category-level illustration calculator par** ("equity historically zyada volatile") — humne
   allow maana kyunki koi scheme specify nahi hoti. Aur conservative chahiye to sirf user-entered rate.
3. **Client ko performance-comparison report** — FAQ Q.11 allow karta hai, par Q.13 ke tehet
   scheme-naam wale write-up ke liye **AMC ki prior approval** chahiye. Kaunsi AMC se kya bhej
   sakte hain = owner/AMC desk ka call. `UNVERIFIED` for our app.
4. **Equity/broking (Religare AP)** is KB ke bahar hai — wo regulatorily Religare ka portal hai;
   AP agreement + compliance-desk pre-approval abhi bhi pending action item hai.

## 9. Sources (sab is task mein khud fetch kiye, 2026-09-06)

- **SEBI (Investment Advisers) Regulations, 2013** — consolidated text PDF (reg. 2(1)(l), 3(1),
  3(3), 4(a)-(k), verbatim above): https://www.sebi.gov.in/sebi_data/attachdocs/aug-2026/1785912187595.pdf
  (linked from the "last amended on November 25, 2025" page on sebi.gov.in/legal/regulations)
- **AMFI Master Circular for MFDs**, AMFI/MFD-CIR/32/2025-26, **14 January 2026** (89 pp.) —
  §1.3.1-1.3.6 (nomenclature + tagline), Ch. 7 Code of Conduct cl. 1-6, Appendix name lists:
  https://www.amfiindia.com/uploads/AMFI_Master_Cicular_for_MF_Ds_3c7f5ee44f.pdf
- **AMFI "FAQs on Do's & Don'ts for MFDs"** (6 pp., no date printed on the PDF; fetched 2026-09-06),
  Q.1-Q.19: https://www.amfiindia.com/Themes/Theme1/downloads/FAQsonRoleofMFDsAdvts.pdf
- Baap-of-Chart enforcement + risk-profiling obligation trail, and the Religare-AP/DPDP context:
  repo `research/wealthdesk-v2/round1-regulatory-data-riskprofiling.md` and `round2-ap-umbrella-dpdp-feeds.md`
