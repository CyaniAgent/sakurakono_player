import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/pages/member/controller.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/container/app_container.dart';

class MemberBangumiCtr
    extends CommonListControllerRiverpod<CoreSpaceArchiveData, CoreSpaceArchiveItem> {
  MemberBangumiCtr({
    required this.mid,
    required this.heroTag,
  }) : super() {
    final response = _ctr.loadingState.data;
    if (response != null) {
      page = 2;
      final res = response.season!;
      loadingState = Success(res.item);
      count = res.count!;
      isEnd = res.item!.length >= count!;
    } else {
      queryData();
    }
  }

  final int mid;
  final String? heroTag;
  int? count;
  late final _ctr = appRead(memberControllerProvider(heroTag!));

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
    final result = await (appRead(memberRepositoryProvider)).spaceArchive(
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