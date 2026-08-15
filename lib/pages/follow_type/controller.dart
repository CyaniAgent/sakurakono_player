import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_item.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:get/get.dart';

abstract class FollowTypeController
    extends CommonListController<CoreFollowData, CoreFollowItemModel> {
  late final int mid;
  late final RxnString name;

  RxInt total = 0.obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  void init() {
    final ownerMid = Pref.userInfoCache?.mid ?? 0;
    final Map? args = Get.arguments;
    mid = args?['mid'] ?? ownerMid;
    final String? name = args?['name'];
    this.name = RxnString(name);
    if (name == null) {
      queryUserName();
    }
    queryData();
  }

  Future<void> queryUserName() async {
    final res = await Get.find<MemberRepository>().memberCardInfo(mid: mid);
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
