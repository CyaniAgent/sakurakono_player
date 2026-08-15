import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/pages/common/common_list_controller.dart';

class SeasonSeriesController
    extends CommonListController<CoreSpaceSsData, CoreSpaceSsModel> {
  SeasonSeriesController(this.mid);
  final int mid;
  int? count;

  @override
  void onInit() {
    super.onInit();
    queryData();
  }

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
    final result = await Get.find<MemberRepository>().seasonSeriesList(
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