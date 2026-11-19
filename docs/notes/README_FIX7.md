# Fix7 — discount dialog crash

Discount dalte waqt red screen: `'_dependents.isEmpty': is not true`.
Reason: dialog band hote hi text controller turant dispose ho jata tha, jabki dialog abhi exit animation me tha.
Fix: dialog ab apna alag widget hai jo controller khud sambhalta hai aur sahi time par dispose karta hai.

Badli file: `billing_screen.dart`. Naya test: `test/widget/discount_dialog_test.dart`.
