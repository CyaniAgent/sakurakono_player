import 'package:go_router/go_router.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_app_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_auth_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_black_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_danmaku_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_dynamics_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_fan_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_fav_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_follow_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_im_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_member_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_msg_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_reply_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_user_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_video_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_download_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_progress_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_sponsor_block_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_search_repository.dart';
import 'package:skf/adapters/ottohub/services/otto_account_provider.dart';
import 'package:skf/adapters/ottohub/services/otto_dynamics_host.dart';
import 'package:skf/adapters/ottohub/services/otto_download_actions.dart';
import 'package:skf/adapters/ottohub/services/otto_member_host.dart';
import 'package:skf/adapters/ottohub/services/otto_mine_actions.dart';
import 'package:skf/adapters/ottohub/services/otto_setting_host.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/adapters/ottohub/services/otto_main_host.dart';
import 'package:skf/adapters/ottohub/services/otto_video_host.dart';
import 'package:skf/core/adapter/app_adapter.dart';
import 'package:skf/core/adapter/play_input_kind.dart';
import 'package:skf/core/models/media_id.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/adapters/riverpod_adapter_overrides.dart';
import 'package:skf/pages/home/controller.dart';
import 'package:skf/pages/main/controller.dart';
import 'package:skf/pages/providers.dart';
import 'package:skf/pages/hot/view.dart';
import 'package:skf/pages/webview/view.dart';
import 'package:skf/pages/video/view.dart';
import 'package:skf/pages/setting/view.dart';
import 'package:skf/pages/fav/view.dart';
import 'package:skf/pages/later/view.dart';
import 'package:skf/pages/history/view.dart';
import 'package:skf/pages/search/view.dart';
import 'package:skf/pages/search_result/view.dart';
import 'package:skf/pages/dynamics/view.dart';
import 'package:skf/pages/follow/view.dart';
import 'package:skf/pages/fan/view.dart';
import 'package:skf/pages/member/view.dart';
import 'package:skf/pages/blacklist/view.dart';
import 'package:skf/pages/setting/pages/font_size_select.dart';
import 'package:skf/pages/setting/pages/display_mode.dart';
import 'package:skf/pages/setting/pages/play_speed_set.dart';
import 'package:skf/pages/setting/pages/bar_set.dart';
import 'package:skf/pages/main/view.dart';
import 'package:skf/pages/follow_type/followed/view.dart';
import 'package:skf/pages/follow_type/follow_same/view.dart';
import 'package:skf/pages/msg_feed_top/reply_me/view.dart';
import 'package:skf/pages/msg_feed_top/at_me/view.dart';
import 'package:skf/pages/msg_feed_top/like_me/view.dart';
import 'package:skf/pages/msg_feed_top/like_detail/view.dart';
import 'package:skf/pages/download/view.dart';
import 'package:skf/utils/extension/string_ext.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// OttoHub adapter implementation of [AppAdapter].
///
/// Registers 13 repository implementations that map to the modern OttoHub SDK
/// API (non-Old modules): Video, Auth, Danmaku, Follow, Black, User, Member,
/// Dynamics, Reply, Fav, Msg, Im, and Fan.
class OttoAdapter implements AppAdapter {
  @override
  String get name => 'ottohub';

  @override
  Future<void> onAppStartPreStorage() async {
    // OttoHub has no pre-storage startup (no Hive TypeAdapters).
  }

  @override
  Future<void> onAppStart() async {
    // OttoHub has no post-storage startup (credentials are restored lazily).
  }

  @override
  Future<void> registerDependencies() async {
    final client = OttohubClient();

    // Register repositories using the modern (non-Old) OttoHub API modules.
    // Riverpod ProviderScope overrides — direct instantiation, no Get.find dependency
    adapterOverrides = <Override>[
      videoRepositoryProvider.overrideWithValue(OttoVideoRepository(client)),
      authRepositoryProvider.overrideWithValue(OttoAuthRepository(client)),
      userRepositoryProvider.overrideWithValue(OttoUserRepository(client)),
      memberRepositoryProvider.overrideWithValue(OttoMemberRepository(client)),
      dynamicsRepositoryProvider.overrideWithValue(OttoDynamicsRepository(client)),
      followRepositoryProvider.overrideWithValue(OttoFollowRepository(client)),
      fanRepositoryProvider.overrideWithValue(OttoFanRepository(client)),
      favRepositoryProvider.overrideWithValue(OttoFavRepository(client)),
      danmakuRepositoryProvider.overrideWithValue(OttoDanmakuRepository(client)),
      replyRepositoryProvider.overrideWithValue(OttoReplyRepository(client)),
      searchRepositoryProvider.overrideWithValue(OttoSearchRepository(client)),
      imRepositoryProvider.overrideWithValue(OttoImRepository(client)),
      progressRepositoryProvider.overrideWithValue(OttoProgressRepository()),
      sponsorBlockRepositoryProvider.overrideWithValue(OttoSponsorBlockRepository()),
      downloadRepositoryProvider.overrideWithValue(OttoDownloadRepository(client)),
      appRepositoryProvider.overrideWithValue(OttoAppRepository()),
      msgRepositoryProvider.overrideWithValue(OttoMsgRepository(client)),
      blackRepositoryProvider.overrideWithValue(OttoBlackRepository(client)),
      // Page hosts / actions (previously Get.lazyPut).
      ottoAccountProvider.overrideWithValue(OttoAccountProvider(client)),
      videoHostProvider.overrideWithValue(OttoVideoHost()),
      settingHostProvider.overrideWithValue(OttoSettingHost()),
      memberHostProvider.overrideWithValue(OttoMemberHost()),
      mainHostProvider.overrideWithValue(OttoMainHost()),
      dynamicsHostProvider.overrideWithValue(OttoDynamicsHost()),
      mineActionsProvider.overrideWithValue(OttoMineActions()),
      downloadActionsProvider.overrideWithValue(OttoDownloadActions()),
      // Generic page bar-state bridges: interface -> Riverpod notifiers.
      mainBarStateProvider.overrideWith((ref) => appRead(mainControllerProvider)),
      homeBarStateProvider.overrideWith((ref) => appRead(homeControllerProvider)),
    ];
  }

