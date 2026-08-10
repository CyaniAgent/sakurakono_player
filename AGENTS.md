# AGENTS.md — SakuraKono Player / skf

## Identity

- **SakuraKono Player Framework (SKF)**: A general-purpose video player Flutter framework. `pubspec.yaml name: skf`. Android package: `com.sakurakono.app`.
- Supports **multiple platform adapters**: Bilibili (via `lib/adapters/bilibili/`), OttoHub (via `lib/adapters/ottohub/`), and others.
- All `package:` imports use `skf` prefix (`package:skf/...`). Zero PiliPlus references remain.
- `lib/core/` and `lib/common/` have **zero** imports from `lib/adapters/`. Verified by grep.

## Current Phase

Structural work complete: Bilibili adapter fully separated (24/24 repositories), OttoHub adapter functional (13 real repos of 24 registered — the rest are crash-prevention stubs), Repository pattern across all core interfaces. **Current work: runtime hardening of the Core↔adapter bridge** — recent commits fixed 11 runtime type-mismatch crash sites via `lib/adapters/bilibili/utils/model_converters.dart` (SPES-014: `as dynamic` eliminated from adapter code), added explicit casts for `Pref.*.obs` dynamic extension dispatch, and fixed Accounts/Hive init ordering. Repository params fully typed (91 Object→String/int, 2026-08-09); 34 Pref getters typed (B站 enum getters moved to BiliPref); as-dynamic casts eliminated (2 features fixed via SelectionArea.onSelectionChanged, 2026-08-10). 6 B站-specific media ID types were moved out of `lib/core/models/` into the adapter.

## SDK & env

- **Flutter 3.44.9 / Dart `>=3.12.0`** — pinned in `.fvmrc` and `pubspec.yaml`. Use `fvm flutter` if FVM is configured.
- Dart MCP server required for code intelligence: `opencode.jsonc` configures `dart mcp-server`.

## Linting & formatting

`analysis_options.yaml` extends `package:flutter_lints/flutter.yaml`. Key rules:

- `always_use_package_imports` / `avoid_relative_lib_imports` — all imports must be `package:skf/...`, never relative.
- `prefer_const_constructors`, `prefer_const_declarations`, `prefer_const_literals_to_create_immutables`.
- `unnecessary_late`, `unnecessary_async`, `unnecessary_await_in_return`.
- `avoid_print`, `cascade_invocations`, `sized_box_for_whitespace`.
- `formatter: trailing_commas: preserve` — do not add/remove trailing commas.
- Excluded from analysis: `lib/grpc/bilibili/**`, `lib/adapters/bilibili/grpc/**`, `lib/ottohub_sdk_fix/**`. Don't edit generated `.pb.dart` files anyway.
- `linter.rules` has **42 explicit rules** — 25 beyond what flutter_lints 6.0.0 already enables (e.g. `always_declare_return_types`, `always_use_package_imports`, `avoid_field_initializers_in_const_classes`, `avoid_void_async`, `cancel_subscriptions`, `cascade_invocations`, `no_literal_bool_comparisons`, `prefer_const_constructors`, `prefer_void_to_null`, `tighten_type_of_initializing_formals`, `use_colored_box`, `use_decorated_box`, `use_named_constants`, `use_null_aware_elements`, `use_truncating_division`). `flutter analyze` (Bilibili) must stay **0 errors, 0 warnings**.

## Architecture

```
lib/
├── core/                      # Abstract interfaces (zero adapter dependency)
│   ├── adapter/               # AppAdapter interface + AdapterRegistry
│   ├── config/                # AppFeatures — compile-time FeatureFlags
│   ├── account/               # AccountProvider (GetxService) + AccountMixin
│   ├── models/                # ~30 Core* type files (video, user, live, fav, msg, …)
│   ├── repository/            # 24 repository interfaces (Video, User, Auth, Danmaku, …)
│   ├── player/                # PlayerFactory, MediaSource, PlaybackReporter
│   ├── plugin/                # Plugin interface, PluginRegistry, LocalFilePlugin, DataSource
│   ├── utils/                # pair, subtitle_utils, image_action_registry
│   └── result/               # LoadingState<T> — sealed class (single unified version)
├── adapters/
│   ├── bilibili/              # B站 adapter
│   │   ├── bili_adapter.dart  # BiliAdapter implements AppAdapter
│   │   ├── bridge.dart        # Bilibili-specific registrations (unchanged)
│   │   ├── repository/        # Bili*Repository for all 24 core interfaces
│   │   ├── pages/             # All B站 UI (441 files, 114 page dirs, 161 view.dart)
│   │   ├── http/              # Dio + HTTP/2 adapter
│   │   ├── grpc/              # Bilibili gRPC endpoints (hand-written + generated .pb.dart)
│   │   ├── player/            # bili_player_factory (media_kit wrapper)
│   │   ├── utils/model_converters.dart  # Core→adapter type converters (runtime crash fixes)
│   │   ├── models/ + models_new/
│   │   └── services/ + plugin/ + common/ + tcp/ + account/ + router/  # DI, pl_player, shared widgets, tcp live, legacy+dead
│   └── ottohub/               # OttoHub adapter
│       ├── bridge.dart        # OttoAdapter implements AppAdapter
│       ├── repository/        # 24 Otto*Repository files (13 real + 2 partial + 9 stubs)
│       ├── player/            # OttoPlayerFactory + otto_reporter.dart
│       └── services/          # OttoAccountProvider
├── ottohub_sdk_fix/           # Vendored ottohub_sdk_dart (pubspec path override)
├── common/                    # Shared widgets — 0 adapter imports (common⇄utils coupled)
├── utils/                     # Storage (hive_ce), path, platform, theme
├── router/app_pages.dart      # GetX routes: uses AdapterRegistry.active.routes
├── scripts/                   # patch.ps1, build.ps1, 18 .patch files for Flutter SDK
├── grpc/bilibili/             # Standalone gRPC generated protobuf code (excluded from analysis)
├── build_config.dart         # version injection reader (skf.* via fromEnvironment)
└── main.dart                 # Entry: initHive → AdapterRegistry → run App
```

