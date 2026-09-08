# Task 1: Production Signing, Identifiers, and Release Metadata Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Configure secure production signing for Android without exposing credentials, sanitize platform display names, verify bundle identifiers, and document production release procedures.

**Architecture:** Load release signing parameters from standard `key.properties` or environment variables in Gradle Kotlin DSL with fallback to unsigned release; update platform manifests and ignore files; provide clear release documentation.

**Tech Stack:** Gradle Kotlin DSL, Android Gradle Plugin, Flutter, iOS Xcode project configurations.

## Global Constraints
- Android release builds must never use the debug signing key.
- Release signing credentials and private keys must never be committed to Git.
- Platform display names must not contain unintended trailing punctuation.
- Production identifiers must remain consistent (`com.demma.glowmatch`).
- Apply ponytail senior dev mode: minimum code that works, no boilerplate.

---

### Task 1.1: Git Ignore & Keystore Security

**Files:**
- Modify: `.gitignore`
- Create: `android/key.properties.example`

- [ ] **Step 1: Update `.gitignore` with signing patterns**
Ensure `*.keystore`, `*.jks`, `**/android/key.properties`, `key.properties`, `local.properties`, `*.mobileprovision`, `*.p12`, `*.cer`, and `ExportOptions.plist` are in `.gitignore`.

- [ ] **Step 2: Create `android/key.properties.example` template**
Provide a clean template with clear instructions for developers.

- [ ] **Step 3: Verify git ignore behavior**
Test creating a temporary `.jks` and `android/key.properties` and verify `git status` ignores them.

- [ ] **Step 4: Commit**
`git commit -m "chore(android): ignore release signing keys and provide key.properties template"`

---

### Task 1.2: Android Release Signing Configuration

**Files:**
- Modify: `android/app/build.gradle.kts`

- [ ] **Step 1: Update `build.gradle.kts` to read release credentials safely**
Implement properties reading for `key.properties` with fallback to `System.getenv(...)`.
Define `release` signingConfig only when credentials are fully available.
Ensure `buildTypes.release` uses `release` signingConfig if available, or leaves it unsigned, removing any reference to `signingConfigs.getByName("debug")`.

- [ ] **Step 2: Verify unsigned build behavior**
Run Gradle `assembleRelease` without `key.properties` or env vars and verify that debug signing key is NOT used.

- [ ] **Step 3: Verify signed build behavior**
Test with temporary test keystore and verify the artifact is signed with the test key.

- [ ] **Step 4: Commit**
`git commit -m "feat(android): configure secure release signing with environment and file fallback"`

---

### Task 1.3: Sanitize Platform Display Names & Metadata

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml`
- Modify: `ios/Runner/Info.plist`
- Modify: `ios/Flutter/Release.xcconfig`

- [ ] **Step 1: Fix Android manifest display name**
Change `android:label="GlowMatch."` to `android:label="GlowMatch"`.

- [ ] **Step 2: Fix iOS Info.plist display names**
Change `CFBundleDisplayName` and `CFBundleName` from `"GlowMatch."` to `"GlowMatch"`.

- [ ] **Step 3: Update `ios/Flutter/Release.xcconfig`**
Add distribution signing comments and profile hooks.

- [ ] **Step 4: Verify platform manifests**
Grep for `GlowMatch.` to ensure no stray trailing periods remain in platform display names.

- [ ] **Step 5: Commit**
`git commit -m "fix(platform): remove trailing punctuation from android and ios display names"`

---

### Task 1.4: Production Release Documentation

**Files:**
- Create: `docs/RELEASE.md`

- [ ] **Step 1: Write comprehensive release guide**
Document keystore generation, `key.properties` configuration, CI secret setup, commands for APK, App Bundle (AAB), and iOS IPA builds.

- [ ] **Step 2: Verify release commands**
Review document commands for syntax and accuracy.

- [ ] **Step 3: Commit**
`git commit -m "docs: add comprehensive production release and signing guide"`
