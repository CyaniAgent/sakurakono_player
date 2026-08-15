import 'package:flutter/material.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/models/search_types.dart' show CoreDimension;
import 'package:skf/pages/dynamics/dynamics_host.dart';

/// OttoHub stub for [DynamicsHost].
///
/// OttoHub has no dynamics-page UI of its own (test-only adapter); the
/// Bilibili pages are not reused here. All deep interactions throw
/// `not_implemented` (crash-prevention, consistent with OttoHub stubs).
class OttoDynamicsHost implements DynamicsHost {
  Never _err() => throw UnimplementedError('not_implemented');

  @override
  Widget buildTabPage(CoreDynamicsTabType type) => _err();

  @override
  void showCreateDynPanel(BuildContext context) => _err();

  @override
  bool get isMainDynamicsTab => false;

  @override
  int get currentUserId => -1;

  @override
  Future<void> reloadTab(CoreDynamicsTabType type) => _err();

  @override
  Future<void> refreshTab(CoreDynamicsTabType type) => _err();

  @override
  void animateTabToTop(CoreDynamicsTabType type) => _err();

  @override
  bool tabHasScrollClients(CoreDynamicsTabType type) => false;

  @override
  double tabScrollPixels(CoreDynamicsTabType type) => 0;

  @override
  void tabAnimToTop(CoreDynamicsTabType type) => _err();

  @override
  Future<void> pushDynDetail(
    CoreDynamicItemModel item, {
    bool isPush = false,
    bool viewComment = false,
  }) =>
      _err();

  @override
  bool viewPgcFromUri(String uri) => false;

  @override
  void toVideoPage({String? bvid, int? cid, CoreDimension? dimension}) =>
      _err();

  @override
  void openLiveFollowPage() => _err();

  @override
  void toLiveRoom(int? roomId) => _err();

  @override
  void handleWebview(
    String url, {
    bool off = false,
    bool inApp = false,
    Map? parameters,
  }) =>
      _err();

  @override
  void showSavePanel({dynamic upMid, dynamic item}) => _err();

  @override
  void pmShare(BuildContext context, {required Map content}) => _err();

  @override
  void checkCreatedDyn({dynamic id, bool isManual = false}) => _err();

  @override
  void showReportDialog(
    BuildContext context, {
    required int mid,
    required String dynId,
  }) =>
      _err();

  @override
  Future<void> showReplyInteractionDialog(
    BuildContext context, {
    required String oid,
    required int type,
    required ValueChanged<int> onSetReplySubject,
  }) =>
      _err();

  @override
  void showRepostPanel(
    BuildContext context,
    CoreDynamicItemModel item,
    VoidCallback onSuccess,
  ) =>
      _err();

  @override
  void showImageSaveDialog({String? title, String? cover, String? bvid}) =>
      _err();

  @override
  Widget buildBlockedItem(
    BuildContext context,
    ThemeData theme,
    CoreModuleBlocked blocked,
  ) =>
      _err();
}
