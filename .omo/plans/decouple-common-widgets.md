# decouple-common-widgets - Work Plan

## TL;DR (For humans)

**What you'll get:** 解决 `lib/common/` 里 16 个对 B站 适配器的直接依赖。核心 UI 类型（图像类型、徽章样式、统计数据、图片源）搬到 `lib/core/models/ui/`；通用主题扩展搬到 `lib/utils/`；两个 `part of` 文件提取为标准独立文件；垂直标签页不再硬编码 `Get.find<MainController>()`。

**Why this approach:** 70% 的耦合是无争议的可搬类型——零 B站 依赖，纯搬文件改路径。剩下 30%（PageUtils 等）本质是 B站 功能，强行抽象得不偿失。先拿下低垂果实，让 common/ 的架构边界清晰。

**What it will NOT do:** 不改 pendant_avatar 的 B站 专属 VIP 徽章；不改 PageUtils/BiliImageUtils；不改 Repository 接口签名（不完整依赖反转是独立问题）。

**Effort:** Medium — 7 tasks across 3 waves, ~60 file changes
**Risk:** Low-Medium — C4（vertical_tabs 注入化）是 2404 行 Flutter fork 里的手术，需谨慎；C1-C3 都是纯搬文件
**Decisions to sanity-check:** SourceType 不重命名（按原路径区分）；ColorSchemeExt 仅搬 `isDark`/`isLight`/`freeColor`；`part of` 提取后文件仍为 B站 耦合

Your next move: approve the plan. Full execution detail follows below.

---

> TL;DR (machine): 7 todos, 3 waves. Move 4 UI enums + theme ext to core, extract 2 part-of files, injectify vertical_tabs. ~60 file changes, flutter analyze 0 errors. Medium effort, low-medium risk.

## Scope
### Must have
- **C1**: 搬 4 组 UI 枚举（ImageType, PBadgeType/PBadgeSize, SourceType/SourceModel, StatType）从 `adapters/bilibili/models/common/` 到 `lib/core/models/ui/`
  - 创建 `lib/core/models/ui/` 目录
  - 每个类型创建新的核心文件（内容不变）
  - 更新所有 lib/common/ 和 lib/adapters/bilibili/ 中引用这些类型的 import 路径
- **C2**: 搬 ColorSchemeExt 的 `isDark`/`isLight`/`freeColor` 属性从 `adapters/bilibili/utils/extension/theme_ext.dart` 到新的 `lib/utils/theme_ext.dart`
  - `vipColor`/`blue`/`btnColor` 保留在原位（依赖 BiliColors）
  - 更新 3 个 common/ 文件的 import（badge.dart, export_import.dart, floating_navigation_bar.dart）
- **C3**: 提取 2 个 part-of 文件从 `part of` 关系为独立文件
  - `dyn_menu_helper.dart`：从 `content_panel.dart` 提取
  - `reply_menu_helper.dart`：从 `reply_item_grpc.dart` 提取
  - 仅做文件结构提取，不改函数体
- **C4**: vertical_tabs.dart 中替换 `Get.find<MainController>()` 为回调参数
  - 删除残留的 `controller.dart` import
- **最终验证**: `flutter analyze` 0 errors

### Must NOT have (guardrails, anti-slop, scope boundaries)
- ❌ 不碰 `avatar_badge_type.dart` (BadgeType with vip/person/institution) — 延期
- ❌ 不碰 PageUtils / BiliImageUtils — B站 功能留在 adapter
- ❌ 不碰 Repository 接口签名 — 独立项目
- ❌ 不碰 widget/integration 测试
- ❌ C3 不改函数体 — 仅 `part of` → 独立文件
- ❌ C2 不搬 `vipColor`/`blue`/`btnColor` — 依赖 BiliColors

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- Test decision: tests-after — existing mockito infra reused
- Per-task: `lsp_diagnostics` on changed files + `flutter analyze` (cumulative after wave)
- Evidence: .omo/evidence/decouple-common-widgets/task-<N>/

