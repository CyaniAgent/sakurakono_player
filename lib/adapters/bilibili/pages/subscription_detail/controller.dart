import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:get/get.dart';
import 'package:skf/core/container/app_container.dart';

class SubDetailController
    extends CommonListControllerRiverpod<CoreSubDetailData, CoreSubDetailItemModel> {
  late int id;
  String? heroTag;
  CoreSubItemModel? subInfo;

  SubDetailController() {
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
    final result = await (appRead(favRepositoryProvider)).favSeasonList(
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
