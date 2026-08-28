import 'package:skf/adapters/bilibili/grpc/bilibili/app/im/v1.pb.dart' show Session;
import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:skf/core/container/app_container.dart';

abstract class CommonWhisperController<R>
    extends CommonListControllerRiverpod<R, Session> {
  CoreImSessionPageType get sessionPageType;

  Future<void> onRemove(int index, int talkerId) async {
    final res = await (appRead(msgRepositoryProvider)).removeMsg(talkerId);
    if (res.isSuccess) {
      loadingState.data!.removeAt(index);
      notifyListeners();
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
        ? await (appRead(imRepositoryProvider)).unpinSession(sessionId: sessionId)
        : await (appRead(imRepositoryProvider)).pinSession(sessionId: sessionId);

    if (res.isSuccess) {
      List<Session> list = loadingState.data!;
      item.isPinned = isTop ? false : true;
      if (!isTop) {
        list.insert(0, list.removeAt(index));
      }
      notifyListeners();
      SmartDialog.showToast('${isTop ? '移除' : ''}置顶成功');
    } else {
      res.toast();
    }
  }

  Future<void> onSetMute(Session item, bool isMuted, int talkerUid) async {
    final res = await (appRead(msgRepositoryProvider)).setMsgDnd(
      uid: Accounts.main.mid,
      setting: isMuted ? 0 : 1,
      dndUid: talkerUid,
    );
    if (res.isSuccess) {
      item.isMuted = !isMuted;
      notifyListeners();
      SmartDialog.showToast('设置成功');
    } else {
      res.toast();
    }
  }

  Future<void> onClearUnread() async {
    final res = await (appRead(imRepositoryProvider)).clearUnread(pageType: sessionPageType);
    if (res.isSuccess) {
      if (loadingState case Success(:final response)) {
        if (response != null && response.isNotEmpty) {
          for (final item in response) {
            if (item.hasUnread()) {
              item.clearUnread();
            }
          }
          notifyListeners();
        }
      }
      SmartDialog.showToast('已标记为已读');
    } else {
      res.toast();
    }
  }

  Future<void> onDeleteList() async {
    final res = await (appRead(imRepositoryProvider)).deleteSessionList(pageType: sessionPageType);
    if (res.isSuccess) {
      loadingState = const Success(null);
    } else {
      res.toast();
    }
  }
}