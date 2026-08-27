import 'package:skf/common/widgets/scroll_physics.dart' show ReloadMixin;
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/adapters/bilibili/pages/common/dyn/common_dyn_controller.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:skf/core/repository/repository_providers.dart';

class DynamicDetailController extends CommonDynController with ReloadMixin {
  Ref? _ref;
  @override
  void attachRef(Ref ref) { _ref = ref; }
  @override
  late int oid;
  @override
  late int replyType;
  late CoreDynamicItemModel dynItem;
  bool _disposed = false;

  @override
  dynamic get sourceId => replyType == 1 ? IdUtils.av2bv(oid) : oid;

  DynamicDetailController() {
    dynItem = Get.arguments['item'] as CoreDynamicItemModel;
    final commentType = dynItem.basic?.commentType;
    final commentIdStr = dynItem.basic?.commentIdStr;
    if (commentType != null &&
        commentType != 0 &&
        commentIdStr != null &&
        commentIdStr.isNotEmpty) {
      _init(commentIdStr, commentType);
    } else {
      (_ref!.read(dynamicsRepositoryProvider)).dynamicDetail(id: dynItem.idStr).then((res) {
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
    final result = await (_ref!.read(dynamicsRepositoryProvider)).dynPrivatePubSetting(
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
    final res = await (_ref!.read(replyRepositoryProvider)).replySubjectModify(
      oid: oid,
      type: replyType,
      action: action,
    );
    if (res.isSuccess) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_disposed) {
          onReload();
        }
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Future<void> onReload() {
    reload = true;
    return super.onReload();
  }
}