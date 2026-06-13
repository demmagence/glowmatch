# Contributing to GlowMatch

This document defines the standards and processes for contributing to GlowMatch. All contributors must follow these guidelines.

---

## Table of Contents

- [Branch Naming](#branch-naming)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Code Review Criteria](#code-review-criteria)
- [Architecture Constraints](#architecture-constraints)
- [Testing Requirements](#testing-requirements)
- [Style and Formatting](#style-and-formatting)

---

## Branch Naming

All work must be done on branches created from `main`. Branch names must use the following format:

```
<type>/<short-description-in-kebab-case>
```

### Allowed Prefixes

| Prefix | Usage |
| :--- | :--- |
| `feat/` | New feature implementation |
| `fix/` | Bug fix |
| `chore/` | Maintenance, dependency updates, configuration changes |
| `refactor/` | Code restructuring with no functional change |
| `test/` | Adding or modifying tests |
| `docs/` | Documentation-only changes |

### Examples

- `feat/ocr-scanner-camera`
- `fix/auth-token-refresh`
- `chore/bump-provider-version`
- `refactor/budget-calculation`
- `test/scanner-viewmodel`
- `docs/update-contributing-guide`

---

## Commit Messages

This project follows the [Conventional Commits](https://www.conventionalcommits.org/) specification.

### Format

```
<type>(<scope>): <subject>
```

- **type**: One of `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.
- **scope**: The feature area or module affected (e.g., `shelf`, `budget`, `scanner`, `journal`, `home`, `core`).
- **subject**: A concise, lowercase description of the change. Do not end with a period.

### Type Definitions

| Type | Description |
| :--- | :--- |
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation-only changes |
| `style` | Code formatting (whitespace, indentation, semicolons); no logic changes |
| `refactor` | Code restructuring without adding features or fixing bugs |
| `test` | Adding or correcting tests |
| `chore` | Dependency updates, build configuration, tooling |

### Examples

```
feat(scanner): integrate camera source with google ml kit text recognition
fix(shelf): clamp remaining uses at zero during decrement
test(budget): add comprehensive viewmodel calculation unit tests
docs(readme): rewrite setup instructions for clarity
chore(deps): update supabase_flutter to 2.5.4
```

---

## Pull Request Process

### Before Opening a PR

1. Rebase your branch onto the latest `main`:

    ```bash
    git fetch origin
    git rebase origin/main
    ```

2. Run all tests and confirm they pass:

    ```bash
    flutter test
    ```

3. Run static analysis and confirm zero issues:

    ```bash
    flutter analyze
    ```

4. Clean up commit history. Squash or rebase to remove fixup, WIP, and merge commits.

### PR Description Requirements

- Provide a clear summary of what the PR changes and why.
- Reference the related GitHub issue number (e.g., `Closes #42`).
- If the PR includes visual changes, attach before/after screenshots.
- List any breaking changes or migration steps required.

### Review and Merge

- All PRs require at least one approving review before merge.
- Address all review comments before requesting re-review.
- Use "Squash and merge" as the default merge strategy to maintain a clean history on `main`.

---

## Code Review Criteria

Reviewers must verify the following:

### MVVM Compliance

- No business logic in widget files. All logic resides in ViewModels or Services.
- Widgets access state exclusively through `Consumer<T>`, `context.watch<T>()`, or `context.read<T>()`.
- ViewModels do not import widget or UI packages (`package:flutter/material.dart` is not permitted in ViewModels; use `package:flutter/foundation.dart` for `ChangeNotifier` and `debugPrint`).

### State Management

- `notifyListeners()` is called only when observable state actually changes.
- Mutable state fields are private. Public access is through read-only getters.
- Derived state is computed in getters, not stored as separate fields that could desynchronize.

### Error Handling

- All database, storage, and network calls are wrapped in `try-catch` blocks.
- Failures produce meaningful fallback values or user-visible error states.
- Errors are logged via `debugPrint`, not silently swallowed.

### Naming Conventions

- Classes: `PascalCase`
- Variables and functions: `camelCase`
- Files: `snake_case.dart`
- Constants: `camelCase` (Dart convention)
- Enum values: `camelCase`

---

## Architecture Constraints

These constraints are non-negotiable. PRs that violate them will be rejected.

1. **Service layer isolation.** All Supabase and external API calls go through `SupabaseService` or dedicated service classes. ViewModels and widgets never make direct HTTP or database calls.

2. **Provider for state management.** Do not introduce additional state management libraries (Riverpod, Bloc, GetX, etc.) without prior team approval.

3. **Feature-based directory structure.** Each feature has its own directory under `lib/features/` containing its screen(s) and viewmodel(s). Shared code goes under `lib/core/`.

4. **Offline-first resilience.** All features must function in offline mock mode when Supabase credentials are absent. New features that require external services must include a mock fallback path.

---

## Testing Requirements

- Every new ViewModel method must have a corresponding unit test.
- Every new Service method must have a corresponding unit test.
- Widget tests are required for new screens or significant UI changes.
- Tests must mirror the `lib/` directory structure under `test/`.
- All tests must pass before a PR can be merged.
- When testing against `SupabaseService`, initialize with mock/offline credentials to prevent service binding errors:

    ```dart
    final supabaseService = SupabaseService();
    await supabaseService.initialize(
      url: 'https://mock.supabase.co',
      anonKey: 'mock-key',
    );
    ```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests for a specific feature
flutter test test/features/shelf/

# Run a specific test file
flutter test test/features/budget/budget_viewmodel_test.dart
```

---

## Style and Formatting

- Lint rules are defined in `analysis_options.yaml` using `flutter_lints`.
- Run `flutter analyze` before committing. Zero warnings and zero errors are required.
- Use `Outfit` (via `google_fonts`) as the primary font family. Do not introduce additional fonts without approval.
- Follow the neobrutalist design language: bold borders (2-4px), offset shadows, high-contrast colors. Refer to `NeobrutalistCard` in `lib/core/widgets/` as the reference implementation.
- Use the `SkincareCategory` enum from `lib/core/constants.dart` for all category references. Do not use raw strings for categories.
- Use constants from `AppConstants` for table names, bucket names, and default values. Do not hardcode these strings.
