// 合集/播放列表能力:媒体列表弹层、选集切换、来源判定与续播提示。

import 'package:flutter/widgets.dart' show BuildContext;
import 'package:skf/core/models/user_types.dart';

/// 合集/播放列表能力宿主。
abstract class PlaylistCapability {
  /// 本适配器是否支持合集/播放列表。
  bool get supported;

  /// 媒体列表弹层(读取视频详情控制器状态)。
  void showMediaListPanel(BuildContext context, String heroTag);

  /// 从媒体列表项切换分P。
  void onChangeEpisodeFromMedia(String heroTag, CoreMediaListItemModel item);

  /// 应用续播分P提示(lastPlayCid 不在当前页时提示跳转)。
  void applyContinuePlayingPart(
    String heroTag, {
    required int? lastPlayCid,
    required int currentCid,
  });

  /// 播放列表来源是否"稍后再看"。
  bool isWatchLaterSource(Object? sourceType);

  /// 播放列表来源是否"收藏夹"。
  bool isFavSource(Object? sourceType);

  /// 播放列表来源 mediaType。
  int sourceMediaType(Object? sourceType);

  /// 是否播放列表来源(非普通/非文件)。
  bool isPlayAllSource(Object? sourceType);

  /// 是否本地文件来源。
  bool isFileSourceSource(Object? sourceType);
}
