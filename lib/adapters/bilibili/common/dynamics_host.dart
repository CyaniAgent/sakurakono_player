import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/common/widgets/dialog/report.dart';
import 'package:skf/adapters/bilibili/common/widgets/image/image_save.dart';
import 'package:skf/adapters/bilibili/http/reply.dart';
import 'package:skf/adapters/bilibili/http/user.dart';
import 'package:skf/adapters/bilibili/http/video.dart';
import 'package:skf/pages/main/main_host.dart';
import 'package:skf/adapters/bilibili/pages/article/widgets/opus_content.dart'
    show moduleBlockedItem;
import 'package:skf/adapters/bilibili/pages/dynamics_create/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_repost/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_tab/controller.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_tab/view.dart';
import 'package:skf/adapters/bilibili/pages/live_follow/view.dart';
import 'package:skf/pages/main/controller.dart';
import 'package:skf/adapters/bilibili/pages/save_panel/view.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';
import 'package:skf/adapters/bilibili/utils/request_utils.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/models/search_types.dart' show CoreDimension;
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/dynamics/dynamics_host.dart';
import 'package:skf/utils/extension/scroll_controller_ext.dart';

/// Bilibili implementation of [DynamicsHost].
///
/// Bridges the generic dynamics page to B站-specific pages/APIs:
/// tab sub-pages, create-dynamic panel, deep URL routing, report dialogs.
class BiliDynamicsHost implements DynamicsHost {
  DynamicsTabController? _tab(CoreDynamicsTabType type) {
    try {
      return Get.find<DynamicsTabController>(tag: type.name);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget buildTabPage(CoreDynamicsTabType type) =>
      DynamicsTabPage(dynamicsType: type);

  @override
  void showCreateDynPanel(BuildContext context) =>
      CreateDynPanel.onCreateDyn(context);

  @override
  bool get isMainDynamicsTab {
    final mainController = Get.find<MainControllerNotifier>();
    return mainController.navigationBars.first.id != MainTabIds.dynamics &&
        mainController.selectedIndex.value == 0;
  }

  @override
  int get currentUserId => Accounts.main.mid;

  @override
  Future<void> reloadTab(CoreDynamicsTabType type) =>
      _tab(type)?.onReload() ?? Future.value();

  @override
  Future<void> refreshTab(CoreDynamicsTabType type) =>
      _tab(type)?.onRefresh() ?? Future.value();

  @override
  void animateTabToTop(CoreDynamicsTabType type) => _tab(type)?.animateToTop();

  @override
  bool tabHasScrollClients(CoreDynamicsTabType type) =>
      _tab(type)?.scrollController.hasClients ?? false;

  @override
  double tabScrollPixels(CoreDynamicsTabType type) =>
      _tab(type)?.scrollController.position.pixels ?? 0;

  @override
  void tabAnimToTop(CoreDynamicsTabType type) =>
      _tab(type)?.scrollController.animToTop();

  @override
  Future<void> pushDynDetail(
    CoreDynamicItemModel item, {
    bool isPush = false,
    bool viewComment = false,
  }) =>
      PageUtils.pushDynDetail(item, isPush: isPush, viewComment: viewComment);

  @override
  bool viewPgcFromUri(String uri) => PageUtils.viewPgcFromUri(uri);

  @override
  void toVideoPage({String? bvid, int? cid, CoreDimension? dimension}) {
    PageUtils.toVideoPage(
      bvid: bvid,
      cid: cid!,
      dimension: ModelConverters.dimension(dimension),
    );
  }

  @override
  void openLiveFollowPage() => Get.to(const LiveFollowPage());

  @override
  void toLiveRoom(int? roomId) => PageUtils.toLiveRoom(roomId);

  @override
  void handleWebview(
    String url, {
    bool off = false,
    bool inApp = false,
    Map? parameters,
  }) =>
      PageUtils.handleWebview(url, off: off, inApp: inApp, parameters: parameters);

  @override
  void openLotteryResult(String businessId) {
    Get.toNamed(
      '/webview',
      parameters: {
        'url':
            'https://www.bilibili.com/h5/lottery/result?business_id=$businessId',
      },
    );
  }

  @override
  void showSavePanel({dynamic upMid, dynamic item}) =>
      SavePanel.toSavePanel(upMid: upMid, item: item);

  @override
  void pmShare(BuildContext context, {required Map content}) =>
      PageUtils.pmShare(context, content: content);

  @override
  String? buildDynamicsShareUrl(String dynId) => 'https://t.bilibili.com/$dynId';

  @override
  void checkCreatedDyn({dynamic id, bool isManual = false}) =>
      RequestUtils.checkCreatedDyn(id: id, isManual: isManual);

  @override
  void showReportDialog(
    BuildContext context, {
    required int mid,
    required String dynId,
  }) =>
      autoWrapReportDialog(
        context,
        ReportOptions.dynamicReport,
        (reasonType, reasonDesc, banUid) {
          if (banUid) {
            VideoHttp.relationMod(mid: mid, act: 5, reSrc: 11);
          }
          return UserHttp.dynamicReport(
            mid: mid,
            dynId: dynId,
            reasonType: reasonType,
            reasonDesc: reasonType == 0 ? reasonDesc : null,
          );
        },
      );

  @override
  Future<void> showReplyInteractionDialog(
    BuildContext context, {
    required String oid,
    required int type,
    required ValueChanged<int> onSetReplySubject,
  }) async {
    final res = await ReplyHttp.replyInteraction(oid: oid, type: type);
    if (res case Success(:final response)) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            final selection = response.upReplySelection;
            final enableSelection = selection.status == 1;
            final reply = response.upReply;
            final enableReply = reply.status == 1;
            return SimpleDialog(
              clipBehavior: Clip.hardEdge,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                ListTile(
                  dense: true,
                  enabled: selection.canModify,
                  title: Text(
                    '${enableSelection ? '停止' : '开启'}评论精选',
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    Get.back();
                    onSetReplySubject(enableSelection ? 2 : 1);
                  },
                ),
                ListTile(
                  dense: true,
                  enabled: reply.canModify,
                  title: Text(
                    '${enableReply ? '关闭' : '恢复'}评论',
                    style: const TextStyle(fontSize: 14),
                  ),
                  onTap: () {
                    Get.back();
                    onSetReplySubject(enableReply ? 3 : 4);
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      res.toast();
    }
  }

  @override
  void showRepostPanel(
    BuildContext context,
    CoreDynamicItemModel item,
    VoidCallback onSuccess,
  ) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => RepostPanel(
          item: item,
          onSuccess: onSuccess,
        ),
      );

  @override
  void showImageSaveDialog({String? title, String? cover, String? bvid}) =>
      imageSaveDialog(title: title, cover: cover, bvid: bvid);

  @override
  Widget buildBlockedItem(
    BuildContext context,
    ThemeData theme,
    CoreModuleBlocked blocked,
  ) =>
      moduleBlockedItem(context, theme, ModelConverters.blockedModule(blocked));
}
