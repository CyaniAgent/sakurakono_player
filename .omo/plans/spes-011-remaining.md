# spes-011-remaining - Work Plan

## TL;DR (For humans)

**What you'll get:** The remaining 23 repository interfaces in `lib/core/repository/` fully decoupled from B站 adapter code. Each interface owns its own core model types (migrated to `core/models/`) instead of importing from `adapters/bilibili/`. The Player Factory now supports plugin-based media sources via a new DataSource parameter. All 24 existing repository unit tests updated to compile and pass with the new interface signatures. Flutter analyze stays at 0 errors throughout.

**Why this approach:** Model-copy to `core/models/` (not `Map`/`dynamic` — preserves type safety) with 4 sequential sprints that maximize parallelism while respecting the FollowData shared-model dependency. P2 (FollowData) must run first because it unblocks 4 repos. P1 (7 simple repos) + P5 (plugin wiring) run in parallel. P3 (14 medium repos, heaviest at 15-20 days) runs next. P6 (2 hardest, auth+im) last. Tests-after throughout.

**What it will NOT do:** No UI/widget changes. No new features. No deletion of adapter model files (they stay for adapter implementations). No changes to `BiliBridge.register()` or DI. No changes to `lib/common/`. No changes to gRPC generated `.pb.dart` files. No migration of adapter models en masse — only what each interface signature needs.

**Effort:** XL — 28-35 days across 23 repos + plugin wiring + test updates
**Risk:** High — gRPC wrapper design for 7 repos is unvalidated, P3 alone is 15-20 days, interface changes cascade to adapter implementations, auth/Account abstraction is the hardest piece

**Decisions to sanity-check:** (1) Model-copy not extract — adapter keeps its own copy of each model. (2) P5 is minimal `DataSource?` parameter on `create()`, no PlayerFactory redesign. (3) P6 deferred to final sprint — auth and im block nothing and have deepest coupling.

Your next move: approve and start work, or opt for a high-accuracy review first. Full execution detail follows below.

---

> TL;DR (machine): 23 repo interfaces decoupled from adapters via model migration to core/models/; PlayerFactory wired for plugin; 24 tests updated; 4 execution sprints (A→B→C→D); XL effort, High risk.

## Scope
### Must have
- **P0**: Fix all pre-existing flutter analyze warnings (list TBD — grep `// ignore:` and verify `flutter analyze` 0 errors after)
- **P1**: Decouple 7 "simple" repository interfaces — migrate 1-2 model types each to `core/models/`
- **P2**: Migrate shared `FollowData` model to `core/models/follow_data.dart` (unlocks 4 repos: fan, follow, member, user)
- **P3**: Decouple 14 "medium" repository interfaces — migrate 3-23 model types each, create gRPC wrapper types, create core enum definitions, replace external deps (dio→core CancelToken, fixnum→int, protobuf→Map, Pair→core/utils/)
- **P4**: Update all 24 existing `test/repository/*_test.dart` files to compile and pass with new interface signatures
- **P5**: Wire `Plugin`/`DataSource` into `PlayerFactory` — add optional `DataSource?` param to `create()`
- **P6**: Decouple `auth_repository.dart` (Account abstraction) + `im_repository.dart` (gRPC deep coupling)
- Keep `flutter analyze` at **0 errors** after each commit

### Must NOT have (guardrails, anti-slop, scope boundaries)
- NO UI/widget changes — this is data layer only
- NO new features — zero new method definitions on any existing interface
- NO deletion of adapter model files — adapter implementations still need them
- NO changes to `BiliBridge.register()` or DI binding registration
- NO changes to `lib/common/` (already adapter-free per spes-010)
- NO changes to gRPC `.pb.dart` generated files (excluded from analysis anyway)
- NO playing with `analysis_options.yaml` — pre-existing info-level lint issues (~370) stay as-is
- NO pushing adapter models into core/ en masse — migrate only what each interface signature needs
- NO TDD — repos exist, tests exist, we adapt them (tests-after)

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- Test decision: tests-after + mockito + flutter_test
- Evidence: `.omo/evidence/spes-011/` (create if not exist)
- Every todo MUST end with:
  1. `flutter analyze` passes (0 errors)
  2. `flutter test` passes (all 72+ tests)
  3. grep assertion: `grep -r "import.*adapters/bilibili" lib/core/repository/<repo_file>.dart` returns 0 matches
  4. Evidence file written to `.omo/evidence/spes-011/task-N-<desc>.md`

