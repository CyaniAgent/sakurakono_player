import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

class MemberArticleCtr
    extends CommonListControllerRiverpod<CoreSpaceArticleData, CoreSpaceArticleItem> {
  MemberArticleCtr({
    required this.mid,
  }) {
    queryData();
  }

  final int mid;

  int count = -1;

  @override
  List<CoreSpaceArticleItem>? getDataList(CoreSpaceArticleData response) {
    count = response.count ?? -1;
    return response.item;
  }

  @override
  void checkIsEnd(int length) {
    if (length >= count) {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState<CoreSpaceArticleData>> customGetData() async {
    final result = await (appRead(memberRepositoryProvider)).spaceArticle(mid: mid, page: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
