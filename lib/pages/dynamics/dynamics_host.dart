import 'package:flutter/material.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/models/search_types.dart' show CoreDimension;
import 'package:skf/pages/providers.dart';

/// Adapter-provided integrations for the generic dynamics page.
///
/// The dynamics page is generic (core models + core repositories), but some
/// of its widgets reach into adapter-only territory:
/// - tab sub-pages and their controllers (Bilibili: [DynamicsTabPage])
/// - the "create dynamic" panel (Bilibili: [CreateDynPanel])
/// - the main scaffold state (Bilibili: [MainController])
/// - deep URL routing ([pushDynDetail], [toVideoPage], ...)
/// - B站-only dialogs (report, reply interaction, save panel, image save)
///
/// Each adapter registers its own implementation via Get (`Get.lazyPut`).
/// OttoHub registers a stub that throws `not_implemented`.
abstract class DynamicsHost {
  static DynamicsHost of() => appRead(dynamicsHostProvider);

  // ---- page composition (top-level view) ----

  /// Build the tab page widget for [type] (Bilibili: `DynamicsTabPage`).
  Widget buildTabPage(CoreDynamicsTabType type);

  /// Show the "create dynamic" bottom sheet (Bilibili: `CreateDynPanel`).
  void showCreateDynPanel(BuildContext context);

  /// Whether the main scaffold considers the dynamics tab active.
  /// Bilibili: `MainController.navigationBars[0] != .dynamics && selectedIndex == 0`.
  bool get isMainDynamicsTab;

  /// Current user id (Bilibili: `Accounts.main.mid`).
  int get currentUserId;

  // ---- tab coordination (top-level controller) ----

  /// Reload the tab controller for [type] (Bilibili: `DynamicsTabController.onReload`).
  Future<void> reloadTab(CoreDynamicsTabType type);

  /// Refresh the tab controller for [type] (Bilibili: `DynamicsTabController.onRefresh`).
  Future<void> refreshTab(CoreDynamicsTabType type);

  /// Animate the tab controller for [type] to top.
  void animateTabToTop(CoreDynamicsTabType type);

  /// Whether the tab controller for [type] has scroll clients.
  bool tabHasScrollClients(CoreDynamicsTabType type);

  /// Scroll pixels of the tab controller for [type].
  double tabScrollPixels(CoreDynamicsTabType type);

  /// Animate the tab scroll controller for [type] to top.
  void tabAnimToTop(CoreDynamicsTabType type);

  // ---- navigation ----

  /// Push the dynamic detail page for [item] with B站-style routing
  /// (Bilibili: `PageUtils.pushDynDetail`).
  Future<void> pushDynDetail(
    CoreDynamicItemModel item, {
    bool isPush = false,
    bool viewComment = false,
  });

  /// Parse an `ep`/`ss` URI and push the PGC page; returns whether handled.
  /// (Bilibili: `PageUtils.viewPgcFromUri`).
  bool viewPgcFromUri(String uri);

  /// Push the video page (Bilibili: `PageUtils.toVideoPage`).
  void toVideoPage({
    String? bvid,
    int? cid,
    CoreDimension? dimension,
  });

  /// Open the live-follow page (Bilibili: `LiveFollowPage`).
  void openLiveFollowPage();

  /// Push the live room page (Bilibili: `PageUtils.toLiveRoom`).
  void toLiveRoom(int? roomId);

  /// Handle a webview URL (Bilibili: `PageUtils.handleWebview`).
  void handleWebview(
    String url, {
    bool off = false,
    bool inApp = false,
    Map? parameters,
  });

  /// Open the lottery result page for a dynamic (Bilibili: h5 webview page).
  void openLotteryResult(String businessId);

  // ---- deep actions (author panel) ----

  /// Show the save panel for a dynamic item (Bilibili: `SavePanel.toSavePanel`).
  void showSavePanel({dynamic upMid, dynamic item});

  /// Share content to a message (Bilibili: `PageUtils.pmShare`).
  void pmShare(BuildContext context, {required Map content});

  /// Build the shareable web link for a dynamic, or null if the adapter has
  /// no web share-link concept (Bilibili: dynamic share link).
  String? buildDynamicsShareUrl(String dynId);

  /// Anti-fraud check for a created dynamic (Bilibili: `RequestUtils.checkCreatedDyn`).
  void checkCreatedDyn({dynamic id, bool isManual = false});

  /// Report dialog for a dynamic (Bilibili: `autoWrapReportDialog` + report flow).
  void showReportDialog(BuildContext context, {required int mid, required String dynId});

  /// Reply interaction settings dialog (Bilibili: `ReplyHttp.replyInteraction`).
  Future<void> showReplyInteractionDialog(
    BuildContext context, {
    required String oid,
    required int type,
    required ValueChanged<int> onSetReplySubject,
  });

  // ---- deep widgets ----

  /// Repost bottom sheet (Bilibili: `RepostPanel`).
  void showRepostPanel(
    BuildContext context,
    CoreDynamicItemModel item,
    VoidCallback onSuccess,
  );

  /// Image save dialog (Bilibili: `imageSaveDialog`).
  void showImageSaveDialog({String? title, String? cover, String? bvid});

  /// Blocked module widget (Bilibili: `moduleBlockedItem` in article page).
  Widget buildBlockedItem(
    BuildContext context,
    ThemeData theme,
    CoreModuleBlocked blocked,
  );
}
