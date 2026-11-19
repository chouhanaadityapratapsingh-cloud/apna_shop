# P1 — Products CSV backup (export)

Products screen ke AppBar me naya **download** icon (sirf jo products edit kar sakta hai). Active products ek CSV me save hote hain
(naam, barcode, unit, purchase/selling price, stock, low-stock alert, brand, category, SKU). Columns wahi hain jo **Import** padhta hai,
to ye file backup bhi hai: nayi/khaali dukaan me Import se wapas aa jaate hain (stock opening stock ban jaata hai).
Archived products shamil nahi. Naam jo `= + - @` se shuru ho use spreadsheet-safe apostrophe milta hai, Import usse hata deta hai.

## Steps
1. Koi naya package nahi.
2. I1, I2, I3, O2 ke baad zip extract karo (arb aur products_list_screen overwrite honge; `import_plan.dart` me chhota sa change).
3. `flutter gen-l10n` → `dart format .` → `flutter analyze` → `flutter test`
4. Rules me koi change nahi.

## Dhyan do
- Ye sirf products ka backup hai: bills, udhar ledger aur stock history isme nahi hain (bills ka alag CSV Reports me hai).
- Windows par file picker "save" dialog wahi hai jo Reports ke CSV me chalta hai.
- Sab kuch sandbox me chala nahi; tests likhe hain (export + import round trip).
