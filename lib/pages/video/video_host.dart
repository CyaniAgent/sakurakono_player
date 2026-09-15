// 视频播放详情页(lib/pages/video/)宿主注入契约 —— 门面。
//
// 标准抽象接口定义在 lib/core/contract/player/(唯一标准面);
// 本文件仅组合 VideoPlayerHost + PlayerCapabilities 并提供 VideoHost.of()。
//
// 适配器实现:BiliVideoHost(全能力)/ OttoVideoHost(主接口)/
// ExampleVideoHost(骨架示例)。
//
// 能力降级模式:可选能力以 nullable getter 声明;返回 null = 不支持,
// 页面必须对 null 降级(隐藏入口/面板)。

import 'dart:async' show Future;
import 'dart:ui' show Color;

import 'package:flutter/animation.dart' show Animation;
import 'package:flutter/widgets.dart' show
    AnimatedListState,
    BuildContext,
    GlobalKey,
    Key,
    ValueChanged,
    VoidCallback,
    Widget;

import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/contract/player/capabilities.dart';
import 'package:skf/core/contract/player/danmaku_trend_capability.dart';
import 'package:skf/core/contract/player/download_capability.dart';
import 'package:skf/core/contract/player/interactive_capability.dart';
import 'package:skf/core/contract/player/notes_capability.dart';
import 'package:skf/core/contract/player/playback_models.dart';
import 'package:skf/core/contract/player/playlist_capability.dart';
import 'package:skf/core/contract/player/segment_skip_capability.dart';
import 'package:skf/core/contract/player/series_capability.dart';
import 'package:skf/core/contract/player/subtitle_capability.dart';
import 'package:skf/core/contract/player/video_player_host.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/pages/providers.dart';
import 'package:skf/pages/video/video_models.dart';

export 'package:skf/core/contract/player/capabilities.dart';
export 'package:skf/core/contract/player/danmaku_trend_capability.dart';
export 'package:skf/core/contract/player/download_capability.dart';
export 'package:skf/core/contract/player/interactive_capability.dart';
export 'package:skf/core/contract/player/notes_capability.dart';
export 'package:skf/core/contract/player/playback_models.dart';
export 'package:skf/core/contract/player/playlist_capability.dart';
export 'package:skf/core/contract/player/segment_skip_capability.dart';
export 'package:skf/core/contract/player/series_capability.dart';
export 'package:skf/core/contract/player/subtitle_capability.dart';
export 'package:skf/core/contract/player/video_player_host.dart';

/// 视频页面宿主:主框架(view/controller)的适配器注入点。
///
/// 播放器表面经 [playerHost](VideoPlayerHost);可选能力来自
/// [PlayerCapabilities](默认实现全不支持,适配器覆写支持的项)。
abstract class VideoHost with DefaultPlayerCapabilities {
  /// 获取当前宿主(双端 bridge 注册)。
  static VideoHost of() => appRead(videoHostProvider);

  /// 播放器宿主(扩展播放器表面)。
  VideoPlayerHost get playerHost;

  // ---------- 账号 ----------

  /// 是否已登录主账号。
  bool get isLogin;

  /// 视频账号是否已登录。
  bool get isVideoLogin;

  // ---------- 播放器 / 覆盖层构建 ----------

  /// 播放器页面销毁回调。
  Future<void> onVideoDetailDispose(String heroTag);

  /// 构建播放器整机(播放器 + 控制层 + 弹幕装配)。
  Widget buildPlayer({
    required String heroTag,
    required double width,
    required double height,
    bool isPipMode = false,
    required bool isPortrait,
  });

  /// 播放器上的额外覆盖层(跳过提示 / 互动选项等)。
  List<Widget> buildPlayerOverlays({
    required String heroTag,
    required bool isFullScreen,
    required double maxHeight,
  });

  /// 键盘控制焦点包装(未启用时返回 null)。
  Widget? buildKeyboardFocus({
    required Widget child,
    required String heroTag,
    required VoidCallback onSendDanmaku,
    required bool Function() canPlay,
    required bool Function() onSkipSegment,
  });

  /// 设置弹窗入口。
  void showSettingSheet(GlobalKey headerKey);

  // ---------- 简介 / 回复 / 相关 ----------

  /// 本地离线简介面板。
  Widget buildLocalIntroPanel({required Key key, required String heroTag});

  /// 投稿视频简介面板。
  Widget buildUgcIntroPanel({
    required Key key,
    required String heroTag,
    required bool isPortrait,
    required bool isHorizontal,
  });

  /// 相关视频面板。
  Widget buildRelatedPanel({required Key key, required String heroTag});

  /// 评论 tab 面板。
  Widget buildReplyPanel({required Key key, required String heroTag, bool isNested = false});

  /// 评论 tab 标签(含数量)。
  Widget buildReplyTabLabel({required String heroTag});

  /// 评论列表滚回顶部。
  void animateReplyToTop(String heroTag);

  // ---------- 弹幕 / 简介控制 ----------

  /// 发送弹幕面板。
  Future<void> showShootDanmakuSheet({
    required String heroTag,
    required String bvid,
    required int cid,
    required int progress,
    String? initialValue,
    void Function(String?)? onSave,
    ({int? mode, int? fontSize, Color? color})? dmConfig,
    ValueChanged<({int mode, int fontSize, Color color})>? onSaveDmConfig,
  });

  /// 简介控制器定时器。
  void startIntroTimer(String heroTag);

  void cancelIntroTimer(String heroTag);

  /// 简介控制器销毁。
  void disposeIntro(String heroTag);

  /// 播放完毕自动播放下一个。
  bool nextPlay(String heroTag);

  /// 稍后再看。
  Future<void> viewLater(String heroTag);

  // ---------- 其他 ----------

  /// 分P尺寸回退查询。
  ({int width, int height})? partDimension(String heroTag, int cid);

  /// 视频标题(失败返回 null)。
  String? videoTitle(String heroTag);

  /// 本地文件条目信息。
  CoreFileEntryInfo? fileEntryInfo(Object? entry);

  /// 关屏定时器是否等待中。
  bool get isShutdownTimerWaiting;

  /// 处理关屏定时器。
  void handleShutdownTimer();
}

/// 从路由参数解析视频类型(兼容适配器 VideoType 与 CoreVideoType 两种入参)。
CoreVideoType coreVideoTypeFromArgs(Object? v) {
  final name = v?.toString() ?? 'VideoType.ugc';
  if (name.contains('ugc')) return CoreVideoType.ugc;
  if (name.contains('pgc')) return CoreVideoType.pgc;
  if (name.contains('pugv')) return CoreVideoType.pugv;
  return CoreVideoType.ugc;
}
