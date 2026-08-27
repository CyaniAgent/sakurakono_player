# lib/pages — Adapter-agnostic UI framework

Child of root AGENTS.md. Shared page framework + domain pages consumed by ALL adapters. Root rules (lints, package:skf imports) apply.

## Overview

160 Dart files, 20 dirs. Adapter-agnostic UI: pages live here, adapters supply behavior via Host interfaces. **Zero `package:skf/adapters/` imports (verified)** — pages never reference adapter types.

## Host interface pattern (核心解耦机制)

- 7 abstract interfaces define adapter-dependent behavior; pages resolve them at runtime via `Get.find<T>()` (GetX, partially converted to Riverpod `ref.read`) or Riverpod providers:

| Interface | Interface file | Bili impl (bilibili/common/) | Otto impl (ottohub/services/) |
|---|---|---|---|
| MainHost | main/main_host.dart | main_host.dart | otto_main_host.dart |
| VideoHost | video/video_host.dart | video_host.dart | otto_video_host.dart |
| MemberHost | member/member_host.dart | member_host.dart | otto_member_host.dart |
| SettingHost | setting/setting_host.dart | setting_host.dart | otto_setting_host.dart |
| DynamicsHost | dynamics/dynamics_host.dart | dynamics_host.dart | otto_dynamics_host.dart |
| MineActions | mine/mine_actions.dart | mine_actions.dart | otto_mine_actions.dart |
| DownloadActions | download/download_actions.dart | download_actions.dart | otto_download_actions.dart |

- Pages depend on the interface ONLY — never on Bili*/Otto* types or `package:skf/adapters/`.

## Layout (20 dirs)

- common/ 14: shared page infra — common_controller.dart (CommonController<R,T> extends ChangeNotifier with ScrollOrRefreshMixin, migrated from GetxController), common_page.dart (CommonPageState), common_list_controller, common_data_controller, fab_mixin, cover_ratio, bar_hide_type, msg_unread_type, dynamic_badge_mode + multi_select/, search/, slide/ subdirs.
- Domain dirs: video 6, main 4, home 3, member 9, mine 5, dynamics 21, download 9 (+ detail/, downloading/, search/), setting 20, fav 22, follow 8, follow_tag_sort 1, follow_type 7, history 5, later 7, blacklist 2, fan 2, msg_feed_top 8, search 5, search_result 2.

## Patterns

- One dir per page → view.dart + controller.dart (+ optional widgets/, models/) — same shape as bilibili/pages/.
- Controllers: Obx and .obs eliminated (0 remaining). Get.find partially converted to `ref.read` (~157 remaining across 62 files). New controllers extend ChangeNotifier + notifyListeners.
- Data access via core repository interfaces (Riverpod providers or Get.find fallback) — never direct HTTP.

## Migration status (2026-08)

- Migrated from lib/adapters/bilibili/pages/ to lib/pages/: dynamics, member, mine, download, video, main, home, setting (8 domains).
- Remaining B站-exclusive pages stay in lib/adapters/bilibili/pages/ (313 files) — see lib/adapters/bilibili/AGENTS.md.

## Where to look

| Task | Location |
|---|---|
| New shared page | pages/<domain>/{view,controller}.dart |
| New adapter-dependent behavior | extend/add a Host interface here + implement in each adapter's common/services dir |
| Shared controller infra | pages/common/ |