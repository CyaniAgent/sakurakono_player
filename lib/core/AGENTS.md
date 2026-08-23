# lib/core — Contract Layer

## OVERVIEW
Adapter-free abstract interfaces for the SKF player framework. Zero imports from lib/adapters/ (verified by grep).

## STRUCTURE

- adapter/ 2: AppAdapter + AdapterRegistry
- account/ 2: AccountProvider + AccountMixin
- models/ 40 (33 root + 7 ui/): Core* types (member_types, live_types, dynamics_types, video_types, user_types, media_id, download_types...)
- repository/ 24: one interface per domain
- result/ 1: loading_state.dart
- utils/ 3: image_action_registry, subtitle_utils, pair
- root: app_meta.dart

## KEY INTERFACES (verified)
- AppAdapter (adapter/app_adapter.dart): name, registerDependencies(), routes, processImageUrl(originalUrl, {quality}) — minimal surface; dead members (displayName/homePage/onInit/hasFeature) + AppFeature enum removed (dead-surface cleanup, 2026-08).
- AdapterRegistry: register(), activate(name), active; both adapters registered upfront in main.dart, ADAPTER dart-define picks active.
- LoadingState (result/loading_state.dart): sealed class, Loading / Success<T>(response) / Error(errMsg, {code}); every repo method returns Future<LoadingState<T>>; NOTE: imports flutter_smart_dialog (a UI package) for error toast — core is NOT purely UI-free.
- AccountProvider (account/account_provider.dart): abstract, extends ChangeNotifier (migrated from GetxService); plain fields for face/login state, restoreFromCache(), authHeaders, onAuthStateChanged. AccountMixin: subscribes onAuthStateChanged.
- AppMeta (app_meta.dart): appName='SakuraKono', packageName='skf', buildConfigPrefix='skf', sourceCodeUrl — the rebranding file; BuildConfig (lib/build_config.dart, NOT in core) composes '${AppMeta.buildConfigPrefix}.code' etc. via fromEnvironment.

## CONVENTIONS
- One repository interface per domain, named <Domain>Repository (e.g. AuthRepository); 24 total. Methods return Future<LoadingState<T>>.
- Core models are plain data classes (no Hive annotations) — Hive-persisted types live in the adapter (bilibili/models).
- package:skf imports only (never relative).
- Dot-shorthand enum/static syntax (Dart ≥3.10) used: `CoreDynamicsTabType type = .all` in repository/dynamics_repository.dart:16. Keep consistent.
- Model enum files carry `// ignore_for_file: constant_identifier_names` (live_enums, search_types, sponsor_block_types, ui/badge_type) — enum constants deliberately not SCREAMING_CASE.

## ANTI-PATTERNS
- Runtime type-identity casts on Core↔adapter: Core and adapter types are DISTINCT classes sharing fields — do not add Core fields that duplicate adapter-only types; conversion belongs in lib/adapters/bilibili/utils/model_converters.dart.
- Typed IDs (2026-08-09): all 91 former `required Object`/`dynamic` params across 9 repository interfaces are now `String`/`int` by semantic family (media/content IDs → String, user IDs → int) — do NOT regress to Object/dynamic. Prefer CoreMediaId only for NEW media-ID methods.
- Core imports from common are FORBIDDEN — `repository/dynamics_repository.dart` now imports `package:skf/core/utils/pair.dart` (fixed 2026-08). `lib/core/utils/pair.dart` holds the canonical `Pair`/`Triple`; keep core code on core/utils, never `common/`.

## WHERE TO LOOK

- Define a new feature interface → repository/<domain>_repository.dart
- App identity/version keys → app_meta.dart (prefix 'skf')
- Rebrand/rename → app_meta.dart first
