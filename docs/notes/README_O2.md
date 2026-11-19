# O2 — Offline billing (bina internet ke bill)

## Idea
Internet na ho to bill phone me save hota hai ("Bill — waiting to sync"). Net aate hi app khud (har 30 sec, ya "Try now")
bill ko server par bhejta hai — **wahi saleId** se, to bill dobara ban hi nahi sakta. Bill number sync ke waqt milta hai.
Products Firestore ke local cache se chalte hain, isliye scan/search offline bhi chalta hai (jo pehle ek baar online khul chuka ho).

## Steps
1. `flutter pub add shared_preferences`
2. **Pehle I1, I2, I3 apply ho chuke hon** (arb aur router unhi par bane hain), phir ye zip extract karo
   (K1 wala `bill_pdf_builder.dart` bhi isme merge hai — isse overwrite hone do).
3. `flutter gen-l10n` → `dart format .` → `flutter analyze` → `flutter test`
4. Firestore rules me koi change nahi.

## Naya / badla
- naya: `lib/features/offline/**` (pending bill model, local store, queue, sync, banner, "Bills waiting to sync" screen)
- badla: `billing_providers.dart` (checkout ka network-error path, salesProvider/saleProvider me pending bills), `sale_done_screen.dart`,
  `bills_history_screen.dart`, `bill_pdf_screen.dart`, `bill_pdf_builder.dart` (PENDING bill no.), `firestore_sale_repository.dart` (timeout 25s→12s),
  `app_shell.dart` (top banner), `app_router.dart` (`/bill/pending`), arb
- tests: `test/unit/offline_test.dart`, `test/widget/pending_sales_screen_test.dart`, helper `fake_pending_sale_store.dart`

## Jab server bill ko mana kare
Dukaan me maal pehle hi bik chuka hota hai, isliye bill phone me rehta hai aur banner laal ho jaata hai:
- stock kam (insufficientStock) → stock add karo, phir **Retry**
- price badal gaya → purani price wapas rakho, phir **Retry**, ya **Discard**
- product archive ho gaya → **Discard** karke bill dobara banao
Baaki bills tab bhi sync ho jaate hain.

## Seemayein (jaan-boojh kar)
- Offline bill stock cache me abhi kam nahi dikhta: offline me ek hi item bar-bar bechoge to sync par "stock kam" aa sakta hai.
- Offline bills **reports/profit/CSV me tab tak nahi** jab tak sync na ho.
- Sirf bill banana offline hai. Product add/edit, stock in/out, udhar payment ab bhi internet maangte hain.
- App data clear / uninstall karne par pending bills chale jaayenge — sync hone tak app mat hatao.
- Sab kuch sandbox me chala nahi; Firestore offline behaviour (transaction ka turant fail hona) phone par test karna: airplane mode me bill banao.

## Phone par test
1. Airplane mode on → bill banao → "Bill (waiting to sync)" + upar banner.
2. Airplane mode off → ~30 sec ya banner → "Try now" → banner gayab, bill history me asli number.
3. Offline me ek bill banao, net aane se pehle us product ka stock Products se kam kar do → sync par laal banner + reason.
