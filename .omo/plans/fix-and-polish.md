# fix-and-polish - Work Plan

## TL;DR (For humans)

**What you'll get:** 一个可编译、0 error 的项目——修复 6 个编译错误，提交所有待处理工作，更新项目追踪文档，完全解耦 common/ 共享组件与适配器的依赖，为全部 24 个仓库接口建立单元测试覆盖，并将插件系统真正接入播放器。

**Why this approach:** 分两波执行——P0+P1 先把项目修复到可编译+可提交状态（这是所有后续工作的基础），然后 P2-P5 四个独立任务并行执行，互不阻塞，最大化执行效率。

**What it will NOT do:** ❌ 不改播放器核心逻辑 / Repository 接口签名 / 现有业务逻辑；❌ 不做插件市场的完整 UI；❌ 不改构建脚本或 Flutter SDK 补丁。

**Effort:** Large — 6 个 phase，~200+ 文件变更
**Risk:** Low-Medium — P0 修复是机械化的（已知 error + 已知修复），P4 测试框架已有 mocks 模式，P5 集成面窄
**Decisions to sanity-check:** common/ 解耦是否值得（已确认「是」）；24 个全覆测试 vs 代表性抽样（已确认「全覆」）

Your next move: execute. Full execution detail follows below.

---

> TL;DR (machine): P0+P1→(P2∥P3∥P4∥P5). Fix 6 errors, commit ~200 files, update OMO, decouple 13 adapter imports in common/, 72 tests (24 repos ×3), wire LocalFilePlugin → player. ~6-10h, final `flutter analyze` 0 errors.

## Scope
### Must have
- P0: 修复 5 个文件中的 6-7 个 compile error（`fav/topic/controller.dart` ×2, `fav/topic/view.dart`, `live_dm_block/controller.dart`, `popular_series/controller.dart`, `video/introduction/pgc/controller.dart`, `video/reply/controller.dart`）
- P1: 提交所有工作区变更（代码 + .omo 文件），与 P0 合并为一个 commit
- P2: 更新 `.omo/README.md` — SPES-009 标记完成
- P3: 解耦 `lib/common/` 中 8 个文件的 13 个 adapter import，用 `Get.find<CoreInterface>()` 替代
- P4: 为全部 24 个 Repository 各写 3 个测试（happy/error/edge），延续现有 mockito 模式
- P5: PluginRegistry 在 BiliBridge.register() 中初始化 + LocalFilePlugin.openFile() 接入播放器

### Must NOT have (guardrails, anti-slop, scope boundaries)
- ❌ 不改播放器内部核心逻辑（PlayerFactory, PlaybackReporter, PlayerController）
- ❌ 不改 Repository 接口签名或方法定义
- ❌ 不改现有业务逻辑（controller/view 中的 UI 逻辑）
- ❌ 不新增适配器（仍保持 bilibili 唯一适配器）
- ❌ 不做插件市场/动态加载/热插拔/插件管理 UI
- ❌ 不做集成测试或 widget 测试（仅单元测试）
- ❌ 不改 Flutter SDK patches、构建脚本或 CI 配置

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- Test decision: tests-after — 现有测试 (3 个) 全程保持通过，P4 新增测试用 mockito
- Evidence: `.omo/evidence/fix-and-polish/task-<N>.md`

## Execution strategy
### Parallel execution waves

**Wave 1**: P0 (fix errors) — 串行，必须首批完成
**Wave 2**: P1 (commit P0+P1) — 串行，依赖 P0
**Wave 3**: P2, P3, P4, P5 — 全部并行执行，互不依赖

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| P0 (fix errors) | — | P1 | — |
| P1 (commit) | P0 | P2,P3,P4,P5 | — |
| P2 (update OMO) | P1 | — | P3,P4,P5 |
| P3 (common decouple) | P1 | — | P2,P4,P5 |
| P4 (unit tests) | P1 | — | P2,P3,P5 |
| P5 (plugin integration) | P1 | — | P2,P3,P4 |

## Todos
> Implementation + Test = ONE todo. Never separate.
<!-- APPEND TASK BATCHES BELOW THIS LINE WITH edit/apply_patch - never rewrite the headers above. -->

### Wave 1 — Fix compile errors

