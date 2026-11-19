# S1 - Shop details (Profile > Shop details)

The owner can set what is printed on every bill PDF:

- shop name, address, city, phone
- UPI ID (printed as "UPI: name@bank" under the phone number)
- the bottom line (default: "Thank you! Visit again.")

Blank optional fields are simply not printed. Managers and staff do not see
the entry, and the Firestore rules refuse their edits as well. Rules allow
only these fields to change; owner, currency, timezone and active flag stay
fixed. Changing needs internet.

Run (project root):

    flutter gen-l10n
    dart format .
    flutter analyze
    flutter test
    firebase deploy --only firestore --project apna-shop-dev

The deploy is needed (store rules changed). Rules tests (needs Java):

    firebase emulators:exec --only firestore --project demo-apna-shop "npm --prefix firestore_tests test"

Not done: a shop LOGO. Uploading a picture needs Firebase Storage, which
needs the paid Blaze plan; a UPI QR code image on the bill is also left for
later (the UPI ID text is printed instead).
