import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/adapters/bilibili/services/bili_account_provider.dart';
import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/adapters/bilibili/models/model_owner.dart';
import 'package:skf/adapters/bilibili/models/user/danmaku_rule_adapter.dart';
import 'package:skf/adapters/bilibili/models/user/info.dart';
import 'package:skf/adapters/bilibili/services/account_service.dart';
import 'package:skf/adapters/bilibili/services/download/download_service.dart';
import 'package:skf/adapters/bilibili/services/service_locator.dart';
import 'package:skf/adapters/bilibili/utils/accounts/account_adapter.dart';
import 'package:skf/adapters/bilibili/utils/accounts/account_type_adapter.dart';
import 'package:skf/adapters/bilibili/utils/accounts/cookie_jar_adapter.dart';
import 'package:skf/adapters/bilibili/utils/request_utils.dart';
import 'package:skf/adapters/riverpod_adapter_overrides.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/pages/common/common_page.dart';
import 'package:skf/adapters/bilibili/pages/article/view.dart';
import 'package:skf/adapters/bilibili/pages/article_list/view.dart';
import 'package:skf/adapters/bilibili/pages/audio/view.dart';
import 'package:skf/pages/blacklist/view.dart';
import 'package:skf/adapters/bilibili/pages/bubble/view.dart';
import 'package:skf/adapters/bilibili/pages/danmaku_block/view.dart';
import 'package:skf/adapters/bilibili/pages/dlna/view.dart';
import 'package:skf/adapters/bilibili/common/download_actions.dart';
import 'package:skf/pages/download/download_actions.dart';
import 'package:skf/pages/download/view.dart';
import 'package:skf/pages/dynamics/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_create_vote/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_detail/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_topic/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_topic_rcmd/view.dart';
import 'package:skf/adapters/bilibili/common/dynamics_host.dart';
import 'package:skf/adapters/bilibili/common/mine_actions.dart';
import 'package:skf/adapters/bilibili/common/setting_host.dart';
import 'package:skf/pages/dynamics/dynamics_host.dart';
import 'package:skf/pages/fan/view.dart';
import 'package:skf/pages/mine/mine_actions.dart';
import 'package:skf/pages/fav/view.dart';
import 'package:skf/adapters/bilibili/pages/fav_create/view.dart';
import 'package:skf/adapters/bilibili/pages/fav_detail/view.dart';
import 'package:skf/adapters/bilibili/pages/fav_search/view.dart';
import 'package:skf/pages/follow/view.dart';
import 'package:skf/adapters/bilibili/pages/follow_search/view.dart';
import 'package:skf/pages/follow_type/follow_same/view.dart';
import 'package:skf/pages/follow_type/followed/view.dart';
import 'package:skf/pages/history/view.dart';
import 'package:skf/adapters/bilibili/pages/history_search/view.dart';
import 'package:skf/pages/home/view.dart';
import 'package:skf/pages/home/controller.dart';
import 'package:skf/adapters/bilibili/pages/hot/view.dart';
import 'package:skf/adapters/bilibili/utils/fav_actions.dart';
import 'package:skf/adapters/bilibili/utils/history_actions.dart';
import 'package:skf/adapters/bilibili/utils/later_actions.dart';
import 'package:skf/pages/later/view.dart';
import 'package:skf/adapters/bilibili/pages/later_search/view.dart';
import 'package:skf/adapters/bilibili/pages/live_dm_block/view.dart';
import 'package:skf/adapters/bilibili/pages/live_room/view.dart';
import 'package:skf/adapters/bilibili/pages/login/view.dart';
import 'package:skf/adapters/bilibili/pages/main_reply/view.dart';
import 'package:skf/adapters/bilibili/pages/match_info/view.dart';
import 'package:skf/adapters/bilibili/common/member_host.dart';
import 'package:skf/pages/member/member_host.dart';
import 'package:skf/pages/member/view.dart';
import 'package:skf/adapters/bilibili/pages/member_dynamics/view.dart';
import 'package:skf/adapters/bilibili/pages/member_guard/view.dart';
import 'package:skf/adapters/bilibili/pages/member_profile/view.dart';
import 'package:skf/adapters/bilibili/pages/member_search/view.dart';
import 'package:skf/adapters/bilibili/pages/member_upower_rank/view.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/archive/view.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/season_series/view.dart';
import 'package:skf/pages/msg_feed_top/at_me/view.dart';
import 'package:skf/pages/msg_feed_top/like_detail/view.dart';
import 'package:skf/pages/msg_feed_top/like_me/view.dart';
import 'package:skf/pages/msg_feed_top/reply_me/view.dart';
import 'package:skf/adapters/bilibili/pages/msg_feed_top/sys_msg/view.dart';
import 'package:skf/adapters/bilibili/pages/music/view.dart';
import 'package:skf/adapters/bilibili/pages/my_reply/view.dart';
import 'package:skf/adapters/bilibili/common/main_host.dart';
import 'package:skf/pages/main/main_host.dart';
import 'package:skf/pages/main/controller.dart';
import 'package:skf/adapters/bilibili/pages/popular_precious/view.dart';
import 'package:skf/adapters/bilibili/pages/popular_series/view.dart';
import 'package:skf/adapters/bilibili/pages/search_panel/builder.dart';
import 'package:skf/pages/search/view.dart';
import 'package:skf/pages/search_result/view.dart';
import 'package:skf/adapters/bilibili/pages/search_trending/view.dart';
import 'package:skf/pages/setting/pages/bar_set.dart';
import 'package:skf/adapters/bilibili/pages/setting_parts/pages/color_select.dart';
import 'package:skf/pages/setting/pages/display_mode.dart';
import 'package:skf/pages/setting/pages/font_size_select.dart';
import 'package:skf/adapters/bilibili/pages/setting_parts/pages/logs.dart';
import 'package:skf/pages/setting/pages/play_speed_set.dart';
import 'package:skf/pages/setting/setting_host.dart';
import 'package:skf/pages/setting/view.dart';
import 'package:skf/adapters/bilibili/pages/settings_search/view.dart';
import 'package:skf/adapters/bilibili/pages/space_setting/view.dart';
import 'package:skf/adapters/bilibili/pages/sponsor_block/view.dart';
import 'package:skf/adapters/bilibili/pages/subscription/view.dart';
import 'package:skf/adapters/bilibili/pages/subscription_detail/view.dart';
import 'package:skf/adapters/bilibili/common/video_host.dart';
import 'package:skf/pages/video/video_host.dart';
import 'package:skf/pages/video/view.dart';
import 'package:skf/adapters/bilibili/pages/webview/view.dart';
import 'package:skf/adapters/bilibili/pages/whisper/view.dart';
import 'package:skf/adapters/bilibili/pages/whisper_detail/view.dart';
import 'package:skf/adapters/bilibili/pages/whisper_settings/view.dart';
import 'package:skf/adapters/bilibili/repository/bili_app_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_audio_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_auth_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_black_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_danmaku_filter_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_danmaku_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_download_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_dynamics_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_fan_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_fav_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_follow_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_im_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_live_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_match_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_member_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_msg_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_music_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_pgc_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_progress_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_reply_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_search_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_space_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_sponsor_block_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_user_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_validate_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_video_repository.dart';
import 'package:skf/core/repository/app_repository.dart';
import 'package:skf/core/repository/audio_repository.dart';
import 'package:skf/core/repository/auth_repository.dart';
import 'package:skf/core/repository/black_repository.dart';
import 'package:skf/core/repository/danmaku_filter_repository.dart';
import 'package:skf/core/repository/danmaku_repository.dart';
import 'package:skf/core/repository/download_repository.dart';
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/repository/fan_repository.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/repository/follow_repository.dart';
import 'package:skf/core/repository/im_repository.dart';
import 'package:skf/core/repository/live_repository.dart';
import 'package:skf/core/repository/match_repository.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/repository/music_repository.dart';
import 'package:skf/core/repository/pgc_repository.dart';
import 'package:skf/core/repository/progress_repository.dart';
import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/repository/space_repository.dart';
import 'package:skf/core/repository/sponsor_block_repository.dart';
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/repository/validate_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:get/get.dart';
import 'package:hive_ce/hive.dart';

