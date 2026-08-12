import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_reply_repository.dart';
import 'package:skf/core/models/reply_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late OttoReplyRepository repo;

  OttoReplyRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    repo = OttoReplyRepository(OttohubClient(dio: dio));
    return repo;
  }

  group('OttoReplyRepository (implementation-level)', () {
    test('happy: mainList converts video comments (type 2) with exact values',
        () async {
      makeRepo(<String, String>{
        'GET /comment/video_comment_list': fixture('ottohub/video_comments'),
      });

      final result = await repo.mainList(
        type: 2,
        oid: 42,
        mode: CoreMode.mainListTime,
        offset: null,
        cursorNext: null,
      );

      expect(result, isA<Success<CoreMainListReply>>());
      final reply = (result as Success<CoreMainListReply>).response;
      expect(reply.replies, hasLength(2));
      final first = reply.replies!.first as Map;
      expect(first['rpid'], 601);
      expect(first['mid'], 2001);
      expect((first['content'] as Map)['message'], '视频评论一');
      expect((first['member'] as Map)['uname'], '评论者甲');
      expect((first['member'] as Map)['avatar'], 'https://example.com/cmt1.jpg');
      expect(first['like'], 0);
      expect(first['rcount'], 3);
      expect(
        first['ctime'],
        DateTime.parse('2024-05-01 10:30:00').millisecondsSinceEpoch ~/ 1000,
      );
      // Second comment has null username/avatar → '' fallbacks.
      final second = reply.replies![1] as Map;
      expect((second['member'] as Map)['uname'], '');
      expect((second['member'] as Map)['avatar'], '');
      expect(second['rcount'], 0);
      expect(fake.requestCount, 1);
    });

    test('happy: mainList converts blog comments (type 1) via bcid', () async {
      makeRepo(<String, String>{
        'GET /comment/blog_comment_list': fixture('ottohub/blog_comments'),
      });

      final result = await repo.mainList(
        type: 1,
        oid: 42,
        mode: CoreMode.mainListTime,
        offset: null,
        cursorNext: null,
      );

      expect(result, isA<Success<CoreMainListReply>>());
      final reply = (result as Success<CoreMainListReply>).response;
      expect(reply.replies, hasLength(1));
      final first = reply.replies!.first as Map;
      expect(first['rpid'], 701);
      expect((first['content'] as Map)['message'], '博客评论一');
      expect(fake.requestCount, 1);
    });

    test('happy: detailList builds root/cursor from the sub-comment page',
        () async {
      makeRepo(<String, String>{
        'GET /comment/video_comment_list': fixture('ottohub/video_comments'),
      });

      final result = await repo.detailList(
        type: 2,
        oid: 42,
        root: 601,
        rpid: 601,
        mode: CoreMode.mainListTime,
        offset: null,
      );

      expect(result, isA<Success<CoreDetailListReply>>());
      final detail = (result as Success<CoreDetailListReply>).response;
      expect((detail.root as Map)['rpid'], 601);
      // 2 comments < 20 → is_end true.
      expect((detail.cursor as Map)['is_end'], isTrue);
      expect(fake.requestCount, 1);
    });

    test('happy: replyAdd posts the video comment and returns Success(null)',
        () async {
      makeRepo(<String, String>{
        'POST /comment/comment_video': fixture('ottohub/comment_result'),
      });

      final result = await repo.replyAdd(
        type: 2,
        oid: 42,
        message: '好评论',
        parent: 601,
      );

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('happy: replyDel posts the video-comment delete and returns Success(null)',
        () async {
      makeRepo(<String, String>{
        'POST /comment/delete_video_comment': fixture('ottohub/ok'),
      });

      final result = await repo.replyDel(type: 2, oid: 42, rpid: 601);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('happy: report posts the video-comment report and returns Success(null)',
        () async {
      makeRepo(<String, String>{
        'POST /comment/report_video_comment': fixture('ottohub/ok'),
      });

      final result = await repo.report(
        rpid: '601',
        oid: '42',
        reasonType: 1,
        reasonDesc: '引战',
      );

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('error: report rejects a non-numeric rpid without HTTP', () async {
      makeRepo(const <String, String>{});

      final result = await repo.report(rpid: 'abc', oid: '42', reasonType: 1);

      expect(result, const Error('OttoHub: 无法解析评论ID'));
      expect(fake.requestCount, 0);
    });

    test('error: mainList returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /comment/video_comment_list': fixture('ottohub/error_comment'),
      });

      final result = await repo.mainList(
        type: 2,
        oid: 42,
        mode: CoreMode.mainListTime,
        offset: null,
        cursorNext: null,
      );

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'comment_not_found');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });
  });
}
