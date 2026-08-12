import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Hand-rolled [HttpClientAdapter] for implementation-level repository tests.
///
/// dio 5.x ships no mock adapter (MockAdapter was removed), so this is the
/// shared replacement for the whole test suite: T6 (OttoHub repos) and
/// T7 (Bili repos) run REAL repository code against fake HTTP responses.
///
/// Routes are keyed by `"METHOD path"` — e.g. `"GET /x/web-interface/view"`.
/// Matching ignores the query string (`Uri.parse(options.path).path`), so
/// `?bvid=...&p=1` still routes to the bare path. Registered routes return
/// the mapped JSON string with HTTP 200 and `application/json; charset=utf-8`;
/// unknown routes return `{"code":-404,"message":"not routed"}` with HTTP 404
/// so error paths are exercised instead of silently passing.
///
/// To let 4xx/5xx responses reach repository error-handling code instead of
/// being thrown by dio, tests must allow them:
///
/// ```dart
/// final dio = Dio(BaseOptions(validateStatus: (_) => true))
///   ..httpClientAdapter = fake;
/// ```
class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(Map<String, String> routes) : _routes = Map.of(routes);

  static const int _okStatus = 200;
  static const int _notFoundStatus = 404;
  static const String _notFoundBody = '{"code":-404,"message":"not routed"}';
  static const String _jsonContentType = 'application/json; charset=utf-8';

  /// `"METHOD path"` → JSON body. A defensive copy; routes can be added or
  /// removed by the test after construction.
  final Map<String, String> _routes;

  /// Number of requests served, for asserting a route was actually hit.
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    final body = _routes[_routeKey(options)];
    if (body == null) {
      return ResponseBody.fromString(
        _notFoundBody,
        _notFoundStatus,
        headers: {Headers.contentTypeHeader: [_jsonContentType]},
      );
    }
    return ResponseBody.fromString(
      body,
      _okStatus,
      headers: {Headers.contentTypeHeader: [_jsonContentType]},
    );
  }

  /// `"GET /path"` with the query string stripped, so `options.path` may be a
  /// bare path or a full URL and still match the same route.
  String _routeKey(RequestOptions options) {
    final path = Uri.parse(options.path).path;
    return '${options.method} $path';
  }

  @override
  void close({bool force = false}) {
    // Nothing to release: no sockets, no clients.
  }
}
