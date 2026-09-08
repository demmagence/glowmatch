# Task 2: CI Pipeline and Clean Test Output Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish an automated GitHub Actions CI pipeline, silence platform binding/plugin error noise in passing tests, verify formatting and localization generation, and validate unsigned Android release builds.

**Architecture:** GitHub Actions matrix/jobs with Flutter action caching; test environment bootstrapping for SQLite in-memory fallback and Geolocator mock channels; Gradle release compilation step without signing credentials.

**Tech Stack:** GitHub Actions, Flutter CLI, Dart Analyzer, Gradle.

## Global Constraints
- CI must run on pull requests and pushes targeting `main`.
- Failing formatting, analysis, localization generation, or tests must fail the CI pipeline.
- Test runs must produce clean outputs without repetitive SQLite/Geolocator missing plugin error stacks.
- Release compilation check must run without storing any secrets or signing keys in the repo.
- Apply ponytail senior dev mode: standard GitHub actions, lean test setup, no superfluous tooling.

---

### Task 2.1: Fix HomeScreen Parameter and Silence Test Noise

**Files:**
- Modify: `lib/features/home/home_screen.dart:201`
- Modify: `lib/core/services/database_helper.dart`
- Modify: `lib/core/services/supabase_service.dart`
- Create/Modify: `test/test_helper.dart` (or method channel mock setup for tests)
- Modify: `lib/core/services/weather_service.dart`

- [ ] **Step 1: Fix `home_screen.dart` compiler error**
Restore `onReorder:` parameter on `ReorderableListView.builder` in `home_screen.dart` to resolve the compile error breaking tests and analyzer.

- [ ] **Step 2: Silence SQLite initialization in tests**
In `DatabaseHelper` / `SupabaseService`, when `_useInMemoryFallback` is active (in test environment), avoid calling native `openDatabase` or logging duplicate initialization errors during test runs.

- [ ] **Step 3: Silence Geolocator MissingPluginException in tests**
Provide default test mock channel handler or check test mode in `WeatherService` so expected location fallback does not dump full plugin exception stacks in test output.

- [ ] **Step 4: Run `flutter test` and verify clean output**
Run `flutter test` and verify that all tests pass with 0 failures and without repetitive error noise.

- [ ] **Step 5: Commit**
`git commit -m "fix(test): resolve home_screen parameter error and eliminate test platform plugin noise"`

---

### Task 2.2: GitHub Actions Workflow Definition

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Create workflow with triggers**
Configure triggers for `push` on `main` and `pull_request` on `main`.

- [ ] **Step 2: Add validation job (`lint-and-analyze`)**
  - Checkout repository
  - Set up Java 17 and Flutter with cache enabled
  - Run `flutter pub get`
  - Verify formatting (`dart format --output=none --set-exit-if-changed .`)
  - Verify localization files (`flutter gen-l10n` + check git diff)
  - Run static analysis (`flutter analyze --fatal-infos --fatal-warnings`)

- [ ] **Step 3: Add test job (`unit-and-widget-tests`)**
  - Run `flutter test`

- [ ] **Step 4: Add unsigned release build job (`build-android-release`)**
  - Run `flutter build apk --release` (or `./gradlew assembleRelease` in `android/`) to verify compilation and ProGuard/R8 rules succeed without secret credentials.

- [ ] **Step 5: Commit**
`git commit -m "ci: add github actions workflow for analysis, tests, and unsigned release build"`

---

### Task 2.3: CI Documentation and Maintenance Guide

**Files:**
- Create: `docs/CI_PIPELINE.md`

- [ ] **Step 1: Document CI checks and branch protection rules**
Document the job names (`lint-and-analyze`, `unit-and-widget-tests`, `build-android-release`) required for branch protection.
Document caching strategies and how to update Flutter version pins.

- [ ] **Step 2: Commit**
`git commit -m "docs: add ci pipeline and branch protection documentation"`