## Execution strategy
### Parallel execution waves
- **Wave 1** (4 parallel — C1a-d): 搬 4 组 UI 枚举到 core（无文件重叠）
- **Wave 2** (2 parallel — C2 + C3): 主题扩展 + part-of 提取（无重叠；需 Wave 1 完成后）
- **Wave 3** (1 — C4): vertical_tabs 注入化（需 Wave 2 完成后）

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| 1 (C1a: ImageType) | — | — | 2, 3, 4 |
| 2 (C1b: PBadgeType) | — | — | 1, 3, 4 |
| 3 (C1c: SourceType) | — | — | 1, 2, 4 |
| 4 (C1d: StatType) | — | — | 1, 2, 3 |
| 5 (C2: theme_ext) | 2 (badge.dart 同时被 C1b 和 C2 触碰) | — | 6 |
| 6 (C3: part-of) | — | — | 5 |
| 7 (C4: vertical_tabs) | — | — | — |

## Todos
> Implementation + Test = ONE todo. Never separate.
<!-- APPEND TASK BATCHES BELOW THIS LINE WITH edit/apply_patch - never rewrite the headers above. -->

### Wave 1 — UI Enum Migration (parallel batch)

- [x] 1. C1a: Move ImageType enum to lib/core/models/ui/
  What to do / Must NOT do:
  - Create `lib/core/models/ui/image_type.dart` with exact same `ImageType` enum content
  - Update ~40 import paths: `package:skf/adapters/bilibili/models/common/image_type.dart` → `package:skf/core/models/ui/image_type.dart`
  - Files to update: lib/common/widgets/image/network_img_layer.dart, lib/common/widgets/pendant_avatar.dart, lib/common/widgets/flutter/text_field/controller.dart + ~37 files in lib/adapters/bilibili/ that import image_type.dart
  - Do NOT rename enum values; do NOT change any logic
  - Do NOT touch `avatar_badge_type.dart`
  - After move, delete old file
  Parallelization: Wave 1 | Blocked by: — | Blocks: —
  References: explorer bg_723b3160 — ImageType (avatar/emote/def) has zero B站 deps; grep for `image_type.dart` to find all consumers
  Acceptance criteria (agent-executable):
  - `grep -r "package:skf/adapters/bilibili/models/common/image_type" lib/` — 0 matches
  - `grep -r "package:skf/core/models/ui/image_type" lib/` — >30 matches
  - `flutter analyze` — 0 errors (for this file alone)
  QA scenarios: Happy: verify import count >30; Failure: if grep still finds old path, fix remaining files
  Commit: Y | refactor(core): move ImageType enum to lib/core/models/ui/

- [x] 2. C1b: Move PBadgeType/PBadgeSize enums to lib/core/models/ui/
  What to do / Must NOT do:
  - Create `lib/core/models/ui/badge_type.dart` with exact same `PBadgeType` and `PBadgeSize` enum content
  - Update ~5 import paths across: lib/common/widgets/badge.dart + lib/adapters/bilibili/ files
  - Do NOT rename enum values; do NOT change `free`/`shop` values
  - Do NOT touch `avatar_badge_type.dart`
  - After move, delete old file
  Parallelization: Wave 1 | Blocked by: — | Blocks: 5 (badge.dart also touched by C2)
  References: explorer bg_723b3160 — PBadgeType/PBadgeSize has zero B站 deps
  Acceptance criteria (agent-executable):
  - `grep -r "package:skf/adapters/bilibili/models/common/badge_type" lib/` — 0 matches
  - `grep -r "package:skf/core/models/ui/badge_type" lib/` — >3 matches
  - `flutter analyze` — 0 errors
  QA scenarios: Happy: verify import count >3; Failure: grep finds old path; fix
  Commit: Y | refactor(core): move PBadgeType/PBadgeSize enums to lib/core/models/ui/

