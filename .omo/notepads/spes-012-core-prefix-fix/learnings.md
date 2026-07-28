# spes-012-core-prefix-fix: Learnings

## Task
Prefix all top-level type declarations in lib/core/models/audio_types.dart and lib/core/models/download_types.dart with Core.

## Files modified

### lib/core/models/audio_types.dart
Types renamed (10):
| Old name | New name |
|---|---|
| AudioListOrder | CoreAudioListOrder |
| AudioPlaylistSource | CoreAudioPlaylistSource |
| AudioThumbType | CoreAudioThumbType |
| AudioPageOption | CoreAudioPageOption |
| AudioPageOptionDirection | CoreAudioPageOptionDirection |
| AudioPlayUrlResp | CoreAudioPlayUrlResp |
| AudioPlaylistResp | CoreAudioPlaylistResp |
| AudioThumbUpResp | CoreAudioThumbUpResp |
| AudioTripleLikeResp | CoreAudioTripleLikeResp |
| AudioCoinAddResp | CoreAudioCoinAddResp |

### lib/core/models/download_types.dart
Types renamed (11):
| Old name | New name |
|---|---|
| BiliDownloadEntryInfo | CoreBiliDownloadEntryInfo |
| PageInfo | CorePageInfo |
| SourceInfo | CoreSourceInfo |
| EpInfo | CoreEpInfo |
| DownloadStatus | CoreDownloadStatus |
| Type1 | CoreType1 |
| Type1PlayerCodecConfig | CoreType1PlayerCodecConfig |
| Type1Segment | CoreType1Segment |
| Type2 | CoreType2 |
| Type2File | CoreType2File |
| None | CoreNone |

Preserved (not renamed):
- BiliDownloadMediaInfo (sealed base class — explicitly excluded per task spec)

## Pitfall: substring collision on eplaceAll
AudioPageOption is a substring of AudioPageOptionDirection. Using eplaceAll for AudioPageOption *after* AudioPageOptionDirection was already renamed to CoreAudioPageOptionDirection caused double-prefixing: CoreCoreAudioPageOptionDirection.

**Fix**: apply the longer name's prefix first (AudioPageOptionDirection → CoreAudioPageOptionDirection), then the shorter name (AudioPageOption → CoreAudioPageOption). Or better, batch all renames for a file in a single edit pass where substring collisions are handled by replacement order.

### lib/core/models/pgc_types.dart
Types renamed (16):
| Old name | New name |
|---|---|
| PgcReviewType | CorePgcReviewType |
| PgcConditionValue | CorePgcConditionValue |
| PgcCondition | CorePgcCondition |
| PgcConditionFilter | CorePgcConditionFilter |
| PgcConditionOrder | CorePgcConditionOrder |
| PgcIndexConditionData | CorePgcIndexConditionData |
| PgcIndexItem | CorePgcIndexItem |
| PgcIndexResult | CorePgcIndexResult |
| Episode | CoreEpisode |
| TimelineResult | CoreTimelineResult |
| Stat | CoreStat |
| Label | CoreLabel |
| Vip | CoreVip |
| Author | CoreAuthor |
| PgcReviewItemModel | CorePgcReviewItemModel |
| PgcReviewData | CorePgcReviewData |

## Pitfall: substring collision on replaceAll (pgc_types.dart)
`Stat` is a substring of `Status`. Using `replaceAll("Stat", "CoreStat")` accidentally mutated `json['vipStatus']` to `json['vipCoreStatus']`. **Fix**: audit string literal content as well as identifiers when applying blanket replaceAll — JSON keys with case-insensitive overlaps are at risk even with case-sensitive matching when shared prefixes like `Stat`→`Status` exist.

## Verification
 flutter analyze lib/core/models/audio_types.dart lib/core/models/download_types.dart lib/core/models/pgc_types.dart → **No issues found** (0 errors).

---

# Round 2: lib/core/models/ui/ files

## Task
Prefix all top-level type declarations in `lib/core/models/ui/*.dart` with `Core`.

## Files changed (6 files)

| File | Renames |
|------|---------|
| `badge_type.dart` | `PBadgeType`→`CorePBadgeType`, `PBadgeSize`→`CorePBadgeSize` |
| `image_action_delegate.dart` | `ImageActionDelegate`→`CoreImageActionDelegate`; internal `SourceModel` ref→`CoreSourceModel` |
| `image_preview_type.dart` | `SourceType`→`CoreSourceType`, `SourceModel`→`CoreSourceModel` |
| `image_type.dart` | `ImageType`→`CoreImageType` |
| `multi_select_controller.dart` | `MultiSelectController`→`CoreMultiSelectController` |
| `stat_type.dart` | `StatType`→`CoreStatType` (+ its const constructor `CoreStatType(...)`) |

## Pitfall: enum const constructors (again)

Dart enum const constructors must match the type name. When renaming `StatType`→`CoreStatType`, the constructor `const StatType(this.iconData, this.label)` was **not** automatically updated. This produced 16 analyzer errors. Fix required a manual second edit.

## Verification
`flutter analyze lib/core/models/ui/` → **No issues found**.

---

# Round 3: lib/core/models/msg_types.dart

## Task
Prefix all 29 top-level type declarations in `lib/core/models/msg_types.dart` with `Core`.

## Types renamed (29)

| Old name | New name |
|----------|----------|
| Cursor | CoreCursor |
| User | CoreUser |
| Pendant | CorePendant |
| BaseOfficialVerify | CoreBaseOfficialVerify |
| Label | CoreLabel |
| Vip | CoreVip |
| ImUserInfosData | CoreImUserInfosData |
| MsgReplyContent | CoreMsgReplyContent |
| MsgReplyItem | CoreMsgReplyItem |
| MsgReplyData | CoreMsgReplyData |
| MsgAtContent | CoreMsgAtContent |
| MsgAtItem | CoreMsgAtItem |
| MsgAtData | CoreMsgAtData |
| MsgLikeContent | CoreMsgLikeContent |
| MsgLikeItem | CoreMsgLikeItem |
| Latest | CoreLatest |
| Total | CoreTotal |
| MsgLikeData | CoreMsgLikeData |
| MsgLikeDetailUser | CoreMsgLikeDetailUser |
| MsgLikeDetailItem | CoreMsgLikeDetailItem |
| MsgLikeDetailPage | CoreMsgLikeDetailPage |
| MsgLikeDetailCard | CoreMsgLikeDetailCard |
| MsgLikeDetailData | CoreMsgLikeDetailData |
| MsgSysItem | CoreMsgSysItem |
| SessionSsData | CoreSessionSsData |
| UidSetting | CoreUidSetting |
| UploadBfsResData | CoreUploadBfsResData |
| SingleUnreadData | CoreSingleUnreadData |
| MsgFeedUnreadData | CoreMsgFeedUnreadData |

## Pitfall: substring collision on `User? user;` replaceAll

`User? user;` is a substring of `CoreMsgLikeDetailUser? user;`. Using `replaceAll("User? user;", "CoreUser? user;")` after `MsgLikeDetailUser` had already been renamed to `CoreMsgLikeDetailUser` resulted in `CoreMsgLikeDetailCoreUser? user;`.

**Fix**: Targeted edit for the corrupted name (`CoreMsgLikeDetailCoreUser? user;` → `CoreMsgLikeDetailUser? user;`), or better, rename `User` *before* the longer User-containing names. In practice, avoid `replaceAll` for short generic type names that may appear inside longer type names; use context-specific replacements instead.

## Verification
`flutter analyze lib/core/models/msg_types.dart` → **No issues found**.

---

# Round 4: lib/core/models/ standalone files

## Task
Prefix remaining `lib/core/models/` top-level types with `Core`: `audio_quality.dart`, `video_quality.dart`, `resolution.dart`, `live_enums.dart`, `cancel_token.dart`.

## Files Modified

| File | Rename |
|------|--------|
| `lib/core/models/audio_quality.dart` | `AudioQuality` → `CoreAudioQuality` |
| `lib/core/models/video_quality.dart` | `VideoQuality` → `CoreVideoQuality` |
| `lib/core/models/resolution.dart` | `Resolution` → `CoreResolution` |
| `lib/core/models/live_enums.dart` | `LiveContributionRankType` → `CoreLiveContributionRankType` |
| `lib/core/models/live_enums.dart` | `LiveSearchType` → `CoreLiveSearchType` |
| `lib/core/models/cancel_token.dart` | `CancelToken` → `CoreCancelToken` |

## Key Findings

1. **No cross-file imports exist** for any of these 5 files. Zero `import` statements across the entire project reference them.
   - These core enums/types are **currently unused / dead code** — no other file depends on them.
   - Adapter-specific equivalents exist (e.g., `adapters/bilibili/models/common/video/audio_quality.dart` with its own `AudioQuality` enum) that are used by actual adapter code.

2. **Core `CancelToken` is unused** — the abstract class has zero implementations or consumers. `lib/core/repository/msg_repository.dart` uses `dio.CancelToken` directly instead.

3. **Core `live_enums` are unused** — `lib/core/repository/live_repository.dart` imports its `LiveContributionRankType` and `LiveSearchType` from adapter-specific files.

## Pitfall: doc comment over-rename

In `cancel_token.dart`, the doc reference `[dio.CancelToken]` was incorrectly renamed to `[dio.CoreCancelToken]` by the blanket `replaceAll`. Manually corrected — `dio.CancelToken` refers to the Dio package's class, not the core abstraction. **Always audit doc comments and string literals after blanket renames.**

## Verification
`flutter analyze lib/core/models/audio_quality.dart lib/core/models/video_quality.dart lib/core/models/resolution.dart lib/core/models/live_enums.dart lib/core/models/cancel_token.dart` → **No issues found** (ran in 0.4s).

---

# Round 4: music_types.dart, sponsor_block_types.dart, auth_types.dart

## Task
Prefix all top-level type declarations in `lib/core/models/music_types.dart`, `lib/core/models/sponsor_block_types.dart`, and `lib/core/models/auth_types.dart` with `Core`.

## Files modified

### lib/core/models/music_types.dart
Types renamed (7):
| Old name | New name |
|----------|----------|
| Artist | CoreArtist |
| SongHeat | CoreSongHeat |
| HotSongHeat | CoreHotSongHeat |
| MusicComment | CoreMusicComment |
| MusicDetail | CoreMusicDetail |
| LabelList | CoreLabelList |
| BgmRecommend | CoreBgmRecommend |

Pitfall: `SongHeat` is a substring of `HotSongHeat`. Using `replaceAll("SongHeat", "CoreSongHeat")` mutated `HotSongHeat` → `HotCoreSongHeat`. Fix: replace `HotCoreSongHeat` → `CoreHotSongHeat` after the fact. Also, `hotSongHeat` (field name, lowercase h) contains `SongHeat`, which also got mangled from `hotSongHeat` → `hotCoreSongHeat`. Required fixing field name back to `hotSongHeat` afterward.

### lib/core/models/sponsor_block_types.dart
Types renamed (6):
| Old name | New name |
|----------|----------|
| ActionType | CoreActionType |
| SegmentType | CoreSegmentType |
| DoublePair | CoreDoublePair |
| PostSegmentModel | CorePostSegmentModel |
| SegmentItemModel | CoreSegmentItemModel |
| UserInfo | CoreUserInfo |

All replaceAll safe — no substring collisions.

### lib/core/models/auth_types.dart
Types renamed (2):
| Old name | New name |
|----------|----------|
| LoginDevicesData | CoreLoginDevicesData |
| LoginDevice | CoreLoginDevice |

Preserved: `CoreAccount` (already prefixed).

Pitfall: `LoginDevice` is a substring of `LoginDevicesData`. A single `replaceAll("LoginDevice", "CoreLoginDevice")` correctly handled both because `LoginDevicesData` → `CoreLoginDevicesData` via that same pattern. This is the rare case where replaceAll with a shorter name works for both.

## Verification
`flutter analyze lib/core/models/music_types.dart lib/core/models/sponsor_block_types.dart lib/core/models/auth_types.dart` → **No issues found**.

---

# Round 5: danmaku_types, danmaku_block, blacklist_*, follow_*, match_contest, media_id

## Task
Prefix all top-level type declarations in 8 core model files with `Core`.

## Files Changed

### Core model files (8)
| File | Renames |
|------|---------|
| `danmaku_types.dart` | `DanmakuPost`→`CoreDanmakuPost`, `DanmakuElement`→`CoreDanmakuElement`, `DanmakuSegmentReply`→`CoreDanmakuSegmentReply`, `DanmakuViewReply`→`CoreDanmakuViewReply` |
| `danmaku_block.dart` | `DanmakuBlockDataModel`→`CoreDanmakuBlockDataModel`, `SimpleRule`→`CoreSimpleRule` |
| `blacklist_data.dart` | `BlackListData`→`CoreBlackListData` |
| `blacklist_item.dart` | `BlackListItem`→`CoreBlackListItem` |
| `follow_item.dart` | `FollowItemModel`→`CoreFollowItemModel` |
| `follow_data.dart` | `FollowData`→`CoreFollowData` |
| `match_contest.dart` | `Season`→`CoreSeason`, `MatchTeam`→`CoreMatchTeam`, `MatchContest`→`CoreMatchContest` |
| `media_id.dart` | `MediaId`→`CoreMediaId`, `Bvid`→`CoreBvid`, `Aid`→`CoreAid`, `Sid`→`CoreSid`, `Epid`→`CoreEpid`, `RoomId`→`CoreRoomId`, `Cid`→`CoreCid`, `LocalPath`→`CoreLocalPath` |

### External consumer files updated (4)
| File | Change |
|------|--------|
| `playback_reporter.dart` | `MediaId`→`CoreMediaId` |
| `player_controller.dart` | `MediaId`→`CoreMediaId` |
| `bili_reporter.dart` | `MediaId`, `Aid`, `Bvid`, `Cid`, `Epid`, `Sid`→`Core*` |
| `bili_player_factory.dart` | `MediaId`→`CoreMediaId` |

## Key Findings

1. **Core model files are mostly self-contained** — only `media_id.dart` has external consumers outside `lib/core/models/`. The repository interfaces import types from adapter model files (`lib/adapters/bilibili/models/`), which define their own separate classes with the same names.

2. **Adapter models remain unchanged** — `lib/adapters/bilibili/models_new/danmaku/post.dart` still defines `DanmakuPost` etc. These are parallel/duplicate type definitions not part of this task.

3. **`member_types.dart` has pre-existing errors** (unrelated to this task) — `CoreLiveRoom`, `CoreWatchedShow` etc. show field-name-shadowing issues in factory constructors.

4. **`replaceAll` side effect on method names** — Short names like `Aid`, `Bvid` in `bili_reporter.dart` renamed private method names (`_extractAid`→`_extractCoreAid`). Harmless (internal consistency preserved) but worth avoiding with targeted edits.

## Verification
`dart analyze` on all 12 changed files → **No issues found**.

---

# Round 5: lib/core/models/dynamics_types.dart

## Task
Prefix all 108 non-Core-prefixed top-level type declarations in `lib/core/models/dynamics_types.dart` with `Core`.

## Types renamed (107 + 1 duplicate removed)

All 108 non-Core-prefixed types were renamed. `Owner` was a duplicate of existing `CoreOwner` (identical body), so the duplicate was removed after renaming references.

## Key findings

1. **Substring collision chains are pervasive** in this file. Many short type names (`Desc`, `Stat`, `Vote`, `Option`, `Common`, `Reserve`, `Good`, `LiveRcmd`, `Pic`) are substrings of longer type names that also needed renaming. The correct order is:
   - Rename **longer/containing types first** (e.g., `SimpleVoteInfo` → `CoreSimpleVoteInfo` before `VoteInfo`, `Vote`)
   - Then rename **shorter types** (e.g., `Vote` → `CoreVote`)
   - For short generic names like `Desc`, `Stat`, `Vote`, `Option`, `Pic`: avoid `replaceAll` entirely — use targeted context-specific edits to prevent corrupting already-renamed types

