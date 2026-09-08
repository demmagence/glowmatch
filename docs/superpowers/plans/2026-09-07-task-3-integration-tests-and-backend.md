# Task 3: Integration Test Coverage Against Real Auth and Backend Behavior Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Modernize integration test suites to accurately verify authentication states, core feature flows (shelf, routine, journal, scanner, sync) against staging Supabase, isolate headless from device-dependent tests, and establish a pre-release test matrix and checklist.

**Architecture:** Flutter `integration_test` package suite with modular flows (auth, core features, offline-to-online sync); disposable test user/data cleanup; separation between headless-safe and camera/device-dependent suites.

**Tech Stack:** `integration_test`, Flutter, Supabase Flutter, SQLite (`sqflite`).

## Global Constraints
- Returning unauthenticated users must navigate to SignInScreen, never Home.
- Staging test data must be disposable and cleaned up after execution without touching production data.
- Camera and gallery tests requiring hardware must be clearly segmented from headless CI suites.
- Apply ponytail senior dev mode: reuse existing models and viewmodels, keep integration tests concise and deterministic.

---

### Task 3.1: Modernize Launch & Authentication Integration Tests

**Files:**
- Modify: `integration_test/app_flow_test.dart`
- Create: `integration_test/auth_flow_test.dart`

- [ ] **Step 1: Correct returning user launch navigation test**
Update `app_flow_test.dart` so that `has_seen_onboarding: true` with no session routes to `SignInScreen` (not `HomeScreen`), matching actual application logic.

- [ ] **Step 2: Add onboarding and guest navigation test**
Test first run (`has_seen_onboarding: false`) navigating to `OnboardingScreen`, skipping onboarding to reach Home as a guest.

- [ ] **Step 3: Add full auth cycle tests**
Test user sign-up, sign-in, session restoration on app restart, and sign-out resetting state and returning to `SignInScreen`.

- [ ] **Step 4: Verify auth integration tests**
Run: `flutter test integration_test/auth_flow_test.dart` (or headless runner) and verify pass.

- [ ] **Step 5: Commit**
`git commit -m "test(integration): update launch navigation and add full authentication lifecycle tests"`

---

### Task 3.2: Core Features & Offline-to-Online Sync Integration Tests

**Files:**
- Create: `integration_test/core_features_test.dart`
- Create: `integration_test/offline_sync_test.dart`

- [ ] **Step 1: Test Shelf CRUD & Routine Streak persistence**
Verify adding a product to shelf, linking to an AM routine step, marking step complete, and validating streak progression.

- [ ] **Step 2: Test Journal & Photo Logging flow**
Verify creating a journal entry with score and note, checking list/gallery display.

- [ ] **Step 3: Test Scanner OCR flow with mock capture**
Verify scanner screen processing an image feed/sample label and displaying analysis result.

- [ ] **Step 4: Test Offline-to-Online Sync persistence**
Queue offline modifications (add shelf item while offline) -> simulate online reconnect -> trigger `SyncService.syncQueue` -> verify persistence in Supabase staging.

- [ ] **Step 5: Verify test execution and staging cleanup**
Ensure all staging test entities are created with `e2e_test_` prefix and deleted during `tearDownAll`.

- [ ] **Step 6: Commit**
`git commit -m "test(integration): add core feature flows and durable offline sync verification"`

---

### Task 3.3: Pre-Release Smoke Test Matrix & Checklist

**Files:**
- Create: `docs/INTEGRATION_TEST_MATRIX.md`
- Create: `docs/PRE_RELEASE_SMOKE_CHECKLIST.md`

- [ ] **Step 1: Define device and OS support matrix**
Document target platform versions (Android 8.0+ / API 26-34, iOS 14.0-18.0), emulator/simulator configs, and device-dependent test procedures (camera, biometric, push notifications).

- [ ] **Step 2: Create pre-release smoke test checklist**
Provide a step-by-step verification checklist for release candidates (launch, auth, camera scan, offline mode, push reminders, cloud sync).

- [ ] **Step 3: Commit**
`git commit -m "docs: add integration test matrix and pre-release smoke test checklist"`
