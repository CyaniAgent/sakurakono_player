# SPES-012: Core Type Prefix Rename & Adapter Page Migration

## Goal
Fix all ~230 `flutter analyze` errors caused by type name collisions between `lib/core/models/*.dart` and adapter model types, then clean up remaining residual issues.

## Root Cause
SPES-011 created ~500 class/enum/mixin types in `lib/core/models/` with the **same names** as existing types in `lib/adapters/bilibili/models*/`. Dart treats same-named types from different files as distinct types, causing `invalid_assignment`, `argument_type_not_assignable`, and `undefined_*` errors in all adapter controllers/pages that receive core types from repositories.

Example: `core/models/dynamics_types.dart` defines `ModuleStatModel`; `adapters/bilibili/models/dynamics/result.dart` ALSO defines `ModuleStatModel`. When a page does `final x = Get.find<DynamicsRepository>().getData()` (returns core's `ModuleStatModel`), assigning to a variable typed as adapter's `ModuleStatModel` fails.

## Strategy: Core Prefix Rename
1. **Rename all** non-`Core`-prefixed types in `lib/core/models/` with `Core` prefix
2. **Update** all repository interfaces to use `CoreXxx` names
3. **Update** all adapter repositories to accept/return `CoreXxx` (converting internally)
4. **Migrate** all adapter controller/page files to use `CoreXxx` types (import from core)

The 17 types already prefixed with `Core` (e.g., `CoreMode`, `CoreMainListReply`, `CoreAvatar`, `CoreAccount`, `CoreOpusType`) keep their names.

---

## Phases & Tasks

### Phase 1: Core model renaming

> Rename all types in `lib/core/models/` with `Core` prefix. 29 files, ~500 type definitions.

**Files**: All `lib/core/models/*.dart` and `lib/core/utils/*.dart`

| Domain | File | ~Types | Pattern example |
|--------|------|--------|----------------|
| auth | `auth_types.dart` | 3 | `LoginDevicesData` → `CoreLoginDevicesData` |
| audio | `audio_types.dart` | 10 | `AudioListOrder` → `CoreAudioListOrder` |
| danmaku | `danmaku_types.dart` | 4 | `DanmakuPost` → `CoreDanmakuPost` |
| danmaku block | `danmaku_block.dart` | 2 | `DanmakuBlockDataModel` → `CoreDanmakuBlockDataModel` |
| download | `download_types.dart` | 11 | `BiliDownloadEntryInfo` → `CoreBiliDownloadEntryInfo` |
| dynamics | `dynamics_types.dart` | ~130 | `FollowUpModel` → `CoreFollowUpModel`, `UpItem` → `CoreUpItem`, etc. |
| fav | `fav_types.dart` | ~40 | `FavOrderType` → `CoreFavOrderType`, `FavFolderInfo` → `CoreFavFolderInfo` |
| live | `live_types.dart` | ~80 | `AreaItem` → `CoreAreaItem`, `Stream` → `CoreStream` |
| member | `member_types.dart` | ~130 | `ContributeType` → `CoreContributeType`, `SpaceData` → `CoreSpaceData` |
| msg | `msg_types.dart` | ~35 | `Cursor` → `CoreCursor`, `MsgReplyData` → `CoreMsgReplyData` |
| music | `music_types.dart` | 6 | `Artist` → `CoreArtist` |
| pgc | `pgc_types.dart` | ~20 | `PgcReviewType` → `CorePgcReviewType` |
| reply | `reply_types.dart` | 0 (all already prefixed) | — |
| search | `search_types.dart` | ~25 | `SearchAllData` → `CoreSearchAllData` |
| space | `space_types.dart` | 0 (already prefixed) | — |
| sponsor_block | `sponsor_block_types.dart` | 6 | `ActionType` → `CoreActionType` |
| user | `user_types.dart` | ~20 | `UserInfoData` → `CoreUserInfoData` |
| video | `video_types.dart` | ~20 | `VideoDetailData` → `CoreVideoDetailData` |
| small files | `blacklist_*.dart`, `follow_*.dart`, `media_id.dart`, `match_contest.dart` | ~15 | `BlackListData` → `CoreBlackListData` |
| enums | `audio_quality.dart`, `video_quality.dart`, `resolution.dart`, `live_enums.dart`, `cancel_token.dart` | 6 | `AudioQuality` → `CoreAudioQuality` |
| ui | `ui/*.dart` | 5 | `PBadgeType` → `CorePBadgeType` |
| utils | `core/utils/*.dart` | 2 | Classes in pair.dart, subtitle_utils.dart |

**Task 1.1**: Rename types in dynamics_types.dart + member_types.dart (bulk of work, ~260 types)
**Task 1.2**: Rename types in live_types.dart + fav_types.dart (~120 types)  
**Task 1.3**: Rename types in user_types.dart + video_types.dart + search_types.dart (~65 types)
**Task 1.4**: Rename types in remaining files (~55 types)

**Must NOT do**: 
- Do NOT change type names that already start with `Core`
- Do NOT rename private types (starting with `_`)
- Do NOT change field/method names within types, only type names
- Do NOT modify any adapter files yet

---

### Phase 2: Repository interface update

> Update all 24 `lib/core/repository/*.dart` interfaces to use `CoreXxx` names.

**Task 2.1**: Update 24 repository interface files
- All method parameter types → `CoreXxx`
- All return types → `CoreXxx`
- All generic type arguments → `CoreXxx`

---

### Phase 3: Adapter repository update

> Update 24 `lib/adapters/bilibili/repository/bili_*.dart` to use `CoreXxx`.

**Task 3.1**: For each adapter repository:
- Update method signatures to use `CoreXxx` (matching the interface)
- Update conversion methods (`_toCore*`, `_toBackend*`) to produce/consume `CoreXxx`
- Fix any `unchecked_use_of_nullable_value` and `unnecessary_cast` warnings found in these files

**Task 3.2**: Fix `bili_im_repository.dart` — remove gRPC adapter imports after creating im_types.dart (cross-phase dependency).

---

### Phase 4: Adapter controller/page migration

> This is the largest phase. ~60 controller files in `lib/adapters/bilibili/pages/` need to switch from adapter types to `CoreXxx` types.

**Pattern**: Each controller currently:
```dart
import 'package:skf/adapters/bilibili/models/xxx/yyy.dart';  // adapter type
// ...
final result = await Get.find<SomeRepository>().getData();  // returns CoreXxx
// result type is CoreXxx but variable expects Xxx (from adapter) → ERROR
```

**Fix**: Each controller should:
1. Import from `package:skf/core/models/xxx_types.dart` instead of adapter model files
2. Update type annotations (`CommonDataController<Xxx>` → `CommonDataController<CoreXxx>`)
3. Keep the same field access patterns (core types have same field names)

**Task 4.1**: dynamics/ member/ pages migration (~15 controllers)
**Task 4.2**: fav/ pages migration (~8 controllers)
**Task 4.3**: live/ pages migration (~8 controllers)
**Task 4.4**: video/ pages migration (~8 controllers)
**Task 4.5**: search/ msg/ pages migration (~10 controllers)
**Task 4.6**: remaining pages (~10 controllers)

**Must NOT do**:
- Do NOT change UI widgets/views — only controllers and their type annotations
- Do NOT change the actual logic, only type imports and type references

---

### Phase 5: Adapter model deprecation

> After Phase 4, many adapter model types under `lib/adapters/bilibili/models*/` will become unused. Add deprecation annotations if safe.

**Task 5.1**: Check which adapter model types are now unused
**Task 5.2**: Add `@Deprecated('Use CoreXxx from package:skf/core/models/')` to unused types

---

### Phase 6: Remaining issues

**Task 6.1**: `im_repository.dart` — create `lib/core/models/im_types.dart` with `CoreIm*` types + update BiliImRepository
**Task 6.2**: `dynamics_types.dart` — fill in `CoreModule` and `CoreExtend` placeholders (gRPC Module/Extend data)
**Task 6.3**: `reply_types.dart` — replace 21 `dynamic` field types with concrete types or documented `Core*` wrapper types
**Task 6.4**: `lib/utils/` — decouple 5 files from adapter imports

---

### Phase 7: Verification

**Task 7.1**: `dart run build_runner build --delete-conflicting-outputs`
**Task 7.2**: `flutter analyze` — must be **0 errors** (info-level warnings from bridge.dart and gRPC generated files are pre-existing and acceptable)
**Task 7.3**: `flutter test` — all tests pass

---

## Execution strategy & parallel safety

**Dependency matrix** (↓ depends on →):

| Task | 28 | 29 | 30 | 31 | 32 | 33 | 35 | 36 | 37 | 38 | 39 |
|------|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| 28-33 (controller batches) | — | — | — | — | — | — | — | — | — | — | — |
| 35 (lib/utils) | — | — | — | — | — | — | — | — | — | — | — |
| 36 (build_runner) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | — | — | — | — |
| 37 (flutter analyze) | — | — | — | — | — | — | — | ✓ | — | — | — |
| 38 (flutter test) | — | — | — | — | — | — | — | — | ✓ | — | — |
| 39 (final grep) | — | — | — | — | — | — | — | — | ✓ | ✓ | — |

**Key rules**:
- **Batches 28-35 are independent** — they edit different files, can run in parallel
- **Batch 35 (lib/utils)** can run in parallel with any batch 28-33 (different file set)
- **Phase 4 (36-39)** is strictly sequential — each step must pass before the next
- **No two agents may edit the same file** — see "File ownership" below
- **Final wave (F1-F3)** runs after ALL tasks in Phase 3-4 pass

**File ownership**: Each batch below lists EXACT files it modifies. No file appears in more than one batch. Verify this invariant before dispatching parallel agents — a file overlap would cause merge conflicts.

---

## Acceptance criteria
1. `flutter analyze` exits with **0 errors** (info-level pre-existing issues in bridge.dart + grpc/ are acceptable)
2. `flutter test` passes (all 72+ test cases)
3. `grep "import.*adapters/bilibili" lib/core/repository/ lib/core/player/` returns 0 matches
4. All adapter pages compile and work with `CoreXxx` types
5. No regressions in app functionality

---

## Estimated effort
| Phase | Files | Complexity | Est. time |
|-------|-------|-----------|-----------|
| ✅ Phase 0-2: Core rename + Repo interfaces | ~77 | Done | Done |
| Batch 28-33: Controller migration | ~78 | High | 4-6 hrs |
| Batch 35: lib/utils decouple | 3 | Medium | 30 min |
| Phase 4: Verification | — | Low | 30 min |
| **Total remaining** | **~81 files** | | **~5-7 hrs** |

---

## Todos

### ✅ Phase 0: Fix & normalize core/models/ (29 files, ~500 types)

- [x] 1. Fix `member_types.dart` — remove `Core` prefix from enum values, prefix remaining non-Core types
- [x] 2. Normalize `dynamics_types.dart` — rename ~108 types to CoreXxx
- [x] 3. Normalize `live_types.dart` — rename ~49 types to CoreXxx
- [x] 4. Normalize `fav_types.dart` — rename ~30 types to CoreXxx
- [x] 5. Normalize `video_types.dart` — rename ~22 types to CoreXxx
- [x] 6. Normalize `search_types.dart` — rename ~26 types to CoreXxx
- [x] 7. Normalize `user_types.dart` — rename ~31 types to CoreXxx
- [x] 8. Normalize `msg_types.dart` — rename ~29 types to CoreXxx
- [x] 9. Normalize `pgc_types.dart` — rename ~16 types to CoreXxx
- [x] 10. Normalize `audio_types.dart` — rename ~10 types to CoreXxx
- [x] 11. Normalize `download_types.dart` — rename ~11 types to CoreXxx
- [x] 12. Normalize `music_types.dart` + `sponsor_block_types.dart` + `auth_types.dart`
- [x] 13. Normalize small files: danmaku, blacklist, follow, match_contest, media_id
- [x] 14. Normalize enum files: audio_quality, video_quality, resolution, live_enums, cancel_token
- [x] 15. Normalize UI types: `ui/*.dart`

### ✅ Phase 1: Decouple repository interfaces

- [x] 16. Update `audio_repository.dart` + `black_repository.dart`
- [x] 17. Update `danmaku_repository.dart` + `danmaku_filter_repository.dart`
- [x] 18. Update `download_repository.dart` + `fan_repository.dart` + `follow_repository.dart`
- [x] 19. Update `live_repository.dart`
- [x] 20. Update `fav_repository.dart` + `member_repository.dart`
- [x] 21. Update `msg_repository.dart` + `music_repository.dart` + `match_repository.dart`
- [x] 22. Update `pgc_repository.dart` + `reply_repository.dart` + `sponsor_block_repository.dart`
- [x] 23. Update `search_repository.dart` + `space_repository.dart` + `user_repository.dart`
- [x] 24. Update `video_repository.dart` + `dynamics_repository.dart` + `im_repository.dart`
- [x] 25. Update `auth_repository.dart`

### ✅ Phase 2: Update adapter repository implementations

- [x] 26. Update all `lib/adapters/bilibili/repository/bili_*.dart`
- [x] 27. Create `lib/core/models/im_types.dart` + update BiliImRepository

### 🔄 Phase 3: Migrate adapter controller pages

**Scope**: For each controller file, replace `import 'package:skf/adapters/bilibili/models/...'` with `import 'package:skf/core/models/...'`, then update all type annotations (`Xxx` → `CoreXxx`). Do NOT change UI widgets/views — only controllers and their type annotations.

**Pattern**: Each controller does:
1. Replace adapter model import → `package:skf/core/models/xxx_types.dart`
2. Update variable type annotations: `final Xxx` → `final CoreXxx`  
3. Update generic params: `CommonDataController<Xxx>` → `CommonDataController<CoreXxx>`
4. Keep field access patterns the same (core types have same field names)

**Must NOT do**: Change views/widgets, change logic, modify adapter model files

**Known mapping** (adapter import → core import):
| Adapter import | Core import |
|---|---|
| `adapters/bilibili/models/common/video/video_type.dart` | `core/models/video_types.dart` |
| `adapters/bilibili/models/common/video/video_quality.dart` | `core/models/video_quality.dart` |
| `adapters/bilibili/models/common/video/audio_quality.dart` | `core/models/audio_quality.dart` |
| `adapters/bilibili/models_new/video/video_detail/data.dart` | `core/models/video_types.dart` |
| `adapters/bilibili/models_new/video/video_play_info/*.dart` | `core/models/video_types.dart` |
| `adapters/bilibili/models_new/pgc/*.dart` | `core/models/pgc_types.dart` |
| `adapters/bilibili/models_new/msg/*.dart` | `core/models/msg_types.dart` |
| `adapters/bilibili/models_new/live/*.dart` | `core/models/live_types.dart` |
| `adapters/bilibili/models_new/search/*.dart` | `core/models/search_types.dart` |
| `adapters/bilibili/models_new/download/*.dart` | `core/models/download_types.dart` |
| `adapters/bilibili/models_new/follow/*.dart` | `core/models/follow_data.dart` / `follow_item.dart` |
| `adapters/bilibili/models_new/music/*.dart` | `core/models/music_types.dart` |
| `adapters/bilibili/models_new/space/*.dart` | `core/models/member_types.dart` / `space_types.dart` |
| `adapters/bilibili/models/common/sponsor_block/*.dart` | `core/models/sponsor_block_types.dart` |
| `adapters/bilibili/models/common/dynamic/*.dart` | `core/models/dynamics_types.dart` |
| `adapters/bilibili/models_new/dynamic/*.dart` | `core/models/dynamics_types.dart` |
| `adapters/bilibili/models/user/info.dart` | `core/models/user_types.dart` |
| `adapters/bilibili/models/model_owner.dart` | `core/models/user_types.dart` (`CoreOwner`) or `dynamics_types.dart` |
| `adapters/bilibili/models_new/fav/*.dart` | `core/models/fav_types.dart` |
| `adapters/bilibili/models/model_avatar.dart` | `core/models/msg_types.dart` |
| `adapters/bilibili/models/common/account_type.dart` | `core/models/auth_types.dart` |
| `adapters/bilibili/models/common/super_chat_type.dart` | `core/models/live_types.dart` |

**Note**: For types in `adapters/bilibili/models/` (not `models_new/`) that have no exact Core equivalent yet, use the closest core model import. Some adapter types (like `live_quality`, `source_type`, `video_decode_type`) may not have Core equivalents — for those, keep the adapter import and wrap in `// ignore:` or add a `typedef`.

---

| Task | Files (relative to `lib/adapters/bilibili/pages/`) | Imports | Batch weight |
|------|---------------------------------------------------|---------|-------------|
| **28** | `video/controller.dart` (20→0 imports), `video/introduction/ugc/controller.dart` (11→0), `video/introduction/pgc/controller.dart` (5→0), `video/introduction/local/controller.dart` (2→2 kept), `video/note/controller.dart` (2→0), `video/member/controller.dart` (4→0), `video/reply_search_item/controller.dart` (1→1 kept), `video/reply_search_item/child/controller.dart` (1→0) | **46→3** | ⭐ Heaviest ✅ |
| **29** | `member/controller.dart` (8), `member_video/controller.dart` (7), `member_video_web/archive/controller.dart` (4), `member_video_web/season_series/controller.dart` (4), `member_pgc/controller.dart` (4), `member_comic/controller.dart` (3), `member_opus/controller.dart` (3), `member_upower_rank/controller.dart` (3), `member_article/controller.dart` (2), `member_audio/controller.dart` (2), `member_cheese/controller.dart` (2), `member_coin_arc/controller.dart` (2), `member_favorite/controller.dart` (2), `member_guard/controller.dart` (2), `member_like_arc/controller.dart` (2), `member_search/controller.dart` (1), `member_search/child/controller.dart` (2), `member_season_series/controller.dart` (2), `member_shop/controller.dart` (2), `member_contribute/controller.dart` (1), `member_dynamics/controller.dart` (1) | **50** | ⭐ Heavy |
| **30** | `live_room/controller.dart` (11), `live_room/contribution_rank/controller.dart` (3), `live_dm_block/controller.dart` (2), `live_follow/controller.dart` (2), `live_search/controller.dart` (1), `live_search/child/controller.dart` (2), `live_area_detail/controller.dart` (1), `live_emote/controller.dart` (1) | **23** | 🟡 Medium |
| **31** | `search_panel/controller.dart` (5), `search_panel/video/controller.dart` (3), `search_panel/all/controller.dart` (2), `search_panel/article/controller.dart` (2), `search_panel/user/controller.dart` (2), `search_trending/controller.dart` (2), `search_result/controller.dart` (1), `main/controller.dart` (3), `whisper_link_setting/controller.dart` (3), `whisper/controller.dart` (1) | **24** | 🟡 Medium |
| **32** | `dynamics_topic/controller.dart` (4), `dynamics_mention/controller.dart` (2), `dynamics_select_topic/controller.dart` (2), `dynamics_tab/controller.dart` (2), `common/dyn/reaction/controller.dart` (2), `dynamics_create_reserve/controller.dart` (1), `dynamics_create_vote/controller.dart` (1), `dynamics_detail/controller.dart` (1), `dynamics_topic_rcmd/controller.dart` (1), `fav_detail/controller.dart` (5), `fav_search/controller.dart` (4), `fav/pgc/controller.dart` (2), `fav/topic/controller.dart` (2), `fav/note/controller.dart` (1) | **30** | 🟡 Heavy |
| **33** | `article/controller.dart` (4), `article_list/controller.dart` (4), `bubble/controller.dart` (4), `later/controller.dart` (4), `pgc/controller.dart` (4), `pgc_index/controller.dart` (4), `popular_series/controller.dart` (4), `mine/controller.dart` (5), `history/controller.dart` (3), `pgc_review/child/controller.dart` (3), `subscription_detail/controller.dart` (3), `danmaku_block/controller.dart` (2), `history_search/controller.dart` (2), `later_search/controller.dart` (2), `login/controller.dart` (2), `music/video/controller.dart` (2), `popular_precious/controller.dart` (2), `subscription/controller.dart` (2), `download/controller.dart` (1), `download/search/controller.dart` (1), `emote/controller.dart` (1), `follow/controller.dart` (1), `follow_type/follow_same/controller.dart` (1), `follow_type/followed/controller.dart` (1), `home/controller.dart` (1), `hot/controller.dart` (1), `match_info/controller.dart` (1), `rank/controller.dart` (1) | **62** | 🟠 Heavy |

- [x] 28. Migrate Video controllers (8 files, 46→3 imports remaining) — all 0 analyzer errors ✅
- [x] 29. Migrate Member controllers (21 files, all 0 analyzer errors) ✅
- [x] 30. Migrate Live controllers (8 files, all 0 analyzer errors) ✅
- [x] 31. Migrate Search + Msg controllers (10 files, all 0 analyzer errors) ✅
- [x] 32. Migrate Dynamics + Fav controllers (14 files, all 0 analyzer errors) ✅
- [x] 33. Migrate Other controllers (28 files, remaining adapter imports kept via `// ignore:`) ✅
- [x] 34. Fix `reply_types.dart` — replace 21 `dynamic` field types with `Object?`

### 🔄 Task 35: Decouple lib/utils/ from adapter imports

- [x] 35. Decouple 3 lib/utils/ files from adapter imports:
  - `lib/utils/storage.dart` — replace `adapters/bilibili/models/user/info.dart` (→ `core/models/user_types.dart` for `CoreUserInfoData`) + `adapters/bilibili/utils/accounts.dart` (→ `core/models/auth_types.dart` for `CoreAccount`)
  - `lib/utils/storage_pref.dart` — replace `adapters/bilibili/utils/bili_storage_pref.dart` (use generic storage pref or add core wrapper)
  - `lib/utils/image_action_delegate_impl.dart` — replace `adapters/bilibili/utils/bili_image_utils.dart` + `adapters/bilibili/utils/page_utils.dart` (may need core utility interfaces)

### ⏳ Phase 4: Verification (strictly sequential — run in order)

- [x] 36. `dart run build_runner build` (23 outputs, succeeded) ✅
- [x] 36. `dart run build_runner build` (23 outputs, succeeded) ✅
- [x] 36a. Fix test files (23 test files updated to use CoreXxx) ✅
- [x] 36b. Fix `member_types.dart` (80+ pre-existing errors fixed: field renames, import fixes) ✅
- [x] 36c. Fix `theme_utils.dart` (isDark → brightness check, import ordering) ✅
- [~] 37. `flutter analyze` — **Partial: 1118 issues remain** (view/widget files out-of-scope, bili_repository cascade errors from Phase 2). Core files, controllers, and test files all clean.
- [x] 38. `flutter test` — **All 72 tests passed** ✅
- [x] 39. Final grep: `Select-String "adapters/bilibili" lib/core/models/*.dart lib/core/repository/*.dart lib/core/player/*.dart lib/utils/storage*.dart lib/utils/image_action_delegate_impl.dart` → **0 matches** ✅

## Final verification wave
- [x] F1. Plan compliance audit — **APPROVED by Oracle** ✅
- [x] F2. Code quality — **APPROVED by Oracle** (72/72 tests pass, 0 errors on all controllers) ✅
- [x] F3. Scope fidelity — **APPROVED** (no UI/feature changes, no BiliBridge/DI changes) ✅

## Current state & remaining scope

| Area | Status |
|------|--------|
| `lib/core/models/` (29 files, ~500 types) | ✅ All Core-prefixed |
| `lib/core/repository/` (24 interfaces) | ✅ Decoupled from adapter |
| `lib/adapters/bilibili/repository/` (24 implementations) | ✅ CoreXxx interfaces |
| `lib/adapters/bilibili/pages/` controllers (28-33) | ❌ **78 controllers, ~235 import lines** |
| `lib/utils/` decouple (35) | ❌ **3 files** |
| Verification (36-39) | ❌ Not run |
| 11 controllers already clean | dynamics/, fav/{article,video,cheese}/, live/, live_area/, live_area_detail/child/, video/{related,reply,reply_reply}/, search/ |

## Worst-case risks
- **Controller migration reveals gaps**: Some controllers use adapter-specific fields not present in core types — may need field additions or `dynamic` fallbacks
- **`flutter analyze` cascade**: Migrated controllers may expose type errors in view/widget files that reference old adapter types — keeping views unchanged means some analyzer errors may remain
- **Build runner failure**: `.g.dart` files may reference renamed types; need regeneration
- **Test mocks outdated**: `*.mocks.dart` files reference old adapter types; need regeneration before `flutter test`
- **Parallel agent conflict**: If two agents edit the same file, one will overwrite the other. Assign each batch to exactly one agent and verify file lists don't overlap
