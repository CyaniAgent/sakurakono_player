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
import 'package:skf/adapters/ottohub/repository/otto_audio_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_danmaku_filter_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_download_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_live_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_match_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_music_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_pgc_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_progress_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_sponsor_block_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_validate_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_search_repository.dart';
import 'package:skf/adapters/ottohub/repository/otto_space_repository.dart';
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
import 'package:skf/core/repository/repository_providers.dart'
    hide pgcRepositoryProvider;
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/adapters/riverpod_adapter_overrides.dart';
import 'package:skf/pages/home/controller.dart';
import 'package:skf/pages/main/controller.dart';
import 'package:skf/pages/providers.dart';
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
      audioRepositoryProvider.overrideWithValue(OttoAudioRepository()),
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
      pgcRepositoryProvider.overrideWithValue(OttoPgcRepository()),
      progressRepositoryProvider.overrideWithValue(OttoProgressRepository()),
      sponsorBlockRepositoryProvider.overrideWithValue(OttoSponsorBlockRepository()),
      validateRepositoryProvider.overrideWithValue(OttoValidateRepository()),
      liveRepositoryProvider.overrideWithValue(OttoLiveRepository()),
      matchRepositoryProvider.overrideWithValue(OttoMatchRepository()),
      musicRepositoryProvider.overrideWithValue(OttoMusicRepository()),
      downloadRepositoryProvider.overrideWithValue(OttoDownloadRepository(client)),
      spaceRepositoryProvider.overrideWithValue(OttoSpaceRepository(client)),
      appRepositoryProvider.overrideWithValue(OttoAppRepository()),
      danmakuFilterRepositoryProvider.overrideWithValue(OttoDanmakuFilterRepository()),
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
  List<GoRoute> get routes => [];

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
