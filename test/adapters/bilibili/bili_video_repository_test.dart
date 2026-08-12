import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:skf/adapters/bilibili/repository/bili_video_repository.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/bili_bootstrap.dart';
import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late Directory tempDir;
  final repo = BiliVideoRepository();

  setUpAll(() async {
    fake = FakeHttpAdapter(const {});
    tempDir = await bootstrapBiliRequest(fake);
  });

  tearDownAll(() async {
    await teardownBiliRequest(tempDir);
  });

  FakeHttpAdapter swap(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    installBiliFakeHttpAdapter(fake);
    return fake;
  }

  group('BiliVideoRepository (implementation-level)', () {
    test('happy: videoIntro converts the /x/web-interface/view fixture', () async {
      swap(<String, String>{
        'GET /x/web-interface/view': fixture('bilibili/view'),
      });

      final result = await repo.videoIntro(bvid: 'BV1xx411c7mD');

      expect(result, isA<Success<CoreVideoDetailData>>());
      final detail = (result as Success<CoreVideoDetailData>).response;
      expect(detail.bvid, 'BV1xx411c7mD');
      expect(detail.aid, 170001);
      expect(detail.videos, 2);
      expect(detail.copyright, 1);
      expect(detail.pic, 'https://i0.hdslb.com/bfs/archive/cover.jpg');
      expect(detail.title, '测试视频标题');
      expect(detail.pubdate, 1700000000);
      expect(detail.ctime, 1699999000);
      expect(detail.desc, '这是视频简介');
      expect(detail.duration, 3661);
      expect(detail.cid, 170002);
      expect(detail.rights, <String, dynamic>{'is_stein_gate': 0});
      expect(detail.owner, <String, dynamic>{
        'mid': 10086,
        'name': '测试UP主',
        'face': 'https://i0.hdslb.com/bfs/face/up.jpg',
      });
      expect(detail.stat, <String, dynamic>{
        'view': 89012,
        'like': 1234,
        'coin': 56,
        'favorite': 567,
        'share': 89,
        'danmaku': 321,
        'reply': 45,
      });
      expect(detail.dimension, <String, dynamic>{
        'width': 1920,
        'height': 1080,
      });
      expect(detail.seasonId, 0);
      expect(detail.isUpowerExclusive, false);
      expect(
        detail.redirectUrl,
        'https://www.bilibili.com/video/BV1xx411c7mD',
      );
      expect(fake.requestCount, 1);
    });

    test('error: videoIntro returns Error on a non-zero code envelope',
        () async {
      swap(<String, String>{
        'GET /x/web-interface/view': fixture('bilibili/view_error'),
      });

      final result = await repo.videoIntro(bvid: 'BV1deleted');

      expect(result, isA<Error>());
      expect((result as Error).errMsg, '视频不存在或已被删除');
      expect(fake.requestCount, 1);
    });

    test('edge: videoIntro tolerates missing optional fields', () async {
      swap(<String, String>{
        'GET /x/web-interface/view': fixture('bilibili/view_minimal'),
      });

      final result = await repo.videoIntro(bvid: 'BV1min');

      expect(result, isA<Success<CoreVideoDetailData>>());
      final detail = (result as Success<CoreVideoDetailData>).response;
      expect(detail.bvid, 'BV1min');
      expect(detail.aid, 1);
      expect(detail.title, '最小字段视频');
      expect(detail.pic, isNull);
      expect(detail.desc, isNull);
      expect(detail.duration, isNull);
      expect(detail.owner, isNull);
      expect(detail.stat, isNull);
      expect(detail.dimension, isNull);
      expect(fake.requestCount, 1);
    });

    test(
        'happy: videoUrl fetches wbi nav keys then converts /x/player/wbi/playurl',
        () async {
      // This is the FIRST wbi-signed request in this isolate: WbiSign finds no
      // cached mixin key in the fresh Hive localCache box and fetches the nav
      // endpoint first — so both routes must be registered.
      swap(<String, String>{
        'GET /x/web-interface/nav': fixture('bilibili/nav'),
        'GET /x/player/wbi/playurl': fixture('bilibili/playurl'),
      });

      final result = await repo.videoUrl(
        avid: 170001,
        cid: 170002,
        tryLook: false,
        videoType: CoreVideoType.ugc,
      );

      expect(result, isA<Success<CorePlayUrlModel>>());
      final play = (result as Success<CorePlayUrlModel>).response;
      expect(play.from, 'local');
      expect(play.result, 'suee');
      expect(play.message, '');
      expect(play.quality, 80);
      expect(play.format, 'mp4');
      expect(play.timeLength, 3661000);
      expect(play.acceptFormat, '16,32,80');
      expect(play.acceptQuality, <int>[80, 32, 16]);
      expect(play.videoCodecid, 7);
      expect(play.durl, <Map<String, dynamic>>[
        <String, dynamic>{
          'order': 1,
          'length': 3661000,
          'size': 12345678,
          'ahead': null,
          'vhead': null,
          'url': 'https://example.com/video.mp4',
          'backup_url': <String>['https://backup.example.com/video.mp4'],
        },
      ]);
      expect(play.supportFormats, <Map<String, dynamic>>[
        <String, dynamic>{
          'quality': 80,
          'format': 'mp4',
          'new_description': '高清 1080P',
          'display_desc': '1080P',
          'codecs': null,
        },
      ]);
      // nav (wbi keys) + playurl.
      expect(fake.requestCount, 2);
    });

    test('error: videoUrl maps a -404 envelope and reuses cached wbi keys',
        () async {
      // WbiSign cached the mixin key in Hive localCache during the previous
      // test — the nav endpoint is deliberately NOT routed here, and the
      // single request proves no second nav fetch happened.
      swap(<String, String>{
        'GET /x/player/wbi/playurl': fixture('bilibili/playurl_error'),
      });

      final result = await repo.videoUrl(
        avid: 170003,
        cid: 170004,
        tryLook: false,
        videoType: CoreVideoType.ugc,
      );

      expect(result, isA<Error>());
      expect((result as Error).errMsg, '视频不存在或已被删除');
      expect(fake.requestCount, 1);
    });
  });
}
