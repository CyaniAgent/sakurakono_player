# Task 4: Decouple download_repository.dart

**Date**: 2026-07-25
**SPES**: 011
**Task**: P1b — Migrate download models to core/models/

## Changes Made

### 1. Created `lib/core/models/download_types.dart`
Core copies of all model types used in `DownloadRepository`:
- `BiliDownloadEntryInfo` — pure data class (no `MultiSelectData` mixin, no UI methods)
- `PageInfo`, `SourceInfo`, `EpInfo` — pure data classes
- `DownloadStatus` — enum
- `BiliDownloadMediaInfo` — sealed class hierarchy with `Type1`, `Type1PlayerCodecConfig`, `Type1Segment`, `Type2`, `Type2File`, `None`
- All classes have `fromJson`/`toJson` serialization
- Adapter-specific dependencies removed (no `MultiSelectData`, no `PlatformUtils`, no Flutter widgets)

### 2. Updated `lib/core/repository/download_repository.dart`
- Changed imports from adapter models to `package:skf/core/models/download_types.dart`
- No method signature changes

### 3. Updated `lib/adapters/bilibili/repository/bili_download_repository.dart`
- Added adapter→core and core→adapter conversion methods
- Uses `import as adapter` for adapter models to avoid name collision
- Converts core types to adapter types before calling `DownloadHttp.getVideoUrl()`
- Converts adapter result types back to core types

### 4. Updated `test/repository/download_repository_test.dart`
- Changed imports from adapter models to `package:skf/core/models/download_types.dart`

### 5. Regenerated mocks
- Ran `dart run build_runner build` — mock file now imports from core models

## Verification

### Adapter import check
```bash
grep "import.*adapters/bilibili" lib/core/repository/download_repository.dart
→ 0 matches (clean)
```

### Dart analyze (changed files)
```bash
dart analyze lib/core/models/download_types.dart
→ No issues found
```

### Tests
```bash
flutter test test/repository/download_repository_test.dart
→ 3/3 tests passed
```

## Files Not Deleted
- Original adapter model files preserved:
  - `lib/adapters/bilibili/models_new/download/bili_download_entry_info.dart`
  - `lib/adapters/bilibili/models_new/download/bili_download_media_file_info.dart`