import 'package:flutter/foundation.dart' show debugPrint;
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
import 'package:skf/adapters/ottohub/models/space_opus/cover.dart';
import 'package:skf/adapters/ottohub/models/space_opus/item.dart';
import 'package:skf/adapters/ottohub/models/space_opus/stat.dart';
import 'package:skf/core/models/dynamics_types.dart' show CoreDynamicsDataModel, CoreDynamicItemModel, CoreBasic, CoreItemModulesModel, CoreModuleAuthorModel, CoreModuleDynamicModel, CoreDynamicDescModel;
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/follow_item.dart';
import 'package:skf/core/models/member_types.dart' hide CoreDynamicsDataModel, CoreDynamicItemModel, CoreBasic, CoreItemModulesModel, CoreModuleAuthorModel, CoreModuleDynamicModel, CoreDynamicDescModel;
import 'package:skf/core/models/space_types.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [MemberRepository] that delegates to OttoHub SDK APIs.
///
/// Uses [IChannelApi] for channel/member data and [IOldProfileApi] for
/// profile-related operations.
class OttoMemberRepository implements MemberRepository {
  final OttohubClient _client;

  OttoMemberRepository(this._client);

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  @override
  Future<void> reportMember(
    int mid, {
    String? reason,
    int? reasonV2,
  }) async {
    // no SDK API — SDK 缺 member report 或等效端点
  }