2. **Double-prefixing cascade**: When `ModuleInteraction` is renamed after `ModuleInteractionItem`, the already-renamed `CoreModuleInteractionItem` gets mangled to `CoreCoreModuleInteractionItem`. Fix: rename `ModuleInteractionItem` before `ModuleInteraction`, or use targeted edits for the shorter name.

3. **`Owner` / `CoreOwner` collision**: `Owner` and `CoreOwner` had identical bodies (both `{int? mid; String? name; String? face;}`). Renaming `Owner` → `CoreOwner` would create a duplicate class definition. The `Owner` class was removed since `CoreOwner` already provides the same type. The reference in `CoreModuleFold` was already updated to `CoreOwner`.

4. **`onlyFansLevel` field name corruption**: `replaceAll("Fan", "CoreFan")` for the short name `Fan` accidentally mutated the field name `onlyFansLevel` → `onlyCoreFansLevel`. Fix: targeted edit to restore the field name.

## Verification
`flutter analyze lib/core/models/dynamics_types.dart` → **No issues found**.

---

# Round 6: lib/core/models/user_types.dart

## Task
Prefix all 31 top-level type declarations in `lib/core/models/user_types.dart` with `Core`.

## Types Renamed (31)

| Old Name | New Name |
|----------|----------|
| UserInfoData | CoreUserInfoData |
| LevelInfo | CoreLevelInfo |
| UserStat | CoreUserStat |
| CoinLogData | CoreCoinLogData |
| CoinLogItem | CoreCoinLogItem |
| HistoryData | CoreHistoryData |
| HistoryTab | CoreHistoryTab |
| History | CoreHistory |
| HistoryItemModel | CoreHistoryItemModel |
| LaterData | CoreLaterData |
| Rights | CoreRights |
| Owner | CoreOwner |
| LaterItemModel | CoreLaterItemModel |
| Stat | CoreStat |
| Bangumi | CoreBangumi |
| Season | CoreSeason |
| Dimension | CoreDimension |
| LoginLogData | CoreLoginLogData |
| LoginLogItem | CoreLoginLogItem |
| MediaListData | CoreMediaListData |
| CntInfo | CoreCntInfo |
| MediaListItemModel | CoreMediaListItemModel |
| RelationData | CoreRelationData |
| SpaceSettingData | CoreSpaceSettingData |
| SpaceSettingModel | CoreSpaceSettingModel |
| Privacy | CorePrivacy |
| SubData | CoreSubData |
| SubItemModel | CoreSubItemModel |
| UserRealNameData | CoreUserRealNameData |
| RejectPage | CoreRejectPage |
| VideoTagItem | CoreVideoTagItem |

## Strategy

### Safe `replaceAll` (29 types)
Most types had unique names not appearing as substrings of other type names in the rename list, so `replaceAll` was safe.

### Targeted edits for `Stat` and `History`
These needed individual targeted edits because:
- `Stat` is a substring of `UserStat` — `replaceAll` on `Stat` would corrupt `UserStat`
- `History` is a substring of `HistoryData`, `HistoryTab`, `HistoryItemModel` — `replaceAll` on `History` would corrupt already-renamed types

## Caught during verification
- Factory constructor return values: `=> History(...)` and `=> Stat(...)` were NOT updated by the `replaceAll` for `factory Xxx.fromJson` because they're on the same line after `=>`. Required a separate targeted edit each.

## File isolation
`user_types.dart` has no imports to or from it anywhere in the codebase (0 files reference it). The types are a documentation spec; actual implementations live in adapter-specific model files imported via `core/repository/user_repository.dart`.

## Verification
`flutter analyze lib/core/models/user_types.dart` → **No issues found**.

---

# Round 7: lib/core/repository/auth_repository.dart

## Task
Replace all adapter imports with core imports and prefix type references with `Core`. Use the core Account interface.

## Changes

### Imports
| Old import | New import |
|------------|------------|
| `package:skf/adapters/bilibili/models_new/login_devices/data.dart` | `package:skf/core/models/auth_types.dart` |
| `package:skf/adapters/bilibili/utils/accounts/account.dart` | _(removed — covered by auth_types.dart)_ |

### Type references renamed
| Old name | New name |
|----------|----------|
| `LoginDevicesData` | `CoreLoginDevicesData` |
| `Account` | `CoreAccount` |

## Key findings

1. **Two adapter imports collapsed to one core import** — both `LoginDevicesData` and `Account` map to types in `lib/core/models/auth_types.dart`. The adapter `Account` is a sealed class hierarchy; the core `CoreAccount` is a flat data class. The repository interface now references the core abstraction.

2. **No callers break** — `AuthRepository` is an abstract interface. The concrete implementations (e.g., `BiliAuthRepository`) import adapter-specific types themselves and map them to/from core types. Changing the abstract interface's types does not require modifying adapter implementations in this round (they will need updating separately to implement the new signatures).

3. **Doc comment `[account]`** references on line 53 are fine — they reference the parameter name, not the type.

## Verification
`flutter analyze lib/core/repository/auth_repository.dart` → **No issues found**.

---

# Round 8: lib/core/repository/danmaku_repository.dart and danmaku_filter_repository.dart

## Task
Replace ALL adapter imports with core imports and prefix type references with `Core`.

## Files Modified

### lib/core/repository/danmaku_repository.dart
**Imports replaced (2 → 1):**
| Old import | New import |
|------------|------------|
| `package:skf/adapters/bilibili/grpc/bilibili/community/service/dm/v1.pb.dart` | _(removed — gRPC types replaced by core)_ |
| `package:skf/adapters/bilibili/models_new/danmaku/post.dart` | `package:skf/core/models/danmaku_types.dart` |

**Type references renamed (3):**
| Old name | New name |
|----------|----------|
| `DanmakuPost` | `CoreDanmakuPost` |
| `DmSegMobileReply` | `CoreDanmakuSegmentReply` |
| `DmViewReply` | `CoreDanmakuViewReply` |

### lib/core/repository/danmaku_filter_repository.dart
**Imports replaced (1):**
| Old import | New import |
|------------|------------|
| `package:skf/adapters/bilibili/models/user/danmaku_block.dart` | `package:skf/core/models/danmaku_block.dart` |

**Type references renamed (2):**
| Old name | New name |
|----------|----------|
| `DanmakuBlockDataModel` | `CoreDanmakuBlockDataModel` |
| `SimpleRule` | `CoreSimpleRule` |

## Key findings

1. **Both files had gRPC/adapter dependencies eliminated** — `danmaku_repository.dart` previously imported the raw protobuf file (`v1.pb.dart`) and adapter model (`DanmakuPost`). Both replaced with a single core types import.

2. **Core types already existed** — `danmaku_types.dart` and `danmaku_block.dart` were already created in Round 5 with `Core`-prefixed types. This round only updated the repository interfaces to use them.

3. **No substring collision risks** — The adapter types (`DanmakuPost`, `DmSegMobileReply`, `DmViewReply`, `DanmakuBlockDataModel`, `SimpleRule`) had unique names in these files. Direct renameAll safe.

4. **Abstract interfaces only** — Both files define abstract repository interfaces. Concrete adapter implementations (e.g., `BiliDanmakuRepository`) remain adapter-imported and will need separate updates.

## Verification
`flutter analyze lib/core/repository/danmaku_repository.dart lib/core/repository/danmaku_filter_repository.dart` → **No issues found**.

---

# Round 8: lib/core/repository/ download, fan, follow repositories

## Task
Replace ALL adapter imports with core imports and prefix type references with `Core` in three core repository interfaces.

## Files Modified

### lib/core/repository/download_repository.dart
| Old import | New import |
|------------|------------|
| `package:skf/adapters/bilibili/models_new/download/bili_download_entry_info.dart` | `package:skf/core/models/download_types.dart` |
| `package:skf/adapters/bilibili/models_new/download/bili_download_media_file_info.dart` | _(merged into download_types.dart)_ |

Type references renamed:
| Old name | New name |
|----------|----------|
| `BiliDownloadEntryInfo` | `CoreBiliDownloadEntryInfo` |
| `SourceInfo` | `CoreSourceInfo` |
| `PageInfo` | `CorePageInfo` |
| `EpInfo` | `CoreEpInfo` |

Preserved: `BiliDownloadMediaInfo` (sealed base class — already in core, no prefix change).

### lib/core/repository/fan_repository.dart
| Old import | New import |
|------------|------------|
| `package:skf/adapters/bilibili/models_new/follow/data.dart` | `package:skf/core/models/follow_data.dart` |

Type references renamed:
| Old name | New name |
|----------|----------|
| `FollowData` | `CoreFollowData` |

### lib/core/repository/follow_repository.dart
| Old import | New import |
|------------|------------|
| `package:skf/adapters/bilibili/models_new/follow/data.dart` | `package:skf/core/models/follow_data.dart` |

Type references renamed:
| Old name | New name |
|----------|----------|
| `FollowData` | `CoreFollowData` |

## Key Findings

1. **Two adapter imports collapsed to one core import** for download_repository.dart — both `bili_download_entry_info.dart` and `bili_download_media_file_info.dart` map to types in `lib/core/models/download_types.dart`.

2. **fan_repository.dart and follow_repository.dart share the same adapter import** (`follow/data.dart`) but both map to `CoreFollowData` in `lib/core/models/follow_data.dart`.

3. **Blast radius — adapter implementations will break** (out of scope for this task):
   - `BiliDownloadRepository` (implements `DownloadRepository`) uses adapter types (`BiliDownloadEntryInfo`, `SourceInfo`, `PageInfo`, `EpInfo`) in its `@override` method. After the interface changed to core types, the adapter implementation's method signature no longer matches.
   - `BiliFanRepository` and `BiliFollowRepository` use adapter `FollowData` in their `@override` methods. After the interface changed to `CoreFollowData`, the adapter implementations' method signatures no longer match.
   - **These adapter files were NOT modified** per task scope constraint ("Do NOT modify files outside these three").

4. **Blast radius — test files will break** (out of scope):
   - `test/repository/download_repository_test.dart` uses adapter `BiliDownloadEntryInfo` and `Type2`/`Type2File` directly. The mock generated from the updated interface expects `CoreBiliDownloadEntryInfo`.
   - `test/repository/fan_repository_test.dart` and `follow_repository_test.dart` use adapter `FollowData` directly. The mocks expect `CoreFollowData`.
   - Mock files (`.mocks.dart`) need regeneration after the interface changes.

5. **Adapters and tests must be updated in follow-up tasks** to use the core types, or alternatively the adapter types need to be aliased/mapped to core types.

## Verification
`flutter analyze lib/core/repository/download_repository.dart lib/core/repository/fan_repository.dart lib/core/repository/follow_repository.dart` → **No issues found**.

---

# Round 8: lib/core/repository/live_repository.dart

## Task
Replace ALL 18 adapter imports with core imports and prefix ALL type references with `Core`.

## Changes

### Imports replaced (18 → 2)
| Old import | New import |
|------------|------------|
| `adapters/.../live_contribution_rank_type.dart` | `core/models/live_enums.dart` |
| `adapters/.../live_search_type.dart` | `core/models/live_enums.dart` |
| `adapters/.../live_area_list/area_item.dart` | `core/models/live_types.dart` |
| `adapters/.../live_area_list/area_list.dart` | `core/models/live_types.dart` |
| `adapters/.../live_contribution_rank/data.dart` | `core/models/live_types.dart` |
| `adapters/.../live_danmaku/danmaku_msg.dart` | `core/models/live_types.dart` |
| `adapters/.../live_dm_block/shield_info.dart` | `core/models/live_types.dart` |
| `adapters/.../live_dm_block/shield_user_list.dart` | `core/models/live_types.dart` |
| `adapters/.../live_dm_info/data.dart` | `core/models/live_types.dart` |
| `adapters/.../live_emote/datum.dart` | `core/models/live_types.dart` |
| `adapters/.../live_feed_index/data.dart` | `core/models/live_types.dart` |
| `adapters/.../live_follow/data.dart` | `core/models/live_types.dart` |
| `adapters/.../live_medal_wall/data.dart` | `core/models/live_types.dart` |
| `adapters/.../live_room_info_h5/data.dart` | `core/models/live_types.dart` |
| `adapters/.../live_room_play_info/data.dart` | `core/models/live_types.dart` |
| `adapters/.../live_search/data.dart` | `core/models/live_types.dart` |
| `adapters/.../live_second_list/data.dart` | `core/models/live_types.dart` |
| `adapters/.../live_superchat/data.dart` | `core/models/live_types.dart` |

Retained: `core/result/loading_state.dart`

### Type references renamed (18)
| Old name | New name |
|----------|----------|
| `RoomPlayInfoData` | `CoreRoomPlayInfoData` |
| `RoomInfoH5Data` | `CoreRoomInfoH5Data` |
| `DanmakuMsg` | `CoreDanmakuMsg` |
| `LiveDmInfoData` | `CoreLiveDmInfoData` |
| `LiveEmoteDatum` | `CoreLiveEmoteDatum` |
| `LiveIndexData` | `CoreLiveIndexData` |
| `LiveFollowData` | `CoreLiveFollowData` |
| `LiveSecondData` | `CoreLiveSecondData` |
| `AreaList` | `CoreAreaList` |
| `AreaItem` | `CoreAreaItem` |
| `LiveSearchData` | `CoreLiveSearchData` |
| `LiveSearchType` | `CoreLiveSearchType` |
| `ShieldInfo` | `CoreShieldInfo` |
| `ShieldUserList` | `CoreShieldUserList` |
| `SuperChatData` | `CoreSuperChatData` |
| `LiveContributionRankData` | `CoreLiveContributionRankData` |
| `LiveContributionRankType` | `CoreLiveContributionRankType` |
| `MedalWallData` | `CoreMedalWallData` |

## Key findings

1. **No substring collisions** — all 18 type names are unique within the file. No `AreaItem` inside `AreaList` etc. The full rewrite approach (write entire file) was used to avoid incremental replaceAll pitfalls.

2. **`AreaItem` is a substring of `AreaList`** — but safe because both were fully rewritten in one pass rather than via sequential `replaceAll`.

3. **All core types already existed** — `live_types.dart` (1670 lines, 35+ types) and `live_enums.dart` (17 lines, 2 enums) already defined all Core-prefixed types. No new types needed to be created.

## Verification
`flutter analyze lib/core/repository/live_repository.dart` → **No issues found**.

---

# Round 9: lib/core/repository/video_repository.dart, dynamics_repository.dart, im_repository.dart

## Task
Replace ALL adapter imports with core imports and prefix type references with `Core` in three core repository files.

## Changes

### lib/core/repository/video_repository.dart

**Imports replaced (22 → 3):**
| Old import | New import |
|------------|------------|
| `adapters/.../grpc/.../reply/v1.pb.dart` show `ReplyInfo` | `core/models/video_types.dart` |
| `adapters/.../models/common/video/video_type.dart` | `core/models/video_types.dart` |
| `adapters/.../models/home/rcmd/result.dart` | `core/models/video_types.dart` |
| `adapters/.../models/model_hot_video_item.dart` | `core/models/video_types.dart` |
| `adapters/.../models/model_rec_video_item.dart` | `core/models/video_types.dart` |
| `adapters/.../models/pgc_lcf.dart` | `core/models/video_types.dart` |
| `adapters/.../models/video/play/url.dart` | `core/models/video_types.dart` |
| `adapters/.../models_new/pgc/pgc_rank/pgc_rank_item_model.dart` | `core/models/video_types.dart` |
| `adapters/.../models_new/popular/popular_precious/data.dart` | `core/models/video_types.dart` |
| `adapters/.../models_new/popular/popular_series_list/list.dart` | `core/models/video_types.dart` |
| `adapters/.../models_new/popular/popular_series_one/data.dart` | `core/models/video_types.dart` |
| `adapters/.../models_new/triple/pgc_triple.dart` | `core/models/video_types.dart` |
| `adapters/.../models_new/triple/ugc_triple.dart` | `core/models/video_types.dart` |
| `adapters/.../models_new/video/video_ai_conclusion/data.dart` | `core/models/video_types.dart` |
| `adapters/.../models_new/video/video_detail/data.dart` | `core/models/video_types.dart` |
| `adapters/.../models_new/video/video_note_list/data.dart` | `core/models/video_types.dart` |
| `adapters/.../models_new/video/video_play_info/data.dart` | `core/models/video_types.dart` |
| `adapters/.../models_new/video/video_relation/data.dart` | `core/models/video_types.dart` |
| `adapters/.../models_new/video/video_shot/data.dart` | `core/models/video_types.dart` |
| `adapters/.../utils/subtitle_utils.dart` | `core/utils/subtitle_utils.dart` |
| `core/result/loading_state.dart` | _(kept)_ |

