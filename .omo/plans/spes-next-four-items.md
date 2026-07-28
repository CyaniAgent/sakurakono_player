# spes-next-four-items - Work Plan

## TL;DR (For humans)
<!-- Fill this LAST, after the detailed plan below is written, so it summarizes the REAL plan. -->

**What you'll get:** 四项重构按序交付：(A) 删除 B站 专属的 LoadingState 副本，统一用核心版本 — 169 个文件导入更新 + 22 个别名清理；(B) 建立单元测试体系 — mockito + build_runner，先给 1 个 Repository 写 3 个示范测试；(C) ValidateHttp 抽象为正式的 ValidateRepository 接口 + BiliValidateRepository 实现；(D) 定义插件架构 — Plugin 接口（≤3 方法）+ PluginRegistry + LocalFilePlugin 数据源演示。

**Why this approach:** A→(B∥C)→D 顺序：A 必须先做（消除类型二义性），B 和 C 可并行，D 依赖前面的全部基建。从小到大积累经验，每步可验证。

**What it will NOT do:** ❌ 不改 widget/integration 测试（仅 unit）；❌ 不做插件市场或动态加载；❌ 不改现有 B站 适配器代码（插件纯新增）；❌ 不改播放器内部实现（仅加插件接入点）。

**Effort:** Large (~200 文件变动)
**Risk:** Medium — A 的 169 文件导入更新 + 22 个别名清理需要原子操作，否则编译断裂
**Decisions to sanity-check:** Plugin 接口 ≤3 方法；测试只做 1 repo × 3 methods 示范；顺序 A→(B∥C)→D 而非严格串行

Your next move: approve the plan. Full execution detail follows below.

---

> TL;DR (machine): A→(B∥C)→D. LoadingState union (192 files). Unit tests (mockito, 1 repo × 3 methods). ValidateHttp→Repository. Plugin interface + LocalFilePlugin demo. ~200 file changes, flutter analyze 0 errors.

## Scope
### Must have
- **A: LoadingState统一** — Delete `lib/adapters/bilibili/http/loading_state.dart`; add `@immutable` to core `Success`/`Error`; update 169 import paths; rewrite 22 alias imports (`as bili_loading`); remove `_fromBili()` from 20 Bili*Repository files; simplify 2 page files' pattern-match conversion; `flutter analyze` → 0 errors
- **B: 单元测试** — `.gitignore`: replace `test*` with `test_results/`; `dart pub add --dev mockito`; write 1 test file (1 repo × 3 methods: happy + error + edge); verify `flutter test` passes
- **C: ValidateHttp抽象** — Create `ValidateRepository` interface in `lib/core/repository/` (2 methods); create `BiliValidateRepository` in `lib/adapters/bilibili/repository/`; register in Bridge; update `request_utils.dart` caller; delete old `validate.dart`; `flutter analyze` → 0 errors
- **D: 插件化架构** — Define `Plugin` interface (≤3 methods: `name`, `onRegister`, `provideDataSource?`); create `PluginRegistry` (core, wrapping GetX); implement `LocalFilePlugin` (data source demo: pick local video → provide URI); add player integration point; `flutter analyze` → 0 errors

### Must NOT have (guardrails, anti-slop, scope boundaries)
- ❌ No widget/integration tests (unit only)
- ❌ No plugin marketplace, dynamic loading, or hot-reload of plugins
- ❌ No changes to existing B站 adapter code (`lib/adapters/bilibili/`) for A/C/D — only delete/add files
- ❌ No changes to video player internals — only add plugin integration hook
- ❌ No `_fromBili()` dead code left after A — must be fully removed
- ❌ Plugin interface: strictly ≤3 abstract methods, no "future plugin" speculative design
- ❌ B's test scope: exactly 1 repo file × 3 methods — no more, no less

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- A: `flutter analyze` before → after, verify 0 errors both times
- B: `flutter test` must pass; `flutter analyze` on generated mocks must not introduce new errors
- C: `flutter analyze` 0 errors; grep confirms no `ValidateHttp` references remain
- D: `flutter analyze` 0 errors; compile check via `flutter build apk --debug` or Dart analysis

