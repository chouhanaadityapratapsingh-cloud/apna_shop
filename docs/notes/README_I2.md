# I2 — Photo se barcode

## Files
- `lib/features/scanner/data/barcode_photo_reader.dart` (naya): image_picker + mobile_scanner `analyzeImage`
- `lib/features/scanner/presentation/barcode_scanner_screen.dart`: "Read barcode from a photo" button (camera / gallery)
- `lib/l10n/app_en.arb`, `app_hi.arb`: 6 naye strings (I1 wale arb par bane hain — pehle I1 apply karo)
- tests: `test/widget/barcode_photo_test.dart`, `test/helpers/fake_barcode_photo_reader.dart`

## Steps
1. `flutter pub add image_picker`
2. Zip extract → `flutter gen-l10n` → `dart format .` → `flutter analyze` → `flutter test`
3. Rules me koi change nahi.

## Flow
Products ke scan icon → Scan screen → "Read barcode from a photo" → camera ya gallery → barcode mila to wahi flow
chalta hai jo live scan ka hai: product mila to khulta hai, nahi mila to "Add product" → form me naam Open Food Facts se prefill.
Photo lete waqt live preview hat jaata hai (camera conflict se bachne ke liye).

## Dhyan do
- Android manifest me `CAMERA` permission already hai (mobile_scanner). image_picker ke camera ke liye wo permission granted honi chahiye;
  scan screen pehle khul chuka hota hai to ho jaati hai. Agar photo-camera crash/cancel ho to batana.
- iOS ke liye Info.plist me NSCameraUsageDescription / NSPhotoLibraryUsageDescription chahiye (abhi sirf Android target hai).
- Photo me barcode saaf, seedha aur paas hona chahiye. Blur ya tirchi photo me "not found" aayega.
- `analyzeImage` ka asli kaam sandbox me test nahi ho sakta; widget tests fake reader use karte hain.
