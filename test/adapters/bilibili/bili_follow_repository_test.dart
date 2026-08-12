import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skf/adapters/bilibili/repository/bili_follow_repository.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_item.dart';
import 'package:skf/core/models/follow_status.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/bili_bootstrap.dart';
import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late Directory tempDir;
  final repo = BiliFollowRepository();

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

  group('BiliFollowRepository (implementation-level)', () {
    test('happy: followings converts the /x/relation/followings fixture',
        () async {
      swap(<String, String>{
        'GET /x/relation/followings': fixture('bilibili/followings'),
      });

      final result = await repo.followings(vmid: 10086, pn: 1);

      expect(result, isA<Success<CoreFollowData>>());
      final data = (result as Success<CoreFollowData>).response;
      expect(data.total, 2);
      expect(data.list, hasLength(2));
      final first = data.list!.first;
      expect(first, isA<CoreFollowItemModel>());
      expect(first.mid, 10001);
      expect(first.uname, 'UP主一');
      expect(first.face, 'https://i0.hdslb.com/bfs/face/1.jpg');
      expect(first.attribute, 1);
      expect(first.sign, '签名一');
      expect(first.officialVerify, <String, dynamic>{
        'type': 1,
        'desc': '认证信息',
      });
      final second = data.list![1];
      expect(second.mid, 10002);
      expect(second.officialVerify, isNull);
      expect(fake.requestCount, 1);
    });

    test('error: followings resolves the -352 code through the errorMsg table',
        () async {
      swap(<String, String>{
        'GET /x/relation/followings': fixture('bilibili/follow_error'),
      });

      final result = await repo.followings(vmid: 10086, pn: 1);

      expect(result, isA<Error>());
      expect((result as Error).errMsg, '风控校验失败，请检查登录状态');
      expect(fake.requestCount, 1);
    });

    test('edge: followings tolerates an empty list', () async {
      swap(<String, String>{
        'GET /x/relation/followings': fixture('bilibili/followings_empty'),
      });

      final result = await repo.followings(vmid: 10086, pn: 1);

      expect(result, isA<Success<CoreFollowData>>());
      final data = (result as Success<CoreFollowData>).response;
      expect(data.list, isEmpty);
      expect(data.total, 0);
      expect(fake.requestCount, 1);
    });

    test('edge: followings tolerates items with missing optional fields',
        () async {
      swap(<String, String>{
        'GET /x/relation/followings': fixture('bilibili/followings_sparse'),
      });

      final result = await repo.followings(vmid: 10086, pn: 1);

      expect(result, isA<Success<CoreFollowData>>());
      final item = (result as Success<CoreFollowData>).response.list!.single;
      expect(item.mid, 999);
      expect(item.uname, isNull);
      expect(item.face, isNull);
      expect(item.attribute, isNull);
      expect(item.sign, isNull);
      expect(item.officialVerify, isNull);
      expect(fake.requestCount, 1);
    });

    test('happy: followStatus converts the /x/relation fixture', () async {
      swap(<String, String>{
        'GET /x/relation': fixture('bilibili/relation'),
      });

      final result = await repo.followStatus(fid: 10001);

      expect(result, isA<Success<CoreFollowStatus>>());
      expect((result as Success<CoreFollowStatus>).response.status, 2);
      expect(fake.requestCount, 1);
    });

    test('error: followStatus returns Error on a non-zero code envelope',
        () async {
      swap(<String, String>{
        'GET /x/relation': fixture('bilibili/relation_error'),
      });

      final result = await repo.followStatus(fid: 10001);

      expect(result, isA<Error>());
      expect((result as Error).errMsg, '请求错误');
      expect(fake.requestCount, 1);
    });

    test('edge: followStatus defaults to 0 when attribute is missing',
        () async {
      swap(<String, String>{
        'GET /x/relation': fixture('bilibili/relation_minimal'),
      });

      final result = await repo.followStatus(fid: 10001);

      expect(result, isA<Success<CoreFollowStatus>>());
      expect((result as Success<CoreFollowStatus>).response.status, 0);
      expect(fake.requestCount, 1);
    });
  });
}
