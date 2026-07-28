# Task 6: Decouple match_repository.dart and music_repository.dart

## Goal
Replace adapter imports in `match_repository.dart` and `music_repository.dart` with core model imports.

## Changes Made

### Core model files (already existed from previous attempt)
- `lib/core/models/match_contest.dart` — Contains `Season`, `MatchTeam`, `MatchContest` with `fromJson`
- `lib/core/models/music_types.dart` — Contains `Artist`, `SongHeat`, `HotSongHeat`, `MusicComment`, `MusicDetail`, `LabelList`, `BgmRecommend` with `fromJson`

### Core repository interfaces (imports changed)
- `lib/core/repository/match_repository.dart` — Changed import from `adapters/bilibili/models_new/match/match_info/contest.dart` to `core/models/match_contest.dart`
- `lib/core/repository/music_repository.dart` — Changed import from `adapters/bilibili/models_new/music/bgm_detail.dart` and `bgm_recommend_list.dart` to `core/models/music_types.dart`

### Adapter repository implementations (conversion layer added)
- `lib/adapters/bilibili/repository/bili_match_repository.dart` — Added `_toCore()` conversion from adapter `MatchContest` to core `MatchContest`; uses `show MatchHttp` to prevent type leakage
- `lib/adapters/bilibili/repository/bili_music_repository.dart` — Added `_detailToCore()`, `_artistToCore()`, `_hotSongHeatToCore()`, `_songHeatToCore()`, `_commentToCore()`, `_recommendToCore()`, `_labelToCore()` conversion methods; uses `show MusicHttp` to prevent type leakage

### Adapter pages (imports changed to core models)
- `lib/adapters/bilibili/pages/match_info/controller.dart` — Changed import to `core/models/match_contest.dart`
- `lib/adapters/bilibili/pages/match_info/view.dart` — Changed import to `core/models/match_contest.dart`
- `lib/adapters/bilibili/pages/music/controller.dart` — Changed import to `core/models/music_types.dart`
- `lib/adapters/bilibili/pages/music/view.dart` — Changed import to `core/models/music_types.dart`
- `lib/adapters/bilibili/pages/music/video/controller.dart` — Changed import to `core/models/music_types.dart`
- `lib/adapters/bilibili/pages/music/video/view.dart` — Changed import to `core/models/music_types.dart`
- `lib/adapters/bilibili/pages/music/widget/music_video_card_h.dart` — Changed import to `core/models/music_types.dart`

### Test files (imports changed to core models)
- `test/repository/match_repository_test.dart` — Changed import to `core/models/match_contest.dart`
- `test/repository/music_repository_test.dart` — Changed import to `core/models/music_types.dart`

## Verification

### Adapter imports in core repository interfaces
```
grep "import.*adapters/bilibili" lib/core/repository/match_repository.dart → 0 matches
grep "import.*adapters/bilibili" lib/core/repository/music_repository.dart → 0 matches
```

### flutter analyze
```
0 errors (434 info-level issues, all pre-existing)
```

### flutter test
```
72/72 tests passed
```

### build_runner
```
dart run build_runner build → succeeded, mocks regenerated with core model imports
```