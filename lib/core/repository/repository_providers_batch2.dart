// Riverpod providers for core repository interfaces — batch 2 of 2.
//
// Additive layer: adapters override these providers with concrete
// implementations. Existing GetX bindings are untouched.

import 'package:riverpod/riverpod.dart';

import 'package:skf/core/repository/im_repository.dart';
import 'package:skf/core/repository/pgc_repository.dart';
import 'package:skf/core/repository/progress_repository.dart';
import 'package:skf/core/repository/sponsor_block_repository.dart';
import 'package:skf/core/repository/validate_repository.dart';
import 'package:skf/core/repository/live_repository.dart';
import 'package:skf/core/repository/match_repository.dart';
import 'package:skf/core/repository/music_repository.dart';
import 'package:skf/core/repository/download_repository.dart';
import 'package:skf/core/repository/space_repository.dart';
import 'package:skf/core/repository/app_repository.dart';
import 'package:skf/core/repository/danmaku_filter_repository.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/repository/black_repository.dart';

/// Messaging / IM conversations.
final imRepositoryProvider = Provider<ImRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// PGC (anime / drama / movie) catalog and detail.
final pgcRepositoryProvider = Provider<PgcRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// Watch progress (viewing position persistence).
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// SponsorBlock skip-segment lookup.
final sponsorBlockRepositoryProvider = Provider<SponsorBlockRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// Cookie / login validation.
final validateRepositoryProvider = Provider<ValidateRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// Live-stream room info and stream URLs.
final liveRepositoryProvider = Provider<LiveRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// Match / e-sports schedule and streams.
final matchRepositoryProvider = Provider<MatchRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// Music / audio track metadata.
final musicRepositoryProvider = Provider<MusicRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// Media download queue and file management.
final downloadRepositoryProvider = Provider<DownloadRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// User space / profile pages.
final spaceRepositoryProvider = Provider<SpaceRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// App-level metadata (version, config).
final appRepositoryProvider = Provider<AppRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// Danmaku (bullet-comment) filter keywords and rules.
final danmakuFilterRepositoryProvider = Provider<DanmakuFilterRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// Message-feed notifications (at-me, like, reply).
final msgRepositoryProvider = Provider<MsgRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// Blacklist management.
final blackRepositoryProvider = Provider<BlackRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);
