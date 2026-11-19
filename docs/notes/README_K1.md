# K1 — Kg / litre units (loose saaman)

Ab product ki unit **Kilogram (kg)** ya **Litre (L)** ho sakti hai. Loose atta, cheeni, tel, chawal
kilo/litre me bikta hai, 1.5 kg ya 250 g bhi (0.25 kg).

## Kaise kaam karta hai
- **Product banate waqt** unit me Kilogram / Litre chuno. Opening stock aur low-stock alert
  `12.5` jaise likho. Price **per kg / per litre** hota hai (box me "/ kg" dikhta hai).
- **Stock in/out/adjust**: 2.5 jaise decimals likh sakte ho (3 decimals tak).
- **Bill**: loose item add karne par 1 kg se shuru hota hai (stock kam ho to jitna hai utna).
  Quantity par **tap** karke exact likho (1.25), ya +/- se aadha kilo badhao/ghatao.
  Line ka amount = kilo x rate (paise tak round).
- **PDF / CSV / reports / order list / voice**: sab me "1.5 kg", rate "Rs.60.00/kg".
  Voice me "2 kilo cheeni" = 2 kg. Report me loose item bill me **1 item** gina jata hai.
- Backend me loose quantity **grams / millilitre** me jodi jati hai (1.5 kg = 1500), isliye stock kabhi fraction me nahi hota.

## Rules badle hain -> deploy zaroori
    firebase deploy --only firestore --project apna-shop-dev
(kg/litre allowed; ek bar kg/litre ka product ban jaye to uski unit badal nahi sakte, aur
piece/packet wale ko kg me badal nahi sakte, kyunki stored number ka matlab badal jata.)

## Steps
    flutter gen-l10n
    dart format .
    flutter analyze
    flutter test

## Dhyan rakho
- **Purane products ko kg me mat badlo** (app rokta bhi hai). Loose item ke liye **naya product** banao
  (jaise "Cheeni Loose", unit kg).
- Pehle se bane bills/stock par asar nahi hai.
- Limits: ek product ka stock max 10,000 kg/L; bill me ek line max itne hi.
- Voice sirf poore kilo/litre samajhta hai ("2 kilo"), "aadha kilo" ya "500 gram" abhi nahi
  (500 gram wala item "not found" me aata hai, galat add nahi hota). Bill me tap karke 0.5 likh do.
- Sandbox me Flutter nahi hai, kuch run nahi hua. Rules ke naye tests `firestore_tests/rules.test.js`
  me hain (Java + emulator chahiye).

## Files
Naye: `quantity.dart`, `quantity_dialog.dart`, tests (`quantity_test`, `cart_weighed_test`,
`weighed_misc_test`, `quantity_dialog_test`, `voice_weighed_test`).
Badle: product, validators, form, messages, cart, sale, billing screen, PDF builder, stock math/sheet/tile,
orders (list, pdf, screen, providers), reports (calc, csv), voice (parser, apply, sheet), firestore.rules,
rules.test.js, app_en.arb, app_hi.arb.
