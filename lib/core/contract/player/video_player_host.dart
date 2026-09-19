// 标准播放器宿主契约:页面对"播放器表面"的最小依赖。
//
// 实现方:各适配器(如 BiliVideoHost/OttoVideoHost/ExampleVideoHost)。
// 消费方:lib/pages/video(仅允许依赖本契约,禁止 import 任何适配器)。


import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:skf/core/models/video_types.dart';
import 'package:skf/pages/video/video_models.dart';
import 'package:skf/player/models/data_source.dart';
import 'package:skf/player/models/heart_beat_type.dart';
import 'package:skf/player/models/play_repeat.dart';
import 'package:skf/player/player_controller.dart';

/// 播放器宿主:暴露适配器扩展播放器上的页面所需成员。
///
/// 实现要求:
/// - `acquirePlayer` 语义 = 每页访问一次;实例已销毁则自动重建。
/// - 弹幕可见性/开关的切换持久化由实现方负责。
abstract class VideoPlayerHost {
  /// 获取当前播放器实例。
  PlayerController acquirePlayer();

  /// 当前播放器实例。
  PlayerController get player;

  /// 音频响度归一化开关(不支持的平台返回 false)。
  bool get enableAudioNormalization;

  /// 播放心跳开关。
  bool get enableHeart;

  /// 弹幕可见性。
  bool get playerDanmakuVisible;

  void setPlayerDanmakuVisible(bool value);

  /// 弹幕开关,切换时持久化由宿主负责。
  bool get danmakuEnabled;

  void toggleDanmakuEnabled();

  /// 播放循环模式。
  PlayRepeat get playerPlayRepeat;

  /// 播放心跳上报(历史进度/ streak)。
  Future<void>? playerMakeHeartBeat({
    required int progress,
    required HeartBeatType type,
    required bool isManual,
    required int aid,
    required String bvid,
    required int cid,
    int? epid,
    int? seasonId,
    int? pgcType,
    required CoreVideoType videoType,
  });

  /// 初始化播放数据源。
  Future<void> playerSetDataSource({
    required DataSource source,
    Duration? seekTo,
    Duration? duration,
    bool isVertical = false,
    int? aid,
    String? bvid,
    int? cid,
    bool autoplay = true,
    int? epid,
    int? seasonId,
    int? pgcType,
    required CoreVideoType videoType,
    VoidCallback? onInit,
    int? width,
    int? height,
    VideoVolume? volume,
    bool autoFullScreenFlag = false,
  });

  /// 注册播放回调。
  void setPlayCallBack(PlayCallback? playCallBack);

  /// 播放计数(页面未持有播放器时使用)。
  void updatePlayCount();

  /// 弹幕是否被作者关闭。
  bool dmStateContains(int cid);

  /// 高能进度条开关。
  bool get showDmChart;
}
