import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/bilibili/bridge.dart';
import 'package:skf/adapters/bilibili/repository/bili_video_repository.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/repository_providers_batch2.dart';
import 'package:skf/core/repository/video_repository.dart';

/// All 26 core repository providers, in the same order as
/// [BiliBridge.buildAdapterOverrides].
final List<ProviderListenable<Object?>> allRepositoryProviders = <
  ProviderListenable<Object?>>[
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
    test('overrides all 26 core repository providers', () {
      final overrides = BiliBridge.buildAdapterOverrides();
      expect(overrides, hasLength(26));

      // With no GetX DI registered, reading an overridden provider must throw
      // Get.find's "not found" String — NOT riverpod's UnimplementedError
      // (which is what an absent override would produce).
      final container = ProviderContainer(overrides: overrides);
      for (final provider in allRepositoryProviders) {
        Object? thrown;
        try {
          container.read(provider);
        } catch (e) {
          thrown = e;
        }
        expect(
          thrown,
          isA<String>(),
          reason:
              '${provider.runtimeType} should be overridden (Get.find throws String)',
        );
      }
    });
  });

  group('BiliBridge.buildAdapterOverrides (Get.find bridge)', () {
    tearDown(Get.reset);

    test(
      'videoRepositoryProvider resolves to VideoRepository via Get.find',
      () {
        // Register only the repo binding the bridge delegates to — mirrors the
        // `lazyPut<VideoRepository>(BiliVideoRepository.new)` call in
        // BiliBridge.register — NOT the full app bootstrap
        // (setupServiceLocator / _initHttp), which requires Hive + audio
        // service and is out of scope for a unit-level bridge test.
        Get.lazyPut<VideoRepository>(BiliVideoRepository.new);
        final container = ProviderContainer(
          overrides: BiliBridge.buildAdapterOverrides(),
        );
        final repo = container.read(videoRepositoryProvider);
        expect(repo, isA<VideoRepository>());
      },
    );
  });
}