## Execution strategy
### Parallel execution waves
> Target 5-8 todos per wave.

**Wave A**: LoadingState统一 — 1 atomic wave (cannot split, risk of broken compilation)
**Wave B+C**: B (单元测试) ∥ C (ValidateHttp抽象) — parallel, no dependency between them
**Wave D**: 插件化架构 — depends on A (type unification) + C (Repository pattern stability)

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| A1-A5 (LoadingState) | — | B, C, D | — |
| B1-B3 (单元测试) | A | — | C1-C3 |
| C1-C3 (ValidateHttp) | A | D (weak) | B1-B3 |
| D1-D4 (插件化) | A, C | — | — |

## Todos
> Implementation + Test = ONE todo. Never separate.

### Wave A — LoadingState统一 (atomic, 1 task)
- [x] 1. 统一 LoadingState + 更新所有 import + 清理别名 + 删除 _fromBili + 页面模式重写 — ATOMIC (全部一次做完，不能分批)
  - 子步骤：
    1. 给 core `Success`/`Error` 加 `@immutable` 注解，加 `import 'package:flutter/foundation.dart' show immutable;`
    2. 在 169 个 HTTP/gRPC/service 文件中：`import 'package:skf/adapters/bilibili/http/loading_state.dart'` → `import 'package:skf/core/result/loading_state.dart'`
    3. 在 22 个使用 `as bili_loading` 别名的文件中删除别名导入；如果有重复的 core import 则保留一个
    4. 在 20 个 Bili*Repository 文件中删除 `_fromBili()` 方法及其所有调用方，内联展开
    5. 在 2 个页面文件（`whisper_detail/view.dart`、`header_control.dart`）中将 `bili_loading.LoadingState`/`bili_loading.Success`/`bili_loading.Error` 替换为非别名版本
    6. 删除 `lib/adapters/bilibili/http/loading_state.dart`
    7. `flutter analyze` 验证 0 errors
  - References: `lib/core/result/loading_state.dart` (目标), `lib/adapters/bilibili/http/loading_state.dart` (删除目标), 169 个文件有 bili import, 22 个有 `as bili_loading`
  - Acceptance criteria: `flutter analyze` — 0 errors; grep for `loading_state.dart` from `adapters/bilibili/http/` — 0 matches; grep for `_fromBili` — 0 matches; grep for `bili_loading` — 0 matches
  - QA scenarios: 
    - Happy: full analyze passes + grep assertions above
    - Failure: if any file still references deleted path → error in analyze output
  - Commit: Y | `refactor(spes): unify LoadingState — delete bili duplicate, update 192 files, add @immutable`

### Wave B — 单元测试 (parallel with C)
- [x] 2. 配置测试环境
  - 修改 `.gitignore`: 将第 152 行的 `test*` 替换为 `test_results/` (只忽略测试产物目录，不忽略 `test/` 源码目录)
  - `dart pub add --dev mockito`
  - `dart pub add --dev build_runner` (验证已存在)
  - 创建 `test/` 目录 + `test/provider/` 目录结构
  - 验证 `flutter test` 能跑起来 (返回 0 tests pass 即可)
  - References: `.gitignore:152`, `pubspec.yaml dev_dependencies`
  - Acceptance criteria: `.gitignore` 不再 `test*` 开头; `dart pub deps | findstr mockito` 有输出; `flutter test` 运行成功 (0 tests, 0 errors)
  - QA scenarios:
    - Happy: `flutter test` returns successfully
    - Failure: gitignore still matches `test/` dir → test files get ignored
  - Commit: N (part of B3)

- [x] 3. 选择示范 Repository + 写 mockito mock
  - 选择最简单的 Repository: `DanmakuFilterRepository` (3 methods) 或 `FanRepository` (1 method) — 因为方法数最少，适合做示范
  - 执行 `dart run build_runner build --delete-conflicting-outputs` 生成 mock
  - 在 `test/repository/` 下创建 mock file
  - References: `lib/core/repository/danmaku_filter_repository.dart` (接口), `lib/adapters/bilibili/repository/bili_danmaku_filter_repository.dart` (实现)
  - Acceptance criteria: mock 文件已生成 (`test/repository/bili_danmaku_filter_repository_test.dart`), `flutter analyze` on test files — 0 errors
  - QA scenarios:
    - Happy: build_runner completes, mock classes compile
    - Failure: mockito code gen creates lint violations → configure build.yaml
  - Commit: N (part of B3)

