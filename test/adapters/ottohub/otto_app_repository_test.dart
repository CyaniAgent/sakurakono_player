import 'package:flutter_test/flutter_test.dart';
import 'package:skf/adapters/ottohub/repository/otto_app_repository.dart';
import 'package:skf/core/models/app_types.dart';
import 'package:skf/core/result/loading_state.dart';

void main() {
  final repo = OttoAppRepository();

  group('OttoAppRepository (implementation-level)', () {
    test('checkUpdate always reports no update', () async {
      final result = await repo.checkUpdate();

      expect(result, isA<Success<CoreUpdateInfo>>());
      final info = (result as Success<CoreUpdateInfo>).response;
      expect(info.hasUpdate, isFalse);
      expect(info.latestVersion, isNull);
      expect(info.downloadUrl, isNull);
      expect(info.releaseNotes, isNull);
      expect(info.publishedAt, isNull);
    });

    test('checkUpdate ignores the currentVersion parameter', () async {
      final result = await repo.checkUpdate(currentVersion: '9.9.9');

      expect(result, isA<Success<CoreUpdateInfo>>());
      expect((result as Success<CoreUpdateInfo>).response.hasUpdate, isFalse);
    });
  });
}
