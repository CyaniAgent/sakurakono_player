// ExampleAdapter —— 新适配器开发骨架(模板)。
//
// 使用方法:
// 1. 复制本目录为 `lib/adapters/你的适配器/`;
// 2. 全局替换 `Example` 前缀为你的适配器名;
// 3. 在 `lib/adapters/adapters.dart` 中注册;
// 4. 逐个把 throw UnimplementedError 的成员替换为真实逻辑:
//    优先实现 core repository(数据层),再实现 Host(页面注入层);
// 5. 未实现的能力保持 `DefaultPlayerCapabilities` 默认值即可——
//    页面会自动降级隐藏对应入口,无需删除框架代码。
//
// 契约位置:
// - 播放器/能力:lib/core/contract/player/
// - 用户空间:lib/pages/member/member_host.dart
// - 动态:lib/pages/dynamics/dynamics_host.dart
// - 主框架/设置/我的/下载:lib/pages/{main,setting,mine,download}/
// - 数据层:lib/core/repository/(接口集,按需实现)

import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart' show Color, GlobalKey, Key, ValueChanged, VoidCallback, Widget;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/adapter/app_adapter.dart';
import 'package:skf/core/adapter/play_input_kind.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/models/media_id.dart';
import 'package:skf/pages/home/controller.dart';
import 'package:skf/pages/main/controller.dart';
import 'package:skf/pages/providers.dart';
import 'package:skf/pages/video/video_host.dart';
import 'package:skf/adapters/riverpod_adapter_overrides.dart';

/// 骨架适配器:演示 [AppAdapter] 的装配方式。
class ExampleAdapter implements AppAdapter {
  @override
  String get name => 'example';

  @override
  Future<void> onAppStartPreStorage() async {
    // GStorage.init() 之前的启动逻辑(如 Hive TypeAdapter 注册)。
  }

  @override
  Future<void> onAppStart() async {
    // GStorage.init() 之后的启动逻辑(如账号恢复)。
  }

  @override
  Future<void> registerDependencies() async {
    // 数据层:至少实现 VideoRepository(推荐/播放地址)才能驱动首页。
    // adapterOverrides = <Override>[
    //   videoRepositoryProvider.overrideWithValue(ExampleVideoRepository()),
    // ];

    // 页面注入层:必须提供 videoHostProvider;其余 Host 读取时抛
    // UnimplementedError,按需补充。
    adapterOverrides = <Override>[
      videoHostProvider.overrideWithValue(ExampleVideoHost()),
      mainBarStateProvider.overrideWith((ref) => appRead(mainControllerProvider)),
      homeBarStateProvider.overrideWith((ref) => appRead(homeControllerProvider)),
    ];
  }

  @override
  List<GoRoute> get routes => const <GoRoute>[];

  @override
  String processImageUrl(String? originalUrl, {int quality = 1}) =>
      originalUrl ?? '';

  @override
  String? buildShareLink(CoreMediaId id, {String? title}) => null;

  @override
  Future<bool> openUrl(String url, {int? businessId, int? oid}) =>
      Future.syncValue(false);

  @override
  PlayInputKind classifyPlayInput(String input) => PlayInputKind.unknown;
}

/// 骨架播放器页宿主:继承 VideoHost 获得全部"能力不支持"默认值,
/// 主接口成员以 UnimplementedError 指示待实现点。
class ExampleVideoHost extends VideoHost {
  @override
  bool get isLogin => throw UnimplementedError(
      'ExampleAdapter: 返回主账号登录状态(无账号体系时返回 false)');

  @override
  bool get isVideoLogin => throw UnimplementedError(
      'ExampleAdapter: 返回视频账号登录状态(无账号体系时返回 false)');

  @override
  VideoPlayerHost get playerHost => throw UnimplementedError(
      'ExampleAdapter: 返回你的播放器宿主(实现 VideoPlayerHost 契约)');

  @override
  Future<void> onVideoDetailDispose(String heroTag) =>
      throw UnimplementedError('ExampleAdapter: 视频页销毁时的清理回调');

  @override
  Widget buildPlayer({
    required String heroTag,
    required double width,
    required double height,
    bool isPipMode = false,
    required bool isPortrait,
  }) =>
      throw UnimplementedError('ExampleAdapter: 装配播放器整机 Widget');

  @override
  List<Widget> buildPlayerOverlays({
    required String heroTag,
    required bool isFullScreen,
    required double maxHeight,
  }) =>
      const <Widget>[];

  @override
  Widget? buildKeyboardFocus({
    required Widget child,
    required String heroTag,
    required VoidCallback onSendDanmaku,
    required bool Function() canPlay,
    required bool Function() onSkipSegment,
  }) =>
      child;

  @override
  void showSettingSheet(GlobalKey headerKey) =>
      throw UnimplementedError('ExampleAdapter: 播放器设置弹窗');

  @override
  Widget buildLocalIntroPanel({required Key key, required String heroTag}) =>
      throw UnimplementedError('ExampleAdapter: 本地视频简介面板');

  @override
  Widget buildUgcIntroPanel({
    required Key key,
    required String heroTag,
    required bool isPortrait,
    required bool isHorizontal,
  }) =>
      throw UnimplementedError('ExampleAdapter: 投稿视频简介面板');

  @override
  Widget buildRelatedPanel({required Key key, required String heroTag}) =>
      throw UnimplementedError('ExampleAdapter: 相关视频面板');

  @override
  Widget buildReplyPanel({
    required Key key,
    required String heroTag,
    bool isNested = false,
  }) =>
      throw UnimplementedError('ExampleAdapter: 评论面板');

  @override
  Widget buildReplyTabLabel({required String heroTag}) =>
      throw UnimplementedError('ExampleAdapter: 评论 tab 标签(含数量)');

  @override
  void animateReplyToTop(String heroTag) =>
      throw UnimplementedError('ExampleAdapter: 评论列表滚回顶部');

  @override
  Future<void> showShootDanmakuSheet({
    required String heroTag,
    required String bvid,
    required int cid,
    required int progress,
    String? initialValue,
    void Function(String?)? onSave,
    ({int? mode, int? fontSize, Color? color})? dmConfig,
    ValueChanged<({int mode, int fontSize, Color color})>? onSaveDmConfig,
  }) =>
      throw UnimplementedError('ExampleAdapter: 发送弹幕面板');

  @override
  void startIntroTimer(String heroTag) =>
      throw UnimplementedError('ExampleAdapter: 简介控制器定时器');

  @override
  void cancelIntroTimer(String heroTag) =>
      throw UnimplementedError('ExampleAdapter: 取消简介定时器');

  @override
  void disposeIntro(String heroTag) =>
      throw UnimplementedError('ExampleAdapter: 销毁简介控制器');

  @override
  bool nextPlay(String heroTag) => false;

  @override
  Future<void> viewLater(String heroTag) =>
      throw UnimplementedError('ExampleAdapter: 稍后再看');

  @override
  ({int width, int height})? partDimension(String heroTag, int cid) => null;

  @override
  String? videoTitle(String heroTag) => null;

  @override
  CoreFileEntryInfo? fileEntryInfo(Object? entry) => null;

  @override
  bool get isShutdownTimerWaiting => false;

  @override
  void handleShutdownTimer() {}
}
