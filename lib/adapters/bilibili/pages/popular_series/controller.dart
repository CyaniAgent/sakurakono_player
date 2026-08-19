import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/common/widgets/scroll_physics.dart' show ReloadMixin;
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:get/get.dart';

class PopularSeriesController
    extends CommonListController<CorePopularSeriesOneData, CoreHotVideoItemModel>
    with ReloadMixin {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  late int number;

  final config = Rxn<Map<String, dynamic>>();
  String? reminder;
  List<CorePopularSeriesListItem>? seriesList;

  @override
  void onInit() {
    super.onInit();
    _getSeriesList();
  }

  Future<void> _getSeriesList() async {
    final res = await (_ref?.read(videoRepositoryProvider) ?? Get.find<VideoRepository>()).popularSeriesList();
    if (res case Success(:final response)) {
      if (response != null && response.isNotEmpty) {
        number = response.first.number!;
        seriesList = response;
        queryData();
      } else {
        loadingState.value = const Success(null);
      }
    } else if (res case Error(:final errMsg, :final code)) {
      loadingState.value = Error(errMsg, code: code);
    }
  }

  @override
  List<CoreHotVideoItemModel>? getDataList(CorePopularSeriesOneData response) {
    config.value = response.config;
    reminder = response.reminder;
    return response.list;
  }

  @override
  Future<LoadingState<CorePopularSeriesOneData>> customGetData() async {
    final result = await (_ref?.read(videoRepositoryProvider) ?? Get.find<VideoRepository>()).popularSeriesOne(number: number);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  Future<void> onReload() {
    if (seriesList?.isEmpty ?? true) {
      return _getSeriesList();
    }
    reload = true;
    return super.onReload();
  }
}
