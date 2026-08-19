import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:skf/adapters/ottohub/bridge.dart';
import 'package:skf/adapters/ottohub/repository/otto_video_repository.dart';
import 'package:skf/adapters/riverpod_adapter_overrides.dart';
import 'package:skf/core/container/app_container.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/repository/video_repository.dart';

void main() {
  group('OttoAdapter adapterOverrides (container smoke)', () {
    setUpAll(() async {
      Get.reset();
      await OttoAdapter().registerDependencies();
      appContainer = ProviderContainer(overrides: adapterOverrides);
    });

    tearDownAll(Get.reset);

    test('videoRepositoryProvider resolves to an OttoVideoRepository', () {
      final repo = appContainer.read(videoRepositoryProvider);
      expect(repo, isA<VideoRepository>());
      expect(repo, isA<OttoVideoRepository>());
      expect(repo, isNotNull);
    });
  });
}