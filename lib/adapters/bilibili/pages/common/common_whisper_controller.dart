import 'package:skf/adapters/bilibili/grpc/bilibili/app/im/v1.pb.dart' show Session;
import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/repository/im_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:get/get.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

abstract class CommonWhisperController<R>
    extends CommonListController<R, Session> {
  CoreImSessionPageType get sessionPageType;

  Future<void> onRemove(int index, int talkerId) async {
    final res = await Get.find<MsgRepository>().removeMsg(talkerId);
    if (res.isSuccess) {
      loadingState
        ..value.data!.removeAt(index)
        ..refresh();
      SmartDialog.showToast('删除成功');
    } else {
      res.toast();
    }
  }

  Future<void> onSetTop(
    Session item,
    int index,
    bool isTop,
    CoreImSessionId sessionId,
  ) async {
    final res = isTop
        ? await Get.find<ImRepository>().unpinSession(sessionId: sessionId)
        : await Get.find<ImRepository>().pinSession(sessionId: sessionId);

    if (res.isSuccess) {
      List<Session> list = loadingState.value.data!;
      item.isPinned = isTop ? false : true;
      if (!isTop) {
        list.insert(0, list.removeAt(index));
      }
      loadingState.refresh();
      SmartDialog.showToast('${isTop ? '移除' : ''}置顶成功');
    } else {
      res.toast();
    }
  }

  Future<void> onSetMute(Session item, bool isMuted, int talkerUid) async {
    final res = await Get.find<MsgRepository>().setMsgDnd(
      uid: Accounts.main.mid,
      setting: isMuted ? 0 : 1,
      dndUid: talkerUid,
    );
    if (res.isSuccess) {
      item.isMuted = !isMuted;
      loadingState.refresh();
      SmartDialog.showToast('设置成功');
    } else {
      res.toast();
    }
  }

  Future<void> onClearUnread() async {
    final res = await Get.find<ImRepository>().clearUnread(pageType: sessionPageType);
    if (res.isSuccess) {
      if (loadingState.value case Success(:final response)) {
        if (response != null && response.isNotEmpty) {
          for (final item in response) {
            if (item.hasUnread()) {
              item.clearUnread();
            }
          }
          loadingState.refresh();
        }
      }
      SmartDialog.showToast('已标记为已读');
    } else {
      res.toast();
    }
  }

  Future<void> onDeleteList() async {
    final res = await Get.find<ImRepository>().deleteSessionList(pageType: sessionPageType);
    if (res.isSuccess) {
      loadingState.value = const Success(null);
    } else {
      res.toast();
    }
  }
}