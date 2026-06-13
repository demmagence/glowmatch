# GlowMatch

GlowMatch is a cross-platform skincare management application built with Flutter. It provides tools for routine planning, ingredient safety analysis, product inventory tracking, budget monitoring, and skin condition journaling -- all backed by Supabase for cloud persistence and offline mock fallback.

**Repository:** [github.com/demmagence/glowmatch](https://github.com/demmagence/glowmatch)

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Running the Application](#running-the-application)
- [Testing](#testing)
- [Supabase Configuration](#supabase-configuration)
- [Environment Variables](#environment-variables)
- [Offline Mode](#offline-mode)
- [Contributing](#contributing)
- [License](#license)

---

## Features

### Routine Planner
Separate AM and PM skincare routines with ordered steps. Steps can be linked to products on the shelf. Location-based weather data (via Open-Meteo) is displayed to inform routine adjustments (e.g., SPF reminders on high-temperature days). Routine completion is tracked with a streak system that persists to Supabase.

### Ingredient Scanner
On-device OCR text recognition powered by Google ML Kit extracts ingredient lists from product labels. Extracted text is analyzed for safety, skin type suitability, and recommendations using the Gemini API (`gemini-3.1-flash-lite`). If the Gemini API key is not configured, a local dictionary-based fallback analysis runs automatically.

### Skincare Shelf
A searchable product inventory with category-based filtering. Tracks product name, brand, category, price, estimated total uses, and remaining uses. Product photos can be uploaded to Supabase Storage (`product-photos` bucket). Low-stock indicators are displayed when remaining uses fall below threshold.

### Budget Tracker
Monthly spending overview calculated from shelf product data. Displays category-level spending breakdowns and cost-per-use efficiency metrics. Supports configurable budget limits with alerts when spending approaches or exceeds the limit. Includes a monthly spending history bar chart for trend visualization.

### Skin Progress Journal
Daily skin condition logging with a score (0-100), notes, and photo uploads to Supabase Storage (`journal-photos` bucket). Entries are displayed in a gallery layout. A line chart visualizes score trends over time. A before-and-after comparison screen allows side-by-side review of journal entries.

### Additional Features
- Dark mode support with system-level toggle
- Splash screen and onboarding flow for first-time users
- Profile and settings screen
- Neobrutalist design language with bold borders, offset shadows, and vibrant accent colors

---

## Architecture

GlowMatch follows the **MVVM (Model-View-ViewModel)** pattern with **Provider** for state management and dependency injection.

```
View (Screen/Widget)
    |
    v
ViewModel (ChangeNotifier)
    |
    v
Service Layer (SupabaseService, WeatherService)
```

**Data flow:**
1. Views dispatch user actions to ViewModels.
2. ViewModels process logic, call services, and update state.
3. Views rebuild reactively via `Consumer<T>` or `context.watch<T>()`.
4. Services handle all external I/O (database, storage, network).

No business logic or direct API calls exist in widget files.

---

## Technology Stack

| Technology | Purpose | Version/Package |
| :--- | :--- | :--- |
| Flutter | Cross-platform UI framework | Dart SDK >= 3.11.0 |
| Provider | State management and DI | `provider: ^6.1.2` |
| Supabase | Database, auth, and file storage | `supabase_flutter: ^2.5.4` |
| Google ML Kit | On-device OCR text recognition | `google_mlkit_text_recognition: ^0.12.0` |
| Gemini API | Ingredient safety analysis | `gemini-3.1-flash-lite` |
| Open-Meteo | Weather data (no API key required) | REST API via `http: ^1.2.1` |
| fl_chart | Charts (line chart, bar chart) | `fl_chart: ^0.66.0` |
| Google Fonts | Typography (Outfit font family) | `google_fonts: ^8.1.0` |
| Geolocator | Device location for weather | `geolocator: ^11.0.0` |
| image_picker | Camera and gallery image selection | `image_picker: ^1.1.2` |

---

## Project Structure

```
glowmatch/
  lib/
    main.dart                           # Application entry point
    core/
      constants.dart                    # Enums, table names, bucket names, defaults
      models/
        shelf_item.dart                 # ShelfItem data model
        routine_step.dart               # RoutineStep data model
        journal_entry.dart              # JournalEntry data model
        streak_data.dart                # StreakData data model
        models.dart                     # Barrel export
      services/
        supabase_service.dart           # Supabase database and storage operations
        weather_service.dart            # Location weather via Open-Meteo
      viewmodels/
        auth_viewmodel.dart             # Authentication state
        theme_viewmodel.dart            # Theme mode (light/dark) state
      widgets/
        neobrutalist_card.dart          # Reusable card with neobrutalist styling
        glowmatch_header.dart           # Shared header widget
        error_state_widget.dart         # Error display with retry action
        loading_overlay.dart            # Full-screen loading indicator
    features/
      main_layout.dart                  # Tab navigation shell with bottom bar
      home/
        home_screen.dart                # Dashboard with routines, weather, streaks
        routine_viewmodel.dart          # Routine CRUD and streak logic
      shelf/
        shelf_screen.dart               # Product inventory grid with search
        shelf_viewmodel.dart            # Shelf CRUD, search, photo upload
      budget/
        budget_screen.dart              # Spending overview, charts, alerts
        budget_viewmodel.dart           # Budget calculations, limits, history
      journal/
        journal_screen.dart             # Journal gallery and entry creation
        journal_viewmodel.dart          # Journal CRUD and photo upload
        journal_detail_screen.dart      # Single entry detail view
        journal_compare_screen.dart     # Before-and-after comparison
        journal_chart_widget.dart       # Skin score line chart
      scanner/
        scanner_screen.dart             # OCR camera and analysis results UI
        scanner_viewmodel.dart          # OCR processing and Gemini integration
      onboarding/
        onboarding_screen.dart          # First-time user onboarding flow
      splash/
        splash_screen.dart              # App launch splash screen
      profile/
        profile_screen.dart             # User profile and settings
        profile_viewmodel.dart          # Profile state
  test/
    core/
      services/                         # Service unit tests
      widgets/                          # Widget unit tests
    features/
      budget/                           # Budget viewmodel tests
      home/                             # Home screen, routine, streak tests
      journal/                          # Journal viewmodel tests
      scanner/                          # Scanner viewmodel tests
      shelf/                            # Shelf screen tests
  supabase/
    migrations/                         # SQL migration scripts
  secrets.example.json                  # Environment variable template
  pubspec.yaml                          # Dart/Flutter dependencies
  analysis_options.yaml                 # Lint rules (flutter_lints)
```

---

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK >= 3.11.0)
- Android Studio or Xcode (for platform-specific builds)
- A Supabase project (optional; the app runs in offline mock mode without one)
- A Gemini API key (optional; ingredient analysis falls back to local dictionary matching)

---

## Setup

1. Clone the repository:

    ```bash
    git clone https://github.com/demmagence/glowmatch.git
    cd glowmatch
    ```

2. Create the secrets file:

    ```bash
    cp secrets.example.json secrets.json
    ```

3. Edit `secrets.json` with your credentials:

    ```json
    {
      "SUPABASE_URL": "https://<project-id>.supabase.co",
      "SUPABASE_ANON_KEY": "<your-anon-key>",
      "GEMINI_API_KEY": "<your-gemini-api-key>",
      "GEMINI_MODEL": "gemini-3.1-flash-lite"
    }
    ```

    Leave the default placeholder values to run in offline mock mode.

4. Install dependencies:

    ```bash
    flutter pub get
    ```

---

## Running the Application

```bash
flutter run --dart-define-from-file=secrets.json
```

The `--dart-define-from-file` flag injects environment variables at compile time. The application reads `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GEMINI_API_KEY`, and `GEMINI_MODEL` from this file.

---

## Testing

Run all unit and widget tests:

```bash
flutter test
```

Tests are organized to mirror the `lib/` directory structure under `test/`. The test suite covers services, widgets, viewmodels, and screen-level widget tests.

---

## Supabase Configuration

If using Supabase for cloud persistence, execute the migration scripts in your project's SQL Editor in order:

1. **Initial schema and RLS** -- `supabase/migrations/20260612000000_init_schema_and_rls.sql`
   - Creates `skincare_shelf`, `routines`, and `journal_entries` tables
   - Enables Row Level Security on all tables
   - Creates the `journal-photos` storage bucket with per-user folder policies

2. **Streaks table** -- `supabase/migrations/20260613000000_create_streaks_table.sql`
   - Creates the `user_streaks` table for routine completion tracking

3. **Product photos bucket** -- `supabase/migrations/20260613000001_create_product_photos_bucket.sql`
   - Creates the `product-photos` storage bucket with per-user folder policies

All migrations are idempotent and safe to re-run.

### Database Schema

| Table | Purpose |
| :--- | :--- |
| `skincare_shelf` | Product inventory (name, brand, category, price, uses, ingredients, photo URL) |
| `routines` | AM/PM routine steps with ordering and optional shelf item linkage |
| `journal_entries` | Daily skin condition logs (score, photo, notes) |
| `user_streaks` | Routine completion streak tracking (current, longest, total) |

### Storage Buckets

| Bucket | Purpose |
| :--- | :--- |
| `journal-photos` | Skin progress journal photo uploads |
| `product-photos` | Shelf product photo uploads |

Both buckets enforce per-user folder isolation via RLS policies on `storage.objects`.

---

## Environment Variables

| Variable | Required | Description |
| :--- | :--- | :--- |
| `SUPABASE_URL` | No | Supabase project URL. Defaults to offline mock mode if unset or placeholder. |
| `SUPABASE_ANON_KEY` | No | Supabase anonymous key. Defaults to offline mock mode if unset or placeholder. |
| `GEMINI_API_KEY` | No | Google Gemini API key for ingredient analysis. Falls back to local analysis if unset. |
| `GEMINI_MODEL` | No | Gemini model identifier. Defaults to `gemini-3.1-flash-lite`. |

---

## Offline Mode

GlowMatch is designed to function without any external services. When Supabase credentials are absent or invalid, `SupabaseService` operates with in-memory mock data that is pre-seeded with sample products, routines, and journal entries. When the Gemini API key is absent, the ingredient scanner uses a local dictionary-based analysis engine.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for branch naming conventions, commit message standards, pull request requirements, and code review guidelines.

---

## License

This project is proprietary. All rights reserved.
