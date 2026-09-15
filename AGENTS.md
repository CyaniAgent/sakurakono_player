# AGENTS.md — SakuraKono Player / skf

## Identity

- **SakuraKono Player Framework (SKF)**: A general-purpose video player Flutter framework. `pubspec.yaml name: skf`. Android package: `com.sakurakono.app`.
- Supports **multiple platform adapters**: Bilibili (via `lib/adapters/bilibili/`), OttoHub (via `lib/adapters/ottohub/`), and others.
- All `package:` imports use `skf` prefix (`package:skf/...`). Zero PiliPlus references remain.
- `lib/core/` and `lib/common/` have **zero** imports from `lib/adapters/`. Verified by grep.

## Current Phase

**GetX fully removed (2026-09-15)** — zero `package:get` imports in lib/ and test/; the `get` git dependency is gone from pubspec.yaml. Current state:

- **Routing**: pure go_router (`MaterialApp.router`, `AppRouter.create` in `lib/router/app_router.dart`; `AppNavigator` facade in `lib/router/app_navigator.dart` with `to/toNamed/back/push/parametersOf`).
- **DI/state**: Riverpod via global `appContainer` (`lib/core/container/app_container.dart`, `appRead(provider)` in non-widget code) + `ProviderContainer(overrides: adapterOverrides)` built in main.dart. Zero `Get.find`/`Get.put`/`Obx`/`.obs`/`GetxController`.
- **Global refresh**: settings that must apply instantly (theme / pure-black / fontWeight / uiScale / page transition) call `appRefresh.refresh()` (`lib/utils/app_refresh.dart`); main.dart wraps MaterialApp in a ListenableBuilder. Page transition is a local `AppPageTransition` enum (`lib/utils/page_transition.dart`, stored indices compatible with the old GetX `Transition`), applied via `pageTransitionsTheme` in `theme_utils.dart`.
- **Controller acquisition patterns**: (1) registry — `Map<String, T> xxxRegistry` + `Provider.family<T, String>` lookup throwing `StateError` (view registers in initState / removes in dispose); (2) family — `ChangeNotifierProvider.family<T, String>` constructing controllers keyed by heroTag. Route params are passed as constructor args from GoRoute builders (`state.uri.queryParameters`) — `Get.parameters` is gone.
- **Download chain**: `DownloadService extends ChangeNotifier` (plain lists + notifyListeners); `DownloadActions` interface extends ChangeNotifier; pages use `ListenableBuilder(actions)` directly (the old Rx stream bridges were deleted).
- **Hive codegen**: `hive_ce_generator` 1.11.1 (dev dep, pinned by analyzer ^10) generates the model `.g.dart` adapters; `hive_registrar_generator` is disabled in `build.yaml` — adapters register manually in `BiliBridge.initHive()`.

Host interfaces via `pages/providers.dart` stubs overridden in both adapters' `adapterOverrides` (videoHost/settingHost/memberHost/mainHost/dynamicsHost/mineActions/downloadActions). Historical: SPES-014 fixed 11 runtime type-mismatch crash sites; Repository params fully typed (91 Object→String/int); dead-surface cleanup (2026-08); unified playback entry (设置页「播放链接」); the GetX removal also fixed real bugs it had been masking — `Get.parameters` always-empty (routes now pass query params explicitly), `Get.key.push` null-crash, dead `Get.appUpdate`/theme no-ops, and `Get.isRegistered` never true.

## SDK & env