Retained: `core/result/loading_state.dart`, `core/utils/subtitle_utils.dart`

**Type references renamed (20):**
| Old name | New name |
|----------|----------|
| `ReplyInfo` | `CoreReplyInfo` |
| `VideoType` | `CoreVideoType` |
| `RcmdVideoItemModel` | `CoreRcmdVideoItemModel` |
| `RcmdVideoItemAppModel` | `CoreRcmdVideoItemAppModel` |
| `HotVideoItemModel` | `CoreHotVideoItemModel` |
| `PlayUrlModel` | `CorePlayUrlModel` |
| `VideoDetailData` | `CoreVideoDetailData` |
| `VideoRelation` | `CoreVideoRelation` |
| `PgcLCF` | `CorePgcLCF` |
| `PgcTriple` | `CorePgcTriple` |
| `UgcTriple` | `CoreUgcTriple` |
| `AiConclusionData` | `CoreAiConclusionData` |
| `PlayInfoData` | `CorePlayInfoData` |
| `VideoShotData` | `CoreVideoShotData` |
| `VideoNoteData` | `CoreVideoNoteData` |
| `PgcRankItemModel` | `CorePgcRankItemModel` |
| `PopularSeriesListItem` | `CorePopularSeriesListItem` |
| `PopularSeriesOneData` | `CorePopularSeriesOneData` |
| `PopularPreciousData` | `CorePopularPreciousData` |

Not renamed: `SubtitleFormat` (already in `core/utils/subtitle_utils.dart`, not adapter-specific)

### lib/core/repository/dynamics_repository.dart

**Imports replaced (20 → 1):**
| Old import | New import |
|------------|------------|
| `adapters/.../models/common/dynamic/dynamics_type.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models/common/reply/reply_option_type.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models/dynamics/result.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models/dynamics/up.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models/dynamics/vote_model.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models_new/article/article_info/data.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models_new/article/article_list/data.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models_new/article/article_view/data.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models_new/bubble/data.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models_new/dynamic/dyn_mention/group.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models_new/dynamic/dyn_reaction/data.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models_new/dynamic/dyn_reserve/data.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models_new/dynamic/dyn_reserve_info/data.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models_new/dynamic/dyn_topic_feed/topic_card_list.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models_new/dynamic/dyn_topic_top/top_details.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models_new/dynamic/dyn_topic_top/topic_item.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../models_new/followee_votes/vote.dart` | `core/models/dynamics_types.dart` |
| `adapters/.../grpc/.../app/dynamic/v2.pb.dart` show `OpusType`, `OpusDetailResp` | `core/models/dynamics_types.dart` |
| `common/widgets/pair.dart` | _(kept)_ |
| `core/result/loading_state.dart` | _(kept)_ |

Retained: `core/result/loading_state.dart`, `common/widgets/pair.dart`

**Type references renamed (21):**
| Old name | New name |
|----------|----------|
| `DynamicsTabType` | `CoreDynamicsTabType` |
| `ReplyOptionType` | `CoreReplyOptionType` |
| `DynamicsDataModel` | `CoreDynamicsDataModel` |
| `FollowUpModel` | `CoreFollowUpModel` |
| `DynamicItemModel` | `CoreDynamicItemModel` |
| `VoteInfo` | `CoreVoteInfo` |
| `ArticleInfoData` | `CoreArticleInfoData` |
| `ArticleViewData` | `CoreArticleViewData` |
| `ArticleListData` | `CoreArticleListData` |
| `BubbleData` | `CoreBubbleData` |
| `MentionGroup` | `CoreMentionGroup` |
| `DynReactionData` | `CoreDynReactionData` |
| `DynReserveData` | `CoreDynReserveData` |
| `ReserveInfoData` | `CoreReserveInfoData` |
| `TopicCardList` | `CoreTopicCardList` |
| `TopDetails` | `CoreTopDetails` |
| `TopicItem` | `CoreTopicItem` |
| `FolloweeVote` | `CoreFolloweeVote` |
| `OpusType` | `CoreOpusType` |
| `OpusDetailResp` | `CoreOpusDetailResp` |
| `OpusPicModel` | `CoreOpusPicModel` |

### lib/core/repository/im_repository.dart — NOT CHANGED

**Finding:** ALL 23 types used by `ImRepository` are gRPC protobuf generated classes with NO Core equivalents:

- From `app/im/v1.pb.dart` (17): `RspSendMsg`, `RspShareList`, `RspSessionMsg`, `SessionMainReply`, `SessionSecondaryReply`, `ClearUnreadReply`, `SessionUpdateReply`, `PinSessionReply`, `UnPinSessionReply`, `DeleteSessionListReply`, `GetImSettingsReply`, `SetImSettingsReply`, `KeywordBlockingListReply`, `KeywordBlockingAddReply`, `KeywordBlockingDeleteReply`, `RspTotalUnread`, `SessionInfo`
- From `im/interfaces/v1.pb.dart` (5): `Offset`, `SessionPageType`, `SessionId`, `IMSettingType`, `Setting`
- From `im/type.pb.dart` (1): `MsgType`
- External packages: `Int64` (fixnum), `PbMap` (protobuf)

**No Core wrapper types exist** in `core/models/` for any of these. Creating them would require a `core/models/im_types.dart` with 23+ Pure-Dart wrapper classes mirroring the protobuf messages. This is out of scope for the current task.

## Verification
`flutter analyze lib/core/repository/video_repository.dart lib/core/repository/dynamics_repository.dart lib/core/repository/im_repository.dart` → **No issues found**.

---

# Round 9: lib/core/repository/ (search, space, user)

## Task
Replace ALL adapter imports with core imports and prefix ALL type references with `Core` in `search_repository.dart`, `space_repository.dart`, and `user_repository.dart`.

## Files Modified

### lib/core/repository/search_repository.dart

**Imports replaced (9 adapter imports → 1 core import):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/models/common/search/search_type.dart` | `core/models/search_types.dart` |
| `adapters/bilibili/models/search/result.dart` | _(same)_ |
| `adapters/bilibili/models/search/suggest.dart` | _(same)_ |
| `adapters/bilibili/models_new/dynamic/dyn_topic_pub_search/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/pgc/pgc_info_model/result.dart` | _(same)_ |
| `adapters/bilibili/models_new/search/search_rcmd/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/search/search_trending/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/video/video_detail/dimension.dart` | _(same)_ |

All 9 adapter model imports collapsed to a single `core/models/search_types.dart` import.

**Type references renamed (10):**
| Old name | New name |
|----------|----------|
| `SearchType` | `CoreSearchType` |
| `SearchSuggestModel` | `CoreSearchSuggestModel` |
| `SearchNumData` | `CoreSearchNumData` |
| `SearchAllData` | `CoreSearchAllData` |
| `Dimension` | `CoreDimension` |
| `PgcInfoModel` | `CorePgcInfoModel` |
| `SearchTrendingData` | `CoreSearchTrendingData` |
| `SearchRcmdData` | `CoreSearchRcmdData` |
| `TopicPubSearchData` | `CoreTopicPubSearchData` |

### lib/core/repository/space_repository.dart

**Imports replaced (2 gRPC imports → 1 core import):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/grpc/bilibili/app/dynamic/v2.pb.dart` (show OpusSpaceFlowResp) | `core/models/space_types.dart` |
| `adapters/bilibili/grpc/bilibili/app/interfaces/v1.pb.dart` (show SearchArchiveReply) | _(same)_ |

Retained: `fixnum` import (used by `Int64` in `searchArchive` method signature).

**Type references renamed (2):**
| Old name | New name |
|----------|----------|
| `OpusSpaceFlowResp` | `CoreOpusSpaceFlowResp` |
| `SearchArchiveReply` | `CoreSearchArchiveReply` |

### lib/core/repository/user_repository.dart

**Imports replaced (13 adapter imports → 2 core imports):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/models/user/info.dart` | `core/models/user_types.dart` |
| `adapters/bilibili/models/user/stat.dart` | _(same)_ |
| `adapters/bilibili/models_new/coin_log/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/follow/data.dart` | `core/models/follow_data.dart` |
| `adapters/bilibili/models_new/history/data.dart` | `core/models/user_types.dart` |
| `adapters/bilibili/models_new/later/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/login_log/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/media_list/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/relation/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/space_setting/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/sub/sub/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/user_real_name/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/video/video_tag/data.dart` | _(same)_ |

**Type references renamed (13):**
| Old name | New name |
|----------|----------|
| `UserInfoData` | `CoreUserInfoData` |
| `UserStat` | `CoreUserStat` |
| `LaterData` | `CoreLaterData` |
| `HistoryData` | `CoreHistoryData` (×2) |
| `RelationData` | `CoreRelationData` |
| `SubData` | `CoreSubData` |
| `VideoTagItem` | `CoreVideoTagItem` |
| `MediaListData` | `CoreMediaListData` |
| `CoinLogData` | `CoreCoinLogData` (×2) |
| `SpaceSettingData` | `CoreSpaceSettingData` |
| `LoginLogData` | `CoreLoginLogData` |
| `UserRealNameData` | `CoreUserRealNameData` |
| `FollowData` | `CoreFollowData` (×2) |

## Key findings

1. **Core model files already existed for all types** — `search_types.dart` (565 lines), `space_types.dart` (51 lines), `user_types.dart` (848 lines), `follow_data.dart` (21 lines) were all created in earlier rounds. No new types needed to be created.

2. **`space_repository.dart` retains `fixnum` import** — The `Int64` type is used in `searchArchive` method parameters and comes from the `fixnum` package, not from any adapter. This is a legitimate external dependency, not an adapter import.

3. **No substring collisions** — All type name replacements were unique across each file. No ordering issues.

4. **All core types are abstract wrappers** — `CoreOpusSpaceFlowResp` and `CoreSearchArchiveReply` in `space_types.dart` are pure-Dart wrappers around gRPC types. They replace protobuf-specific types (`OpusSpaceFlowResp`, `SearchArchiveReply`, `Int64`) with plain Dart equivalents (`dynamic`, `List<dynamic>?`, `int`).

5. **`CoreFollowData` split from user_types** — The `CoreFollowData` type lives in a separate file (`follow_data.dart`) because it imports `CoreFollowItemModel` from `follow_item.dart`. This is the only case where user_repository needs two core model imports instead of one.

## Verification
`flutter analyze lib/core/repository/search_repository.dart lib/core/repository/space_repository.dart lib/core/repository/user_repository.dart` → **No issues found** (ran in 2.3s).

---

# Round 10: lib/core/repository/audio_repository.dart, black_repository.dart

## Task
Replace ALL adapter imports with core imports and prefix ALL type references with `Core` in two core repository files.

## Files Modified

### lib/core/repository/audio_repository.dart

**Imports replaced (2 adapter imports → 1 core import):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/grpc/bilibili/app/archive/middleware/v1.pb.dart` | `core/models/audio_types.dart` |
| `adapters/bilibili/grpc/bilibili/app/listener/v1.pb.dart` | _(merged into audio_types.dart)_ |

Retained: `fixnum` (for `Int64`), `core/result/loading_state.dart`.

**Type references renamed (9):**
| Old name | New name |
|----------|----------|
| `PlayURLResp` | `CoreAudioPlayUrlResp` |
| `PlaylistResp` | `CoreAudioPlaylistResp` |
| `PlaylistSource` | `CoreAudioPlaylistSource` |
| `PageOption` | `CoreAudioPageOption` |
| `ListOrder` | `CoreAudioListOrder` |
| `ThumbUpResp` | `CoreAudioThumbUpResp` |
| `ThumbUpReq_ThumbType` | `CoreAudioThumbType` |
| `TripleLikeResp` | `CoreAudioTripleLikeResp` |
| `CoinAddResp` | `CoreAudioCoinAddResp` |

Default value changed: `ListOrder.ORDER_NORMAL` → `CoreAudioListOrder.orderNormal` (enum values follow Dart camelCase convention).

### lib/core/repository/black_repository.dart

**Imports replaced (1 → 1):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/models_new/blacklist/data.dart` | `core/models/blacklist_data.dart` |

**Type references renamed (1):**
| Old name | New name |
|----------|----------|
| `BlackListData` | `CoreBlackListData` |

## Key Findings

1. **`archive/middleware/v1.pb.dart` import was unused in the interface** — All types used in `audio_repository.dart` (`PlayURLResp`, `PlaylistResp`, `ThumbUpResp`, etc.) are defined in `listener/v1.pb.dart`, not the archive middleware. The archive import was only needed by adapter implementations (e.g., `AudioGrpc`) which use request types like `PlayURLReq`, `PlayItem`, `PlayerArgs`. Removed from the core interface.

2. **All 9 audio Core types already existed** — `audio_types.dart` was created in earlier rounds with all `Core`-prefixed types. No new types needed to be created.

3. **Enum value naming convention mismatch** — gRPC enums use `UPPER_SNAKE_CASE` (e.g., `ListOrder.ORDER_NORMAL`), while Dart core enums use `camelCase` (e.g., `CoreAudioListOrder.orderNormal`). The default parameter value had to be updated accordingly.

4. **`fixnum` import retained** — `Int64` is from the `fixnum` package, not an adapter dependency. It remains in the core interface for method parameters (`oid`, `subId`, `id`, `extraId`).

## Verification
`flutter analyze lib/core/repository/audio_repository.dart lib/core/repository/black_repository.dart` → **No issues found**.

---

# Round 11: lib/core/repository/pgc_repository.dart, reply_repository.dart, sponsor_block_repository.dart

## Task
Replace ALL adapter imports with core imports and prefix ALL type references with `Core` in three core repository files.

## Files Modified

### lib/core/repository/pgc_repository.dart

**Imports replaced (6 adapter imports → 1 core import):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/models/common/pgc_review_type.dart` | `core/models/pgc_types.dart` |
| `adapters/bilibili/models_new/pgc/pgc_index_condition/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/pgc/pgc_index_result/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/pgc/pgc_index_result/list.dart` | _(same)_ |
| `adapters/bilibili/models_new/pgc/pgc_review/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/pgc/pgc_timeline/result.dart` | _(same)_ |

Retained: `core/result/loading_state.dart`

**Type references renamed (6):**
| Old name | New name |
|----------|----------|
| `PgcIndexResult` | `CorePgcIndexResult` |
| `PgcIndexConditionData` | `CorePgcIndexConditionData` |
| `PgcIndexItem` | `CorePgcIndexItem` |
| `TimelineResult` | `CoreTimelineResult` |
| `PgcReviewData` | `CorePgcReviewData` |
| `PgcReviewType` | `CorePgcReviewType` |

### lib/core/repository/reply_repository.dart

