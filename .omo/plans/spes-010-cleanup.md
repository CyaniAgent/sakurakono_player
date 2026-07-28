# spes-010-cleanup - Work Plan

## TL;DR (For humans)

**What you'll get:** 一个干净的项目工作区（清理了 100+ 个临时会话文件），common/ 共享组件不再直接依赖 B站 适配器，以及一份详细的 core/repository 接口解构路线图。

**Why this approach:** 技术债需要先清理再规划。运行会话文件是开发缓存不应进入版本控制；common/ 中剩余的 3 个 adapter import 是之前的解耦遗漏；而核心接口的 153 个 adapter import 需要先全面分析再分批执行，不能一次硬改。

**What it will NOT do:** ❌ 不改 core/repository 的代码（仅分析）; ❌ 不改业务逻辑; ❌ 不改播放器或构建系统。

**Effort:** Medium — 3 个 phase（清理 + 小解耦 + 大分析）
**Risk:** Low — 清理和 common 解耦是机械操作；分析报告不涉及代码修改
**Decisions to sanity-check:** core/ 接口解耦是否分批执行（已确认 — 先分析后分批）

Your next move: approve the plan, then execute via `/start-work`. Full execution detail follows below.

---

> TL;DR (machine): Medium, Low. P0: 清理 100+ 会话文件 + .gitignore. P1: 清除 common/ 3 个 adapter import（2 files）. P2: 产出 23 文件 153 import 的 core/repository 解耦分析报告. flutter analyze 0 errors, flutter test 72/72.

## Scope
### Must have
- P0: 清理 `.omo/run-continuation/` — 添加 `omo/run-continuation/` 到 `.gitignore`，删除所有临时 JSON 文件
- P1: 清除 `lib/common/` 剩余的 3 个 adapter import
- P2: 产出 `lib/core/repository/` 接口解耦分析报告

### Must NOT have (guardrails, anti-slop, scope boundaries)
- ❌ 不改 core/repository 的接口代码（仅分析）
- ❌ 不改 adapter 端的实现代码
- ❌ 不改业务逻辑（controller/view）
- ❌ 不改播放器核心接口（PlayerFactory, PlayerController）
- ❌ 不改 build 脚本或 CI 配置
- ❌ 不新增适配器或业务功能

## Verification strategy
> Zero human intervention - all verification is agent-executed.
- Test decision: tests-after — 现有测试 (72 个) 全程保持通过；P1 修复后运行 `flutter analyze` 0 errors
- Evidence: `.omo/evidence/spes-010-cleanup/task-<N>.md`

## Execution strategy
### Parallel execution waves
**Wave 1**: P0 (清理会话文件) — 串行，独立无依赖
**Wave 2**: P1 (common 解耦) — 串行，可独立执行
**Wave 3**: P2 (分析报告) — 串行，需要 P0+P1 完成后的项目状态作为分析基准

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| P0 (清理会话文件) | — | — | P1(可并行) |
| P1 (common 解耦) | — | — | P0(可并行) |
| P2 (分析报告) | P0,P1 | — | — |

## Todos
> Implementation + Test = ONE todo. Never separate.
<!-- APPEND TASK BATCHES BELOW THIS LINE WITH edit/apply_patch - never rewrite the headers above. -->
- [x] 1. 清理 `.omo/run-continuation/` 会话文件
  What to do / Must NOT do:
  - 读取 `.gitignore` 确认当前内容
  - 如果还没有 `omo/run-continuation/` 条目，添加到 `.gitignore`
  - 删除 `.omo/run-continuation/` 下的所有 `ses_*.json` 文件（约 100+ 个）
  - 确认 `git status --short` 干净（只显示 `.gitignore` 修改）
  - ❌ 不修改任何代码文件
  - ❌ 不删除 `.omo/drafts/` 或 `.omo/plans/` 中的内容
  - ❌ 不修改其他 `.omo/` 文件
  Parallelization: Wave 1 | Blocked by: — | Blocks: —
  References:
  - `glob ".omo/run-continuation/*.json"` — 100+ 文件
  - `.gitignore` — 根目录的 gitignore 文件
  Acceptance criteria (agent-executable):
  - `git status --short` — 仅 `.gitignore` 修改（添加 run-continuation/ 条目）无其他变更
  - `Test-Path ".omo/run-continuation/ses_*.json"` — 返回 `False`（无残留文件）
  QA scenarios:
  - Happy: 文件删除 + .gitignore 更新成功，git status 干净
  - Failure: 文件删除失败或 gitignore 写错 → 回退并重试
  Evidence: `.omo/evidence/spes-010-cleanup/task-1.md`
  Commit: Y | `chore(omo): clean run-continuation session files and add to .gitignore`

