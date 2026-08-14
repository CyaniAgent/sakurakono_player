import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skf/adapters/bilibili/repository/bili_progress_repository.dart';
import 'package:skf/core/models/media_id.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/utils/path_utils.dart';
import 'package:skf/utils/storage.dart';

/// Bootstraps a real Hive store in a throwaway temp dir (bili_bootstrap's
/// GStorage pattern, minus the network Request singleton) so the repository
/// tests exercise the actual `watchProgress` box without touching the disk
/// beyond the temp dir.
Future<Directory> bootstrapProgressStorage() async {
  final tempDir = await Directory.systemTemp.createTemp('skf_progress_test');
  tmpDirPath = tempDir.path;
  appSupportDirPath = tempDir.path;
  await GStorage.init();
  return tempDir;
}

void main() {
  late Directory tempDir;
  final repo = BiliProgressRepository();

  setUpAll(() async {
    tempDir = await bootstrapProgressStorage();
  });

  tearDownAll(() async {
    await GStorage.close();
    await tempDir.delete(recursive: true);
  });

  group('BiliProgressRepository (implementation-level)', () {
    test('happy: setProgress then getProgress round-trips the saved value',
        () async {
      const id = CoreCid('20001');

      await repo.setProgress(id, 3600000);

      final result = await repo.getProgress(id);
      expect(result, isA<Success<int?>>());
      expect((result as Success<int?>).response, 3600000);
    });

    test('happy: clearProgress removes the saved value', () async {
      const id = CoreCid('20002');
      await repo.setProgress(id, 12345);

      await repo.clearProgress(id);

      final result = await repo.getProgress(id);
      expect(result, isA<Success<int?>>());
      expect((result as Success<int?>).response, isNull);
    });

    test('edge: getProgress on an unknown media returns null', () async {
      final result = await repo.getProgress(const CoreCid('never_set'));

      expect(result, isA<Success<int?>>());
      expect((result as Success<int?>).response, isNull);
    });

    test('edge: distinct media ids do not share progress entries', () async {
      await repo.setProgress(const CoreCid('10001'), 111);
      await repo.setProgress(const CoreCid('10002'), 222);

      final a = await repo.getProgress(const CoreCid('10001'));
      final b = await repo.getProgress(const CoreCid('10002'));
      expect((a as Success<int?>).response, 111);
      expect((b as Success<int?>).response, 222);
    });

    test('edge: setProgress overwrites a previous value', () async {
      const id = CoreCid('10003');
      await repo.setProgress(id, 1000);

      await repo.setProgress(id, 2000);

      final result = await repo.getProgress(id);
      expect((result as Success<int?>).response, 2000);
    });
  });
}