### Key patterns

- **Adapter selection at compile time**: `flutter run --dart-define=ADAPTER=bilibili` (default) or `ADAPTER=ottohub`. Each adapter implements `AppAdapter` and registers its own DI bindings via `AdapterRegistry.activate()`.
- **FeatureFlags**: Optional features are compile-time gated via `AppFeatures.*` (`bool.fromEnvironment`). Disable with `--dart-define=FEATURE_SEARCH=false`.
- **Pages → Repository**: Bilibili pages use `Get.find<Repository>()` (not direct HTTP). OttoHub pages share the same UI but use Otto*Repository implementations.
- **Core→adapter bridge**: Core and adapter types share fields but are distinct classes. For known conversion sites use `lib/adapters/bilibili/utils/model_converters.dart`; repository params are typed String/int (no `as dynamic` — SPES-014).
- **Dead AppAdapter surfaces**: `homePage`, `onInit()`, and `AdapterRegistry.hasFeature()` are NEVER consumed — `activate()` only calls `registerDependencies()`; the `/` route hardcodes bilibili `MainApp` (not `active.homePage`); real feature gating is compile-time `AppFeatures.*` in `BiliBridge.registerRoutes()`. `AdapterRegistry.active` has exactly 2 consumers: `lib/router/app_pages.dart` (routes) + `lib/common/widgets/image/network_img_layer.dart` (processImageUrl).
- **GetX** throughout: `GetMaterialApp`, `GetPage`, `Get.lazyPut`, `Get.put`, `Get.find`, `Get.toNamed()`.
- **LoadingState<T>** everywhere: sealed class with `Success`, `Error`, `Loading` variants.

## Adapter Status

| Adapter | Status | Repository Coverage | Notes |
|---------|--------|-------------------|-------|
| Bilibili | Complete | 24/24 | All features |
| OttoHub | In Progress | 24/24 registered (13 real, 2 partial, 9 stubs) | Core playback + account |

## Adapter development

### Creating an adapter

```dart
class NewAdapter implements AppAdapter {
  String get name => 'newadapter';
  String get displayName => 'New Platform';
  Future<void> registerDependencies() { /* Get.lazyPut<Repo>(Impl.new) */ }
  List<GetPage> get routes => BiliBridge.registerRoutes(); // reuse pages
  bool hasFeature(AppFeature f) => /* true for supported features */;
}
```

### Feature flag reference

All 11 flags default **true**; disable with `--dart-define=FEATURE_X=false`:

| Flag | Use |
|---|---|
| `FEATURE_SEARCH` | Disable for SDKs without search |
| `FEATURE_LIVE` | Disable if no live streaming |
| `FEATURE_MUSIC` | |
| `FEATURE_PGC` | Disable if no drama/anime |
| `FEATURE_DOWNLOAD` | Disable if client handles downloads |
| `FEATURE_DM_FILTER` / `FEATURE_AUDIO` / `FEATURE_MATCH` / `FEATURE_SPACE` / `FEATURE_SPONSOR` / `FEATURE_VALIDATE` | |

### Launch configs (VS Code)

