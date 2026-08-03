import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/bilibili/bridge.dart';
import 'package:skf/adapters/bilibili/pages/main/view.dart';
import 'package:skf/adapters/bilibili/services/download/download_service.dart';
import 'package:skf/adapters/ottohub/player/otto_player_factory.dart';
import 'package:skf/adapters/ottohub/player/otto_reporter.dart';
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
import 'package:skf/adapters/ottohub/services/otto_account_provider.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/adapter/app_adapter.dart';
import 'package:skf/core/player/player_factory.dart';
import 'package:skf/core/player/playback_reporter.dart';
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
import 'package:skf/core/result/loading_state.dart';
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
  String get displayName => 'OttoHub';

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
      // Stub registrations for feature-flagged services.
      // These prevent crashes when Bilibili UI code does Get.find<>()
      // for features not implemented by the OttoHub adapter.
      ..lazyPut<LiveRepository>(_StubLiveRepository.new)
      ..lazyPut<SearchRepository>(_StubSearchRepository.new)
      ..lazyPut<PgcRepository>(_StubPgcRepository.new)
      ..lazyPut<DownloadService>(_StubDownloadService.new)
      ..lazyPut<AccountProvider>(() => OttoAccountProvider(client))
      ..lazyPut<PlaybackReporter>(OttoReporter.new)
      ..lazyPut<PlayerFactory>(OttoPlayerFactory.new);
  }

  @override
  List<GetPage> get routes => BiliBridge.registerRoutes();

  @override
  bool hasFeature(AppFeature feature) => switch (feature) {
    // Only features that are implemented have OttoHub equivalents.
    AppFeature.search => false,
    AppFeature.space => false,
    AppFeature.download => false,
    AppFeature.validate => false,
    AppFeature.danmakuFilter => false,
    // Not implemented by OttoHub SDK (modern API):
    AppFeature.live => false,
    AppFeature.music => false,
    AppFeature.audio => false,
    AppFeature.match => false,
    AppFeature.pgc => false,
    AppFeature.sponsorBlock => false,
  };

  @override
  Widget get homePage => const MainApp();

  @override
  Future<void> onInit() async {
    // OttoHub-specific initialization can be added here.
  }

  @override
  String processImageUrl(String? originalUrl, {int quality = 1}) {
    // OttoHub images don't need CDN suffix processing
    return originalUrl?.http2https ?? '';
  }
}

// ---------------------------------------------------------------------------
// Stub classes — prevent crashes when Bilibili UI code references
// feature-flagged services that OttoHub does not implement.
// ---------------------------------------------------------------------------

/// Stub [SearchRepository] — uses `noSuchMethod` to handle all methods.
///
/// Search is feature-flagged ([AppFeature.search]) but some UI code
/// (e.g. [BaseSearchController]) may still call `Get.find<SearchRepository>()`
/// regardless of the feature flag. This stub prevents the crash.
class _StubSearchRepository implements SearchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    // For methods returning Future<LoadingState<T>>, return an error.
    if (invocation.isMethod) {
      return Future.value(const Error('OttoHub: not implemented'));
    }
    return super.noSuchMethod(invocation);
  }
}

/// Stub [PgcRepository] — uses `noSuchMethod` to handle all methods.
class _StubPgcRepository implements PgcRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isMethod) {
      return Future.value(const Error('OttoHub: not implemented'));
    }
    return super.noSuchMethod(invocation);
  }
}

/// Stub [LiveRepository] — uses `noSuchMethod` to handle all methods.
///
/// Live is feature-flagged ([AppFeature.live]) but some UI code may still
/// call `Get.find<LiveRepository>()` regardless of the feature flag.
class _StubLiveRepository implements LiveRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isMethod) {
      return Future.value(const Error('OttoHub: not implemented'));
    }
    return super.noSuchMethod(invocation);
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
