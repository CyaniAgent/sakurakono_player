import 'package:riverpod/riverpod.dart';
import 'package:skf/core/repository/audio_repository.dart';
import 'package:skf/core/repository/auth_repository.dart';
import 'package:skf/core/repository/danmaku_repository.dart';
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/repository/fan_repository.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/repository/follow_repository.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/repository/reply_repository.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/repository/video_repository.dart';

/// Riverpod providers for core repository interfaces.
///
/// Each provider throws [UnimplementedError] by default — adapters override
/// these in their bridge registration (e.g. [BiliBridge.registerDependencies]).

final videoRepositoryProvider = Provider<VideoRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

final audioRepositoryProvider = Provider<AudioRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

final memberRepositoryProvider = Provider<MemberRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

final dynamicsRepositoryProvider = Provider<DynamicsRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

final followRepositoryProvider = Provider<FollowRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

final fanRepositoryProvider = Provider<FanRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

final favRepositoryProvider = Provider<FavRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

final danmakuRepositoryProvider = Provider<DanmakuRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

final replyRepositoryProvider = Provider<ReplyRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

final searchRepositoryProvider = Provider<SearchRepository>(
(ref) => throw UnimplementedError('Override in adapter'),
);
