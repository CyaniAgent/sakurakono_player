import 'dart:io' show HttpException;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_app_repository.dart';
import 'package:skf/core/models/app_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late OttoAppRepository repo;

  OttoAppRepository makeRepo(
    Map<String, String> routes, {
    Future<(int, int)?> Function(String url)? probeImageSize,
  }) {
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
    // prober 置空函数:测试离线,不探测封面尺寸(可注入替换)。
    repo = OttoAppRepository(
      OttohubClient(dio: dio, config: const BaseApiConfig(wrapHttpErrors: true)),
      probeImageSize: probeImageSize ?? (_) async => null,
    );
    return repo;
  }

  group('OttoAppRepository (implementation-level)', () {
    test('checkUpdate always reports no update', () async {
      makeRepo(<String, String>{});

      final result = await repo.checkUpdate();

      expect(result, isA<Success<CoreUpdateInfo>>());
      final info = (result as Success<CoreUpdateInfo>).response;
      expect(info.hasUpdate, isFalse);
      expect(info.latestVersion, isNull);
      expect(info.downloadUrl, isNull);
      expect(info.releaseNotes, isNull);
      expect(info.publishedAt, isNull);
    });

    test('checkUpdate ignores the currentVersion parameter', () async {
      makeRepo(<String, String>{});

      final result = await repo.checkUpdate(currentVersion: '9.9.9');

      expect(result, isA<Success<CoreUpdateInfo>>());
      expect((result as Success<CoreUpdateInfo>).response.hasUpdate, isFalse);
    });
  });

  group('OttoAppRepository slideshow', () {
    test('happy: maps slides into CoreSlide list', () async {
      makeRepo(<String, String>{
        'GET /system/slideshow': fixture('ottohub/slideshow'),
      });

      final result = await repo.slideshow();

      expect(result, isA<Success<List<CoreSlide>>>());
      final slides = (result as Success<List<CoreSlide>>).response;
      expect(slides, hasLength(3));
      expect(slides[0].imgUrl, 'https://img.ottohub.cn/image/slide1.png');
      expect(slides[0].title, '第一条轮播');
      expect(slides[0].href, 'https://www.ottohub.cn/v/32823');
      expect(slides[1].href, 'https://www.ottohub.cn/b/55481');
      // 缺省字段容错。
      expect(slides[2].title, isNull);
      expect(slides[2].href, isNull);
    });

    test('happy: probed first-slide size is reported on CoreSlide', () async {
      final probedUrls = <String>[];
      makeRepo(<String, String>{
        'GET /system/slideshow': fixture('ottohub/slideshow'),
      }, probeImageSize: (url) async {
        probedUrls.add(url);
        return (1600, 900);
      });

      final result = await repo.slideshow();

      final slides = (result as Success<List<CoreSlide>>).response;
      expect(probedUrls, ['https://img.ottohub.cn/image/slide1.png']);
      expect(slides[0].width, 1600);
      expect(slides[0].height, 900);
    });

    test('happy: probe failure keeps CoreSlide size null', () async {
      makeRepo(<String, String>{
        'GET /system/slideshow': fixture('ottohub/slideshow'),
      }, probeImageSize: (_) async => throw const HttpException('offline'));

      final result = await repo.slideshow();

      expect(result, isA<Success<List<CoreSlide>>>());
      final slides = (result as Success<List<CoreSlide>>).response;
      expect(slides[0].width, isNull);
      expect(slides[0].height, isNull);
    });

    test('edge: empty slides list succeeds with no entries', () async {
      makeRepo(<String, String>{
        'GET /system/slideshow': '{"status":"success","data":{"slides":[]}}',
      });

      final result = await repo.slideshow();

      expect(result, isA<Success<List<CoreSlide>>>());
      expect((result as Success<List<CoreSlide>>).response, isEmpty);
    });

    test('error: server error surfaces as Error state', () async {
      makeRepo(<String, String>{});

      final result = await repo.slideshow();

      expect(result, isA<Error>());
    });
  });
}
