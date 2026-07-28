# Fix Runtime Type Mismatches — 11 View Crash Sites

## Problem
Core* types and adapter types have incompatible runtime types. `as dynamic` bypasses compile checks but crashes at runtime.

## Root Cause
Core video model hierarchy (`CoreBaseVideoItemModel` etc.) lacks `toJson()` methods and stores nested data as `Map<String, dynamic>`, while adapter models use typed objects (`BaseOwner`, `BaseStat`, etc.).

## Strategy (user-approved)
1. Add `toJson()` to Core* video item types with proper Map output
2. Ensure format matches adapter `fromJson()` expectations
3. The existing `model_converters.dart` then works correctly

## Tasks

### 1. Add toJson() to Core video hierarchy
**Files:** `lib/core/models/video_types.dart`

Add `toJson()` to:
- `CoreBaseVideoItemModel` — base fields + owner/stat/dimension as Maps
- `CoreBaseRcmdVideoItemModel` — add goto, uri, rcmdReason, param, pgcBadge
- `CoreRcmdVideoItemModel` — no extra fields
- `CoreRcmdVideoItemAppModel` — add talkBack, cardType, threePoint
- `CoreHotVideoItemModel` — add all extra fields

Each `toJson()` must produce output compatible with the corresponding adapter `fromJson()`.

### 2. Verify model_converters output
Check `lib/adapters/bilibili/utils/model_converters.dart` produces Maps matching adapter `fromJson()` expectations. Focus on:
- `three_point_v2` format (list of type/reasons items)
- `rcmd_reason` format
- `owner`/`stat` as Maps not objects

### 3. Fix rcmd converter three_point_v2
The current converter:
```dart
'three_point_v2': core.threePoint!['dislikeReasons'],
```
This passes the wrong structure. Need to pass the full `threePoint` map or restructure it.

## Verification
```powershell
flutter analyze 2>&1 | Select-String "^  error" | Measure-Object -Line
flutter test
flutter run -d windows
```

## TODOs
1. [x] Add toJson() to Core video types in `video_types.dart`
2. [x] Fix model_converters.dart: three_point_v2 format
3. [x] Verify + commit: flutter analyze 0 errors + flutter test pass

## Commit
```
fix: add toJson() to Core video types + fix runtime type conversion
```
