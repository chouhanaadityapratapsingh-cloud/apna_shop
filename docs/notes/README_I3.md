# I3 — Bill / list ki photo se products

## Pehle
I1 aur I2 apply ho chuke hon (arb I2 wale par bana hai).

## Files
- naya: `import/domain/ocr_rows.dart`, `import/data/text_photo_reader.dart`, `import/presentation/photo_import_screen.dart`
- badla: `import_providers.dart` (`loadTable`), `import_screen.dart` (photo button), `app_router.dart` (`/products/import-photo`), arb
- tests: `ocr_rows_test.dart`, `photo_import_screen_test.dart`, `fake_text_photo_reader.dart`

## Steps
1. `flutter pub add google_mlkit_text_recognition`
2. Zip extract → `flutter gen-l10n` → `dart format .` → `flutter analyze` → `flutter test`
3. Rules me koi change nahi.
4. Agar Android build `compileSdk`/`minSdk` par shikayat kare: plugin ko minSdk 21+ aur compileSdk 35/36 chahiye (`android/app/build.gradle`).

## Flow
Products → upload icon (Import) → "Photo of a bill or list" → photo → items ki list (naam, stock, unit, cost, selling editable;
jo product nahi use untick) → Continue → wahi import preview (duplicates, errors, "add") → Add.
Kuch bhi bina check kiye save nahi hota.

## Parsing ke rules
- Same line ke columns jodte hain (y-position se), phir: naam, pehla number = quantity, doosra = purchase price, teesra (amount) ignore.
- "5 kg", "2.5 ltr" se unit pata chalta hai, warna pcs.
- Total, GST, date, phone, heading wali lines hat jaati hain.

## Dhyan do
- OCR Latin (English/Roman) text ke liye hai. Devanagari script abhi nahi; haath ki likhai aksar galat padhi jaayegi — isliye review step hai.
- Selling price photo me nahi hota; khaali rahe to items agle screen par "no price" me rukte hain (switch se 0 price par add ho sakte hain).
- ML Kit ka asli kaam sirf phone par test ho sakta hai; sandbox me sirf parsing aur screens ke tests hain.