## Execution strategy

### Execution waves (4 sprints)
| Sprint | Todos | Est. effort | Parallelizable? |
|--------|-------|-------------|-----------------|
| **A** | P0 (warnings) + P2 (FollowData) | 1 day | P0 ⟂ P2 |
| **B** | P1 (7 simple repos) + P5 (plugin) + P4 (test update for P1) | 3-4 days | P1 ⟂ P5; P4 depends on P1 |
| **C** | P3 (14 medium repos) + P4 (test update for P3) | 15-20 days | P3 repos parallelizable within sprint; P4 depends on P3 |
| **D** | P6 (auth + im) + P4 (test update for P6) | 10-12 days | auth ⟂ im |

### Decoupling strategy (same for ALL repos)
For each repository interface file:
1. **Identify** which adapter types appear in the interface's method signatures (return types, parameter types)
2. **For simple data models**: Copy the model class(es) into `core/models/<repo_name>_types.dart`, strip adapter-only fields, add `fromMap`/`toMap` serialization
3. **For gRPC protobuf types**: Create pure-Dart wrapper types in `core/models/<repo_name>_types.dart` — the interface uses these wrappers; the adapter implementation converts between protobuf and wrapper types
4. **For enums**: Redefine the enum in `core/models/<repo_name>_enums.dart` with identical values
5. **For external deps**: Replace `dio.CancelToken` with core abstract, `fixnum.Int64` with `int`, `protobuf.PbMap` with `Map<String, dynamic>`, `Pair` with `core/utils/pair.dart`
6. **Update the interface** file to import only `package:skf/core/...` packages
7. **Update the adapter implementation** file (`lib/adapters/bilibili/repository/`) to import the new core model and convert between core↔adapter types
8. **Regenerate mocks** and update tests
9. **Verify**: grep zero adapter imports in interface, `flutter analyze` 0 errors, all tests pass

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| P2 (FollowData) | — | P1: fan, follow | P0 |
| P1: black | P2 (for fan+follow only) | P4 | P1 all others, P5 |
| P1: download | — | P4 | P1 all others, P5 |
| P1: fan | P2 | P4 | P1 all others, P5 |
| P1: follow | P2 | P4 | P1 all others, P5 |
| P1: match | — | P4 | P1 all others, P5 |
| P1: music | — | P4 | P1 all others, P5 |
| P1: danmaku_filter | — | P4 | P1 all others, P5 |
| P5 (plugin) | — | — | P1, all |
| P3: 14 repos | P1 (pattern established) | P4, P6 | Within P3, all parallel |
| P4 (test updates) | P1, P3, P6 | — | Within P4, all parallel |
| P6: auth | P3 | — | P6: im |
| P6: im | P3 | — | P6: auth |

## Todos

<!-- APPEND TASK BATCHES BELOW THIS LINE WITH edit/apply_patch - never rewrite the headers above. -->

### Sprint A — Foundation (Wave 1)

- [x] 1. **P0: Fix pre-existing flutter analyze warnings**
  What to do / Must NOT do: Run `flutter analyze` and collect the exact warning list. For each pre-existing warning that is in non-generated source code, either fix the root cause (preferred) or add `// ignore:` with a `// TODO(spes-011):` justification comment. Do NOT add ignores to gRPC generated `.pb.dart` files (already excluded from analysis). Do NOT change analysis_options.yaml. Do NOT fix info-level lint issues (~370 pre-existing). After all fixes, `flutter analyze` must show 0 errors (info-level issues are acceptable).
  Parallelization: Wave 1 | Blocked by: — | Blocks: —
  References: `flutter analyze` output; `analysis_options.yaml` (excludes `lib/grpc/bilibili/**`)
  Acceptance criteria (agent-executable): `flutter analyze` exits with 0 and shows 0 errors (warnings are acceptable if they are pre-existing info-level lints). Each `// ignore:` has a `// TODO(spes-011):` comment above it.
  QA scenarios: happy — `flutter analyze` returns exit code 0; failure — any new error after a fix is introduced, verify by reverting and re-running.
  Evidence: `.omo/evidence/spes-011/task-1-warnings.md`
  Commit: Y | `fix(spes-011): resolve pre-existing flutter analyze warnings`

