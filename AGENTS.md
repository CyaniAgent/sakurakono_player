# AGENTS.md — SakuraKono Player / skf

## Identity

- **SakuraKono Player Framework (SKF)**: A Bilibili video player Flutter app. `pubspec.yaml name: skf`. Android package: `com.sakurakono.app`.
- Rebranding from PiliPlus is **complete**. All `package:` imports use `skf` prefix (`package:skf/...`). Zero PiliPlus references remain.

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
- gRPC generated `.pb.dart` files are **excluded** from analysis in `analysis_options.yaml`.

## Architecture

```
lib/
├── core/                      # Abstract interfaces (zero B站 dependency)
│   ├── models/                # 27 Core* type files (video, user, live, fav, msg, …)
│   ├── repository/            # 24 repository interfaces (Video, User, Auth, Danmaku, …)
│   ├── player/                # PlayerFactory, MediaSource, PlaybackReporter
│   ├── plugin/                # Plugin interface, PluginRegistry, LocalFilePlugin, DataSource
│   ├── result/                # LoadingState<T> — sealed class (single unified version)
│   ├── account/               # AccountProvider
│   └── utils/                 # Utility classes
├── adapters/bilibili/         # B站 adapter — the only adapter
│   ├── bridge.dart            # BiliBridge.register() — single entry point, registers all DI + HTTP
│   ├── repository/            # Bili*Repository implementations for all 24 core interfaces
│   ├── http/                  # Dio + HTTP/2 adapter (still uses models_new/ types)
│   ├── grpc/                  # Bilibili gRPC endpoints (generated .pb.dart)
│   ├── pages/                 # All B站 UI pages (~60)
│   ├── player/                # bili_player_factory (media_kit wrapper)
│   ├── utils/                 # Cookie jar, extensions, request_utils
│   ├── models/                # Old adapter models (still imported by http/ + utils/)
│   └── models_new/            # Newer adapter model files
├── common/                    # Shared widgets — 0 adapter imports (fully decoupled)
├── utils/                     # Storage (hive_ce), path, platform, theme
├── router/app_pages.dart      # GetX routes: `/` → MainApp + BiliBridge.registerRoutes()
├── scripts/                   # patch.ps1, build.ps1, 16+ .patch files for Flutter SDK
├── build_config.dart          # Reads skf.{code,name,time,hash} from --dart-define
└── main.dart                  # Entry: initHive → GStorage → BiliBridge.register() → run App
```

### Key patterns

- **Bridge + Repository DI**: `BiliBridge.register()` is the sole entry point. It calls `initHive()`, registers ~30 DI bindings via `Get.lazyPut<Interface>(Implementation.new)`, and calls `_initHttp()`. Never import adapter files from core; always use `Get.find<Interface>()`.
- **GetX** throughout: `GetMaterialApp`, `GetPage`, `Get.lazyPut`, `Get.put`, `Get.find`, `Get.toNamed()`.
- **Core→adapter bridge**: When a Core type needs to be passed to a widget expecting an adapter type, use `as dynamic` cast. Both types have the same fields.
- **Architecture boundary**: `lib/core/` and `lib/common/` have **zero** imports from `lib/adapters/`. Verified by grep.

## Key dev commands

| Action | Command |
|--------|---------|
| Analyze | `flutter analyze` — must stay **0 errors, 0 warnings** (~254 info-level issues pre-existing) |
| Test | `flutter test` — **72 tests** across 24 repository test files |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` |
| Mock codegen | Same command — generates `*.mocks.dart` in `test/repository/` |
| Fix warnings | `dart fix --apply` (auto-fixes prefer_const_*, trailing comma, etc.) |
| JNI bindings | `dart run tool/jnigen.dart` → `lib/utils/android/bindings.g.dart` |
| Icons | `dart run flutter_launcher_icons` |
| Splash | `dart run flutter_native_splash:create` |

## Build & release

**Version injection** (CI only): `lib/scripts/build.ps1 <platform>` writes `skf_release.json` with `{skf.name, skf.code, skf.hash, skf.time}`, read by `BuildConfig` via `String.fromEnvironment`.

- **Android**: `flutter build apk --release --split-per-abi --dart-define-from-file=skf_release.json`
- **Windows**: `fastforge package --platform windows --targets exe --flutter-build-args="dart-define-from-file=skf_release.json"` (fastforge + Inno Setup; Chinese lang at `windows/packaging/exe/ChineseSimplified.isl`)
- **CI**: `.github/workflows/build.yml` orchestrates 5 platform builds

**Flutter SDK patching**: `lib/scripts/patch.ps1 <platform>` MUST run before build. Applies 16+ local `.patch` files. Indexed to Flutter 3.44.6 — changing version breaks patches.

## Dependencies

Many packages are git-forked under `bggRGjQaUbCoE` or `My-Responsitories`:
- `get` (GetX fork `version_4.7.2`), `media_kit` & sub-libs (`version_1.2.5`), `cached_network_image_ce`, `catcher_2`, `window_manager`, `file_picker`, `flutter_smart_dialog`, `flutter_sortable_wrap`, `canvas_danmaku`, `font_awesome_flutter`, `super_sliver_list`, `extended_nested_scroll_view`, `desktop_webview_window`

See `dependency_overrides` in `pubspec.yaml` — many packages have both a regular dep and an override.

## Testing

- **24 repository test files** in `test/repository/` — 72 tests total (3 per repo: happy + error + edge).
- Uses `mockito: ^5.7.0` + `build_runner`. Each test file has a corresponding `*.mocks.dart`.
- `*.mocks.dart` files are **gitignored** — regenerate with `dart run build_runner build`.
- Pattern: `test/repository/<name>_test.dart` using `@GenerateMocks([Bili*Repository])`.

## Gotchas

- **Storage init order**: `GStorage.init()` after `BiliBridge.initHive()`. Exits on failure.
- **`.gitignore`**: Uses `test_results/` (not `test*`) to avoid ignoring `test/` dir. `*.mocks.dart` is gitignored.
- **`distribute_options.yaml`**: Output `dist/` for fastforge.
- **`lib/core/di/service_registry.dart`**: Deprecated — all DI through GetX.
- **`.omo/`**: Boulder state, work plans, session continuations. Not for code.
- **Rebranding complete**: `pili_release.json` gitignored; use `skf_release.json`.
- **Root cleanup done**: `_analyze_errors.txt`, `temp_non_shim_files.txt`, 8 refactoring `.ps1` scripts deleted.

## Platform quirks

- **Android**: MaxScreenSize + FlutterDisplayMode for high-refresh.
- **iOS**: Connectivity monitoring for network switching.
- **Windows**: WebViewEnvironment for flutter_inappwebview.
- **Desktop**: window_manager with saved window size/position.
- **Mobile**: Edge-to-edge system UI, transparent bars.
