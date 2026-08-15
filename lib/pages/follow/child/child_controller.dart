
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_item.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/repository/follow_repository.dart';
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/follow/follow_models.dart' show FollowOrderType;
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/pages/follow/controller.dart';
import 'package:skf/utils/storage.dart';
import 'package:skf/utils/storage_key.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:get/get.dart';

class FollowChildController
    extends CommonListController<CoreFollowData, CoreFollowItemModel> {
  FollowChildController(this.controller, this.mid, this.tagid);
  final FollowController? controller;
  final int? tagid;
  final int mid;
  int? total;

  late final loadSameFollow = controller?.isOwner == false;
  late final Rx<LoadingState<List<CoreFollowItemModel>?>> sameState =
      LoadingState<List<CoreFollowItemModel>?>.loading().obs;

  late final Rx<FollowOrderType> orderType = FollowOrderType.values[Pref.followOrderType].obs;

  void setOrderType(FollowOrderType type) {
    orderType.value = type;
    GStorage.setting.put(SettingBoxKey.followOrderType, type.index);
  }

  @override
  void onInit() {
    super.onInit();
    queryData();
    if (loadSameFollow) {
      _loadSameFollow();
    }
  }

  @override
  List<CoreFollowItemModel>? getDataList(CoreFollowData response) {
    total = response.total;
    return response.list;
  }

  @override
  void checkIsEnd(int length) {
    if (total != null && length >= total!) {
      isEnd = true;
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<CoreFollowData> response) {
    if (controller != null) {
      try {
        if (controller!.isOwner &&
            tagid == null &&
            isRefresh &&
            controller!.followState.value.isSuccess) {
          controller!.tabs
            ..[0].count = response.response.total
            ..refresh();
        }
      } catch (_) {}
    }
    return false;
  }

  @override
  Future<LoadingState<CoreFollowData>> customGetData() async {
    if (tagid != null) {
      final biliResult = await Get.find<MemberRepository>().followUpGroup(
        mid: mid,
        tagid: tagid,
        pn: page,
      );
      return switch (biliResult) {
        Success<CoreFollowData>(:final response) => Success<CoreFollowData>(response),
        Error(:final errMsg, :final code) => Error(errMsg, code: code),
        _ => LoadingState.loading(),
      };
    }

    return Get.find<FollowRepository>().followings(
      vmid: mid,
      pn: page,
      orderType: orderType.value.type,
    );
  }

  Future<void> _loadSameFollow() async {
    final res = await Get.find<UserRepository>().sameFollowing(mid: mid);
    if (res case Success(:final response)) {
      sameState.value = Success(response.list);
    }
  }
}
