# master-plan-remaining - Work Plan

## TL;DR (For humans)

**What you'll get:** 一整套剩余工作的执行路线图——清理 3 个残留 PiliPlus 引用（5 分钟），统一 LoadingState（核心基础，169 文件），完成剩余 17+1 个 Repository 抽象（~50 文件），建立单元测试体系（3 个示范测试），将 ValidateHttp 抽象为标准接口，最后搭建插件化架构（Plugin + Registry + 本地文件 Demo）。

**Why this approach:** LoadingState 统一是地基——它修改 169 个文件的 import 路径，后续所有工作都在统一后的类型系统上进行。Plan C（剩余 Repository）和 Plan A 的 B/C 互相独立，可并行执行，最大化利用执行资源。

**What it will NOT do:** ❌ 不碰 common/ 剩余的 13 个适配器导入（可接受债务）；❌ 不改播放器内部；❌ 不改 Repository 接口签名。

**Effort:** XL — 4 个阶段，200+ 文件变更，合计 ~25-30h 执行时间
**Risk:** Medium — P1（LoadingState 统一）原子操作，编译断裂风险高；其余为模式化工作
**Decisions to sanity-check:** LoadingState 统一必须先做；Plan C 放在 LoadingState 之后而非之前

Your next move: approve the plan. Full execution detail follows below.

---

> TL;DR (machine): P0→P1→(P2∥P3∥P4)→P5. SPES-009 cleanup + LoadingState (~200f) + 17 Repos (~50f) + unit tests + ValidateHttp + Plugins. ~25-30h, flutter analyze 0 errors. Refer to existing detailed plans for each phase.

## Scope
### Must have
- **P0**: SPES-009 收尾 — README.md/AGENTS.md/pubspec.yaml 中 PiliPlus 引用清理
- **P1**: LoadingState统一 — 删除 adapter 副本，统一用 core 版本，更新 169 文件（Plan A-A，详见 `.omo/plans/spes-next-four-items.md`）
- **P2**: 剩余 17+1 Repository 抽象（Plan C，详见 `.omo/plans/spes-group3-remaining-services.md`）
- **P3**: 单元测试体系（Plan A-B，详见 `.omo/plans/spes-next-four-items.md`）
- **P4**: ValidateHttp→ValidateRepository（Plan A-C，详见 `.omo/plans/spes-next-four-items.md`）
- **P5**: 插件化架构（Plan A-D，详见 `.omo/plans/spes-next-four-items.md`）

### Must NOT have (guardrails, anti-slop, scope boundaries)
- ❌ 不修改 common/ 剩余的 13 个适配器导入
- ❌ 不改播放器内部实现
- ❌ 不改 Repository 接口签名
- ❌ 不新增未在已有计划中的工作项
- ❌ 不重复编写已有计划的详细 TODO（引用对应文件）

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- Test decision: tests-after — 每个 phase 执行后 `flutter analyze` 0 errors
- 各 phase 的详细验证策略见对应计划文件

## Execution strategy
### Parallel execution waves

**Phase 0**: SPES-009 cleanup — 1 个独立任务，可随时执行
**Phase 1**: LoadingState统一 — 1 个原子任务（P0 之后，P2 之前）
**Phase 2**: 3 个并行流：
  - Stream 2A: Plan C — 17+1 Repository（依赖 P1 完成后的统一 LoadingState）
  - Stream 2B: Plan A-B 单元测试（依赖 P1，与 Plan C 不冲突）
  - Stream 2C: Plan A-C ValidateHttp 抽象（依赖 P1，与 Plan C/B 不冲突）
**Phase 3**: 插件化架构（依赖 P1 + P2C，但 Plan C 和 AB 不阻塞）

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| P0 (SPES-009 cleanup) | — | — | 所有 |
| P1 (LoadingState统一) | P0 (可选) | P2, P3, P4, P5 | — |
| P2 (Plan C: 17 Repos) | P1 | — | P3, P4 |
| P3 (单元测试) | P1 | — | P2, P4 |
| P4 (ValidateHttp) | P1 | P5 (weak) | P2, P3 |
| P5 (插件化架构) | P1, P4 | — | — |

## Todos
> Implementation + Test = ONE todo. Never separate.
<!-- APPEND TASK BATCHES BELOW THIS LINE WITH edit/apply_patch - never rewrite the headers above. -->

### Phase 0 — SPES-009 收尾 (1 task, trivial)

