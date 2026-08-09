import 'package:skf/common/widgets/scroll_physics.dart' show ReloadMixin;
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/adapters/bilibili/pages/common/dyn/common_dyn_controller.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

class DynamicDetailController extends CommonDynController with ReloadMixin {
  @override
  late int oid;
  @override
  late int replyType;
  late CoreDynamicItemModel dynItem;

  @override
  dynamic get sourceId => replyType == 1 ? IdUtils.av2bv(oid) : oid;

  @override
  void onInit() {
    super.onInit();
    dynItem = Get.arguments['item'] as CoreDynamicItemModel;
    final commentType = dynItem.basic?.commentType;
    final commentIdStr = dynItem.basic?.commentIdStr;
    if (commentType != null &&
        commentType != 0 &&
        commentIdStr != null &&
        commentIdStr.isNotEmpty) {
      _init(commentIdStr, commentType);
    } else {
      Get.find<DynamicsRepository>().dynamicDetail(id: dynItem.idStr).then((res) {
        if (res case Success(:final response)) {
          _init(response.basic!.commentIdStr!, response.basic!.commentType!);
        } else {
          res.toast();
        }
      });
    }
  }

  void _init(String commentIdStr, int commentType) {
    oid = int.parse(commentIdStr);
    replyType = commentType;
    queryData();
  }

  Future<LoadingState> onSetPubSetting(bool isPrivate, String dynId) async {
    final result = await Get.find<DynamicsRepository>().dynPrivatePubSetting(
      dynId: dynId,
      action: isPrivate ? 'public_pub' : 'private_pub',
    );
    final coreResult = switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
    if (coreResult.isSuccess) {
      dynItem.modules?.moduleAuthor?.badgeText = isPrivate ? null : '仅自己可见';
      SmartDialog.showToast('设置成功');
    } else {
      SmartDialog.showToast(coreResult.toString());
    }
    return coreResult;
  }

  Future<void> onSetReplySubject(int action) async {
    final res = await Get.find<ReplyRepository>().replySubjectModify(
      oid: oid,
      type: replyType,
      action: action,
    );
    if (res.isSuccess) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          onReload();
        }
      });
    }
  }

  @override
  Future<void> onReload() {
    reload = true;
    return super.onReload();
  }
}