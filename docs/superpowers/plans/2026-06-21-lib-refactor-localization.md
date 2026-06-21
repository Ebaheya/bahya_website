# Lib Refactor and Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Keep every `lib` Dart file below 600 lines and migrate every app-owned visible Arabic/English string to generated Flutter ARB localization without changing behavior.

**Architecture:** Preserve every existing public class and method signature. Decompose oversized libraries through feature-local parts/extensions, use generated `AppLocalizations` as the only translation source, and retain locale persistence through `AppLanguageController`.

**Tech Stack:** Flutter 3.x, Dart 3.9, `flutter gen-l10n`, ARB/ICU messages, Flutter test, Flutter analyzer.

---

### Task 1: Establish executable safeguards

**Files:**
- Create: `lib/platform/url_strategy.dart`
- Create: `lib/platform/url_strategy_stub.dart`
- Create: `lib/platform/url_strategy_web.dart`
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart`
- Create: `test/architecture/lib_quality_test.dart`

- [ ] Add a test that recursively reads `lib/**/*.dart` and fails with the exact paths and line counts at or above 600.
- [ ] Run `flutter test test/architecture/lib_quality_test.dart` and confirm failure lists the six baseline oversized files.
- [ ] Add conditional URL-strategy adapters: the stub exposes `configureUrlStrategy()` as a no-op; the web implementation calls `setUrlStrategy(PathUrlStrategy())`; the conditional export selects the web implementation only for `dart.library.js_interop`.
- [ ] Update `main.dart` to call `configureUrlStrategy()` and remove its direct `flutter_web_plugins` import.
- [ ] Replace the template counter assertion with a smoke test that pumps `MyApp` under the generated/localization delegates without assuming a counter UI.
- [ ] Run `flutter test` and confirm the VM test compiler no longer fails on `dart:ui_web`.

### Task 2: Configure generated ARB localization

**Files:**
- Create: `l10n.yaml`
- Modify: `pubspec.yaml`
- Create: `lib/l10n/app_en.arb`
- Create: `lib/l10n/app_ar.arb`
- Modify: `lib/l10n/app_localizations.dart`
- Create: `test/l10n/app_localizations_test.dart`

- [ ] Write localization tests that load English and Arabic delegates and assert representative simple and parameterized messages.
- [ ] Run the localization tests and confirm they fail because generated messages do not exist.
- [ ] Configure `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-localization-file: app_localizations_generated.dart`, `output-class: AppLocalizations`, and `synthetic-package: false`; enable `flutter: generate: true`.
- [ ] Seed both ARB catalogs from the complete existing `enToAr`/`arToEn` union, assigning stable lowerCamelCase semantic keys and ICU placeholders to dynamic messages.
- [ ] Run `flutter gen-l10n`; resolve duplicate/conflicting legacy entries by preserving the text currently selected at runtime.
- [ ] Refactor `AppLanguageController` into the non-generated localization support file, retain secure-storage loading/toggling, and add a `BuildContext` extension returning generated `AppLocalizations`.
- [ ] Run localization tests and confirm both locales and placeholders pass.

### Task 3: Migrate visible strings repository-wide

**Files:**
- Modify: every Dart file under `lib/screens`, `lib/helper`, `lib/bloc`, and `lib/logic` that renders or returns app-owned user-visible text
- Delete after migration: `lib/l10n/en_to_ar.dart`
- Delete after migration: `lib/l10n/ar_to_en.dart`
- Create: `test/architecture/localization_coverage_test.dart`

- [ ] Add a source scan test covering visible widget constructor arguments, input decoration labels/hints/errors, dialog/snackbar/tooltip content, and existing `localizedText*` calls; whitelist only protocol identifiers, routes, asset paths, API keys, logs, and user/server-provided values.
- [ ] Run it and confirm it fails on the current hardcoded call sites.
- [ ] Replace every visible literal and `localizedText(context, literal)` call with a generated getter or ICU method. Pass dynamic values as typed placeholder arguments.
- [ ] Replace context-free display strings with generated localization passed from the caller or locale-aware generated lookup without changing execution order.
- [ ] Remove the legacy translation maps and runtime substring translator when repository searches report no imports or calls.
- [ ] Run the localization coverage test and manually inspect its whitelist entries.

### Task 4: Split `WebService`

**Files:**
- Modify: `lib/data/api/web/web_service.dart`
- Create: `lib/data/api/web/web_service_helpers.dart`
- Create: `lib/data/api/web/web_service_users.dart`
- Create: `lib/data/api/web/web_service_patients.dart`
- Create: `lib/data/api/web/web_service_forms.dart`
- Create: `lib/data/api/web/web_service_assessments.dart`
- Create: `lib/data/api/web/web_service_admin.dart`

- [ ] Add a source-level API characterization test that records every public `WebService` method name and named parameter set.
- [ ] Run it against an intentionally incomplete expected manifest and confirm failure shows the current surface.
- [ ] Convert `web_service.dart` into the owning library with unchanged imports, `UserRole`, `WebService`, Dio field, and part directives.
- [ ] Move methods verbatim into feature-focused `part of` files; do not edit endpoints, payloads, response processing, exception handling, or signatures.
- [ ] Update the characterization manifest to the observed baseline and run it successfully.

### Task 5: Split oversized widgets and controller

**Files:**
- Modify: `lib/helper/widgets/volunteer/patients_list.dart`
- Create: `lib/helper/widgets/volunteer/patients_list_actions.dart`
- Create: `lib/helper/widgets/volunteer/patients_list_content.dart`
- Modify: `lib/helper/admin_widgets/user/user_table.dart`
- Create: `lib/helper/admin_widgets/user/user_table_content.dart`
- Create: `lib/helper/admin_widgets/user/user_table_filters.dart`
- Modify: `lib/helper/widgets/filler/saved_filler_widget.dart`
- Create: `lib/helper/widgets/filler/saved_filler_fields.dart`
- Create: `lib/helper/widgets/filler/saved_filler_sections.dart`
- Modify: `lib/helper/widgets/schedule/schedule_form.dart`
- Create: `lib/helper/widgets/schedule/schedule_form_actions.dart`
- Create: `lib/helper/widgets/schedule/schedule_form_content.dart`
- Modify: `lib/logic/add_questionnaire_controller.dart`
- Create: `lib/logic/add_questionnaire_validation.dart`
- Create: `lib/logic/add_questionnaire_payloads.dart`
- Create: `lib/logic/add_questionnaire_workflows.dart`

- [ ] For each owning file, add `part` directives and move contiguous private methods or private widgets verbatim into `part of` files.
- [ ] Keep state fields, public constructors, public controller members, lifecycle methods, callback order, and async boundaries unchanged.
- [ ] Format each feature after extraction and run targeted analyzer checks for its owning library.
- [ ] Run the line-limit test and split any formatted file still at or above 600 lines.

### Task 6: Behavior-preserving cleanup

**Files:**
- Modify: Dart files reported by analyzer under `lib/`

- [ ] Remove analyzer-proven unused imports, unused locals, dead private helpers, unnecessary imports, unnecessary interpolation braces, and missing control-flow braces.
- [ ] Rename non-public files to lower-case snake case and update imports where this is filesystem-safe.
- [ ] Replace deprecated color opacity calls with equivalent `withValues(alpha:)` calls.
- [ ] Leave deprecated form/radio APIs unchanged if migration would alter state ownership or event behavior; record them as remaining issues.
- [ ] Run `flutter analyze` after each cleanup group and revert any change that introduces an error or changes a public API.

### Task 7: Final verification

**Files:**
- Modify only files required by verification failures

- [ ] Run `flutter gen-l10n`.
- [ ] Run `dart format lib test`.
- [ ] Run the physical line-count scan and confirm every `lib/**/*.dart` file has fewer than 600 lines.
- [ ] Run repository searches for legacy localization imports/calls and unreviewed visible literals.
- [ ] Run `flutter analyze` and capture exact remaining error, warning, and info counts.
- [ ] Run `flutter test` and capture the test count.
- [ ] Run `flutter build web` and capture the exit status.
- [ ] Review `git diff --check`, `git status --short`, and the full diff summary before reporting changed files and remaining issues.
