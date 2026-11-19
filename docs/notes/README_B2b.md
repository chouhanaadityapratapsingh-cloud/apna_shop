# B2b - Customer name and number on every bill

On the payment sheet the customer name and mobile number can be filled for
ANY bill (cash, UPI or udhar). Blank is fine for cash/UPI: nothing is printed.
When filled, it is printed on the PDF in all four templates and shown on the
saved-bill screen. For udhar both are still required. Whatever is filled must
be valid (name 2-60 letters, mobile 10 digits). No rules change, no new
packages. Run: flutter gen-l10n, dart format ., flutter analyze, flutter test.
