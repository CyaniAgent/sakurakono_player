import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skf/adapters/ottohub/repository/otto_progress_repository.dart';
import 'package:skf/core/models/media_id.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/utils/path_utils.dart';
import 'package:skf/utils/storage.dart';

/// Bootstraps a real Hive store in a throwaway temp dir (bili_bootstrap's
/// GStorage pattern, minus the network Request singleton) so the repository
/// tests exercise the actual `setting` box without touching the network.
Future<Directory> bootstrapProgressStorage() async {
  final tempDir = await Directory.systemTemp.createTemp('skf_progress_test');
  tmpDirPath = tempDir.path;
  appSupportDirPath = tempDir.path;
  await GStorage.init();
  return tempDir;
}

void main() {
  late Directory tempDir;
  final repo = OttoProgressRepository();

  setUpAll(() async {
    tempDir = await bootstrapProgressStorage();
  });

  tearDownAll(() async {
    await GStorage.close();
    await tempDir.delete(recursive: true);
  });

  group('OttoProgressRepository (implementation-level)', () {
    test('happy: setProgress then getProgress round-trips the saved value',
        () async {
      const id = CoreNumericId('50001');

      await repo.setProgress(id, 7200000);

      final result = await repo.getProgress(id);
      expect(result, isA<Success<int?>>());
      expect((result as Success<int?>).response, 7200000);
    });

    test('happy: setProgress writes under the progress:<id> setting key',
        () async {
      const id = CoreNumericId('50002');
      await repo.setProgress(id, 999);

      expect(GStorage.setting.get('progress:50002'), 999);
    });

    test('happy: clearProgress removes the saved value', () async {
      const id = CoreNumericId('50003');
      await repo.setProgress(id, 12345);

      await repo.clearProgress(id);

      final result = await repo.getProgress(id);
      expect(result, isA<Success<int?>>());
      expect((result as Success<int?>).response, isNull);
      expect(GStorage.setting.get('progress:50003'), isNull);
    });

    test('edge: getProgress on an unknown media returns null', () async {
      final result = await repo.getProgress(const CoreNumericId('never_set'));

      expect(result, isA<Success<int?>>());
      expect((result as Success<int?>).response, isNull);
    });

    test('edge: distinct media ids do not share progress entries', () async {
      await repo.setProgress(const CoreNumericId('60001'), 111);
      await repo.setProgress(const CoreNumericId('60002'), 222);

      final a = await repo.getProgress(const CoreNumericId('60001'));
      final b = await repo.getProgress(const CoreNumericId('60002'));
      expect((a as Success<int?>).response, 111);
      expect((b as Success<int?>).response, 222);
    });
  });
}
