# GlowMatch — GitHub Issues

> Assignees: **ALIFKA-HUB**, **wibisanabama**, **Derylfabiensyah**
> Rule: All database-related issues → **Derylfabiensyah**. Distribution: ALIFKA-HUB = 11, wibisanabama = 10, Derylfabiensyah = 10.

---

## 👤 ALIFKA-HUB — 11 Issues

---

### [ISSUE-A01] Simplify Splash Screen — Remove AI-like Intro Animation

**Assignee**: ALIFKA-HUB
**Label**: `ui`, `splash`

**Description**:
The current splash screen looks overly complex and resembles an AI-generated intro, which doesn't match the intended brand feel.

**Expected Behavior**:
- The splash screen should display only the text **"GlowMatch"** in a clean, minimal style.
- The dot/period at the end of "GlowMatch" must be colored **red** (e.g., `Colors.red` or `Color(0xFFE53935)`).
- No animations, no AI-style transitions, no tagline or extra UI elements during splash.
- After a short delay (1–2 seconds), navigate to the appropriate screen (onboarding or main layout).

**Steps to Reproduce**:
1. Launch the app.
2. Observe the current splash screen.

**Acceptance Criteria**:
- [ ] Splash shows only `GlowMatch` text (with red dot) centered on screen.
- [ ] No extra widgets or animations on the splash screen.
- [ ] Transition to next screen is clean and quick.

---

### [ISSUE-A02] Inconsistent AppBar Style Across Pages

**Assignee**: ALIFKA-HUB
**Label**: `ui`, `appbar`

**Description**:
The AppBar styling on the **Budget** and **Journal** pages does not match the style used on the **Home** and **Shelf** pages, causing a visually inconsistent experience.

**Expected Behavior**:
- AppBar on Budget and Journal pages should use the exact same styling (font, size, weight, color, elevation, and `centerTitle`) as the AppBar on Home and Shelf pages.
- This should respect both light and dark theme modes.

**Steps to Reproduce**:
1. Navigate to the Home page → note the AppBar style.
2. Navigate to Budget or Journal page → note the difference.

**Acceptance Criteria**:
- [ ] Budget AppBar matches Home AppBar visually.
- [ ] Journal AppBar matches Home AppBar visually.
- [ ] Both light and dark themes are correct.

---

### [ISSUE-A03] Bottom Navigation Does Not Respond When Tapping Quickly

**Assignee**: ALIFKA-HUB
**Label**: `bug`, `navigation`, `performance`

**Description**:
When the user taps on bottom navigation items quickly (e.g., switching between tabs rapidly), the app sometimes does not navigate to the tapped tab. This is likely caused by heavy widget rebuilds with no debounce or tap-lock mechanism.

**Expected Behavior**:
- Navigation should always respond to user taps, even when switching quickly between tabs.
- If the page is loading, show a loading indicator rather than silently ignoring the tap.

**Steps to Reproduce**:
1. Open the app on main layout.
2. Tap multiple bottom navigation tabs rapidly.
3. Observe that sometimes the page does not change.

**Acceptance Criteria**:
- [ ] Every tap on a nav item reliably changes the active page.
- [ ] Consider adding a debounce or in-progress guard to prevent duplicate navigations.
- [ ] No UI freeze or unresponsive state during tab switching.

---

### [ISSUE-A04] Add Notification Reminder Feature in Settings

**Assignee**: ALIFKA-HUB
**Label**: `feature`, `settings`, `notification`

**Description**:
The Settings page currently has no option for push/local notifications. Users should be able to set daily reminders for their morning (AM) and evening (PM) skincare routines.

**Expected Behavior**:
- Add a "Notifications" section in the Settings/Profile page.
- User can toggle reminder on/off for AM routine and PM routine separately.
- User can select the time for each reminder (time picker).
- Notification is scheduled locally using `flutter_local_notifications` or equivalent.
- Reminders should persist across app restarts (saved via `shared_preferences`).

**Acceptance Criteria**:
- [ ] AM routine reminder toggle + time picker.
- [ ] PM routine reminder toggle + time picker.
- [ ] Notification fires at the correct time even when app is in background.
- [ ] Settings persist after closing and reopening the app.

---

### [ISSUE-A05] Add Password Visibility Toggle on Secure Account Form