class BiliBridge {
  static bool _initialized = false;
  static bool _hiveInitialized = false;

  static void initHive() {
    if (_hiveInitialized) return;
    _hiveInitialized = true;

    Hive
      ..registerAdapter(OwnerAdapter())
      ..registerAdapter(UserInfoDataAdapter())
      ..registerAdapter(LevelInfoAdapter())
      ..registerAdapter(BiliCookieJarAdapter())
      ..registerAdapter(LoginAccountAdapter())
      ..registerAdapter(AccountTypeAdapter())
      ..registerAdapter(RuleFilterAdapter());
  }

  static void register() {
    if (_initialized) return;
    _initialized = true;

    initHive();
    Get
      ..lazyPut<AccountProvider>(BiliAccountProvider.new)
      ..lazyPut(AccountService.new)
      ..lazyPut(DownloadService.new)
      // Repositories
      ..lazyPut<VideoRepository>(BiliVideoRepository.new)
      ..lazyPut<UserRepository>(BiliUserRepository.new)
      ..lazyPut<AuthRepository>(BiliAuthRepository.new)
      ..lazyPut<BiliSearchRepository>(BiliSearchRepository.new)
      ..lazyPut<SearchRepository>(() => Get.find<BiliSearchRepository>())
      ..lazyPut<ReplyRepository>(BiliReplyRepository.new)
      ..lazyPut<FavRepository>(BiliFavRepository.new)
      ..lazyPut<DynamicsRepository>(BiliDynamicsRepository.new)
      ..lazyPut<MemberRepository>(BiliMemberRepository.new)
      ..lazyPut<LiveRepository>(BiliLiveRepository.new)
      ..lazyPut<MsgRepository>(BiliMsgRepository.new)
      ..lazyPut<ImRepository>(BiliImRepository.new)
      ..lazyPut<DanmakuRepository>(BiliDanmakuRepository.new)
      ..lazyPut<MusicRepository>(BiliMusicRepository.new)
      ..lazyPut<DanmakuFilterRepository>(BiliDanmakuFilterRepository.new)
      ..lazyPut<FollowRepository>(BiliFollowRepository.new)
      ..lazyPut<AudioRepository>(BiliAudioRepository.new)
      ..lazyPut<FanRepository>(BiliFanRepository.new)
      ..lazyPut<BlackRepository>(BiliBlackRepository.new)
      ..lazyPut<MatchRepository>(BiliMatchRepository.new)
      ..lazyPut<SpaceRepository>(BiliSpaceRepository.new)
      ..lazyPut<DownloadRepository>(BiliDownloadRepository.new)
      ..lazyPut<PgcRepository>(BiliPgcRepository.new)
      ..lazyPut<SponsorBlockRepository>(BiliSponsorBlockRepository.new)
      ..lazyPut<ValidateRepository>(BiliValidateRepository.new)
      ..lazyPut<ProgressRepository>(BiliProgressRepository.new)
      ..lazyPut<AppRepository>(BiliAppRepository.new)
      // Generic page bar-state bridges: interface -> Riverpod notifiers
      ..lazyPut<MainControllerNotifier>(MainControllerNotifier.new)
      ..lazyPut<HomeBarState>(() => Get.find<HomeControllerNotifier>())
      ..lazyPut<HomeControllerNotifier>(HomeControllerNotifier.new)
      ..lazyPut<MainBarState>(() => Get.find<MainControllerNotifier>())
      // Main shell host (tabs, home subtabs, dyn badge, scheme, update)
      ..lazyPut<MainHost>(BiliMainHost.new)
      // Dynamics page host (tab pages, deep dialogs, URL routing)
      ..lazyPut<DynamicsHost>(BiliDynamicsHost.new)
      // Mine page host (menu items, account ops, header actions)
      ..lazyPut<MineActions>(BiliMineActions.new)
      // Member page host (sub-page tabs, deep dialogs, URL routing)
      ..lazyPut<MemberHost>(BiliMemberHost.new)
      // Download page host (download service + local playback navigation)
      ..lazyPut<DownloadActions>(BiliDownloadActions.new)
      // Video page host (player extras, danmaku, reply, intro panels, sheets)
      ..lazyPut<VideoHost>(BiliVideoHost.new)
      // Setting page host (menu items, account ops, play-input dispatch)
      ..lazyPut<SettingHost>(BiliSettingHost.new);
    setupServiceLocator();
    _initHttp();
    adapterOverrides = buildAdapterOverrides();
  }

