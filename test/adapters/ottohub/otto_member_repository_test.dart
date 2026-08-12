import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/repository/otto_member_repository.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_opus/item.dart';
import 'package:skf/core/models/dynamics_types.dart'
    show CoreDynamicsDataModel;
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/member_types.dart'
    hide CoreDynamicsDataModel, CoreDynamicItemModel;
import 'package:skf/core/models/space_types.dart';
import 'package:skf/core/result/loading_state.dart';

import '../../helpers/fake_http_adapter.dart';
import '../../helpers/fixtures.dart';

void main() {
  late FakeHttpAdapter fake;
  late OttoMemberRepository repo;

  OttoMemberRepository makeRepo(Map<String, String> routes) {
    fake = FakeHttpAdapter(routes);
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost',
        // Permit 4xx/5xx so error paths are reachable in tests.
        validateStatus: (_) => true,
      ),
    )
      ..httpClientAdapter = fake;
    repo = OttoMemberRepository(OttohubClient(dio: dio));
    return repo;
  }

  group('OttoMemberRepository (implementation-level)', () {
    test('happy: spaceArchive converts user videos into CoreSpaceArchiveData',
        () async {
      makeRepo(<String, String>{
        'GET /video/user/7': fixture('ottohub/video_list'),
      });

      final result = await repo.spaceArchive(type: CoreContributeType.video, mid: 7);

      expect(result, isA<Success<CoreSpaceArchiveData>>());
      final data = (result as Success<CoreSpaceArchiveData>).response;
      expect(data.count, 2);
      expect(data.item, hasLength(2));
      final first = data.item!.first;
      expect(first.title, '推荐视频A');
      expect(first.cover, 'https://example.com/a.jpg');
      expect(first.duration, 300);
      expect(first.play, 4500);
      expect(first.uri, '101');
      expect(first.param, '101');
      expect(first.goto, 'av');
      expect(first.bvid, '101');
      expect(first.cid, 101);
      expect(fake.requestCount, 1);
    });

    test('edge: spaceArchive handles an empty video_list', () async {
      makeRepo(<String, String>{
        'GET /video/user/7': fixture('ottohub/video_list_empty'),
      });

      final result = await repo.spaceArchive(type: CoreContributeType.video, mid: 7);

      expect(result, isA<Success<CoreSpaceArchiveData>>());
      final data = (result as Success<CoreSpaceArchiveData>).response;
      expect(data.count, 0);
      expect(data.item, isEmpty);
      expect(fake.requestCount, 1);
    });

    test('happy: memberInfo converts UserDetail fields', () async {
      makeRepo(<String, String>{
        'GET /user/get_user_detail': fixture('ottohub/user_detail'),
      });

      final result = await repo.memberInfo(mid: 7);

      expect(result, isA<Success<CoreMemberInfoModel>>());
      final info = (result as Success<CoreMemberInfoModel>).response;
      expect(info.mid, 7);
      expect(info.name, '用户七');
      expect(info.sex, '男');
      expect(info.face, 'https://example.com/u7.jpg');
      expect(info.sign, '签名七');
      expect(fake.requestCount, 1);
    });

    test('error: memberInfo returns Error on status=error envelope', () async {
      makeRepo(<String, String>{
        'GET /user/get_user_detail': fixture('ottohub/error_block'),
      });

      final result = await repo.memberInfo(mid: 7);

      expect(result, isA<Error>());
      final err = result as Error;
      expect(err.errMsg, 'user_not_found');
      expect(err.code, 200);
      expect(fake.requestCount, 1);
    });

    test('happy: memberStat converts UserData into a raw stat map', () async {
      makeRepo(<String, String>{
        'GET /profile/user_data': fixture('ottohub/user_data'),
      });

      final result = await repo.memberStat(mid: 7);

      expect(result, isA<Success<Map>>());
      final data = (result as Success<Map>).response;
      expect(data['following'], 50);
      expect(data['follower'], 800);
      expect(data['video_num'], 12);
      expect(data['blog_num'], 3);
      expect(fake.requestCount, 1);
    });

    test('happy: memberCardInfo wraps the detail into a CoreCard', () async {
      makeRepo(<String, String>{
        'GET /user/get_user_detail': fixture('ottohub/user_detail'),
      });

      final result = await repo.memberCardInfo(mid: 7);

      expect(result, isA<Success<CoreMemberCardInfoData>>());
      final info = (result as Success<CoreMemberCardInfoData>).response;
      expect(info.coreCard?.mid, '7');
      expect(info.coreCard?.name, '用户七');
      expect(info.coreCard?.face, 'https://example.com/u7.jpg');
      expect(fake.requestCount, 1);
    });

    test('happy: searchArchive converts search results into vlist', () async {
      makeRepo(<String, String>{
        'GET /video/search': fixture('ottohub/video_list'),
      });

      final result = await repo.searchArchive(mid: 7, pn: 1);

      expect(result, isA<Success<CoreSearchArchiveData>>());
      final data = (result as Success<CoreSearchArchiveData>).response;
      expect(data.corePage?.count, 2);
      expect(data.list?.vlist, hasLength(2));
      final first = data.list!.vlist!.first;
      expect(first.title, '推荐视频A');
      expect(first.author, 'UP主A');
      expect(first.corePic, 'https://example.com/a.jpg');
      expect(first.bvid, '101');
      expect(first.play, 4500);
      expect(first.videoReview, 120);
      expect(fake.requestCount, 1);
    });

    test('happy: memberDynamic converts timeline items into core dynamics',
        () async {
      makeRepo(<String, String>{
        'GET /following/timeline/7': fixture('ottohub/timeline'),
      });

      final result = await repo.memberDynamic(mid: 7);

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
      expect(first.modules!.moduleDynamic!.desc!.text, '发布了一个新视频');
      expect(data.hasMore, isFalse);
      expect(fake.requestCount, 1);
    });

    test('happy: followUpGroup resolves uid from profile when mid is null',
        () async {
      makeRepo(<String, String>{
        'GET /profile/user_profile': fixture('ottohub/user_profile'),
        'GET /following/list/10086': fixture('ottohub/following_list'),
      });

      final result = await repo.followUpGroup(mid: null, tagid: null, pn: 1);

      expect(result, isA<Success<CoreFollowData>>());
      expect((result as Success<CoreFollowData>).response.list, hasLength(2));
      expect(fake.requestCount, 2);
    });

    test('happy: followUpGroup uses the given mid directly', () async {
      makeRepo(<String, String>{
        'GET /following/list/7': fixture('ottohub/following_list'),
      });

      final result = await repo.followUpGroup(mid: 7, tagid: null, pn: 1);

      expect(result, isA<Success<CoreFollowData>>());
      expect(
        (result as Success<CoreFollowData>).response.list!.first.uname,
        '关注用户甲',
      );
      expect(fake.requestCount, 1);
    });

    test('happy: getfollowSearch converts searched users into CoreFollowData',
        () async {
      makeRepo(<String, String>{
        'GET /user/select_user_list': fixture('ottohub/user_summaries'),
      });

      final result = await repo.getfollowSearch(mid: 7, ps: 20, pn: 1, name: '甲');

      expect(result, isA<Success<CoreFollowData>>());
      final data = (result as Success<CoreFollowData>).response;
      expect(data.total, 2);
      expect(data.list!.first.mid, 1001);
      expect(data.list!.first.uname, '搜索结果甲');
      expect(data.list!.first.sign, '简介甲');
      expect(data.list![1].sign, isNull);
      expect(fake.requestCount, 1);
    });

    test('happy: space builds CoreSpaceData with the CoreCard', () async {
      makeRepo(<String, String>{
        'GET /user/get_user_detail': fixture('ottohub/user_detail'),
      });

      final result = await repo.space(mid: 7);

      expect(result, isA<Success<CoreSpaceData>>());
      final space = (result as Success<CoreSpaceData>).response;
      expect(space.coreCard, isNotNull);
      expect(space.coreCard!.mid, 7);
      expect(space.coreCard!.name, '用户七');
      expect(space.coreCard!.face, 'https://example.com/u7.jpg');
      expect(fake.requestCount, 1);
    });

    test('happy: memberView returns the raw detail map', () async {
      makeRepo(<String, String>{
        'GET /user/get_user_detail': fixture('ottohub/user_detail'),
      });

      final result = await repo.memberView(mid: 7);

      expect(result, isA<Success<Map>>());
      final map = (result as Success<Map>).response;
      expect(map['mid'], 7);
      expect(map['name'], '用户七');
      expect(map['face'], 'https://example.com/u7.jpg');
      expect(map['top_photo'], 'https://example.com/u7cover.jpg');
      expect(fake.requestCount, 1);
    });

    test('happy: spaceOpus converts blog list into opus flow items', () async {
      makeRepo(<String, String>{
        'GET /blog/user_blog_list': fixture('ottohub/blog_list'),
      });

      final result = await repo.spaceOpus(hostMid: 7, page: 1);

      expect(result, isA<Success<CoreOpusSpaceFlowResp>>());
      final resp = (result as Success<CoreOpusSpaceFlowResp>).response;
      expect(resp.itemList, hasLength(2));
      final first = resp.itemList!.first as SpaceOpusItemModel;
      expect(first.content, '作品一内容');
      expect(first.opusId, '301');
      expect(first.stat?.like, '15');
      expect(first.cover?.url, 'https://example.com/b1.jpg');
      // Second item has null thumbnails → cover null, content falls back to title.
      expect((resp.itemList![1] as SpaceOpusItemModel).content, '作品二');
      expect((resp.itemList![1] as SpaceOpusItemModel).cover, isNull);
      expect(resp.nextPage, isNull);
      expect(fake.requestCount, 1);
    });

    test('happy: specialAction skips the toggle when state already matches',
        () async {
      makeRepo(<String, String>{
        'GET /following/status/7': fixture('ottohub/follow_status'),
      });

      final result = await repo.specialAction(fid: 7, isAdd: true);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 1);
    });

    test('happy: specialAction toggles when the state differs', () async {
      makeRepo(<String, String>{
        'GET /following/status/7': fixture('ottohub/follow_status_mutual'),
        'POST /following/follow/7': fixture('ottohub/follow_toggle'),
      });

      final result = await repo.specialAction(fid: 7, isAdd: false);

      expect(result, const Success<void>(null));
      expect(fake.requestCount, 2);
    });
  });
}