- [x] 2. **P2: Migrate FollowData model to `core/models/follow_data.dart`**
  What to do / Must NOT do: Copy the `FollowData` model class from `adapters/bilibili/models_new/follow/data.dart` to `lib/core/models/follow_data.dart`. The copy must strip any adapter-only fields and keep only the data fields used by the 4 consuming repository interfaces (fan, follow, member, user). Add JSON serialization (`fromJson`/`toJson`) if not present. Update `fan_repository.dart`, `follow_repository.dart`, `member_repository.dart`, `user_repository.dart` to import from `package:skf/core/models/follow_data.dart` instead of adapter path. Update the 4 adapter implementation files to import the core copy. Do NOT delete the original adapter model file — the adapter implementations still reference it internally. Do NOT change any method signatures in this step (that happens in P1/P3). This is purely an import path swap.
  Parallelization: Wave 1 | Blocked by: — | Blocks: P1: fan, follow
  References: `lib/adapters/bilibili/models_new/follow/data.dart` (source); `lib/core/repository/fan_repository.dart`, `lib/core/repository/follow_repository.dart`, `lib/core/repository/member_repository.dart`, `lib/core/repository/user_repository.dart` (consumers); `lib/adapters/bilibili/repository/` (4 impl files)
  Acceptance criteria (agent-executable): `grep -r "import.*adapters/bilibili.*follow/data" lib/core/repository/` returns 0 matches. `flutter analyze` 0 errors. `flutter test` all pass.
  QA scenarios: happy — 4 repo interfaces import from core, `flutter test` passes; failure — any test fails due to model shape mismatch, verify by checking the model's field list matches original.
  Evidence: `.omo/evidence/spes-011/task-2-followdata.md`
  Commit: Y | `feat(spes-011): migrate FollowData model to core/models/`

### Sprint B — Simple repos + Plugin (Wave 2)

- [x] 3. **P1a: Decouple `black_repository.dart` — migrate BlackListData**
  What to do / Must NOT do: Copy `BlackListData` from `adapters/bilibili/models_new/blacklist/data.dart` to `core/models/blacklist_data.dart`. Add JSON serialization. Update `black_repository.dart` import. Update `BiliBlackRepository` adapter implementation to import core model and convert if needed. Run mock regeneration for `black_repository_test.dart`.
  Parallelization: Wave 2 | Blocked by: — | Blocks: P4
  References: Report: lines 68-78; `lib/core/repository/black_repository.dart:1` (current adapter import)
  Acceptance criteria: `grep "import.*adapters/bilibili" lib/core/repository/black_repository.dart` → 0 matches. `flutter analyze` 0 errors. `flutter test` passes.
  QA scenarios: happy — interface uses core model, tests pass; failure — adapter import still present.
  Evidence: `.omo/evidence/spes-011/task-3-black.md`
  Commit: Y | `feat(spes-011): decouple black_repository.dart — migrate BlackListData`

- [x] 4. **P1b: Decouple `download_repository.dart` — migrate download models**
  What to do / Must NOT do: Copy `BiliDownloadEntryInfo`, `BiliDownloadMediaInfo`, `SourceInfo`, `PageInfo`, `EpInfo` to `core/models/download_types.dart`. Update import in interface and adapter implementation. Regenerate mocks and update tests.
  Parallelization: Wave 2 | Blocked by: — | Blocks: P4
  References: Report: lines 105-116; `lib/core/repository/download_repository.dart:1-2`
  Acceptance criteria: `grep "import.*adapters/bilibili" lib/core/repository/download_repository.dart` → 0 matches. `flutter analyze` 0 errors.
  Evidence: `.omo/evidence/spes-011/task-4-download.md`
  Commit: Y | `feat(spes-011): decouple download_repository.dart — migrate download models`

