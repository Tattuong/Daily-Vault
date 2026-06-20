# Daily Vault

Secure personal storage for passwords, secret notes and documents. Lock with PIN or fingerprint. Earn or buy stars to unlock themes, backgrounds and premium features.

## Tech stack

- **Flutter** (Dart 3.4+)
- **Hive** — local vault storage
- **local_auth** — PIN & biometric unlock
- **Remote IAP config** — `https://api2.blwsmartware.net/N206.json`

## Package IDs

## Google Play IAP products

## Remote config (N206.json)


Sample: `docs/N206.json`

## Setup

```bash
flutter pub get
python tool/generate_logo.py
flutter pub run flutter_launcher_icons
flutter run
```

## Release build

Configure `android/key.properties` for signing, then:

```bash
flutter build appbundle --release
```
