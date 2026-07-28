---
slug: spes-next-four-items
status: awaiting-approval
intent: clear
pending-action: write .omo/plans/spes-next-four-items.md
approach: A→B→C→D sequentially: LoadingState unification → Unit testing → ValidateHttp abstraction → Plugin architecture with data-source demo
---

# Draft: spes-next-four-items

## Components (topology ledger)
| id | outcome | status | evidence |
|----|---------|--------|----------|
| A - LoadingState统一 | Delete bili's duplicate, add @immutable to core, update 169 imports | active | lib/core/result/loading_state.dart vs lib/adapters/bilibili/http/loading_state.dart (identical + toast exists in both) |
| B - 测试体系 | Unit tests with mockito for Repository layer | active | test* in .gitignore (line 152), flutter_test in dev_deps, 0 test files exist |
| C - ValidateHttp抽象 | ValidateRepository interface + BiliValidateRepository impl | active | validate.dart: 2 methods, 1 caller (request_utils.dart) |
| D - 插件化架构 | Plugin interface + PluginRegistry + LocalFilePlugin demo | active | No plugin infra exists; lib/core/di/service_registry.dart deprecated |

## Open assumptions (announced defaults)
| assumption | adopted default | rationale | reversible? |
|------------|----------------|-----------|-------------|
| Test mock library | mockito | Project already has build_runner infra, more feature-rich for complex mocking | Yes |
| Plugin demo type | LocalFilePlugin (数据源插件) | Minimal risk, demonstrates real value, doesn't touch existing B站 code | Reversible in design |
| Test target first | Repository layer | User chose unit tests first; Repository layer has clean boundaries for mocking | Yes |
| Ordering | A→B→C→D sequential | User chose this; each builds on the previous | Yes |

## Findings (cited - path:lines)
- core LoadingState has toast() (lib/core/result/loading_state.dart:21) — identical to bili's
- Only diffs: bili has @immutable on Success/Error (lib/adapters/bilibili/http/loading_state.dart:33,53)
- 169 files still import bili's loading_state (all HTTP/gRPC service files + repo wrappers)
- ValidateHttp: 2 methods, 1 caller in request_utils.dart (lib/adapters/bilibili/http/validate.dart)
- No test files exist; test* is gitignored (line 152); flutter_test in dev_deps
- Plugin infra: zero; service_registry.dart is @Deprecated (lib/core/di/service_registry.dart)

## Decisions (with rationale)
1. A (LoadingState) first — smallest, most mechanical, fixed dependencies for B's tests
2. mockito over mocktail — build_runner infra already exists for .g.dart generation
3. LocalFilePlugin as demo — provides real, verifiable value without risking existing code
4. Unit tests on Repository layer first — clean mock boundaries, tests validate DI wiring

## Scope IN
- A: One LoadingState class in core; delete bili copy; add @immutable; update all imports
- B: .gitignore change; add mockito/mockito_annotation/build_runner deps; unit tests for 2-3 representative repositories
- C: ValidateRepository interface (core) + BiliValidateRepository (bili adapter) + Bridge registration + caller update
- D: Plugin interface (core) + PluginRegistry (core) + LocalFilePlugin (new dir) + player integration demo

## Scope OUT (Must NOT have)
- ❌ No widget/integration tests in this SPES (unit only)
- ❌ No plugin marketplace or dynamic loading (just interface + 1 demo)
- ❌ No changes to existing B站 adapter code (plugins are additive)
- ❌ No changes to video player internals (only plugin integration point)

## Open questions
None — all forks resolved via interview.

## Approval gate
status: awaiting-approval
