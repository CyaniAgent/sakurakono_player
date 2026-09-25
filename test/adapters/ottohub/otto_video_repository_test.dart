import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_video_repository.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

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

  group('OttoVideoRepository (implementation-level)', () {
    test('happy: videoIntro converts VideoDetail fixture into CoreVideoDetailData',
        () async {
      makeRepo(<String, String>{
        'GET /video/42': fixture('ottohub/video_detail'),
      });

      final result = await repo.videoIntro(bvid: '42');

      expect(result, isA<Success<CoreVideoDetailData>>());
      final detail = (result as Success<CoreVideoDetailData>).response;
      expect(detail.bvid, '42');
      expect(detail.aid, 42);
      expect(detail.cid, 42);
      expect(detail.pic, 'https://example.com/cover.jpg');
      expect(detail.title, '测试视频标题');
      expect(detail.desc, '这是一个视频简介');
      expect(detail.duration, 3661);
      // "2024-01-15T10:30:00Z" → 1705314600 epoch seconds.
      expect(detail.pubdate, 1705314600);
      expect(detail.owner, <String, dynamic>{
        'mid': 10086,
        'name': '测试UP主',
        'face': 'https://example.com/avatar.jpg',
      });
      expect(detail.stat, <String, dynamic>{
        'view': 89012,
        'like': 1234,
        'favorite': 567,
        'danmu': 321,
      });
      expect(fake.requestCount, 1);
    });

    test('happy: videoUrl maps videoUrl/videoM3u8Url into durl entries', () async {
      makeRepo(<String, String>{
        'GET /video/42': fixture('ottohub/video_detail'),
      });

      final result = await repo.videoUrl(
        avid: 42,
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
      expect(play.timeLength, 3661 * 1000); // 秒 → 毫秒
      expect(play.lastPlayTime, 0); // last_watch_second 为空
      expect(fake.requestCount, 1);
    });

    test('happy: rcmdVideoList converts VideoSummary list with string counts',
        () async {
      makeRepo(<String, String>{
        'GET /video/random': fixture('ottohub/video_list'),
      });

      final result = await repo.rcmdVideoList(ps: 10, freshIdx: 0);

      expect(result, isA<Success<List<CoreRcmdVideoItemModel>>>());
      final list = (result as Success<List<CoreRcmdVideoItemModel>>).response;
      expect(list, hasLength(2));
      final first = list.first;
      expect(first.aid, 101);
      expect(first.bvid, '101');
      expect(first.cid, 101);
      expect(first.cover, 'https://example.com/a.jpg');
      expect(first.title, '推荐视频A');
      expect(first.duration, 300);
      expect(first.goto, 'av');
      expect(
        first.pubdate,
        DateTime.parse('2024-03-01T12:00:00Z').millisecondsSinceEpoch ~/ 1000,
      );
      expect(first.owner, <String, dynamic>{
        'mid': 1001,
        'name': 'UP主A',
        'face': 'https://example.com/a_avatar.jpg',
      });
      expect(first.stat, <String, dynamic>{
        'view': 4500,
        'like': 120,
        'favorite': 30,
      });
      // Second item has null avatar_url → face defaults to ''.
      expect(list[1].owner, <String, dynamic>{
        'mid': 1002,
        'name': 'UP主B',
        'face': '',
      });
      expect(fake.requestCount, 1);
    });

    test('error: videoIntro returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /video/99': fixture('ottohub/error_video'),
      });

      final result = await repo.videoIntro(bvid: '99');

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'video_not_found');
      expect(err.code, 200); // httpStatus of the envelope response
      expect(fake.requestCount, 1);
    });

    test('error: videoIntro rejects non-numeric bvid without any HTTP', () async {
      makeRepo(const <String, String>{});

      final result = await repo.videoIntro(bvid: 'BV1xx');

      expect(result, const Error('OttoHub: 无效的视频ID（仅支持纯数字ID）'));
      expect(fake.requestCount, 0);
    });

    test('edge: videoIntro tolerates missing optional fields', () async {
      makeRepo(<String, String>{
        'GET /video/7': fixture('ottohub/video_detail_minimal'),
      });

      final result = await repo.videoIntro(bvid: '7');

      expect(result, isA<Success<CoreVideoDetailData>>());
      final detail = (result as Success<CoreVideoDetailData>).response;
      expect(detail.title, '最小字段视频');
      expect(detail.desc, ''); // intro missing
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

    test('edge: rcmdVideoList handles an empty video_list', () async {
      makeRepo(<String, String>{
        'GET /video/random': fixture('ottohub/video_list_empty'),
      });

      final result = await repo.rcmdVideoList(ps: 10, freshIdx: 0);

      expect(result, isA<Success<List<CoreRcmdVideoItemModel>>>());
      expect(
        (result as Success<List<CoreRcmdVideoItemModel>>).response,
        isEmpty,
      );
      expect(fake.requestCount, 1);
    });
  });

  group('OttoVideoRepository hotVideoList (period ranking)', () {
    test('happy: page 1 weekly ranking maps time_limit and zero offset',
        () async {
      makeRepo(<String, String>{
        'GET /video/popular': fixture('ottohub/video_list'),
      });

      final result = await repo.hotVideoList(pn: 1, ps: 20, timeLimitDays: 7);

      expect(result, isA<Success<List<CoreHotVideoItemModel>>>());
      final list = (result as Success<List<CoreHotVideoItemModel>>).response;
      expect(list, hasLength(2));
      expect(list.first.title, '推荐视频A');
      expect(fake.loggedRequests.single.queryParameters['time_limit'], 7);
      expect(fake.loggedRequests.single.queryParameters['offset'], 0);
      expect(fake.loggedRequests.single.queryParameters['num'], 20);
    });

    test('happy: page 3 maps pn to row offset (pn-1)*ps, monthly window',
        () async {
      makeRepo(<String, String>{
        'GET /video/popular': fixture('ottohub/video_list'),
      });

      final result = await repo.hotVideoList(pn: 3, ps: 20, timeLimitDays: 30);

      expect(result, isA<Success<List<CoreHotVideoItemModel>>>());
      expect(fake.loggedRequests.single.queryParameters['time_limit'], 30);
      expect(fake.loggedRequests.single.queryParameters['offset'], 40);
    });

    test('happy: null timeLimitDays omits the window parameter', () async {
      makeRepo(<String, String>{
        'GET /video/popular': fixture('ottohub/video_list'),
      });

      final result = await repo.hotVideoList(pn: 1, ps: 20);

      expect(result, isA<Success<List<CoreHotVideoItemModel>>>());
      expect(fake.loggedRequests.single.queryParameters.containsKey(
        'time_limit',
      ), isFalse);
    });
  });

  group('OttoVideoRepository categoryVideoList (zone)', () {
    test('happy: category id goes into the path, num clamped to server cap',
        () async {
      makeRepo(<String, String>{
        'GET /video/category/0': fixture('ottohub/video_list'),
      });

      final result = await repo.categoryVideoList(category: 0, num: 50);

      expect(result, isA<Success<List<CoreHotVideoItemModel>>>());
      expect(
        (result as Success<List<CoreHotVideoItemModel>>).response,
        hasLength(2),
      );
      // 服务端 num 上限 20(超出 http_400),仓库层钳制。
      expect(fake.loggedRequests.single.queryParameters['num'], 20);
    });

    test('error: unrouted category surfaces as Error', () async {
      makeRepo(<String, String>{});

      final result = await repo.categoryVideoList(category: 9, num: 50);

      expect(result, isA<Error>());
    });
  });
}
