import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_im_repository.dart';
import 'package:skf/core/models/im_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late OttoImRepository repo;

  OttoImRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    repo = OttoImRepository(OttohubClient(dio: dio));
    return repo;
  }

  group('OttoImRepository (implementation-level)', () {
    test('happy: sendMsg posts the message and echoes the content', () async {
      makeRepo(<String, String>{
        'POST /im/send_message': fixture('ottohub/ok'),
      });

      final result = await repo.sendMsg(
        senderUid: 10086,
        receiverId: 3001,
        content: '你好',
      );

      expect(result, isA<Success<CoreImRspSendMsg>>());
      final rsp = (result as Success<CoreImRspSendMsg>).response;
      expect(rsp.msgKey, 0);
      expect(rsp.msgContent, '你好');
      expect(rsp.seqno, 0);
      expect(fake.requestCount, 1);
    });

    test('happy: syncFetchSessionMsgs converts messages with parsed timestamps',
        () async {
      makeRepo(<String, String>{
        'GET /im/friend_message': fixture('ottohub/im_friend_messages'),
      });

      final result = await repo.syncFetchSessionMsgs(
        talkerId: 3001,
        endSeqno: 2,
        beginSeqno: 0,
      );

      expect(result, isA<Success<CoreImRspSessionMsg>>());
      final rsp = (result as Success<CoreImRspSessionMsg>).response;
      expect(rsp.messages, hasLength(2));
      final first = rsp.messages.first;
      expect(first.msgKey, 901);
      expect(first.msgType, 1);
      expect(first.content, '你好呀');
      expect(first.seqno, 901);
      expect(first.senderUid, 3001);
      expect(
        first.timestamp,
        DateTime.parse('2024-07-04 10:00:00').millisecondsSinceEpoch ~/ 1000,
      );
      expect(fake.requestCount, 1);
    });

    test('happy: sessionMain converts the friend list into sessions', () async {
      makeRepo(<String, String>{
        'GET /im/friend_list': fixture('ottohub/im_friend_list'),
      });

      final result = await repo.sessionMain();

      expect(result, isA<Success<CoreImSessionMainReply>>());
      final reply = (result as Success<CoreImSessionMainReply>).response;
      expect(reply.sessions, hasLength(2));
      final first = reply.sessions.first;
      expect(first.talkerId, 3001);
      expect(first.sessionType, 1);
      expect(first.unreadCount, 2);
      expect(first.sessionName, '私信好友甲');
      // Second friend has null newMessageNum → 0.
      expect(reply.sessions[1].unreadCount, 0);
      expect(fake.requestCount, 1);
    });

    test('happy: sessionMain forwards the first offset entry as pagination',
        () async {
      makeRepo(<String, String>{
        'GET /im/friend_list': fixture('ottohub/im_friend_list'),
      });

      final result = await repo.sessionMain(
        offset: {
          CoreImSessionPageType.home.index: const CoreImOffset(
            normalOffset: 40,
            topOffset: 5,
          ),
        },
      );

      // Non-empty offset map must not crash and yields the same conversion.
      expect(result, isA<Success<CoreImSessionMainReply>>());
      final reply = (result as Success<CoreImSessionMainReply>).response;
      expect(reply.sessions, hasLength(2));
      expect(reply.sessions.first.talkerId, 3001);
      expect(fake.requestCount, 1);
    });

    test('happy: clearUnread marks all system messages read', () async {
      makeRepo(<String, String>{
        'POST /im/read_all_system_message': fixture('ottohub/ok'),
      });

      final result = await repo.clearUnread();

      expect(result, isA<Success<CoreImClearUnreadReply>>());
      expect(fake.requestCount, 1);
    });

    test('happy: getTotalUnread converts the new-message count', () async {
      makeRepo(<String, String>{
        'GET /im/new_message_num': fixture('ottohub/im_new_message_num'),
      });

      final result = await repo.getTotalUnread();

      expect(result, isA<Success<CoreImRspTotalUnread>>());
      expect(
        (result as Success<CoreImRspTotalUnread>).response.totalUnread,
        7,
      );
      expect(fake.requestCount, 1);
    });

    test('happy: deleteSessionList deletes every friend-session message',
        () async {
      makeRepo(<String, String>{
        'GET /im/friend_list': fixture('ottohub/im_friend_list'),
        'GET /im/friend_message': fixture('ottohub/im_friend_messages'),
        'POST /im/delete_message': fixture('ottohub/ok'),
      });

      final result = await repo.deleteSessionList();

      expect(result, isA<Success<CoreImDeleteSessionListReply>>());
      // 1 friend-list + 2 message fetches + 4 message deletes.
      expect(fake.requestCount, 7);
    });

    test('happy: sessionDetail resolves the friend from the friend list',
        () async {
      makeRepo(<String, String>{
        'GET /im/friend_list': fixture('ottohub/im_friend_list'),
      });

      final result = await repo.sessionDetail(talkerId: 3001);

      expect(result, isA<Success<CoreImSessionInfo>>());
      final info = (result as Success<CoreImSessionInfo>).response;
      expect(info.talkerId, 3001);
      expect(info.sessionType, 1);
      expect(info.unreadCount, 2);
      expect(info.groupName, '私信好友甲');
      expect(info.groupCover, 'https://example.com/friend1.jpg');
      expect(fake.requestCount, 1);
    });

    test('happy: sessionDetail falls back to a generic user lookup', () async {
      makeRepo(<String, String>{
        'GET /im/friend_list': fixture('ottohub/im_friend_list_empty'),
        'GET /user/1001': fixture('ottohub/user_1001_profile'),
      });

      final result = await repo.sessionDetail(talkerId: 1001);

      expect(result, isA<Success<CoreImSessionInfo>>());
      final info = (result as Success<CoreImSessionInfo>).response;
      expect(info.talkerId, 1001);
      expect(info.groupName, '搜索结果甲');
      expect(info.groupCover, 'https://example.com/s1.jpg');
      expect(fake.requestCount, 2);
    });

    test('error: sessionDetail reports missing session when not found',
        () async {
      makeRepo(<String, String>{
        'GET /im/friend_list': fixture('ottohub/im_friend_list_empty'),
        'GET /user/1001': fixture('ottohub/error_block'),
      });

      final result = await repo.sessionDetail(talkerId: 999);

      expect(result, const Error('OttoHub: 会话不存在'));
      expect(fake.requestCount, 2);
    });
  });
}
