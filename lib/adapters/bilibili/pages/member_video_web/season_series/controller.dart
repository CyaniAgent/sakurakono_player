import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/base/controller.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/router/app_navigator.dart';

class MemberSSWebCtr
    extends BaseVideoWebCtr<CoreSeasonWebData, CoreSeasonArchive, CoreArchiveSortTypeApp> {
  @override
  CoreArchiveSortTypeApp order = CoreArchiveSortTypeApp.desc;
  late CoreWebSsType _type;
  late Object _id;

  MemberSSWebCtr() {
    final args = AppNavigator.arguments;
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
    final result = await (appRead(memberRepositoryProvider)).seasonSeriesWeb(
      type: _type,
      mid: mid,
      id: _id.toString(),
      ps: ps,
      pn: page,
      sort: order,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
