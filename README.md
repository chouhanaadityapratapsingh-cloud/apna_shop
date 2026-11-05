# Apna Shop

Inventory and stock-management app for Indian kirana stores and small
retailers. Flutter + Firebase, Android-first.

Status: **M2 (store setup and roles)**.

- M1: theme, routing, email/password auth, typed errors, English/Hindi strings.
- M2: create-store flow, store/member/role model, store-scoped repository,
  Firestore security rules with tests.

Products, stock movements, barcode scanning, offline sync, reports and team
invites come in later milestones.

## Requirements

- Flutter 3.47.x (Dart 3.13.x)
- Node.js and the Firebase CLI (`npm install -g firebase-tools`)
- Java 21 or newer (only for the Firestore emulator that runs the rules tests)
- A **separate** Firebase project for Apna Shop (do not reuse another app's)

## Setup

```
flutter pub get
flutter gen-l10n
```

### Firebase

1. Create a Firebase project (for example `apna-shop-dev`).
2. Authentication: enable **Email/Password**.
3. Firestore Database: create a database in **production mode**. Pick a
   location close to your users (for example `asia-south1`). The location
   cannot be changed later.
4. Connect the app:
   ```
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Choose the Apna Shop project and the Android platform. This replaces the
   placeholder `lib/firebase_options.dart` and adds `android/app/google-services.json`.
5. Deploy the security rules (**required**, otherwise Create store fails):
   ```
   firebase deploy --only firestore:rules --project <your-project-id>
   ```
6. Run the app:
   ```
   flutter run
   ```

Until step 4 is done the app shows a "Firebase setup needed" screen instead of
crashing.

Never commit service-account keys or admin credentials. This repo needs none.

## Data model (M2)

```
users/{uid}                         email, displayName, activeStoreId, createdAt
stores/{storeId}                    name, ownerUid, currencyCode, timezone, city?, phone?, isActive, createdAt
stores/{storeId}/members/{uid}      role (owner|manager|staff), status, permissions[], joinedAt
```

Creating a store writes all three documents in one atomic batch. The rules
check that the store, the owner membership and the user's `activeStoreId`
pointer arrive together, that the user becomes the owner, and that a user has
only one store.

The blueprint lists `createStore` as a Cloud Function. M2 uses a rules-checked
batch instead, because Cloud Functions need the Blaze plan. Stock movements
(M4) will need the Blaze plan.

## Checks

Flutter:

```
dart format .
flutter analyze
flutter test
```

Firestore rules tests (run from the project root; needs Java and the Firebase CLI):

```
cd firestore_tests
npm install --save-dev @firebase/rules-unit-testing firebase
cd ..
firebase emulators:exec --only firestore --project demo-apna-shop "npm --prefix firestore_tests test"
```

## Known limitations (M2)

- Creating a store needs an internet connection (by design: it is online-only).
- The first sign-in on a new device needs an internet connection so the app
  can find the user's store. Offline caching arrives with M6.
- Joining an existing store (team invites) is not built yet. Only the owner
  who creates a store has access to it.
- Store settings editing and closing a store are not built yet; the rules
  block those writes for now.
- The preferred-language setting is not stored yet. The app follows the device
  language (English or Hindi).
- Products, Activity and Reports tabs are labelled "Not available yet".
- Hindi strings should be reviewed by a native speaker on a real device.
