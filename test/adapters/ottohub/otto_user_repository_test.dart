import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_user_repository.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late OttoUserRepository repo;

  OttoUserRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    repo = OttoUserRepository(OttohubClient(dio: dio));
    return repo;
  }

  group('OttoUserRepository (implementation-level)', () {
    test('happy: userInfo merges profile and detail into CoreUserInfoData',
        () async {
      makeRepo(<String, String>{
        'GET /profile': fixture('ottohub/user_profile'),
        'GET /user/10086': fixture('ottohub/user_detail_10086'),
      });

      final result = await repo.userInfo();

      expect(result, isA<Success<CoreUserInfoData>>());
      final info = (result as Success<CoreUserInfoData>).response;
      expect(info.isLogin, isTrue);
      expect(info.mid, 10086);
      expect(info.uname, '测试用户');
      expect(info.face, 'https://example.com/avatar.jpg');
      expect(fake.requestCount, 2);
    });

    test('edge: userInfo tolerates a failing detail lookup (face falls back)',
        () async {
      // Only the profile route is registered — the detail call gets a 404.
      makeRepo(<String, String>{
        'GET /profile': fixture('ottohub/user_profile'),
      });

      final result = await repo.userInfo();

      expect(result, isA<Success<CoreUserInfoData>>());
      final info = (result as Success<CoreUserInfoData>).response;
      expect(info.isLogin, isTrue);
      expect(info.mid, 10086);
      expect(info.uname, '测试用户');
      expect(info.face, isNull);
      expect(fake.requestCount, 2); // profile + (failing) detail lookup
    });

    test('happy: userStatOwner converts follow/fan counts', () async {
      makeRepo(<String, String>{
        'GET /profile': fixture('ottohub/user_data'),
      });

      final result = await repo.userStatOwner();

      expect(result, isA<Success<CoreUserStat>>());
      final stat = (result as Success<CoreUserStat>).response;
      expect(stat.following, 50);
      expect(stat.follower, 800);
      expect(fake.requestCount, 1);
    });

    test('error: userStatOwner returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /profile': fixture('ottohub/error_block'),
      });

      final result = await repo.userStatOwner();

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'user_not_found');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });

    test('happy: historyList converts VideoSummary items into CoreHistoryData',
        () async {
      makeRepo(<String, String>{
        'GET /video/history-list': fixture('ottohub/history_video_list'),
      });

      final result = await repo.historyList(type: 'archive');

      expect(result, isA<Success<CoreHistoryData>>());
      final data = (result as Success<CoreHistoryData>).response;
      expect(data.list, hasLength(2));
      final first = data.list!.first;
      expect(first.title, '历史视频一');
      expect(first.cover, 'https://example.com/h1.jpg');
      expect(first.uri, '201');
      expect(first.authorName, 'UP主A');
      expect(first.authorMid, 1001);
      expect(first.duration, 240);
      expect(first.history.oid, 201);
      expect(first.history.bvid, '201');
      expect(first.history.cid, 201);
      expect(first.history.business, 'archive');
      expect(fake.requestCount, 1);
    });

    test('happy: userRelation converts follow status into attribute', () async {
      makeRepo(<String, String>{
        'GET /following/status/7': fixture('ottohub/follow_status'),
      });

      final result = await repo.userRelation(7);

      expect(result, isA<Success<CoreRelationData>>());
      expect((result as Success<CoreRelationData>).response.attribute, 1);
      expect(fake.requestCount, 1);
    });

    test('happy: userSubFolder pages collection names into CoreSubData',
        () async {
      makeRepo(<String, String>{
        'GET /collection/get_user_video_collection':
            fixture('ottohub/collection_list'),
      });

      final result = await repo.userSubFolder(mid: 7, pn: 1, ps: 2);

      expect(result, isA<Success<CoreSubData>>());
      final data = (result as Success<CoreSubData>).response;
      expect(data.list, hasLength(2));
      expect(data.list![0].id, 0);
      expect(data.list![0].fid, 0);
      expect(data.list![0].title, '合集A');
      expect(data.list![0].type, 2);
      expect(data.list![1].title, '合集B');
      expect(data.hasMore, isTrue);
      expect(fake.requestCount, 1);
    });

    test('happy: spaceSetting returns the default privacy shell', () async {
      makeRepo(<String, String>{
        'GET /profile': fixture('ottohub/user_profile'),
      });

      final result = await repo.spaceSetting();

      expect(result, isA<Success<CoreSpaceSettingData>>());
      final setting = (result as Success<CoreSpaceSettingData>).response;
      expect(setting.privacy!.list1, isNotEmpty);
      expect(fake.requestCount, 1);
    });

    test('happy: getUserRealName converts detail username', () async {
      makeRepo(<String, String>{
        'GET /user/7': fixture('ottohub/user_detail'),
      });

      final result = await repo.getUserRealName(7);

      expect(result, isA<Success<CoreUserRealNameData>>());
      expect((result as Success<CoreUserRealNameData>).response.name, '用户七');
      expect(fake.requestCount, 1);
    });

    test('edge: getUserRealName rejects a non-numeric mid without HTTP',
        () async {
      makeRepo(const <String, String>{});

      final result = await repo.getUserRealName('abc');

      expect(result, const Error('missing_argument'));
      expect(fake.requestCount, 0);
    });

    test('happy: followedUp converts the following list', () async {
      makeRepo(<String, String>{
        'GET /following/list/7': fixture('ottohub/following_list'),
      });

      final result = await repo.followedUp(mid: 7, pn: 1);

      expect(result, isA<Success<CoreFollowData>>());
      final data = (result as Success<CoreFollowData>).response;
      expect(data.list, hasLength(2));
      expect(data.list!.first.mid, 2001);
      expect(data.list!.first.uname, '关注用户甲');
      expect(data.list!.first.sign, '签名甲');
      expect(fake.requestCount, 1);
    });

    test('happy: sameFollowing converts the following list without paging',
        () async {
      makeRepo(<String, String>{
        'GET /following/list/7': fixture('ottohub/following_list'),
      });

      final result = await repo.sameFollowing(mid: 7);

      expect(result, isA<Success<CoreFollowData>>());
      expect(
        (result as Success<CoreFollowData>).response.list,
        hasLength(2),
      );
      expect(fake.requestCount, 1);
    });
  });
}