- [x] 5. **P1c: Decouple `fan_repository.dart` + `follow_repository.dart` — use core FollowData**
  What to do / Must NOT do: Change both interfaces to use `package:skf/core/models/follow_data.dart` (already migrated in P2). Update method signatures if needed. Update adapter implementations to import core model. Remove adapter imports. Regenerate mocks.
  Parallelization: Wave 2 | Blocked by: P2 (task 2) | Blocks: P4
  References: Report: lines 148-158 (fan), 182-192 (follow); `lib/core/repository/fan_repository.dart:1`; `lib/core/repository/follow_repository.dart:1`
  Acceptance criteria: `grep "import.*adapters/bilibili" lib/core/repository/fan_repository.dart lib/core/repository/follow_repository.dart` → 0 matches each. `flutter analyze` 0 errors.
  Evidence: `.omo/evidence/spes-011/task-5-fan-follow.md`
  Commit: Y | `feat(spes-011): decouple fan+follow repos — use core FollowData`

- [x] 6. **P1d: Decouple `match_repository.dart` + `music_repository.dart`**
  What to do / Must NOT do: Migrate `MatchContest` to `core/models/match_contest.dart`. Migrate `MusicDetail`, `BgmRecommend` to `core/models/music_types.dart`. Update interface imports + adapter implementations. Regenerate mocks.
  Parallelization: Wave 2 | Blocked by: — | Blocks: P4
  References: Report: lines 239-249 (match), 308-319 (music)
  Acceptance criteria: `grep "import.*adapters/bilibili" lib/core/repository/match_repository.dart lib/core/repository/music_repository.dart` → 0 matches each.
  Evidence: `.omo/evidence/spes-011/task-6-match-music.md`
  Commit: Y | `feat(spes-011): decouple match+music repos — migrate models`

- [x] 7. **P1e: Decouple `danmaku_filter_repository.dart` (already partially done)**
  What to do / Must NOT do: This was the only repo already decoupled in the report (its interface already uses `LoadingState<DanmakuBlockDataModel>`). Verify the current state — it may already be adapter-free. If not, migrate `DanmakuBlockDataModel`, `SimpleRule` to `core/models/danmaku_block.dart`. Update interface import and adapter implementation.
  Parallelization: Wave 2 | Blocked by: — | Blocks: P4
  References: Report: lines 80-91
  Acceptance criteria: `grep "import.*adapters/bilibili" lib/core/repository/danmaku_filter_repository.dart` → 0 matches.
  Evidence: `.omo/evidence/spes-011/task-7-danmaku-filter.md`
  Commit: Y | `feat(spes-011): finalize danmaku_filter_repository decoupling`

