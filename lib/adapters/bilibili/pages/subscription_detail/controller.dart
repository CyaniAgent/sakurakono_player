import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class SubDetailController
    extends CommonListController<CoreSubDetailData, CoreSubDetailItemModel> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
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
    final result = await (_ref?.read(favRepositoryProvider) ?? Get.find<FavRepository>()).favSeasonList(
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
