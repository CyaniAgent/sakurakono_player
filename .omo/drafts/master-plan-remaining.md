---
slug: master-plan-remaining
status: drafting
intent: clear
review_required: false
pending-action: write .omo/plans/master-plan-remaining.md
approach: 整合所有剩余工作（SPES-009 收尾 + Plan A + Plan C）为有序执行路线图，引用已有详细计划，不重复内容
---

# Draft: master-plan-remaining

## Components (topology ledger)
| id | outcome | status | evidence path |
|----|---------|--------|---------------|
| P0: SPES-009 cleanup | 清理 README/AGENTS/pubspec 中残留 PiliPlus 引用 | active | `grep -i piliplus lib/ + *.md + pubspec.yaml` |
| P1: Plan A-A LoadingState统一 | 删除 adapter LoadingState 副本，统一用 core 版本，更新 169 文件 | active | `lib/core/result/loading_state.dart` (target), `lib/adapters/bilibili/http/loading_state.dart` (delete) |
| P2: Plan C 剩余 Repository | 17+1 个新 Repository 接口/实现，~50 文件变更 | active | `.omo/plans/spes-group3-remaining-services.md` |
| P3: Plan A-B 单元测试 | mockito + 3 示范测试 | active | `.omo/plans/spes-next-four-items.md#L81` |
| P4: Plan A-C ValidateHttp抽象 | → ValidateRepository 接口 + 实现 | active | `.omo/plans/spes-next-four-items.md#L119` |
| P5: Plan A-D 插件化架构 | Plugin 接口 + Registry + LocalFilePlugin demo | active | `.omo/plans/spes-next-four-items.md#L148` |

## Open assumptions (announced defaults)
| assumption | adopted default | rationale | reversible? |
|-----------|----------------|-----------|-------------|
| 执行顺序 | P0 → P1 → (P2 ∥ P3 ∥ P4) → P5 | LoadingState 统一是后续所有工作的前提；Plan C 的 Repository 使用统一的 LoadingState 路径；测试/ValidateHttp/插件可并行 | 否（依赖链决定） |
| Plan C 需要 LoadingState 统一后执行 | 执行 Plan C 前先执行 P1 | Plan C 的控制器重构会引用 LoadingState，先用统一路径避免二次修改 | 是（可先执行 Plan C 再用 P1 更新，但效率低） |
| SPES-009 收尾独立 | 在任何阶段都可执行 | 纯文本修改，无代码依赖 | 是 |

## Findings (cited - path:lines)
- `.omo/plans/spes-next-four-items.md` — Plan A 完整草案，207 行，A→(B∥C)→D 顺序
- `.omo/plans/spes-group3-remaining-services.md` — Plan C 完整草案，123 行，17+1 Repository
- `.omo/plans/update-agents-md.md` — 已执行，AGENTS.md 已更新
- `pubspec.yaml:2` — `description` 仍含 "fork of PiliPlus"
- `README.md` — 多处 PiliPlus 引用
- `AGENTS.md` — 已更新，仅项目背景提及 PiliPlus
- `lib/common/` — 13 个适配器导入残留（计划中已确认为可接受技术债务）

## Decisions (with rationale)
1. **参考而非复制现有计划**: Plan A 和 Plan C 已有完整详细的 TODO 清单。本总体规划引用它们，不重复内容。执行时直接引用对应计划文件。
2. **P1 后做 Plan C**: Plan C 的控制器重构会处理 LoadingState 引用。P1 统一 LoadingState 后，Plan C 直接使用 core 路径，避免二次修改。
3. **P3/P4 可并行**: 单元测试和 ValidateHttp 抽象互不依赖，都可与 Plan C 并行。

## Scope IN
- SPES-009 收尾：清理 3 个文件中的 PiliPlus 引用
- Plan A-A: LoadingState 统一（核心阻塞项）
- Plan C: 剩余 17+1 Repository
- Plan A-B: 单元测试体系
- Plan A-C: ValidateHttp→Repository
- Plan A-D: 插件化架构
- 明确执行顺序和依赖关系

## Scope OUT (Must NOT have)
- ❌ 不重复编写已有计划的详细 TODO（引用 `.omo/plans/` 中的对应文件）
- ❌ 不新增未在现有计划中的工作项
- ❌ 不修改 common/ 剩余的 13 个适配器导入（已确认为可接受债务）
- ❌ 不修改播放器内部实现
- ❌ 不改 Repository 接口签名

## Open questions
（无 — 所有信息可从代码库和现有计划中获取）

## Approval gate
status: awaiting-approval
pending-action: approved → execute with `/start-work`
approach: P0→P1→(P2∥P3∥P4)→P5. 引用已有详细计划文件，不重复内容。执行阶段代理读取对应计划文件。
<!-- When exploration is exhausted and unknowns are answered, set status: awaiting-approval. -->
<!-- That durable record is the loop guard: on a later turn read it and resume at the gate instead of re-running exploration. -->
