import 'package:skf/adapters/bilibili/grpc/bilibili/app/im/v1.pb.dart'
    show Offset, Session, SessionMainReply, ThreeDotItem;
import 'package:skf/adapters/bilibili/grpc/im.dart' show ImGrpc;
import 'package:protobuf/protobuf.dart' show PbMap;
import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/core/repository/im_repository.dart';
import 'package:skf/core/result/loading_state.dart';

import 'package:skf/adapters/bilibili/pages/common/common_whisper_controller.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';

class WhisperController extends CommonWhisperController<SessionMainReply> {

  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  @override
  CoreImSessionPageType sessionPageType = CoreImSessionPageType.home;

  late final List<({bool enabled, IconData icon, String name, String route})>
  msgFeedTopItems;
  late final RxList<int> unreadCounts;

  PbMap<int, Offset>? offset;

  Rx<List<ThreeDotItem>?> threeDotItems = Rx<List<ThreeDotItem>?>(null);
  Rx<List<ThreeDotItem>?> outsideItem = Rx<List<ThreeDotItem>?>(null);

  @override
  void onInit() {
    super.onInit();
    msgFeedTopItems = [
      const (
        name: "回复我的",
        icon: Icons.message_outlined,
        route: "/replyMe",
        enabled: true,
      ),
      const (
        name: "@我",
        icon: Icons.alternate_email_outlined,
        route: "/atMe",
        enabled: true,
      ),
      (
        name: "收到的赞",
        icon: Icons.favorite_border_outlined,
        route: "/likeMe",
        enabled: !Pref.disableLikeMsg,
      ),
      const (
        name: "系统通知",
        icon: Icons.notifications_none_outlined,
        route: "/sysMsg",
        enabled: true,
      ),
    ];
    unreadCounts = List.filled(msgFeedTopItems.length, 0).obs;
    queryMsgFeedUnread();
    queryData();
  }

  Future<void> queryMsgFeedUnread() async {
    final res = await (_ref?.read(imRepositoryProvider) ?? Get.find<ImRepository>()).getTotalUnread(unreadType: 2);
    if (res case Success(:final response)) {
      final unreadMap = response.msgFeedUnread;
      final data = CoreMsgFeedUnreadData(
        reply: unreadMap?['reply'] ?? 0,
        at: unreadMap?['at'] ?? 0,
        like: unreadMap?['like'] ?? 0,
        sysMsg: unreadMap?['sys_msg'] ?? 0,
      );
      final unreadCounts = [data.reply, data.at, data.like, data.sysMsg];
      if (!listEquals(this.unreadCounts, unreadCounts)) {
        this.unreadCounts.value = unreadCounts;
      }
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  @override
  List<Session>? getDataList(SessionMainReply response) {
    offset = response.paginationParams.offsets;
    isEnd = !response.paginationParams.hasMore;
    return response.sessions;
  }

  @override
  bool customHandleResponse(
    bool isRefresh,
    Success<SessionMainReply> response,
  ) {
    if (isRefresh) {
      threeDotItems.value = response.response.threeDotItems;
      outsideItem.value = response.response.outsideItem;
    }
    return false;
  }

  @override
  Future<LoadingState<SessionMainReply>> customGetData() async {
    final result = await ImGrpc.sessionMain(offset: offset);
    return result;
  }

  @override
  Future<void> onRefresh() {
    offset = null;
    queryMsgFeedUnread();
    return super.onRefresh();
  }
}



