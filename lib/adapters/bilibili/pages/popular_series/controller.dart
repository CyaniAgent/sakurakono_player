import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/common/widgets/scroll_physics.dart' show ReloadMixin;
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PopularSeriesController
    extends CommonListControllerRiverpod<CorePopularSeriesOneData, CoreHotVideoItemModel>
    with ReloadMixin {
  late int number;

  Map<String, dynamic>? config;
  String? reminder;
  List<CorePopularSeriesListItem>? seriesList;

  PopularSeriesController() {
    _getSeriesList();
  }

  Future<void> _getSeriesList() async {
    final res = await (appRead(videoRepositoryProvider)).popularSeriesList();
    if (res case Success(:final response)) {
      if (response != null && response.isNotEmpty) {
        number = response.first.number!;
        seriesList = response;
        queryData();
      } else {
        loadingState = const Success(null);
      }
    } else if (res case Error(:final errMsg, :final code)) {
      loadingState = Error(errMsg, code: code);
    }
  }

  @override
  List<CoreHotVideoItemModel>? getDataList(CorePopularSeriesOneData response) {
    config = response.config;
    reminder = response.reminder;
    return response.list;
  }

  @override
  Future<LoadingState<CorePopularSeriesOneData>> customGetData() async {
    final result = await (appRead(videoRepositoryProvider)).popularSeriesOne(number: number);
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

/// PopularSeriesController（单实例）。
final popularSeriesControllerProvider = Provider<PopularSeriesController>((ref) => PopularSeriesController());
