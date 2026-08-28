import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

class MemberLikeArcController
    extends CommonListControllerRiverpod<CoreCoinLikeArcData, CoreCoinLikeArcItem> {
  final dynamic mid;
  MemberLikeArcController({this.mid}) {
    queryData();
  }
  @override
  List<CoreCoinLikeArcItem>? getDataList(CoreCoinLikeArcData response) {
    return response.item;
  }

  @override
  Future<LoadingState<CoreCoinLikeArcData>> customGetData() async {
    final result = await (appRead(memberRepositoryProvider)).likeArc(mid: mid, page: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}