- [x] 1. 修复 6-7 个 compile error（5 个文件）
  What to do / Must NOT do:
  - 修复以下文件中的 compile error：
    1. `lib/adapters/bilibili/pages/fav/topic/controller.dart:48` — `conflicting_method_and_field`: 将 `onDelete` 方法重命名为 `onRemoveTopic`，避免与 `GetLifeCycleBase.onDelete` 字段冲突
    2. `lib/adapters/bilibili/pages/fav/topic/controller.dart:52` — `undefined_identifier`: `index` 未定义，需要从 `onDelete` 方法签名中恢复 `index` 参数
    3. `lib/adapters/bilibili/pages/fav/topic/view.dart:87` — `undefined_method`: view 仍调用了旧的 `onRemove`，但 controller 改成了 `onDelete`。需要根据 controller 的实际方法名同步
    4. `lib/adapters/bilibili/pages/live_dm_block/controller.dart:114` — `undefined_identifier`: `uid` 未定义。需要从方法签名中恢复或添加 `uid` 参数
    5. `lib/adapters/bilibili/pages/popular_series/controller.dart:60` — `unchecked_use_of_nullable_value`: `response?.isNullOrEmpty` 需要使用 `?.` 调用
    6. `lib/adapters/bilibili/pages/video/introduction/pgc/controller.dart:124` — `undefined_identifier`: `HttpString` 未定义。可能是在重构中丢失的 import 或变量，需要检查上下文修复
    7. `lib/adapters/bilibili/pages/video/reply/controller.dart:52` — `Expected a method, getter, setter or operator declaration`: 代码片段不完整，需要修复语法
  - ❌ 不改任何业务逻辑
  - ❌ 不改方法签名（除非是恢复被错误修改的参数）
  - ❌ 不改其他文件（除非是 controller/view 签名不匹配的联动修复）
  - 修复后运行 `flutter analyze` 确认 0 errors
  Parallelization: Wave 1 | Blocked by: — | Blocks: P1
  References: 
  - `lib/adapters/bilibili/pages/fav/topic/controller.dart:48,52`
  - `lib/adapters/bilibili/pages/fav/topic/view.dart:87`
  - `lib/adapters/bilibili/pages/live_dm_block/controller.dart:114`
  - `lib/adapters/bilibili/pages/popular_series/controller.dart:60`
  - `lib/adapters/bilibili/pages/video/introduction/pgc/controller.dart:124`
  - `lib/adapters/bilibili/pages/video/reply/controller.dart:52`
  Acceptance criteria (agent-executable):
  - `flutter analyze` — 0 errors
  - `flutter test` — 3/3 pass（不应破坏现有测试）
  QA scenarios:
  - Happy: `flutter analyze` 输出 "0 errors"；`flutter test` 3/3 pass
  - Failure: 仍有 error → 读取具体错误继续修复
  Evidence: `.omo/evidence/fix-and-polish/task-p0.md`
  Commit: N（与 P1 合并提交）

- [x] 2. 提交工作区（与 P0 合并为一个 commit）
  What to do / Must NOT do:
  - 在 P0 修复完成并验证通过后执行
  - 执行 `git add` 包含所有修改/删除/新增的文件
  - 包含：`lib/` 所有已修改文件 + `.omo/` 新文件 + 删除 4 个 adapter 模型文件
  - 不包含：`.omo/run-continuation/` 中大量临时会话文件（不追踪它们，保持 gitignore 模式）
  - commit message: `fix(spes): fix compile errors, common decouple infra, plugin system — P0-P5 batch`
  - ❌ 不要在 P0 验证通过前提交
  Parallelization: Wave 2 | Blocked by: P0 | Blocks: P2,P3,P4,P5
  References: `git status --short`（~200+ 已修改文件）
  Acceptance criteria (agent-executable):
  - `git status --short` 显示 0 个未提交变更（仅 `.omo/run-continuation/` 未追踪文件允许存在）
  - `flutter analyze` — 0 errors（在提交时验证）
  QA scenarios:
  - Happy: commit 成功，push 可选
  - Failure: commit 被 hooks 拒绝 → 修复 hook 提示的问题
  Evidence: `.omo/evidence/fix-and-polish/task-p1.md`
  Commit: Y | `fix(spes): fix compile errors, common decouple infra, plugin system — P0-P5 batch`

### Wave 3 — 4 个并行任务

