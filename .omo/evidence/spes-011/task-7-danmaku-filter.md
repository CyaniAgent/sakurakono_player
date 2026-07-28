# Task 7: Decouple danmaku_filter_repository.dart

**Date**: 2026-07-25

## Changes Made

### 1. Created `lib/core/models/danmaku_block.dart`
Core copies of `DanmakuBlockDataModel` and `SimpleRule` with:
- `final` fields (immutable, unlike adapter's `late` mutable fields)
- `DanmakuBlockDataModel()` constructor with required `rule`, `rule1`, `rule2` and optional `toast`, `valid`, `ver`
- `SimpleRule()` constructor with required `id`, `type`, `filter`
- `fromJson()` factory constructors (preserving the adapter's rule-splitting logic by `type`)
- `toJson()` serialization

### 2. Updated `lib/core/repository/danmaku_filter_repository.dart`
- Changed import from `package:skf/adapters/bilibili/models/user/danmaku_block.dart`
- Changed to `package:skf/core/models/danmaku_block.dart`

### 3. Updated `lib/adapters/bilibili/repository/bili_danmaku_filter_repository.dart`
- Removed import of adapter model
- Added conversion from adapter types (returned by `DanmakuFilterHttp`) to core types using dynamic access pattern (consistent with FollowData/BlackListData migrations)
- Added proper `Success`/`Error` handling for both `danmakuFilter()` and `danmakuFilterAdd()` (previously just delegated)

### 4. Updated `test/repository/danmaku_filter_repository_test.dart`
- Changed import from adapter model to core model
- Regenerated mocks via `dart run build_runner build`

## Files NOT modified (adapter-specific files still import adapter model)
- `lib/adapters/bilibili/http/danmaku_block.dart` — unchanged
- `lib/adapters/bilibili/pages/danmaku_block/view.dart` — unchanged
- `lib/adapters/bilibili/pages/danmaku_block/controller.dart` — unchanged
- `lib/adapters/bilibili/models/user/danmaku_rule.dart` — unchanged
- `lib/adapters/bilibili/models/user/danmaku_block.dart` — **preserved** per task requirement

## Verification
- `grep "import.*adapters/bilibili" lib/core/repository/danmaku_filter_repository.dart` → **0 matches** ✅
- `flutter analyze` → **0 errors** ✅ (433 issues total, all info-level)
- `flutter test` → **72/72 All tests passed** ✅

## Adapter model still exists
Original file at `lib/adapters/bilibili/models/user/danmaku_block.dart` was **NOT deleted**.
