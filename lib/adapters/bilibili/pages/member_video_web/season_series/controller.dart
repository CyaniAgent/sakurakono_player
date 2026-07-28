import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/base/controller.dart';
import 'package:get/get.dart';

class MemberSSWebCtr
    extends BaseVideoWebCtr<CoreSeasonWebData, CoreSeasonArchive, CoreArchiveSortTypeApp> {
  @override
  final Rx<CoreArchiveSortTypeApp> order = Rx(CoreArchiveSortTypeApp.desc);
  late final CoreWebSsType _type;
  late final Object _id;

  @override
  void onInit() {
    final args = Get.arguments;
    _type = args['type'];
    _id = args['id'];
    super.onInit();
  }

  @override
  List<CoreSeasonArchive>? getDataList(CoreSeasonWebData response) {
    return response.archives;
  }

  @override
  bool customHandleResponse(
    bool isRefresh,
    Success<CoreSeasonWebData> response,
  ) {
    if (isRefresh) {
      final data = response.response;
      if (data.corePage?.total case final total?) {
        count = total;
        totalPage = (total / ps).ceil();
      }
    }
    return false;
  }

  @override
  Future<LoadingState<CoreSeasonWebData>> customGetData() async {
    final result = await Get.find<MemberRepository>().seasonSeriesWeb(
      type: _type,
      mid: mid,
      id: _id,
      ps: ps,
      pn: page,
      sort: order.value,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
