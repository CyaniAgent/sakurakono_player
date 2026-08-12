import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_follow_repository.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_status.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late OttoFollowRepository repo;

  OttoFollowRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    repo = OttoFollowRepository(OttohubClient(dio: dio));
    return repo;
  }

  group('OttoFollowRepository (implementation-level)', () {
    test('happy: followings converts FollowingUser list with exact values',
        () async {
      makeRepo(<String, String>{
        'GET /following/list/0': fixture('ottohub/following_list'),
      });

      final result = await repo.followings(vmid: 0, pn: 1);

      expect(result, isA<Success<CoreFollowData>>());
      final data = (result as Success<CoreFollowData>).response;
      expect(data.total, 2);
      expect(data.list, hasLength(2));
      final first = data.list!.first;
      expect(first.mid, 2001);
      expect(first.uname, '关注用户甲');
      expect(first.face, 'https://example.com/avatar1.jpg');
      expect(first.sign, '签名甲');
      expect(data.list![1].sign, isNull);
      expect(fake.requestCount, 1);
    });

    test('happy: followStatus converts follow_status', () async {
      makeRepo(<String, String>{
        'GET /following/status/7': fixture('ottohub/follow_status'),
      });

      final result = await repo.followStatus(fid: 7);

      expect(result, isA<Success<CoreFollowStatus>>());
      expect((result as Success<CoreFollowStatus>).response.status, 1);
      expect(fake.requestCount, 1);
    });

    test('happy: toggleFollow posts the toggle and returns Success(null)',
        () async {
      makeRepo(<String, String>{
        'POST /following/follow/7': fixture('ottohub/follow_toggle'),
      });

      final result = await repo.toggleFollow(fid: 7);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('error: followings returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /following/list/0': fixture('ottohub/error_following'),
      });

      final result = await repo.followings(vmid: 0, pn: 1);

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'error_following_uid');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });

    test('edge: followings handles empty user_list with total 0', () async {
      makeRepo(<String, String>{
        'GET /following/list/0': fixture('ottohub/following_list_empty'),
      });

      final result = await repo.followings(vmid: 0, pn: 1);

      expect(result, isA<Success<CoreFollowData>>());
      final data = (result as Success<CoreFollowData>).response;
      expect(data.total, 0);
      expect(data.list, isEmpty);
      expect(fake.requestCount, 1);
    });

    test('edge: followStatus maps mutual-follow status 2', () async {
      makeRepo(<String, String>{
        'GET /following/status/7': fixture('ottohub/follow_status_mutual'),
      });

      final result = await repo.followStatus(fid: 7);

      expect((result as Success<CoreFollowStatus>).response.status, 2);
      expect(fake.requestCount, 1);
    });
  });
}
