# Contributing to GlowMatch 🤝

We welcome contributions to GlowMatch! Please review this document to understand our branch structure, commit standards, Pull Request requirements, and code review guidelines.

---

## 🗺️ Branch Naming Conventions

All active development must happen on dedicated branches branched off of `main`. Use the following prefixes for branch names:

*   `feat/` - Introduce a new feature (e.g., `feat/ocr-scanner-camera`)
*   `fix/` - Fix a bug or issue (e.g., `fix/auth-token-refresh`)
*   `chore/` - Maintenance tasks, dependency updates, configuration changes (e.g., `chore/bump-provider-version`)
*   `refactor/` - Refactoring existing code with no functional changes (e.g., `refactor/budget-calculation`)
*   `test/` - Adding new unit/widget tests or fixing tests (e.g., `test/scanner-viewmodel`)
*   `docs/` - Documentation-only changes (e.g., `docs/update-contributing-guide`)

Format: `<type>/<short-description-kebab-case>`

---

## 📥 Pull Request Checklist

Before opening a Pull Request (PR), make sure your branch passes the following checklist:

- [ ] **Tests Pass**: Run `flutter test` locally. Ensure that all unit/widget tests run successfully and exit with status code 0.
- [ ] **No Lint Warnings**: Run `flutter analyze`. There should be zero compilation warnings, info alerts, or code health errors based on our `analysis_options.yaml`.
- [ ] **UI Screenshots**: If your PR makes visual adjustments to the interface, attach before/after screenshots or GIFs to the PR description.
- [ ] **Clean Git History**: Rebase or clean up your commits before submitting, ensuring no redundant merge commits from upstream.
- [ ] **Documentation**: Ensure public API comments and README sections are updated if new features or variables are introduced.

---

## 🔍 Code Review Guidelines

When reviewing PRs or preparing code for review, look out for:

1.  **MVVM Pattern Enforcement**:
    *   No business logic or direct API/Supabase calls in widget files. Everything goes through the ViewModels or Services.
    *   Widgets should rely on `Consumer<T>` or `context.watch<T>()` / `context.read<T>()`.
2.  **State Cleanliness**:
    *   Always verify that `notifyListeners()` is called only when UI state updates are necessary.
    *   Expose variables as read-only getters where appropriate, leaving setters internal.
3.  **Exception Handling**:
    *   Verify database and network calls are wrapped in robust try-catch blocks with appropriate fallback values.
4.  **Test Coverage**:
    *   Ensure any new Service methods or ViewModel workflows have corresponding test cases in a mirroring structure in the `test/` directory.

---

## 📝 Commit Message Guidelines

We follow the **Conventional Commits** specification. The format should be:

```
<type>(<scope>): <subject>
```

### Supported Types:
*   `feat`: A new feature
*   `fix`: A bug fix
*   `docs`: Documentation only changes
*   `style`: Code formatting changes (e.g., semicolons, indentations)
*   `refactor`: Code restructuring without bug fixes or feature additions
*   `test`: Adding or correcting tests
*   `chore`: Update dependencies, scripts, build-runner, etc.

### Examples:
*   `feat(scanner): integrate camera source with google ml kit text recognition`
*   `fix(shelf): clamp remaining uses at 0 during decrement`
*   `test(budget): add comprehensive viewmodel calculation unit tests`