- **Flutter 3.47.0 / Dart 3.13.0** — pinned in `.fvmrc` and `pubspec.yaml`. Use `fvm flutter` if FVM is configured.
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
│   ├── account/               # AccountProvider (ChangeNotifier) + AccountMixin
│   ├── models/                # ~30 Core* type files (video, user, live, fav, msg, …)
│   ├── repository/            # 24 repository interfaces (Video, User, Auth, Danmaku, …)
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
│   │   ├── utils/model_converters.dart  # Core→adapter type converters (runtime crash fixes)
│   │   ├── models/ + models_new/
│   │   └── services/ + plugin/ + common/ + tcp/  # DI, pl_player, shared widgets, tcp live
│   └── ottohub/               # OttoHub adapter
│       ├── bridge.dart        # OttoAdapter implements AppAdapter
│       ├── repository/        # 24 Otto*Repository files (14 real + 2 partial + 8 stubs)
│       └── services/          # OttoAccountProvider
├── ottohub_sdk_fix/           # Vendored ottohub_sdk_dart (pubspec path override)
├── common/                    # Shared widgets — 0 adapter imports (common⇄utils coupled)
├── utils/                     # Storage (hive_ce), path, platform, theme
├── router/                    # go_router: app_router.dart (AppRouter.create), app_navigator.dart facade, app_pages.dart (routes from AdapterRegistry.active)
├── scripts/                   # patch.ps1, build.ps1, 18 .patch files for Flutter SDK
├── grpc/bilibili/             # Standalone gRPC generated protobuf code (excluded from analysis)
├── build_config.dart         # version injection reader (skf.* via fromEnvironment)
└── main.dart                 # Entry: initHive → AdapterRegistry → run App
```

### Key patterns

- **Adapter selection at compile time**: `flutter run --dart-define=ADAPTER=bilibili` (default) or `ADAPTER=ottohub`. Each adapter implements `AppAdapter` and registers its own DI bindings via `AdapterRegistry.activate()`.
- **Structural feature removal**: routes register unconditionally; removing a feature = delete the GoRoute line in `bridge.dart` `buildRoutes()` + the pages/<feature>/ directory + any feature-only repository registration. No compile-time flags.
  移除功能的标准路径（无编译开关）：
  1. 删除 `lib/adapters/bilibili/bridge.dart` `buildRoutes()` 中对应 GoRoute 行；
  2. 删除对应 `pages/<feature>/` 目录；
  3. 删除仅该功能使用的 repository 注册/依赖。
- **Pages → Repository**: all pages use `appRead(repositoryProvider)` (Riverpod). OttoHub pages share the same UI but use Otto*Repository implementations.
- **Core→adapter bridge**: Core and adapter types share fields but are distinct classes. For known conversion sites use `lib/adapters/bilibili/utils/model_converters.dart`; repository params are typed String/int (no `as dynamic` — SPES-014).
- **Unified playback entry (统一播放入口)**: 设置页「播放链接」(`lib/adapters/bilibili/pages/setting/play_input_dialog.dart`) → `classifyPlayInput` (`lib/adapters/bilibili/utils/play_input.dart`, pure function) → B站 URL/BV/av → `PiliScheme.routePushFromUrl`; OttoHub pure-numeric ID → `PageUtils.toVideoPage`. **Dynamic plugin loading is NOT feasible under Flutter AOT** (`Isolate.spawnUri` unsupported, `dart:mirrors` disabled, dart_eval runtime cost high — AppFlowy 2023 case); long-term vision = JS/LUA script engine (quickjs-class), NOT done this round.
- **Controllers**: ChangeNotifier-based (`CommonControllerRiverpod`/`CommonListControllerRiverpod` in `lib/pages/common/common_controller_riverpod.dart`); widgets rebuild via `ListenableBuilder`. Public wrapper `notifyChange()` exists on `CommonControllerRiverpod`/`VideoDetailController`/`LiveRoomController` for external rebuild requests. `GetX fully removed 2026-09-15` — see Current Phase.
- **Riverpod**: Base controller classes `CommonControllerRiverpod`, `CommonListControllerRiverpod` in `lib/pages/common/common_controller_riverpod.dart`. Controllers extend `ChangeNotifier`; widgets use `ListenableBuilder` or `Consumer`.
- **LoadingState<T>** everywhere: sealed class with `Success`, `Error`, `Loading` variants.

## Adapter Status

| Adapter | Status | Repository Coverage | Notes |
|---------|--------|-------------------|-------|
| Bilibili | Complete | 24/24 | All features |
| OttoHub | In Progress | 24/24 registered (14 real, 2 partial, 8 stubs) | 测试/验证用（生产仅 Bilibili） |

## Adapter development

### Creating an adapter

```dart
class NewAdapter implements AppAdapter {
  String get name => 'newadapter';
  @override
  Future<void> registerDependencies() async {
    // Riverpod overrides only — no GetX.
    adapterOverrides = <Override>[ videoRepositoryProvider.overrideWith(Impl.new), /* ... */ ];
  }
  @override
  List<GoRoute> get routes => /* adapter GoRoutes */;
}
```

生产环境只启用一个适配器（Bilibili）；多适配器（OttoHub）仅为测试/验证架构可行性。

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
  ]
}
```

