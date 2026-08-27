import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_list_controller.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

class RcmdController extends CommonListController {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  late bool enableSaveLastData = Pref.enableSaveLastData;
  final bool appRcmd = Pref.appRcmd;

  int? lastRefreshAt;
  late bool savedRcmdTip = Pref.savedRcmdTip;

  @override
  bool get isEnd => false;

  RcmdController() {
    page = 0;
    queryData();
  }

  @override
  Future<LoadingState> customGetData() async {
    final result = await (appRcmd
        ? (_ref!.read(videoRepositoryProvider)).rcmdVideoListApp(freshIdx: page)
        : (_ref!.read(videoRepositoryProvider)).rcmdVideoList(freshIdx: page, ps: 20));
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  bool handleError(String? errMsg) {
    return enableSaveLastData;
  }

  @override
  void handleListResponse(List dataList) {
    if (enableSaveLastData && page == 0) {
      if (loadingState case Success(:final response)) {
        if (response != null && response.isNotEmpty) {
          if (savedRcmdTip) {
            lastRefreshAt = dataList.length;
          }
          if (response.length > 200) {
            dataList.addAll(response.take(50));
          } else {
            dataList.addAll(response);
          }
        }
      }
    }
  }

  @override
  Future<void> onRefresh() {
    page = 0;
    isEnd = false;
    return queryData();
  }
}
