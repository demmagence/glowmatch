# GlowMatch Release & Production Signing Guide

This guide describes how to configure signing, manage credentials securely, and produce production release artifacts for Android and iOS.

---

## 1. Production Identifiers & Metadata

The production application identifiers and metadata across platforms are standardized as follows:

| Platform | Identifier / Property | Value | Configuration Location |
| :--- | :--- | :--- | :--- |
| **Android** | Application ID | `com.demma.glowmatch` | `android/app/build.gradle.kts` |
| **Android** | Namespace | `com.demma.glowmatch` | `android/app/build.gradle.kts` |
| **Android** | Display Name (Label) | `GlowMatch` | `android/app/src/main/AndroidManifest.xml` |
| **iOS** | Bundle Identifier | `com.demma.glowmatch` | `ios/Runner.xcodeproj/project.pbxproj` |
| **iOS** | Display Name | `GlowMatch` | `ios/Runner/Info.plist` (`CFBundleDisplayName`) |
| **iOS** | Bundle Name | `GlowMatch` | `ios/Runner/Info.plist` (`CFBundleName`) |

---

## 2. Android Production Signing

Android release builds in GlowMatch are designed to be secure by default:
- **Debug signing is never used in release builds.**
- If signing credentials are provided, Gradle signs the release artifact using the production key.
- If signing credentials are not provided (e.g. non-secret CI checks), Gradle compiles an **unsigned** release artifact (`app-release-unsigned.apk` or unsigned AAB), preventing any accidental release with debug keys.

### 2.1 Generating an Upload Keystore

To create a new Android release signing keystore locally:

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

> [!WARNING]
> Keep the generated keystore file and passwords safe and backed up. If you lose your upload keystore, you will need to contact Google Play Console support to reset the upload key.

### 2.2 Local Build Configuration (`key.properties`)

1. Copy the template:
   ```bash
   cp android/key.properties.example android/key.properties
   ```

2. Place your keystore file in `android/app/` (or specify an absolute or relative path) and edit `android/key.properties`:
   ```properties
   storePassword=<keystore-password>
   keyPassword=<key-password>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

3. `android/key.properties` and `*.jks` / `*.keystore` are strictly ignored by `.gitignore` and must never be committed.

### 2.3 CI / GitHub Actions Secret Configuration

In continuous integration environments, avoid checking in keystores. Instead, supply the credentials via environment variables:

| Environment Variable | Description | Example / Secret Source |
| :--- | :--- | :--- |
| `KEYSTORE_PATH` | Path to keystore on CI runner | `/tmp/upload-keystore.jks` |
| `KEYSTORE_PASSWORD` | Keystore password | `${{ secrets.ANDROID_KEYSTORE_PASSWORD }}` |
| `KEY_ALIAS` | Key alias name | `${{ secrets.ANDROID_KEY_ALIAS }}` |
| `KEY_PASSWORD` | Key password | `${{ secrets.ANDROID_KEY_PASSWORD }}` |

To decode a base64-encoded keystore stored in GitHub Secrets (`ANDROID_KEYSTORE_BASE64`):
```bash
echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > /tmp/upload-keystore.jks
export KEYSTORE_PATH=/tmp/upload-keystore.jks
```

### 2.4 Building Android Release Artifacts

#### Google Play Android App Bundle (AAB):
```bash
flutter build appbundle --release --dart-define-from-file=secrets.json
```
Output: `build/app/outputs/bundle/release/app-release.aab`

#### Standalone Release APK:
```bash
flutter build apk --release --dart-define-from-file=secrets.json
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### Unsigned Release Check (without secrets):
```bash
flutter build apk --release
```
When credentials are omitted, this compiles release bytecode and verifies ProGuard/R8 rules without requiring signing secrets.

---

## 3. iOS Production Signing & Archiving

### 3.1 Distribution Signing Configuration

Distribution profiles and Apple Developer Team IDs can be configured in `ios/Flutter/Release.xcconfig` or via environment variables:

```xcconfig
CODE_SIGN_IDENTITY = Apple Distribution
DEVELOPMENT_TEAM = <YOUR_TEAM_ID>
PROVISIONING_PROFILE_SPECIFIER = <YOUR_PROVISIONING_PROFILE_NAME>
```

### 3.2 Building iOS Archive & IPA

To build an iOS release archive:

```bash
flutter build ipa --release --dart-define-from-file=secrets.json
```

For automated distribution via export options:
```bash
flutter build ipa --release --export-options-plist=ExportOptions.plist --dart-define-from-file=secrets.json
```

---

## 4. Credential Security Checklist

Before pushing commits or publishing releases, ensure:
1. `git status --ignored` shows `key.properties` and `*.jks` under the Ignored list.
2. No passwords or private keys are written in build scripts (`build.gradle.kts`, `Release.xcconfig`, etc.).
3. Secrets are stored in `secrets.json` (for app configuration) or GitHub Actions Secrets (for CI/CD).