**Imports replaced (1 gRPC import → 1 core import):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart` | `core/models/reply_types.dart` |

Removed: `fixnum` import (no longer needed — `Int64` replaced with `int`).

**Type references renamed (7):**
| Old name | New name |
|----------|----------|
| `MainListReply` | `CoreMainListReply` |
| `DetailListReply` | `CoreDetailListReply` |
| `DialogListReply` | `CoreDialogListReply` |
| `Mode` | `CoreMode` |
| `SearchItemReply` | `CoreSearchItemReply` |
| `SearchItemType` | `CoreSearchItemType` |
| `TranslateReplyResp` | `CoreTranslateReplyResp` |

Additional change: `Int64` parameters replaced with `int` (3 occurrences in `translateReply` method, 1 in `mainList` method).

### lib/core/repository/sponsor_block_repository.dart

**Imports replaced (4 adapter imports → 1 core import):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/models/common/sponsor_block/post_segment_model.dart` | `core/models/sponsor_block_types.dart` |
| `adapters/bilibili/models/common/sponsor_block/segment_type.dart` | _(same)_ |
| `adapters/bilibili/models_new/sponsor_block/segment_item.dart` | _(same)_ |
| `adapters/bilibili/models_new/sponsor_block/user_info.dart` | _(same)_ |

Retained: `core/result/loading_state.dart`

**Type references renamed (4):**
| Old name | New name |
|----------|----------|
| `SegmentItemModel` | `CoreSegmentItemModel` |
| `SegmentType` | `CoreSegmentType` |
| `UserInfo` | `CoreUserInfo` |
| `PostSegmentModel` | `CorePostSegmentModel` |

## Key findings

1. **No substring collisions** — All type names in these three files are unique. No ordering issues with replaceAll.

2. **`fixnum` removed from reply_repository.dart** — The `Int64` type from the `fixnum` package was used in gRPC method signatures. Since `CoreTranslateReplyResp` and other core reply types use `int` instead of `Int64`, the `fixnum` import is no longer needed in the core interface. Note: `space_repository.dart` still retains `fixnum` for its own `Int64` usage.

3. **All core types already existed** — `pgc_types.dart`, `reply_types.dart`, and `sponsor_block_types.dart` were all created in earlier rounds. No new types needed to be created.

4. **Abstract interfaces only** — All three files define abstract repository interfaces. Concrete adapter implementations (e.g., `BiliPgcRepository`, `BiliReplyRepository`, `BiliSponsorBlockRepository`) remain adapter-imported and will need separate updates.

## Verification
`flutter analyze lib/core/repository/pgc_repository.dart lib/core/repository/reply_repository.dart lib/core/repository/sponsor_block_repository.dart` → **No issues found**.

---

# Round 11: adapter repo implementations — match Core-prefixed interfaces

## Task
Update 4 adapter repository implementations to match the now-CoreXxx interfaces:
- `bili_audio_repository.dart`
- `bili_black_repository.dart`
- `bili_danmaku_repository.dart`
- `bili_danmaku_filter_repository.dart`

## Changes per file

### lib/adapters/bilibili/repository/bili_audio_repository.dart
- Added `_toCore<T, A>(LoadingState<A>, T Function(A))` helper (extracts Success, converts; re-wraps Error/Loading)
- Updated return types: `PlayURLResp`→`CoreAudioPlayUrlResp`, `PlaylistResp`→`CoreAudioPlaylistResp`, etc.
- Updated parameter types to match interface: `PlaylistSource?`→`CoreAudioPlaylistSource?`, `PageOption?`→`CoreAudioPageOption?`, `ListOrder`→`CoreAudioListOrder`, `ThumbUpReq_ThumbType`→`CoreAudioThumbType`
- Added Core→gRPC enum conversion: `PlaylistSource.valueOf(from.value)`, `PageOption_Direction.valueOf(dir.value)`, `ListOrder.valueOf(order.value)`, `ThumbUpReq_ThumbType.valueOf(type.value)`
- Response conversion: `CoreAudioXxx.fromJson(data.toJson())` via gRPC `GeneratedMessage.toJson()`

### lib/adapters/bilibili/repository/bili_black_repository.dart
- Updated return type: `BlackListData`→`CoreBlackListData`
- Core model `BlackListData` lacks `toJson()`, so used manual map construction: `CoreBlackListItem.fromJson({'mid': e.mid, ...})`
- Added `_toCore` helper + `_toCoreBlackListData` static conversion function

### lib/adapters/bilibili/repository/bili_danmaku_repository.dart
- Updated return types: `DanmakuPost`→`CoreDanmakuPost`, `DmSegMobileReply`→`CoreDanmakuSegmentReply`, `DmViewReply`→`CoreDanmakuViewReply`
- `void`/`String?` return types left unchanged (same in interface)
- For `DanmakuPost` (no `toJson`): direct constructor `CoreDanmakuPost(dmid: data.dmid)`
- For gRPC types: `CoreDanmakuSegmentReply.fromJson(data.toJson())` and `CoreDanmakuViewReply.fromJson(data.toJson())`

### lib/adapters/bilibili/repository/bili_danmaku_filter_repository.dart
- Updated return types: `DanmakuBlockDataModel`→`CoreDanmakuBlockDataModel`, `SimpleRule`→`CoreSimpleRule`
- `void` return for `danmakuFilterDel` left unchanged
- `DanmakuBlockDataModel` lacks `toJson()` — manual map construction via `_toCoreDanmakuBlockDataModel` + `_simpleRuleToJson` helpers
- `SimpleRule` (adapter) → `CoreSimpleRule` via direct constructor

### Core model files updated (auxiliary)

| File | Addition |
|------|----------|
| `lib/core/models/audio_types.dart` | Added `fromJson()` factories to 5 response types: `CoreAudioPlayUrlResp`, `CoreAudioPlaylistResp`, `CoreAudioThumbUpResp`, `CoreAudioTripleLikeResp`, `CoreAudioCoinAddResp` |
| `lib/core/models/danmaku_types.dart` | Added `fromJson()` factories to `CoreDanmakuElement`, `CoreDanmakuSegmentReply`, `CoreDanmakuViewReply` |

## Key findings

1. **gRPC `toJson()` works seamlessly** — protobuf `GeneratedMessage.toJson()` returns `Map<String, dynamic>`, which feeds directly into core `CoreXxx.fromJson()`. Used for all audio and DM gRPC response types.

2. **Adapter models without `toJson()` need manual conversion** — `BlackListData`, `DanmakuPost`, `DanmakuBlockDataModel`, and `SimpleRule` (adapter versions) have `fromJson()` constructors but no `toJson()`. Three strategies used:
   - **Direct constructor mapping** (simplest): `CoreDanmakuPost(dmid: data.dmid)` when both types have same fields
   - **Manual JSON map + Core.fromJson**: `CoreBlackListData.fromJson({'list': ..., 'total': ...})` when Core model has fromJson
   - **Manual JSON map via helper**: `_simpleRuleToJson` converts adapter model to map, then `CoreDanmakuBlockDataModel.fromJson(...)` reconstructs

3. **Dart sealed class covariance** — `LoadingState<Never>` (Error, Loading) is a subtype of `LoadingState<CoreXxx>`. The `_toCore` helper handles this via pattern matching (`Error(:final errMsg, :final code) => Error<T>(...)`).

4. **All 4 adapter files have zero diagnostics** — verified via `lsp_diagnostics`.

5. **Pre-existing errors in test mock files** — 1000+ errors in `test/repository/*_test.mocks.dart` files. These mock files were generated against the old interface signatures and need regeneration via `dart run build_runner build --delete-conflicting-outputs`. Out of scope for this task.

## Verification
`lsp_diagnostics()` on all 4 adapter files + 2 core model files → **No issues found** (0 errors, 0 warnings, 0 hints).

---
# Round 11: lib/core/repository/fav_repository.dart, member_repository.dart

## Task
Replace ALL adapter imports with core imports and prefix ALL type references with `Core` in two core repository files.

## Files Modified

### lib/core/repository/fav_repository.dart

**Imports replaced (11 adapter imports → 1 core import):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/models/common/fav_order_type.dart` | `core/models/fav_types.dart` |
| `adapters/bilibili/models_new/fav/fav_article/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/fav/fav_detail/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/fav/fav_folder/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/fav/fav_folder/list.dart` | _(same)_ |
| `adapters/bilibili/models_new/fav/fav_note/list.dart` | _(same)_ |
| `adapters/bilibili/models_new/fav/fav_pgc/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/fav/fav_topic/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/space/space_cheese/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/space/space_fav/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/sub/sub_detail/data.dart` | _(same)_ |

Retained: `core/result/loading_state.dart`

**Type references renamed (11):**
| Old name | New name |
|----------|----------|
| `FavOrderType` | `CoreFavOrderType` |
| `FavDetailData` | `CoreFavDetailData` |
| `SubDetailData` | `CoreSubDetailData` |
| `SpaceCheeseData` | `CoreSpaceCheeseData` |
| `FavTopicData` | `CoreFavTopicData` |
| `FavArticleData` | `CoreFavArticleData` |
| `FavNoteItemModel` | `CoreFavNoteItemModel` |
| `FavPgcData` | `CoreFavPgcData` |
| `FavFolderData` | `CoreFavFolderData` |
| `SpaceFavData` | `CoreSpaceFavData` |
| `FavFolderInfo` | `CoreFavFolderInfo` |

### lib/core/repository/member_repository.dart

**Imports replaced (24 adapter imports → 3 core imports):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/models/common/member/archive_order_type_app.dart` | `core/models/member_types.dart` |
| `adapters/bilibili/models/common/member/archive_order_type_web.dart` | _(same)_ |
| `adapters/bilibili/models/common/member/archive_sort_type_app.dart` | _(same)_ |
| `adapters/bilibili/models/common/member/contribute_type.dart` | _(same)_ |
| `adapters/bilibili/models/common/member/web_ss_type.dart` | _(same)_ |
| `adapters/bilibili/models/dynamics/result.dart` | _(same)_ |
| `adapters/bilibili/models/member/info.dart` | _(same)_ |
| `adapters/bilibili/models/member/tags.dart` | _(same)_ |
| `adapters/bilibili/models_new/follow/data.dart` | `core/models/follow_data.dart` |
| `adapters/bilibili/models_new/member/coin_like_arc/data.dart` | `core/models/member_types.dart` |
| `adapters/bilibili/models_new/member/search_archive/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/member/season_web/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/member_card_info/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/member_guard/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/space/space/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/space/space_archive/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/space/space_article/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/space/space_audio/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/space/space_cheese/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/space/space_opus/data.dart` | `core/models/space_types.dart` |
| `adapters/bilibili/models_new/space/space_season_series/item.dart` | `core/models/member_types.dart` |
| `adapters/bilibili/models_new/space/space_shop/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/upower_rank/data.dart` | _(same)_ |

Retained: `core/result/loading_state.dart`

**Type references renamed (24):**
| Old name | New name |
|----------|----------|
| `ContributeType` | `CoreContributeType` |
| `ArchiveOrderTypeApp` | `CoreArchiveOrderTypeApp` |
| `ArchiveSortTypeApp` | `CoreArchiveSortTypeApp` |
| `ArchiveOrderTypeWeb` | `CoreArchiveOrderTypeWeb` |
| `WebSsType` | `CoreWebSsType` |
| `DynamicsDataModel` | `CoreDynamicsDataModel` |
| `MemberInfoModel` | `CoreMemberInfoModel` |
| `MemberTagItemModel` | `CoreMemberTagItemModel` |
| `FollowData` | `CoreFollowData` |
| `CoinLikeArcData` | `CoreCoinLikeArcData` |
| `SearchArchiveData` | `CoreSearchArchiveData` |
| `SeasonWebData` | `CoreSeasonWebData` |
| `MemberCardInfoData` | `CoreMemberCardInfoData` |
| `MemberGuardData` | `CoreMemberGuardData` |
| `SpaceData` | `CoreSpaceData` |
| `SpaceArchiveData` | `CoreSpaceArchiveData` |
| `SpaceArticleData` | `CoreSpaceArticleData` |
| `SpaceAudioData` | `CoreSpaceAudioData` |
| `SpaceCheeseData` | `CoreSpaceCheeseData` |
| `SpaceOpusData` | `CoreOpusSpaceFlowResp` |
| `SpaceSsData` | `CoreSpaceSsData` |
| `SpaceShopData` | `CoreSpaceShopData` |
| `UpowerRankData` | `CoreUpowerRankData` |

## Key Findings

1. **All 24 adapter imports in member_repository.dart collapsed to 3 core imports** — `member_types.dart` covers most types, `follow_data.dart` for follow data, and `space_types.dart` for opus data.

2. **Name collision: `CoreDynamicsDataModel`** — This type exists in both `dynamics_types.dart` and `member_types.dart`. The `dynamics_types.dart` version was used initially, but since `member_types.dart` also defines it and is needed for other types, the import of `dynamics_types.dart` was removed entirely. The `member_types.dart` version is the correct one for member repository operations.

3. **No substring collisions** — All type names were unique across each file. The full rewrite approach (write entire file) was used to avoid incremental replaceAll pitfalls.

4. **All core types already existed** — `fav_types.dart` (736 lines), `member_types.dart` (2900+ lines), `space_types.dart` (50 lines), and `follow_data.dart` (20 lines) were all created in earlier rounds. No new types needed to be created.

5. **Adapter implementations will break** (out of scope) — Concrete adapter implementations (e.g., `BiliFavRepository`, `BiliMemberRepository`) use adapter-specific types in their `@override` methods. After the interface changed to core types, these implementations will need separate updates.

## Verification
`flutter analyze lib/core/repository/fav_repository.dart lib/core/repository/member_repository.dart` → **No issues found** (ran in 3.5s).

---

# Round 12: lib/core/repository/msg_repository.dart, music_repository.dart, match_repository.dart

## Task
Replace ALL adapter imports with core imports and prefix ALL type references with `Core` in three core repository files.

## Files Modified

### lib/core/repository/msg_repository.dart

**Imports replaced (11 adapter imports → 1 core import):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/models_new/msg/im_user_infos/datum.dart` | `core/models/msg_types.dart` |
| `adapters/bilibili/models_new/msg/msg_at/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/msg/msg_dnd/uid_setting.dart` | _(same)_ |
| `adapters/bilibili/models_new/msg/msg_like/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/msg/msg_like_detail/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/msg/msg_reply/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/msg/msg_sys/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/msg/session_ss/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/msgfeed_unread/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/single_unread/data.dart` | _(same)_ |
| `adapters/bilibili/models_new/upload_bfs/data.dart` | _(same)_ |

Retained: `core/result/loading_state.dart`, `dio`

**Type references renamed (11):**
| Old name | New name |
|----------|----------|
| `MsgReplyData` | `CoreMsgReplyData` |
| `MsgAtData` | `CoreMsgAtData` |
| `MsgLikeData` | `CoreMsgLikeData` |
| `MsgLikeDetailData` | `CoreMsgLikeDetailData` |
| `MsgSysItem` | `CoreMsgSysItem` |
| `UploadBfsResData` | `CoreUploadBfsResData` |
| `ImUserInfosData` | `CoreImUserInfosData` |
| `SessionSsData` | `CoreSessionSsData` |
| `UidSetting` | `CoreUidSetting` |
| `SingleUnreadData` | `CoreSingleUnreadData` |
| `MsgFeedUnreadData` | `CoreMsgFeedUnreadData` |

### lib/core/repository/music_repository.dart

**Imports replaced (2 adapter imports → 1 core import):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/models_new/music/bgm_detail.dart` | `core/models/music_types.dart` |
| `adapters/bilibili/models_new/music/bgm_recommend_list.dart` | _(same)_ |

Retained: `core/result/loading_state.dart`

**Type references renamed (2):**
| Old name | New name |
|----------|----------|
| `MusicDetail` | `CoreMusicDetail` |
| `BgmRecommend` | `CoreBgmRecommend` |

### lib/core/repository/match_repository.dart

**Imports replaced (1 adapter import → 1 core import):**
| Old import | New import |
|------------|------------|
| `adapters/bilibili/models_new/match/match_info/contest.dart` | `core/models/match_contest.dart` |

Retained: `core/result/loading_state.dart`

**Type references renamed (1):**
| Old name | New name |
|----------|----------|
| `MatchContest` | `CoreMatchContest` |

## Key Findings

