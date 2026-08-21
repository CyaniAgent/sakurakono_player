import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';

class MemberShopController
    extends CommonListControllerRiverpod<CoreSpaceShopData, CoreSpaceShopItem> {
  MemberShopController(this.mid) {
    queryData();
  }

  final int mid;
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }


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
    final result = await (_ref?.read(memberRepositoryProvider) ?? Get.find<MemberRepository>()).spaceShop(mid: mid);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}