- [x] 3. C1c: Move SourceType/SourceModel to lib/core/models/ui/
  What to do / Must NOT do:
  - Create `lib/core/models/ui/image_preview_type.dart` with exact same `SourceType`, `SourceModel` content
  - Update ~16 import paths: lib/common/widgets/image_viewer/gallery_viewer.dart, lib/common/widgets/image_grid/image_grid_view.dart + ~14 files in lib/adapters/bilibili/
  - Do NOT rename enum values (note: there is a DIFFERENT `SourceType` in `video/source_type.dart` — leave that one alone, different import path)
  - After move, delete old file
  Parallelization: Wave 1 | Blocked by: — | Blocks: —
  References: explorer bg_723b3160 — SourceType/SourceModel has zero B站 deps; confirm that `video/source_type.dart` is a separate type
  Acceptance criteria (agent-executable):
  - `grep -r "package:skf/adapters/bilibili/models/common/image_preview_type" lib/` — 0 matches
  - `grep -r "package:skf/core/models/ui/image_preview_type" lib/` — >12 matches
  - `flutter analyze` — 0 errors
  QA scenarios: Happy: import paths updated correctly; Failure: flutter analyze > 0 errors; verify video/source_type.dart untouched
  Commit: Y | refactor(core): move SourceType/SourceModel to lib/core/models/ui/

- [x] 4. C1d: Move StatType enum to lib/core/models/ui/
  What to do / Must NOT do:
  - Create `lib/core/models/ui/stat_type.dart` with exact same `StatType` enum content (including Chinese labels — future i18n)
  - Update ~3 import paths: lib/common/widgets/stat/stat.dart + lib/adapters/bilibili/ files
  - Do NOT change labels or rename values
  - After move, delete old file
  Parallelization: Wave 1 | Blocked by: — | Blocks: —
  References: explorer bg_723b3160 — StatType has zero B站 deps; labels are data not code
  Acceptance criteria (agent-executable):
  - `grep -r "package:skf/adapters/bilibili/models/common/stat_type" lib/` — 0 matches
  - `grep -r "package:skf/core/models/ui/stat_type" lib/` — >2 matches
  - `flutter analyze` — 0 errors
  QA scenarios: Happy: stat.dart shows correct labels; Failure: import path still old
  Commit: Y | refactor(core): move StatType enum to lib/core/models/ui/

### Wave 2 — Theme Extension + Part-of Extraction

- [x] 5. C2: Create core ColorSchemeExt in lib/utils/; update common/ imports
  What to do / Must NOT do:
  - Create `lib/utils/theme_ext.dart` with `ColorSchemeExt` extension containing only: `isDark`, `isLight`, `freeColor` (the 3 properties WITHOUT BiliColors dependency)
  - In adapter's `lib/adapters/bilibili/utils/extension/theme_ext.dart`, REMOVE `isDark`/`isLight`/`freeColor`, keep only `vipColor`/`blue`/`btnColor` (keep old file, just trim)
  - Update 3 common/ imports in: lib/common/widgets/badge.dart, lib/common/widgets/dialog/export_import.dart, lib/common/widgets/floating_navigation_bar.dart
    - badge.dart: change `package:skf/adapters/bilibili/utils/extension/theme_ext.dart` → `package:skf/utils/theme_ext.dart`
    - export_import.dart and floating_navigation_bar.dart: same change
  - Do NOT move `vipColor`/`blue`/`btnColor` — they depend on BiliColors
  - Do NOT break adapter files that import theme_ext.dart for BiliColors properties
  Parallelization: Wave 2 | Blocked by: 2 (badge.dart touched by both C1b and C2) | Blocks: —
  References: explorer bg_4d745e4f — 3 common/ files use theme_ext; theme_ext.dart:22-27 shows isDark/isLight/freeColor have no BiliColors dep
  Acceptance criteria (agent-executable):
  - `grep -r "package:skf/adapters/bilibili/utils/extension/theme_ext" lib/common/` — 0 matches
  - `grep -r "package:skf/utils/theme_ext" lib/common/` — 3 matches (badge.dart, export_import.dart, floating_navigation_bar.dart)
  - `grep "import.*theme_ext" lib/adapters/bilibili/utils/extension/theme_ext.dart` — confirms adapter still exports vipColor/blue/btnColor
  - `flutter analyze` — 0 errors
  QA scenarios: Happy: 3 common/ files updated, adapter extension still works; Failure: badge.dart still uses old import, or flutter analyze fails
  Commit: Y | refactor(core): move generic ColorSchemeExt properties to lib/utils/

