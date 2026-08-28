import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

class MemberShopController
    extends CommonListControllerRiverpod<CoreSpaceShopData, CoreSpaceShopItem> {
  MemberShopController(this.mid) {
    queryData();
  }

  final int mid;


  bool? showMoreTab;
  String? clickUrl;
  String? showMoreDesc;

  @override
  List<CoreSpaceShopItem>? getDataList(CoreSpaceShopData response) {
    isEnd = response.haveNextPage == false;
    showMoreTab = response.showMoreTab;
    clickUrl = response.clickUrl;
    showMoreDesc = response.showMoreDesc;
    return response.data;
  }

  @override
  Future<LoadingState<CoreSpaceShopData>> customGetData() async {
    final result = await (appRead(memberRepositoryProvider)).spaceShop(mid: mid);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}