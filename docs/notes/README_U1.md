# U1 — UPI QR on the bill (udhar due)

Jab bill me udhar baaki ho **aur** shop details me UPI id bhari ho, to bill PDF (4 templates)
me "Scan to pay balance Rs X" QR aata hai. Scan karte hi koi bhi UPI app us amount ke saath khulta hai.

- Paid bill (udhar 0) ya UPI id khali: QR nahi aata, bill pehle jaisa.
- Koi naya package nahi; QR `pdf` package se hi bana hai. Rules/arb badle nahi.
- Ek hi file badli: `bill_pdf_builder.dart`. Naya test: `test/unit/bill_upi_qr_test.dart`.

    dart format .
    flutter analyze
    flutter test

Dhyan: sandbox me Flutter nahi hai, kuch run nahi hua. Asli phone par ek udhar wala bill banake QR
scan karke dekhna (alag phone ya UPI app se) ki amount aur naam sahi aa raha hai.
