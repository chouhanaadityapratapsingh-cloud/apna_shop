# I1 — Excel / CSV se products import

## Naye / badle files
- `lib/features/import/**` (naya): table reader, import plan, xlsx reader, sample sheet, providers, screen
- `lib/app/router/app_router.dart`: route `/products/import` (`:productId` se pehle)
- `lib/features/products/presentation/products_list_screen.dart`: AppBar me upload icon (sirf editProducts wale ko)
- `lib/l10n/app_en.arb`, `app_hi.arb`: import strings
- tests: `test/unit/import_test.dart`, `test/widget/import_screen_test.dart`

## Steps
1. `flutter pub add archive xml`
2. Zip ko project me extract karo (arb/router/products_list overwrite honge — agar tumne inhe I1 ke baad badla ho to merge karo)
3. `flutter gen-l10n` → `dart format .` → `flutter analyze` → `flutter test`
4. Firestore rules me **koi change nahi**.

## Kaise kaam karta hai
- Pehli row heading hoti hai. Name/Item/Product, Barcode/EAN, Unit/UOM, Purchase/Cost, Selling/Rate/MRP/Price, Qty/Stock, Low stock, Brand, Category, SKU samjhe jaate hain (Hindi headings bhi).
- Unit: pcs, pkt, box, btl, pack, kg, ltr (kg/litre me stock decimal ho sakta hai, jaise 25.5).
- Sirf barcode wali row: naam Open Food Facts se (max 100 rows, internet chahiye).
- Pehle se maujood barcode / same naam+brand, aur file me repeat: skip.
- Selling price nahi to row roki jaati hai; switch on karo to price 0 ke saath add hoti hai.
- Max 1000 rows. Internet jaaye to import ruk jaata hai, jo add ho chuka wo rehta hai.

## Dhyan do
- `.xls` (purani) support nahi — .xlsx ya CSV me save karo.
- Excel me barcode column Text format me rakho, warna leading zero ud sakte hain aur lamba number 8.9E+12 ban sakta hai.
- `xlsx_reader.dart` apna parser hai (archive + xml), sandbox me chala nahi sakta; analyze error de to paste karna. (`excel` package pdf se xml version par clash karta hai, isliye use nahi kiya.)
