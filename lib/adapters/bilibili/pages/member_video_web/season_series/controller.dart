import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/base/controller.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

class MemberSSWebCtr
    extends BaseVideoWebCtr<CoreSeasonWebData, CoreSeasonArchive, CoreArchiveSortTypeApp> {
  @override
  final Rx<CoreArchiveSortTypeApp> order = Rx(CoreArchiveSortTypeApp.desc);
  late CoreWebSsType _type;
  late Object _id;
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }

  MemberSSWebCtr() {
    final args = Get.arguments;
    _type = args['type'];
    _id = args['id'];
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
    final result = await (_ref!.read(memberRepositoryProvider)).seasonSeriesWeb(
      type: _type,
      mid: mid,
      id: _id.toString(),
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
