import 'package:skf/core/models/space_types.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/models_new/space/space/tab2.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/adapters/bilibili/pages/member/controller.dart';
import 'package:collection/collection.dart';
import 'package:get/get.dart';

class MemberOpusController
    extends CommonListController<CoreOpusSpaceFlowResp, dynamic> {
  MemberOpusController({
    required this.heroTag,
    required this.mid,
  });

  final String? heroTag;
  final int mid;

  String offset = '';
  Rx<SpaceTabFilter> type = const SpaceTabFilter(
    text: "全部图文",
    meta: "all",
    tabName: "图文",
  ).obs;
  List<SpaceTabFilter>? filter;

  @override
  void onInit() {
    super.onInit();
    filter = Get.find<MemberController>(tag: heroTag).tab2
        ?.firstWhereOrNull((e) => e.param == 'contribute')
        ?.items
        ?.firstWhereOrNull((e) => e.param == 'opus')
        ?.filter;
    queryData();
  }

  @override
  Future<void> onRefresh() {
    offset = '';
    return super.onRefresh();
  }

  @override
  List<dynamic>? getDataList(CoreOpusSpaceFlowResp response) {
    if (response.nextPage == null) {
      isEnd = true;
    }
    return response.itemList;
  }

  @override
  Future<LoadingState<CoreOpusSpaceFlowResp>> customGetData() async {
    final result = await Get.find<MemberRepository>().spaceOpus(
      hostMid: mid,
      page: page,
      offset: offset,
      type: type.value.meta,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}