- [x] 8. **P5: Wire Plugin/DataSource into PlayerFactory**
  What to do / Must NOT do: In `lib/core/player/player_factory.dart`, change `create()` to `create({DataSource? dataSource})`. The `dataSource` is converted to a `FileMediaSource` via `dataSource.toMediaSource()` at the call site (NOT inside the factory). Update `BiliPlayerFactory` adapter implementation to accept the optional param (ignore it — B站 adapter doesn't use plugins). Do NOT change the existing `create()` signature's non-nullable return — keep backward compat by only adding an optional parameter. Do NOT add plugin UI or file picker integration. Do NOT modify `PluginRegistry` or `LocalFilePlugin`.
  Parallelization: Wave 2 | Blocked by: — | Blocks: —
  References: `lib/core/player/player_factory.dart` (current); `lib/core/plugin/data_source.dart` (toMediaSource()); `lib/core/player/player_controller.dart` (VideoPlayerController); `lib/adapters/bilibili/player/bili_player_factory.dart` (impl)
  Acceptance criteria: `PlayerFactory.create()` accepts `DataSource?` parameter. `BiliPlayerFactory` compiles with the updated signature. `flutter analyze` 0 errors.
  QA scenarios: happy — `PlayerFactory.create(dataSource: myDataSource)` compiles, DataSource.toMediaSource() invoked at call site; failure — removing the optional param causes compile error, verify by checking the interface.
  Evidence: `.omo/evidence/spes-011/task-8-plugin-player.md`
  Commit: Y | `feat(spes-011): wire DataSource into PlayerFactory.create()`

- [x] 9. **P4 (Wave 2): Update tests for P1-decoupled repos**
  What to do / Must NOT do: After P1 (tasks 3-7), the 7 repository interfaces have new import paths and possibly changed model types. The 24 existing `test/repository/*_test.dart` files and their `.mocks.dart` files must be regenerated. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate mocks. Fix any test compilation errors due to signature changes. Add coverage if the P1 repos now support new code paths. Do NOT change test logic or assertions unless required by signature changes.
  Parallelization: Wave 2 | Blocked by: P1 (tasks 3,4,5,6,7) | Blocks: —
  References: `test/repository/` (24 files); `test/repository/*.mocks.dart` (24 files); pattern from `test/repository/danmaku_filter_repository_test.dart`
  Acceptance criteria: `flutter test` passes (all 70+ tests). `dart run build_runner build --delete-conflicting-outputs` succeeds. `flutter analyze` 0 errors.
  Evidence: `.omo/evidence/spes-011/task-9-tests-wave2.md`
  Commit: Y | `test(spes-011): update P1 repo tests for new signatures`

### Sprint C — Medium repos (Wave 3)

- [x] 10. **P3a: Decouple `pgc_repository.dart` + `sponsor_block_repository.dart`**
  What to do / Must NOT do: For `pgc_repository.dart` (1 enum `PgcReviewType` + 5 models) and `sponsor_block_repository.dart` (2 enums `PostSegmentModel`, `SegmentType` + 2 models): Create `core/models/pgc_types.dart` and `core/models/sponsor_block_types.dart` with enum definitions and model copies. Update imports in both interfaces and both adapter implementations. Update tests. Effort: ~3 days combined.
  Parallelization: Wave 3 | Blocked by: P1 (pattern established) | Blocks: P4 (wave 3 tests)
  References: Report: lines 321-336 (pgc), 384-397 (sponsor_block)
  Acceptance criteria: `grep "import.*adapters/bilibili" lib/core/repository/pgc_repository.dart lib/core/repository/sponsor_block_repository.dart` → 0 matches. `flutter analyze` 0 errors. `flutter test` passes.
  Evidence: `.omo/evidence/spes-011/task-10-pgc-sponsor.md`
  Commit: Y | `feat(spes-011): decouple pgc+sponsor_block repos`

- [x] 11. **P3b: Decouple `search_repository.dart` + `space_repository.dart` + `reply_repository.dart`**
  What to do / Must NOT do: `search_repository.dart` (1 enum `SearchType` + 7 models, 1 shared `Dimension`) — migrate to `core/models/search_types.dart`. `space_repository.dart` (2 gRPC types) — create pure-Dart wrapper types in `core/models/space_types.dart`, replace `fixnum.Int64` with `int`. `reply_repository.dart` (1 gRPC type `ReplyInfo` classes) — create wrapper types in `core/models/reply_types.dart`. Update all interfaces + adapter implementations. Effort: ~4-5 days combined.
  Parallelization: Wave 3 | Blocked by: — | Blocks: P4
  References: Report: lines 351-368 (search), 370-382 (space), 338-349 (reply)
  Acceptance criteria: All 3 interfaces have 0 adapter imports. `flutter analyze` 0 errors.
  Evidence: `.omo/evidence/spes-011/task-11-search-space-reply.md`
  Commit: Y | `feat(spes-011): decouple search+space+reply repos`

- [x] 12. **P3c: Decouple `fav_repository.dart` + `msg_repository.dart`**
  What to do / Must NOT do: `fav_repository.dart` (1 enum `FavOrderType` + 10 models) — migrate to `core/models/fav_types.dart`. `msg_repository.dart` (11 models + dio `CancelToken`) — migrate models to `core/models/msg_types.dart`, create abstract `CancelToken` in `core/models/cancel_token.dart`, replace dio dep. Update adapter implementations. Effort: ~4-5 days combined.
  Parallelization: Wave 3 | Blocked by: — | Blocks: P4
  References: Report: lines 160-180 (fav), 285-306 (msg)
  Acceptance criteria: Both interfaces have 0 adapter imports. `CancelToken` is abstract core type. `flutter analyze` 0 errors.
  Evidence: `.omo/evidence/spes-011/task-12-fav-msg.md`
  Commit: Y | `feat(spes-011): decouple fav+msg repos, abstract CancelToken`

- [x] 13. **P3d: Decouple `danmaku_repository.dart` + `audio_repository.dart`**
  What to do / Must NOT do: `danmaku_repository.dart` (1 gRPC type `DmSegMobileReply` + 1 model `DanmakuPost`) — create gRPC wrapper in `core/models/danmaku_types.dart`, migrate model. `audio_repository.dart` (2 gRPC types `PlayURLResp`, `PlaylistResp` etc.) — create gRPC wrappers in `core/models/audio_types.dart`, replace `fixnum.Int64` with `int`. Effort: ~3-4 days combined.
  Parallelization: Wave 3 | Blocked by: — | Blocks: P4
  References: Report: lines 41-53 (audio), 92-103 (danmaku)
  Acceptance criteria: Both interfaces have 0 adapter imports. `flutter analyze` 0 errors.
  Evidence: `.omo/evidence/spes-011/task-13-danmaku-audio.md`
  Commit: Y | `feat(spes-011): decouple danmaku+audio repos, create gRPC wrappers`

- [x] 14. **P3e: Decouple `user_repository.dart` — 13 models**
  What to do / Must NOT do: Migrate 13 adapter model types to `core/models/user_types.dart`. This includes `FollowData` (already in core from P2), `VideoTagItem` (shared with video_repo), and 11 user-specific models. Create `UserInfo`, `UserStat`, `CoinLogData`, `HistoryData`, `LaterData`, `LoginLogData`, `MediaListData`, `RelationData`, `SpaceSettingData`, `SubData`, `UserRealNameData`, `VideoTagItem`. Update interface import + adapter implementation. Effort: ~3-4 days.
  Parallelization: Wave 3 | Blocked by: — | Blocks: P4
  References: Report: lines 399-421; `lib/core/repository/user_repository.dart:1-13`
  Acceptance criteria: 0 adapter imports in user_repository.dart. `flutter analyze` 0 errors.
  Evidence: `.omo/evidence/spes-011/task-14-user.md`
  Commit: Y | `feat(spes-011): decouple user_repository.dart — migrate 13 models`

- [x] 15. **P3f: Decouple `live_repository.dart` — 2 enums + 16 models**
  What to do / Must NOT do: Migrate 2 enums (`LiveContributionRankType`, `LiveSearchType`) to `core/models/live_enums.dart`. Migrate 16 live models to `core/models/live_types.dart`. Update interface + adapter implementation. Effort: ~4-5 days.
  Parallelization: Wave 3 | Blocked by: — | Blocks: P4
  References: Report: lines 210-237; `lib/core/repository/live_repository.dart:1-18`
  Acceptance criteria: 0 adapter imports in live_repository.dart.
  Evidence: `.omo/evidence/spes-011/task-15-live.md`
  Commit: Y | `feat(spes-011): decouple live_repository.dart — migrate 18 types`

- [x] 16. **P3g: Decouple `video_repository.dart` + `member_repository.dart` + `dynamics_repository.dart`**
  What to do / Must NOT do: These are the 3 heaviest repos (20, 23, 19 adapter imports each). `video_repository.dart` (1 gRPC + 1 enum + 1 subtitle util + 17 models) — create `core/models/video_types.dart`, migrate `SubtitleFormat` to `core/utils/subtitle_utils.dart`. `member_repository.dart` (5 enums + 18 models) — create `core/models/member_types.dart`. `dynamics_repository.dart` (2 enums + 1 gRPC + 14 models + `Pair`) — create `core/models/dynamics_types.dart`, move `Pair` to `core/utils/pair.dart`. Effort: ~6-8 days combined (these are the heaviest).
  Parallelization: Wave 3 | Blocked by: — | Blocks: P4
  References: Report: lines 423-452 (video), 251-284 (member), 118-147 (dynamics)
  Acceptance criteria: All 3 interfaces have 0 adapter imports. `Pair` in core/utils/. `SubtitleFormat` in core/utils/. `flutter analyze` 0 errors.
  Evidence: `.omo/evidence/spes-011/task-16-video-member-dynamics.md`
  Commit: Y | `feat(spes-011): decouple video+member+dynamics repos`

- [x] 17. **P4 (Wave 3): Update tests for P3-decoupled repos**
  What to do / Must NOT do: After P3 (tasks 10-16), regenerate all mocks and fix test compilation errors. Run `dart run build_runner build --delete-conflicting-outputs` to regenerate `.mocks.dart` files. Fix any test logic that relied on adapter model types now replaced with core types. Do NOT change test assertions unless forced by type changes.
  Parallelization: Wave 3 | Blocked by: P3 (tasks 10-16) | Blocks: —
  References: `test/repository/` (all 24 files including P3 repos); pattern from existing tests
  Acceptance criteria: `flutter test` passes (all tests). `dart run build_runner build` succeeds. `flutter analyze` 0 errors.
  Evidence: `.omo/evidence/spes-011/task-17-tests-wave3.md`
  Commit: Y | `test(spes-011): update P3 repo tests for new signatures`

### Sprint D — Hard repos (Wave 4)

- [x] 18. **P6a: Decouple `auth_repository.dart` — abstract Account in core**
  What to do / Must NOT do: `auth_repository.dart` uses `Account` (a Bilibili adapter sealed class managing cookies, headers, GRPC metadata). This is the hardest decoupling task. Create an abstract `Account` interface in `core/models/account.dart` that exposes only the methods used by `auth_repository.dart` (likely `Future<Map<String, String>> headers`, login status checks). Create a wrapper in the adapter that implements core `Account` by delegating to the existing Bili `Account`. Migrate `LoginDevicesData` to `core/models/login_devices_data.dart`. Update `auth_repository.dart` to use core `Account` interface. Update `BiliAuthRepository` adapter implementation. Effort: ~4-5 days.
  Parallelization: Wave 4 | Blocked by: P3 (pattern established) | Blocks: P4
  References: Report: lines 55-66; `lib/core/repository/auth_repository.dart:1-2`; `lib/adapters/bilibili/utils/accounts/account.dart`
  Acceptance criteria: `auth_repository.dart` has 0 adapter imports. `Account` is a core abstract interface. `flutter analyze` 0 errors. `flutter test` passes.
  Evidence: `.omo/evidence/spes-011/task-18-auth.md`
  Commit: Y | `feat(spes-011): decouple auth_repository — abstract Account interface`

- [x] 19. **P6b: Decouple `im_repository.dart` — gRPC deep coupling**
  What to do / Must NOT do: `im_repository.dart` has 3 gRPC protobuf imports and all method signatures use protobuf types directly. This is the deepest gRPC coupling. Create pure-Dart wrapper types in `core/models/im_types.dart` for all protobuf types used in the interface: `RspSendMsg`, `RspShareList`, `RspSessionMsg`, `SessionMainReply`, `SessionSecondaryReply`, `ClearUnreadReply`, `SessionUpdateReply`, `PinSessionReply`, `UnPinSessionReply`, `DeleteSessionListReply`, `GetImSettingsReply`, `SetImSettingsReply`, `KeywordBlockingListReply`, `KeywordBlockingAddReply`, `KeywordBlockingDeleteReply`, `RspTotalUnread`, `SessionInfo`, `MsgType`, `Offset`, `SessionPageType`, `SessionId`, `IMSettingType`, `Setting`. Replace `fixnum.Int64` with `int`, `protobuf.PbMap` with `Map<String, dynamic>`. Update adapter implementation to convert between gRPC and wrapper types. Effort: ~5-7 days.
  Parallelization: Wave 4 | Blocked by: P3 | Blocks: P4
  References: Report: lines 194-208; `lib/core/repository/im_repository.dart:1-3`
  Acceptance criteria: `im_repository.dart` has 0 adapter imports. All protobuf types replaced with wrappers. `flutter analyze` 0 errors.
  Evidence: `.omo/evidence/spes-011/task-19-im.md`
  Commit: Y | `feat(spes-011): decouple im_repository — gRPC wrapper types`

- [x] 20. **P4 (Wave 4): Final test updates for P6**
  What to do / Must NOT do: Regenerate mocks and update tests for auth + im repos. Fix any remaining test compilation errors across all 24 test files. Run full test suite and fix any test logic issues introduced by interface changes.
  Parallelization: Wave 4 | Blocked by: P6 (tasks 18, 19) | Blocks: —
  References: `test/repository/auth_repository_test.dart`, `test/repository/im_repository_test.dart`; all 24 test files
  Acceptance criteria: `flutter test` passes (all tests). `dart run build_runner build --delete-conflicting-outputs` succeeds. `flutter analyze` 0 errors.
  Evidence: `.omo/evidence/spes-011/task-20-tests-wave4.md`
  Commit: Y | `test(spes-011): final test updates for P6 decoupling`

- [x] 21. **Final verification: grep zero adapter imports across ALL core/repository/**
  What to do / Must NOT do: Run comprehensive assertion that NO file under `lib/core/repository/` imports anything from `lib/adapters/`. Also check that `lib/core/player/` has no adapter imports. Verify `flutter analyze` 0 errors. Verify `flutter test` all pass. Write final evidence summary.
  Parallelization: Wave 4 | Blocked by: all prior tasks | Blocks: —
  References: All modified files
  Acceptance criteria: `grep -r "import.*adapters/bilibili" lib/core/repository/ lib/core/player/` returns 0 total matches. `flutter analyze` 0 errors. `flutter test` passes.
  Evidence: `.omo/evidence/spes-011/task-21-final-verification.md`
  Commit: N (verification only, no code changes)

## Final verification wave
> Runs in parallel after ALL todos. ALL must APPROVE. Surface results and wait for the user's explicit okay before declaring complete.
- [x] F1. Plan compliance audit — all 21 todos completed, no scope creep, no MUST NOT violations
- [x] F2. Code quality review — `dart analyze` 0 errors in lib/core/ and test/repository/, no regression, grep assertion passes (0 adapter imports in all 24 core/repository/ files)
- [x] F3. Real manual QA — `flutter test` all 72/72 pass, app compiles
- [x] F4. Scope fidelity — no UI changes, no new features, no changes to BiliBridge/DI/common/

## Commit strategy
- **Sprint A**: 2 commits (P0 warnings, P2 FollowData)
- **Sprint B**: 7 commits (one per P1 repo + P5 plugin + P4 test updates)
- **Sprint C**: 8 commits (one per P3 group + P4 test updates)
- **Sprint D**: 3 commits (P6 auth, P6 im, P4 final test updates)
- **F-verification**: No commit (evidence only)
- Commit message format: `<type>(spes-011): <description>` where type = feat/fix/test
- No squash — keep individual commits for traceability

## Success criteria
1. `grep -r "import.*adapters/bilibili" lib/core/repository/` returns 0 matches (all 23 interfaces clean)
2. `grep "import.*adapters/bilibili" lib/core/player/` returns 0 matches (PlayerFactory clean)
3. `flutter analyze` exits with 0 errors
4. `flutter test` passes (all 70+ tests)
5. All 24 test files compile and pass with new interface signatures
6. `PlayerFactory.create({DataSource? dataSource})` compiles
7. No files outside `lib/core/`, `lib/adapters/bilibili/repository/`, `test/repository/` were modified
8. `.omo/evidence/spes-011/` contains per-task evidence files
