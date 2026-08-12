import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_black_repository.dart';
import 'package:skf/core/models/black_status.dart';
import 'package:skf/core/models/blacklist_data.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late OttoBlackRepository repo;

  OttoBlackRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    repo = OttoBlackRepository(OttohubClient(dio: dio));
    return repo;
  }

  group('OttoBlackRepository (implementation-level)', () {
    test('happy: blackList converts BlockRecord list with parsed mtime',
        () async {
      makeRepo(<String, String>{
        'GET /block/list': fixture('ottohub/block_list'),
      });

      final result = await repo.blackList(pn: 1);

      expect(result, isA<Success<CoreBlackListData>>());
      final data = (result as Success<CoreBlackListData>).response;
      expect(data.total, 2);
      expect(data.list, hasLength(2));
      final first = data.list!.first;
      expect(first.mid, 777);
      expect(first.uname, '小黑一号');
      expect(first.face, 'https://example.com/black1.jpg');
      // "2024-05-01T12:00:00Z" → epoch seconds.
      expect(
        first.mtime,
        DateTime.parse('2024-05-01T12:00:00Z').millisecondsSinceEpoch ~/ 1000,
      );
      expect(data.list![1].mid, 778);
      expect(fake.requestCount, 1);
    });

    test('happy: checkBlack converts BlockStatusResponse flags', () async {
      makeRepo(<String, String>{
        'GET /block/status/777': fixture('ottohub/block_status'),
      });

      final result = await repo.checkBlack(uid: 777);

      expect(result, isA<Success<CoreBlackStatus>>());
      final status = (result as Success<CoreBlackStatus>).response;
      expect(status.targetUserId, 777);
      expect(status.iBlocked, isTrue);
      expect(status.heBlocked, isFalse);
      expect(status.mutualBlock, isFalse);
      expect(status.anyBlock, isTrue);
      expect(fake.requestCount, 1);
    });

    test('happy: addBlack posts the block and returns Success(null)', () async {
      makeRepo(<String, String>{
        'POST /block': fixture('ottohub/block_response'),
      });

      final result = await repo.addBlack(uid: 777);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('happy: removeBlack deletes the block and returns Success(null)',
        () async {
      makeRepo(<String, String>{
        'DELETE /block/777': fixture('ottohub/block_response'),
      });

      final result = await repo.removeBlack(uid: 777);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('error: blackList returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /block/list': fixture('ottohub/error_block'),
      });

      final result = await repo.blackList(pn: 1);

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'user_not_found');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });

    test('edge: blackList handles an empty list with total 0', () async {
      makeRepo(<String, String>{
        'GET /block/list': fixture('ottohub/block_list_empty'),
      });

      final result = await repo.blackList(pn: 1);

      expect(result, isA<Success<CoreBlackListData>>());
      final data = (result as Success<CoreBlackListData>).response;
      expect(data.total, 0);
      expect(data.list, isEmpty);
      expect(fake.requestCount, 1);
    });
  });
}