- [x] 6. C3: Extract 2 part-of files into standalone files
  What to do / Must NOT do:
  - Extract `lib/common/widgets/context_menu/dyn_menu_helper.dart` from `part of 'package:skf/adapters/bilibili/pages/dynamics/widgets/content_panel.dart'`
    - Remove `part of` directive, add explicit imports for used types (NetworkImgLayer, ModuleDynamicModel, etc.)
  - Extract `lib/common/widgets/context_menu/reply_menu_helper.dart` from `part of 'package:skf/adapters/bilibili/pages/video/reply/widgets/reply_item_grpc.dart'`
    - Remove `part of` directive, add explicit imports for used types (Emote, ReplyGrpc, etc.)
  - Update parent files to remove `part:` declarations
  - Do NOT change function bodies or logic
  - Do NOT remove B站 imports from these files — they remain B站-coupled adapter helper files
  - After extraction, files are standalone but still adapter-coupled (part of "acceptable technical debt" stance)
  - Explicit imports needed for each extracted file (list all symbols used — ~15+ imports per file): NetworkImgLayer, SelectionText, openUrlMenuBuilder, Get, SmartDialog, showConfirmDialog, GStorage, ReplyGrpc, Emoji/Emote, ModuleDynamicModel, Colors, ContextMenuButtonItem, AdaptiveTextSelectionToolbar, Element, RegExp, SettingBoxKey
  Parallelization: Wave 2 | Blocked by: — | Blocks: —
  References: explorer bg_4d745e4f — both files are `part of` adapter files; types used include ModuleDynamicModel, Emoji, ReplyGrpc, GStorage, NetworkImgLayer
  Acceptance criteria (agent-executable):
  - `grep "part of" lib/common/widgets/context_menu/dyn_menu_helper.dart` — 0 matches
  - `grep "part of" lib/common/widgets/context_menu/reply_menu_helper.dart` — 0 matches
  - `grep "part.*context_menu" lib/adapters/bilibili/pages/dynamics/widgets/content_panel.dart` — 0 matches
  - `grep "part.*context_menu" lib/adapters/bilibili/pages/video/reply/widgets/reply_item_grpc.dart` — 0 matches
  - `flutter analyze` — 0 errors
  QA scenarios: Happy: files compile as standalone; Failure: part of still present or flutter analyze fails
  Commit: Y | refactor(common): extract part-of context_menu helpers to standalone files

### Wave 3 — Vertical Tabs Decoupling

- [x] 7. C4: Replace Get.find<MainController>() in vertical_tabs.dart with callback parameter
  What to do / Must NOT do:
  - In `lib/common/widgets/flutter/vertical_tabs.dart`, replace `final _mainCtr = Get.find<MainController>();` with a constructor/callback parameter for bottom nav state
  - Remove the import `package:skf/adapters/bilibili/pages/main/controller.dart`
  - Update all callers that use `VerticalTabController` — only 1 caller: `lib/adapters/bilibili/pages/rank/view.dart` — pass the callback there
  - Do NOT change any other logic in vertical_tabs.dart (2404-line Flutter SDK fork — minimal surgery)
  - Do NOT add new features or change scroll behavior
  Parallelization: Wave 3 | Blocked by: 5, 6 (but no actual code dependency) | Blocks: —
  References: explorer bg_4d745e4f — vertical_tabs.dart:1631 has `Get.find<MainController>()`; line 10 imports controller.dart; file is 2404 lines of Flutter SDK fork code
  Acceptance criteria (agent-executable):
  - `grep "MainController" lib/common/widgets/flutter/vertical_tabs.dart` — 0 matches
  - `grep "package:skf/adapters/bilibili/pages/main/controller" lib/common/widgets/flutter/vertical_tabs.dart` — 0 matches
  - `flutter analyze` — 0 errors
  - All callers of VerticalTabController updated correctly
  QA scenarios: Happy: vertical_tabs no longer imports B站 code; Failure: MainController still referenced or flutter analyze fails
  Commit: Y | refactor(common): decouple vertical_tabs from MainController via callback

