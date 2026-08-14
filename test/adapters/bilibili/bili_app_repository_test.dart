import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skf/adapters/bilibili/repository/bili_app_repository.dart';
import 'package:skf/core/models/app_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/bili_bootstrap.dart';
import '../../helpers/fake_http_adapter.dart';

/// Route key for the GitHub releases API used by [BiliAppRepository].
const _releasesRoute = 'GET /repos/CyaniAgent/sakurakono_player/releases';

void main() {
  late FakeHttpAdapter fake;
  late Directory tempDir;
  final repo = BiliAppRepository();

  setUpAll(() async {
    fake = FakeHttpAdapter(const {});
    tempDir = await bootstrapBiliRequest(fake);
  });

  tearDownAll(() async {
    await teardownBiliRequest(tempDir);
  });

  FakeHttpAdapter swap(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    installBiliFakeHttpAdapter(fake);
    return fake;
  }

  group('BiliAppRepository (implementation-level)', () {
    test('happy: newer release maps to hasUpdate=true with full metadata',
        () async {
      swap(<String, String>{
        _releasesRoute: '''
[
  {
    "tag_name": "v1.2.3",
    "body": "修复了若干问题",
    "created_at": "2099-01-01T00:00:00Z",
    "assets": [
      {
        "name": "skf-arm64-v8a.apk",
        "browser_download_url": "https://github.com/CyaniAgent/sakurakono_player/releases/download/v1.2.3/skf-arm64-v8a.apk"
      }
    ]
  }
]
''',
      });

      // BuildConfig.buildTime is 0 in tests, so any post-1970 release wins.
      final result = await repo.checkUpdate(currentVersion: 'v1.0.0');

      expect(result, isA<Success<CoreUpdateInfo>>());
      final info = (result as Success<CoreUpdateInfo>).response;
      expect(info.hasUpdate, isTrue);
      expect(info.latestVersion, 'v1.2.3');
      expect(info.releaseNotes, '修复了若干问题');
      expect(info.publishedAt, '2099-01-01T00:00:00Z');
      expect(
        info.downloadUrl,
        'https://github.com/CyaniAgent/sakurakono_player/releases/download/v1.2.3/skf-arm64-v8a.apk',
      );
      expect(fake.requestCount, 1);
    });

    test('no-update: release older than build time reports hasUpdate=false',
        () async {
      swap(<String, String>{
        _releasesRoute: '''
[
  {
    "tag_name": "v0.9.0",
    "body": "老版本",
    "created_at": "1969-01-01T00:00:00Z",
    "assets": []
  }
]
''',
      });

      final result = await repo.checkUpdate();

      expect(result, isA<Success<CoreUpdateInfo>>());
      final info = (result as Success<CoreUpdateInfo>).response;
      expect(info.hasUpdate, isFalse);
      expect(info.latestVersion, 'v0.9.0');
      expect(info.downloadUrl, isNull);
      expect(fake.requestCount, 1);
    });

    test('error: unrouteable request surfaces as Error', () async {
      swap(const <String, String>{});

      final result = await repo.checkUpdate();

      expect(result, isA<Error>());
      expect((result as Error).errMsg, isNotEmpty);
      expect(fake.requestCount, 1);
    });

    test('edge: empty release list reports check failure', () async {
      swap(<String, String>{_releasesRoute: '[]'});

      final result = await repo.checkUpdate();

      expect(result, isA<Error>());
      expect((result as Error).errMsg, contains('GitHub'));
      expect(fake.requestCount, 1);
    });
  });
}
