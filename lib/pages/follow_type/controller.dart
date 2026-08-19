import 'package:skf/router/app_navigator.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_item.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

abstract class FollowTypeController
    extends CommonListController<CoreFollowData, CoreFollowItemModel> {
  late final int mid;
  late final RxnString name;

  RxInt total = 0.obs;

  Ref? repoRef;

  /// Attach a Riverpod [Ref] for repository access.
  /// Call this during controller initialization after construction.
  void attachRef(Ref ref) { repoRef = ref; }

  @override
  void onInit() {
    super.onInit();
    init();
  }

  void init() {
    final ownerMid = repoRef?.read(accountProvider).userId ?? Get.find<AccountProvider>().userId ?? 0;
    final Map? args = AppNavigator.arguments;
    mid = args?['mid'] ?? ownerMid;
    final String? name = args?['name'];
    this.name = RxnString(name);
    if (name == null) {
      queryUserName();
    }
    queryData();
  }

  Future<void> queryUserName() async {
    final res = await (repoRef?.read(memberRepositoryProvider) ?? Get.find<MemberRepository>()).memberCardInfo(mid: mid);
    name.value = res.dataOrNull?.card?.name;
  }

  @override
  List<CoreFollowItemModel>? getDataList(CoreFollowData response) {
    total.value = response.total ?? 0;
    return response.list;
  }

  @override
  void checkIsEnd(int length) {
    if (length >= total.value) {
      isEnd = true;
    }
  }
}
