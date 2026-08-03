import 'package:skf/adapters/bilibili/account/bili_account_provider.dart';
import 'package:skf/adapters/bilibili/http/init.dart';
import 'package:skf/adapters/bilibili/models/model_owner.dart';
import 'package:skf/adapters/bilibili/models/user/danmaku_rule_adapter.dart';
import 'package:skf/adapters/bilibili/models/user/info.dart';
import 'package:skf/adapters/bilibili/player/bili_player_factory.dart';
import 'package:skf/adapters/bilibili/player/bili_reporter.dart';
import 'package:skf/adapters/bilibili/services/account_service.dart';
import 'package:skf/adapters/bilibili/services/download/download_service.dart';
import 'package:skf/adapters/bilibili/services/service_locator.dart';
import 'package:skf/adapters/bilibili/utils/accounts/account_adapter.dart';
import 'package:skf/adapters/bilibili/utils/accounts/account_type_adapter.dart';
import 'package:skf/adapters/bilibili/utils/accounts/cookie_jar_adapter.dart';
import 'package:skf/adapters/bilibili/utils/request_utils.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/plugin/local_file_plugin.dart';
import 'package:skf/core/plugin/plugin_registry.dart';
import 'package:skf/core/player/player_factory.dart';
import 'package:skf/core/player/playback_reporter.dart';
import 'package:skf/adapters/bilibili/pages/article/view.dart';
import 'package:skf/adapters/bilibili/pages/article_list/view.dart';
import 'package:skf/adapters/bilibili/pages/audio/view.dart';
import 'package:skf/adapters/bilibili/pages/blacklist/view.dart';
import 'package:skf/adapters/bilibili/pages/bubble/view.dart';
import 'package:skf/adapters/bilibili/pages/danmaku_block/view.dart';
import 'package:skf/adapters/bilibili/pages/dlna/view.dart';
import 'package:skf/adapters/bilibili/pages/download/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_create_vote/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_detail/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_topic/view.dart';
import 'package:skf/adapters/bilibili/pages/dynamics_topic_rcmd/view.dart';
import 'package:skf/adapters/bilibili/pages/fan/view.dart';
import 'package:skf/adapters/bilibili/pages/fav/view.dart';
import 'package:skf/adapters/bilibili/pages/fav_create/view.dart';
import 'package:skf/adapters/bilibili/pages/fav_detail/view.dart';
import 'package:skf/adapters/bilibili/pages/fav_search/view.dart';
import 'package:skf/adapters/bilibili/pages/follow/view.dart';
import 'package:skf/adapters/bilibili/pages/follow_search/view.dart';
import 'package:skf/adapters/bilibili/pages/follow_type/follow_same/view.dart';
import 'package:skf/adapters/bilibili/pages/follow_type/followed/view.dart';
import 'package:skf/adapters/bilibili/pages/history/view.dart';
import 'package:skf/adapters/bilibili/pages/history_search/view.dart';
import 'package:skf/adapters/bilibili/pages/home/view.dart';
import 'package:skf/adapters/bilibili/pages/hot/view.dart';
import 'package:skf/adapters/bilibili/pages/later/view.dart';
import 'package:skf/adapters/bilibili/pages/later_search/view.dart';
import 'package:skf/adapters/bilibili/pages/live_dm_block/view.dart';
import 'package:skf/adapters/bilibili/pages/live_room/view.dart';
import 'package:skf/adapters/bilibili/pages/login/view.dart';
import 'package:skf/adapters/bilibili/pages/main_reply/view.dart';
import 'package:skf/adapters/bilibili/pages/match_info/view.dart';
import 'package:skf/adapters/bilibili/pages/member/view.dart';
import 'package:skf/adapters/bilibili/pages/member_dynamics/view.dart';
import 'package:skf/adapters/bilibili/pages/member_guard/view.dart';
import 'package:skf/adapters/bilibili/pages/member_profile/view.dart';
import 'package:skf/adapters/bilibili/pages/member_search/view.dart';
import 'package:skf/adapters/bilibili/pages/member_upower_rank/view.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/archive/view.dart';
import 'package:skf/adapters/bilibili/pages/member_video_web/season_series/view.dart';
import 'package:skf/adapters/bilibili/pages/msg_feed_top/at_me/view.dart';
import 'package:skf/adapters/bilibili/pages/msg_feed_top/like_detail/view.dart';
import 'package:skf/adapters/bilibili/pages/msg_feed_top/like_me/view.dart';
import 'package:skf/adapters/bilibili/pages/msg_feed_top/reply_me/view.dart';
import 'package:skf/adapters/bilibili/pages/msg_feed_top/sys_msg/view.dart';
import 'package:skf/adapters/bilibili/pages/music/view.dart';
import 'package:skf/adapters/bilibili/pages/my_reply/view.dart';
import 'package:skf/adapters/bilibili/pages/popular_precious/view.dart';
import 'package:skf/adapters/bilibili/pages/popular_series/view.dart';
import 'package:skf/adapters/bilibili/pages/search/view.dart';
import 'package:skf/adapters/bilibili/pages/search_result/view.dart';
import 'package:skf/adapters/bilibili/pages/search_trending/view.dart';
import 'package:skf/adapters/bilibili/pages/setting/pages/bar_set.dart';
import 'package:skf/adapters/bilibili/pages/setting/pages/color_select.dart';
import 'package:skf/adapters/bilibili/pages/setting/pages/display_mode.dart';
import 'package:skf/adapters/bilibili/pages/setting/pages/font_size_select.dart';
import 'package:skf/adapters/bilibili/pages/setting/pages/logs.dart';
import 'package:skf/adapters/bilibili/pages/setting/pages/play_speed_set.dart';
import 'package:skf/adapters/bilibili/pages/setting/view.dart';
import 'package:skf/adapters/bilibili/pages/settings_search/view.dart';
import 'package:skf/adapters/bilibili/pages/space_setting/view.dart';
import 'package:skf/adapters/bilibili/pages/sponsor_block/view.dart';
import 'package:skf/adapters/bilibili/pages/subscription/view.dart';
import 'package:skf/adapters/bilibili/pages/subscription_detail/view.dart';
import 'package:skf/adapters/bilibili/pages/video/view.dart';
import 'package:skf/adapters/bilibili/pages/webview/view.dart';
import 'package:skf/adapters/bilibili/pages/whisper/view.dart';
import 'package:skf/adapters/bilibili/pages/whisper_detail/view.dart';
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
import 'package:skf/adapters/bilibili/repository/bili_reply_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_search_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_space_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_sponsor_block_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_user_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_validate_repository.dart';
import 'package:skf/adapters/bilibili/repository/bili_video_repository.dart';
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
import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/repository/space_repository.dart';
import 'package:skf/core/repository/sponsor_block_repository.dart';
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/repository/validate_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
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
    Get.lazyPut<PlaybackReporter>(BiliReporter.new);
    Get.lazyPut<AccountProvider>(BiliAccountProvider.new);
    Get.lazyPut<PlayerFactory>(BiliPlayerFactory.new);
    Get.lazyPut(AccountService.new);
    Get.lazyPut(DownloadService.new);
    // Repositories
    Get.lazyPut<VideoRepository>(BiliVideoRepository.new);
    Get.lazyPut<UserRepository>(BiliUserRepository.new);
    Get.lazyPut<AuthRepository>(BiliAuthRepository.new);
    Get.lazyPut<BiliSearchRepository>(BiliSearchRepository.new);
    Get.lazyPut<SearchRepository>(() => Get.find<BiliSearchRepository>());
    Get.lazyPut<ReplyRepository>(BiliReplyRepository.new);
    Get.lazyPut<FavRepository>(BiliFavRepository.new);
    Get.lazyPut<DynamicsRepository>(BiliDynamicsRepository.new);
    Get.lazyPut<MemberRepository>(BiliMemberRepository.new);
    Get.lazyPut<LiveRepository>(BiliLiveRepository.new);
    Get.lazyPut<MsgRepository>(BiliMsgRepository.new);
    Get.lazyPut<ImRepository>(BiliImRepository.new);
    Get.lazyPut<DanmakuRepository>(BiliDanmakuRepository.new);
    Get.lazyPut<MusicRepository>(BiliMusicRepository.new);
    Get.lazyPut<DanmakuFilterRepository>(BiliDanmakuFilterRepository.new);
    Get.lazyPut<FollowRepository>(BiliFollowRepository.new);
    Get.lazyPut<AudioRepository>(BiliAudioRepository.new);
    Get.lazyPut<FanRepository>(BiliFanRepository.new);
    Get.lazyPut<BlackRepository>(BiliBlackRepository.new);
    Get.lazyPut<MatchRepository>(BiliMatchRepository.new);
    Get.lazyPut<SpaceRepository>(BiliSpaceRepository.new);
    Get.lazyPut<DownloadRepository>(BiliDownloadRepository.new);
    Get.lazyPut<PgcRepository>(BiliPgcRepository.new);
    Get.lazyPut<SponsorBlockRepository>(BiliSponsorBlockRepository.new);
    Get.lazyPut<ValidateRepository>(BiliValidateRepository.new);
    // Plugin registry
    final pluginRegistry = PluginRegistry();
    Get.put(pluginRegistry);
    pluginRegistry.register(LocalFilePlugin());
    setupServiceLocator();
    _initHttp();
  }

  static void _initHttp() {
    Request();
    Request.setCookie();
    RequestUtils.syncHistoryStatus();
  }

  static List<GetPage> registerRoutes() => [
    // 首页(推荐)
    GetPage(name: '/home', page: () => const HomePage()),
    // 热门
    GetPage(name: '/hot', page: () => const HotPage()),
    // 视频详情
    GetPage(name: '/videoV', page: () => const VideoDetailPageV()),
    //
    GetPage(name: '/webview', page: () => const WebviewPage()),
    // 设置
    GetPage(name: '/setting', page: () => const SettingPage()),
    //
    GetPage(name: '/fav', page: () => const FavPage()),
    //
    GetPage(name: '/favDetail', page: () => const FavDetailPage()),
    // 稍后再看
    GetPage(name: '/later', page: () => const LaterPage()),
    // 历史记录
    GetPage(name: '/history', page: () => const HistoryPage()),
    // 搜索页面
    GetPage(name: '/search', page: () => const SearchPage()),
    // 搜索结果
    GetPage(name: '/searchResult', page: () => const SearchResultPage()),
    // 动态
    GetPage(name: '/dynamics', page: () => const DynamicsPage()),
    // 动态详情
    GetPage(name: '/dynamicDetail', page: () => const DynamicDetailPage()),
    // 关注
    GetPage(name: '/follow', page: () => const FollowPage()),
    // 粉丝
    GetPage(name: '/fan', page: () => const FansPage()),
    // 直播详情
    GetPage(name: '/liveRoom', page: () => const LiveRoomPage()),
    // 用户中心
    GetPage(name: '/member', page: () => const MemberPage()),
    GetPage(name: '/memberSearch', page: () => const MemberSearchPage()),
    //
    GetPage(name: '/blackListPage', page: () => const BlackListPage()),
    GetPage(name: '/colorSetting', page: () => const ColorSelectPage()),
    GetPage(name: '/fontSizeSetting', page: () => const FontSizeSelectPage()),
    // 屏幕帧率
    GetPage(name: '/displayModeSetting', page: () => const SetDisplayMode()),
    //
    GetPage(name: '/articlePage', page: () => const ArticlePage()),

    // 历史记录搜索
    GetPage(name: '/playSpeedSet', page: () => const PlaySpeedPage()),
    // 收藏搜索
    GetPage(name: '/favSearch', page: () => const FavSearchPage()),
    GetPage(name: '/historySearch', page: () => const HistorySearchPage()),
    GetPage(name: '/laterSearch', page: () => const LaterSearchPage()),
    GetPage(name: '/followSearch', page: () => const FollowSearchPage()),
    // 消息页面
    GetPage(name: '/whisper', page: () => const WhisperPage()),
    // 私信详情
    GetPage(name: '/whisperDetail', page: () => const WhisperDetailPage()),
    // 回复我的
    GetPage(name: '/replyMe', page: () => const ReplyMePage()),
    // @我的
    GetPage(name: '/atMe', page: () => const AtMePage()),
    // 收到的赞
    GetPage(name: '/likeMe', page: () => const LikeMePage()),
    // 系统消息
    GetPage(name: '/sysMsg', page: () => const SysMsgPage()),
    // 登录页面
    GetPage(name: '/loginPage', page: () => const LoginPage()),
    // 用户动态
    GetPage(name: '/memberDynamics', page: () => const MemberDynamicsPage()),
    // 日志
    GetPage(name: '/logs', page: () => const LogsPage()),
    // 订阅
    GetPage(name: '/subscription', page: () => const SubPage()),
    // 订阅详情
    GetPage(name: '/subDetail', page: () => const SubDetailPage()),
    // 弹幕屏蔽管理
    GetPage(name: '/danmakuBlock', page: () => const DanmakuBlockPage()),
    GetPage(name: '/sponsorBlock', page: () => const SponsorBlockPage()),
    GetPage(name: '/createFav', page: () => const CreateFavPage()),
    GetPage(name: '/editProfile', page: () => const EditProfilePage()),
    GetPage(name: '/settingsSearch', page: () => const SettingsSearchPage()),
    GetPage(name: '/searchTrending', page: () => const SearchTrendingPage()),
    GetPage(name: '/dynTopic', page: () => const DynTopicPage()),
    GetPage(name: '/articleList', page: () => const ArticleListPage()),
    GetPage(name: '/barSetting', page: () => const BarSetPage()),
    GetPage(name: '/upowerRank', page: () => const UpowerRankPage()),
    GetPage(name: '/spaceSetting', page: () => const SpaceSettingPage()),
    GetPage(name: '/dynTopicRcmd', page: () => const DynTopicRcmdPage()),
    GetPage(name: '/matchInfo', page: () => const MatchInfoPage()),
    GetPage(name: '/msgLikeDetail', page: () => const LikeDetailPage()),
    GetPage(name: '/liveDmBlockPage', page: () => const LiveDmBlockPage()),
    GetPage(name: '/createVote', page: () => const CreateVotePage()),
    GetPage(name: '/musicDetail', page: () => const MusicDetailPage()),
    GetPage(name: '/popularSeries', page: () => const PopularSeriesPage()),
    GetPage(name: '/popularPrecious', page: () => const PopularPreciousPage()),
    GetPage(name: '/audio', page: () => const AudioPage()),
    GetPage(name: '/mainReply', page: () => const MainReplyPage()),
    GetPage(name: '/followed', page: () => const FollowedPage()),
    GetPage(name: '/sameFollowing', page: () => const FollowSamePage()),
    GetPage(name: '/download', page: () => const DownloadPage()),
    GetPage(name: '/dlna', page: () => const DLNAPage()),
    GetPage(name: '/myReply', page: () => const MyReply()),
    GetPage(name: '/videoWeb', page: () => const MemberVideoWeb()),
    GetPage(name: '/ssWeb', page: () => const MemberSSWeb()),
    GetPage(name: '/memberGuard', page: () => const MemberGuard()),
    GetPage(name: '/bubble', page: () => const BubblePage()),
  ];
}