- [x] 2. 修复 `lib/common/` 剩余 3 个 adapter import
  What to do / Must NOT do:
  - 读取 `lib/common/widgets/appbar/appbar.dart`:
    - 当前 import: `MultiSelectBase` 来自 `adapters/bilibili/pages/common/multi_select/base.dart`
    - 读取 `lib/adapters/bilibili/pages/common/multi_select/base.dart` 理解 `MultiSelectBase` 是什么
    - 如果 `MultiSelectBase` 是纯接口（无 adapter 依赖），将其抽象接口移到 `lib/core/models/ui/multi_select_base.dart`
    - 如果 `MultiSelectBase` 有 adapter 依赖，改为参数化模式（widget 不直接 import adapter 类型）
  - 读取 `lib/common/widgets/image_grid/image_grid_view.dart`:
    - 当前 import: `bili_image_utils.dart` 和 `page_utils.dart`
    - 读取这两个 util 文件确认它们的功能
    - 如果是从 HTTP/数据层无关的纯工具函数，移到 `lib/common/utils/` 或 `lib/utils/`
    - 如果依赖 adapter 数据，则在调用处改为参数化传入
  - 修复后运行 `flutter analyze` 确认 0 errors
  - 运行 `grep "import.*adapters/bilibili" lib/common/ -r` 确认 0 matches
  - ❌ 不改业务逻辑
  - ❌ 不改 adapter 端实现
  - ❌ 如果 MultiSelectBase 实在无法抽象，在报告中记录原因并跳过
  Parallelization: Wave 2 | Blocked by: — | Blocks: —
  References:
  - `lib/common/widgets/appbar/appbar.dart:1` — `MultiSelectBase` import
  - `lib/common/widgets/image_grid/image_grid_view.dart:30-31` — 2 util imports
  - `lib/adapters/bilibili/pages/common/multi_select/base.dart` — MultiSelectBase 定义
  - `lib/adapters/bilibili/utils/bili_image_utils.dart` — 图片工具
  - `lib/adapters/bilibili/utils/page_utils.dart` — 页面导航工具
  - AGENTS.md Architecture section for core/adapter separation
  Acceptance criteria (agent-executable):
  - `grep "import.*adapters/bilibili" lib/common/ -r` — 0 matches
  - `flutter analyze` — 0 errors
  - `flutter test` — 72/72 pass
  QA scenarios:
  - Happy: common/ 无 adapter import，analyze + test 通过
  - Failure: 仍有残留 import 或引入新 error
  Evidence: `.omo/evidence/spes-010-cleanup/task-2.md`
  Commit: Y | `refactor(common): decouple last 3 adapter imports from common/`

- [x] 3. 产出 `lib/core/repository/` 接口解耦分析报告
  What to do / Must NOT do:
  - 对 `lib/core/repository/` 中 23 个有 adapter import 的接口文件进行全面分析
  - 对每个文件，分类统计 adapter import 的类型：
    - 类别 A: gRPC protobuf 生成的类型（如 `v1.pb.dart`）
    - 类别 B: 模型/数据类（如 `data.dart`, `info.dart`）
    - 类别 C: 工具函数/枚举（如 `utils/`, `models/common/`）
  - 对每个文件，评估解耦难度：简单（仅替换 import）/ 中等（需创建 core 类型）/ 困难（接口设计依赖 adapter 概念）
  - 建议解耦执行顺序（按依赖关系分组）
  - 产出分析报告到 `.omo/reports/core-repository-decoupling.md`
  - ❌ 不修改任何代码文件
  - ❌ 不修改 API 接口
  - ❌ 不创建或删除任何核心接口
  Parallelization: Wave 3 | Blocked by: P0, P1 | Blocks: —
  References:
  - `lib/core/repository/` — 24 个接口文件（23 个有 adapter import，1 个无）
  - `lib/core/repository/validate_repository.dart` — 无 adapter import 的参考范例
  - `lib/adapters/bilibili/repository/` — 24 个 Bili* 实现
  Acceptance criteria (agent-executable):
  - `.omo/reports/core-repository-decoupling.md` 存在且包含所有 24 个接口的分析
  - 报告中包含：import 分类统计、每个接口的难度评级、建议执行顺序
  QA scenarios:
  - Happy: 报告完整、分类清晰、建议可行
  - Failure: 报告缺失重要接口或分类错误
  Evidence: `.omo/evidence/spes-010-cleanup/task-3.md`
  Commit: Y | `docs(omo): add core-repository decoupling analysis report`

## Final verification wave
> Runs in parallel after ALL todos. ALL must APPROVE. Surface results and wait for the user's explicit okay before declaring complete.
- [x] F1. Plan compliance audit — P0, P1, P2 均按计划完成
- [x] F2. Code quality — `flutter analyze` 0 errors；`flutter test` 72/72 pass
- [x] F3. Real manual QA — 引用各 task 的 QA 标准逐项确认
- [x] F4. Scope fidelity — 无范围蔓延，core/ 代码未被修改

## Commit strategy
- P0: `chore(omo): clean run-continuation session files and add to .gitignore`
- P1: `refactor(common): decouple last 3 adapter imports from common/`
- P2: `docs(omo): add core-repository decoupling analysis report`

## Success criteria
- `git status --short` — 干净（仅 .gitignore 中 run-continuation/ 新增）
- `grep "import.*adapters/bilibili" lib/common/ -r` — 0 matches（P1）
- `.omo/reports/core-repository-decoupling.md` 存在（P2）
- `flutter analyze` — 0 errors
- `flutter test` — 72/72 pass