  static void _initHttp() {
    Request();
    Request.setCookie();
    RequestUtils.syncHistoryStatus();
  }

  /// 构建 26 个核心 repository provider 的 Riverpod overrides。
  /// 使用 overrideWith（延迟闭包）——Get.find 在首次读取时才执行，
  /// 确保 activate() 与 GetX DI 完成后才解析。
  static List<Override> buildAdapterOverrides() {
    return <Override>[
      videoRepositoryProvider.overrideWith((ref) => Get.find<VideoRepository>()),
      audioRepositoryProvider.overrideWith((ref) => Get.find<AudioRepository>()),
      authRepositoryProvider.overrideWith((ref) => Get.find<AuthRepository>()),
      userRepositoryProvider.overrideWith((ref) => Get.find<UserRepository>()),
      memberRepositoryProvider.overrideWith((ref) => Get.find<MemberRepository>()),
      dynamicsRepositoryProvider.overrideWith((ref) => Get.find<DynamicsRepository>()),
      followRepositoryProvider.overrideWith((ref) => Get.find<FollowRepository>()),
      fanRepositoryProvider.overrideWith((ref) => Get.find<FanRepository>()),
      favRepositoryProvider.overrideWith((ref) => Get.find<FavRepository>()),
      danmakuRepositoryProvider.overrideWith((ref) => Get.find<DanmakuRepository>()),
      replyRepositoryProvider.overrideWith((ref) => Get.find<ReplyRepository>()),
      searchRepositoryProvider.overrideWith((ref) => Get.find<SearchRepository>()),
      imRepositoryProvider.overrideWith((ref) => Get.find<ImRepository>()),
      pgcRepositoryProvider.overrideWith((ref) => Get.find<PgcRepository>()),
      progressRepositoryProvider.overrideWith((ref) => Get.find<ProgressRepository>()),
      sponsorBlockRepositoryProvider.overrideWith((ref) => Get.find<SponsorBlockRepository>()),
      validateRepositoryProvider.overrideWith((ref) => Get.find<ValidateRepository>()),
      liveRepositoryProvider.overrideWith((ref) => Get.find<LiveRepository>()),
      matchRepositoryProvider.overrideWith((ref) => Get.find<MatchRepository>()),
      musicRepositoryProvider.overrideWith((ref) => Get.find<MusicRepository>()),
      downloadRepositoryProvider.overrideWith((ref) => Get.find<DownloadRepository>()),
      spaceRepositoryProvider.overrideWith((ref) => Get.find<SpaceRepository>()),
      appRepositoryProvider.overrideWith((ref) => Get.find<AppRepository>()),
      danmakuFilterRepositoryProvider.overrideWith((ref) => Get.find<DanmakuFilterRepository>()),
      msgRepositoryProvider.overrideWith((ref) => Get.find<MsgRepository>()),
      blackRepositoryProvider.overrideWith((ref) => Get.find<BlackRepository>()),
    ];
  }

