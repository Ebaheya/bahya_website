# Lib Refactor and Localization Design

## Objective

Refactor all Dart code under `lib/` without changing application logic, API contracts, Cubit behavior, model behavior, navigation, or rendered UI behavior. Every Dart file must remain below 600 lines. All user-visible Arabic and English text must move to Flutter's generated ARB localization system.

## Baseline

- 139 Dart files and approximately 40,623 lines under `lib/`.
- Six files exceed 600 lines:
  - `lib/data/api/web/web_service.dart` (1,081)
  - `lib/helper/widgets/volunteer/patients_list.dart` (748)
  - `lib/helper/admin_widgets/user/user_table.dart` (678)
  - `lib/helper/widgets/filler/saved_filler_widget.dart` (676)
  - `lib/logic/add_questionnaire_controller.dart` (632)
  - `lib/helper/widgets/schedule/schedule_form.dart` (626)
- The current localization implementation uses `enToAr` and `arToEn` maps with runtime substring replacement.
- The baseline analyzer reports 246 findings: warnings, deprecations, naming findings, and style findings. There are no analyzer errors.
- The repository was clean before planning began.

## Considered Approaches

### 1. Preserve the map-based translator

This minimizes call-site changes but remains weakly typed, silently returns untranslated strings, handles interpolation through substring replacement, and duplicates source text as identifiers. It does not meet the maintainability requirement.

### 2. Generated ARB localization with compatibility fallback

Generated ARB getters would cover migrated strings while the old translator remains temporarily available. This reduces migration risk but leaves two localization systems and makes completeness difficult to verify.

### 3. Complete generated ARB migration

Use `flutter gen-l10n`, `app_en.arb`, and `app_ar.arb`; replace visible literals and translation calls with generated getters and parameterized methods; remove the old bidirectional maps after all call sites are migrated. This provides typed access, explicit parameters, and a single maintainable source of truth.

The approved approach is option 3.

## Localization Architecture

- Enable Flutter code generation in `pubspec.yaml` and add `l10n.yaml`.
- Store English source messages in `lib/l10n/app_en.arb` and Arabic translations in `lib/l10n/app_ar.arb`.
- Preserve every currently supported translation, including messages embedded in validation errors, dialogs, tooltips, empty states, table labels, buttons, status labels, and notifications.
- Convert interpolated messages to ARB placeholders instead of concatenation or substring replacement.
- Keep `AppLanguageController`, persisted language selection, supported locales, RTL behavior, and locale toggling semantics unchanged.
- Expose a small `BuildContext` localization extension if it materially reduces repetitive generated-localization imports. This extension must only delegate to the generated class.
- Do not localize protocol values, API paths, JSON keys, identifiers, role/status enum values sent to the server, logging-only messages, or user/server-provided content.
- Remove `en_to_ar.dart` and `ar_to_en.dart` only after repository-wide scans confirm no runtime dependencies remain.

## Safe File Decomposition

### Web service

Keep `WebService` as the public API. Split implementation into feature-focused library parts or extensions under `lib/data/api/web/`, grouped around authentication/users, patients/volunteers, forms/assignments/assessments, dashboard/reports/audit, and shared response/sorting helpers. Method names, signatures, Dio calls, endpoints, request bodies, response shapes, and exception handling remain unchanged.

### Oversized stateful widgets

Keep the existing public widget classes and constructor signatures. Extract private render sections, dialogs, cards, tables, and helper methods into feature-local `part` files where shared private state access is required. Existing state ownership, callbacks, controller lifetimes, keys, layout values, and event order remain unchanged.

Affected features are volunteer patients, user management, saved questionnaire filling, and schedule forms.

### Questionnaire controller

Keep `AddQuestionnaireController` and its public surface unchanged. Extract pure validation/body-building helpers and private workflow helpers into focused library parts or private collaborators. Preserve notification timing, validation ordering, payload construction, edit/save/delete flows, and error messages.

### Line limit

After all changes, count every `lib/**/*.dart` file using physical line counts. Files near the threshold will be split further so formatting cannot push them above 599 lines.

## General Cleanup Boundaries

- Apply behavior-preserving naming and readability improvements only.
- Remove imports, locals, and private declarations only when analyzer evidence proves they are unused.
- Deduplicate repeated presentation helpers only when inputs and output behavior are identical.
- Avoid broad API renames. Existing public symbols remain available unless a filename-only rename is required to satisfy linting and all imports can be updated safely.
- Deprecation migrations are allowed only when the replacement has equivalent behavior. Findings with possible UI or state semantics changes remain documented instead of being changed speculatively.

## Verification

- Add localization tests covering English and Arabic lookup, parameterized messages, locale persistence behavior where testable, and representative widget text.
- Add focused characterization tests for extracted pure helpers where feasible.
- Run `flutter gen-l10n` and verify generated sources compile.
- Run `dart format` on all Dart sources.
- Verify every Dart file under `lib/` is below 600 lines.
- Scan for direct visible string literals and review each remaining match as localized, non-visible, user-provided, or protocol data.
- Run `flutter test`.
- Run `flutter analyze` and compare its output with the 246-finding baseline.
- Run a Flutter web build as the final compile verification because this repository is configured as a web application.

## Completion Criteria

- No Dart file under `lib/` has 600 or more lines.
- All visible app-owned strings use generated ARB localization.
- Arabic and English remain supported with current locale persistence and directionality.
- No screen, widget, Cubit, model, service method, API call, or feature is removed.
- Formatting succeeds, tests pass, and the web build succeeds.
- Analyzer errors are zero; remaining warnings or infos are reported with exact categories and counts.
