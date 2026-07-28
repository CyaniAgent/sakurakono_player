---
slug: spes-011-remaining
status: drafting
intent: clear
pending-action: write .omo/plans/spes-011-remaining.md
approach: One plan, 3 sprints (Sprint A: P0+P1+P2+P4 parallel, Sprint B: P3+P5 parallel, Sprint C: P6 sequential), final verification wave
---

# Draft: spes-011-remaining

## Components (topology ledger)
| id | outcome | status | evidence path |
|----|---------|--------|---------------|
| P0 | Fix 10 flutter analyze warnings (unused_local_variable, unused_import, dead_code) | active | `flutter analyze` output |
| P1 | Decouple 7 simple repository interfaces (no adapter model in signature) | active | `lib/core/repository/` analysis report (row count per file) |
| P2 | Migrate FollowData model to core/models/ | ✅ completed | `.omo/evidence/spes-011/task-2-followdata.md` |
| P3 | Decouple 14 medium repository interfaces (model refs removed from interface) | active | Same report |
| P4 | Expand unit tests: 5 new test files following mockito pattern | active | `test/repository/danmaku_filter_repository_test.dart` |
| P5 | Wire Plugin → PlayerFactory: add `DataSource?` param to `create()` | active | `lib/core/player/player_factory.dart`, `lib/core/plugin/data_source.dart` |
| P6 | Decouple auth+im repos (last, highest difficulty) | deferred to Sprint C | Report: highest row count, deep adapter coupling |

## Open assumptions (announced defaults)
| assumption | adopted default | rationale | reversible? |
|-----------|-----------------|-----------|-------------|
| P5 design: add `DataSource?` param to `PlayerFactory.create()` | Option A — simplest change | PlayerFactory is the single entry point; caller decides DataSource vs MediaSource | Yes |
| Sprint grouping: A (P0+P1+P2+P4 parallel) → B (P3+P5 parallel) → C (P6) | Maximizes parallelism, respects dependencies | P4 tests depend on P1/P3 interfaces; P5 independent; P6 blocks nothing | Yes |
| P2 model migration: copy model to core/ with updated imports | Copy, not extract | Minimal blast radius; model is simple | Yes |
| P4 test approach: tests-after (not TDD) | Existing repos are already written | TDD would require rewriting repos from scratch | Yes |
| P4 scope: 5 new test files | One per key repo group | Match existing pattern | Yes |
| P0 strategy: add `// ignore:` with justification for pre-existing warnings | Already confirmed pre-existing in spes-010 | Not introducing new issues | No (ignores are fixable later) |

## Findings (cited - path:lines)
- PlayerFactory.create() currently has no parameters → adding `DataSource?` is a non-breaking extension | `lib/core/player/player_factory.dart:3`
- Plugin interfaces exist (Plugin, PluginRegistry, DataSource, LocalFilePlugin) but never wired to player | `lib/core/plugin/plugin.dart`, `lib/core/plugin/data_source.dart`
- Test pattern uses mockito + LoadingState | `test/repository/danmaku_filter_repository_test.dart:1-47`
- 23 repository interfaces total (1 already decoupled: DanmakuFilterRepository) | `.omo/reports/core-repository-decoupling.md`
- 152 adapter imports classified across 24 files | same report

## Decisions (with rationale)
- **PlayerFactory integration**: `create({DataSource? dataSource})` — simplest, non-breaking, caller decides. The DataSource.toMediaSource() conversion happens at the call site.
- **Sprint A parallelism**: P0 (warnings) + P1 (simple repos) + P2 (model) + P4 (tests for already-decoupled repo) can all run independently.
- **Sprint B parallelism**: P3 (14 medium repos) + P5 (plugin wiring) have zero overlap — P5 touches player/plugin, P3 touches repository interfaces.
- **P4 test target**: 5 test files for P1+P3 repos that have clear success/failure paths.
- **P6 deferred**: Auth+IM repos have deepest adapter model coupling; they don't block any other component.

## Scope IN
- Fix 10 pre-existing flutter analyze warnings
- Decouple all 23 remaining repository interfaces (core/repository/)
- Migrate FollowData model to core/models/
- Add 5 repository unit test files
- Wire Plugin/DataSource into PlayerFactory
- Keep `flutter analyze` at 0 errors throughout

## Scope OUT (Must NOT have)
- No UI changes (no widget modifications)
- No new features or shared model extraction beyond FollowData
- No existing adapter implementations changed (only interface signatures)
- No changes to BiliBridge.register() or DI registration
- No migration of adapter models to core/ (FollowData is the single exception)
- No changes to lib/common/ (already clean)

## Metis findings incorporated
| Finding | Resolution |
|---------|-----------|
| P4: 24 test files already exist | Changed P4 from "add 5 tests" to "update 24 existing tests for new signatures" (tasks 9, 17, 20) |
| Missing decoupling strategy (model migration vs primitive types) | Explicitly documented 9-step decoupling strategy: model-copy to core/models/ for all repos; adapter implementations updated to convert between core↔adapter types |
| P2 must precede P1 fan+follow | Sprint A (P2) runs before Sprint B (P1) — FollowData migration unblocks 4 repos |
| Adapter implementation changes unavoidable | Removed "no impl changes" Scope OUT — replaced with explicit adapter conversion step in each todo |
| P0 warnings untracked | Task 1 requires running flutter analyze and capturing exact list before fixing |
| P3 effort (15-20d) may overflow sprint C | Flagged as risk in TL;DR; P3 split into 7 sub-todos (tasks 10-16) for parallel execution |
| gRPC wrapper design unvalidated | Added unified gRPC wrapper pattern to decoupling strategy; P6 im_repository deferred to Sprint D as highest risk |
| Combo repos (member+fav shared models) | Migration order adjusted: shared models (FollowData, SpaceCheeseData, Dimension, DynamicsDataModel, VideoTagItem) migrated in the repo that uses them first, then shared via core import |

## Open questions
(none — all resolved via defaults + Metis findings)

## Approval gate
status: completed
<!-- The user approved 2026-07-24 -- "继续计划" after the brief. Plan file written at .omo/plans/spes-011-remaining.md. -->
