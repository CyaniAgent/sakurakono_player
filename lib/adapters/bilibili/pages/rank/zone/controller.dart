import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:get/get.dart';

class ZoneController extends CommonListControllerRiverpod<dynamic, dynamic> {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  ZoneController({this.rid, this.seasonType}) {
    queryData();
  }

  int? rid;
  int? seasonType;

  @override
  Future<LoadingState> customGetData() async {
    final result = await (rid != null
        ? (_ref!.read(videoRepositoryProvider)).getRankVideoList(rid!)
        : seasonType == 4 || seasonType == 5
            ? (_ref!.read(videoRepositoryProvider)).pgcRankList(seasonType: seasonType!)
            : (_ref!.read(videoRepositoryProvider)).pgcSeasonRankList(seasonType: seasonType!));
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}