- [x] 0. SPES-009 收尾 — 清理 PiliPlus 残留引用
  What to do / Must NOT do:
  - 修改 `pubspec.yaml` line 2: `description: "fork of PiliPlus"` → `description: "SakuraKono Player Framework — plugin-based video player"`
  - 修改 `README.md`: 替换所有 "PiliPlus" 引用为 "SKF" 或 "SakuraKono Player"，保持项目历史说明
  - 检查 `AGENTS.md` 是否仍有 PiliPlus 引用（目前已更新，仅项目身份说明部分提及）
  - 不要修改代码逻辑或功能
  - `grep -i piliplus .omo/` — 允许（计划文件中可引用历史名称）
  - `grep -i piliplus lib/` — 0 matches（不应有代码引用）
  - `grep -i piliplus pubspec.yaml README.md AGENTS.md` — 仅在 AGENTS.md 项目身份部分有 "PiliPlus" 历史说明（允许）
  Parallelization: Phase 0 | Blocked by: — | Blocks: —
  References: `pubspec.yaml:2`, `README.md` (多处), `AGENTS.md:28` (已更新)
  Acceptance criteria (agent-executable):
  - `grep -i piliplus pubspec.yaml` — 0 matches
  - `grep -i piliplus lib/` — 0 matches
  - `flutter analyze` — 0 errors
  - AGENTS.md 中 "PiliPlus" 仅出现在项目历史说明中（允许）
  QA scenarios:
  - Happy: README 不再出现 PiliPlus 作为项目名称；pubspec description 更新
  - Failure: 仍有文件引用 PiliPlus 作为当前项目名称
  Evidence: `.omo/evidence/master-plan-remaining/task-0-evidence.md`
  Commit: Y | `chore(spes): cleanup remaining PiliPlus references in docs`

### Phase 1 — LoadingState 统一 (1 atomic task)

- [x] 1. LoadingState统一（Plan A-A，引用 `.omo/plans/spes-next-four-items.md` Lines 64-79）
  What to do / Must NOT do:
  - **完整执行 Plan A-A 的详细 TODO**（见 `.omo/plans/spes-next-four-items.md#L64-L79`）
  - 关键步骤：
    1. 给 core `Success`/`Error` 加 `@immutable`
    2. 更新 169 个文件的 import 路径（adapter → core）
    3. 重写 22 个别名导入（`as bili_loading`）
    4. 删除 20 个 Bili*Repository 的 `_fromBili()` 方法
    5. 简化 2 个页面文件的模式匹配转换
    6. 删除 `lib/adapters/bilibili/http/loading_state.dart`
  - ❌ 不修改任何业务逻辑
  - ❌ 不修改测试文件
  - 必须一次完成（原子操作），否则编译断裂
  Parallelization: Phase 1 | Blocked by: 0 | Blocks: 2, 3, 4, 5
  References: `.omo/plans/spes-next-four-items.md#L64-L79`（完整子步骤）
  Acceptance criteria (agent-executable):
  - `flutter analyze` — 0 errors
  - `grep "loading_state" lib/adapters/bilibili/http/` — 0 matches
  - `grep "_fromBili" lib/` — 0 matches
  - `grep "bili_loading" lib/` — 0 matches
  QA scenarios:
  - Happy: analyze 0 errors + grep assertions all pass
  - Failure: 任何文件遗留旧路径 → analyze error
  Evidence: `.omo/evidence/master-plan-remaining/task-1-evidence.md`
  Commit: Y | `refactor(spes): unify LoadingState — delete bili duplicate, update 192 files, add @immutable`

### Phase 2 — 并行流 (3 streams run in parallel)

- [x] 2. Plan C — 剩余 17+1 Repository（引用 `.omo/plans/spes-group3-remaining-services.md`）
  What to do / Must NOT do:
  - **完整执行 Plan C 的详细 TODO**（见 `.omo/plans/spes-group3-remaining-services.md`）
  - Waves:
    - Wave 0: 删除 `grpc/view.dart`
    - Wave 1: 5 个大 Repository（Dynamics, Member, Live, Msg, Im）
    - Wave 2: 10 个极简 Repository（Danmaku, Music, DanmakuFilter, Follow, Audio, Fan, Black, Match, Space, Download）
    - Wave 3: 2 个中等 Repository（Pgc, SponsorBlock）
    - Wave 4: 控制器重构
    - Wave 5: 最终验证
  - ❌ 不统一 LoadingState
  - ❌ 不写测试
  - ❌ 不改业务逻辑
  - 前提条件: P1 (LoadingState统一) 必须先完成
  Parallelization: Phase 2 Stream 2A | Blocked by: 1 | Blocks: —
  References: `.omo/plans/spes-group3-remaining-services.md`（完整 123 行 TODO）
  Acceptance criteria (agent-executable):
  - `flutter analyze` — 0 errors
  - 所有 17+1 个 Repository 接口 + 实现存在
  - Bridge 注册完整
  - `grpc/view.dart` 已删除
  QA scenarios: 见 Plan C 文档
  Evidence: `.omo/evidence/master-plan-remaining/task-2-evidence.md`
  Commit: Y (multiple per Plan C commit strategy)