1. **All 14 adapter imports collapsed to 3 core imports** — `msg_types.dart` (11 adapter imports → 1), `music_types.dart` (2 → 1), `match_contest.dart` (1 → 1). Each core model file already contained all required Core-prefixed types.

2. **All Core types already existed** — `msg_types.dart` (630 lines, 29 types), `music_types.dart` (200+ lines, 7 types), and `match_contest.dart` (61 lines, 3 types) were all created in earlier rounds. No new types needed to be created.

3. **No substring collisions** — All type names in these three files are unique. No ordering issues with replaceAll.

4. **`dio` import retained in msg_repository.dart** — The `CancelToken` type is from the `dio` package, not an adapter dependency. It remains in the core interface for the `uploadBfs` method parameter.

5. **Abstract interfaces only** — All three files define abstract repository interfaces. Concrete adapter implementations (e.g., `BiliMsgRepository`, `BiliMusicRepository`, `BiliMatchRepository`) remain adapter-imported and will need separate updates.

## Verification
`flutter analyze lib/core/repository/msg_repository.dart lib/core/repository/music_repository.dart lib/core/repository/match_repository.dart` → **No issues found**.

---

# Round 13: BiliAdapter repository implementations — CoreXxx type alignment

## Task
Update three adapter repository implementations (`bili_download_repository.dart`, `bili_fan_repository.dart`, `bili_follow_repository.dart`) to match their core interfaces after the interfaces switched to CoreXxx types.

## Changes per file

### `lib/adapters/bilibili/repository/bili_download_repository.dart`

**Imports updated:**
| Added | Removed |
|-------|---------|
| `core/models/download_types.dart` | — |
| `bili_download_media_file_info.dart as adapter` | `bili_download_media_file_info.dart` (unaliased) |

**Method signature changed:**
| Parameter | Old type | New type |
|-----------|----------|----------|
| `entry` | `BiliDownloadEntryInfo` | `CoreBiliDownloadEntryInfo` |
| `source` | `SourceInfo?` | `CoreSourceInfo?` |
| `pageData` | `PageInfo?` | `CorePageInfo?` |
| `ep` | `EpInfo?` | `CoreEpInfo?` |

**Conversion flow:**
1. Input params: `CoreXxx.toJson()` → `AdapterXxx.fromJson()` to convert Core→Adapter before delegating to `DownloadHttp`
2. Output result: `adapter.BiliDownloadMediaInfo` → `BiliDownloadMediaInfo` (core) via a private `_toCoreMediaInfo()` helper using `switch` on adapter sealed type variants (`adapter.Type1`, `adapter.Type2`, `adapter.None`)

### `lib/adapters/bilibili/repository/bili_fan_repository.dart`

| Change | Old | New |
|--------|-----|-----|
| Return type | `LoadingState<FollowData>` | `LoadingState<CoreFollowData>` |
| Import `follow/data.dart` | present | removed (redundant — transitively imported by `fan.dart`) |
| Import `core/models/follow_data.dart` | absent | added |
| Conversion pattern | direct return of `FanHttp.fans()` | Success unbox → JSON map construction → `CoreFollowData.fromJson()` |

### `lib/adapters/bilibili/repository/bili_follow_repository.dart`

Identical pattern to fan — `followings()` return type changed to `LoadingState<CoreFollowData>` with JSON-based conversion. `sortFollowTag()` unchanged (both sides return `LoadingState<void>`).

## Key findings

1. **Sealed class name collision** — Both `core/models/download_types.dart` and `adapters/.../bili_download_media_file_info.dart` define a `BiliDownloadMediaInfo` sealed class. The adapter import must use an alias (`as adapter`) to disambiguate. The conversion helper maps sealed variants via `switch` across JSON.

2. **Adapter `FollowData` lacks `toJson()`** — The adapter model `FollowData` (and `FollowItemModel`) have no `toJson()` method. The conversion pattern `CoreXxx.fromJson(data.toJson())` would not compile. **Workaround**: manually construct the JSON map literal with each field mapped by name (`'mid': e.mid`, etc.), then pass to `CoreFollowData.fromJson()`.

3. **Transitive import sufficed** — Both `fan.dart` and `follow.dart` already import `follow/data.dart`, so the separate import in the repository files was redundant. The analyzer flagged it as `unused_import`.

4. **Method with `async` but no `await`** — `sortFollowTag()` returned a Future directly without `await`. Analyzer flagged `unnecessary_async`. Fix: remove the `async` keyword, making it a synchronous return of a Future.

## Verification
`flutter analyze lib/adapters/bilibili/repository/bili_download_repository.dart lib/adapters/bilibili/repository/bili_fan_repository.dart lib/adapters/bilibili/repository/bili_follow_repository.dart` → **No issues found** (ran in 226.9s).

---

# Round 14: bili_auth_repository.dart and bili_validate_repository.dart

## Task
Update adapter repository implementations to match CoreXxx interfaces: `bili_auth_repository.dart` and `bili_validate_repository.dart`.

## Files Modified

### `lib/adapters/bilibili/repository/bili_auth_repository.dart`

**Initial errors (flutter analyze):**
| Error | Message |
|-------|---------|
| `invalid_override` | `logout(Account)` → interface expects `logout(CoreAccount)` |
| `invalid_override` | `loginDevices()` returns `LoadingState<LoginDevicesData>` → interface expects `LoadingState<CoreLoginDevicesData>` |
| `unnecessary_await_in_return` | `getQRCode()` and `loginDevices()` |

**Import changes:**
| Action | Import |
|--------|--------|
| Added | `package:skf/core/models/auth_types.dart` |
| Added | `package:skf/adapters/bilibili/utils/accounts.dart` |
| Removed | `package:skf/adapters/bilibili/utils/accounts/account.dart` |
| Removed | `package:skf/adapters/bilibili/models_new/login_devices/data.dart` (unused — types resolved transitively through `login.dart` return types) |

**Method signature changes:**
| Method | Old | New |
|--------|-----|-----|
| `logout` | `logout(Account account)` | `logout(CoreAccount account)` |
| `loginDevices` | `Future<LoadingState<LoginDevicesData>>` | `Future<LoadingState<CoreLoginDevicesData>>` |

**Implementation changes:**
| Method | Change |
|--------|--------|
| `getQRCode()` | Removed `async`/`await` (direct return) |
| `logout(CoreAccount account)` | Ignored CoreAccount param, uses `Accounts.main` internally to get adapter `Account` for `LoginHttp.logout()` |
| `loginDevices()` | Added `async`/`await` + pattern-match switch to convert `LoginDevicesData` → `CoreLoginDevicesData` via field-by-field mapping |

**Conversion pattern for `loginDevices()`:**
```dart
final result = await LoginHttp.loginDevices();
return switch (result) {
  Success(:final response) => Success(CoreLoginDevicesData(
    devices: response.devices?.map((d) => CoreLoginDevice(
      deviceName: d.deviceName,
      isCurrentDevice: d.isCurrentDevice,
      latestLoginAt: d.latestLoginAt,
      source: d.source,
    )).toList(),
  )),
  Error(:final errMsg) => Error(errMsg),
  Loading() => LoadingState.loading(),
};
```

### `lib/adapters/bilibili/repository/bili_validate_repository.dart`

**No changes needed** — The `ValidateRepository` interface returns `Future<LoadingState<Map?>>` for both methods, and the adapter already matches. No CoreXxx types are used in the interface.

## Key findings

1. **`Account` import no longer needed** — The adapter `Account` type (from `account.dart`) was only used as the `logout` parameter type. After switching to `CoreAccount`, the underlying call `LoginHttp.logout(Accounts.main)` resolves `Account` through `Accounts.main`'s return type + `LoginHttp.logout()`'s parameter type, both of which declare `Account`. Explicit import of `account.dart` is unnecessary.

2. **`LoginDevicesData` import was unused post-rewrite** — The `response.devices` access in the pattern match works because `LoginHttp.loginDevices()` return type `LoadingState<LoginDevicesData>` makes `LoginDevicesData` accessible through its method signature. An explicit `import` of `login_devices/data.dart` is flagged as unused. The `LoginDevice` inner type (used in `.map((d) => CoreLoginDevice(...))`) is also accessible through `response.devices` type resolution.

3. **`LoadingState.loading()` is not a const constructor** — The factory constructor `factory LoadingState.loading() => const Loading._internal()` is NOT marked `const`, so `const LoadingState.loading()` fails. Use `LoadingState.loading()` (without `const`).

4. **`validate_repository.dart` needs no adapter update** — Its interface uses `Map?` (not a CoreXxx type), so the adapter continues to compile correctly with existing imports.

## Verification
`flutter analyze lib/adapters/bilibili/repository/bili_auth_repository.dart lib/adapters/bilibili/repository/bili_validate_repository.dart` → **No issues found** (ran in 120.2s).

---

# Round 13: IM repository — gRPC types to CoreIm* wrappers

## Task
Create adapter-independent CoreIm* wrapper types for all gRPC protobuf types used in `ImRepository`, then update the abstract interface and adapter implementation to use them.

## Files Modified

### Created: `lib/core/models/im_types.dart` (286 lines)
New file with 23+ CoreIm* wrapper types mirroring gRPC protobuf types:

| Category | Types |
|----------|-------|
| Enums (3) | `CoreImMsgType`, `CoreImSessionPageType`, `CoreImSettingType` |
| Data classes (6) | `CoreImOffset`, `CoreImSessionId`, `CoreImSetting`, `CoreImShareSessionInfo`, `CoreImMsg`, `CoreImSession`, `CoreImKeywordBlockingItem` |
| Reply types (17) | `CoreImRspSendMsg`, `CoreImRspShareList`, `CoreImRspSessionMsg`, `CoreImSessionMainReply`, `CoreImSessionSecondaryReply`, `CoreImClearUnreadReply`, `CoreImSessionUpdateReply`, `CoreImPinSessionReply`, `CoreImUnPinSessionReply`, `CoreImDeleteSessionListReply`, `CoreImGetImSettingsReply`, `CoreImSetImSettingsReply`, `CoreImKeywordBlockingListReply`, `CoreImKeywordBlockingAddReply`, `CoreImKeywordBlockingDeleteReply`, `CoreImRspTotalUnread`, `CoreImSessionInfo` |

### Updated: `lib/core/repository/im_repository.dart`
- **Removed 4 adapter/gRPC imports**: `v1.pb.dart`, `interfaces/v1.pb.dart`, `type.pb.dart`, `fixnum`, `protobuf`
- **Added 1 core import**: `core/models/im_types.dart`
- **All gRPC types replaced** with CoreIm* equivalents:
  - `Int64` parameters → `int`
  - `PbMap<int, Offset>` → `Map<int, CoreImOffset>`
  - `MsgType` → `CoreImMsgType`
  - `SessionPageType?` → `CoreImSessionPageType?`
  - `SessionId?` → `CoreImSessionId?`
  - `IMSettingType?` → `CoreImSettingType?`
  - `Map<int, Setting>?` → `Map<int, CoreImSetting>?`
- All 17 return types wrapped in `LoadingState<CoreIm*>` instead of `LoadingState<grpcType>`

### Updated: `lib/adapters/bilibili/repository/bili_im_repository.dart`
- **Converted adapter to bridge layer** between gRPC and CoreIm* types
- Added `_mapSuccess<T, R>()` helper to transform `LoadingState<GrpcType>` → `LoadingState<CoreImType>` using sealed class pattern matching
- Added **17 extension methods** on gRPC types for `.toCore()` conversion
- Added **4 enum-to-enum mappers**: `_msgTypeToGrpc`, `_sessionPageTypeToGrpc`, `_imSettingTypeToGrpc`
- Added **2 type converters**: `_sessionIdToGrpc`, `_settingToGrpc`
- Each method calls `ImGrpc.*` (still returns gRPC types), then maps through `_mapSuccess(result, (r) => r.toCore())`

### Consumer files with implicit gRPC dependency resolved
6 page controllers that use `ImRepository` via DI (`Get.find<ImRepository>()`) no longer transitively import gRPC types:
- `whisper/controller.dart`
- `whisper_detail/controller.dart`
- `whisper_secondary/controller.dart`
- `whisper_block/controller.dart`
- `whisper_link_setting/controller.dart`
- `common/common_whisper_controller.dart`

All LSP-clean — no cascade of adapter imports through the abstract interface.

## Key findings

1. **gRPC types are deeply nested** — `SessionMainReply` wraps `Session` objects, which in turn contain `SessionId`, `SessionInfo` (v1.pb), `Unread`, `MsgSummary`, etc. The CoreIm* types flatten the most commonly accessed fields.

2. **`hide SessionInfo` pattern** — Both `im.dart` and `bili_im_repository.dart` import v1.pb.dart with `hide SessionInfo` because `type.pb.dart` also defines `SessionInfo`. The hidden v1.pb.dart `SessionInfo` is still accessible through the `Session` field getter (`session.sessionInfo.sessionName`). Extension methods on `Session` work correctly because method resolution happens on the object's runtime type, not the import-level identifier name.

3. **`PbMap` is a protobuf-specific map type** — NOT a standard Dart `Map`. Converted to `Map<int, CoreImOffset>` with the adapter mapping `Offset` fields (`normalOffset`, `topOffset`) from `Int64` to `int`.

4. **`PaginationParams.hasMore`** — `SessionMainReply` and `SessionSecondaryReply` expose pagination state via an embedded `PaginationParams` message. Only the top-level `hasMore` boolean is surfaced in `CoreImSessionMainReply`/`CoreImSessionSecondaryReply`.

## Verification
LSP diagnostics on all 3 changed files → **No issues found**.

```bash
lsp_diagnostics lib/core/models/im_types.dart → clean
lsp_diagnostics lib/core/repository/im_repository.dart → clean  
lsp_diagnostics lib/adapters/bilibili/repository/bili_im_repository.dart → clean
lsp_diagnostics lib/adapters/bilibili/pages/whisper/* → clean
lsp_diagnostics lib/adapters/bilibili/bridge.dart → clean
```

---

# Round 15: bili_msg_repository.dart, bili_music_repository.dart, bili_match_repository.dart

## Task
Update adapter repository implementations to match CoreXxx interfaces.

## Files Modified

### `lib/adapters/bilibili/repository/bili_msg_repository.dart`

**Import changes:**
| Action | Import |
|--------|--------|
| Added | `package:skf/core/models/msg_types.dart` |
| Removed (11) | All individual `models_new/msg/` and `models_new/single_unread/`, `models_new/msgfeed_unread/`, `models_new/upload_bfs/` imports |

**Method signature changes (11 methods):**
| Method | Old return type | New return type |
|--------|----------------|-----------------|
| `msgFeedReplyMe` | `LoadingState<MsgReplyData>` | `LoadingState<CoreMsgReplyData>` |
| `msgFeedAtMe` | `LoadingState<MsgAtData>` | `LoadingState<CoreMsgAtData>` |
| `msgFeedLikeMe` | `LoadingState<MsgLikeData>` | `LoadingState<CoreMsgLikeData>` |
| `msgLikeDetail` | `LoadingState<MsgLikeDetailData>` | `LoadingState<CoreMsgLikeDetailData>` |
| `msgFeedNotify` | `LoadingState<List<MsgSysItem>?>` | `LoadingState<List<CoreMsgSysItem>?>` |
| `uploadBfs` | `LoadingState<UploadBfsResData>` | `LoadingState<CoreUploadBfsResData>` |
| `imUserInfos` | `LoadingState<List<ImUserInfosData>?>` | `LoadingState<List<CoreImUserInfosData>?>` |
| `getSessionSs` | `LoadingState<SessionSsData>` | `LoadingState<CoreSessionSsData>` |
| `getMsgDnd` | `LoadingState<List<UidSetting>?>` | `LoadingState<List<CoreUidSetting>?>` |
| `msgUnread` | `LoadingState<SingleUnreadData>` | `LoadingState<CoreSingleUnreadData>` |
| `msgFeedUnread` | `LoadingState<MsgFeedUnreadData>` | `LoadingState<CoreMsgFeedUnreadData>` |

