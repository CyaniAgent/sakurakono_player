import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skf/adapters/bilibili/bridge.dart';
import 'package:skf/adapters/bilibili/repository/bili_video_repository.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/repository/video_repository.dart';

/// All 26 core repository providers, in the same order as
/// [BiliBridge.buildAdapterOverrides].
final List<ProviderListenable<Object?>> allRepositoryProviders = <ProviderListenable<Object?>>[
  videoRepositoryProvider,
  audioRepositoryProvider,
  authRepositoryProvider,
  userRepositoryProvider,
  memberRepositoryProvider,
  dynamicsRepositoryProvider,
  followRepositoryProvider,
  fanRepositoryProvider,
  favRepositoryProvider,
  danmakuRepositoryProvider,
  replyRepositoryProvider,
  searchRepositoryProvider,
  imRepositoryProvider,
  pgcRepositoryProvider,
  progressRepositoryProvider,
  sponsorBlockRepositoryProvider,
  validateRepositoryProvider,
  liveRepositoryProvider,
  matchRepositoryProvider,
  musicRepositoryProvider,
  downloadRepositoryProvider,
  spaceRepositoryProvider,
  appRepositoryProvider,
  danmakuFilterRepositoryProvider,
  msgRepositoryProvider,
  blackRepositoryProvider,
];

void main() {
  group('BiliBridge.buildAdapterOverrides (shape)', () {
    test('returns exactly 26 overrides', () {
      final overrides = BiliBridge.buildAdapterOverrides();
      expect(overrides, hasLength(26));
    });

    test('each override provides a non-null repository', () {
      final container = ProviderContainer(
        overrides: BiliBridge.buildAdapterOverrides(),
      );
      for (final provider in allRepositoryProviders) {
        final repo = container.read(provider);
        expect(repo, isNotNull,
          reason: '${provider.runtimeType} should resolve without error',
        );
      }
    });
  });

  group('BiliBridge.buildAdapterOverrides (type safety)', () {
    test('videoRepositoryProvider resolves to VideoRepository', () {
      final container = ProviderContainer(
        overrides: BiliBridge.buildAdapterOverrides(),
      );
      final repo = container.read(videoRepositoryProvider);
      expect(repo, isA<VideoRepository>());
    });

    test('videoRepositoryProvider resolves to BiliVideoRepository', () {
      final container = ProviderContainer(
        overrides: BiliBridge.buildAdapterOverrides(),
      );
      final repo = container.read(videoRepositoryProvider);
      expect(repo, isA<BiliVideoRepository>());
    });
  });
}
