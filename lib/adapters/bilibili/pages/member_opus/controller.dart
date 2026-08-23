import 'package:skf/core/models/space_types.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/models_new/space/space/tab2.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/pages/member/controller.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:get/get.dart';

class MemberOpusController
    extends CommonListControllerRiverpod<CoreOpusSpaceFlowResp, dynamic> {
  MemberOpusController({
    required this.heroTag,
    required this.mid,
  }) {
    filter = Get.find<MemberController>(tag: heroTag).tab2
        ?.firstWhereOrNull((e) => e.param == 'contribute')
        ?.items
        ?.firstWhereOrNull((e) => e.param == 'opus')
        ?.filter;
    queryData();
  }

  final String? heroTag;
  final int mid;

  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }

  String offset = '';
  SpaceTabFilter type = const SpaceTabFilter(
    text: "全部图文",
    meta: "all",
    tabName: "图文",
  );
  List<SpaceTabFilter>? filter;

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
    final result = await (_ref!.read(memberRepositoryProvider)).spaceOpus(
      hostMid: mid,
      page: page,
      offset: offset,
      type: type.meta,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}