import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_msg_repository.dart';
import 'package:skf/core/models/msg_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late OttoMsgRepository repo;

  OttoMsgRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    repo = OttoMsgRepository(OttohubClient(dio: dio));
    return repo;
  }

  group('OttoMsgRepository (implementation-level)', () {
    test('happy: msgFeedNotify converts unread messages into system items',
        () async {
      makeRepo(<String, String>{
        'GET /im/unread_message_list': fixture('ottohub/im_unread_messages'),
      });

      final result = await repo.msgFeedNotify();

      expect(result, isA<Success<List<CoreMsgSysItem>?>>());
      final list = (result as Success<List<CoreMsgSysItem>?>).response;
      expect(list, hasLength(2));
      expect(list![0].id, 801);
      expect(list[0].cursor, 801);
      expect(list[0].title, '系统');
      expect(list[0].content, '系统消息一');
      expect(list[0].timeAt, '2024-07-01T08:00:00Z');
      expect(list[1].title, '通知');
      expect(fake.requestCount, 1);
    });

    test('error: msgFeedNotify returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /im/unread_message_list': fixture('ottohub/error_im'),
      });

      final result = await repo.msgFeedNotify();

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'error_token');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });

    test('edge: msgFeedNotify handles an empty unread list', () async {
      makeRepo(<String, String>{
        'GET /im/unread_message_list': fixture('ottohub/im_unread_empty'),
      });

      final result = await repo.msgFeedNotify();

      expect(result, isA<Success<List<CoreMsgSysItem>?>>());
      expect((result as Success<List<CoreMsgSysItem>?>).response, isEmpty);
      expect(fake.requestCount, 1);
    });

    test('happy: msgSysUpdateCursor marks all system messages read', () async {
      makeRepo(<String, String>{
        'POST /im/read_all_system_message': fixture('ottohub/ok'),
      });

      final result = await repo.msgSysUpdateCursor(0);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('happy: removeMsg deletes the message and returns Success(null)',
        () async {
      makeRepo(<String, String>{
        'POST /im/delete_message': fixture('ottohub/ok'),
      });

      final result = await repo.removeMsg(801);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('happy: ackSessionMsg reads the message and returns Success(null)',
        () async {
      makeRepo(<String, String>{
        'POST /im/read_message': fixture('ottohub/im_read_message'),
      });

      final result = await repo.ackSessionMsg(talkerId: 3001, ackSeqno: 901);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('happy: imUserInfos resolves each uid via getUserById', () async {
      makeRepo(<String, String>{
        'GET /user/id_user_list': fixture('ottohub/user_summaries'),
      });

      final result = await repo.imUserInfos(uids: '1,2');

      expect(result, isA<Success<List<CoreImUserInfosData>?>>());
      final list = (result as Success<List<CoreImUserInfosData>?>).response;
      expect(list, hasLength(2));
      expect(list![0].mid, 1001);
      expect(list[0].name, '搜索结果甲');
      expect(list[0].face, 'https://example.com/s1.jpg');
      expect(list[0].sign, '简介甲');
      expect(list[1].mid, 1001);
      expect(list[1].sign, '简介甲');
      expect(fake.requestCount, 2);
    });

    test('edge: imUserInfos rejects an empty uid list without HTTP', () async {
      makeRepo(const <String, String>{});

      final result = await repo.imUserInfos(uids: '');

      expect(result, const Error('missing_argument'));
      expect(fake.requestCount, 0);
    });

    test('happy: createTextDynamic submits the blog and returns Success(null)',
        () async {
      makeRepo(<String, String>{
        'POST /creator/submit_blog': fixture('ottohub/submit_result'),
      });

      final result = await repo.createTextDynamic('第一行标题\n正文内容');

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('happy: msgUnread converts the new-message count into unread fields',
        () async {
      makeRepo(<String, String>{
        'GET /im/new_message_num': fixture('ottohub/im_new_message_num'),
      });

      final result = await repo.msgUnread();

      expect(result, isA<Success<CoreSingleUnreadData>>());
      final data = (result as Success<CoreSingleUnreadData>).response;
      expect(data.unfollowUnread, 7);
      expect(data.followUnread, 7);
      expect(fake.requestCount, 1);
    });

    test('happy: msgFeedUnread maps the count into sysMsg only', () async {
      makeRepo(<String, String>{
        'GET /im/new_message_num': fixture('ottohub/im_new_message_num'),
      });

      final result = await repo.msgFeedUnread();

      expect(result, isA<Success<CoreMsgFeedUnreadData>>());
      final data = (result as Success<CoreMsgFeedUnreadData>).response;
      expect(data.sysMsg, 7);
      expect(data.at, 0);
      expect(data.like, 0);
      expect(data.reply, 0);
      expect(fake.requestCount, 1);
    });
  });
}