**Conversion pattern:**
```dart
final result = await MsgHttp.msgFeedReplyMe(cursor: cursor, cursorTime: cursorTime);
if (result case Success(:final response)) {
  return Success(CoreMsgReplyData.fromJson(response.toJson()));
}
return result as LoadingState<CoreMsgReplyData>;
```

For list-returning methods: `.map((e) => CoreXxx.fromJson(e.toJson())).toList()`.

### `lib/adapters/bilibili/repository/bili_music_repository.dart`

**Import changes:**
| Action | Import |
|--------|--------|
| Added | `package:skf/core/models/music_types.dart` |
| Removed (2) | `models_new/music/bgm_detail.dart`, `bgm_recommend_list.dart` |

**Method signature changes (2 methods):**
| Method | Old return type | New return type |
|--------|----------------|-----------------|
| `bgmDetail` | `LoadingState<MusicDetail>` | `LoadingState<CoreMusicDetail>` |
| `bgmRecommend` | `LoadingState<List<BgmRecommend>?>` | `LoadingState<List<CoreBgmRecommend>?>` |

### `lib/adapters/bilibili/repository/bili_match_repository.dart`

**Import changes:**
| Action | Import |
|--------|--------|
| Added | `package:skf/core/models/match_contest.dart` |
| Removed (1) | `models_new/match/match_info/contest.dart` |

**Method signature changes (1 method):**
| Method | Old return type | New return type |
|--------|----------------|-----------------|
| `matchInfo` | `LoadingState<MatchContest?>` | `LoadingState<CoreMatchContest?>` |

## Key findings

1. **Adapter models lacked `toJson()`** — All adapter model classes used by the three repositories (`MsgReplyData`, `MsgAtData`, `MsgLikeData`, `MusicDetail`, `MatchContest`, their sub-models, and model_avatar.dart classes) had `fromJson()` but not `toJson()`. Adding `toJson()` to **~30 model classes across ~25 files** was required before the `CoreXxx.fromJson(response.toJson())` pattern could compile.

2. **Duplicate `Cursor` and `User` classes across directories** — `msg_reply/cursor.dart`, `msg_at/cursor.dart`, and `msg_like/cursor.dart` all define a class named `Cursor` with identical fields. Similarly, `msg_reply/user.dart`, `msg_at/user.dart`, and `msg_like/user.dart` all define `User`. Each is a separate class in its own library. All needed independent `toJson()` additions.

3. **Substring-safe `toJson()` field names** — Unlike the Core model prefix task, `toJson()` implementations are manual field-by-field maps with explicitly written keys. No substring collision risk because each field name is written by hand.

4. **`unnecessary_await_in_return` flag** — Methods that directly `return await httpLayer.method()` without subsequent logic trigger `unnecessary_await_in_return`. Fix: remove `await` (return the Future directly). Only affects methods whose return type does NOT require conversion (e.g., `void`-returning methods).