**Assignee**: ALIFKA-HUB
**Label**: `ui`, `settings`, `ux`

**Description**:
In the Secure Account section of Settings, the password field does not have a visibility toggle. Users cannot verify what they are typing, which increases the chance of input errors.

**Expected Behavior**:
- Add an eye icon (👁) button on the right side of the password input field.
- Tapping the icon toggles between `obscureText: true` and `obscureText: false`.
- This applies to both the password field and the confirm password field (if present).

**Acceptance Criteria**:
- [ ] Eye icon visible on all password fields in the Secure Account form.
- [ ] Tapping the icon reveals/hides the password text.
- [ ] Icon state updates correctly (open eye / closed eye).

---

### [ISSUE-A06] Implement Swipe-to-Delete for Routine Steps on Home Page

**Assignee**: ALIFKA-HUB
**Label**: `feature`, `home`, `ux`

**Description**:
Currently, deleting a routine step requires navigating into a menu or edit dialog. The UX should be improved by allowing users to swipe a step card to reveal a delete action — similar to standard list patterns (e.g., Flutter's `Dismissible` widget).

**Expected Behavior**:
- Wrap each routine step card in a `Dismissible` widget.
- Swiping left reveals a red delete background with a trash icon.
- A confirmation dialog should appear before permanently deleting the step.
- After deletion, the list updates without a full page reload.

**Acceptance Criteria**:
- [ ] Swipe gesture is smooth and follows the card.
- [ ] Red delete background with trash icon is visible during swipe.
- [ ] Confirmation dialog appears before deletion.
- [ ] Step is removed from the list immediately after confirmation.

---

### [ISSUE-A07] Add Real-Time Clock Display on Home Page

**Assignee**: ALIFKA-HUB
**Label**: `feature`, `home`, `ui`

**Description**:
The Home page does not display the current time. A real-time clock adds context (especially useful alongside the AM/PM routine indicator) and improves the daily-use feel of the app.

**Expected Behavior**:
- Display the current time (HH:mm format) prominently on the Home screen.
- The clock should update every second using a `Timer.periodic`.
- The clock should respect the device locale (12hr or 24hr based on device setting, or default to 24hr).
- Dispose the timer properly in the widget's `dispose()` method to prevent memory leaks.

**Acceptance Criteria**:
- [ ] Real-time clock is visible on the Home page.
- [ ] Time updates every second without any visible flicker.
- [ ] Timer is properly cancelled on widget dispose.

---

### [ISSUE-A08] Remove Skin Score System and Score Table from Journal Page

**Assignee**: ALIFKA-HUB
**Label**: `refactor`, `journal`, `ui`

**Description**:
The Journal page currently displays a skin score and a score-based table/chart at the top of the screen. This feature is considered inaccurate and not useful. It should be removed entirely.

**Expected Behavior**:
- Remove the skin score number display from the Journal header.
- Remove the score table/chart widget below it.
- Clean up all related state and ViewModel logic for `skinScore` if it is no longer used elsewhere.
- The space freed up should be used naturally by the remaining journal content (contribution grid — see ISSUE-D09).

**Acceptance Criteria**:
- [ ] No skin score number visible on the Journal page.
- [ ] No score table or chart visible on the Journal page.
- [ ] No dead/unused score-related UI code remains.

---

### [ISSUE-A09] Remove Skin Score from Journal Compare Screen

**Assignee**: ALIFKA-HUB
**Label**: `refactor`, `journal`

**Description**:
The Journal Compare screen shows a score comparison between two selected journal entries. Since the score system is being removed (ISSUE-A08), the score display in the Compare screen must also be removed.

**Expected Behavior**:
- Remove all score-related UI from `journal_compare_screen.dart`.
- The compare screen should only show photos, dates, and notes side-by-side.
- If `skinScore` is still part of the `JournalEntry` model, it can remain in the model but should not be displayed anywhere in the UI.

**Acceptance Criteria**:
- [ ] No skin score label or value shown in compare screen.
- [ ] Compare screen still functions (photo + notes comparison intact).
- [ ] No broken references from score removal.

---

### [ISSUE-A10] Fix Camera Distortion / Aspect Ratio on Scanner Page

**Assignee**: ALIFKA-HUB
**Label**: `bug`, `scanner`, `camera`

**Description**:
The camera preview on the Scanner page appears distorted (squished/stretched), making it difficult to accurately frame and scan product ingredient text.

**Expected Behavior**:
- The camera preview should maintain the correct aspect ratio (no distortion).
- Use `CameraPreview` with proper `AspectRatio` widget wrapping.
- The preview should fill the screen naturally using `fit: BoxFit.cover` or proper constraints.

**Steps to Reproduce**:
1. Open the Scanner page.
2. Observe that the camera preview looks stretched or squished.

**Acceptance Criteria**:
- [ ] Camera preview is undistorted on common screen sizes.
- [ ] Aspect ratio matches the device's camera sensor ratio.
- [ ] Preview fills the screen cleanly without black bars or stretch.

---

### [ISSUE-A11] Revamp Scanner to Google Lens-Style Text Selection Interaction

**Assignee**: ALIFKA-HUB
**Label**: `feature`, `scanner`, `ux`

**Description**:
The current scanner automatically runs OCR on the entire camera frame and detects everything as ingredients — even when pointing at non-skincare objects. The scanning experience needs a complete UX overhaul to a **Google Lens-style** flow where the user manually selects text before analysis runs.

**Expected Behavior**:
1. User points the camera at a product label.
2. ML Kit detects text blocks and highlights them as tappable overlays on the camera preview.
3. User **manually taps** on the text block they want to analyze.
4. The selected text is passed to an analysis step.
5. The app parses the selected text for ingredient keywords and displays:
   - A list of identified ingredient names.
   - A short description/note for each ingredient (if available).
6. No automatic "detect everything" behavior — user must actively select text first.

**Acceptance Criteria**:
- [ ] Camera shows detected text blocks as selectable overlays on the preview.
- [ ] User taps to select specific text blocks.
- [ ] Analysis only runs on selected text.
- [ ] Output shows ingredient names + brief descriptions.
- [ ] "Save to Shelf" button is removed from the post-scan result screen (see ISSUE-B09).

---

## 👤 wibisanabama — 10 Issues

---

### [ISSUE-B01] Fix Guest Mode: Sign Out Should Navigate to Get Started Screen

**Assignee**: wibisanabama
**Label**: `bug`, `settings`, `auth`

**Description**:
When a user is in guest mode and taps "Sign Out" from the Settings/Profile page, nothing visible happens — the user stays on the same screen. The correct behavior is to navigate back to the onboarding / "Get Started" screen and reset all local state.

**Expected Behavior**:
- Tapping Sign Out while in guest mode clears the local session/state.
- The app navigates to the Onboarding/Get Started screen.
- All local ViewModels should be reset (shelf, journal, routines data cleared from state).

**Acceptance Criteria**:
- [ ] Sign Out in guest mode clears state.
- [ ] App navigates to OnboardingScreen after sign out.
- [ ] No stale data remains visible after sign out.

---

### [ISSUE-B02] Remove "Smart Alert" Feature from Budget Page

**Assignee**: wibisanabama
**Label**: `refactor`, `budget`

**Description**:
The Smart Alert section on the Budget page is not relevant to the core functionality and should be removed to simplify the UI.

**Expected Behavior**:
- Remove the Smart Alert widget/section entirely from `budget_screen.dart`.
- Remove any related logic from `budget_viewmodel.dart` if it exists solely for this feature.
- The rest of the Budget page (allocation chart, spending history) remains intact.

**Acceptance Criteria**:
- [ ] No Smart Alert UI visible on Budget page.
- [ ] No orphaned alert logic remains in the ViewModel.

---

### [ISSUE-B03] Revise Budget Page: Monthly Spend Based on Product Add Date with Period Filter

**Assignee**: wibisanabama
**Label**: `feature`, `budget`, `ui`

**Description**:
The "Monthly Spend" metric on the Budget page currently uses incorrect logic. It should be based on **when products were added to the shelf** (`created_at` date), not on product consumption. The user should also be able to filter by different time periods.

**Expected Behavior**:
- Monthly spend = sum of `price` of all shelf items added within the selected time period.
- Add a filter/toggle with three options:
  - **30 days** (default)
  - **90 days**
  - **All time**
- The total spend displayed updates dynamically when the filter changes.
- No spending "limit" field — remove it if present.

**Acceptance Criteria**:
- [ ] Spend calculation uses product add date, not usage count.
- [ ] 30 / 90 / All-time filter toggles work correctly.
- [ ] Spending limit input removed (if any).
- [ ] Total updates when filter is changed.

---

### [ISSUE-B04] Remove Usage Estimation Indicator from Shelf Product Cards

**Assignee**: wibisanabama
**Label**: `refactor`, `shelf`, `ui`

**Description**:
Each product card on the Shelf page shows a `x/x left` usage indicator (remaining uses / estimated uses). Since the usage tracking feature is being removed, this indicator should be deleted from the UI.

**Expected Behavior**:
- Remove the `remainingUses / estimatedUses` indicator text from all product cards.
- Remove any progress bar that visualizes remaining usage.
- The product card should still show: name, brand, category, and price.

**Acceptance Criteria**:
- [ ] No usage indicator on shelf product cards.
- [ ] No usage progress bar on shelf product cards.
- [ ] Card layout looks clean without the removed elements.

---

### [ISSUE-B05] Replace "Estimated Uses" with "Product Size" Field in Add/Edit Product Form

**Assignee**: wibisanabama
**Label**: `feature`, `shelf`, `ui`

**Description**:
The Add/Edit product form currently has an "Estimated Uses" input field. This is being removed and replaced with a **"Product Size"** field (e.g., `30ml`, `50g`, `100ml`).

**Expected Behavior**:
- Remove the `estimatedUses` input field from the Add Product and Edit Product forms.
- Add a new text field: **"Product Size"** (free text input).
- The field should have a placeholder: `e.g. 30ml, 50g, 100ml`.
- This value is stored with the product (see ISSUE-D07 for DB schema change).

**Acceptance Criteria**:
- [ ] `estimatedUses` field removed from Add/Edit form.
- [ ] New `productSize` text field added with correct placeholder.
- [ ] Value saves and displays correctly in product detail.

---

### [ISSUE-B06] Remove "Use Product" Button from Shelf Product Bottom Sheet

**Assignee**: wibisanabama
**Label**: `refactor`, `shelf`, `ui`

**Description**:
The product detail bottom sheet on the Shelf page has a "Use Product" button that decrements the `remainingUses` counter. Since the usage tracking system is being removed, this button should be deleted from the UI.

**Expected Behavior**:
- Remove the "Use Product" button from the bottom sheet entirely.
- Remove any call to `decrementShelfItemUses` from the UI layer.
- The bottom sheet should still show: product details, edit, and delete options.

**Acceptance Criteria**:
- [ ] No "Use Product" button visible in the product detail bottom sheet.
- [ ] `decrementShelfItemUses` is no longer called from the UI layer.

---

### [ISSUE-B07] Add Placeholder Text to All Fields in Add/Edit Product Form

**Assignee**: wibisanabama
**Label**: `ux`, `shelf`

**Description**:
The Add/Edit product form fields currently have no hint/placeholder text, making it unclear what format or value the user should enter in each field.

**Expected Behavior**:
Add clear, descriptive `hintText` to every input field in the form:

| Field | Placeholder |
|---|---|
| Product Name | `e.g. Moisture Surge Intense` |
| Brand | `e.g. Clinique` |
| Category | `Select a category` |
| Price | `e.g. 150000` |
| Product Size | `e.g. 30ml, 50g` |
| Ingredients | `e.g. Niacinamide, Hyaluronic Acid, Ceramide` |

**Acceptance Criteria**:
- [ ] All form fields have a visible `hintText`.
- [ ] Placeholder text disappears when user starts typing.
- [ ] Placeholders are concise and helpful.

---

### [ISSUE-B08] Display Price in Rupiah (IDR) Format on Shelf

**Assignee**: wibisanabama
**Label**: `feature`, `shelf`, `ui`

**Description**:
Product prices on the Shelf page are currently displayed in a generic number format without a currency symbol. The default currency should be **Indonesian Rupiah (IDR / Rp)**, formatted correctly.

**Expected Behavior**:
- Display prices as: `Rp 150.000` (following IDR formatting convention with `.` as thousands separator).
- This applies to: product cards, product detail bottom sheet, and the Add/Edit form preview.
- Use `NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)` from the `intl` package.
- Currency symbol and formatting should update if the user changes currency in Settings (see ISSUE-D05).

**Acceptance Criteria**:
- [ ] All price displays on Shelf use IDR format by default.
- [ ] Formatting is consistent (thousands separator, no unnecessary decimals for IDR).
- [ ] `intl` package used for number formatting.

---

### [ISSUE-B09] Remove "Save to Shelf" Button from Scanner Result Screen

**Assignee**: wibisanabama
**Label**: `refactor`, `scanner`

**Description**:
After scanning a product, the result screen shows a "Save to Shelf" button that pre-fills the Shelf form with scanned ingredients. This button should be removed as the scanner flow is being redesigned (see ISSUE-A11).

**Expected Behavior**:
- Remove the "Save to Shelf" button from the post-scan result view entirely.
- The scanner result screen should only display the identified ingredients and their descriptions as read-only output.
- User navigates to Shelf manually if they want to add a product.

**Acceptance Criteria**:
- [ ] No "Save to Shelf" button on the scanner result screen.
- [ ] Ingredients list is still displayed as read-only output.
- [ ] Removing the button does not cause any errors or broken navigation.

---

### [ISSUE-B10] Fix False Positive Ingredient Detection on Scanner

**Assignee**: wibisanabama
**Label**: `bug`, `scanner`

**Description**:
The scanner currently detects "skincare ingredients" even when the camera is pointed at a random object with no ingredient-related text. The detection logic is too permissive and produces frequent false positives.

**Expected Behavior**:
- Only flag text as an ingredient if it **matches against a curated known-ingredient keyword list** (e.g., Niacinamide, Hyaluronic Acid, Retinol, Ceramide, Glycerin, Salicylic Acid, etc.).
- If no recognizable ingredient keywords are found, show a clear message: `"No skincare ingredients detected. Try scanning an ingredient list on a product label."`
- Apply a minimum text block length/confidence threshold to filter out noise.

**Acceptance Criteria**:
- [ ] Scanning a random object with no ingredient text returns a "no ingredient found" message.
- [ ] Only known ingredient keywords are highlighted/reported in results.
- [ ] Minimum confidence or text-length filtering is applied to reduce noise.

---

## 👤 Derylfabiensyah — 10 Issues

---

### [ISSUE-D01] Overhaul Authentication: Replace Magic Link with Sign In / Sign Up System

**Assignee**: Derylfabiensyah
**Label**: `feature`, `auth`, `database`

**Description**:
The current "Secure Account" flow uses an email magic link approach. This needs to be replaced with a full **email + password Sign In / Sign Up** system. User data must be persisted in Supabase and the session must survive app restarts.

**Expected Behavior**:
- Replace magic link flow with standard email/password auth using `signUp` and `signInWithPassword` from `supabase_flutter`.
- Add a **Sign Up** screen: email, password, confirm password fields.
- Add a **Sign In** screen: email, password fields.
- On successful login, the session persists across app restarts (Supabase handles this via local storage).
- The Onboarding/Get Started screen routes to Sign In or Sign Up.
- On sign out (from settings), clear the session and navigate back to Get Started.

**Database Changes**:
- Verify `auth.users` table is correctly configured in the Supabase project.
- All existing tables (`skincare_shelf`, `routines`, `journal_entries`, `user_streaks`) must use the authenticated `user_id` from `auth.uid()`.
- Update all RLS policies to use `auth.uid()` where not already done.

**Acceptance Criteria**:
- [ ] Sign Up screen works with email + password.
- [ ] Sign In screen works with email + password.
- [ ] Session persists after app restart (user stays logged in).
- [ ] All user data in DB is scoped to `auth.uid()`.
- [ ] Sign Out clears session and navigates to onboarding.
- [ ] Error messages shown for: invalid credentials, weak password, email already taken.

---

### [ISSUE-D02] Persist Routine Completion State to Database

**Assignee**: Derylfabiensyah
**Label**: `bug`, `database`, `home`

**Description**:
When a user marks their routine steps as complete, the completion state is not saved to the database. After re-login or app restart, all steps appear uncompleted again. This also breaks the streak tracking system.

**Expected Behavior**:
- When a step is marked complete, save the event to DB with a `completed_date` = today's date and `user_id`.
- On app load, fetch today's completions and restore the UI state (checkmarks, greyed-out cards).
- At the start of each new calendar day, completion state resets automatically.
- Completing all steps of a routine (AM or PM) triggers `recordRoutineCompletion` exactly once per day.

**Database Changes**:
- Create a new `routine_completions` table:
  ```sql
  CREATE TABLE routine_completions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    routine_step_id TEXT NOT NULL,
    routine_type TEXT NOT NULL,
    completed_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, routine_step_id, completed_date)
  );
  ```
- Add RLS policies: users can only CRUD their own rows.
- Add CRUD methods to `SupabaseService` for routine completions.

**Acceptance Criteria**:
- [ ] Completing a routine step saves to the `routine_completions` table.
- [ ] On app relaunch, today's completed steps are restored visually (checkmarks + grey cards).
- [ ] Completion state resets at the start of a new calendar day.
- [ ] Completing all steps triggers the streak counter correctly once per day.

---

### [ISSUE-D03] Add Streak History and Detailed Stats to Home Page

**Assignee**: Derylfabiensyah
**Label**: `feature`, `database`, `home`

**Description**:
The streak system currently only shows the current streak count with no historical data. Users need to see full streak history — past streaks, total completions, and a 30-day log.

**Expected Behavior**:
- Add a "Streak History" section or accessible modal from the Home page.
- Display:
  - **Current streak** (days in a row).
  - **Longest streak** (all-time record).
  - **Total routine completions** (all-time count).
  - **Last 30 days**: a visual day-by-day indicator (e.g., dots/icons) showing which days had completions.
  - **Previous streaks**: list of past streaks with start and end dates, and the streak length.

**Database Changes**:
- Create a `daily_completion_log` table:
  ```sql
  CREATE TABLE daily_completion_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    completed_date DATE NOT NULL,
    streak_count INT NOT NULL,
    UNIQUE(user_id, completed_date)
  );
  ```
- Update `recordRoutineCompletion` to also insert into `daily_completion_log`.
- Add a query method to fetch the last 30 days and historical streak segments.
- Add RLS policies for the new table.

**Acceptance Criteria**:
- [ ] Streak history screen/modal shows current streak, longest streak, total completions.
- [ ] Last 30 days of completions are shown visually day-by-day.
- [ ] Previous (broken) streaks are listed with start/end dates and length.
- [ ] All data persists and loads correctly from DB.

---

### [ISSUE-D04] Fix Spending History: Base Calculation on Product Add Date

**Assignee**: Derylfabiensyah
**Label**: `bug`, `database`, `budget`

**Description**:
The Spending History section on the Budget page incorrectly calculates spending. It should be based on **when products were added to the shelf** (`created_at`), not on consumption events.

**Expected Behavior**:
- Spending = sum of `price` of all shelf items added within the selected time period (30 / 90 / all-time).
- Group spending by month for the history list.
- Each product added to the shelf in a given month counts toward that month's spending.
- Query is fetched from Supabase using `created_at` column on `skincare_shelf`.

**Database Changes**:
- Verify `created_at` column exists and is populated correctly in `skincare_shelf`.
- Write a Supabase query that sums `price` grouped by month/period for a given `user_id`.
- Update `BudgetViewModel` and `SupabaseService` to use the corrected query.

**Acceptance Criteria**:
- [ ] Spending amounts reflect the product add date, not usage events.
- [ ] Monthly grouping works correctly.
- [ ] Period filter (30 / 90 / all-time) returns correct totals.
- [ ] Data loads from DB (not mocked).

---

### [ISSUE-D05] Add Multi-Currency Support with Exchange Rate API Integration

**Assignee**: Derylfabiensyah
**Label**: `feature`, `database`, `settings`

**Description**:
The app should support multiple currencies. Users can select their preferred currency from Settings, and all price displays across the app (Shelf, Budget) update accordingly using a live exchange rate API.

**Expected Behavior**:
- Add a "Currency" dropdown in the App Settings section.
- Options: at least IDR, USD, EUR, SGD, MYR, JPY, GBP, AUD (8+ currencies).
- On currency change, fetch the latest exchange rate (e.g., from `https://open.er-api.com/v6/latest/IDR`).
- Apply the conversion rate to all displayed prices across Shelf and Budget.
- Store the selected currency code in `shared_preferences`.
- Cache exchange rates locally for 24 hours to avoid redundant API calls.

**Implementation Notes**:
- Prices are stored in DB as IDR (base currency — no schema change needed).
- Implement a `CurrencyService` singleton:
  - `fetchRates()` → fetch and cache exchange rates.
  - `convert(double amountIDR, String targetCurrency) → double`.
- Expose selected currency via a new `CurrencyViewModel` (extend or separate from `ThemeViewModel`).

**Acceptance Criteria**:
- [ ] Currency selector in Settings with at least 8 currency options.
- [ ] All price displays update immediately when currency is changed.
- [ ] Exchange rates are fetched from a real live API.
- [ ] Rates are cached locally for 24 hours.
- [ ] Selected currency persists after app restart.

---

### [ISSUE-D06] Implement CRUD for Custom Skincare Product Categories

**Assignee**: Derylfabiensyah
**Label**: `feature`, `database`, `shelf`

**Description**:
Skincare product categories are currently hardcoded in the `SkincareCategory` enum. Users should be able to create, view, rename, and delete their own custom categories.

**Expected Behavior**:
- Add a "Manage Categories" screen accessible from Shelf page or Settings.
- Displays default categories + any custom categories the user has created.
- User can:
  - **Create** a new category with a name and optional color.
  - **Rename** an existing custom category.
  - **Delete** a custom category (with warning if products are using it).
- The category dropdown in Add/Edit product form pulls from both default and custom categories.

**Database Changes**:
```sql
CREATE TABLE skincare_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  color TEXT NOT NULL DEFAULT '0xFFE040FB',
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```
- Add RLS policies: users can only CRUD their own rows.
- Seed default categories via migration with `is_default = TRUE`.
- Add CRUD methods to `SupabaseService` for categories.

**Acceptance Criteria**:
- [ ] User can create a new category with a name and color.
- [ ] User can rename an existing custom category.
- [ ] User can delete a custom category (with in-use warning).
- [ ] Category dropdown in Add/Edit product form shows all categories.
- [ ] Default categories are always visible and cannot be deleted.

---

### [ISSUE-D07] Add "Product Size" Field and "Date Added" Display to Shelf Schema

**Assignee**: Derylfabiensyah
**Label**: `database`, `shelf`

**Description**:
Two schema updates are required for the Shelf feature: add a `product_size` field, and ensure `created_at` is surfaced as a "Date Added" label in the product detail view. The old `estimated_uses` / `remaining_uses` fields are deprecated.

**Expected Behavior**:
- Add `product_size TEXT` column to `skincare_shelf` table.
- In the product detail view, display **"Date Added"** using the `created_at` timestamp formatted as a readable date (e.g., `June 15, 2026`).
- `estimated_uses` and `remaining_uses` columns can remain in the DB for backward compatibility but are no longer written to from new app versions.

**Database Changes**:
```sql
ALTER TABLE skincare_shelf ADD COLUMN IF NOT EXISTS product_size TEXT;
```
- Update `ShelfItem` model: add `productSize` field, update `fromJson` / `toJson` / `copyWith`.
- Update `SupabaseService.addShelfItem` and `updateShelfItem` to include `product_size`.
- Display `created_at` as "Date Added" in the product detail bottom sheet.

**Acceptance Criteria**:
- [ ] `product_size` column exists in Supabase `skincare_shelf` table.
- [ ] `ShelfItem` model includes `productSize` field.
- [ ] "Product Size" value displays in product detail view.
- [ ] "Date Added" (from `created_at`) displays in product detail in human-readable format.
- [ ] Old `estimated_uses` data is not broken (nullable / backward-compatible).

---

### [ISSUE-D08] Fix Routine Completion Not Triggering Streak Correctly After Re-login

**Assignee**: Derylfabiensyah
**Label**: `bug`, `database`, `home`

**Description**:
Even when a user completes their routine, the streak counter does not increment correctly — especially after re-login. The streak calculation logic and DB persistence need to be aligned.

**Expected Behavior**:
- Streak increments only **once per day**, not multiple times per session.
- `recordRoutineCompletion` is called only when **all steps** of a routine are marked complete for that day.
- `lastCompletedDate` in `user_streaks` must be accurately read from DB on app start (not from mock).
- If the user logs in after midnight (new day), streak logic correctly continues or breaks based on date comparison.

**Database Changes**:
- Verify `user_streaks.last_completed_date` is stored as `DATE` or `TIMESTAMPTZ`.
- Ensure the upsert in `recordRoutineCompletion` uses `onConflict: 'user_id'` correctly.
- Verify RLS policy allows the authenticated user to read and update only their own streak row.

**Acceptance Criteria**:
- [ ] Completing all routine steps triggers `recordRoutineCompletion` exactly once per day.
- [ ] Streak increments correctly across multiple logins on the same day.
- [ ] Streak breaks correctly when the user misses a day.
- [ ] Streak data loads from DB correctly on app start (not from mock/hardcoded values).

---

### [ISSUE-D09] Add GitHub-Style Daily Contribution Grid to Journal Page

**Assignee**: Derylfabiensyah
**Label**: `feature`, `journal`, `database`

**Description**:
As a replacement for the removed skin score system (see ISSUE-A08), add a **GitHub-style contribution heatmap** to the Journal page. Each day is represented by a small colored square based on whether the user logged a journal entry that day.

**Expected Behavior**:
- Display a scrollable grid of day squares (like GitHub's contribution graph).
- Each square represents one calendar day.
- Square is **colored** (e.g., pink/green gradient based on recency) if a journal entry exists for that day.
- Square is **grey/empty** if no entry exists.
- Tapping a colored square navigates to that journal entry's detail screen.
- Show at minimum the last **12 weeks (84 days)** of history, scrollable horizontally.
- Display month labels above the corresponding week columns.
- Journal entry dates must be fetched from the real `journal_entries` DB table (`logged_date` column).

**Database Changes**:
- Ensure `logged_date` in `journal_entries` is stored as a proper `DATE` type (or parseable date string).
- Add a query method in `SupabaseService` to fetch journal entry dates for the last N days:
  ```dart
  Future<List<DateTime>> getJournalDates(String userId, {int days = 84})
  ```
- Update `JournalViewModel` to expose the list of dated entries for the grid widget.

**Acceptance Criteria**:
- [ ] Contribution grid renders correctly with day squares.
- [ ] Days with journal entries are visually distinct (colored) from empty days (grey).
- [ ] Tapping a colored square opens the corresponding journal entry detail.
- [ ] Grid scrolls horizontally if content overflows.
- [ ] Grid data is sourced from real DB entries, not mock data.
- [ ] Month labels are displayed correctly above columns.

---

### [ISSUE-D10] Completed Routine Step Cards Should Show Checkmark and Grey State

**Assignee**: Derylfabiensyah
**Label**: `ui`, `database`, `home`

**Description**:
When the user marks a routine step as complete, the card does not visually change. There is no checkmark or greyed-out appearance, making it unclear which steps have been done. This visual state must also be driven by the DB persistence layer (see ISSUE-D02).

**Expected Behavior**:
- When a step is marked as complete, the card should:
  - Show a green checkmark icon.
  - Apply a grey overlay or reduced opacity (`0.5`) to the card content.
  - Show muted/strikethrough text for the step name and description.
- The visual state is restored on app relaunch from the `routine_completions` table (linked to ISSUE-D02).
- Tapping the checkmark again can un-complete a step (toggle — also removes DB record for that step + date).
- All steps greyed out = entire routine section shows as "Completed" with a summary state.

**Implementation Notes**:
- The UI changes (checkmark, grey card, muted text) are purely widget-level but must read completion state from `RoutineViewModel`, which fetches from DB.
- Works in conjunction with ISSUE-D02 (DB persistence) — both should be completed together or D02 first.

**Acceptance Criteria**:
- [ ] Completed step card shows a visible green checkmark icon.
- [ ] Completed step card appears greyed-out / muted opacity.
- [ ] Step name and description text appear muted or struck-through.
- [ ] Tapping checkmark toggles the completion state (UI + DB).
- [ ] State is restored correctly from DB on app relaunch.
- [ ] When all steps are complete, a "Routine Complete" summary state is shown.
