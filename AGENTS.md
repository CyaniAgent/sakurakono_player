# AGENTS.md — SakuraKono Player / skf

## Identity

- **SakuraKono Player Framework (SKF)**: A general-purpose video player Flutter framework. `pubspec.yaml name: skf`. Android package: `com.sakurakono.app`.
- Supports **multiple platform adapters**: Bilibili (via `lib/adapters/bilibili/`), OttoHub (via `lib/adapters/ottohub/`), and others.
- All `package:` imports use `skf` prefix (`package:skf/...`). Zero PiliPlus references remain.
- `lib/core/` and `lib/common/` have **zero** imports from `lib/adapters/`. Verified by grep.

## Current Phase

Structural work complete: Bilibili adapter fully separated (24/24 repositories), OttoHub adapter functional (13/24), Repository pattern across all core interfaces. **Current work: runtime hardening of the Core↔adapter bridge** — recent commits fixed 11 runtime type-mismatch crash sites via `lib/adapters/bilibili/utils/model_converters.dart`, added explicit casts for `Pref.*.obs` dynamic extension dispatch, and fixed Accounts/Hive init ordering. 6 B站-specific media ID types were moved out of `lib/core/models/` into the adapter.

## SDK & env

- **Flutter 3.44.6 / Dart `>=3.12.0`** — pinned in `.fvmrc` and `pubspec.yaml`. Use `fvm flutter` if FVM is configured.
- Dart MCP server required for code intelligence: `opencode.jsonc` configures `dart mcp-server`.

## Linting & formatting

`analysis_options.yaml` extends `package:flutter_lints/flutter.yaml`. Key rules:

- `always_use_package_imports` / `avoid_relative_lib_imports` — all imports must be `package:skf/...`, never relative.
- `prefer_const_constructors`, `prefer_const_declarations`, `prefer_const_literals_to_create_immutables`.
- `unnecessary_late`, `unnecessary_async`, `unnecessary_await_in_return`.
- `avoid_print`, `cascade_invocations`, `sized_box_for_whitespace`.
- `formatter: trailing_commas: preserve` — do not add/remove trailing commas.
- Excluded from analysis: `lib/grpc/bilibili/**`, `lib/adapters/bilibili/grpc/**`, `lib/ottohub_sdk_fix/**`. Don't edit generated `.pb.dart` files anyway.

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
│   └── result/                # LoadingState<T> — sealed class (single unified version)
├── adapters/
│   ├── bilibili/              # B站 adapter
│   │   ├── bili_adapter.dart  # BiliAdapter implements AppAdapter
│   │   ├── bridge.dart        # Bilibili-specific registrations (unchanged)
│   │   ├── repository/        # Bili*Repository for all 24 core interfaces
│   │   ├── pages/             # All B站 UI (161 view.dart files, ~440 Dart files)
│   │   ├── http/              # Dio + HTTP/2 adapter
│   │   ├── grpc/              # Bilibili gRPC endpoints (hand-written + generated .pb.dart)
│   │   ├── player/            # bili_player_factory (media_kit wrapper)
│   │   ├── utils/model_converters.dart  # Core→adapter type converters (runtime crash fixes)
│   │   └── models/ + models_new/
│   └── ottohub/               # OttoHub adapter
│       ├── bridge.dart        # OttoAdapter implements AppAdapter
│       ├── repository/        # 13 Otto*Repository implementations
│       ├── player/            # OttoPlayerFactory + otto_reporter.dart
│       ├── services/          # OttoAccountProvider
│       └── utils/
├── ottohub_sdk_fix/           # Vendored ottohub_sdk_dart (pubspec path override)
├── common/                    # Shared widgets — 0 adapter imports (fully decoupled)
├── utils/                     # Storage (hive_ce), path, platform, theme
├── router/app_pages.dart      # GetX routes: uses AdapterRegistry.active.routes
├── scripts/                   # patch.ps1, build.ps1, 18 .patch files for Flutter SDK
├── grpc/bilibili/             # Standalone gRPC generated protobuf code (excluded from analysis)
└── main.dart                  # Entry: initHive → AdapterRegistry → run App
```

### Key patterns

- **Adapter selection at compile time**: `flutter run --dart-define=ADAPTER=bilibili` (default) or `ADAPTER=ottohub`. Each adapter implements `AppAdapter` and registers its own DI bindings via `AdapterRegistry.activate()`.
- **FeatureFlags**: Optional features are compile-time gated via `AppFeatures.*` (`bool.fromEnvironment`). Disable with `--dart-define=FEATURE_SEARCH=false`.
- **Pages → Repository**: Bilibili pages use `Get.find<Repository>()` (not direct HTTP). OttoHub pages share the same UI but use Otto*Repository implementations.
- **Core→adapter bridge**: Core and adapter types share fields but are distinct classes. For known conversion sites use `lib/adapters/bilibili/utils/model_converters.dart`; for pass-through where types are field-compatible, `as dynamic` cast works but is a runtime crash risk — prefer converters.
- **GetX** throughout: `GetMaterialApp`, `GetPage`, `Get.lazyPut`, `Get.put`, `Get.find`, `Get.toNamed()`.
- **LoadingState<T>** everywhere: sealed class with `Success`, `Error`, `Loading` variants.

## Adapter Status

| Adapter | Status | Repository Coverage | Notes |
|---------|--------|-------------------|-------|
| Bilibili | Complete | 24/24 | All features |
| OttoHub | In Progress | 13/24 | Core playback + account |

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

The CI `ottohub_analyze` job (`.github/workflows/build.yml`) is the source of truth — it disables **all 11 flags**; OttoHub analyze only passes with the full set disabled.

## Key dev commands

| Action | Command |
|--------|---------|
| Analyze (Bilibili) | `flutter analyze --dart-define=ADAPTER=bilibili` — must stay **0 errors, 0 warnings** |
| Analyze (OttoHub) | `flutter analyze --dart-define=ADAPTER=ottohub` + all 11 flags `=false` (see launch config) |
| Test | `flutter test` — **72 tests** across 24 repository test files |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` |
| Mock codegen | Same command — generates `*.mocks.dart` in `test/repository/` |
| Fix warnings | `dart fix --apply` (auto-fixes prefer_const_*, trailing comma, etc.) |
| JNI bindings | `dart run tool/jnigen.dart` → `lib/utils/android/bindings.g.dart` |
| Icons | `dart run flutter_launcher_icons` |
| Splash | `dart run flutter_native_splash:create` |
| Pub get | `flutter pub get` (not `dart pub get`) |

