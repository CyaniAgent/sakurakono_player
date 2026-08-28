import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';

import 'dart:async' show Timer, StreamSubscription;
import 'dart:convert' show jsonDecode;
import 'dart:math' as math;

import 'package:skf/adapters/bilibili/common/widgets/dialog/report.dart';
import 'package:skf/common/widgets/flutter/text_field/controller.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/adapters/bilibili/models/common/super_chat_type.dart'; // ignore: keep until CoreSuperChatType exists
import 'package:skf/adapters/bilibili/models/common/video/live_quality.dart'; // ignore: keep until CoreLiveQuality exists
import 'package:skf/core/models/live_types.dart';
import 'package:skf/adapters/bilibili/pages/common/publish/publish_route.dart';
import 'package:skf/adapters/bilibili/pages/danmaku/danmaku_model.dart';
import 'package:skf/adapters/bilibili/pages/live_room/send_danmaku/view.dart';
import 'package:skf/adapters/bilibili/pages/video_parts/widgets/header_control.dart';
import 'package:skf/adapters/bilibili/plugin/pl_player/controller.dart';
import 'package:skf/player/models/data_source.dart';
import 'package:skf/player/utils/danmaku_options.dart';
import 'package:skf/adapters/bilibili/services/service_locator.dart';
import 'package:skf/adapters/bilibili/tcp/live.dart';
import 'package:skf/adapters/bilibili/utils/accounts.dart';
import 'package:skf/utils/connectivity_utils.dart';
import 'package:skf/utils/danmaku_utils.dart';
import 'package:skf/utils/duration_utils.dart';
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:skf/utils/global_data.dart';
import 'package:skf/utils/num_utils.dart';
import 'package:skf/utils/platform_utils.dart';
import 'package:skf/utils/storage_pref.dart';
import 'package:skf/utils/theme_utils.dart';
import 'package:skf/utils/utils.dart';
import 'package:skf/adapters/bilibili/utils/video_utils.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:easy_debounce/easy_throttle.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:skf/core/container/app_container.dart';

class LiveRoomController extends ChangeNotifier {

  /// Public notify wrapper — [notifyListeners] is protected in
  /// [ChangeNotifier]; views call this to request a rebuild.
  void notifyChange() => notifyListeners();

  final String heroTag;

  int roomId = Get.arguments;
  int? ruid;
  DanmakuController<DanmakuExtra>? danmakuController;
  final plPlayerController = PlPlayerController.getInstance(
    isLive: true,
  );

  bool isLoaded = false;
  CoreRoomInfoH5Data? roomInfoH5;

  int? liveTime;
  Timer? liveTimeTimer;

  void startLiveTimer() {
    if (liveTime != null) {
      liveTimeTimer ??= Timer.periodic(
        const Duration(minutes: 5),
        (_) { liveTime = liveTime; notifyListeners(); },
      );
    }
  }

  void cancelLiveTimer() {
    liveTimeTimer?.cancel();
    liveTimeTimer = null;
  }

