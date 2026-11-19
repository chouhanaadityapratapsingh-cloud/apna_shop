# UI1 — Redesign round 1: theme, navigation, logo, Home

Spec: "NexPOS UI/UX Redesign" (PDF). Naam **Apna Shop** hi rakha; logo/wordmark naya.

## Steps
1. Zip ko project me extract karo (assets/fonts bhi aayenge).
2. `pubspec.yaml` me ye add karo (flutter: ke andar, `uses-material-design: true` ke neeche):
```yaml
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```
   (Inter font SIL Open Font License me hai; license file saath hai.) Koi naya package nahi.
3. `flutter pub get` → `flutter gen-l10n` → `dart format .` → `flutter analyze` → `flutter test`
4. Rules me koi change nahi. **Hindi** text Inter me nahi hota — wo phone ke default font se aata hai (normal).

## Kya badla
- Theme: Primary #2563EB, background #F8FAFC, white surface, success #10B981, error #EF4444, 1px #E2E8F0 border, flat cards (no shadow),
  radius 12 (cards/dialogs/sheets) aur 8 (buttons/fields), 8-pt spacing, Inter font. Dark mode bhi same colours ke dark version me.
- Bottom bar: **Home, Products, Udhar, Reports** + beech me gol **New sale** button (bill screen par chhup jaata hai). Tablet/wide (>=720px): side NavigationRail.
  Profile ab Home ke upar-right avatar se khulta hai. Bill ka rasta wahi hai.
- Logo + wordmark ("Apna" bold, "Shop" light) splash par.
- Home: store naam + avatar, range selector, swipe hone wale KPI cards (Sales, Udhar pending, Low stock), 4 quick actions
  (Add product, Import Excel, Sync offline [badge], Setup store — permission ke hisaab se), payment split + 7-din bars,
  low-stock list, **Recent sales** (last 5; hara = Received, laal = udhar Pending), khaali hone par friendly message.
- Offline banner: amber, patla: "Working offline – N bills will sync when internet returns" (galti hone par laal).
- Haptics: nav tab / New sale button par.

## Dhyan do
- Abhi sirf theme/nav/Home hai. Billing (UI2), Products (UI3), Udhar (UI4) screens ka layout agle rounds me.
  Un screens par naya theme (colours, cards, buttons) to turant dikhega, par layout purana rahega.
- Beech ka gol button list ke bottom ko thoda dhak sakta hai; agle rounds me lists ko bottom padding denge.
- Sandbox me kuch chala nahi; naye tests: `app_shell_test.dart`, updated `home_screen_test.dart`, `pending_sales_screen_test.dart`.
