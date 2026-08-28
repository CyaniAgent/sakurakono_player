import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/core/container/app_container.dart';

class ZoneController extends CommonListControllerRiverpod<dynamic, dynamic> {
  ZoneController({this.rid, this.seasonType}) {
    queryData();
  }

  int? rid;
  int? seasonType;

  @override
  Future<LoadingState> customGetData() async {
    final result = await (rid != null
        ? (appRead(videoRepositoryProvider)).getRankVideoList(rid!)
        : seasonType == 4 || seasonType == 5
            ? (appRead(videoRepositoryProvider)).pgcRankList(seasonType: seasonType!)
            : (appRead(videoRepositoryProvider)).pgcSeasonRankList(seasonType: seasonType!));
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }
}

/// 每实例注册表 — zone 页 view 创建后登记，按 `${rid}${seasonType}` 经
/// [zoneControllerProvider] 读取（替代 GetX tag 注册）。
final Map<String, ZoneController> zoneRegistry = {};

final zoneControllerProvider = Provider.family<ZoneController, String>(
  (ref, key) => zoneRegistry[key] ??
      (throw StateError('ZoneController not registered for key: $key')),
);