- [x] 4. 写 3 个示范测试 (happy + error + edge) + 验证
  - 测试 1 (happy): mock HTTP 返回成功数据 → assert Repository 返回正确 type
  - 测试 2 (error): mock HTTP 返回错误 → assert Repository 返回 Error LoadingState
  - 测试 3 (edge): mock HTTP 返回空数据 → assert Repository 正确处理
  - `flutter test` — 3/3 pass
  - `flutter analyze` — 0 new errors
  - References: `test/repository/` structure
  - Acceptance criteria: `flutter test` — 3 passed; `flutter analyze` — 0 errors
  - QA scenarios:
    - Happy: 3 tests green
    - Failure: test fails → investigate mock setup
  - Commit: Y | `test(spes): add unit testing infra + 3 DanmakuFilterRepository tests`

### Wave C — ValidateHttp 抽象 (parallel with B)
- [x] 5. 创建 ValidateRepository 接口
  - 创建 `lib/core/repository/validate_repository.dart`
  - 2 个方法: `gaiaVgateRegister(String vVoucher) → Future<LoadingState<Map?>>`; `gaiaVgateValidate(...) → Future<LoadingState<Map?>>`
  - 接口使用 core 的 LoadingState
  - References: `lib/adapters/bilibili/http/validate.dart` (2 methods, 1 caller)
  - Acceptance criteria: 接口定义正确，`flutter analyze` — 0 errors
  - Commit: N (part of 7)

- [x] 6. 创建 BiliValidateRepository 实现 + Bridge 注册
  - 创建 `lib/adapters/bilibili/repository/bili_validate_repository.dart`
  - 实现 2 个方法 (从 `validate.dart` 复制逻辑)
  - Bridge 添加: `Get.lazyPut<ValidateRepository>(BiliValidateRepository.new);`
  - References: `validate.dart`, `bridge.dart`
  - Acceptance criteria: `flutter analyze` — 0 errors; Bridge 包含 BiliValidateRepository 注册
  - Commit: N (part of 7)

- [x] 7. 更新调用方 + 删除旧文件 + 验证
  - 更新 `lib/adapters/bilibili/utils/request_utils.dart`: `ValidateHttp.gaiaVgateValidate(...)` → `Get.find<ValidateRepository>().gaiaVgateValidate(...)`; 添加 `import 'package:get/get.dart';` 若缺失
  - 删除 `lib/adapters/bilibili/http/validate.dart`
  - `flutter analyze` — 0 errors
  - grep 确认无 `ValidateHttp` 残留
  - References: `request_utils.dart`, `validate.dart`
  - Acceptance criteria: `flutter analyze` 0 errors; grep "ValidateHttp" — 0 matches; `request_utils.dart` 使用 `Get.find<ValidateRepository>()`
  - QA scenarios:
    - Happy: analyze 0 errors, grep clean
    - Failure: old ValidateHttp still referenced → error
  - Commit: Y | `refactor(spes): extract ValidateHttp→ValidateRepository, 2 methods, 1 caller`

### Wave D — 插件化架构
- [x] 8. 定义 Plugin 接口 (≤3 抽象方法)
  - 创建 `lib/core/plugin/plugin.dart`
  - 接口定义 (最多 3 个抽象方法): `String get name;` `Future<void> onRegister(PluginRegistry registry);` `DataSource? provideDataSource(String sourceId);` (可选)
  - 创建 `lib/core/plugin/data_source.dart` — `DataSource` 数据源模型类 (id, uri, title, metadata)
  - 禁止: 超过 3 个抽象方法; 任何 "future plugin" 占位方法
  - References: `lib/core/` 结构 (account/, di/, models/, player/, repository/, result/)
  - Acceptance criteria: `flutter analyze` — 0 errors; Plugin 接口 ≤3 抽象方法
  - Commit: N (part of 11)

