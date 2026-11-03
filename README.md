# Apna Shop

Inventory and stock-management app for Indian kirana stores and small
retailers. Flutter + Firebase, Android-first.

Status: **M1 (foundation)** — theme, routing, email/password auth, typed
errors, English/Hindi strings. Store setup, products and stock movements come
in later milestones.

## Requirements

- Flutter 3.47.x (Dart 3.13.x)
- Node.js and the Firebase CLI (`npm install -g firebase-tools`)
- A **separate** Firebase project for Apna Shop (do not reuse another app's)

## Setup

```
flutter pub get
flutter gen-l10n
```

### Firebase

1. In the Firebase console create a project (for example `apna-shop-dev`).
2. Authentication → Sign-in method → enable **Email/Password**.
3. Connect the app:
   ```
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Pick the Apna Shop project and the Android platform. This replaces the
   placeholder `lib/firebase_options.dart` and adds `android/app/google-services.json`.
4. Run the app:
   ```
   flutter run
   ```

Until step 3 is done the app shows a "Firebase setup needed" screen instead of
crashing.

Never commit service-account keys or admin credentials. This repo needs none.

## Checks

```
dart format .
flutter analyze
flutter test
```

## Known limitations (M1)

- Products, Activity and Reports tabs are labelled "Not available yet".
- Store setup, team and stock features are not built yet.
- The app follows the device language (English or Hindi). There is no
  in-app language switch yet.
- Hindi strings should be reviewed by a native speaker on a real device.
- Password reset and phone sign-in are not included.