  @override
  List<GoRoute> get routes => _routes;

  // 路由表:全部指向框架层页面(lib/pages)+ 上收页面(lib/pages/{rcmd,hot,about,webview})。
  // 纯 B 站专属页(直播/专栏/赛事/音乐区/充电/舰团等)已随适配器删除。
  List<GoRoute> get _routes => [
        // 首页(推荐)——主页壳(侧边栏/底部导航 + 主 tab 页)
        GoRoute(path: '/home', builder: (_, _) => const MainApp()),
        // 热门
        GoRoute(path: '/hot', builder: (_, _) => const HotPage()),
        // 视频详情
        GoRoute(path: '/videoV', builder: (_, _) => const VideoDetailPageV()),
        // 内嵌浏览器
        GoRoute(
          path: '/webview',
          builder: (_, state) => WebviewPage(
            url: state.uri.queryParameters['url'] ?? 'about:blank',
          ),
        ),
        // 设置
        GoRoute(path: '/setting', builder: (_, _) => const SettingPage()),
        // 收藏夹列表
        GoRoute(path: '/fav', builder: (_, _) => const FavPage()),
        // 稍后再看
        GoRoute(path: '/later', builder: (_, _) => const LaterPage()),
        // 历史记录
        GoRoute(
          path: '/history',
          builder: (_, state) => HistoryPage(
            type: state.uri.queryParameters['type'],
          ),
        ),
        // 搜索
        GoRoute(path: '/search', builder: (_, _) => const SearchPage()),
        GoRoute(
          path: '/searchResult',
          builder: (_, _) => const SearchResultPage(),
        ),
        // 动态
        GoRoute(path: '/dynamics', builder: (_, _) => const DynamicsPage()),
        // 关注 / 粉丝
        GoRoute(path: '/follow', builder: (_, _) => const FollowPage()),
        GoRoute(path: '/fan', builder: (_, _) => const FansPage()),
        GoRoute(path: '/followed', builder: (_, _) => const FollowedPage()),
        GoRoute(path: '/sameFollowing', builder: (_, _) => const FollowSamePage()),
        // 用户中心
        GoRoute(
          path: '/member',
          builder: (_, state) => MemberPage(
            mid: state.uri.queryParameters['mid'],
            fromViewAid: state.uri.queryParameters['from_view_aid'],
          ),
        ),
        GoRoute(path: '/blackListPage', builder: (_, _) => const BlackListPage()),
        // 设置子页
        GoRoute(
            path: '/fontSizeSetting', builder: (_, _) => const FontSizeSelectPage()),
        GoRoute(path: '/displayModeSetting', builder: (_, _) => const SetDisplayMode()),
        GoRoute(path: '/playSpeedSet', builder: (_, _) => const PlaySpeedPage()),
        GoRoute(path: '/barSetting', builder: (_, _) => const BarSetPage()),
        // 消息
        GoRoute(path: '/replyMe', builder: (_, _) => const ReplyMePage()),
        GoRoute(path: '/atMe', builder: (_, _) => const AtMePage()),
        GoRoute(path: '/likeMe', builder: (_, _) => const LikeMePage()),
        GoRoute(path: '/msgLikeDetail', builder: (_, _) => const LikeDetailPage()),
        // 下载
        GoRoute(path: '/download', builder: (_, _) => const DownloadPage()),
      ];

  @override
  String processImageUrl(String? originalUrl, {int quality = 1}) {
    // OttoHub images don't need CDN suffix processing
    return originalUrl?.http2https ?? '';
  }

  @override
  String? buildShareLink(CoreMediaId id, {String? title}) {
    // OttoHub has no web share-link concept — pure-numeric IDs only.
    return null;
  }

  @override
  Future<bool> openUrl(String url, {int? businessId, int? oid}) {
    // OttoHub has no deep-link scheme; URLs are unhandled.
    return Future.syncValue(false);
  }

  @override
  PlayInputKind classifyPlayInput(String input) {
    // OttoHub videos are pure-numeric IDs; everything else is unknown
    // (bilibili URLs included — they reach the toast just as before).
    final value = input.trim();
    if (value.isEmpty) return PlayInputKind.unknown;
    if (RegExp(r'^\d+$').hasMatch(value)) return PlayInputKind.numericId;
    return PlayInputKind.unknown;
  }
}