- [x] 9. 创建 PluginRegistry
  - 创建 `lib/core/plugin/plugin_registry.dart`
  - 包装 GetX DI: `register<T extends Plugin>(T plugin)`、`resolve<T extends Plugin>()`、`all()`、`getDataSource(String id)`
  - 使用 `Get.put()` 注册 plugin 单例
  - 注意: 不要另起一套 DI 框架 — 直接复用 GetX
  - References: `lib/core/di/service_registry.dart` (已废弃, 用 GetX 取代)
  - Acceptance criteria: `flutter analyze` — 0 errors; PluginRegistry 使用 GetX 做 DI
  - Commit: N (part of 11)

- [x] 10. 实现 LocalFilePlugin (数据源 demo)
  - 创建 `lib/core/plugin/local_file_plugin.dart`
  - 实现 Plugin 接口: `name = "local_file"`; `onRegister()` 注册自己; `provideDataSource()` 返回本地视频文件 URI
  - 使用 `file_picker` 或 `platform` API 选择本地文件 (先验证 `file_picker` 已在 pubspec.yaml 中)
  - 如果 `file_picker` 不存在: 用硬编码 demo 路径或 `dart:io` File 选择器 (跨平台兼容)
  - 与现有 `lib/adapters/bilibili/pages/video/introduction/local/controller.dart` 不重叠 — LocalFilePlugin 是纯数据源，不涉及 UI
  - References: `pubspec.yaml` 检查 file_picker, `lib/core/plugin/plugin.dart`
  - Acceptance criteria: `flutter analyze` — 0 errors; LocalFilePlugin 编译通过
  - Commit: N (part of 11)

- [x] 11. 播放器集成点 + 端到端验证
  - 在播放器入口注入 plugin hook: 播放前检查 PluginRegistry 是否有匹配的 DataSource
  - 最小集成: 在 `lib/core/player/player_factory.dart` 或类似位置添加可选 DataSource 参数
  - 验证全链路: `PluginRegistry.register(LocalFilePlugin())` → `registry.getDataSource("local_file")` → 返回 URI
  - `flutter analyze` — 0 errors
  - References: `lib/core/player/player_factory.dart`, `lib/adapters/bilibili/player/bili_player_factory.dart`
  - Acceptance criteria: `flutter analyze` 0 errors; LocalFilePlugin 可注册到 PluginRegistry; 全链路编译通过
  - QA scenarios:
    - Happy: Plugin 可注册、可解析、可提供 DataSource
    - Failure: GetX DI 注入冲突 → 检查作用域
  - Commit: Y | `feat(spes): add Plugin interface + PluginRegistry + LocalFilePlugin demo`

## Final verification wave
> Runs in parallel after ALL todos. ALL must APPROVE.
- [x] 12. Plan compliance audit — 所有 todo 完成, 范围未超出
- [x] 13. Code quality review — `flutter analyze` — 0 errors
- [x] 14. Real manual QA — grep 确认: 无 bili LoadingState 引用; 无 ValidateHttp 残留; 无 _fromBili 残留; Plugin 接口 ≤3 方法
- [x] 15. Scope fidelity — 确认: ❌ 无 widget/integration 测试; ❌ 无插件市场; ❌ 无现有 B站 代码改动; Plugin 接口未膨胀

## Commit strategy
- A1: `refactor(spes): unify LoadingState — delete bili duplicate, update 192 files, add @immutable`
- B3: `test(spes): add unit testing infra + 3 DanmakuFilterRepository tests`
- C3: `refactor(spes): extract ValidateHttp→ValidateRepository, 2 methods, 1 caller`
- D4: `feat(spes): add Plugin interface + PluginRegistry + LocalFilePlugin demo`

## Success criteria
- A: `flutter analyze` 0 errors; no bili LoadingState usage; no `_fromBili`; no `bili_loading` alias
- B: `flutter test` 3/3 pass; `.gitignore` no longer ignores test dir
- C: `flutter analyze` 0 errors; no `ValidateHttp` references; `request_utils.dart` uses DI
- D: Plugin interface ≤3 methods; LocalFilePlugin compiles; PluginRegistry wraps GetX
- All: `flutter analyze` 0 errors (113 pre-existing infos only)
