import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/pages/member/controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:get/get.dart';

class MemberBangumiCtr
    extends CommonListController<CoreSpaceArchiveData, CoreSpaceArchiveItem> {
  MemberBangumiCtr({
    required this.mid,
    required this.heroTag,
  });

  final int mid;
  final String? heroTag;
  int? count;
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  late final _ctr = Get.find<MemberController>(tag: heroTag);

  @override
  void onInit() {
    super.onInit();
    final response = _ctr.loadingState.value.data;
    if (response != null) {
      page = 2;
      final res = response.season!;
      loadingState.value = Success(res.item);
      count = res.count!;
      isEnd = res.item!.length >= count!;
    } else {
      queryData();
    }
  }

  @override
  List<CoreSpaceArchiveItem>? getDataList(CoreSpaceArchiveData response) {
    return response.item;
  }

  @override
  void checkIsEnd(int length) {
    if (count != null && length >= count!) {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState<CoreSpaceArchiveData>> customGetData() async {
    final result = await (_ref?.read(memberRepositoryProvider) ?? Get.find<MemberRepository>()).spaceArchive(
      type: CoreContributeType.bangumi,
      mid: mid,
      pn: page,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}