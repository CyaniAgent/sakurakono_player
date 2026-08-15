import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/member_types.dart';

/// Adapter-provided integrations for the generic member page.
///
/// The member page is generic (core models + core repositories), but parts of
/// it reach into adapter-only territory:
/// - member sub-pages (home/contribute/favorite/bangumi/cheese/shop tabs)
/// - account-aware follow/block actions and share links (Bilibili: [Accounts])
/// - tab policy (which server tabs are supported, preferred default tab)
/// - B站-only dialogs (report, live medal wall, login devices/logs, shortcut)
/// - deep URL routing ([pushFromUri], [handleWebview], [pushDynFromId])
///
/// Each adapter registers its own implementation via Get (`Get.lazyPut`).
/// OttoHub registers a stub that throws `not_implemented`.
abstract class MemberHost {
  static MemberHost of() => Get.find<MemberHost>();

  /// Current user id (Bilibili: `Accounts.main.mid`).
  int get currentUserId;

  // ---- tab policy (controller) ----

  /// Filter the server-provided tab list to the ones this adapter renders
  /// (Bilibili: [MemberTabType] filter + shop flag).
  List<CoreSpaceTab2> filterTabs(List<CoreSpaceTab2> tabs);

  /// Tab param preferred by the user setting, or null when unset
  /// (Bilibili: `Pref.memberTab` mapped to [MemberTabType]).
  String? get preferredTabParam;

  // ---- page composition (top-level view) ----

  /// Build the sub-page widget for a space tab [param] (Bilibili:
  /// `MemberHome`/`MemberContribute`/`MemberFavorite`/...).
  Widget buildTab({
    required String param,
    String? title,
    required String heroTag,
    required int mid,
    required RxInt contributeInitialIndex,
  });

  /// Whether the "网页投稿" menu item is available (Bilibili: a
  /// [MemberContributeCtr] is registered for [heroTag]).
  bool canToWebArchive(String heroTag);

  /// Open the web-archive page (Bilibili: `MemberSSWeb`/`MemberVideoWeb`).
  void toWebArchive({
    required String heroTag,
    required int mid,
    required String username,
  });

  // ---- follow / block ----

  /// Follow/unfollow with confirmation feedback (Bilibili:
  /// `RequestUtils.actionRelationMod`).
  void actionRelationMod(
    BuildContext context, {
    required int mid,
    required bool isFollow,
    required ValueChanged<int> afterMod,
  });
  void shareUser(int mid);
  // ---- actions (menu) ----

  /// Push the login devices page (Bilibili: `CoreLoginDevicesPage`).
  void openLoginDevices();

  /// Push the login log page (Bilibili: `LogPage` + `LoginLogController`).
  void openLoginLog();

  /// Push the coin log page (Bilibili: `LogPage` + `CoinLogController`).
  void openCoinLog();

  /// Push the exp log page (Bilibili: `LogPage` + `ExpLogController`).
  void openExpLog();

  /// Show the report dialog (Bilibili: `showMemberReportDialog`).
  void showReportDialog(
    BuildContext context, {
    required String? name,
    required int mid,
  });

  /// Show the live medal wall dialog (Bilibili: [MedalWall] + live medal API).
  Future<void> showLiveMedalWall(int mid);

  /// Create a home-screen shortcut (Bilibili: `PiliAndroidHelper.createShortcut`
  /// + `bilibili://space/` scheme).
  void createShortcut({
    required int mid,
    required String name,
    required String avatar,
  });

  // ---- deep navigation ----

  /// Push a dynamic detail page by id (Bilibili: `PageUtils.pushDynFromId`).
  void pushDynFromId(String? id);

  /// Handle a webview URL (Bilibili: `PageUtils.handleWebview`).
  void handleWebview(String url);

  /// Route a deep link URI (Bilibili: `PiliScheme.routePushFromUrl`).
  void pushFromUri(String uri);

  /// Push the member guard page (Bilibili: `MemberGuard.toMemberGuard`).
  void openMemberGuard({
    required int mid,
    required String name,
    required Object? count,
  });

  /// Push the upower rank page (Bilibili: `UpowerRankPage.toUpowerRank`).
  void openUpowerRank({
    required int mid,
    required String name,
    required Object? count,
  });
}
