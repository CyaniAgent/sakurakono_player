# AGENTS.md — lib/utils (Storage / Theme / Platform / Version)

CHILD of root AGENTS.md. Global rules, CI, and dependency forks live there — not here.

## OVERVIEW

50 Dart files: cross-cutting plumbing — Hive storage layer (the #1 init-order gotcha), Pref typed facade, path/platform/theme helpers, Dart extensions.

## STRUCTURE

| Path | Files | Content |
|---|---|---|
| root | 34 | storage.dart, storage_pref.dart, storage_key.dart, storage_utils.dart, path_utils.dart, platform_utils.dart, theme_utils.dart, theme_ext.dart, device_utils.dart, cache_manager.dart, danmaku_utils.dart, num/date/duration/color_utils, image_utils, share_utils, permission_handler, feed_back, mobile_observer, max_screen_size, json_file_handler, grid, em, filtering_text, parse_string/int/bool, set_int_adapter, calc_window_position, connectivity_utils, utils.dart, asset_utils, image_action_delegate_impl.dart |
| android/ | 2 | android_helper.dart + bindings.g.dart (jnigen-generated, analysis-excluded) |
| extension/ | 14 | widget_ext, string_ext, num_ext, context_ext, get_ext, box_ext, size_ext, file_ext, map_ext, iterable_ext, scroll_controller_ext, nested_scroll_ext, selectable_region_ext |

## STORAGE LAYER (critical)

- **GStorage** (storage.dart), `abstract final class`. `init()`: `Hive.init(appSupportDirPath/hive)` → `regAdapter()` (SetIntAdapter) → `Future.wait` opens **7 boxes in PARALLEL**: userInfo, localCache, setting, historyWord, video, account (private), watchProgress (`Box<int>` with custom desc-key comparator); conditionally opens reply (`Box<Uint8List>`) if `setting['saveReply']==true`. Also `exportAllSettings`/`importAllJsonSettings`, `compact()`, `close()`, `clear()`.
- **Init order** (main.dart): `_initAppPath()` → `adapter.onAppStartPreStorage()` (TypeAdapters MUST precede box opens; OttoHub: none) → `GStorage.init()` → `adapter.onAppStart()` → `_initDownPath`/`_initTmpPath`/`CacheManager.ensureInitialized()` in parallel → `AdapterRegistry.register+activate`.
- **Pref** (storage_pref.dart, ~860ln): typed getters/setters over GStorage boxes — THE way to read/write settings (Pref.themeMode, Pref.uiScale, Pref.downloadPath, Pref.themeMode…). Never touch raw boxes from feature code.
- **Keys** (storage_key.dart): SettingBoxKey const keys(已去 B 站专属键), LocalCacheKey 4, VideoBoxKey 5.

## PATH / PLATFORM / THEME / VERSION

- **path_utils.dart**: late finals tmpDirPath, appSupportDirPath, downloadPath; PathUtils consts (videoNameType1 `'0.mp4'`, videoNameType2 `'video.m4s'`, audioNameType2 `'audio.m4s'`, danmakuName `'danmaku.pb'`, downloadDir `'download'`).
- **platform_utils.dart**: PlatformUtils.isMobile/isDesktop via `@pragma("vm:platform-const")` (compile-time fold).
- **theme_utils.dart**: ThemeUtils.getThemeData(ColorScheme, isDynamic, isDark) builds full M3 ThemeData (dynamic_color, custom AppBar/SnackBar/Dialog/BottomSheet/Card themes); `darkenTheme()` for pure-black dark mode. theme_ext.dart: ColorSchemeExt.isLight/isDark/freeColor (0xFFFF7F24 / 0xFFD66011).
- **BuildConfig is NOT here** — it's `lib/build_config.dart`: reads skf.code/name/time/hash via `(int|String).fromEnvironment` with prefix `AppMeta.buildConfigPrefix='skf'` (`lib/core/app_meta.dart`). `skf_release.json` written by `lib/scripts/build.ps1`, injected via `--dart-define-from-file`.

## CONVENTIONS

- `abstract final class` for all statics-only utilities (GStorage, Pref, ThemeUtils, PlatformUtils, PathUtils, BuildConfig).
- Storage access: Pref (typed) > GStorage box getters > raw box. Const string keys grouped per box class.
- Extensions live in extension/, one file per target type.

## ANTI-PATTERNS

- NEVER reorder storage init: Hive adapter registration (BiliBridge.initHive) before GStorage.init before Accounts.init — violations crash at startup.
- Do not import adapters into utils (verified clean). utils imports common in only 4 files (theme_utils→style, storage_pref→gesture widget, grid→skeleton/video_card_h, image_utils→constants) — keep this direction rare.
- bindings.g.dart is generated — never hand-edit; regenerate via `dart run tool/jnigen.dart` (commit-pinned dart-lang/native).
- No build.yaml exists project-wide (mockito builder config ships in-package) — don't add one unless a custom builder requires it.

## WHERE TO LOOK

| Task | Location |
|---|---|
| Read/write a setting | Pref.\<name\> (add key to storage_key.dart first) |
| Storage init / boxes | storage.dart |
| Paths / download naming | path_utils.dart |
| Theme customization | theme_utils.dart + common/style.dart |
| Build / version info | lib/build_config.dart (via AppMeta prefix) |
