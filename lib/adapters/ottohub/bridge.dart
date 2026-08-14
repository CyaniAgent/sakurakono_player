import 'package:get/get.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/bilibili/bridge.dart';
import 'package:skf/adapters/bilibili/services/download/download_service.dart';
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
import 'package:skf/adapters/ottohub/repository/otto_audio_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_danmaku_filter_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_download_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_live_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_match_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_music_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_pgc_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_sponsor_block_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_validate_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_search_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_space_repository.dart';
import 'package:skf/adapters/ottohub/services/otto_account_provider.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/adapter/app_adapter.dart';
import 'package:skf/core/models/media_id.dart';
import 'package:skf/core/repository/auth_repository.dart';
import 'package:skf/core/repository/black_repository.dart';
import 'package:skf/core/repository/danmaku_repository.dart';
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/repository/fan_repository.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/repository/follow_repository.dart';
import 'package:skf/core/repository/im_repository.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/repository/pgc_repository.dart';
import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/repository/live_repository.dart';
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/repository/audio_repository.dart';
import 'package:skf/core/repository/danmaku_filter_repository.dart';
import 'package:skf/core/repository/download_repository.dart';
import 'package:skf/core/repository/match_repository.dart';
import 'package:skf/core/repository/music_repository.dart';
import 'package:skf/core/repository/sponsor_block_repository.dart';
import 'package:skf/core/repository/validate_repository.dart';
import 'package:skf/core/repository/space_repository.dart';
import 'package:skf/utils/extension/string_ext.dart';

/// OttoHub adapter implementation of [AppAdapter].
///
/// Registers 13 repository implementations that map to the modern OttoHub SDK
/// API (non-Old modules): Video, Auth, Danmaku, Follow, Black, User, Member,
/// Dynamics, Reply, Fav, Msg, Im, and Fan.
class OttoAdapter implements AppAdapter {
  @override
  String get name => 'ottohub';

  @override
  Future<void> registerDependencies() async {
    final client = OttohubClient();

    // Register repositories using the modern (non-Old) OttoHub API modules.
    Get
      ..lazyPut<VideoRepository>(() => OttoVideoRepository(client))
      ..lazyPut<AuthRepository>(() => OttoAuthRepository(client))
      ..lazyPut<DanmakuRepository>(() => OttoDanmakuRepository(client))
      ..lazyPut<FollowRepository>(() => OttoFollowRepository(client))
      ..lazyPut<BlackRepository>(() => OttoBlackRepository(client))
      ..lazyPut<UserRepository>(() => OttoUserRepository(client))
      ..lazyPut<MemberRepository>(() => OttoMemberRepository(client))
      ..lazyPut<DynamicsRepository>(() => OttoDynamicsRepository(client))
      ..lazyPut<ReplyRepository>(() => OttoReplyRepository(client))
      ..lazyPut<FavRepository>(() => OttoFavRepository(client))
      ..lazyPut<MsgRepository>(() => OttoMsgRepository(client))
      ..lazyPut<ImRepository>(() => OttoImRepository(client))
      ..lazyPut<FanRepository>(() => OttoFanRepository(client))
      // Stub registrations for features the OttoHub SDK does not support.
      // These prevent crashes when Bilibili UI code does Get.find<>()
      // for features not implemented by the OttoHub adapter.
      // impossible — no SDK API (OttoHub 无此域)
      ..lazyPut<AudioRepository>(OttoAudioRepository.new)
      // impossible — no SDK API (OttoHub 无此域)
      ..lazyPut<DanmakuFilterRepository>(OttoDanmakuFilterRepository.new)
      ..lazyPut<DownloadRepository>(() => OttoDownloadRepository(client))
      // impossible — no SDK API (OttoHub 无此域)
      ..lazyPut<LiveRepository>(OttoLiveRepository.new)
      // impossible — no SDK API (OttoHub 无此域)
      ..lazyPut<MatchRepository>(OttoMatchRepository.new)
      // impossible — no SDK API (OttoHub 无此域)
      ..lazyPut<MusicRepository>(OttoMusicRepository.new)
      // impossible — no SDK API (OttoHub 无此域)
      ..lazyPut<PgcRepository>(OttoPgcRepository.new)
      // impossible — no SDK API (OttoHub 无此域)
      ..lazyPut<SponsorBlockRepository>(OttoSponsorBlockRepository.new)
      // impossible — no SDK API (OttoHub 无此域)
      ..lazyPut<ValidateRepository>(OttoValidateRepository.new)
      ..lazyPut<SearchRepository>(() => OttoSearchRepository(client))
      ..lazyPut<SpaceRepository>(() => OttoSpaceRepository(client))
      ..lazyPut<DownloadService>(_StubDownloadService.new)
      ..lazyPut<AccountProvider>(() => OttoAccountProvider(client));
  }

  @override
  List<GetPage> get routes => BiliBridge.registerRoutes();

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
}

/// Stub [DownloadService] — prevents crashes when Bilibili download pages
/// call `Get.find<DownloadService>()` but download is not implemented.
///
/// Extends [DownloadService] directly so all methods are inherited.
/// Overrides only the methods that would trigger filesystem I/O
/// (which is Bilibili-specific and irrelevant to OttoHub).
class _StubDownloadService extends DownloadService {
  @override
  void initDownloadList() {
    // OttoHub does not support downloads — no-op to prevent crash.
  }

  @override
  void onInit() {
    waitForInitialization = Future.value();
    // Stub — no initialization needed for OttoHub.
    super.onInit();
  }
}
// ---------------------------------------------------------------------------
// Stub classes — prevent crashes when Bilibili UI code references
// feature-flagged services that OttoHub does not implement.
// ---------------------------------------------------------------------------
