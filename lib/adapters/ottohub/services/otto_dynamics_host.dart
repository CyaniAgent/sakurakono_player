import 'package:flutter/material.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/models/search_types.dart' show CoreDimension;
import 'package:skf/pages/dynamics/dynamics_host.dart';

/// OttoHub stub for [DynamicsHost].
///
/// OttoHub has no dynamics-page UI of its own (test-only adapter); the
/// Bilibili pages are not reused here. All deep interactions degrade to
/// no-op / placeholder (defensive degradation, no exceptions thrown).
class OttoDynamicsHost implements DynamicsHost {

  @override
  Widget buildTabPage(CoreDynamicsTabType type) => const SizedBox.shrink();

  @override
  void showCreateDynPanel(BuildContext context) {}

  @override
  bool get isMainDynamicsTab => false;

  @override
  int get currentUserId => -1;

  @override
  Future<void> reloadTab(CoreDynamicsTabType type) async {}

  @override
  Future<void> refreshTab(CoreDynamicsTabType type) async {}

  @override
  void animateTabToTop(CoreDynamicsTabType type) {}

  @override
  bool tabHasScrollClients(CoreDynamicsTabType type) => false;

  @override
  double tabScrollPixels(CoreDynamicsTabType type) => 0;

  @override
  void tabAnimToTop(CoreDynamicsTabType type) {}

  @override
  Future<void> pushDynDetail(
    CoreDynamicItemModel item, {
    bool isPush = false,
    bool viewComment = false,
  }) async {}

  @override
  bool viewPgcFromUri(String uri) => false;

  @override
  void toVideoPage({String? bvid, int? cid, CoreDimension? dimension}) {}

  @override
  void openLiveFollowPage() {}

  @override
  void toLiveRoom(int? roomId) {}

  @override
  void handleWebview(
    String url, {
    bool off = false,
    bool inApp = false,
    Map? parameters,
  }) {
  }

  @override
  void showSavePanel({dynamic upMid, dynamic item}) {}

  @override
  void pmShare(BuildContext context, {required Map content}) {}

  @override
  void checkCreatedDyn({dynamic id, bool isManual = false}) {}

  @override
  void showReportDialog(
    BuildContext context, {
    required int mid,
    required String dynId,
  }) {
  }

  @override
  Future<void> showReplyInteractionDialog(
    BuildContext context, {
    required String oid,
    required int type,
    required ValueChanged<int> onSetReplySubject,
  }) async {}

  @override
  void showRepostPanel(
    BuildContext context,
    CoreDynamicItemModel item,
    VoidCallback onSuccess,
  ) {
  }

  @override
  void showImageSaveDialog({String? title, String? cover, String? bvid}) {}

  @override
  Widget buildBlockedItem(
    BuildContext context,
    ThemeData theme,
    CoreModuleBlocked blocked,
  ) =>
      const SizedBox.shrink();
}
