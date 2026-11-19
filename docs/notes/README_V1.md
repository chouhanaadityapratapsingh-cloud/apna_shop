# V1 — Voice entry (bolkar bill me item jodna)

Billing screen par naya **mic button** (Scan / Add by name ke saath). Dabao, bolo:
"2 atta, 1 sugar, 3 parle g" — app items product list se match karke dikhati hai (quantity ke saath).
Tick/untick karo, + / − se quantity badlo, **Add to bill** dabao. Stock se zyada bola to
quantity stock tak kam hoti hai aur message aata hai. Bina bole **type** bhi kar sakte ho (wahi box).

Samajhta hai: "2 atta", "atta 2", "do atta teen sugar", "atta aur sugar" (bina number = 1),
Devanagari (दो आटा, ३ आटा), chhoti galtiyan (sugr → sugar). Jo na mile wo "Not found" me dikhta hai,
guess nahi hota. Do items barabar match ho to "Please check this match" aata hai.

## Setup (pehli baar, 3 kaam)

1. Package:

       flutter pub add speech_to_text

   (pub.dev par 7.5.0 hai; isko Flutter 3.44+/Dart 3.12+ chahiye, tumhare paas 3.47 hai.)

2. `android/app/src/main/AndroidManifest.xml` me, `<manifest>` ke andar (`<application>` ke bahar):

       <uses-permission android:name="android.permission.RECORD_AUDIO"/>
       <uses-permission android:name="android.permission.INTERNET"/>
       <queries>
         <intent>
           <action android:name="android.speech.RecognitionService"/>
         </intent>
       </queries>

   Agar `<queries>` pehle se hai to sirf `<intent>...</intent>` uske andar jod do.
   INTERNET pehle se ho to dobara mat likhna.

3. Zip extract karo, phir:

       flutter gen-l10n
       dart format .
       flutter analyze
       flutter test

   Phir app **band karke dobara run** karo (`flutter run`), hot reload se plugin nahi judta.

## Dhyan rakho
- Bolne ke liye phone me Google ka speech service chahiye (zyadatar Android phones me hota hai) aur aam taur par internet.
  Na ho to sheet me message aata hai aur type karna chalta rehta hai.
- **English / Hinglish** mode (default) me phone Roman letters deta hai, jo tumhare product names se match hote hain.
  **हिन्दी** mode Devanagari deta hai: wo tabhi match hoga jab product ka naam Devanagari me ho.
- Pehli baar mic ki permission maangega.
- Sandbox me Flutter nahi hai, kuch run nahi hua. Parser ke 15 unit tests aur sheet ke 9 widget tests likhe hain,
  par asli mic ka behaviour sirf phone par dikhega. Pehle shaant jagah test karna, phir dukaan me.
- Ek bill me max 15 lines wali limit yahan bhi lagti hai.

## Files
Naye: `lib/features/voice/**`, `test/unit/voice_order_test.dart`, `test/widget/voice_order_sheet_test.dart`,
`test/helpers/fake_voice_recognizer.dart`.
Badle: `billing_screen.dart` (fix7 wala discount fix saath me hai), `app_en.arb`, `app_hi.arb`.
Rules deploy ki zarurat nahi.
