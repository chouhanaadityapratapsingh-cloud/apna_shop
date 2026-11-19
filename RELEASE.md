# Release checklist

## 1. Git (first commit)
```
cd C:\dev\apna_shop
git init
git add .
git status          # check no keys or keystore are listed
git commit -m "Apna Shop: billing, stock, udhar, reports, offline billing, EN/HI"
git branch -M main
git remote add origin https://github.com/<you>/apna_shop.git
git push -u origin main
```
`.gitignore` must contain (add if missing):
```
android/key.properties
*.jks
*.keystore
android/local.properties
```
`lib/firebase_options.dart` and `android/app/google-services.json` hold project
ids and an API key. They are not secrets (Firestore rules protect the data),
but if you prefer, keep them out of the public repo and tell readers to run
`flutterfire configure`.

## 2. Signing key (once, keep it safe)
```
keytool -genkey -v -keystore %USERPROFILE%\apna_shop_upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Create `android/key.properties`:
```
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=C:\\Users\\<you>\\apna_shop_upload.jks
```
Back up the .jks and the passwords. If you lose them you cannot update the app.

In `android/app/build.gradle.kts` read `key.properties` and add a `release`
signing config (see https://docs.flutter.dev/deployment/android#sign-the-app).
Paste the file here and I will make the exact edit.

## 3. Build
```
flutter build apk --release --split-per-abi
```
APKs are in `build\app\outputs\flutter-apk\`. Use `app-arm64-v8a-release.apk`
for most phones.

## 4. Before giving it to the shopkeeper
- Deploy the latest `firestore.rules` and indexes
- Install the release APK on a clean phone, sign up, add a shop, make a bill
- Test once with airplane mode on
- Take 4 screenshots (Home, Billing, Products, Udhar) into `docs/screenshots`
