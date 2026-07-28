---
slug: spes-010-cleanup
status: drafting
intent: clear
pending-action: write .omo/plans/spes-010-cleanup.md
approach: "清理剩余技术债 — 三步走：P0 清除会话文件 + P1 清除 common/ 剩余 adapter import + P2 产出 core/repository 接口解耦分析报告与路线图"
---

# Draft: spes-010-cleanup

## Components (topology ledger)
<!-- Lock the SHAPE before depth. One row per top-level component that can succeed or fail independently. -->
<!-- id | outcome (one line) | status: active|deferred | evidence path -->
- P0 | 清理 .omo/run-continuation/ 临时文件 | active | glob count = 100+
- P1 | 清除 common/ 剩余 3 个 adapter import | active | `grep "import.*adapters/bilibili" lib/common/` = 3 matches in 2 files
- P2 | core/repository 接口解耦分析 | active | `grep "import.*adapters/bilibili" lib/core/` = 153 matches in 23 files

## Open assumptions (announced defaults)
<!-- Record any default you adopt instead of asking, so the user can veto it at the gate. -->
<!-- assumption | adopted default | rationale | reversible? -->
- Gitignore 策略: `run-continuation/` 整个目录加 .gitignore 而非逐个删除 | 会话文件是执行缓存，不需要版本控制 | ✅ 可恢复
- core/ 解耦方案: 采用「分析先行」策略 — 先产出完整的影响面分析报告，再决定是否按批次重构 | 23 个接口 153 个 import 影响面太大，需要先摸底 | ✅ 可调整范围
- common/ `appbar.dart` MultiSelectBase: 将 MultiSelectBase 接口移到 core/models/ui/ 下，而非在 common/ 中保留 adapter import | 遵循 core 不依赖 adapter 的原则 | ⚠️ 需要确认 MultiSelectBase 是否真的不依赖 adapter 逻辑

## Findings (cited - path:lines)
1. `.omo/run-continuation/` 有 100+ 个 ses_*.json 文件（会话续期缓存），非代码资产 — `glob ".omo/run-continuation/*.json"` count=100+
2. `lib/common/` 剩余 3 个 adapter import 在 2 个文件中：
   - `lib/common/widgets/appbar/appbar.dart:1` → `MultiSelectBase` from `adapters/bilibili/pages/common/multi_select/base.dart`
   - `lib/common/widgets/image_grid/image_grid_view.dart:30` → `bili_image_utils.dart`
   - `lib/common/widgets/image_grid/image_grid_view.dart:31` → `page_utils.dart`
3. `lib/core/repository/` 24 个接口文件中 23 个有 adapter import，共 153 个引用 — `grep -c "import.*adapters/bilibili" lib/core/` = 23 files, 153 matches
4. `lib/core/` 中的 player/ plugin/ models/ result/ account/ 目录均无 adapter import — 问题仅限于 `repository/`
5. `validate_repository.dart` 是唯一一个没有 adapter import 的 repository 接口

## Decisions (with rationale)
1. **P0 使用 .gitignore 而非 git rm**: 会话文件是开发缓存，不应进入版本控制。添加 `omo/run-continuation/` 到 .gitignore 一次性解决
2. **P1 的 MultiSelectBase 需要抽象化**: `appbar.dart` 引用的是适配器层的页面基类，需要将其核心契约提到 `lib/core/models/ui/` 下，或改为接口+参数化模式
3. **P2 只产出分析报告**: 23 个接口 153 个 import 的全面解耦是数周工作，不宜在一个 plan 中完成。先分析、分类、排序，再产出一个或多个后续计划
4. **P2 报告需要包含**: 每个接口的进口分类统计（gRPC类型 vs 模型类型 vs 工具函数）、解耦难度评级、建议执行顺序

## Scope IN
- P0: 清理 .omo/run-continuation/（添加 .gitignore + 可选删除已追踪文件）
- P1: 清除 lib/common/ 剩余 3 个 adapter import（2 个文件）
- P2: 产出 core/repository 解耦分析报告（不执行实际解耦代码更改）

## Scope OUT (Must NOT have)
- ❌ 不执行 core/repository 的实际解耦代码修改（只分析不修改）
- ❌ 不改 build 脚本、CI 配置、Flutter SDK
- ❌ 不改播放器核心逻辑（PlayerFactory, PlayerController 等）
- ❌ 不新增业务功能
- ❌ 不改任何 adapter 端逻辑

## Open questions
1. MultiSelectBase 是否可以被抽象为 core 接口而不改变其行为？— 需要阅读其代码确认
2. `bili_image_utils` 和 `page_utils` 是否可提取为 core utils 或通过不同方式调用？— 需要阅读确认

## Approval gate
status: awaiting-approval
<!-- When exploration is exhausted and unknowns are answered, set status: awaiting-approval. -->
<!-- That durable record is the loop guard: on a later turn read it and resume at the gate instead of re-running exploration. -->
