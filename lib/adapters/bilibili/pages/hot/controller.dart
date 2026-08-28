import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';

import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';

class HotController
    extends CommonListControllerRiverpod<List<CoreHotVideoItemModel>, CoreHotVideoItemModel> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }

  HotController() {
    queryData();
  }

  @override
  Future<LoadingState<List<CoreHotVideoItemModel>>> customGetData() async {
    final result = await (_ref!.read(videoRepositoryProvider)).hotVideoList(
      pn: page,
      ps: 20,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}

/// Hot page controller (single instance).
final hotControllerProvider = Provider<HotController>((ref) => HotController()..attachRef(ref));