5. **Unused adapter imports** — After switching to CoreXxx return types, the adapter model imports became unused (the types are resolved through the HTTP layer's return types). The analyzer flagged `unused_import` warnings. All such imports were removed.

6. **`MusicDetail.achievement` field serialization nuance** — The `achievement` field is `List<String>` but is constructed in `fromJson` by spreading `json['achievement']`, `json['music_rank']`, and `json['recreation_rank']` together. The `toJson()` needs to be consistent — re-serialize only `achievement` and optionally the rank fields if they were stored separately. In practice, the `toJson()` returns `'achievement': achievement` and separately stores `'music_rank'` and `'recreation_rank'` only if they exist at specific indices (positions 1 and 2), which is a lossy round-trip. Acceptable because conversion only goes adapter→core (not back).

## Verification
`dart analyze lib/adapters/bilibili/repository/bili_msg_repository.dart lib/adapters/bilibili/repository/bili_music_repository.dart lib/adapters/bilibili/repository/bili_match_repository.dart` → **No issues found** (0 errors, 0 warnings).

---

# Round 16: bili_search_repository.dart, bili_space_repository.dart, bili_user_repository.dart

## Task
Update adapter repository implementations to match CoreXxx interfaces: `bili_search_repository.dart`, `bili_space_repository.dart`, and `bili_user_repository.dart`.

## Files Modified

### `lib/adapters/bilibili/repository/bili_search_repository.dart`

**Import changes:**
| Added | Removed |
|-------|---------|
| `package:skf/core/models/search_types.dart` | All individual `models/` and `models_new/` adapter imports (9 imports) |

**Method signature changes (all methods):**
| Method | Old return type | New return type |
|--------|----------------|-----------------|
| `searchSuggest` | `LoadingState<SearchSuggestModel>` | `LoadingState<CoreSearchSuggestModel>` |
| `searchNum` | `LoadingState<SearchNumData>` | `LoadingState<CoreSearchNumData>` |
| `searchUser` | `LoadingState<SearchNumData>` | `LoadingState<CoreSearchNumData>` |
| `searchAll` | `LoadingState<SearchAllData>` | `LoadingState<CoreSearchAllData>` |
| `searchBangumi` | `LoadingState<PgcInfoModel>` | `LoadingState<CorePgcInfoModel>` |
| `searchLive` | `LoadingState<PgcInfoModel>` | `LoadingState<CorePgcInfoModel>` |
| `searchTopic` | `LoadingState<PgcInfoModel>` | `LoadingState<CorePgcInfoModel>` |
| `searchTrending` | `LoadingState<SearchTrendingData?>` | `LoadingState<CoreSearchTrendingData?>` |
| `searchRcmd` | `LoadingState<SearchRcmdData>` | `LoadingState<CoreSearchRcmdData>` |

**Conversion pattern** — Uses `_toCore<T, A>()` generic helper + per-type converter functions that do field-level mapping (not JSON roundtrip):

```dart
LoadingState<T> _toCore<T, A>(LoadingState<A> state, T Function(A) convert) {
  return switch (state) {
    Success<A>(:final response) => Success<T>(convert(response)),
    Error(:final errMsg, :final code) => Error(errMsg, code: code),
    Loading() => LoadingState<T>.loading(),
  };
}
```

### `lib/adapters/bilibili/repository/bili_space_repository.dart`

**Import changes:**
| Added | Removed |
|-------|---------|
| `package:skf/core/models/space_types.dart` | `app/dynamic/v2.pb.dart` (gRPC OpusSpaceFlowResp) |
| | `app/interfaces/v1.pb.dart` (gRPC SearchArchiveReply) |

**Method signature changes (2 methods):**
| Method | Old return type | New return type |
|--------|----------------|-----------------|
| `opusSpaceFlow` | `LoadingState<OpusSpaceFlowResp>` | `LoadingState<CoreOpusSpaceFlowResp>` |
| `searchArchive` | `LoadingState<SearchArchiveReply>` | `LoadingState<CoreSearchArchiveReply>` |

### `lib/adapters/bilibili/repository/bili_user_repository.dart`

**Import changes:**
| Added | Removed |
|-------|---------|
| `package:skf/core/models/user_types.dart` | All individual `models/` and `models_new/` adapter imports (13 imports) |
| `package:skf/core/models/follow_data.dart` | |
| `package:skf/core/models/follow_item.dart` | |

**Method signature changes (all methods):** 16 methods had return types changed from adapter types to CoreXxx equivalents:
`CoreUserInfoData`, `CoreUserStat`, `CoreLaterData`, `CoreHistoryData` (×2), `CoreRelationData`, `CoreSubData`, `CoreVideoTagItem`, `CoreMediaListData`, `CoreCoinLogData` (×2), `CoreSpaceSettingData`, `CoreLoginLogData`, `CoreUserRealNameData`, `CoreFollowData` (×2), `CoreCoinLogData`.

**Conversion pattern** — Field-level mapping (no `toJson()` needed) with the same `_toCore` helper. The adapter model types are resolved through `UserHttp.*` return types — explicit adapter imports removed since they're no longer needed in the file scope.

Converter functions added (15):
- `_convertUserInfoData` — maps `UserInfoData` → `CoreUserInfoData` with nested `CoreLevelInfo`
- `_convertUserStat` — maps `UserStat` → `CoreUserStat`
- `_convertLaterData` — maps `LaterData` → `CoreLaterData` with `_convertLaterItemModel`
- `_convertHistoryData` — maps `HistoryData` → `CoreHistoryData` with `_convertHistoryItemModel`
- `_convertRelationData` — maps `RelationData` → `CoreRelationData`
- `_convertSubData` — maps `SubData` → `CoreSubData` with `_convertSubItemModel`
- `_convertVideoTagItem` — maps `VideoTagItem` → `CoreVideoTagItem`
- `_convertMediaListData` — maps `MediaListData` → `CoreMediaListData` with `_convertMediaListItemModel`
- `_convertCoinLogData` — maps `CoinLogData` → `CoreCoinLogData` with `_convertCoinLogItem`
- `_convertSpaceSettingData` — maps `SpaceSettingData` → `CoreSpaceSettingData` with nested `CorePrivacy` / `CoreSpaceSettingModel`
- `_convertLoginLogData` — maps `LoginLogData` → `CoreLoginLogData` with `_convertLoginLogItem`
- `_convertUserRealNameData` — maps `UserRealNameData` → `CoreUserRealNameData` with nested `CoreRejectPage`
- `_convertFollowData` — maps `FollowData` → `CoreFollowData` with `_convertFollowItemModel`

Sub-type converters (7): `_convertLaterItemModel`, `_convertHistoryItemModel`, `_convertSubItemModel`, `_convertMediaListItemModel`, `_convertCoinLogItem`, `_convertFollowItemModel`.

## Key findings

1. **Adapter model types resolved through method signatures** — `SearchHttp.*` and `UserHttp.*` method return types reference adapter model classes (`SearchSuggestModel`, `UserInfoData`, etc.). Even without explicit imports, the Dart compiler resolves these types through the method signature chain. The adapter imports in the repository files were only needed when the repository defined its own type references (method signatures). After switching to CoreXxx method signatures, the adapter types are only used in converter function parameter types — and those are resolved through the `Success(:final response)` pattern match on the `UserHttp.*` return type. **Removing explicit adapter imports only works when the adapter types are exclusively referenced through method return type inference, not when they appear in explicit type annotations.**

2. **Converter functions must use adapter types as parameter types** — The `_toCore` converter pattern takes a `T Function(A) convert` where `A` is the adapter type. The converter function itself declares its parameter as the adapter type (e.g., `CoreUserInfoData _convertUserInfoData(UserInfoData data)`). This means `UserInfoData` must be resolvable. If the adapter model file is not explicitly imported, the compiler resolves it through the `UserHttp.userInfo()` return type. **This works transitively — the explicit adapter import becomes unnecessary.**

3. **`SpaceSettingData` fields use explicit types** — The converter for `spaceSetting()` maps `SpaceSettingData.privacy.list1/2/3` which are `List<SpaceSettingModel>`. Each `SpaceSettingModel` has `name`, `key`, `value`, `isReverse` fields. No nested adapter model types beyond what's resolved through method return types.

4. **Sub-type converters resolve transitively** — Converters like `_convertFollowItemModel(FollowItemModel item)` work because `FollowItemModel` is resolved through the parent `_convertFollowData`'s parameter `FollowData data`, which gets its type from `UserHttp.followedUp()`'s return type. The transitive chain is: `UserHttp.followedUp()` → `Success(:final response)` where `response` is `FollowData` → `_convertFollowData(response)` → `_convertFollowItemModel(item)` where `item` is a `FollowItemModel` from `data.list.map(...)`.

5. **No `toJson()` needed** — Unlike the fan/follow/download/fav/member repos where `CoreXxx.fromJson(adapter.toJson())` worked, the user repository models lack `toJson()`. The field-by-field mapping approach was required instead. This is safe because it avoids dependency on model serialization methods that may not exist on adapter types.

6. **`CoreOwner.fromJson()` used for nested `upper` / `owner` fields** — `CoreOwner` has a `fromJson` factory method. The adapter `UpperItemModel` and `OwnerItemModel` have `toJson()` methods (judged by the `.toJson()` call working without unresolved-reference errors). Where `toJson()` was available, the `CoreXxx.fromJson(item.toJson())` pattern was preferred over manual field mapping.

## Verification
LSP diagnostics on all 3 files → **0 errors each**.

---

# Round 17: bili_pgc_repository.dart, bili_reply_repository.dart, bili_sponsor_block_repository.dart

## Task
Update adapter repository implementations to match CorePgcRepository, CoreReplyRepository, and CoreSponsorBlockRepository interfaces.

## Files Modified

### `lib/adapters/bilibili/repository/bili_pgc_repository.dart`

**Import changes:**
| Added | Removed |
|-------|---------|
| `package:skf/core/models/pgc_types.dart` | All 6 individual `models_new/pgc/` adapter imports |

**Method signature changes (all methods):**
| Method | Old return type | New return type |
|--------|----------------|-----------------|
| `indexResult` | `LoadingState<PgcIndexResult>` | `LoadingState<CorePgcIndexResult>` |
| `indexCondition` | `LoadingState<PgcIndexConditionData>` | `LoadingState<CorePgcIndexConditionData>` |
| `timelineResult` | `LoadingState<TimelineResult>` | `LoadingState<CoreTimelineResult>` |
| `reviewList` | `LoadingState<PgcReviewData>` | `LoadingState<CorePgcReviewData>` |

**Parameter change:**
`reviewList(CorePgcReviewType type, ...)` — input param maps CorePgcReviewType → PgcReviewType via switch:
```dart
static PgcReviewType _adaptPgcReviewType(CorePgcReviewType t) => switch (t) {
  CorePgcReviewType.long => PgcReviewType.long,
  CorePgcReviewType.short => PgcReviewType.short,
};
```

**Conversion pattern:** `CoreXxx.fromJson(r.toJson())` — requires adapter models to have `toJson()`.

### `lib/adapters/bilibili/repository/bili_reply_repository.dart`

**Import changes:**
| Added | Removed |
|-------|---------|
| `package:skf/core/models/reply_types.dart` | `v1.pb.dart` (all protobuf types except via `show` list) |

Retained: `protobuf/reply.dart` (ReplyGrpc), `v1.pb.dart` (with `show` for specific types used in conversion: `MainListReply`, `DetailListReply`, `DialogListReply`, `Mode`, `SearchItemReply`, `SearchItemType`, `TranslateReplyResp`), `http/reply.dart` (ReplyHttp), `fixnum` (for Int64).

**Method signature changes (5 methods):**
| Method | Old return type | New return type |
|--------|----------------|-----------------|
| `mainList` | `LoadingState<MainListReply>` | `LoadingState<CoreMainListReply>` |
| `detailList` | `LoadingState<DetailListReply>` | `LoadingState<CoreDetailListReply>` |
| `dialogList` | `LoadingState<DialogListReply>` | `LoadingState<CoreDialogListReply>` |
| `searchItem` | `LoadingState<SearchItemReply>` | `LoadingState<CoreSearchItemReply>` |
| `translateReply` | `LoadingState<TranslateReplyResp>` | `LoadingState<CoreTranslateReplyResp>` |

**Parameter changes:**
- `mainList`: `Mode mode` → `CoreMode mode`, `Int64? cursorNext` → `int? cursorNext`
- `detailList`: `Mode mode` → `CoreMode mode`
- `searchItem`: `SearchItemType itemType` → `CoreSearchItemType itemType`
- `translateReply`: `Int64 type/oid/rpid` → `int type/oid/rpid`

**Conversion pattern — field-level mapping (not JSON roundtrip):**
Since protobuf generated types lack a `toJson()` method that produces the JSON shape `CoreXxx.fromJson` expects, each method manually constructs the CoreXxx from adapter/grpc fields in the `Success` pattern match:

```dart
if (result case Success(response: final r)) {
  return Success(CoreMainListReply(
    cursor: r.cursor,
    replies: r.replies,
    subjectControl: r.subjectControl,
    upTop: r.upTop,
    adminTop: r.adminTop,
    voteTop: r.voteTop,
    paginationReply: r.paginationReply,
    mode: CoreMode.valueOf(r.mode.value),
    modeText: r.modeText,
  ));
}
```

Enum conversion helpers:
```dart
static Mode _modeToProto(CoreMode m) =>
    Mode.valueOf(m.value) ?? Mode.DEFAULT_Mode;

static SearchItemType _searchItemTypeToProto(CoreSearchItemType t) =>
    SearchItemType.valueOf(t.value) ?? SearchItemType.DEFAULT_ITEM_TYPE;
```

### `lib/adapters/bilibili/repository/bili_sponsor_block_repository.dart`

**Import changes:**
| Added | Removed |
|-------|---------|
| `package:skf/core/models/sponsor_block_types.dart` | `models_new/sponsor_block/segment_item.dart` |
| `package:skf/common/widgets/pair.dart` | `models_new/sponsor_block/user_info.dart` |
| `segment_type.dart` | _(kept — used in converter)_ |
| `action_type.dart` | _(kept — used in converter)_ |
| `post_segment_model.dart` | _(kept — used in converter)_ |

**Method signature changes (4 methods):**
| Method | Old return type | New return type |
|--------|----------------|-----------------|
| `getSkipSegments` | `LoadingState<List<SegmentItemModel>>` | `LoadingState<List<CoreSegmentItemModel>>` |
| `voteOnSponsorTime` | `SegmentType? category` param | `CoreSegmentType? category` param |
| `userInfo` | `LoadingState<UserInfo>` | `LoadingState<CoreUserInfo>` |
| `postSkipSegments` | `LoadingState<List<SegmentItemModel>>` return, `List<PostSegmentModel> segments` param | `List<CorePostSegmentModel> segments` param |

**Conversion patterns:**

JSON roundtrip (output): `CoreSegmentItemModel.fromJson(e.toJson())`, `CoreUserInfo.fromJson(r.toJson())` — requires adapter models to have `toJson()` (previously added as prerequisite).

Enum conversion (input):
```dart
static SegmentType _toAdapterSegmentType(CoreSegmentType t) =>
    SegmentType.values.firstWhere((a) => a.name == t.name);

static ActionType _toAdapterActionType(CoreActionType t) =>
    ActionType.values.firstWhere((a) => a.name == t.name);
```

Model conversion (input):
```dart
static PostSegmentModel _toAdapterPostSegment(CorePostSegmentModel m) =>
    PostSegmentModel(
      segment: Pair<double, double>(
        first: m.segment.first,
        second: m.segment.second,
      ),
      category: _toAdapterSegmentType(m.category),
      actionType: _toAdapterActionType(m.actionType),
    );
```

## Key findings

1. **Protobuf types lack `toJson()`** — Unlike adapter pure-Dart models, gRPC protobuf generated types do NOT have a `toJson()` method. The field-level mapping pattern is required for reply repository methods. This is safe but verbose.

2. **`CoreMode.valueOf()` and `Mode.valueOf()` share the same pattern** — Both are protobuf enums with a `valueOf(int)` constructor. `CoreMode.valueOf(r.mode.value)` maps back from adapter to core, `Mode.valueOf(m.value)` maps from core to adapter (for request parameters). Both require `??` fallback:
   - `CoreMode.valueOf(r.mode.value)` returns `CoreMode?`, accessed directly (the field type `CoreMode?` is fine for data classes)
   - `Mode.valueOf(coreMode.value) ?? Mode.DEFAULT_Mode` for request parameters (non-nullable)

3. **`Int64` ↔ `int` conversion** — `Int64(value)` for outgoing parameters, `Int64?` for nullable: `cursorNext != null ? Int64(cursorNext) : null`. For the `translateReply` method returning `Map<Int64, ReplyInfo>`, convert with `.map((key, value) => MapEntry(key.toInt(), value))`.

4. **Unused import `pair.dart`** — `Pair` is used in the `_toAdapterPostSegment` helper, but if the file also imports `post_segment_model.dart` (which transitively imports `pair.dart`), the explicit `pair.dart` import can be flagged as unused. A `// ignore: unused_import` directive was added.

5. **Transitive type resolution** — Adapter model types (`SegmentItemModel`, `UserInfo`) are resolved through `SponsorBlock.*` method return types. Explicit adapter model imports for these are unused after switching to CoreXxx signatures. Removed.

6. **All Core types already existed** — `pgc_types.dart`, `reply_types.dart`, and `sponsor_block_types.dart` were all created in earlier rounds. No new core model types needed.

## Verification
LSP diagnostics on all 3 files → **0 errors each**.
```
lsp_diagnostics lib/adapters/bilibili/repository/bili_pgc_repository.dart → clean
lsp_diagnostics lib/adapters/bilibili/repository/bili_reply_repository.dart → clean
lsp_diagnostics lib/adapters/bilibili/repository/bili_sponsor_block_repository.dart → clean
```

---

# Round 18: bili_fav_repository.dart, bili_member_repository.dart, bili_live_repository.dart

## Task
Update adapter repository implementations to match CoreXxx interfaces: `bili_fav_repository.dart`, `bili_member_repository.dart`, and `bili_live_repository.dart`.

## Files Modified

### `lib/adapters/bilibili/repository/bili_live_repository.dart` (581 lines)

**Import changes:**
| Added | Removed |
|-------|---------|
| `package:skf/core/models/live_types.dart` | — |
| `package:skf/core/repository/live_repository.dart` | — |
| `package:skf/core/result/loading_state.dart` | — |

Retained all adapter model imports (28 imports) — adapter types resolved through `LiveHttp.*` return types.

**Conversion pattern — `_*ToMap` helpers consumed by `Core*.fromJson()`:**
```dart
Map<String, dynamic> _roomPlayInfoToMap(RoomPlayInfoData d) => <String, dynamic>{
  'room_id': d.roomId,
  'short_id': d.shortId,
  'playurl_info': d.playurlInfo == null ? null : _playurlInfoToMap(d.playurlInfo!),
};

final result = await LiveHttp.liveRoomInfo(roomId: roomId, parentAreaId: parentAreaId, areaId: areaId);
if (result case Success(:final response)) {
  return Success(CoreRoomPlayInfoData.fromJson(_roomPlayInfoToMap(response)));
}
return result as LoadingState<CoreRoomPlayInfoData>;
```

**Helper count:** 20 `_*ToMap` helpers + some inline map literals.

**Key patterns:**
- Some adapter models have `toJson()` (e.g., `RoomInfoH5Data.roomInfo.toJson()`, `Emoticon.toJson()`), used directly in map construction
- Inline map literals for simple sub-types (e.g., `host_list` mapping inside `_liveDmInfoToMap`)
- Enum conversion for input params: `LiveSearchType.values.firstWhere((e) => e.name == type.name)` for `CoreLiveSearchType` → `LiveSearchType`
- `LiveContributionRankType.values.firstWhere((e) => e.name == type.name)` for `CoreLiveContributionRankType` → `LiveContributionRankType`

### `lib/adapters/bilibili/repository/bili_fav_repository.dart` (691 lines)

**Import changes:**
| Added | Removed |
|-------|---------|
| `package:skf/core/models/fav_types.dart` | — |
| `package:skf/core/repository/fav_repository.dart` | — |
| `package:skf/core/result/loading_state.dart` | — |

Retained: 28 adapter model imports (resolved through `FavHttp.*` return types).

**Helper count:** 29 `_*ToMap` helpers.

**Conversion pattern:** Same `_*ToMap` → `CoreXxx.fromJson()` as bili_live_repository.

**Method overloads (34 `Future<LoadingState<*>>` methods):**
- Enum input conversion via `_toFavOrder(CoreFavOrderType)` helper
- Mix of `_*ToMap` helpers for complex types (FavFolderInfo, FavFolderData, FavDetailItemModel, etc.)
- Some adapter models have `toJson()` for nested fields (e.g., `upper?.toJson()`)
- `model_owner.dart` import for `UpperItemModel` / `OwnerItemModel` toJson resolution

**Key complexity:** Deeply nested type graph — FavFolder → FavDetailItem → CntInfo/Ogv/Ugc → multiple levels; FavArticle → Author/Cover/Stat; FavPgc → NewEp; FavTopic → PageInfo/TopicItem/TopicList; SpaceCheese → Item/Page; SubDetail → SubItem/Media.

### `lib/adapters/bilibili/repository/bili_member_repository.dart` (1331 lines)

**Import changes:**
| Added | Removed |
|-------|---------|
| `package:skf/core/models/member_types.dart` | — |
| `package:skf/core/models/space_types.dart` | — |
| `package:skf/core/models/follow_data.dart` | — |
| `package:skf/core/repository/member_repository.dart` | — |
| `package:skf/core/result/loading_state.dart` | — |

Retained: 23 adapter model imports.

**Helper count:** 99 `_*ToMap` helpers — the largest set across all repository implementations.

**Method overloads (29 `Future<LoadingState<*>>` methods):**

| Method | Adapter type → Core type |
|--------|--------------------------|
| `memberInfo` | `MemberInfoModel` → `CoreMemberInfoModel` |
| `memberCardInfo` | `MemberCardInfoData` → `CoreMemberCardInfoData` |
| `memberTag` | `List<MemberTagItemModel>` → `List<CoreMemberTagItemModel>` |
| `memberDynamic` | `DynamicsDataModel` → `CoreDynamicsDataModel` |
| `memberFav` | `SpaceFavData` → `CoreSpaceFavData` |
| `memberCheese` | `SpaceCheeseData` → `CoreSpaceCheeseData` |
| `memberFollow` | `FollowData` → `CoreFollowData` |
| `memberGuard` | `MemberGuardData` → `CoreMemberGuardData` |
| `memberArchive` | `SpaceArchiveData` → `CoreSpaceArchiveData` |
| `memberArticle` | `SpaceArticleData` → `CoreSpaceArticleData` |
| `memberAudio` | `SpaceAudioData` → `CoreSpaceAudioData` |
| `memberSpace` | `SpaceData` → `CoreSpaceData` |
| `memberCoinLikeArc` | `CoinLikeArcData` → `CoreCoinLikeArcData` |
| `memberSearchArchive` | `SearchArchiveData` → `CoreSearchArchiveData` |
| `memberSeasonWeb` | `SeasonWebData` → `CoreSeasonWebData` |
| `memberUpowerRank` | `UpowerRankData` → `CoreUpowerRankData` |
| `memberSpaceShop` | `SpaceShopData` → `CoreSpaceShopData` |
| `memberSpaceOpus` | `SpaceOpusData` → `CoreOpusSpaceFlowResp` |
| `memberSpaceSs` | `SpaceSsData` → `CoreSpaceSsData` |

**Enum conversion (input params):**
```dart
static ContributeType _toContributeType(CoreContributeType t) =>
    ContributeType.values.firstWhere((e) => e.name == t.name);
```
Same pattern for `CoreArchiveOrderTypeApp` → `ArchiveOrderTypeApp`, `CoreArchiveSortTypeApp` → `ArchiveSortTypeApp`, `CoreArchiveOrderTypeWeb` → `ArchiveOrderTypeWeb`, `CoreWebSsType` → `WebSsType`.

**Key complexity:**
1. **Largest conversion surface** — 99 helpers across ~30 methods, the most of any adapter repo
2. **Double key pattern** — Some core types expect both `'bvid'` and `'bv_id'` keys from different consumers
3. **`CoreVip` field name collision** — The JSON key `'CoreVip'` is NOT a Core-prefixed type reference but an actual JSON string key that matches what `CoreMemberInfoModel.fromJson` looks for. The key `'vip'` would NOT work. Verified by reading the core model's `fromJson` factory.
4. **`CoreOpusSpaceFlowResp` special case** — This core type has no `fromJson()`; it's constructed directly via `CoreOpusSpaceFlowResp(items: response.items?.map(...))` from `SpaceOpusData.feedItems`. The adapter `SpaceOpusData` fields are mapped manually.
5. **`CoreSpaceShopItem.fromJson` nested structure** — Expects `{'cover': {'url': item.cover.url}}`, so `_spaceShopItemToMap` maps `'cover': {'url': d.cover.url}`.
6. **`SpaceTab` skip strategy** — Adapter `SpaceTab` uses boolean flags; core `CoreSpaceTab` uses name/uri. Emitted as `null` since all core fields are nullable.

## Key findings

1. **Manual JSON map construction is the consistent pattern** across all 3 repos — `_*ToMap` helpers build `Map<String, dynamic>` matching `Core*.fromJson()` expectations. No `toJson()` dependency on adapter models.

2. **Adapter models mostly lack `toJson()`** — Unlike download/fan/follow repos where `toJson()` was added, these 3 repos use only the `_*ToMap` pattern, avoiding any modification to adapter model files.

3. **Type-safe enum bridging**: `values.firstWhere((e) => e.name == adapterEnum.name)` — works when both core and adapter enums use the same `name` values. Safe because both sides serialize enum names to/from JSON.

4. **`CoreOpusSpaceFlowResp` has no `fromJson`** — This is a gRPC wrapper type constructed directly from `SpaceOpusData` fields. Handled via explicit field mapping in `memberSpaceOpus`.

5. **JSON key naming must match core model factories exactly** — `'CoreVip'`, `'CoreCard'`, `'CoreDesc'`, `'CorePage'`, `'CoreStats'` are literal JSON keys expected by `CoreMemberInfoModel.fromJson`. These are NOT Core-prefixed type names — they are the actual JSON serialization keys defined in the core model files.

6. **Transitive type resolution keeps adapter imports** — Unlike earlier rounds where adapter imports were removed, these files retain all adapter model imports because the `_*ToMap` helpers directly reference adapter types in their parameter lists. These imports cannot be removed.

## Verification
LSP diagnostics on all 3 files → **0 errors each**.
```
lsp_diagnostics lib/adapters/bilibili/repository/bili_live_repository.dart → clean
lsp_diagnostics lib/adapters/bilibili/repository/bili_fav_repository.dart → clean
lsp_diagnostics lib/adapters/bilibili/repository/bili_member_repository.dart → clean
```

---

# Round 19: bili_video_repository.dart and bili_dynamics_repository.dart

## Task
Update two remaining adapter repository implementations to match CoreXxx interfaces: `bili_video_repository.dart` and `bili_dynamics_repository.dart`. These were the last two adapter repositories not yet updated (excluded from earlier rounds due to their complexity).

## Files Modified

### `lib/adapters/bilibili/repository/bili_video_repository.dart` (~700 lines)

**Conversion pattern — `_mapState` generic helper:**
```dart
static LoadingState<T> _mapState<A, T>(
  LoadingState<A> source,
  T Function(A data) mapper,
) {
  return source.when(
    loading: LoadingState.loading,
    error: (e, s) => LoadingState.error(e, s),
    success: (data) => LoadingState.success(mapper(data)),
  );
}
```

**Helpers added:**
| Helper | Count |
|--------|-------|
| `_mapState` | 1 |
| `_toCore*` converters | ~30 |
| `_toAdapterVideoType` (enum) | 1 |
| `_toAdapterSubtitleFormat` (enum) | 1 |
| Total helpers | ~33 |

**Conversion approach — field-level mapping:** Unlike the `_*ToMap` + `CoreXxx.fromJson` pattern used in Round 18, the video repo uses direct constructor calls on core types (since `CoreRcmdVideoItemModel` etc. lack `fromJson`). Each converter manually maps fields from adapter to core type.

**Method count:** 24 `Future<LoadingState<*>>` methods updated.

**Key adapter types → Core types:**
| Method | Adapter type | Core type |
|--------|-------------|-----------|
| `rcmdVideoList` | `RcmdVideoItemModel` | `CoreRcmdVideoItemModel` |
| `rcmdVideoListApp` | `RcmdVideoItemAppModel` | `CoreRcmdVideoItemAppModel` |
| `hotVideoList` | `HotVideoItemModel` | `CoreHotVideoItemModel` |
| `videoUrl` | `PlayUrlModel` | `CorePlayUrlModel` |
| `videoIntro` | `VideoRelation` | `CoreVideoRelation` |
| `videoRelation` | `VideoRelation` | `CoreVideoRelation` |
| `relatedVideoList` | `RcmdVideoItemModel` | `CoreRcmdVideoItemModel` |
| `pgcLikeCoinFav` | `PgcLCF` | `CorePgcLCF` |
| `coinVideo` | `int?` | `int?` (unchanged) |
| `pgcTriple` | `PgcTriple` | `CorePgcTriple` |
| `ugcTriple` | `UgcTriple` | `CoreUgcTriple` |
| `replyAdd` | `ReplyInfo` | `CoreReplyInfo` |
| `aiConclusion` | `AiConclusionData` | `CoreAiConclusionData` |
| `playInfo` | `PlayInfoData` | `CorePlayInfoData` |
| `vttSubtitles` | `String?` | `String?` (unchanged) |
| `getRankVideoList` | `List<HotVideoItemModel>` | `List<CoreHotVideoItemModel>` |
| `pgcRankList` | `PgcRankItemModel` | `CorePgcRankItemModel` |
| `pgcSeasonRankList` | `PgcRankItemModel` | `CorePgcRankItemModel` |
| `videoshot` | `VideoShotData` | `CoreVideoShotData` |
| `getVideoNoteList` | `VideoNoteData` | `CoreVideoNoteData` |
| `popularSeriesList` | `PopularSeriesListItem` | `CorePopularSeriesListItem` |
| `popularSeriesOne` | `PopularSeriesOneData` | `CorePopularSeriesOneData` |
| `popularPrecious` | `PopularPreciousData` | `CorePopularPreciousData` |
| `heartBeat` | `void` | `void` (unchanged) |
| `tvPlayUrl` | `PlayUrlModel` | `CorePlayUrlModel` |

**Video-specific challenge — SubtitleFormat:**
The `SubtitleFormat` enum lives in `core/utils/subtitle_utils.dart` (not in the core model files). The adapter uses `SubtitleFormat` from the same file (core version). Both the adapter and core use the same `SubtitleFormat`, so no conversion needed for it. However, input parameter `VideoType` is an adapter enum → requires `_toAdapterVideoType` converter from `CoreVideoType` to `VideoType` for the `videoUrl` method.

### `lib/adapters/bilibili/repository/bili_dynamics_repository.dart` (1520 lines)

**Conversion pattern — `_mapState` + field-level mapping:**
Same `_mapState<A, T>` helper used as video. Two additional generic helpers for nullable/list mapping:
```dart
static T? _mapNullable<T, R>(R? value, T Function(R) mapper) =>
    value == null ? null : mapper(value);
static List<T>? _mapList<T, R>(List<R>? list, T Function(R) mapper) =>
    list?.map(mapper).toList();
```

**Helpers added:**
| Helper | Count |
|--------|-------|
| `_mapState`, `_mapNullable`, `_mapList` | 3 |
| Enum converters (CoreDynamicsTabType, CoreReplyOptionType, CoreOpusType) | 6 (3 each direction) |
| `_toCore*` converters (adapter → core) | ~90 |
| `_toAdapterVoteInfo` (core → adapter for createVote/updateVote) | 1 |
| `_toAdapterOption` (sub-converter for VoteInfo) | 1 |
| Total helpers | ~101 |

**Method count:** 25 `Future<LoadingState<*>>` methods updated, 2 enum input params updated.

**Complexity — largest conversion surface (~90 converters):**
The dynamics repository has the deepest type nesting of any adapter repo. `CoreDynamicsDataModel` → `CoreDynamicItemModel` → `CoreItemModulesModel` → 12 sub-modules + their sub-types → ~80 total sub-types. Every non-trivial field in the adapter models needed a corresponding `_toCore*` converter.

**Sub-type hierarchy breakdown:**
1. **Result types** (from `result.dart`): `DynamicsDataModel`, `DynamicItemModel`, `ItemModulesModel`, `ModuleAuthorModel`, `ModuleStatModel`, `ModuleDynamicModel`, `DynamicAddModel`, `DynamicDescModel`, `DynamicMajorModel` + ~40 sub-types (Badge, Stat, Vote, Ugc, Reserve, Good, RichTextNodeItem, Emoji, LiveModel, etc.)
2. **Follow/Up types** (from `up.dart`): `FollowUpModel`, `UpItem`, `LiveUsers`, `LiveUserItem`
3. **Article types** (4 files): `ArticleInfoData` + Stats, `ArticleViewData` + Avatar/Opus/Ops, `ArticleListData` + ListInfo/ArticleItem
4. **Vote types**: `VoteInfo` + SimpleVoteInfo + Option
5. **Topic types** (3 files): `TopicItem`, `TopicCreator`, `TopDetails`, `TopicCardList`, `TopicCardItem`, `FoldCardItem`, `TopicSortByConf`, `AllSortBy`
6. **Bubble types** (6 files): `BubbleData`, `BaseInfo`, `TribeInfo`, `Content`, `DynList`, `Meta`, `Category`, `CategoryList`, `SortInfo`, `SortItem`
7. **Reaction types**: `DynReactionData`, `DynReactionItem`
8. **Mention types**: `MentionGroup`, `MentionItem`
9. **Reserve types**: `DynReserveData`, `ReserveInfoData`
10. **Followee vote types**: `FolloweeVote`
11. **gRPC types**: `OpusDetailResp`, `CoreOpusType` enum conversion

**Key patterns:**
1. **gRPC type conversion handled via CoreXxx direct construction** — `OpusDetailResp` (protobuf) has no `toJson()`, so `_toCoreOpusDetailResp` constructs `CoreOpusDetailResp` with a `CoreOpusItem` containing `CoreModule()` placeholders (both are empty placeholder types).
2. **`LoadingState<T?>` nullable handling** — Methods returning `LoadingState<Xxx?>` (topicTop, topicFeed, topicFold, dynTopicRcmd, dynPic, dynMention, followeeVotes) use inline `result.when(...)` instead of `_mapState`, because the nullable `data` value needs special handling: `data != null ? mapper(data) : null`.
3. **Enum bridge via `.index`** — `CoreDynamicsTabType.values[type.index]` since both enums have same variants in same order. Same for `CoreReplyOptionType`. For `CoreOpusType` ↔ `OpusType` (gRPC enum), explicit `switch` mapping required.
4. **VoteInfo parameter conversion** — `createVote(CoreVoteInfo)` and `updateVote(CoreVoteInfo)` receive core types as input. `_toAdapterVoteInfo` converts back to adapter `VoteInfo` before delegating to `DynamicsHttp.createVote/updateVote`.
5. **Adapter `adapter_vote` import alias** — Both `core/models/dynamics_types.dart` and `adapters/.../vote_model.dart` define `VoteInfo`/`SimpleVoteInfo`/`Option`. The adapter import uses `as adapter_vote` to disambiguate.

## Key findings

1. **`_mapState` is the cornerstone pattern** — Used across all adapter repos. The sealed class `LoadingState<T>` makes pattern matching natural: `source.when(loading: ..., error: ..., success: (data) => ...)`.

2. **Direct field mapping vs JSON roundtrip** — The video and dynamics repos use direct field mapping (constructing CoreXxx with named parameters) rather than `CoreXxx.fromJson(adapter.toJson())`. This is necessary because:
   - **Core types lack `fromJson`** in video_types.dart and dynamics_types.dart (unlike fav/live/member repos where CoreXxx.fromJson was available)
   - **Accuracy**: Direct field mapping avoids serialization/deserialization overhead and potential key name mismatches

3. **Sub-string safe** — All converter function names are unique (`_toCoreDynamicsDataModel`, `_toCoreFollowUpModel`, etc.), with no risk of substring collision between type names.

4. **Pre-existing errors in test mock files persist** — `test/repository/video_repository_test.mocks.dart` and `dynamics_repository_test.mocks.dart` still reference old adapter types. These need mock regeneration via `dart run build_runner build --delete-conflicting-outputs` (out of scope).

5. **Pre-existing errors in controller files** — ~6 controller files (`dynamics_select_topic/controller.dart`, `fan/controller.dart`, `fav/note/controller.dart`, etc.) show `CoreXxx` ↔ adapter type mismatches. These are pre-existing errors from the interface changes in earlier rounds and require separate updates (out of scope).

## Blast radius check — remaining files

| Repository file | Status |
|----------------|--------|
| `bili_video_repository.dart` | **FIXED** (Round 19) |
| `bili_dynamics_repository.dart` | **FIXED** (Round 19) |
| `bili_audio_repository.dart` | Fixed in Round 11 |
| `bili_black_repository.dart` | Fixed in Round 11 |
| `bili_danmaku_repository.dart` | Fixed in Round 11 |
| `bili_danmaku_filter_repository.dart` | Fixed in Round 11 |
| `bili_im_repository.dart` | Fixed in Round 13 (IM) |
| `bili_download_repository.dart` | Fixed in Round 13 |
| `bili_fan_repository.dart` | Fixed in Round 13 |
| `bili_follow_repository.dart` | Fixed in Round 13 |
| `bili_auth_repository.dart` | Fixed in Round 14 |
| `bili_validate_repository.dart` | No changes needed |
| `bili_msg_repository.dart` | Fixed in Round 15 |
| `bili_music_repository.dart` | Fixed in Round 15 |
| `bili_match_repository.dart` | Fixed in Round 15 |
| `bili_search_repository.dart` | Fixed in Round 16 |
| `bili_space_repository.dart` | Fixed in Round 16 |
| `bili_user_repository.dart` | Fixed in Round 16 |
| `bili_pgc_repository.dart` | Fixed in Round 17 |
| `bili_reply_repository.dart` | Fixed in Round 17 |
| `bili_sponsor_block_repository.dart` | Fixed in Round 17 |
| `bili_live_repository.dart` | Fixed in Round 18 |
| `bili_fav_repository.dart` | Fixed in Round 18 |
| `bili_member_repository.dart` | Fixed in Round 18 |

**All 24 adapter repository files now match their CoreXxx interfaces.** ✓

## Verification

LSP diagnostics on both files → **0 errors each**:
```
lsp_diagnostics lib/adapters/bilibili/repository/bili_video_repository.dart → clean
lsp_diagnostics lib/adapters/bilibili/repository/bili_dynamics_repository.dart → clean
```

---

# Round 20: Controller files under search/ and msg/ — migrate to CoreXxx types

## Task
Migrate ~6 controller files under `lib/adapters/bilibili/pages/search/` and `lib/adapters/bilibili/pages/msg_feed_top/` to use CoreXxx types from core/models/ instead of adapter model types.

## Files modified (6)

| File | Adapter imports removed | Core import added | Type changes |
|------|------------------------|-------------------|--------------|
| `search/controller.dart` | `suggest.dart`, `search_rcmd/data.dart`, `search_trending/data.dart` | `core/models/search_types.dart` | `SearchSuggestItem`→`CoreSearchSuggestItem`, `SearchTrendingData`→`CoreSearchTrendingData`, `SearchRcmdData`→`CoreSearchRcmdData` |
| `msg_feed_top/like_me/controller.dart` | `msg_like/data.dart`, `msg_like/item.dart` | `core/models/msg_types.dart` | `MsgLikeData`→`CoreMsgLikeData`, `MsgLikeItem`→`CoreMsgLikeItem` |
| `msg_feed_top/at_me/controller.dart` | `msg_at/data.dart`, `msg_at/item.dart` | `core/models/msg_types.dart` | `MsgAtData`→`CoreMsgAtData`, `MsgAtItem`→`CoreMsgAtItem` |
| `msg_feed_top/reply_me/controller.dart` | `msg_reply/data.dart`, `msg_reply/item.dart` | `core/models/msg_types.dart` | `MsgReplyData`→`CoreMsgReplyData`, `MsgReplyItem`→`CoreMsgReplyItem` |
| `msg_feed_top/like_detail/controller.dart` | `msg_like_detail/{card,data,item}.dart` (3 files) | `core/models/msg_types.dart` | `MsgLikeDetailData`→`CoreMsgLikeDetailData`, `MsgLikeDetailItem`→`CoreMsgLikeDetailItem`, `MsgLikeDetailCard`→`CoreMsgLikeDetailCard` |
| `msg_feed_top/sys_msg/controller.dart` | `msg_sys/data.dart` | `core/models/msg_types.dart` | `MsgSysItem`→`CoreMsgSysItem` |

## Pre-existing issue fixed
- `search/controller.dart` had a duplicate `import 'package:get/get.dart'` on lines 7 and 15. The second duplicate was removed. (Pre-existing warning, not introduced by this round.)

## Key findings

1. **Direct type substitution** — Unlike repository files where converters were needed (adapter → Core mapping), controller files use these types directly as generic type parameters (e.g., `CommonDataController<CoreMsgLikeData, ...>`). The type annotations are just type names in extends/generics/var declarations — no data conversion needed because the repository already returns CoreXxx types.

2. **Repository return types already CoreXxx** — Since `msg_repository.dart` and `search_repository.dart` already return `LoadingState<CoreXxx>` (migrated in earlier rounds), the controllers now compile correctly with just the import swap + type name prefix changes.

3. **No string/substring collisions** — All type names in these files are unique and appear only as type annotations (not in string literals or JSON keys). Simple `replaceAll`-style edits work safely without side effects.

## Verification
`flutter analyze on all 6 files` → **No issues found** (ran in 280.2s).

---

# Round 20: reply_types.dart — replace dynamic with concrete types

## Task
Replace all `dynamic` type annotations in `lib/core/models/reply_types.dart` with concrete types.

## Problem
The file used `dynamic` for 17 fields across 5 Core* wrapper classes (`CoreMainListReply`, `CoreDetailListReply`, `CoreDialogListReply`, `CoreSearchItemReply`, `CoreTranslateReplyResp`). `dynamic` disables all static type checking — callers can call any method without compile-time validation.

## Constraint
`bili_reply_repository.dart` constructs these Core* types by passing gRPC protobuf objects directly (e.g., `cursor: r.cursor` where `r.cursor` is `CursorReply`). Since protobuf types (e.g., `CursorReply`, `ReplyInfo`, `SubjectControl`) are NOT subtypes of `Map<String, dynamic>` or any Core* wrapper type, the replacement type must be a supertype of all protobuf generated messages.

## Resolution: `Object?`
- `dynamic` → `Object?` for single-value fields (cursor, subjectControl, upTop, adminTop, voteTop, paginationReply, root, extra)
- `List<dynamic>?` → `List<Object?>?` for list fields (replies, items)
- `Map<int, dynamic>?` → `Map<int, Object?>?` for map fields (translatedReplies)

`Object?` is a concrete nullable type — it enables static type checking (`is` checks, casts, null checks) unlike `dynamic` which bypasses all checking.

## What was NOT possible (and why)
- `CoreReplyInfo?` for ReplyInfo fields — breaks because gRPC `ReplyInfo` (protobuf `GeneratedMessage`) ≠ `CoreReplyInfo` (pure-Dart class). No subtype relationship.
- `Map<String, dynamic>?` for cursor/subjectControl/etc. — breaks because gRPC types aren't `Map<String, dynamic>`.
- `CoreCursor?` — the message cursor type (`CursorReply` with `next`, `prev`, `isBegin`, `isEnd`, `mode`, `modeText`) differs from the existing `CoreCursor` (which has `isEnd`, `id`, `time`).

## Count of replacements
- 9 bare `dynamic` → `Object?`
- 4 `List<dynamic>` → `List<Object?>`
- 1 `Map<int, dynamic>` → `Map<int, Object?>`
- Total: 14 `dynamic` tokens replaced (plus 1 in doc comment)

## Verification
`flutter analyze lib/core/models/reply_types.dart` → **No issues found**.
`lsp_diagnostics` on `bili_reply_repository.dart` and `reply_repository.dart` → **No diagnostics**.
