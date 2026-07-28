---
slug: fix-and-polish
status: awaiting-approval
intent: clear
pending-action: write .omo/plans/fix-and-polish.md
approach: 6-phase plan (P0-P5) — fix compile errors, commit, update OMO tracking, decouple common/ adapter imports, expand unit tests to all 24 repositories, wire LocalFilePlugin into player flow. P0+P1 merged commit, P2-P5 each independent commit.
---

# Draft: fix-and-polish

## Components (topology ledger)
| id | outcome | status | evidence path |
|----|---------|--------|---------------|
| P0 | 修复 6 个 compile error (fav/topic ×3, live_dm_block, popular_series, pgc controller) | active | `flutter analyze` — errors identified in 5 files |
| P1 | 提交工作区 ~200+ 已修改文件 | active | `git status --short` — modified/deleted/untracked files |
| P2 | 更新 OMO README — SPES-009 标记完成 | active | `.omo/README.md:16-18` |
| P3 | 解耦 common/ 的 13 个 adapter import (8 文件) | active | grep result — 8 files, 13 imports |
| P4 | 扩充单元测试覆盖全部 24 个 Repository | active | 现有 3 个测试 (DanmakuFilter) |
| P5 | LocalFilePlugin 接入播放器 | active | `lib/core/plugin/` 4 files exist, not wired |

## Open assumptions (announced defaults)
| assumption | adopted default | rationale | reversible? |
|------------|----------------|-----------|-------------|
| P0 修复策略 | 逐文件修复，不重构整体结构 | 最小改动原则 | yes |
| P3 解耦策略 | 用 Get.find<CoreInterface>() 替换 adapter import，与现有 Plan C 模式一致 | 全项目已用同一模式 | yes |
| P4 测试模式 | 每个 Repository 3 个测试 (happy/error/edge)，与 DanmakuFilter 模式一致 | 延续现有测试风格 | yes |
| P5 接入方式 | 在 BiliBridge.register() 中初始化 PluginRegistry，LocalFilePlugin 提供 openFile() 给播放器 | 最小可工作路径 | yes |

## Findings (cited — path:lines)
- 6 compile errors at: `lib/adapters/bilibili/pages/fav/topic/controller.dart:48,52`, `view.dart:87`, `live_dm_block/controller.dart:114`, `popular_series/controller.dart:60`, `video/introduction/pgc/controller.dart:124`
- 13 adapter imports in common/: `gallery_viewer.dart`(3), `reply_menu_helper.dart`(2), `pendant_avatar.dart`(2), `image_grid_view.dart`(2), `dynamic_card.dart`(1), `appbar.dart`(1), `dyn_menu_helper.dart`(1), `avatars.dart`(1)
- 24 repository interfaces in `lib/core/repository/`: Audio, Auth, Black, Danmaku, DanmakuFilter, Download, Dynamics, Fan, Fav, Follow, Im, Live, Match, Member, Msg, Music, Pgc, Reply, Search, Space, SponsorBlock, User, Validate, Video
- Existing test: `test/repository/danmaku_filter_repository_test.dart` (3 tests, mockito)
- Plugin files: `lib/core/plugin/plugin.dart`(3 methods), `plugin_registry.dart`, `data_source.dart`, `local_file_plugin.dart`
- `flutter analyze` returns 0 errors on HEAD commit (verified 2026-07-24, 419 info/warnings pre-existing); working tree has 6 errors from uncommitted changes

## Decisions (with rationale)
1. **P3 包含**: 用户选择包含 common/ 解耦，达到 core 层纯净
2. **P4 全覆盖**: 用户选择 24 个 Repository 全部覆盖，每个 3 个测试 = 72 个测试
3. **P5 LocalFilePlugin 接入**: 用户选择最小可工作路径
4. **提交策略**: P0+P1 合并提交，P2-P5 各独立提交

## Scope IN
- P0: 修复 5 个文件中的 6 个 compile error
- P1: 提交所有工作区变更（代码 + .omo 文件）
- P2: 更新 `.omo/README.md`
- P3: 解耦 common/ 中 8 个文件的 13 个 adapter import
- P4: 为全部 24 个 Repository 添加单元测试（每 Repo 3 个）
- P5: PluginRegistry 在 BiliBridge 初始化 + LocalFilePlugin.openFile() 接入播放

## Scope OUT (Must NOT have)
- ❌ 不改播放器内部核心逻辑
- ❌ 不改 Repository 接口签名
- ❌ 不新增适配器（仍保持 bilibili 唯一适配器）
- ❌ 不做插件市场/动态加载/热插拔
- ❌ 不做插件管理 UI
- ❌ 不改现有业务逻辑
- ❌ 不改 Flutter SDK patches 或构建脚本

## Open questions
- [已关闭] P3 common/ 解耦是否包含 → 用户确认「包含」
- [已关闭] P4 测试覆盖面 → 用户确认「全部 24 个 Repository」
- [已关闭] P5 插件集成范围 → 用户确认「LocalFilePlugin 接入播放」
- [已关闭] 提交策略 → 用户确认「P0+P1 合并提交，其余独立」

## Approval gate
status: awaiting-approval
<!-- When exploration is exhausted and unknowns are answered, set status: awaiting-approval. -->
<!-- That durable record is the loop guard: on a later turn read it and resume at the gate instead of re-running exploration. -->
