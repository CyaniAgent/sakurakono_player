import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_video_repository.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../helpers/fake_http_adapter.dart';
import '../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late OttoVideoRepository repo;

  OttoVideoRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    // wrapHttpErrors 与生产 bridge 一致:HTTP 错误包装成 ApiException。
    repo = OttoVideoRepository(
      OttohubClient(dio: dio, config: const BaseApiConfig(wrapHttpErrors: true)),
    );
    return repo;
  }

  group('OttoVideoRepository.videoUrl (implementation-level)', () {
    test('happy: string bvid is resolved to the detail endpoint and mapped '
        'into durl entries', () async {
      makeRepo(<String, String>{
        'GET /video/42': fixture('ottohub/video_detail'),
      });

      final result = await repo.videoUrl(
        bvid: '42',
        cid: 42,
        tryLook: false,
        videoType: CoreVideoType.ugc,
      );

      expect(result, isA<Success<CorePlayUrlModel>>());
      final play = (result as Success<CorePlayUrlModel>).response;
      expect(play.durl, <Map<String, dynamic>>[
        <String, dynamic>{'url': 'https://example.com/video.mp4'},
        <String, dynamic>{'url': 'https://example.com/video.m3u8'},
      ]);
      expect(play.quality, 0); // OttoHub 无画质概念
      expect(play.timeLength, 3661 * 1000); // 契约毫秒 ← SDK 秒
      expect(play.lastPlayTime, 0); // last_watch_second 为 null
      // 请求确实落到了 /video/42(bvid 字符串 → 路径参数)。
      expect(fake.loggedRequests.single.method, 'GET');
      expect(Uri.parse(fake.loggedRequests.single.path).path, '/video/42');
      expect(fake.requestCount, 1);
    });

    test('error: non-numeric bvid is rejected locally without any HTTP',
        () async {
      makeRepo(const <String, String>{});

      final result = await repo.videoUrl(
        bvid: 'BV1xx',
        cid: 1,
        tryLook: false,
        videoType: CoreVideoType.ugc,
      );

      expect(result, const Error('OttoHub: 无效的视频ID（仅支持纯数字ID）'));
      expect(fake.requestCount, 0);
    });

    test('error: status=error envelope surfaces errMsg and envelope httpStatus',
        () async {
      makeRepo(<String, String>{
        'GET /video/99': fixture('ottohub/error_video'),
      });

      final result = await repo.videoUrl(
        avid: 99,
        cid: 99,
        tryLook: false,
        videoType: CoreVideoType.ugc,
      );

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'video_not_found');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });
  });

  group('OttoVideoRepository.videoIntro (implementation-level)', () {
    test('edge: minimal payload fills missing optional fields with defaults',
        () async {
      makeRepo(<String, String>{
        'GET /video/7': fixture('ottohub/video_detail_minimal'),
      });

      final result = await repo.videoIntro(bvid: '7');

      expect(result, isA<Success<CoreVideoDetailData>>());
      final detail = (result as Success<CoreVideoDetailData>).response;
      expect(detail.bvid, '7');
      expect(detail.aid, 7);
      expect(detail.cid, 7);
      expect(detail.title, '最小字段视频');
      expect(detail.desc, ''); // intro missing
      expect(detail.pic, 'https://example.com/min.jpg');
      expect(detail.owner, <String, dynamic>{
        'mid': 1,
        'name': '无头像用户',
        'face': '', // avatar_url missing
      });
      expect(detail.stat, <String, dynamic>{
        'view': 1,
        'like': 0,
        'favorite': 0,
        'danmu': 0, // comment_count missing
      });
      expect(fake.requestCount, 1);
    });
  });

  group('OttoVideoRepository.categoryVideoList (implementation-level)', () {
    test('happy: category id goes into the path and num is clamped to the '
        'server cap of 20', () async {
      makeRepo(<String, String>{
        'GET /video/category/3': fixture('ottohub/video_list'),
      });

      final result = await repo.categoryVideoList(category: 3, num: 50);

      expect(result, isA<Success<List<CoreHotVideoItemModel>>>());
      final list = (result as Success<List<CoreHotVideoItemModel>>).response;
      expect(list, hasLength(2));
      expect(list.first.aid, 101);
      expect(list.first.title, '推荐视频A');
      // 服务端 num 上限 20(超出 http_400),仓库层钳制。
      expect(fake.loggedRequests.single.queryParameters['num'], 20);
      // 分区 id 作为路径段而非 query 参数。
      expect(Uri.parse(fake.loggedRequests.single.path).path,
          '/video/category/3');
      expect(fake.requestCount, 1);
    });

    test('happy: string counts in the payload are coerced into int stats',
        () async {
      makeRepo(<String, String>{
        'GET /video/category/0': fixture('ottohub/video_list'),
      });

      final result = await repo.categoryVideoList(category: 0, num: 20);

      final list = (result as Success<List<CoreHotVideoItemModel>>).response;
      expect(list[1].stat, <String, dynamic>{
        'view': 450, // "450" → 450
        'like': 12,
        'favorite': 3,
      });
      // null avatar_url → face 默认空串。
      expect(list[1].owner!['face'], '');
      expect(fake.requestCount, 1);
    });

    test('error: unrouted category surfaces as Error', () async {
      makeRepo(const <String, String>{});

      final result = await repo.categoryVideoList(category: 9, num: 50);

      expect(result, isA<Error>());
      expect(fake.requestCount, 1);
    });
  });
}