- [x] 3. 更新 OMO README — SPES-009 完成标记
  What to do / Must NOT do:
  - 修改 `.omo/README.md`：
    - 将 SPES-009 从「执行中」移到「已完成」
    - 添加 SPES-009 验收记录（flutter analyze 0 errors, 所有 grep 断言通过等）
  - ❌ 不改任何代码文件
  - ❌ 不改其他文档
  Parallelization: Wave 3 | Blocked by: P1 | Blocks: —
  References: `.omo/README.md:14-18`（当前 SPES-009 仍在执行中列表）
  Acceptance criteria (agent-executable):
  - `Select-String "009" .omo/README.md` — 在「已完成」表中出现，不在「执行中」表中
  QA scenarios:
  - Happy: 文档更新正确
  - Failure: 格式错误或遗漏
  Evidence: `.omo/evidence/fix-and-polish/task-p2.md`
  Commit: Y | `docs(omo): mark SPES-009 as completed`

- [x] 4. 解耦 common/ 的 13 个 adapter import
  What to do / Must NOT do:
  - 修改以下 8 个文件，将 `import 'package:skf/adapters/bilibili/...'` 替换为 `Get.find<CoreInterface>()` 模式：
    1. `lib/common/widgets/image_viewer/gallery_viewer.dart` — 3 个 adapter import
    2. `lib/common/widgets/context_menu/reply_menu_helper.dart` — 2 个 adapter import
    3. `lib/common/widgets/pendant_avatar.dart` — 2 个 adapter import
    4. `lib/common/widgets/image_grid/image_grid_view.dart` — 2 个 adapter import
    5. `lib/common/skeleton/dynamic_card.dart` — 1 个 adapter import
    6. `lib/common/widgets/appbar/appbar.dart` — 1 个 adapter import
    7. `lib/common/widgets/context_menu/dyn_menu_helper.dart` — 1 个 adapter import
    8. `lib/common/widgets/avatars.dart` — 1 个 adapter import
  - 替换策略：分析每个 import 使用的具体类型/函数，找到对应的 core interface，用 `Get.find<Interface>()` 替代
  - 对于无法直接映射到 Repository 的情况，考虑在 core/ 中添加适配器接口或在 bridge 中注册
  - ❌ 不改业务逻辑
  - ❌ 不改 core/ 中的接口定义
  - ❌ 不改 adapter 端的实现
  - 如果某个 import 对应的是纯工具函数而非接口，则在 core/ 中创建抽象接口并在 bridge 注册
  Parallelization: Wave 3 | Blocked by: P1 | Blocks: —
  References: 
  - `grep "import.*adapters/bilibili" lib/common/ -r` — 13 matches in 8 files
  - 现有模式参考：`lib/common/widgets/stat/stat.dart`（已解耦的示例）
  - AGENTS.md Architecture section for core/adapter separation pattern
  Acceptance criteria (agent-executable):
  - `grep "import.*adapters/bilibili" lib/common/ -r` — 0 matches
  - `flutter analyze` — 0 errors
  QA scenarios:
  - Happy: common/ 中无 adapter import，compile 通过
  - Failure: 仍有残留 import，或引入新 error
  Evidence: `.omo/evidence/fix-and-polish/task-p3.md`
  Commit: Y | `refactor(common): decouple 13 adapter imports from common/ widgets`

- [x] 5. 为全部 24 个 Repository 添加单元测试（72 个测试）
  What to do / Must NOT do:
  - 为以下 24 个 Repository 各写 3 个测试（happy/error/edge），延续 `danmaku_filter_repository_test.dart` 的 mockito 模式：
    Audio, Auth, Black, Danmaku, DanmakuFilter(已有3个), Download, Dynamics, Fan, Fav, Follow, Im, Live, Match, Member, Msg, Music, Pgc, Reply, Search, Space, SponsorBlock, User, Validate, Video
  - 每个测试文件结构：
    1. 使用 `mockito` + `@GenerateMocks([Bili*Repository])` 生成 mock
    2. 3 个测试：happy path（返回数据）、error path（抛出异常）、edge case（空数据/边界值）
    3. 使用 `test/repository/` 目录，文件名 `<name>_repository_test.dart`
  - 首先检查哪些 Bili*Repository 实现已存在（在 `lib/adapters/bilibili/repository/`）
  - 运行 `dart run build_runner build --delete-conflicting-outputs` 生成 mock 文件
  - ❌ 不超过每个 Repository 3 个测试
  - ❌ 不写 widget/integration 测试
  - ❌ 不改任何生产代码
  - ❌ 不改 build_runner 配置
  - ✅ 如果某个 Repository 的 Bili 实现不存在，跳过该 Repository 并记录
  Parallelization: Wave 3 | Blocked by: P1 | Blocks: —
  References:
  - `lib/core/repository/` — 24 interfaces
  - `lib/adapters/bilibili/repository/` — Bili* implementations
  - `test/repository/danmaku_filter_repository_test.dart` — 现有示例
  - `pubspec.yaml` — `mockito: ^5.7.0`, `build_runner` in dev_dependencies
  Acceptance criteria (agent-executable):
  - `flutter test` — 全部通过（至少 3 + 23×3 = 72 个测试通过）
  - `flutter analyze` — 0 errors（mock 文件可能产生 info，但不允许 error）
  QA scenarios:
  - Happy: 72 个测试全部通过
  - Failure: 测试失败或 mock 生成错误
  Evidence: `.omo/evidence/fix-and-polish/task-p4.md`
  Commit: Y | `test(spes): add unit tests for all 24 repository interfaces`

