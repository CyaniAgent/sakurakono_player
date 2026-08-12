import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_danmaku_repository.dart';
import 'package:skf/core/models/danmaku_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late OttoDanmakuRepository repo;

  OttoDanmakuRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    repo = OttoDanmakuRepository(OttohubClient(dio: dio));
    return repo;
  }

  group('OttoDanmakuRepository (implementation-level)', () {
    test('happy: dmSegMobile converts danmaku mode/color/fontSize/progress',
        () async {
      makeRepo(<String, String>{
        'GET /danmaku/42': fixture('ottohub/danmaku_list'),
      });

      final result = await repo.dmSegMobile(cid: 42, segmentIndex: 0);

      expect(result, isA<Success<CoreDanmakuSegmentReply>>());
      final reply = (result as Success<CoreDanmakuSegmentReply>).response;
      expect(reply.elems, hasLength(3));

      // scroll: time 5.5s → 5500ms, color #FFFFFF, font 25.
      final scroll = reply.elems[0];
      expect(scroll.id, 11);
      expect(scroll.content, '哈哈哈');
      expect(scroll.progress, 5500);
      expect(scroll.mode, 1);
      expect(scroll.color, 0xFFFFFF);
      expect(scroll.fontsize, 25);

      // top: time 12.25s → 12250ms, color #FF0000, font 32.
      final top = reply.elems[1];
      expect(top.id, 22);
      expect(top.progress, 12250);
      expect(top.mode, 5);
      expect(top.color, 0xFF0000);
      expect(top.fontsize, 32);

      // bottom: time 30s → 30000ms, color #00FF00, font 18.
      final bottom = reply.elems[2];
      expect(bottom.id, 33);
      expect(bottom.progress, 30000);
      expect(bottom.mode, 4);
      expect(bottom.color, 0x00FF00);
      expect(bottom.fontsize, 18);
      expect(fake.requestCount, 1);
    });

    test('happy: shootDanmaku posts the danmaku and returns Success(null dmid)',
        () async {
      makeRepo(<String, String>{
        'POST /danmaku': fixture('ottohub/ok'),
      });

      final result = await repo.shootDanmaku(
        oid: 42,
        msg: '测试弹幕',
        bvid: '42',
        progress: 5500,
        color: 0xFFFFFF,
      );

      expect(result, isA<Success<CoreDanmakuPost>>());
      expect((result as Success<CoreDanmakuPost>).response.dmid, isNull);
      expect(fake.requestCount, 1);
    });

    test('happy: danmakuRecall deletes the danmaku and returns Success(null)',
        () async {
      makeRepo(<String, String>{
        'DELETE /danmaku/11': fixture('ottohub/ok'),
      });

      final result = await repo.danmakuRecall(cid: 42, id: 11);

      expect(result, const Success<String?>(null));
      expect(fake.requestCount, 1);
    });

    test('error: dmSegMobile returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /danmaku/42': fixture('ottohub/error_danmaku'),
      });

      final result = await repo.dmSegMobile(cid: 42, segmentIndex: 0);

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'danmaku_not_found');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });

    test('edge: dmSegMobile handles an empty danmaku list', () async {
      makeRepo(<String, String>{
        'GET /danmaku/42': fixture('ottohub/danmaku_list_empty'),
      });

      final result = await repo.dmSegMobile(cid: 42, segmentIndex: 0);

      expect(result, isA<Success<CoreDanmakuSegmentReply>>());
      final reply = (result as Success<CoreDanmakuSegmentReply>).response;
      expect(reply.elems, isEmpty);
      expect(fake.requestCount, 1);
    });
  });
}
