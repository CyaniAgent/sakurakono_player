import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/adapters/bilibili/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class SubDetailController
    extends CommonListController<CoreSubDetailData, CoreSubDetailItemModel> {
  late int id;
  String? heroTag;
  CoreSubItemModel? subInfo;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    id = args['id'];
    subInfo = args['subInfo'];
    heroTag = args['heroTag'];

    queryData();
  }

  @override
  List<CoreSubDetailItemModel>? getDataList(CoreSubDetailData response) {
    subInfo = response.info;
    return response.medias;
  }

  @override
  void checkIsEnd(int length) {
    final count = subInfo?.mediaCount;
    if (count != null && length >= count) {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState<CoreSubDetailData>> customGetData() async {
    final result = await Get.find<FavRepository>().favSeasonList(
      id: id,
      ps: 20,
      pn: page,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
