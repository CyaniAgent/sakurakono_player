import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_fav_repository.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../helpers/fake_http_adapter.dart';
import '../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late OttoFavRepository repo;

  OttoFavRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    repo = OttoFavRepository(OttohubClient(dio: dio));
    return repo;
  }

  group('OttoFavRepository.userfavFolder (implementation-level)', () {
    test('happy: collection names are paginated into synthesized folders',
        () async {
      makeRepo(<String, String>{
        'GET /collection/get_user_video_collection':
            fixture('ottohub/collection_list'),
      });

      final result = await repo.userfavFolder(pn: 1, ps: 2, mid: 7);

      expect(result, isA<Success<CoreFavFolderData>>());
      final data = (result as Success<CoreFavFolderData>).response;
      expect(data.count, 3); // 全量计数,非本页条数
      expect(data.list, hasLength(2)); // ps=2 截取前两个
      expect(data.list![0].id, 0); // (pn-1)*ps + index
      expect(data.list![0].title, '合集A');
      expect(data.list![0].mid, 7);
      expect(data.list![1].id, 1);
      expect(data.list![1].title, '合集B');
      expect(data.hasMore, isTrue); // 1*2 < 3
      expect(fake.requestCount, 1);
    });

    test('happy: page 2 returns the tail slice without hasMore', () async {
      makeRepo(<String, String>{
        'GET /collection/get_user_video_collection':
            fixture('ottohub/collection_list'),
      });

      final result = await repo.userfavFolder(pn: 2, ps: 2, mid: 7);

      final data = (result as Success<CoreFavFolderData>).response;
      expect(data.list, hasLength(1));
      expect(data.list!.single.id, 2);
      expect(data.list!.single.title, '合集C');
      expect(data.hasMore, isFalse); // 2*2 >= 3
      expect(fake.requestCount, 1);
    });

    test('error: null mid is rejected locally without any HTTP', () async {
      makeRepo(const <String, String>{});

      final result = await repo.userfavFolder(pn: 1, ps: 20, mid: null);

      expect(result, const Error('missing_mid'));
      expect(fake.requestCount, 0);
    });

    test('error: status=error envelope surfaces errMsg and envelope httpStatus',
        () async {
      makeRepo(<String, String>{
        'GET /collection/get_user_video_collection':
            fixture('ottohub/error_block'),
      });

      final result = await repo.userfavFolder(pn: 1, ps: 20, mid: 7);

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'user_not_found');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });
  });

  group('OttoFavRepository.allFavFolders (implementation-level)', () {
    test('happy: returns every name with index-based ids and no hasMore',
        () async {
      makeRepo(<String, String>{
        'GET /collection/get_user_video_collection':
            fixture('ottohub/collection_list'),
      });

      final result = await repo.allFavFolders(7);

      expect(result, isA<Success<CoreFavFolderData>>());
      final data = (result as Success<CoreFavFolderData>).response;
      expect(data.count, 3);
      expect(data.list, hasLength(3));
      expect(data.list![2].id, 2);
      expect(data.list![2].title, '合集C');
      expect(data.list![2].mid, 7);
      expect(data.hasMore, isFalse); // 全量返回,无下一页
      expect(fake.requestCount, 1);
    });

    test('error: non-numeric mid is rejected locally without any HTTP',
        () async {
      makeRepo(const <String, String>{});

      final result = await repo.allFavFolders('abc');

      expect(result, const Error('invalid_media_id'));
      expect(fake.requestCount, 0);
    });
  });

  group('OttoFavRepository.userFavFolderDetail (implementation-level)', () {
    test('happy: converts the flat favorite video list and synthesizes info',
        () async {
      makeRepo(<String, String>{
        'GET /video/favorite-list': fixture('ottohub/favorite_list'),
      });

      final result = await repo.userFavFolderDetail(mediaId: 42, pn: 1, ps: 20);

      expect(result, isA<Success<CoreFavDetailData>>());
      final data = (result as Success<CoreFavDetailData>).response;
      expect(data.info!.id, 42); // mediaId 回填
      expect(data.info!.mediaCount, 2); // total_count
      expect(data.medias, hasLength(2));
      final first = data.medias!.first;
      expect(first.id, 401);
      expect(first.type, 2);
      expect(first.title, '收藏视频一');
      expect(first.cover, 'https://example.com/f1.jpg');
      expect(first.intro, '收藏简介一');
      expect(first.duration, 120);
      expect(first.upper!.mid, 1001);
      expect(first.upper!.name, 'UP主A');
      expect(first.upper!.face, 'https://example.com/avatar1.jpg');
      expect(first.cntInfo!.play, 200);
      expect(data.hasMore, isFalse); // 1*20 >= 2
      // offset/num 分页参数真实下发。
      expect(fake.loggedRequests.single.queryParameters['offset'], 0);
      expect(fake.loggedRequests.single.queryParameters['num'], 20);
      expect(fake.requestCount, 1);
    });

    test('happy: pn=2 maps to a non-zero offset', () async {
      makeRepo(<String, String>{
        'GET /video/favorite-list': fixture('ottohub/favorite_list'),
      });

      await repo.userFavFolderDetail(mediaId: 42, pn: 2, ps: 10);

      expect(fake.loggedRequests.single.queryParameters['offset'], 10);
      expect(fake.loggedRequests.single.queryParameters['num'], 10);
    });
  });

  group('OttoFavRepository capability downgrade', () {
    test('favTopic returns not_implemented Error without any HTTP', () async {
      makeRepo(const <String, String>{});

      final result = await repo.favTopic(page: 1);

      expect(result, isA<Error>());
      expect((result as Error).errMsg, 'not_implemented');
      expect(fake.requestCount, 0);
    });
  });
}