  /// Convert GetX GetPage routes to GoRouter GoRoute routes.
  static List<GoRoute> buildRoutes() {
    return [
      // 首页(推荐)
      GoRoute(path: '/home', builder: (_, _) => const HomePage()),
      // 热门
      GoRoute(path: '/hot', builder: (_, _) => const HotPage()),
      // 视频详情
      GoRoute(path: '/videoV', builder: (_, _) => const VideoDetailPageV()),
      //
      GoRoute(path: '/webview', builder: (_, _) => const WebviewPage()),
      // 设置
      GoRoute(path: '/setting', builder: (_, _) => const SettingPage()),
      //
      GoRoute(path: '/fav', builder: (_, _) => FavPage(actions: biliFavActions)),
      //
      GoRoute(path: '/favDetail', builder: (_, _) => const FavDetailPage()),
      GoRoute(
        path: '/later',
        builder: (_, _) => LaterPage(actions: biliLaterActions),
      ),
      GoRoute(
        path: '/history',
        builder: (_, _) => HistoryPage(actions: biliHistoryActions),
      ),
      // 搜索页面
      GoRoute(path: '/search', builder: (_, _) => const SearchPage()),
      // 搜索结果
      GoRoute(path: '/searchResult', builder: (_, _) => const SearchResultPage(panelBuilder: biliSearchPanelBuilder)),
      // 动态
      GoRoute(path: '/dynamics', builder: (_, _) => const DynamicsPage()),
      // 动态详情
      GoRoute(path: '/dynamicDetail', builder: (_, _) => const DynamicDetailPage()),
      // 关注
      GoRoute(path: '/follow', builder: (_, _) => const FollowPage()),
      // 粉丝
      GoRoute(path: '/fan', builder: (_, _) => const FansPage()),
      // 直播详情
      GoRoute(path: '/liveRoom', builder: (_, _) => const LiveRoomPage()),
      // 用户中心
      GoRoute(path: '/member', builder: (_, _) => const MemberPage()),
      GoRoute(path: '/memberSearch', builder: (_, _) => const MemberSearchPage()),
      //
      GoRoute(path: '/blackListPage', builder: (_, _) => const BlackListPage()),
      GoRoute(path: '/colorSetting', builder: (_, _) => const ColorSelectPage()),
      GoRoute(path: '/fontSizeSetting', builder: (_, _) => const FontSizeSelectPage()),
      // 屏幕帧率
      GoRoute(path: '/displayModeSetting', builder: (_, _) => const SetDisplayMode()),
      //
      GoRoute(path: '/articlePage', builder: (_, _) => const ArticlePage()),

      // 历史记录搜索
      GoRoute(path: '/playSpeedSet', builder: (_, _) => const PlaySpeedPage()),
      // 收藏搜索
      GoRoute(path: '/favSearch', builder: (_, _) => const FavSearchPage()),
      GoRoute(path: '/historySearch', builder: (_, _) => const HistorySearchPage()),
      GoRoute(path: '/laterSearch', builder: (_, _) => const LaterSearchPage()),
      GoRoute(path: '/followSearch', builder: (_, _) => const FollowSearchPage()),
      // 消息页面
      GoRoute(path: '/whisper', builder: (_, _) => const WhisperPage()),
      // 私信详情
      GoRoute(path: '/whisperDetail', builder: (_, _) => const WhisperDetailPage()),
      // 回复我的
      GoRoute(path: '/replyMe', builder: (_, _) => const ReplyMePage()),
      // @我的
      GoRoute(path: '/atMe', builder: (_, _) => const AtMePage()),
      // 收到的赞
      GoRoute(path: '/likeMe', builder: (_, _) => const LikeMePage()),
      // 系统消息
      GoRoute(path: '/sysMsg', builder: (_, _) => const SysMsgPage()),
      // 消息设置（从通用消息页经路由进入，参数 ['type'] 为 CoreImSettingType）
      GoRoute(path: '/whisperSettings', builder: (_, _) => const WhisperSettingsPage()),
      // 登录页面
      GoRoute(path: '/loginPage', builder: (_, _) => const LoginPage()),
      // 用户动态
      GoRoute(path: '/memberDynamics', builder: (_, _) => const MemberDynamicsPage()),
      // 日志
      GoRoute(path: '/logs', builder: (_, _) => const LogsPage()),
      // 订阅
      GoRoute(path: '/subscription', builder: (_, _) => const SubPage()),
      // 订阅详情
      GoRoute(path: '/subDetail', builder: (_, _) => const SubDetailPage()),
      // 弹幕屏蔽管理
      GoRoute(path: '/danmakuBlock', builder: (_, _) => const DanmakuBlockPage()),
      GoRoute(path: '/sponsorBlock', builder: (_, _) => const SponsorBlockPage()),
      GoRoute(path: '/createFav', builder: (_, _) => const CreateFavPage()),
      GoRoute(path: '/editProfile', builder: (_, _) => const EditProfilePage()),
      GoRoute(path: '/settingsSearch', builder: (_, _) => const SettingsSearchPage()),
      GoRoute(path: '/searchTrending', builder: (_, _) => const SearchTrendingPage()),
      GoRoute(path: '/dynTopic', builder: (_, _) => const DynTopicPage()),
      GoRoute(path: '/articleList', builder: (_, _) => const ArticleListPage()),
      GoRoute(path: '/barSetting', builder: (_, _) => const BarSetPage()),
      GoRoute(path: '/upowerRank', builder: (_, _) => const UpowerRankPage()),
      GoRoute(path: '/spaceSetting', builder: (_, _) => const SpaceSettingPage()),
      GoRoute(path: '/dynTopicRcmd', builder: (_, _) => const DynTopicRcmdPage()),
      GoRoute(path: '/matchInfo', builder: (_, _) => const MatchInfoPage()),
      GoRoute(path: '/msgLikeDetail', builder: (_, _) => const LikeDetailPage()),
      GoRoute(
        path: '/liveDmBlockPage',
        builder: (_, state) => LiveDmBlockPage(roomId: state.uri.queryParameters['roomId']!),
      ),
      GoRoute(path: '/createVote', builder: (_, _) => const CreateVotePage()),
      GoRoute(path: '/musicDetail', builder: (_, _) => const MusicDetailPage()),
      GoRoute(path: '/popularSeries', builder: (_, _) => const PopularSeriesPage()),
      GoRoute(path: '/popularPrecious', builder: (_, _) => const PopularPreciousPage()),
      GoRoute(path: '/audio', builder: (_, _) => const AudioPage()),
      GoRoute(path: '/mainReply', builder: (_, _) => const MainReplyPage()),
      GoRoute(path: '/followed', builder: (_, _) => const FollowedPage()),
      GoRoute(path: '/sameFollowing', builder: (_, _) => const FollowSamePage()),
      GoRoute(path: '/download', builder: (_, _) => const DownloadPage()),
      GoRoute(path: '/dlna', builder: (_, _) => const DLNAPage()),
      GoRoute(path: '/myReply', builder: (_, _) => const MyReply()),
      GoRoute(path: '/videoWeb', builder: (_, _) => const MemberVideoWeb()),
      GoRoute(path: '/ssWeb', builder: (_, _) => const MemberSSWeb()),
      GoRoute(path: '/memberGuard', builder: (_, _) => const MemberGuard()),
      GoRoute(path: '/bubble', builder: (_, _) => const BubblePage()),
    ];
  }
}
