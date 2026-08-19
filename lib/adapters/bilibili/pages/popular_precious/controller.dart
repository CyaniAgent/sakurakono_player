import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class PopularPreciousController
    extends CommonListController<CorePopularPreciousData, CoreHotVideoItemModel> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  @override
  void onInit() {
    super.onInit();
    queryData();
  }

  int? mediaId;

  @override
  List<CoreHotVideoItemModel>? getDataList(CorePopularPreciousData response) {
    mediaId = response.mediaId;
    return response.list;
  }

  @override
  Future<LoadingState<CorePopularPreciousData>> customGetData() async {
    final result = await (_ref?.read(videoRepositoryProvider) ?? Get.find<VideoRepository>()).popularPrecious(page: page);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
