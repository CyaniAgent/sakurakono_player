import 'package:skf/adapters/bilibili/pages/sponsor_block/block_mixin.dart';
import 'package:skf/adapters/bilibili/plugin/pl_player/bili_player_mixin.dart';
import 'package:skf/player/models/play_status.dart';
import 'package:skf/player/player_controller.dart';

/// B站 播放器控制器：通用播放核心（[PlayerController]，lib/player/）
/// + B站 扩展（[BiliPlayerMixin]，含弹幕/心跳/预览/超分辨率/PiP 等）。
///
/// 对外 API 与拆分前保持一致：`PlPlayerController.instance`、
/// `PlPlayerController.getInstance()`、`setDataSource(...)`、播放控制、
/// 事件流等均可继续使用。
class PlPlayerController extends PlayerController
    with BlockConfigMixin, BiliPlayerMixin {
  // 添加一个私有构造函数
  PlPlayerController._();

  // 获取实例 传参
  static PlPlayerController getInstance({bool isLive = false}) {
    // 如果实例尚未创建，则创建一个新实例
    return (PlayerController.currentInstance ??= PlPlayerController._())
        as PlPlayerController
      ..isLive = isLive
      ..playerCount += 1;
  }

  /// 当前播放器实例（仅在存在 [PlPlayerController] 时非空）。
  static PlPlayerController? get instance =>
      PlayerController.currentInstance as PlPlayerController?;

  /// FFmpeg loudnorm 滤镜参数正则（设置页音频归一化检测使用）。
  static final loudnormRegExp = RegExp('loudnorm=([^,]+)');

  static bool instanceExists() => PlayerController.currentInstance != null;

  static void setPlayCallBack(PlayCallback? playCallBack) {
    PlayerController.currentInstance?.registerPlayCallBack(playCallBack);
  }

  static Future<void>? playIfExists() {
    return PlayerController.currentInstance?.invokePlayCallBack();
  }

  // try to get PlayerStatus
  static PlayerStatus? getPlayerStatusIfExists() {
    return PlayerController.currentInstance?.playerStatus.value;
  }

  static Future<void> pauseIfExists({
    bool notify = true,
    bool isInterrupt = false,
  }) async {
    final player = PlayerController.currentInstance;
    if (player?.playerStatus.isPlaying ?? false) {
      await player?.pause(notify: notify, isInterrupt: isInterrupt);
    }
  }

  static Future<void> seekToIfExists(
    Duration position, {
    bool isSeek = true,
  }) async {
    await PlayerController.currentInstance?.seekTo(position, isSeek: isSeek);
  }

  static double? getVolumeIfExists() {
    return PlayerController.currentInstance?.volume.value;
  }

  static Future<void>? setVolumeIfExists(
    double volumeNew, {
    bool showIndicator = true,
  }) {
    return PlayerController.currentInstance?.setVolume(
      volumeNew,
      showIndicator: showIndicator,
    );
  }

  static void updatePlayCount() {
    final player = PlayerController.currentInstance;
    if (player?.playerCount == 1) {
      player?.dispose();
    } else {
      player?.playerCount -= 1;
    }
  }
}