- [x] 6. LocalFilePlugin 接入播放器
  What to do / Must NOT do:
  - 修改 `lib/adapters/bilibili/bridge.dart`：
    - 在 `register()` 中添加 `Get.put(PluginRegistry())` 或 `Get.lazyPut<PluginRegistry>(PluginRegistry.new)`
    - 注册 LocalFilePlugin 到 PluginRegistry
  - 修改 `lib/adapters/bilibili/player/bili_player_factory.dart` 或相关播放器入口：
    - 添加一个「打开本地文件」的途径，使用 LocalFilePlugin 的 openFile()
    - 支持 FilePicker 选择文件后通过 MediaSource 创建播放器
  - 如果需要，在 `lib/core/player/` 中添加 `local_file_data_source.dart` 作为 DataSource 的实现
  - ❌ 不改现有播放器核心逻辑（PlayerController、PlayerFactory 接口）
  - ❌ 不做插件选择 UI
  - ❌ 不做插件热加载
  - ❌ 不改任何非插件相关的适配器代码
  Parallelization: Wave 3 | Blocked by: P1 | Blocks: —
  References:
  - `lib/core/plugin/plugin.dart` — Plugin 接口（3 方法）
  - `lib/core/plugin/plugin_registry.dart` — PluginRegistry
  - `lib/core/plugin/local_file_plugin.dart` — LocalFilePlugin（FilePicker + fromPath）
  - `lib/core/player/player_factory.dart` — PlayerFactory 抽象
  - `lib/core/player/media_source.dart` — MediaSource 模型
  - `lib/adapters/bilibili/bridge.dart` — BiliBridge.register()
  - `lib/adapters/bilibili/player/bili_player_factory.dart` — B站 PlayerFactory 实现
  Acceptance criteria (agent-executable):
  - `flutter analyze` — 0 errors
  - PluginRegistry 在 BiliBridge.register() 中被初始化
  - LocalFilePlugin 可以通过 PluginRegistry 获取
  QA scenarios:
  - Happy: PluginRegistry 注册成功，LocalFilePlugin 可调用 openFile()
  - Failure: 编译错误或运行时注册失败
  Evidence: `.omo/evidence/fix-and-polish/task-p5.md`
  Commit: Y | `feat(plugin): wire PluginRegistry into BiliBridge + LocalFilePlugin player integration`

## Final verification wave
> Runs in parallel after ALL todos. ALL must APPROVE. Surface results and wait for the user's explicit okay before declaring complete.
- [x] F1. Plan compliance audit — 所有 6 个 phase 按计划完成，范围未超出
- [x] F2. Code quality — `flutter analyze` 0 errors；`flutter test` 全部通过
- [x] F3. Real manual QA — 引用各 task 的 QA 标准逐项确认
- [x] F4. Scope fidelity — 无范围蔓延，无未授权的修改

## Commit strategy
- P0+P1: `fix(spes): fix compile errors, common decouple infra, plugin system — P0-P5 batch`
- P2: `docs(omo): mark SPES-009 as completed`
- P3: `refactor(common): decouple 13 adapter imports from common/ widgets`
- P4: `test(spes): add unit tests for all 24 repository interfaces`
- P5: `feat(plugin): wire PluginRegistry into BiliBridge + LocalFilePlugin player integration`

## Success criteria
- `flutter analyze` — **0 errors**（最终验证）
- `flutter test` — **全部通过**（至少 72+ 个测试）
- `grep "import.*adapters/bilibili" lib/common/ -r` — **0 matches**（P3）
- `.omo/README.md` 中 SPES-009 状态为「已完成」（P2）
- PluginRegistry 在 Bridge 中初始化，LocalFilePlugin 可接入播放（P5）