  Widget get timeWidget => ListenableBuilder(
    listenable: this,
    builder: (_, _) {
      final liveTime = this.liveTime;
      String text = '';
      if (liveTime != null) {
        final duration = DurationUtils.formatDurationBetween(
          liveTime * 1000,
          DateTime.now().millisecondsSinceEpoch,
        );
        text += duration.isEmpty ? '刚刚开播' : '开播$duration';
      }
      if (text.isEmpty) {
        return const SizedBox.shrink();
      }
      return Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
        ),
      );
    },
  );

  // dm
  CoreLiveDmInfoData? dmInfo;
  List<RichTextItem>? savedDanmaku;
  int builtLength = 0;
  List<dynamic> messages = [];
  bool get shouldRefresh => builtLength != messages.length;
  CoreSuperChatItem? fsSC;
  List<CoreSuperChatItem> superChatMsg = [];
  bool disableAutoScroll = false;
  bool autoScroll = true;
  LiveMessageStream? _msgCoreStream;
  late final ScrollController scrollController;
  int pageIndex = 0;
  PageController? pageController;

  int? currentQn = PlatformUtils.isMobile ? null : Pref.liveQuality;
  String currentQnDesc = '';
  bool isPortrait = false;
  late List<({int code, String desc})> acceptQnList = [];

  late final bool isLogin;
  late final int mid;

  String? videoUrl;
  bool? isPlaying;
  late bool isFullScreen = false;

  final superChatType = SuperChatType.values[Pref.superChatType];
  late final showSuperChat = superChatType != SuperChatType.disable;

  final headerKey = GlobalKey<TimeBatteryMixin>();

  String title = '';

  String? onlineCount;

  String? watchedShow;
  Widget get watchedWidget => ListenableBuilder(
    listenable: this,
    builder: (_, _) {
      if (watchedShow case final watchedShow?) {
        return Text(
          watchedShow,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        );
      }
      return const SizedBox.shrink();
    },
  );

  StreamSubscription? _sizeSub;

  void _onSizeChanged((int, int) value) {
    final isVertical = value.$2 > value.$1;
    isPortrait = isVertical;
    plPlayerController.isVertical = isVertical;
  }

  void _startSizeSub() {
    if (isPortrait) return;
    _stopSizeSub();
    _sizeSub = plPlayerController.videoPlayerController?.stream.size.listen(
      _onSizeChanged,
    );
  }

  void _stopSizeSub() {
    _sizeSub?.cancel();
    _sizeSub = null;
  }

  LiveRoomController(this.heroTag) {
    scrollController = ScrollController()..addListener(listener);
    final account = Accounts.main;
    isLogin = account.isLogin;
    mid = account.mid;
    queryLiveUrl(autoFullScreenFlag: true);
    queryLiveInfoH5();
    if (Accounts.heartbeat.isLogin && !Pref.historyPause) {
      (appRead(videoRepositoryProvider)).roomEntryAction(roomId: roomId);
    }
    if (showSuperChat) {
      pageController = PageController();
    }
  }

  Future<void>? playerInit({
    bool autoplay = true,
    bool autoFullScreenFlag = false,
  }) {
    if (videoUrl == null) {
      return null;
    }
    return plPlayerController.setDataSource(
      NetworkSource(videoSource: videoUrl!, audioSource: null),
      isLive: true,
      autoplay: autoplay,
      isVertical: isPortrait,
      autoFullScreenFlag: autoFullScreenFlag,
    );
  }

  Future<void> queryLiveUrl({bool autoFullScreenFlag = false}) async {
    currentQn ??= await ConnectivityUtils.isWiFi
        ? Pref.liveQuality
        : Pref.liveQualityCellular;
    final res = await (appRead(liveRepositoryProvider)).liveRoomInfo(
      roomId: roomId,
      qn: currentQn,
      onlyAudio: plPlayerController.onlyPlayAudio,
    );
    if (res case Success(:final response)) {
      if (response.liveStatus != 1) {
        _showDialog('当前直播间未开播');
        return;
      }
      final playurl = response.playurlInfo?.playurl;
      if (playurl == null) {
        _showDialog('无法获取播放地址');
        return;
      }
      ruid = response.uid;
      if (response.roomId case final roomId?) {
        this.roomId = roomId;
      }
      liveTime = response.liveTime;
      startLiveTimer();
      isPortrait = response.isPortrait ?? false;
      stream = playurl.stream;
      _initCoreStreamIndex();
      await initLiveUrl(
        streamIndex: streamIndex,
        formatIndex: formatIndex,
        codecIndex: codecIndex,
        liveUrlIndex: liveUrlIndex,
      );
      isLoaded = true;
      notifyListeners();
    } else {
      _showDialog(res.toString());
    }
  }

  late List<CoreStream> stream;
  int streamIndex = 0;
  int formatIndex = 0;
  int codecIndex = 0;
  int liveUrlIndex = 0;

  void _initCoreStreamIndex() {
    final pref = Pref.liveStream;
    if (pref != null) {
      try {
        final String protocolName = pref[0];
        final String formatName = pref[1];
        final String codecName = pref[2];
        for (var (i, s) in stream.indexed) {
          if (s.protocolName == protocolName) {
            streamIndex = i;
            for (var (j, f) in s.format.indexed) {
              if (f.formatName == formatName) {
                formatIndex = j;
                for (var (k, c) in f.codec.indexed) {
                  if (c.codecName == codecName) {
                    codecIndex = k;
                    return;
                  }
                }
              }
            }
          }
        }
      } catch (_) {}
    }
  }

  Future<void>? initLiveUrl({
    int streamIndex = 0,
    int formatIndex = 0,
    int codecIndex = 0,
    int liveUrlIndex = 0,
  }) {
    this.streamIndex = streamIndex;
    this.formatIndex = formatIndex;
    this.codecIndex = codecIndex;
    this.liveUrlIndex = liveUrlIndex;

    final CoreCodecItem item = stream
        .getOrFirst(streamIndex)
        .format
        .getOrFirst(formatIndex)
        .codec
        .getOrFirst(codecIndex);
    // 以服务端返回的码率为准
    currentQn = item.currentQn;
    acceptQnList = item.acceptQn.map((e) {
      return (
        code: e,
        desc: LiveQuality.fromCode(e)?.desc ?? e.toString(),
      );
    }).toList();
    currentQnDesc =
        LiveQuality.fromCode(currentQn)?.desc ?? currentQn.toString();
    videoUrl = VideoUtils.getLiveCdnUrl(item, index: liveUrlIndex);
    return playerInit()?.whenComplete(_startSizeSub);
  }

  Future<void> queryLiveInfoH5() async {
    final res = await (appRead(liveRepositoryProvider)).liveRoomInfoH5(roomId: roomId);
    if (res case Success(:final response)) {
      roomInfoH5 = response;
      title = response.roomInfo?.title ?? '';
      watchedShow = response.watchedShow?.textLarge;
      notifyListeners();
      videoPlayerServiceHandler?.onVideoDetailChange(response, roomId, heroTag);
    } else {
      SmartDialog.showToast(res.toString());
    }
  }

  void _showDialog(String title) {
    showDialog(
      context: Get.context!,
      builder: (_) => AlertDialog(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              '关闭',
              style: TextStyle(color: ThemeUtils.theme.colorScheme.outline),
            ),
          ),
          TextButton(
            onPressed: () {
              if (plPlayerController.isDesktopPip) {
                plPlayerController.exitDesktopPip();
              }
              Get
                ..back()
                ..back();
            },
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  void scrollToBottom([_]) {
    EasyThrottle.throttle(
      'liveDm',
      const Duration(milliseconds: 500),
      () => WidgetsBinding.instance.addPostFrameCallback(
        _scrollToBottom,
      ),
    );
  }

  void _scrollToBottom([_]) {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linearToEaseOut,
      );
    }
  }

  void handleJumpToBottom() {
    disableAutoScroll = false;
    if (shouldRefresh) {
      notifyListeners();
      WidgetsBinding.instance.addPostFrameCallback(_jumpToBottom);
    } else {
      _jumpToBottom();
    }
  }

  void _jumpToBottom([_]) {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  void closeLiveMsg() {
    _msgCoreStream?.close();
    _msgCoreStream = null;
  }

  @pragma('vm:notify-debugger-on-exception')
  Future<void> prefetch() async {
    final res = await (appRead(liveRepositoryProvider)).liveRoomDmPrefetch(roomId: roomId);
    if (res case Success(:final response)) {
      if (response != null && response.isNotEmpty) {
        messages.addAll(response);
        scrollToBottom();
      }
    } else {
      if (kDebugMode) {
        Utils.reportError(res.toString());
      }
    }
  }

  Future<void> getSuperChatMsg() async {
    final res = await (appRead(liveRepositoryProvider)).superChatMsg(roomId);
    if (res.dataOrNull?.list case final list?) {
      superChatMsg.addAll(list);
    }
  }

  void clearSC() {
    superChatMsg.removeWhere((e) => e.expired);
  }

  void startLiveMsg() {
    if (messages.isEmpty) {
      prefetch();
      if (showSuperChat) {
        getSuperChatMsg();
      }
    }
    if (_msgCoreStream != null) {
      return;
    }
    if (dmInfo != null) {
      initDm(dmInfo!);
      return;
    }
      (appRead(liveRepositoryProvider)).liveRoomGetDanmakuToken(roomId: roomId).then((res) {
        if (res case Success(:final response)) {
          initDm(dmInfo = response);
        }
      }).catchError((Object _) {});
  }

  void listener() {
    final userScrollDirection = scrollController.position.userScrollDirection;
    if (userScrollDirection == .forward) {
        disableAutoScroll = true;
    } else if (userScrollDirection == .reverse) {
      final pos = scrollController.position;
      if (pos.maxScrollExtent - pos.pixels <= 100 && disableAutoScroll) {
        disableAutoScroll = false;
        refreshMsgIfNeeded();
      }
    }
  }

  void refreshMsgIfNeeded() {
    if (shouldRefresh) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _stopSizeSub();
    closeLiveMsg();
    cancelLikeTimer();
    cancelLiveTimer();
    savedDanmaku?.clear();
    savedDanmaku = null;
    messages.clear();
    if (showSuperChat) {
      superChatMsg.clear();
      fsSC = null;
    }
    scrollController
      ..removeListener(listener)
      ..dispose();
    pageController?.dispose();
    danmakuController = null;
    super.dispose();
  }

  // 修改画质
  Future<void>? changeQn(int qn) {
    if (currentQn == qn) {
      return null;
    }
    currentQn = qn;
    currentQnDesc =
        LiveQuality.fromCode(currentQn)?.desc ?? currentQn.toString();
    return queryLiveUrl();
  }

  void initDm(CoreLiveDmInfoData info) {
    if (info.hostList.isNullOrEmpty) {
      return;
    }
    _msgCoreStream =
        LiveMessageStream(
            streamToken: info.token,
            roomId: roomId,
            uid: Accounts.heartbeat.mid,
            servers: info.hostList
                .map((host) => 'wss://${host.host}:${host.wssPort}/sub')
                .toList(),
          )
          ..addEventListener(_danmakuListener)
          ..init();
  }

  void addDm(dynamic msg, [DanmakuContentItem<DanmakuExtra>? item]) {
    if (plPlayerController.showDanmaku) {
      if (item != null && plPlayerController.enableShowLiveDanmaku) {
        danmakuController?.addDanmaku(item);
      }
      if (autoScroll && !disableAutoScroll) {
        messages.add(msg);
        return;
      }
    }

    if (!messages.contains(msg)) messages.add(msg);
  }

  @pragma('vm:notify-debugger-on-exception')
  void _danmakuListener(dynamic obj) {
    try {
      // logger.i(' 原始弹幕消息 ======> ${jsonEncode(obj)}');
      switch (obj['cmd']) {
        case 'DANMU_MSG':
          final info = obj['info'];
          final first = info[0];
          final content = first[15];
          final Map<String, dynamic> extra = jsonDecode(content['extra']);
          final user = content['user'];
          // final midHash = first[7];
          final uid = user['uid'];
          final name = user['base']['name'];
          final msg = info[1];
          CoreLiveBaseEmote? uemote;
          if (first[13] case Map<String, dynamic> map) {
            uemote = CoreLiveBaseEmote.fromJson(map);
          }
          final checkInfo = info[9];
          final liveExtra = LiveDanmaku(
            id: extra['id_str'],
            mid: uid,
            dmType: extra['dm_type'],
            ts: checkInfo['ts'],
            ct: checkInfo['ct'],
          );
          final coreExtra = CoreLiveDanmakuExtra(
            id: extra['id_str'],
            mid: uid,
            dmType: extra['dm_type'],
            ts: checkInfo['ts'],
            ct: checkInfo['ct'],
          );
          CoreLiveOwner? reply;
          final replyMid = extra['reply_mid'];
          if (replyMid != null && replyMid != 0) {
            reply = CoreLiveOwner(
              mid: replyMid,
              name: extra['reply_uname'],
            );
          }
          addDm(
            CoreDanmakuMsg(
              name: name,
              text: msg,
              emots: (extra['emots'] as Map<String, dynamic>?)?.map(
                (k, v) => MapEntry(k, CoreLiveBaseEmote.fromJson(v)),
              ),
              uemote: uemote,
              extra: coreExtra,
              reply: reply,
              medalInfo: !GlobalData().showMedal || user['medal'] == null
                  ? null
                  : CoreUinfoMedal.fromJson(user['medal']),
            ),
            DanmakuContentItem(
              msg,
              color: DanmakuOptions.blockColorful
                  ? Colors.white
                  : DmUtils.decimalToColor(extra['color']),
              type: DmUtils.getPosition(extra['mode']),
              // extra['send_from_me'] is invalid
              selfSend: isLogin && uid == mid,
              extra: liveExtra,
            ),
          );
          break;
        case 'SUPER_CHAT_MESSAGE' when showSuperChat:
          final item = CoreSuperChatItem.fromJson(obj['data']);
          superChatMsg.insert(0, item);
          if (plPlayerController.showDanmaku &&
              (isFullScreen || plPlayerController.isDesktopPip)) {
            fsSC = item.copyWith(
              endTime: math.min(
                item.endTime,
                DateTime.now().millisecondsSinceEpoch ~/ 1000 + 10,
              ),
            );
          }
          addDm(item);
          break;
        // case 'SUPER_CHAT_MESSAGE_DELETE' when showSuperChat:
        //   if (obj['roomid'] == roomId) {
        //     final ids = obj['data']?['ids'] as List?;
        //     if (ids != null && ids.isNotEmpty) {
        //       if (superChatType == .valid) {
        //         superChatMsg.removeWhere((e) => ids.contains(e.id));
        //       } else {
        //         bool? refresh;
        //         for (final id in ids) {
        //           if (superChatMsg.firstWhereOrNull((e) => e.id == id)
        //               case final item?) {
        //             item.deleted = true;
        //             refresh ??= true;
        //           }
        //         }
        //         if (refresh ?? false) {
        //           superChatMsg.refresh();
        //         }
        //       }
        //     }
        //   }
        case 'WATCHED_CHANGE':
          watchedShow = obj['data']['text_large'];
          break;
        case 'ONLINE_RANK_COUNT':
          onlineCount = NumUtils.numFormat(obj['data']['count']);
          break;
        case 'ROOM_CHANGE':
          title = obj['data']['title'];
          break;
      }
    } catch (e, s) {
      if (kDebugMode) {
        Utils.reportError(e, s);
      }
    }
  }

  int likeClickTime = 0;
  Timer? likeClickTimer;

  void cancelLikeTimer() {
    likeClickTimer?.cancel();
    likeClickTimer = null;
  }

  void onLikeTapDown([_]) {
    cancelLikeTimer();
    likeClickTime++;
    notifyListeners();
  }

  void onLikeTapUp([_]) {
    likeClickTimer ??= Timer(
      const Duration(milliseconds: 800),
      onLike,
    );
  }

  Future<void> onLike() async {
    if (!isLogin) {
      likeClickTime = 0;
      return;
    }
    final res = await (appRead(liveRepositoryProvider)).liveLikeReport(
      clickTime: likeClickTime,
      roomId: roomId,
      uid: mid,
      anchorId: roomInfoH5?.roomInfo?.uid,
    );
    if (res.isSuccess) {
      SmartDialog.showToast('点赞成功');
    } else {
      SmartDialog.showToast(res.toString());
    }
    likeClickTime = 0;
    notifyListeners();
  }

  void onSendDanmaku([bool fromEmote = false]) {
    if (kReleaseMode && !isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    Get.key.currentState!.push(
      PublishRoute(
        barrierColor: Colors.transparent,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Theme(
            data: ThemeUtils.darkTheme,
            child: LiveSendDmPanel(
              fromEmote: fromEmote,
              liveRoomController: this,
              items: savedDanmaku,
              autofocus: !fromEmote,
              onSave: (msg) {
                if (msg.isEmpty) {
                  savedDanmaku?.clear();
                  savedDanmaku = null;
                } else {
                  savedDanmaku = msg.toList();
                }
              },
            ),
          );
        },
        transitionDuration: fromEmote
            ? const Duration(milliseconds: 400)
            : const Duration(milliseconds: 500),
      ),
    );
  }

  void reportSC(CoreSuperChatItem item) {
    if (!isLogin) {
      SmartDialog.showToast('账号未登录');
      return;
    }
    autoWrapReportDialog(
      Get.context!,
      ban: false,
      ReportOptions.liveDanmakuReport,
      (reasonType, reasonDesc, banUid) {
        return (appRead(liveRepositoryProvider)).superChatReport(
          id: item.id,
          roomId: roomId,
          uid: item.uid,
          msg: item.message,
          reason: ReportOptions.liveDanmakuReport['']![reasonType]!,
          ts: item.ts,
          token: item.token,
        );
      },
    );
  }
}
