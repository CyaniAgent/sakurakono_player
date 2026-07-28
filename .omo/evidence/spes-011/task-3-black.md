# SPES-011 Task 3: Black Repository Decoupling

## Status: ✅ Complete

## Changes

### New files
- `lib/core/models/blacklist_data.dart` — Core `BlackListData` model with `fromJson`, no adapter dependencies
- `lib/core/models/blacklist_item.dart` — Core `BlackListItem` model with `fromJson`, no adapter dependencies

### Modified files
- `lib/core/repository/black_repository.dart` — Changed import from `package:skf/adapters/bilibili/models_new/blacklist/data.dart` to `package:skf/core/models/blacklist_data.dart`
- `lib/adapters/bilibili/repository/bili_black_repository.dart` — Added core model imports, added adapter→core type conversion in `blackList()` method body (removed direct passthrough to `BlackHttp`)
- `lib/adapters/bilibili/pages/blacklist/controller.dart` — Changed imports from adapter models to core models
- `lib/adapters/bilibili/pages/blacklist/view.dart` — Changed import from adapter `BlackListItem` to core `BlackListItem`
- `test/repository/black_repository_test.dart` — Changed import from adapter `BlackListData` to core `BlackListData`

### Regenerated
- `test/repository/black_repository_test.mocks.dart` — Regenerated via `build_runner`, now references core model

## Verification

| Check | Result |
|-------|--------|
| `grep "import.*adapters/bilibili" lib/core/repository/black_repository.dart` | 0 matches ✅ |
| `flutter analyze` — errors | 0 errors ✅ |
| `flutter test` | 72/72 pass ✅ |

## Pattern

Follows the same pattern as P2 (FollowData migration):
1. Create core model copies without adapter dependencies
2. Update interface imports to use core models
3. Add adapter→core type conversion in implementation using `dynamic` field access
4. Update controller/view/test imports
5. Regenerate mocks
