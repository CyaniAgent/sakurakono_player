import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_dynamics_repository.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

/// AccountProvider double exposing a fixed [userId] without touching Hive.
class _FakeAccountProvider extends AccountProvider {
  _FakeAccountProvider(this._uid);

  final int? _uid;

  @override
  RxString get rxFace => ''.obs;
  @override
  RxBool get rxIsLogin => false.obs;
  @override
  String? get face => null;
  @override
  bool get isLogin => false;
  @override
  int? get userId => _uid;
  @override
  String? get displayName => null;
  @override
  void restoreFromCache() {}
  @override
  Map<String, String> get authHeaders => const {};
  @override
  Map<String, String> get grpcMetadata => const {};
  @override
  Stream<bool> onAuthStateChanged() => const Stream<bool>.empty();
}

void main() {
  late FakeHttpAdapter fake;
  late OttoDynamicsRepository repo;

  OttoDynamicsRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    repo = OttoDynamicsRepository(OttohubClient(dio: dio));
    return repo;
  }

  setUp(() {
    Get.put<AccountProvider>(_FakeAccountProvider(10086));
  });

  tearDown(Get.reset);

  group('OttoDynamicsRepository (implementation-level)', () {
    test('happy: followDynamic converts the timeline into core dynamics',
        () async {
      makeRepo(<String, String>{
        'GET /following/timeline': fixture('ottohub/timeline'),
      });

      final result = await repo.followDynamic(hostMid: 0);

      expect(result, isA<Success<CoreDynamicsDataModel>>());
      final data = (result as Success<CoreDynamicsDataModel>).response;
      expect(data.items, hasLength(2));
      final first = data.items!.first;
      expect(first.idStr, '42');
      expect(first.type, 'video');
      expect(first.basic!.commentIdStr, '42');
      expect(first.modules!.moduleAuthor!.mid, 10086);
      expect(first.modules!.moduleAuthor!.name, '测试用户');
      expect(first.modules!.moduleAuthor!.face, 'https://example.com/avatar.jpg');
      expect(first.modules!.moduleAuthor!.pubTime, '2024-03-05T10:00:00Z');
      expect(first.modules!.moduleStat!.like!.count, 99);
      expect(first.modules!.moduleStat!.favorite!.count, 11);
      expect(first.modules!.moduleDynamic!.desc!.text, '发布了一个新视频');
      expect(first.modules!.moduleDynamic!.major!.type, 'archive');
      expect(first.modules!.moduleDynamic!.major!.archive!.aid, 42);
      expect(first.modules!.moduleDynamic!.major!.archive!.cover,
          'https://example.com/dyn1.jpg');
      expect(first.modules!.moduleDynamic!.major!.archive!.title, '动态视频');
      // next offset derived from the item count.
      expect(data.offset, '2');
      expect(data.hasMore, isFalse);
      expect(fake.requestCount, 1);
    });

    test('error: followDynamic returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /following/timeline': fixture('ottohub/error_following'),
      });

      final result = await repo.followDynamic(hostMid: 0);

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'error_following_uid');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });

    test('happy: followUp converts the following list via the account uid',
        () async {
      makeRepo(<String, String>{
        'GET /following/list/10086': fixture('ottohub/following_list'),
      });

      final result = await repo.followUp();

      expect(result, isA<Success<CoreFollowUpModel>>());
      final model = (result as Success<CoreFollowUpModel>).response;
      expect(model.upList, hasLength(2));
      expect(model.upList!.first.mid, 2001);
      expect(model.upList!.first.uname, '关注用户甲');
      expect(model.upList!.first.face, 'https://example.com/avatar1.jpg');
      expect(model.hasMore, isFalse);
      expect(fake.requestCount, 1);
    });

    test('edge: followUp rejects when no account provider is registered',
        () async {
      Get.reset(); // simulate not being logged in.
      makeRepo(<String, String>{});

      final result = await repo.followUp();

      expect(result, const Error('OttoHub: 用户未登录', code: 401));
      expect(fake.requestCount, 0);
    });

    test('happy: dynUpList converts the list and derives the next offset',
        () async {
      makeRepo(<String, String>{
        'GET /following/list/10086': fixture('ottohub/following_list'),
      });

      final result = await repo.dynUpList('0');

      expect(result, isA<Success<CoreFollowUpModel>>());
      final model = (result as Success<CoreFollowUpModel>).response;
      expect(model.upList, hasLength(2));
      expect(model.offset, '2');
      expect(fake.requestCount, 1);
    });

    test('happy: thumbDynamic toggles the like when the state differs', () async {
      makeRepo(<String, String>{
        'GET /video/42': fixture('ottohub/video_detail_minimal'),
        'POST /video/like/42': fixture('ottohub/like_toggle'),
      });

      final result = await repo.thumbDynamic(dynamicId: '42', up: 1);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 2);
    });

    test('edge: thumbDynamic skips the toggle when already liked', () async {
      makeRepo(<String, String>{
        'GET /video/42': fixture('ottohub/video_detail_liked'),
      });

      final result = await repo.thumbDynamic(dynamicId: '42', up: 1);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('error: thumbDynamic rejects a null dynamicId without HTTP', () async {
      makeRepo(const <String, String>{});

      final result = await repo.thumbDynamic(dynamicId: null, up: 1);

      expect(result, const Error('OttoHub: dynamicId is null'));
      expect(fake.requestCount, 0);
    });

    test('happy: dynamicDetail converts the blog detail into a core dynamic',
        () async {
      makeRepo(<String, String>{
        'GET /blog/get_blog_detail': fixture('ottohub/blog_detail'),
      });

      final result = await repo.dynamicDetail(id: '42');

      expect(result, isA<Success<CoreDynamicItemModel>>());
      final item = (result as Success<CoreDynamicItemModel>).response;
      expect(item.idStr, '42');
      expect(item.type, 'blog');
      expect(item.basic!.commentIdStr, '42');
      expect(item.modules!.moduleAuthor!.mid, 10086);
      expect(item.modules!.moduleAuthor!.name, '测试用户');
      expect(item.modules!.moduleAuthor!.pubTime, '2024-04-01T00:00:00Z');
      expect(item.modules!.moduleStat!.like!.count, 120);
      expect(item.modules!.moduleStat!.comment!.count, 5);
      expect(item.modules!.moduleDynamic!.desc!.text, '博客正文内容');
      expect(fake.requestCount, 1);
    });

    test('happy: articleInfo strips the cv prefix and converts stats',
        () async {
      makeRepo(<String, String>{
        'GET /blog/get_blog_detail': fixture('ottohub/blog_detail'),
      });

      final result = await repo.articleInfo(cvId: 'cv42');

      expect(result, isA<Success<CoreArticleInfoData>>());
      final article = (result as Success<CoreArticleInfoData>).response;
      expect(article.favorite, isTrue);
      expect(article.title, '博客标题');
      expect(article.stats!.favorite, 30);
      expect(article.stats!.like, 120);
      expect(article.stats!.reply, 5);
      expect(article.originImageUrls, <String>['https://example.com/t1.jpg']);
      expect(fake.requestCount, 1);
    });

    test('happy: opusDetail converts the blog detail into a core dynamic',
        () async {
      makeRepo(<String, String>{
        'GET /blog/get_blog_detail': fixture('ottohub/blog_detail_minimal'),
      });

      final result = await repo.opusDetail(opusId: '7');

      expect(result, isA<Success<CoreDynamicItemModel>>());
      final item = (result as Success<CoreDynamicItemModel>).response;
      expect(item.idStr, '7');
      expect(item.type, 'blog');
      // Minimal detail: no avatar/username — author fields fall back to null.
      expect(item.modules!.moduleAuthor!.name, isNull);
      expect(item.modules!.moduleDynamic!.desc!.text, '只有必填字段');
      expect(fake.requestCount, 1);
    });
  });
}
