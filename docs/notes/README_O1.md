# O1 — Order list (distributor ko bhejne ke liye)

Home ke "Low stock" card me **Make order list** button. Khulne par saare kam-stock items aate hain
with suggested quantity (low-stock mark ka double minus current stock, kam se kam 1).
+ / − se quantity badlo, 0 kar do to wo item list se nikal jata hai.

- **Copy text** → WhatsApp/SMS me paste karne ke liye plain list.
- **Share PDF** → A4 PDF, share sheet se WhatsApp/email/print.

Naya package nahi, rules deploy nahi. l10n badla hai.

    flutter gen-l10n
    dart format .
    flutter analyze
    flutter test

Files naye: `lib/features/orders/**`, `test/unit/order_list_test.dart`,
`test/widget/orders_screen_test.dart`.
Badle: `home_screen.dart`, `app_router.dart`, `app_en.arb`, `app_hi.arb`.

Dhyan: sandbox me Flutter nahi hai, kuch run nahi hua. Order list ki PDF/text English me hai
(distributor ke liye), screen EN/HI dono me.