  @override
  Future<LoadingState<CoreSpaceArticleData>> spaceArticle({
    required int mid,
    required int page,
  }) async {
    // no SDK API — SDK 缺 space article list 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreSpaceSsData>> seasonSeriesList({
    required int? mid,
    required int pn,
  }) async {
    // no SDK API — SDK 缺 season/series list 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreSpaceArchiveData>> spaceArchive({
    required CoreContributeType type,
    required int? mid,
    String? aid,
    CoreArchiveOrderTypeApp? order,
    CoreArchiveSortTypeApp? sort,
    int? pn,
    int? next,
    int? seasonId,
    String? seriesId,
    bool? includeCursor,
  }) async {
    try {
      final videos = await _client.video.getUserVideos(mid ?? 0,
          offset: pn != null ? (pn - 1) * 30 : null);
      return Success(CoreSpaceArchiveData(
        item: videos.videoList
            .map((v) => CoreSpaceArchiveItem(
                  title: v.title,
                  cover: v.coverUrl,
                  duration: v.duration,
                  play: v.viewCount,
                  uri: v.vid.toString(),
                  param: v.vid.toString(),
                  goto: 'av',
                  bvid: v.vid.toString(),
                  cid: v.vid,
                ))
            .toList(),
        count: videos.videoList.length,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoMemberRepository.spaceArchive ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreSpaceAudioData>> spaceAudio({
    required int page,
    required mid,
  }) async {
    // no SDK API — SDK 缺 space audio list 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreSpaceCheeseData>> spaceCheese({
    required int page,
    required mid,
  }) async {
    // no SDK API — SDK 缺 space cheese list 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreSpaceData>> space({
    int? mid,
    int? fromViewAid,
  }) async {
    try {
      final detail = await _client.oldUser.getUserDetail(mid ?? 0);
      return Success(CoreSpaceData.fromJson(<String, dynamic>{
        'CoreCard': <String, dynamic>{
          'mid': detail.uid,
          'name': detail.username,
          'face': detail.avatarUrl,
          'sign': detail.intro,
          'top_photo': detail.coverUrl,
        },
        'coreArchive': <String, dynamic>{
          'count': detail.videoNum,
        },
      }));
    } on ApiException catch (e) {
      debugPrint('OttoMemberRepository.space ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreMemberInfoModel>> memberInfo({
    required int mid,
    String token = '',
  }) async {
    try {
      final detail = await _client.oldUser.getUserDetail(mid);
      return Success(CoreMemberInfoModel(
        mid: detail.uid,
        name: detail.username,
        sex: detail.sex,
        face: detail.avatarUrl,
        sign: detail.intro,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoMemberRepository.memberInfo ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<Map>> memberStat({int? mid}) async {
    try {
      final data = await _client.oldProfile.getUserData();
      return Success(<String, dynamic>{
        'following': data.followingsCount,
        'follower': data.fansCount,
        'video_num': data.videoNum,
        'blog_num': data.blogNum,
      });
    } on ApiException catch (e) {
      debugPrint('OttoMemberRepository.memberStat ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreMemberCardInfoData>> memberCardInfo({int? mid}) async {
    try {
      final detail = await _client.oldUser.getUserDetail(mid ?? 0);
      return Success(CoreMemberCardInfoData(
        coreCard: CoreCard(
          mid: detail.uid.toString(),
          name: detail.username,
          face: detail.avatarUrl,
        ),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoMemberRepository.memberCardInfo ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreSearchArchiveData>> searchArchive({
    required int mid,
    int tid = 0,
    int ps = 30,
    required int pn,
    String? keyword,
    String? specialType,
    CoreArchiveOrderTypeWeb order = CoreArchiveOrderTypeWeb.pubdate,
  }) async {
    try {
      final result = await _client.video.search(
        searchTerm: keyword,
        offset: (pn - 1) * ps,
        num: ps,
        uid: mid,
      );
      return Success(CoreSearchArchiveData.fromJson(<String, dynamic>{
        'list': <String, dynamic>{
          'vlist': result.videoList.map((v) => <String, dynamic>{
            'title': v.title,
            'author': v.username,
            'CorePic': v.coverUrl,
            'bvid': v.vid.toString(),
            'play': v.viewCount,
            'video_review': v.likeCount,
          }).toList(),
        },
        'CorePage': <String, dynamic>{
          'count': result.totalCount,
        },
      }));
    } on ApiException catch (e) {
      debugPrint('OttoMemberRepository.searchArchive ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreSeasonWebData>> seasonSeriesWeb({
    required CoreWebSsType type,
    required int mid,
    required String id,
    int ps = 30,
    required int pn,
    CoreArchiveSortTypeApp sort = CoreArchiveSortTypeApp.desc,
  }) async {
    // no SDK API — SDK 缺 season/series web 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreDynamicsDataModel>> memberDynamic({
    String? offset,
    required int mid,
  }) async {
    try {
      final timeline = await _client.following.getUserTimeline(mid,
          offset: offset != null ? int.tryParse(offset) : null);
      return Success(CoreDynamicsDataModel(
        items: timeline.timelineList
            .map((t) => CoreDynamicItemModel(
                  idStr: t.vid?.toString() ?? t.bid?.toString(),
                  type: t.contentType,
                  basic: CoreBasic(commentIdStr: t.vid?.toString()),
                  modules: CoreItemModulesModel(
                    moduleAuthor: CoreModuleAuthorModel(
                      mid: t.uid,
                      name: t.username,
                      face: t.avatarUrl,
                      pubTime: t.time,
                    ),
                    moduleDynamic: CoreModuleDynamicModel(
                      desc: CoreDynamicDescModel(text: t.content),
                    ),
                  ),
                ))
            .toList(),
        hasMore: timeline.timelineList.length >= 20,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoMemberRepository.memberDynamic ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreDynamicsDataModel>> dynSearch({
    required int pn,
    required int mid,
    required String? offset,
    required String keyword,
  }) async {
    // no SDK API — SDK 缺 dynamic search 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CoreMemberTagItemModel>>> followUpTags() async {
    // no SDK API — SDK 缺 follow tag list 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> specialAction({
    int? fid,
    bool isAdd = true,
  }) async {
    try {
      // The SDK only exposes a toggle, so read the follow state first and
      // only toggle when it differs from the requested direction.
      // followStatus: 0=unfollowed, 1=following, 2=mutual - any non-zero
      // counts as following (avoids unfollowing a mutual follow when isAdd).
      final status = await _client.following.getStatus(fid!);
      if ((status.followStatus != 0) != isAdd) {
        await _client.following.toggleFollow(fid);
      }
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoMemberRepository.specialAction ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<void>> addUsers(String fids, String tagids) async {
    // no SDK API — SDK 缺 follow tag add-users 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreFollowData>> followUpGroup({
    int? mid,
    int? tagid,
    int? pn,
    int ps = 20,
  }) async {
    // SDK getFollowingList cannot filter by follow tag — tagid is ignored;
    // a null mid resolves to the caller's own uid via the profile.
    try {
      final uid = mid ?? (await _client.oldProfile.getUserProfile()).uid;
      final list = await _client.following.getFollowingList(
        uid,
        offset: pn != null ? (pn - 1) * ps : null,
        num: ps,
      );
      return Success(CoreFollowData(
        list: list.userList
            .map((u) => CoreFollowItemModel(
                  mid: u.uid,
                  uname: u.username,
                  face: u.avatarUrl,
                  sign: u.intro,
                ))
            .toList(),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoMemberRepository.followUpGroup ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<int>> createFollowTag(String tagName) async {
    // no SDK API — SDK 缺 follow tag create 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> updateFollowTag(
    Object tagid,
    Object name,
  ) async {
    // no SDK API — SDK 缺 follow tag update 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> delFollowTag(Object tagid) async {
    // no SDK API — SDK 缺 follow tag delete 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CoreMemberTagItemModel>?>> getTopVideo() async {
    // no SDK API — SDK 缺 pinned video 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<Map>> memberView({required int mid}) async {
    try {
      final detail = await _client.oldUser.getUserDetail(mid);
      return Success(<String, dynamic>{
        'mid': detail.uid,
        'name': detail.username,
        'face': detail.avatarUrl,
        'top_photo': detail.coverUrl,
      });
    } on ApiException catch (e) {
      debugPrint('OttoMemberRepository.memberView ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreFollowData>> getfollowSearch({
    required int mid,
    required int ps,
    required int pn,
    required String name,
  }) async {
    try {
      final result = await _client.oldUser.searchUsers(
        searchTerm: name,
        num: ps,
      );
      return Success(CoreFollowData(
        list: result.map((u) => CoreFollowItemModel(
          mid: u.uid,
          uname: u.username,
          face: u.avatarUrl,
          sign: u.intro,
        )).toList(),
        total: result.length,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoMemberRepository.getfollowSearch ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreOpusSpaceFlowResp>> spaceOpus({
    required int hostMid,
    required int page,
    String offset = '',
    String type = 'all',
  }) async {
    try {
      final blogs = await _client.oldBlog.getUserBlogList(
        uid: hostMid,
        offset: (page - 1) * 30,
        num: 30,
      );
      return Success(CoreOpusSpaceFlowResp(
        itemList: blogs.map((b) => SpaceOpusItemModel(
          content: b.content ?? b.title,
          opusId: b.bid.toString(),
          stat: Stat(like: b.likeCount.toString()),
          cover: b.thumbnails?.isNotEmpty == true
              ? Cover.fromJson(<String, dynamic>{'url': b.thumbnails!.first})
              : null,
        )).toList(),
        nextPage: blogs.length >= 30 ? page * 30 : null,
        hostUpOpusCollection: null,
        hostUpNoteNavBar: null,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoMemberRepository.spaceOpus ApiException: ${e.errorCode}');
      return Error(e.errorCode, code: e.httpStatus);
    }
  }

  @override
  Future<LoadingState<CoreUpowerRankData>> upowerRank({
    required int upMid,
    required int page,
    int? privilegeType,
  }) async {
    // no SDK API — SDK 缺 upower rank 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreCoinLikeArcData>> coinArc({
    required int mid,
    required int page,
  }) async {
    // no SDK API — SDK 缺 coin archive list 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreCoinLikeArcData>> likeArc({
    required int mid,
    required int page,
  }) async {
    // no SDK API — SDK 缺 liked archive list 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreSpaceShopData>> spaceShop({
    required int mid,
  }) async {
    // no SDK API — SDK 缺 space shop 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreMemberGuardData>> memberGuard({
    required int ruid,
    required int page,
  }) async {
    // no SDK API — SDK 缺 member guard 或等效端点
    return _err(const ApiException('not_implemented'));
  }
}
