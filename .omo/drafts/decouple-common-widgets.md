---
slug: decouple-common-widgets
status: awaiting-approval
intent: clear
review_required: false
pending-action: write .omo/plans/decouple-common-widgets.md
approach: Move 4 UI enum families + theme extension to lib/core/; extract 2 part-of files; injectify vertical_tabs.dart
---

# Draft: decouple-common-widgets

## Components (topology ledger)
| id | outcome | status | evidence path |
|----|---------|--------|---------------|
| C1: UI enum migration | ImageType, PBadgeType/SourceType/SourceModel, StatType moved to lib/core/models/ui/; all adapter + common/ imports updated | active | explorer bg_723b3160: all 4 types have zero B站 deps |
| C2: Theme extension migration | ColorSchemeExt (isDark/isLight) moved to lib/utils/; 3 common/ imports updated | active | explorer bg_4d745e4f: 3 shallow imports |
| C3: Part-of extraction | dyn_menu_helper.dart + reply_menu_helper.dart extracted from `part of` to standalone files | active | explorer bg_4d745e4f: 2 files with `part of` |
| C4: Vertical tabs decouple | Get.find<MainController>() replaced with callback parameter | active | explorer bg_4d745e4f: deep coupling in Flutter fork |
| C5: BadgeType parameterization | Core defines generic BadgeType, B站 adapter maps via param (deferred to future) | deferred | User choice: 参数化 strategy |

## Open assumptions (announced defaults)
| assumption | adopted default | rationale | reversible? |
|-----------|----------------|-----------|-------------|
| Scope depth | 基础层 (C1-C4) — covers 16/23 imports | 最后 30% 在 PageUtils/BiliImageUtils 本质是 B站 功能，边际收益递减 | Yes — can revisit |
| Incomplete DI in repo interfaces | NOT addressed | Repository interfaces (24 files) all return B站 model types — this is a larger architectural issue beyond common/ scope | N/A |
| StatType labels | Chinese labels moved as-is to core; parameterized for future i18n | Labels are data, not code; no B站 API refs | Yes — i18n later |
| Test strategy | tests-after — existing test infra (mockito) reused | Widget decoupling tests verify no import breakage | N/A |

## Findings (cited - path:lines)
- 23 B站 imports across 15 lib/common/ files (explorer bg_4d745e4f)
- 4 types have zero B站 deps: ImageType, PBadgeType/PBadgeSize, SourceType/SourceModel, StatType (explorer bg_723b3160)
- BadgeType (avatar/vip/person) references BiliColors — B站-specific (bg_723b3160)
- 2 files are `part of` adapter files: dyn_menu_helper.dart, reply_menu_helper.dart (bg_4d745e4f)
- vertical_tabs.dart has `Get.find<MainController>()` hardcoded, is 2404-line Flutter SDK fork (bg_4d745e4f)
- All 24 repository interfaces return B站 model types in signatures — incomplete DI (bg_a5637247)
- lib/core/models/ exists with 4 files: audio_quality, media_id, resolution, video_quality (bg_a5637247)

## Decisions (with rationale)
1. **基础层 scope** — 边际收益递减：PageUtils 819 行深度 B站 耦合，强行抽象得不偿失
2. **参数化 BadgeType** — core 定义通用形状(颜色+值)，B站 适配器端映射实体
3. **搬入非别名** — 类型搬入 core 目录，adapter 端改 import 路径，不改类型名（减少 churn）

## Scope IN
- C1: 4 UI enum families → lib/core/models/ui/
- C2: ColorSchemeExt → lib/utils/
- C3: 2 part-of files → standalone
- C4: vertical_tabs.dart MainController → callback

## Scope OUT (Must NOT have)
- ❌ PageUtils/BiliImageUtils 解耦 — B站 功能，留在 adapter
- ❌ pendant_avatar BadgeType 解耦 — deferred
- ❌ Repository 接口签名清理 — 独立的大项目
- ❌ widget/integration 测试

## Resolved design forks (Metis post-hoc)
| Fork | Decision | Rationale |
|------|----------|-----------|
| Two SourceType enums | Move image_preview_types's SourceType as-is to core; different import paths prevent collision | video/source_type.dart is a separate B站-gRPC type in different path |
| ColorSchemeExt split | Move isDark/isLight/freeColor; keep vipColor/blue/btnColor in adapter | Those 3 reference BiliColors |
| C3 post-extraction status | Extract file structure only; content stays B站-coupled | These are adapter helper files, not core; extraction is just to remove `part of` anti-pattern |

## Open questions
- None resolved via adopted defaults

## Approval gate
status: approved
pending-action: write .omo/plans/decouple-common-widgets.md
