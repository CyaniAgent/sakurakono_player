import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_fan_repository.dart';
import 'package:skf/core/models/fan_model.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late OttoFanRepository repo;

  OttoFanRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    repo = OttoFanRepository(OttohubClient(dio: dio));
    return repo;
  }

  group('OttoFanRepository (implementation-level)', () {
    test('happy: fans converts FollowingUser list with exact values', () async {
      makeRepo(<String, String>{
        'GET /following/fans/0': fixture('ottohub/following_list'),
      });

      final result = await repo.fans(vmid: 0, pn: 1);

      expect(result, isA<Success<CoreFollowData>>());
      final data = (result as Success<CoreFollowData>).response;
      expect(data.total, 2);
      expect(data.list, hasLength(2));
      final first = data.list!.first;
      expect(first.mid, 2001);
      expect(first.uname, '关注用户甲');
      expect(first.face, 'https://example.com/avatar1.jpg');
      expect(first.sign, '签名甲');
      // Second user has null intro → sign stays null.
      expect(data.list![1].sign, isNull);
      expect(fake.requestCount, 1);
    });

    test('happy: activeFollower converts the first active follower', () async {
      makeRepo(<String, String>{
        'GET /following/active/0': fixture('ottohub/active_followers'),
      });

      final result = await repo.activeFollower();

      expect(result, isA<Success<CoreActiveFollower?>>());
      final follower = (result as Success<CoreActiveFollower?>).response;
      expect(follower, isNotNull);
      expect(follower!.uid, 3001);
      expect(follower.username, '活跃粉丝一号');
      expect(follower.avatarUrl, 'https://example.com/fan1.jpg');
      expect(follower.latestActivityTime, '2024-06-01T08:00:00Z');
      expect(fake.requestCount, 1);
    });

    test('error: fans returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /following/fans/0': fixture('ottohub/error_following'),
      });

      final result = await repo.fans(vmid: 0, pn: 1);

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'error_following_uid');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });

    test('error: activeFollower returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /following/active/0': fixture('ottohub/error_following'),
      });

      final result = await repo.activeFollower();

      expect(result, isA<Error>());
      expect((result as Error).errMsg, 'error_following_uid');
      expect(fake.requestCount, 1);
    });

    test('edge: fans handles empty user_list with total 0', () async {
      makeRepo(<String, String>{
        'GET /following/fans/0': fixture('ottohub/following_list_empty'),
      });

      final result = await repo.fans(vmid: 0, pn: 1);

      expect(result, isA<Success<CoreFollowData>>());
      final data = (result as Success<CoreFollowData>).response;
      expect(data.total, 0);
      expect(data.list, isEmpty);
      expect(fake.requestCount, 1);
    });

    test('edge: activeFollower returns Success(null) for an empty list', () async {
      makeRepo(<String, String>{
        'GET /following/active/0': fixture('ottohub/active_followers_empty'),
      });

      final result = await repo.activeFollower();

      expect(result, const Success<CoreActiveFollower?>(null));
      expect(fake.requestCount, 1);
    });
  });
}
