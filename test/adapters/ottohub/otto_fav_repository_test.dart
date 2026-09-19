import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_fav_repository.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

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

  group('OttoFavRepository (implementation-level)', () {
    test('happy: favFavFolder skips the toggle when already favorited',
        () async {
      makeRepo(<String, String>{
        'GET /video/42': fixture('ottohub/video_detail'),
      });

      final result = await repo.favFavFolder(42);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('happy: favFavFolder toggles the favorite when not yet favorited',
        () async {
      makeRepo(<String, String>{
        'GET /video/7': fixture('ottohub/video_detail_minimal'),
        'POST /video/favorite/7': fixture('ottohub/favorite_toggle'),
      });

      final result = await repo.favFavFolder(7);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 2);
    });

    test('error: favFavFolder rejects an invalid media id without HTTP',
        () async {
      makeRepo(const <String, String>{});

      final result = await repo.favFavFolder('abc');

      expect(result, const Error('invalid_media_id'));
      expect(fake.requestCount, 0);
    });

    test('happy: favVideo toggles each resource vid', () async {
      makeRepo(<String, String>{
        'POST /video/favorite/42': fixture('ottohub/favorite_toggle'),
        'POST /video/favorite/43': fixture('ottohub/favorite_toggle'),
      });

      final result = await repo.favVideo(resources: '42, 43');

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 2);
    });

    test('happy: userfavFolder paginates collection names into folders',
        () async {
      makeRepo(<String, String>{
        'GET /collection/get_user_video_collection':
            fixture('ottohub/collection_list'),
      });

      final result = await repo.userfavFolder(pn: 1, ps: 2, mid: 7);

      expect(result, isA<Success<CoreFavFolderData>>());
      final data = (result as Success<CoreFavFolderData>).response;
      expect(data.count, 3);
      expect(data.list, hasLength(2));
      expect(data.list![0].id, 0);
      expect(data.list![0].title, '合集A');
      expect(data.list![0].mid, 7);
      expect(data.list![1].title, '合集B');
      expect(data.hasMore, isTrue);
      expect(fake.requestCount, 1);
    });

    test('happy: allFavFolders returns every name with index-based ids',
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
      expect(data.hasMore, isFalse);
      expect(fake.requestCount, 1);
    });

    test('error: userfavFolder returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /collection/get_user_video_collection': fixture('ottohub/error_block'),
      });

      final result = await repo.userfavFolder(pn: 1, ps: 20, mid: 7);

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'user_not_found');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });

    test('happy: userFavFolderDetail converts the favorite video list', () async {
      makeRepo(<String, String>{
        'GET /video/favorite-list': fixture('ottohub/favorite_list'),
      });

      final result = await repo.userFavFolderDetail(mediaId: 42, pn: 1, ps: 20);

      expect(result, isA<Success<CoreFavDetailData>>());
      final data = (result as Success<CoreFavDetailData>).response;
      expect(data.info!.id, 42);
      expect(data.info!.mediaCount, 2);
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
      expect(data.hasMore, isFalse);
      expect(fake.requestCount, 1);
    });

    test('happy: addOrEditFolder assigns the video to the named collection',
        () async {
      makeRepo(<String, String>{
        'POST /collection/set_video_collection': fixture('ottohub/ok'),
      });

      final result = await repo.addOrEditFolder(
        isAdd: true,
        mediaId: '42',
        title: '新合集',
        privacy: 0,
        cover: '',
        intro: '',
      );

      expect(result, isA<Success<CoreFavFolderInfo>>());
      final folder = (result as Success<CoreFavFolderInfo>).response;
      expect(folder.id, 42);
      expect(folder.title, '新合集');
      expect(folder.mid, 0);
      expect(fake.requestCount, 1);
    });

    test('happy: favFolderInfo converts the collection detail', () async {
      makeRepo(<String, String>{
        'GET /collection/get_video_collection': fixture('ottohub/collection_detail'),
      });

      final result = await repo.favFolderInfo(mediaId: '501');

      expect(result, isA<Success<CoreFavFolderInfo>>());
      final folder = (result as Success<CoreFavFolderInfo>).response;
      expect(folder.id, 501);
      expect(folder.title, '合集A');
      expect(folder.cover, 'https://example.com/c1.jpg');
      expect(folder.mediaCount, 2);
      expect(fake.requestCount, 1);
    });

    test('edge: favFolderInfo handles an empty video_list', () async {
      makeRepo(<String, String>{
        'GET /collection/get_video_collection':
            fixture('ottohub/collection_detail_empty'),
      });

      final result = await repo.favFolderInfo(mediaId: '501');

      expect(result, isA<Success<CoreFavFolderInfo>>());
      final folder = (result as Success<CoreFavFolderInfo>).response;
      expect(folder.title, '空合集');
      expect(folder.cover, '');
      expect(folder.mediaCount, 0);
      expect(fake.requestCount, 1);
    });

    test('happy: sortFav posts the collection sort order', () async {
      makeRepo(<String, String>{
        'POST /collection/set_video_collection_sort_order': fixture('ottohub/ok'),
      });

      final result = await repo.sortFav(mediaId: '501', sort: '1');

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('happy: noteList converts favorite blog items into notes', () async {
      makeRepo(<String, String>{
        'GET /blog/favorite-list': fixture('ottohub/favorite_blog_list'),
      });

      final result = await repo.noteList(page: 1);

      expect(result, isA<Success<List<CoreFavNoteItemModel>?>>());
      final list = (result as Success<List<CoreFavNoteItemModel>?>).response;
      expect(list, hasLength(2));
      expect(list![0].title, '收藏笔记一');
      expect(list[0].summary, '笔记内容一');
      expect(list[0].pic, 'https://example.com/n1.jpg');
      expect(list[0].cvid, 1001);
      expect(list[0].noteId, 1001);
      // Second item: null content/thumbnails → null summary/pic.
      expect(list[1].summary, isNull);
      expect(list[1].pic, isNull);
      expect(fake.requestCount, 1);
    });

    test('happy: delNote deletes each published blog via the manage API',
        () async {
      makeRepo(<String, String>{
        'POST /manage/delete_blog': fixture('ottohub/ok'),
      });

      final result = await repo.delNote(isPublish: true, noteIds: '301,302');

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 2);
    });
  });
}