## Build & release

**Version injection** (CI only): `lib/scripts/build.ps1 <platform>` writes `skf_release.json` with `{skf.name, skf.code, skf.hash, skf.time}`, read by `BuildConfig` via `String.fromEnvironment`.

**Flutter SDK patching**: `lib/scripts/patch.ps1 <platform>` MUST run before build. Applies 18 local `.patch` files indexed to Flutter 3.44.6 — changing Flutter version breaks patches.

| Platform | Command |
|----------|---------|
| Android | `flutter build apk --release --split-per-abi --dart-define-from-file=skf_release.json` |
| iOS | `flutter build ios --release --no-codesign --dart-define-from-file=skf_release.json` |
| macOS | `flutter build macos --release --dart-define-from-file=skf_release.json` |
| Windows | `fastforge package --platform windows --targets exe --flutter-build-args="dart-define-from-file=skf_release.json"` |
| Linux | `flutter build linux --release --dart-define-from-file=skf_release.json` |

- CI: `.github/workflows/build.yml` orchestrates 5 platform builds; Flutter version comes from `pubspec.yaml` (`flutter-version-file`). PR builds skip release signing and use dev APK flag (`--android-project-arg dev=1`).
- Windows: fastforge + Inno Setup; Chinese language file at `windows/packaging/exe/ChineseSimplified.isl`.
- Linux: CI produces .tar.gz, .deb, .rpm, and .AppImage artifacts.

## Dependencies

Many packages are git-forked under `bggRGjQaUbCoE` or `My-Responsitories`:
- `get` (GetX fork `version_4.7.2`), `media_kit` & sub-libs (`version_1.2.5`), `cached_network_image_ce`, `catcher_2`, `window_manager`, `file_picker`, `flutter_smart_dialog`, `flutter_sortable_wrap`, `canvas_danmaku`, `font_awesome_flutter`, `super_sliver_list`, `extended_nested_scroll_view`, `desktop_webview_window`
- `ottohub_sdk_dart` is **overridden to a local path**: `dependency_overrides: ottohub_sdk_dart: path: lib/ottohub_sdk_fix` — a vendored copy of the SDK (excluded from analysis). SDK fixes go there, not pub.dev.

See `dependency_overrides` in `pubspec.yaml` — media_kit, flutter_inappwebview, and cached_network_image_ce have both regular deps and overrides.

## Testing

- **24 repository test files** in `test/repository/` — 72 tests total (3 per repo: happy + error + edge). `test/num_utils_test.dart` also exists at the root.
- Uses `mockito: ^5.7.0` + `build_runner`. Each test file has a corresponding `*.mocks.dart`.
- `*.mocks.dart` files are **gitignored** — regenerate with `dart run build_runner build`.
- Pattern: `test/repository/<name>_test.dart` using `@GenerateMocks([<Core>Repository])` — mocks target the **core** repository interfaces (e.g. `AuthRepository`), not Bili-prefixed types.

## Gotchas

- **Storage init order**: `GStorage.init()` after `BiliBridge.initHive()`. Exits on failure. The Hive adapter registration must happen before any adapter activation. Hive boxes may already be open (`Accounts.init()` must handle that).
- **`.gitignore`**: Uses `test_results/` (not `test*`) to avoid ignoring `test/` dir. `*.mocks.dart` is gitignored. `pili_release.json` is gitignored but **`skf_release.json` is not** — a local build creates it; don't commit it.
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
