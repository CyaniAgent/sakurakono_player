import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_download_repository.dart';
import 'package:skf/core/models/download_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

/// Minimal entry whose [CoreBiliDownloadEntryInfo.avid] drives the SDK call.
CoreBiliDownloadEntryInfo makeEntry({int avid = 42}) => CoreBiliDownloadEntryInfo(
      isCompleted: false,
      totalBytes: 0,
      downloadedBytes: 0,
      title: '测试视频',
      cover: 'https://example.com/cover.jpg',
      preferedVideoQuality: 0,
      guessedTotalBytes: 0,
      totalTimeMilli: 0,
      danmakuCount: 0,
      avid: avid,
      bvid: '$avid',
    );

void main() {
  late FakeHttpAdapter fake;
  late OttoDownloadRepository repo;

  OttoDownloadRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    repo = OttoDownloadRepository(OttohubClient(dio: dio));
    return repo;
  }

  group('OttoDownloadRepository (implementation-level)', () {
    test('happy: getVideoUrl builds a single mp4 segment from videoUrl',
        () async {
      makeRepo(<String, String>{
        'GET /video/42': fixture('ottohub/video_detail'),
      });

      final result = await repo.getVideoUrl(entry: makeEntry());

      expect(result, isA<Success<BiliDownloadMediaInfo>>());
      final media = (result as Success<BiliDownloadMediaInfo>).response
          as CoreType1;
      expect(media.format, 'mp4');
      expect(media.isResolved, isTrue);
      expect(media.timeLength, 3661);
      expect(media.segmentList, hasLength(1));
      expect(media.segmentList.first.url, 'https://example.com/video.mp4');
      expect(media.segmentList.first.order, 0);
      expect(fake.requestCount, 1);
    });

    test('happy: getVideoUrl falls back to the m3u8 stream with m3u8 format',
        () async {
      makeRepo(<String, String>{
        'GET /video/42': fixture('ottohub/video_detail_m3u8'),
      });

      final result = await repo.getVideoUrl(entry: makeEntry());

      expect(result, isA<Success<BiliDownloadMediaInfo>>());
      final media = (result as Success<BiliDownloadMediaInfo>).response
          as CoreType1;
      expect(media.format, 'm3u8');
      expect(media.timeLength, 60);
      expect(media.segmentList.first.url, 'https://example.com/video.m3u8');
      expect(fake.requestCount, 1);
    });

    test('error: getVideoUrl returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /video/42': fixture('ottohub/error_video'),
      });

      final result = await repo.getVideoUrl(entry: makeEntry());

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'video_not_found');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });

    test('edge: getVideoUrl returns CoreNone when both URLs are null', () async {
      makeRepo(<String, String>{
        'GET /video/42': fixture('ottohub/video_detail_no_url'),
      });

      final result = await repo.getVideoUrl(entry: makeEntry());

      expect(result, isA<Success<BiliDownloadMediaInfo>>());
      final media = (result as Success<BiliDownloadMediaInfo>).response
          as CoreNone;
      expect(media.message, 'no playable url');
      expect(fake.requestCount, 1);
    });

    test('edge: getVideoUrl tolerates a minimal detail with no URLs', () async {
      makeRepo(<String, String>{
        'GET /video/42': fixture('ottohub/video_detail_minimal'),
      });

      final result = await repo.getVideoUrl(entry: makeEntry());

      expect(result, isA<Success<BiliDownloadMediaInfo>>());
      final media = (result as Success<BiliDownloadMediaInfo>).response
          as CoreNone;
      expect(media.message, 'no playable url');
      expect(fake.requestCount, 1);
    });
  });
}