- [x] 3. Plan A-B — 单元测试体系（引用 `.omo/plans/spes-next-four-items.md` Lines 81-117）
  What to do / Must NOT do:
  - **完整执行 Plan A-B 的详细 TODO**（见 `.omo/plans/spes-next-four-items.md#L81-L117`）
  - 子任务:
    1. 配置测试环境（gitignore fix + mockito + build_runner）
    2. 选择 Demo Repository + 生成 mock
    3. 写 3 个示范测试（happy + error + edge）
  - ❌ 不超过 3 个测试
  - ❌ 不写 widget/integration 测试
  Parallelization: Phase 2 Stream 2B | Blocked by: 1 | Blocks: —
  References: `.omo/plans/spes-next-four-items.md#L81-L117`（完整 TODO）
  Acceptance criteria (agent-executable):
  - `flutter test` — 3/3 pass
  - `flutter analyze` — 0 errors
  - `.gitignore` line 152: `test_results/`（非 `test*`）
  QA scenarios: 见 Plan A-B 文档
  Evidence: `.omo/evidence/master-plan-remaining/task-3-evidence.md`
  Commit: Y | `test(spes): add unit testing infra + 3 DanmakuFilterRepository tests`

- [x] 4. Plan A-C — ValidateHttp 抽象（引用 `.omo/plans/spes-next-four-items.md` Lines 119-146）
  What to do / Must NOT do:
  - **完整执行 Plan A-C 的详细 TODO**（见 `.omo/plans/spes-next-four-items.md#L119-L146`）
  - 子任务:
    1. 创建 ValidateRepository 接口（2 方法）
    2. 创建 BiliValidateRepository 实现 + Bridge 注册
    3. 更新调用方 + 删除旧 validate.dart
  - ❌ 不改 LoadingState
  - ❌ 不改其他文件
  Parallelization: Phase 2 Stream 2C | Blocked by: 1 | Blocks: 5 (weak)
  References: `.omo/plans/spes-next-four-items.md#L119-L146`（完整 TODO）
  Acceptance criteria (agent-executable):
  - `flutter analyze` — 0 errors
  - `grep "ValidateHttp" lib/` — 0 matches
  - `request_utils.dart` 使用 `Get.find<ValidateRepository>()`
  QA scenarios: 见 Plan A-C 文档
  Evidence: `.omo/evidence/master-plan-remaining/task-4-evidence.md`
  Commit: Y | `refactor(spes): extract ValidateHttp→ValidateRepository, 2 methods, 1 caller`

### Phase 3 — 插件化架构

- [x] 5. Plan A-D — 插件化架构（引用 `.omo/plans/spes-next-four-items.md` Lines 148-187）
  What to do / Must NOT do:
  - **完整执行 Plan A-D 的详细 TODO**（见 `.omo/plans/spes-next-four-items.md#L148-L187`）
  - 子任务:
    1. Plugin 接口定义（≤3 抽象方法）
    2. DataSource 模型
    3. PluginRegistry（包装 GetX DI）
    4. LocalFilePlugin 实现
    5. 播放器集成点
  - ❌ Plugin 接口不超过 3 个抽象方法
  - ❌ 不做插件市场/动态加载
  - ❌ 不改现有 B站 适配器代码
  Parallelization: Phase 3 | Blocked by: 1, 4 (weak) | Blocks: —
  References: `.omo/plans/spes-next-four-items.md#L148-L187`（完整 TODO）
  Acceptance criteria (agent-executable):
  - `flutter analyze` — 0 errors
  - Plugin 接口 ≤3 抽象方法
  - LocalFilePlugin 可注册到 PluginRegistry
  - 全链路编译通过
  QA scenarios: 见 Plan A-D 文档
  Evidence: `.omo/evidence/master-plan-remaining/task-5-evidence.md`
  Commit: Y | `feat(spes): add Plugin interface + PluginRegistry + LocalFilePlugin demo`

## Final verification wave
> Runs in parallel after ALL todos. ALL must APPROVE. Surface results and wait for the user's explicit okay before declaring complete.
- [x] F1. Plan compliance audit — 所有 phase 按计划完成，范围未超出
- [x] F2. Code quality — `flutter analyze` 0 errors；所有 grep 断言通过
- [x] F3. Real manual QA — 引用各计划文件的 QA 标准
- [x] F4. Scope fidelity — 无范围蔓延，无未授权的修改

## Commit strategy
- P0: `chore(spes): cleanup remaining PiliPlus references in docs`
- P1: `refactor(spes): unify LoadingState — delete bili duplicate, update 192 files, add @immutable`
- P2: 多 commit，按 Plan C 策略（每 3-5 个 Repo 一批 + 控制器重构）
- P3: `test(spes): add unit testing infra + 3 DanmakuFilterRepository tests`
- P4: `refactor(spes): extract ValidateHttp→ValidateRepository, 2 methods, 1 caller`
- P5: `feat(spes): add Plugin interface + PluginRegistry + LocalFilePlugin demo`

## Success criteria
- `grep -i piliplus pubspec.yaml` — 0 matches (P0)
- `grep "loading_state" lib/adapters/bilibili/http/` — 0 matches (P1)
- `grep "_fromBili" lib/` — 0 matches (P1)
- `grep "bili_loading" lib/` — 0 matches (P1)
- `flutter test` — 3/3 pass (P3)
- `grep "ValidateHttp" lib/` — 0 matches (P4)
- Plugin 接口 ≤3 抽象方法 (P5)
- **最终**: `flutter analyze` — 0 errors
