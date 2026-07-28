# Task 15 — P3f: Decouple `live_repository.dart`

**Status**: ✅ Complete  
**Date**: 2026-07-25  
**Commit**: (pending)

## What was done

### 1. Created `lib/core/models/live_enums.dart`
- `LiveContributionRankType` enum (values: `unknown`, `gold`, `silver`, `bronze`)
- `LiveSearchType` enum (values: `room`, `user`)

### 2. Created `lib/core/models/live_types.dart`
All 16+ models with `fromJson`/`toJson`:
- `RoomPlayInfoData`, `RoomInfoH5Data`, `DanmakuMsg`, `LiveDmInfoData`, `LiveEmoteDatum`
- `LiveIndexData`, `LiveFollowData`, `LiveSecondData`, `AreaList`, `AreaItem`
- `LiveSearchData`, `ShieldInfo`, `ShieldUserList`, `SuperChatData`, `SuperChatItem`
- `SuperChatUserInfo`, `LiveContributionRankData`, `MedalWallData`
- Plus sub-models: `PlayUrlInfo`, `Stream`, `Format`, `Codec`, `UrlInfo`, `CardLiveItem`, `LiveSecondTag`, `UinfoMedal`, `MedalInfo`, `CardData`, `CardListItem`, `CardDataItem`, `WatchedShow`, `FollowItem`, `ShieldRule`, `HostList`, `Emoticon`, `RoomItem`, `RoomInfo`, `AnchorInfo`, `BaseInfo`, `UserItem`, `ContributionRankItem`, `MedalWallItem`

### 3. Updated `lib/core/repository/live_repository.dart`
- Replaced 18 adapter imports with 2 core model imports (`live_enums.dart`, `live_types.dart`)
- Verified: `grep "import.*adapters/bilibili" lib/core/repository/live_repository.dart` → 0 matches

### 4. Updated `lib/adapters/bilibili/repository/bili_live_repository.dart`
- Added labeled adapter imports (`as adapter`)
- Created `_mapState<TAdapter, TCore>()` helper function
- Created 16+ standalone `_toCore*` conversion functions
- Created enum conversion extensions (`toAdapter()`)
- Replaced all `.toCore()` extension method calls with conversion functions
- Fixed `SuperChatUserInfo` → `UserInfo` adapter class name mismatch

## Verification

### `flutter analyze` on all 4 files: 0 errors
```
Analyzing 4 items...
11 issues found. (info-level only — unnecessary_await, cascade_invocations)
```

### Adapter import check: PASS
```
grep "import.*adapters/bilibili" lib/core/repository/live_repository.dart → 0 matches
```

## Files modified
- `lib/core/models/live_enums.dart` — **created**
- `lib/core/models/live_types.dart` — **created**
- `lib/core/repository/live_repository.dart` — **modified** (imports only)
- `lib/adapters/bilibili/repository/bili_live_repository.dart` — **modified** (conversion functions)