## Final verification wave
> Runs in parallel after ALL todos. ALL must APPROVE. Surface results and wait for the user's explicit okay before declaring complete.
- [x] F1. Plan compliance audit — verify all 7 tasks completed per scope
- [x] F2. Code quality review — `flutter analyze` 0 errors; `grep` confirms no residual old imports in lib/common/
- [x] F3. Real manual QA — grep all 23 original imports from lib/common/ → only the 7 approved adapter imports remain (pendant_avatar's avatar_badge_type + page_utils, gallery_viewer's page_utils + bili_image_utils + fullscreen, image_grid_view's bili_image_utils + page_utils)
- [x] F4. Scope fidelity — no scope creep: verify no files outside scope were modified

## Commit strategy
- 每个 C1 task 独立 commit: `refactor(core): move <Type> to lib/core/models/ui/`
- C2 独立 commit: `refactor(utils): extract generic ColorSchemeExt to lib/utils/`
- C3 独立 commit: `refactor(common): extract part-of context_menu helpers`
- C4 独立 commit: `refactor(common): decouple vertical_tabs from MainController`

## Success criteria
### Import audit (21 total → 7 removed + 14 remain)

**被移除的 7 个导入**（C1-C4 覆盖）:
- `image_type.dart` — network_img_layer.dart, pendant_avatar.dart, text_field/controller.dart (3 files)
- `badge_type.dart` — badge.dart (1 file)
- `image_preview_type.dart` — gallery_viewer.dart, image_grid_view.dart (2 files)
- `stat_type.dart` — stat.dart (1 file)
- `theme_ext.dart` — badge.dart, export_import.dart, floating_navigation_bar.dart (3 files, counted above)
- `main/controller.dart` — vertical_tabs.dart (1 file)
- 2 `part of` directives — context_menu/ (2 files)

**保留的 14 个导入**（公认 B站 耦合，留在 adapter）:
- `models/model_owner.dart` — avatars.dart (1)
- `models/common/badge_type.dart` — badge.dart's `free`/`shop` values via PBadgeType? ✅ (moved to core)
- `models/common/avatar_badge_type.dart` — pendant_avatar.dart (1)
- `models/common/stat_type.dart` — stat.dart ✅ (moved to core)
- `models/common/image_type.dart` — network_img_layer.dart ✅ (moved to core)
- `models/common/image_preview_type.dart` — gallery_viewer.dart ✅ (moved to core)
- `utils/extension/theme_ext.dart` — badge.dart, export_import.dart ✅ (partial — isDark/isLight/freeColor moved)
- `utils/global_data.dart` — skeleton/dynamic_card.dart (1)
- `utils/page_utils.dart` — pendant_avatar.dart, gallery_viewer.dart, image_grid_view.dart (3)
- `utils/bili_image_utils.dart` — gallery_viewer.dart, image_grid_view.dart (2)
- `plugin/pl_player/utils/fullscreen.dart` — gallery_viewer.dart (1)
- `pages/common/multi_select/base.dart` — appbar/appbar.dart (1)
- `pages/dynamics/widgets/content_panel.dart` — part-of extraction (0 after C3)
- `pages/video/reply/widgets/reply_item_grpc.dart` — part-of extraction (0 after C3)
- `pages/main/controller.dart` — vertical_tabs.dart (0 after C4)

### Verification commands
- `flutter analyze` — 0 errors (pre-existing info-level warnings tolerated)
- `grep "part of.*content_panel\|part of.*reply_item_grpc" lib/common/` — 0 matches
- `grep "Get.find<MainController>" lib/common/widgets/flutter/vertical_tabs.dart` — 0 matches
- `grep "package:skf/main.dart" lib/common/` — 0 matches (flag for gallery_viewer.dart main.dart import)
