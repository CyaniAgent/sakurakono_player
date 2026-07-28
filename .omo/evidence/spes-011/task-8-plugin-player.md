# Task 8 — Wire Plugin/DataSource into PlayerFactory

## Goal
Add optional `DataSource?` parameter to `PlayerFactory.create()` so plugins can supply media via `DataSource.toMediaSource()`.

## Changes

### 1. `lib/core/player/player_factory.dart` (interface)
- Added `import 'package:skf/core/plugin/data_source.dart';`
- Changed signature: `VideoPlayerController create()` → `VideoPlayerController create({DataSource? dataSource})`

### 2. `lib/adapters/bilibili/player/bili_player_factory.dart` (adapter)
- Added `import 'package:skf/core/plugin/data_source.dart';`
- Updated override: `create({DataSource? dataSource})` — ignores the param (B站 adapter doesn't use plugins)

## Design Decisions
- **Backward compatible** — optional named parameter, all existing call sites compile without changes
- **Conversion at call site** — `DataSource.toMediaSource()` is called externally, not inside the factory
- **No other files touched** — PluginRegistry, LocalFilePlugin, and plugin UI remain unchanged

## Verification

### `flutter analyze`
- **0 errors**, 431 issues total (all pre-existing warnings/infos, as documented in AGENTS.md ~370 info-level)

### `flutter test`
- **57 passed, 5 failed** — all 5 failures are pre-existing compilation errors in `bili_download_repository.dart` (`adapter` prefix not imported), entirely unrelated to this change
- The 3 documented DanmakuFilterRepository tests are among the passing tests
