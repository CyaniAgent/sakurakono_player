import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_http_adapter.dart';

void main() {
  group('FakeHttpAdapter', () {
    late FakeHttpAdapter fake;
    late Dio dio;

    setUp(() {
      fake = FakeHttpAdapter(<String, String>{
        'GET /x/web-interface/view': '{"code":0,"data":{"bvid":"BV1xx"}}',
        'POST /x/msg/ack': '{"code":0}',
      });
      dio = Dio(
        BaseOptions(
          baseUrl: 'http://localhost',
          // Permit 4xx/5xx so error paths are reachable in tests.
          validateStatus: (_) => true,
        ),
      )
        ..httpClientAdapter = fake;
    });

    test('registered route returns 200 with exact body and content-type', () async {
      final res = await dio.get<String>(
        '/x/web-interface/view',
        options: Options(responseType: ResponseType.plain),
      );
      expect(res.statusCode, 200);
      expect(res.data, '{"code":0,"data":{"bvid":"BV1xx"}}');
      expect(
        res.headers.value(Headers.contentTypeHeader),
        'application/json; charset=utf-8',
      );
    });

    test('unknown path returns 404 JSON', () async {
      final res = await dio.get<String>(
        '/x/web-interface/unknown',
        options: Options(responseType: ResponseType.plain),
      );
      expect(res.statusCode, 404);
      expect(res.data, '{"code":-404,"message":"not routed"}');
    });

    test('query string is ignored for routing', () async {
      final res = await dio.get<String>(
        '/x/web-interface/view?bvid=BV1xx&p=1',
        options: Options(responseType: ResponseType.plain),
      );
      expect(res.statusCode, 200);
      expect(res.data, '{"code":0,"data":{"bvid":"BV1xx"}}');
    });

    test('POST and GET on the same path route independently', () async {
      final getRes = await dio.get<String>(
        '/x/msg/ack',
        options: Options(responseType: ResponseType.plain),
      );
      expect(getRes.statusCode, 404);

      final postRes = await dio.post<String>(
        '/x/msg/ack',
        options: Options(responseType: ResponseType.plain),
      );
      expect(postRes.statusCode, 200);
      expect(postRes.data, '{"code":0}');
    });
  });
}
