import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/router/app_navigator.dart';

class RelatedController
    extends CommonListControllerRiverpod<List<CoreHotVideoItemModel>?, CoreHotVideoItemModel> {
  RelatedController({this.autoQuery = true}) {
    if (autoQuery) {
      queryData();
    }
  }
  String bvid = AppNavigator.arguments['bvid'];
  final bool autoQuery;

  /// 首次查询已触发（playRelated 复刻 GetX isRegistered 语义：查询中不重复触发）。
  bool autoQueried = false;

  @override
  Future<LoadingState<List<CoreHotVideoItemModel>?>> customGetData() async {
    final result = await (appRead(videoRepositoryProvider)).relatedVideoList(bvid: bvid);
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
/// 相关推荐控制器（每视频页一实例，按 heroTag 键控）。
final relatedControllerProvider = ChangeNotifierProvider
    .family<RelatedController, String>(
  (ref, heroTag) => RelatedController(autoQuery: false),
);
