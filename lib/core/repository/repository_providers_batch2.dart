// Riverpod providers for core repository interfaces — batch 2 of 2.
//
// Additive layer: adapters override these providers with concrete
// implementations. Existing GetX bindings are untouched.

import 'package:riverpod/riverpod.dart';

import 'package:skf/core/repository/im_repository.dart';
import 'package:skf/core/repository/progress_repository.dart';
import 'package:skf/core/repository/sponsor_block_repository.dart';
import 'package:skf/core/repository/download_repository.dart';
import 'package:skf/core/repository/app_repository.dart';
import 'package:skf/core/repository/msg_repository.dart';
import 'package:skf/core/repository/black_repository.dart';

/// Messaging / IM conversations.
final imRepositoryProvider = Provider<ImRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// PGC (anime / drama / movie) catalog and detail.

/// Watch progress (viewing position persistence).
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// SponsorBlock skip-segment lookup.
final sponsorBlockRepositoryProvider = Provider<SponsorBlockRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// Cookie / login validation.

/// Live-stream room info and stream URLs.

/// Match / e-sports schedule and streams.

/// Music / audio track metadata.

/// Media download queue and file management.
final downloadRepositoryProvider = Provider<DownloadRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// User space / profile pages.

/// App-level metadata (version, config).
final appRepositoryProvider = Provider<AppRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// Danmaku (bullet-comment) filter keywords and rules.

/// Message-feed notifications (at-me, like, reply).
final msgRepositoryProvider = Provider<MsgRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);

/// Blacklist management.
final blackRepositoryProvider = Provider<BlackRepository>(
  (ref) => throw UnimplementedError('Override in adapter'),
);
