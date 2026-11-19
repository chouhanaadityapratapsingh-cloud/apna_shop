# R1 — Reports + profit

## Kya naya hai
- Home par **Reports** button (owner / jinko sales dikhti hain).
- Period: Today, Last 7 days, Last 30 days, This month, Custom dates.
- Total, bills/items, cash / UPI / udhar split, discount, **profit**.
- Day-by-day list, top 10 items (quantity se aur amount se).
- **CSV export** (Excel/Sheets me khulta hai, Hindi naam bhi sahi).
- Ab har naye bill ki line me purchase price (`costPaise`) save hota hai, taaki profit nikle.

## Zaroori: rules deploy
Firestore rules badle hain:

    firebase deploy --only firestore --project apna-shop-dev

## Phir
    flutter gen-l10n
    dart format .
    flutter analyze
    flutter test

## Dhyan rakho
- Profit sirf **is update ke baad bane bills** ka dikhta hai. Purane bills me cost saved nahi tha.
  Agar kuch bills me cost hai aur kuch me nahi, to profit sirf cost wale bills ka hota hai (note dikhta hai).
- Ek report max 2000 bills padhti hai (uske upar message dikhta hai).
- CSV "save as" dialog se save hoti hai (file_picker).
- Staff ko sirf apne bills dikhte hain (rules ki wajah se).
- Sandbox me Flutter nahi hai, isliye kuch run nahi hua. Tests likhe hain par tumhare machine par pehli baar chalenge.
- `firestore_tests/rules.test.js` me naye tests hain (wrong/missing cost) — Java + emulator chahiye.

## Files
Naye: `lib/features/reports/**`, `test/unit/report_calc_test.dart`, `test/unit/sales_csv_test.dart`,
`test/widget/reports_screen_test.dart`, `test/helpers/{sample_sales,fake_report_exporter}.dart`.
Badle: `sale.dart`, `firestore_sale_repository.dart`, `home_screen.dart`, `app_router.dart`,
`app_en.arb`, `app_hi.arb`, `firestore.rules`, `rules.test.js`.
