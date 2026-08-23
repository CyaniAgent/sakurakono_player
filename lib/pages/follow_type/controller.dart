import 'package:skf/router/app_navigator.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_item.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

abstract class FollowTypeController
    extends CommonListControllerRiverpod<CoreFollowData, CoreFollowItemModel> {
  FollowTypeController() {
    init();
  }
  late final int mid;
  String? name;

  int total = 0;

  Ref? repoRef;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(Ref ref) { repoRef = ref; }


  void init() {
    final ownerMid = repoRef?.read(accountProvider).userId ?? Get.find<AccountProvider>().userId ?? 0;
    final Map? args = AppNavigator.arguments;
    mid = args?['mid'] ?? ownerMid;
    final String? name = args?['name'];
    this.name = name;
    if (name == null) {
      queryUserName();
    }
    queryData();
  }

  Future<void> queryUserName() async {
    final res = await (repoRef?.read(memberRepositoryProvider) ?? Get.find<MemberRepository>()).memberCardInfo(mid: mid);
    name = res.dataOrNull?.card?.name;
  }

  @override
  List<CoreFollowItemModel>? getDataList(CoreFollowData response) {
    total = response.total ?? 0;
    return response.list;
  }

  @override
  void checkIsEnd(int length) {
    if (length >= total) {
      isEnd = true;
    }
  }
}
