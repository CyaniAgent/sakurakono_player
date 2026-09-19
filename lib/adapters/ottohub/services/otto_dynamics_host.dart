import 'package:flutter/material.dart';

import 'package:skf/adapters/ottohub/services/otto_dynamics_pages.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/models/search_types.dart' show CoreDimension;
import 'package:skf/pages/dynamics/dynamics_host.dart';
import 'package:skf/router/app_navigator.dart';

/// OttoHub 动态页宿主实现。
///
/// OttoHub 的「动态」内容形态为博客:全部/专栏 tab 展示站内最新博客
/// (经 ottoBlogRepositoryProvider),其余 tab(投稿/番剧/UP)无对应
/// 内容形态,显示占位。B站 专属交互(转发/抽奖/直播等)降级 no-op。
class OttoDynamicsHost implements DynamicsHost {

  @override
  Widget buildTabPage(CoreDynamicsTabType type) =>
      OttoDynamicsTabPage(type: type);

  @override
  void showCreateDynPanel(BuildContext context) {}

  @override
  bool get isMainDynamicsTab => false;

  @override
  int get currentUserId => appRead(accountProvider).userId ?? -1;

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
  void toVideoPage({String? bvid, int? cid, CoreDimension? dimension}) {
    final vid = int.tryParse(bvid ?? '');
    if (vid != null && vid > 0) {
      AppNavigator.toNamed(
        '/videoV',
        preventDuplicates: false,
        arguments: <String, dynamic>{
          'aid': vid,
          'bvid': '$vid',
          'cid': vid,
          'heroTag': '$vid-${DateTime.now().millisecondsSinceEpoch}',
        },
      );
    }
  }

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
    AppNavigator.toNamed(
      '/webview',
      parameters: {'url': url},
    );
  }

  @override
  void openLotteryResult(String businessId) {}

  @override
  void showSavePanel({dynamic upMid, dynamic item}) {}


  @override
  void pmShare(BuildContext context, {required Map content}) {}

  @override
  String? buildDynamicsShareUrl(String dynId) => null;

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
