import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

class SeasonSeriesController
    extends CommonListControllerRiverpod<CoreSpaceSsData, CoreSpaceSsModel> {
  SeasonSeriesController(this.mid) {
    queryData();
  }
  final int mid;
  int? count;

  @override
  List<CoreSpaceSsModel>? getDataList(CoreSpaceSsData response) {
    count = response.corePage?.total;
    return (response.seasonsList ?? <CoreSpaceSsModel>[]) +
        (response.seriesList ?? <CoreSpaceSsModel>[]);
  }

  @override
  void checkIsEnd(int length) {
    if (count != null && length >= count!) {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState<CoreSpaceSsData>> customGetData() async {
    final result = await (appRead(memberRepositoryProvider)).seasonSeriesList(
      mid: mid,
      pn: page,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}