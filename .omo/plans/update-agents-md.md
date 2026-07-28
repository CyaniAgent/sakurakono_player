# Update AGENTS.md

## Overview

Rewrite `AGENTS.md` to be a compact, high-signal instruction file for future OpenCode sessions. Based on thorough repo investigation (pubspec.yaml, analysis_options.yaml, main.dart, bridge.dart, CI workflows, build/patch scripts, lib/core architecture, .gitignore, .omo dir, test dir).

## Scope

- Replace current `AGENTS.md` (88 lines, mixed signal) with a more compact version.
- Remove stale/obvious claims (e.g. "camel_case_types" — that's a Dart default).
- Add critical missing facts: build versioning (`skf_release.json`), fastforge Windows build, SDK patching requirement, `.omo/` directory purpose, MCP server config, actual test status, `dependency_overrides` details.

## Plan (1 task)

- [x] 1. Write `AGENTS.md` — 报告式项目标识说明、SDK/环境要求、lint规则摘要、架构图（含Bridge+Repository DI模式）、关键命令速查表、构建/发布流程（含Flutter SDK patch注意事项）、依赖项特殊说明、关键注意事项（init顺序、gitignore、gRPC排除、distribute_options等）、测试说明、平台差异。

## Proposed content

```markdown
# AGENTS.md — SakuraKono Player / skf

## Identity

- **SakuraKono Player Framework (SKF)**: A Bilibili video player Flutter app. `pubspec.yaml name: skf`. Android package: `com.sakurakono.app`.
- Rebranding from PiliPlus is **complete**. All `package:` imports use `skf` prefix (`package:skf/...`).

## SDK & env

- **Flutter 3.44.6 / Dart `>=3.12.0`** — pinned in `.fvmrc` and `pubspec.yaml`. Use `fvm flutter` if FVM is configured.
- Dart MCP server required for code intelligence: `opencode.jsonc` configures `dart mcp-server`.

## Linting & formatting

`analysis_options.yaml` extends `package:flutter_lints/flutter.yaml`. Rules you will hit:

- `always_use_package_imports` / `avoid_relative_lib_imports` — **all imports must be `package:skf/...`**, never relative.
- `prefer_const_constructors`, `prefer_const_declarations`, `prefer_const_literals_to_create_immutables`.
- `unnecessary_late`, `unnecessary_async`, `unnecessary_await_in_return`.
- `camel_case_types`, `camel_case_extensions`.
- `formatter: trailing_commas: preserve` — do not add/remove trailing commas.

Also enforced: `avoid_print`, `cascade_invocations`, `sized_box_for_whitespace`.

## Architecture

```
lib/
├── core/                      # Abstract interfaces (adapter-independent)
│   ├── account/account_provider.dart
│   ├── app_meta.dart          # Centralized app metadata (branding)
│   ├── player/                # VideoPlayerController, MediaSource, PlayerFactory, PlaybackReporter
│   ├── repository/            # 24 repository interfaces (Video, User, Auth, Danmaku, …)
│   ├── result/loading_state.dart  # Unified LoadingState<T> — sealed class
│   └── plugin/                # Plugin, PluginRegistry, DataSource, LocalFilePlugin
├── adapters/bilibili/         # B站 adapter — the only adapter
│   ├── bridge.dart            # BiliBridge.register() — single entry point, registers all DI + HTTP
│   ├── repository/            # Bili*Repository implementations for all 24 core interfaces
│   ├── http/                  # Dio + HTTP/2 adapter
│   ├── grpc/                  # Bilibili gRPC endpoints (generated .pb.dart files)
│   ├── player/bili_player_factory.dart
│   ├── plugin/pl_player/      # Wrapper around media_kit
│   ├── pages/                 # All B站 UI pages
│   ├── services/              # audio_service, download_service, service_locator
│   ├── utils/                 # Accounts (cookie jar), extensions, request_utils
│   ├── tcp/live.dart          # Live streaming protocol
│   └── models/ + models_new/  # Dart models with .g.dart generated files
├── router/app_pages.dart      # GetX routes: \`/\` → MainApp + BiliBridge.registerRoutes()
├── common/                    # Shared widgets (some still have adapter imports)
├── utils/                     # Storage (hive_ce), path, platform, theme, cache_manager
├── scripts/                   # patch.ps1, build.ps1, 16+ .patch files for Flutter SDK
├── build_config.dart          # Reads skf.{code,name,time,hash} from --dart-define
└── main.dart                  # Entry: init hive → GStorage → BiliBridge.register() → run App
```

### Key pattern: Bridge + Repository DI

The sole adapter entry point is `BiliBridge.register()` which:
1. Calls `initHive()` — registers Hive adapters
2. Registers ~30 DI bindings via `Get.lazyPut<Interface>(Implementation.new)`
3. Calls `_initHttp()` — initializes Dio and syncs history status

Never import adapter files from core; always use `Get.find<Interface>()`.

### State management

- **GetX** throughout: `GetMaterialApp`, `GetPage`, `Get.lazyPut`, `Get.put`, `Get.find`, `Get.toNamed()`.
- Routes: `lib/router/app_pages.dart` merges \`/\` (MainApp) with `BiliBridge.registerRoutes()` (~60 pages).

## Key dev commands

| Action | Command |
|--------|---------|
| Analyze | `flutter analyze` — must stay **0 errors** (~370 info-level issues pre-existing) |
| Test | `flutter test` — currently 3 tests in `test/repository/danmaku_filter_repository_test.dart` |
| Codegen | `dart run build_runner build --delete-conflicting-outputs` |
| JNI bindings | `dart run tool/jnigen.dart` → `lib/utils/android/bindings.g.dart` |
| Icons | `dart run flutter_launcher_icons` |
| Splash | `dart run flutter_native_splash:create` |

## Build & release

**Version injection** (CI only): `lib/scripts/build.ps1 <platform>` writes `skf_release.json` with `{skf.name, skf.code, skf.hash, skf.time}`, read by `BuildConfig` via `String.fromEnvironment`.

- **Android**: `flutter build apk --release --split-per-abi --dart-define-from-file=skf_release.json`
- **Windows**: `fastforge package --platform windows --targets exe --flutter-build-args="dart-define-from-file=skf_release.json"` (fastforge + Inno Setup; Chinese lang file at `windows/packaging/exe/ChineseSimplified.isl`)
- **CI**: `.github/workflows/build.yml` orchestrates 5 platform builds

**Flutter SDK patching**: `lib/scripts/patch.ps1 <platform>` MUST be run before build. It cherry-picks commits, reverts unwanted ones, and applies 16+ local `.patch` files (bottom sheet, scroll view, navigator, text field, text selection, image anim, layout builder, FAB, popup menu, etc.). Indexed to Flutter 3.44.6 — changing version breaks patches.

## Dependencies

Many packages are git-forked under `bggRGjQaUbCoE` or `My-Responsitories`:
- `get` (GetX fork `version_4.7.2`), `media_kit` & all sub-libs (`version_1.2.5`), `cached_network_image_ce`, `catcher_2`, `window_manager`, `file_picker`, `flutter_smart_dialog`, `flutter_sortable_wrap`, `canvas_danmaku`, `font_awesome_flutter`, `super_sliver_list`, `extended_nested_scroll_view`, `desktop_webview_window`

See `dependency_overrides` in `pubspec.yaml` — many packages have both a regular dep and an override.

## Gotchas

- **Storage init order**: `GStorage.init()` after `BiliBridge.initHive()`. Exits on failure.
- **`.gitignore` line 152**: `test_results/` — do NOT add `test*` which would ignore `test/` dir.
- **gRPC generated files excluded** from analysis in `analysis_options.yaml`.
- **`distribute_options.yaml`**: Output `dist/` for fastforge.
- **`lib/core/di/service_registry.dart`**: Deprecated — all DI through GetX.
- **`.omo/`**: Boulder state, work plans, session continuations. Not for code.

## Testing

- `flutter_test` + `mockito: ^5.7.0` + `build_runner`. 1 test file, 3 tests (DanmakuFilterRepository).
- Follow pattern: `test/repository/<name>_test.dart` + generated `*.mocks.dart`.
- Run codegen after adding mockito annotations.

## Platform quirks

- **Android**: MaxScreenSize + FlutterDisplayMode for high-refresh.
- **iOS**: Connectivity monitoring for network switching.
- **Windows**: WebViewEnvironment for flutter_inappwebview.
- **Desktop**: window_manager with saved window size/position.
- **Mobile**: Edge-to-edge system UI, transparent bars.
```

## Verification

- `flutter analyze` — 0 errors (pre-existing baseline)
- File diff: only `AGENTS.md` changed
