# B3 - Udhar tab (customer ledger)

New bottom tab **Udhar** (Home, Products, Bill, Udhar, Profile). Activity
(stock history) moved to the clock icon at the top of the Products screen.

- **Udhar list**: total udhar of the shop, customers with biggest udhar first,
  search by name or mobile, "Show settled" to include customers at zero.
- **Customer screen**: balance, **Record payment received** (amount, Cash/UPI,
  optional note, "Full amount" shortcut) and the full history (each udhar bill
  and each payment). Tap an udhar line to open that bill (and its PDF).
- A payment can never be more than the balance, and the balance changes only
  together with a new ledger entry (enforced in Firestore rules, so it holds
  even if the app is modified).

Run (project root):

    flutter gen-l10n
    dart format .
    flutter analyze
    flutter test
    firebase deploy --only firestore --project apna-shop-dev

The rules changed (payment entries), so the deploy is needed. Rules tests:

    firebase emulators:exec --only firestore --project demo-apna-shop "npm --prefix firestore_tests test"

Limits: payments and udhar need internet; ledger entries cannot be edited or
deleted (a mistaken payment needs a correction feature later); staff can record
payments (owner-only option can be added).