**CI note:** the `ottohub_analyze` job (`.github/workflows/build.yml`) runs bare `flutter analyze` — no feature flags; all routes are registered unconditionally.

## Key dev commands

| Action | Command |
|--------|---------|
| Analyze | `flutter analyze` — must stay **0 errors, 0 warnings** (plain flag; both adapters compile unconditionally) |
| Test | `flutter test` — **270 tests** (24 repo envelope 72 + num_utils 7 + bilibili adapter 28 + ottohub adapter 121 + router/helpers ~42) |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` |
| Mock codegen | Same command — generates `*.mocks.dart` in `test/repository/` |
| Fix warnings | `dart fix --apply` (auto-fixes prefer_const_*, trailing comma, etc.) |
| JNI bindings | `dart run tool/jnigen.dart` → `lib/utils/android/bindings.g.dart` (jnigen pinned to `dart-lang/native` commit `5552083`) |
| Icons | `dart run flutter_launcher_icons` |
| Splash | `dart run flutter_native_splash:create` |
| Pub get | `flutter pub get` (not `dart pub get`). On this machine set `PUB_CACHE=D:\FlutterCache` — the default `%LOCALAPPDATA%\Pub\Cache` is empty and git-hosted forks re-fetch from GitHub (flaky network) |

## Build & release

**Version injection** (CI only): `lib/scripts/build.ps1 <platform>` writes `skf_release.json` with `{skf.name, skf.code, skf.hash, skf.time}`, read by `BuildConfig` via `String.fromEnvironment`. Side effects: rewrites `pubspec.yaml` `version:` (`<name>+<code>`; android name gets `-<9-char hash>` suffix) and exports `version` to `GITHUB_ENV` (used by artifact rename/package steps). Requires `fetch-depth: 0` (versionCode = `git rev-list --count HEAD`).

**Flutter SDK patching**: `lib/scripts/patch.ps1 <platform>` MUST run before build. Applies 17 local `.patch` files indexed to Flutter 3.47.0 — changing Flutter version breaks patches. 16 apply inside the Flutter SDK (`FLUTTER_ROOT`); 1 (`bottom_sheet_ios_app.patch`) applies to the APP repo on iOS only. Platform matrix varies: android also reverts `NewOverScrollIndicator` + cherry-picks `TextSelectionMenuFix`; linux/mac/windows get only the shared 12.

| Platform | Command |
|----------|---------|
| Android | `flutter build apk --release --split-per-abi --dart-define-from-file=skf_release.json --pub` |
| iOS | `flutter build ios --release --no-codesign --dart-define-from-file=skf_release.json` |
| macOS | `flutter build macos --release --dart-define-from-file=skf_release.json` |
| Windows | `fastforge package --platform windows --targets exe --flutter-build-args="dart-define-from-file=skf_release.json"` |
| Linux | `flutter build linux --release -v --pub --dart-define-from-file=skf_release.json` |

- CI: `.github/workflows/build.yml` orchestrates android + ottohub_analyze, delegating to 4 reusable workflows (`ios.yml`/`mac.yml`/`win_x64.yml`/`linux_x64.yml`). **PR runs only android + win_x64 (+ottohub_analyze); ios/mac/linux are workflow_dispatch-only.** PR android uses `--android-project-arg dev=1` → `.dev` suffix + debug-signed (no keystore). Release android is signed only if `SIGN_KEYSTORE_BASE64` secret set; GitHub Release created only when `tag` input non-empty. **No `flutter test` job exists in CI — tests run locally only.**
- CI Flutter version is NOT pinned for build jobs: `flutter-version-file: pubspec.yaml` reads a `>=3.12.0` range; only `ottohub_analyze` pins `flutter-version: 3.44.6`. CI artifacts: Windows emits BOTH a portable zip and the Inno setup exe; Android emits 3 split-per-abi APKs (arm64-v8a/armeabi-v7a/x86_64) as separate artifacts.
- Windows: fastforge + Inno Setup; Chinese language file at `windows/packaging/exe/ChineseSimplified.isl`.
- Linux: CI produces .tar.gz, .deb, .rpm, and .AppImage artifacts.

## Dependencies

Many packages are git-forked under `bggRGjQaUbCoE` or `My-Responsitories`:
- Forked git deps: `media_kit` & sub-libs (`version_1.2.5`), `cached_network_image_ce`, `catcher_2`, `window_manager`, `file_picker`, `flutter_smart_dialog`, `flutter_sortable_wrap`, `canvas_danmaku`, `font_awesome_flutter`, `super_sliver_list`, `extended_nested_scroll_view`, `desktop_webview_window`, `audio_service`, `chat_bottom_container`, `material_design_icons_flutter`, `native_device_orientation`. (`get` fork removed 2026-09-15 with the GetX cleanup.)
- Fork-org exceptions: `desktop_webview_window` is from `Predidit/linux_webview_window`; `webdav_client` is from `wgh136/webdav_client` (not the two orgs above).
- `ottohub_sdk_dart` is **overridden to a local path**: `dependency_overrides: ottohub_sdk_dart: path: lib/ottohub_sdk_fix` — a vendored copy of the SDK (excluded from analysis). SDK fixes go there, not pub.dev.

See `dependency_overrides` in `pubspec.yaml` — media_kit, flutter_inappwebview, and cached_network_image_ce have both regular deps and overrides.

## Testing

- **270 tests total**: `test/repository/` 24 envelope tests (72) + `test/num_utils_test.dart` (7) + `test/adapters/bilibili/` (28 + bridge_overrides) + `test/adapters/ottohub/` (121+ across 14+ Otto*Repository test files + bridge_container) + `test/router/` (app_navigator) + `test/helpers/` (4). All 24 core repositories covered 1:1 — no gaps. ⚠️ `bridge_overrides_test` asserts the exact override count (34+2 bar-state = 36 entries in `buildAdapterOverrides`) — update it when adding overrides. `appContainer` is a global `late final` — tests that trigger `appRead` must assign it in `setUpAll` (Provider caches values; per-test reassignment is impossible).
- Uses `mockito` + `build_runner` (mockito's builder config ships in-package, `@GenerateMocks` is sufficient). `build.yaml` exists: freezed unions=sealed + json_serializable explicit_to_json + `hive_registrar_generator` disabled (Hive adapters register manually in `BiliBridge.initHive()`).
- `*.mocks.dart` files are gitignored — regenerate with `dart run build_runner build` before `flutter test` (regenerated 2026-09-15).
- Pattern: `test/repository/<name>_test.dart` using `@GenerateMocks([<Core>Repository])` — mocks target the **core** repository interfaces (e.g. `AuthRepository`), not Bili-prefixed types. Every generic `LoadingState<T>` return needs `provideDummy<LoadingState<...>>(...)` or build_runner fails. The 24 repo tests are envelope/shape tests of the LoadingState contract — they do NOT exercise Bili*/Otto* implementations. Adapter-scoped tests (`test/adapters/<adapter>/`) DO exercise real adapter code (fixtures + FakeHttpAdapter in `test/helpers/`).
- **No widget or integration tests exist.**

## Gotchas

- **Storage init order**: `GStorage.init()` after `BiliBridge.initHive()`. Exits on failure. `flutter_html` 3.0.0 is broken with `html >=0.15.6` (internal `matches()` removed) — pinned via `dependency_overrides: html: 0.15.5+1`; do not remove the pin. The Hive adapter registration must happen before any adapter activation. Hive boxes may already be open (`Accounts.init()` must handle that).
- **`.gitignore`**: Uses `test_results/` (not `test*`) to avoid ignoring `test/` dir. `*.mocks.dart`, `pili_release.json`, and `skf_release.json` are ALL gitignored (a local build creates the latter; it stays untracked).
- **`distribute_options.yaml`**: Output `dist/` for fastforge.
- **`.omo/`**: Boulder state, work plans, session continuations. Not for code.
- **gRPC exclusion**: `analysis_options.yaml` excludes `lib/grpc/bilibili/**`, `lib/adapters/bilibili/grpc/**`, and `lib/ottohub_sdk_fix/**`. Don't edit generated `.pb.dart` files.
- **AccountProvider**: `lib/core/account/account_provider.dart` now extends `ChangeNotifier` (migrated from `GetxService`). All adapters must register an implementation.

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
├── lib/utils/AGENTS.md       # storage init order, Pref, theme, version plumbing
├── lib/pages/AGENTS.md       # adapter-agnostic UI framework + Host interfaces
└── lib/player/AGENTS.md      # generic media_kit player core
```