```json
{
  "name": "SKF (Bilibili)",
  "args": ["--dart-define=ADAPTER=bilibili"]
},
{
  "name": "SKF (OttoHub)",
  "args": [
    "--dart-define=ADAPTER=ottohub",
    "--dart-define=FEATURE_SEARCH=false",
    "--dart-define=FEATURE_LIVE=false",
    "--dart-define=FEATURE_MUSIC=false",
    "--dart-define=FEATURE_PGC=false",
    "--dart-define=FEATURE_DOWNLOAD=false",
    "--dart-define=FEATURE_DM_FILTER=false",
    "--dart-define=FEATURE_AUDIO=false",
    "--dart-define=FEATURE_MATCH=false",
    "--dart-define=FEATURE_SPACE=false",
    "--dart-define=FEATURE_SPONSOR=false",
    "--dart-define=FEATURE_VALIDATE=false"
  ]
}
```

**CI note:** the `ottohub_analyze` job (`.github/workflows/build.yml`) runs bare `flutter analyze` with **no dart-defines** — all 11 flags default to `true` in CI. The 11-flag `=false` set exists ONLY in the VS Code launch config; analyze output is flag-independent (const `bool.fromEnvironment` does not change dead-branch analysis).

## Key dev commands

| Action | Command |
|--------|---------|
| Analyze (Bilibili) | `flutter analyze --dart-define=ADAPTER=bilibili` — must stay **0 errors, 0 warnings** |
| Analyze (OttoHub) | `flutter analyze --dart-define=ADAPTER=ottohub` + all 11 flags `=false` (see launch config) |
| Test | `flutter test` — **87 tests** (72 repo + 7 num_utils + 5 ottohub_bridge + 3 model_converters) |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` |
| Mock codegen | Same command — generates `*.mocks.dart` in `test/repository/` |
| Fix warnings | `dart fix --apply` (auto-fixes prefer_const_*, trailing comma, etc.) |
| JNI bindings | `dart run tool/jnigen.dart` → `lib/utils/android/bindings.g.dart` (jnigen pinned to `dart-lang/native` commit `5552083`) |
| Icons | `dart run flutter_launcher_icons` |
| Splash | `dart run flutter_native_splash:create` |
| Pub get | `flutter pub get` (not `dart pub get`) |

## Build & release

**Version injection** (CI only): `lib/scripts/build.ps1 <platform>` writes `skf_release.json` with `{skf.name, skf.code, skf.hash, skf.time}`, read by `BuildConfig` via `String.fromEnvironment`. Side effects: rewrites `pubspec.yaml` `version:` (`<name>+<code>`; android name gets `-<9-char hash>` suffix) and exports `version` to `GITHUB_ENV` (used by artifact rename/package steps). Requires `fetch-depth: 0` (versionCode = `git rev-list --count HEAD`).

**Flutter SDK patching**: `lib/scripts/patch.ps1 <platform>` MUST run before build. Applies 17 local `.patch` files indexed to Flutter 3.44.9 — changing Flutter version breaks patches. 16 apply inside the Flutter SDK (`FLUTTER_ROOT`); 1 (`bottom_sheet_ios_app.patch`) applies to the APP repo on iOS only. Platform matrix varies: android also reverts `NewOverScrollIndicator` + cherry-picks `TextSelectionMenuFix`; linux/mac/windows get only the shared 12.

| Platform | Command |
|----------|---------|
| Android | `flutter build apk --release --split-per-abi --dart-define-from-file=skf_release.json --pub` |
| iOS | `flutter build ios --release --no-codesign --dart-define-from-file=skf_release.json` |
| macOS | `flutter build macos --release --dart-define-from-file=skf_release.json` |
| Windows | `fastforge package --platform windows --targets exe --flutter-build-args="dart-define-from-file=skf_release.json"` |
| Linux | `flutter build linux --release -v --pub --dart-define-from-file=skf_release.json` |

- CI: `.github/workflows/build.yml` orchestrates android + ottohub_analyze, delegating to 4 reusable workflows (`ios.yml`/`mac.yml`/`win_x64.yml`/`linux_x64.yml`). **PR runs only android + win_x64 (+ottohub_analyze); ios/mac/linux are workflow_dispatch-only.** PR android uses `--android-project-arg dev=1` → `.dev` suffix + debug-signed (no keystore). Release android is signed only if `SIGN_KEYSTORE_BASE64` secret set; GitHub Release created only when `tag` input non-empty. **No `flutter test` job exists in CI — tests run locally only.**
- CI Flutter version is NOT pinned for build jobs: `flutter-version-file: pubspec.yaml` reads a `>=3.12.0` range; only `ottohub_analyze` pins `flutter-version: 3.44.9`. CI artifacts: Windows emits BOTH a portable zip and the Inno setup exe; Android emits 3 split-per-abi APKs (arm64-v8a/armeabi-v7a/x86_64) as separate artifacts.
- Windows: fastforge + Inno Setup; Chinese language file at `windows/packaging/exe/ChineseSimplified.isl`.
- Linux: CI produces .tar.gz, .deb, .rpm, and .AppImage artifacts.

## Dependencies

Many packages are git-forked under `bggRGjQaUbCoE` or `My-Responsitories`:
- `get` (GetX fork `version_4.7.2`), `media_kit` & sub-libs (`version_1.2.5`), `cached_network_image_ce`, `catcher_2`, `window_manager`, `file_picker`, `flutter_smart_dialog`, `flutter_sortable_wrap`, `canvas_danmaku`, `font_awesome_flutter`, `super_sliver_list`, `extended_nested_scroll_view`, `desktop_webview_window`, `audio_service`, `chat_bottom_container`, `material_design_icons_flutter`, `native_device_orientation`
- Fork-org exceptions: `desktop_webview_window` is from `Predidit/linux_webview_window`; `webdav_client` is from `wgh136/webdav_client` (not the two orgs above).
- `ottohub_sdk_dart` is **overridden to a local path**: `dependency_overrides: ottohub_sdk_dart: path: lib/ottohub_sdk_fix` — a vendored copy of the SDK (excluded from analysis). SDK fixes go there, not pub.dev.

See `dependency_overrides` in `pubspec.yaml` — media_kit, flutter_inappwebview, and cached_network_image_ce have both regular deps and overrides.

## Testing

- **87 tests total**: 24 repo test files in `test/repository/` (72 tests, 3 per repo: happy + error + edge) + `test/num_utils_test.dart` (7) + `test/ottohub_bridge_test.dart` (5) + `test/adapters/bilibili/model_converters_test.dart` (3). All 24 core repositories covered 1:1 — no gaps.
- Uses `mockito: ^5.7.0` + `build_runner` (resolved: mockito 5.7.0 / build_runner 2.15.1). **No `build.yaml` exists** — mockito's builder config ships in-package, `@GenerateMocks` annotation is sufficient.
- `*.mocks.dart` files are **gitignored** — regenerate with `dart run build_runner build`. ⚠️ Local mocks currently claim generation by mockito **5.4.6** (stale vs resolved 5.7.0) — regenerate before `flutter test`.
- Pattern: `test/repository/<name>_test.dart` using `@GenerateMocks([<Core>Repository])` — mocks target the **core** repository interfaces (e.g. `AuthRepository`), not Bili-prefixed types. Every generic `LoadingState<T>` return needs `provideDummy<LoadingState<...>>(...)` or build_runner fails. The 24 repo tests are envelope/shape tests of the LoadingState contract — they do NOT exercise Bili*/Otto* implementations (exception: `ottohub_bridge_test.dart` + `model_converters_test.dart` DO exercise real adapter code). Adapter-scoped tests live in `test/adapters/<adapter>/`.
- **No widget or integration tests exist.**

## Gotchas

- **Storage init order**: `GStorage.init()` after `BiliBridge.initHive()`. Exits on failure. The Hive adapter registration must happen before any adapter activation. Hive boxes may already be open (`Accounts.init()` must handle that).
- **`.gitignore`**: Uses `test_results/` (not `test*`) to avoid ignoring `test/` dir. `*.mocks.dart`, `pili_release.json`, and `skf_release.json` are ALL gitignored (a local build creates the latter; it stays untracked).
- **`distribute_options.yaml`**: Output `dist/` for fastforge.
- **`.omo/`**: Boulder state, work plans, session continuations. Not for code.
- **gRPC exclusion**: `analysis_options.yaml` excludes `lib/grpc/bilibili/**`, `lib/adapters/bilibili/grpc/**`, and `lib/ottohub_sdk_fix/**`. Don't edit generated `.pb.dart` files.
- **AccountProvider is a GetxService**: `lib/core/account/account_provider.dart` extends `GetxService`. All adapters must register an implementation.

## Platform quirks

- **Android**: MaxScreenSize + FlutterDisplayMode for high-refresh.
- **iOS**: Connectivity monitoring for network switching.
- **Windows**: WebViewEnvironment for flutter_inappwebview.
- **Desktop**: window_manager with saved window size/position.
- **Mobile**: Edge-to-edge system UI, transparent bars.

## AGENTS.md hierarchy

This knowledge base is hierarchical — subdirectory files cover their subtree only, never repeating parent content:

```
AGENTS.md                    (root — this file)
├── lib/core/AGENTS.md        # contract layer (AppAdapter, LoadingState, 24 repo interfaces)
├── lib/adapters/bilibili/AGENTS.md   # B站 adapter internals (bridge, HTTP, pages, converters)
├── lib/adapters/ottohub/AGENTS.md    # OttoHub adapter (DI overlay, stub contract)
├── lib/common/AGENTS.md      # shared widgets + vendored flutter/ dir
└── lib/utils/AGENTS.md       # storage init order, Pref, theme, version plumbing
```
