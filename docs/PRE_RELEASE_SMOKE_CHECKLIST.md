# GlowMatch Pre-Release Smoke Test Checklist

A comprehensive, repeatable verification checklist to execute on staging builds or release candidate artifacts prior to store submission.

---

## Pre-Requisites & Test Environment

- **Build Type:** Release Candidate (Signed or Unsigned staging build)
- **Target Devices:** Physical Android device (API 28+), Physical iOS device or Simulator (iOS 15+)
- **Backend Environment:** Supabase Staging project with clean test buckets (`product-photos`, `journal-photos`)
- **Network Modes:** WiFi, Cellular Data, Airplane Mode (Offline)

---

## Step-by-Step Verification Checklist

### 1. Fresh Install & First-Time Onboarding
- [ ] Install fresh build on device without cached app data.
- [ ] Launch application: Splash screen animates cleanly with `GlowMatch.` logo.
- [ ] Onboarding screen appears with 3 informative slides.
- [ ] Swiping through slides updates dot indicators.
- [ ] Tapping "Skip" or "Get Started" navigates into the main app shell as a Guest.

### 2. Returning Unauthenticated User Flow
- [ ] Mark onboarding as completed without an active logged-in session.
- [ ] Force-close and re-launch application.
- [ ] **Acceptance Criterion Check:** Splash screen routes user directly to **Sign In Screen** (NOT to Home).
- [ ] "Sign In", "Sign Up", and "Continue as Guest" buttons are all visible and functional.

### 3. Authentication & Session Restoration
- [ ] Create a new account with email & password via Sign Up screen.
- [ ] Verify immediate redirect to MainLayout upon successful registration.
- [ ] Terminate and restart the application: Session is restored automatically without prompting for login.
- [ ] Navigate to Profile > tap "Sign Out": User is logged out, local state is reset, and app returns to Sign In.

### 4. Skincare Shelf & Inventory Tracking
- [ ] Tap Shelf tab: Pre-seeded default categories (Serum, Sunscreen, Moisturizer, etc.) appear.
- [ ] Tap "+ Add Product": Enter name, brand, category, price, and estimated uses.
- [ ] Save product: New item immediately appears on shelf with correct category accent color.
- [ ] Tap product card: Decrement remaining uses; verify usage counter updates.
- [ ] Filter by category: Only products in selected category are displayed.

### 5. Routine Planner & Streak Progression
- [ ] Tap Home tab: Routine steps for morning (AM) and evening (PM) are visible.
- [ ] Tap checkbox to complete a routine step: Checkbox updates with check animation.
- [ ] Complete all steps for the day: Streak count increments and persists.
- [ ] Open Streak History bottom sheet: Completion dot reflects today's date in calendar.

### 6. Skin Progress Journal
- [ ] Tap Journal tab: Current skin score and score trend line chart render.
- [ ] Tap "LOG PROGRESS": Enter skin score (0–100), notes, and attach photo.
- [ ] Save entry: Gallery updates with new date card.
- [ ] Open Before & After comparison screen: Select two entries and verify side-by-side photo comparison.

### 7. Ingredient Scanner (OCR & Safety Analysis)
- [ ] Tap Scanner button in bottom navigation.
- [ ] System camera permission prompt appears; grant permission.
- [ ] Point camera at skincare ingredient label: Text blocks are detected on-screen.
- [ ] Tap analyze: Gemini analysis (or local dictionary fallback) breaks down active ingredients with safety ratings.

### 8. Offline-to-Online Data Persistence & Sync
- [ ] Enable Airplane Mode (turn off WiFi & Mobile Data).
- [ ] Add a new shelf item while offline.
- [ ] Restart app while still offline: Offline item remains in local SQLite cache.
- [ ] Disable Airplane Mode (reconnect to internet).
- [ ] App automatically synchronizes pending queue to Supabase staging; verify item appears in database.

### 9. Settings & Localization
- [ ] Navigate to Profile:
  - Toggle Dark Mode: Theme switches smoothly between light and dark neobrutalist schemes.
  - Switch Language to Indonesian (ID): Interface strings update immediately.
  - Switch Language to English (EN): Interface strings restore to English.

### 10. Automated Staging Backend Verification
- [ ] Staging secrets present in environment or `secrets.json` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, optional `SUPABASE_TEST_EMAIL` / `SUPABASE_TEST_PASSWORD`).
- [ ] Execute authenticated staging integration test:
  ```bash
  flutter test integration_test/staging_authenticated_flow_test.dart -d <device_id> --dart-define-from-file=secrets.json
  ```
- [ ] Verify test suite asserts real Supabase auth session, remote CRUD operations on `skincare_shelf`, and offline queue synchronization.
- [ ] Verify disposable test data (`e2e_*`) is completely torn down upon test completion.
- [ ] Verify failure assertion: Executing without secrets fails fast with descriptive `TestFailure` message.

---

## Release Evidence Sign-off

| Field | Details |
| :--- | :--- |
| **Release Candidate Version** | `v0.1.0+1` (or target release tag) |
| **Tested Platforms** | Android (Model / OS: __________) / iOS (Model / OS: __________) |
| **Backend Integration Suite** | [ ] PASS (Authenticated Staging Flow + Teardown) / [ ] SKIPPED |
| **Test Date** | ____________________ |
| **Lead QA / Tester Name** | ____________________ |
| **Result** | [ ] PASS / [ ] FAIL / [ ] BLOCKER IDENTIFIED |
| **Notes / Exceptions** | ________________________________________________ |
