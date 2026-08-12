import 'package:flutter/foundation.dart' show debugPrint;
import 'package:get/get.dart';
import 'package:skf/common/widgets/pair.dart';
import 'package:skf/core/account/account_provider.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';

/// Implementation of [DynamicsRepository] that delegates to OttoHub SDK APIs.
///
/// Uses [IFollowingApi] for timeline/feed functionality, [IOldBlogApi] for
/// blog detail, [IOldEngagementApi] / [IVideoApi] for like interactions.
class OttoDynamicsRepository implements DynamicsRepository {
  final OttohubClient _client;

  OttoDynamicsRepository(this._client);

  // ---------------------------------------------------------------------------
  // Convenience helpers
  // ---------------------------------------------------------------------------

  LoadingState<T> _ok<T>(T value) => Success(value);

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  CoreUpItem _toCoreUpItem(FollowingUser u) => CoreUpItem(
        mid: u.uid,
        uname: u.username,
        face: u.avatarUrl,
      );

  /// Extract a numeric ID from a dynamic idStr (which could be a `vid` or `bid`).
  int? _parseId(dynamic id) {
    if (id == null) return null;
    if (id is int) return id;
    final s = id.toString();
    return int.tryParse(s);
  }

  // ---------------------------------------------------------------------------
  // Dynamic feed timeline
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreDynamicsDataModel>> followDynamic({
    int? hostMid,
    String? offset,
    Set<int>? tempBannedList,
    CoreDynamicsTabType type = .all,
  }) async {
    try {
      final timeline = await _client.following.getTimeline(
        offset: offset != null ? int.tryParse(offset) : null,
      );
      final items = timeline.timelineList.map((t) {
        final idStr = t.vid?.toString() ?? t.bid?.toString();
        return CoreDynamicItemModel(
          idStr: idStr,
          type: t.contentType,
          basic: CoreBasic(commentIdStr: idStr),
          modules: CoreItemModulesModel(
            moduleAuthor: CoreModuleAuthorModel(
              mid: t.uid,
              name: t.username,
              face: t.avatarUrl,
              pubTime: t.time,
            ),
            moduleStat: CoreModuleStatModel(
              like: CoreDynamicStat(count: t.likeCount),
              favorite: CoreDynamicStat(count: t.favoriteCount),
            ),
            moduleDynamic: CoreModuleDynamicModel(
              desc: CoreDynamicDescModel(text: t.content),
              major: CoreDynamicMajorModel(
                type: 'archive',
                archive: CoreDynamicArchiveModel(
                  aid: t.vid,
                  cover: t.coverUrl,
                  title: t.title,
                ),
              ),
            ),
          ),
        );
      }).toList();
      // Compute next offset from current count so the caller can paginate.
      final nextOffset = items.isNotEmpty ? items.length.toString() : null;
      return Success(CoreDynamicsDataModel(
        items: items,
        offset: nextOffset,
        hasMore: timeline.timelineList.length >= 20,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoDynamicsRepository.followDynamic ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Followed UP list
  // ---------------------------------------------------------------------------

  /// Get the current user's UID from [OttoAccountProvider].
  ///
  /// Falls back to `0` if the user is not logged in. A UID of `0` will
  /// result in a 404 error from the server (no user with ID 0 exists).
  int get _currentUid {
    try {
      final uid = Get.find<AccountProvider>().userId;
      if (uid != null) return int.tryParse(uid) ?? 0;
    } catch (e) {
      debugPrint('OttoDynamicsRepository._currentUid error: $e');
    }
    return 0;
  }

  @override
  Future<LoadingState<CoreFollowUpModel>> followUp() async {
    try {
      final uid = _currentUid;
      if (uid <= 0) {
        return const Error('OttoHub: 用户未登录', code: 401);
      }
      final list = await _client.following.getFollowingList(
        uid,
        num: 50,
      );
      return _ok(CoreFollowUpModel(
        upList: list.userList.map(_toCoreUpItem).toList(),
        hasMore: list.userList.length >= 50,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoDynamicsRepository.followUp ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreFollowUpModel>> dynUpList(String? offset) async {
    try {
      final uid = _currentUid;
      if (uid <= 0) {
        return const Error('OttoHub: 用户未登录', code: 401);
      }
      final list = await _client.following.getFollowingList(
        uid,
        offset: offset != null ? int.tryParse(offset) : null,
        num: 50,
      );
      final items = list.userList.map(_toCoreUpItem).toList();
      final nextOffset =
          items.isNotEmpty ? items.length.toString() : null;
      return _ok(CoreFollowUpModel(
        upList: items,
        offset: nextOffset,
        hasMore: list.userList.length >= 50,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoDynamicsRepository.dynUpList ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreFollowUpModel>> followings({
    int? vmid,
    int? pn,
    int ps = 20,
    String orderType = '',
  }) async {
    try {
      final uid = vmid ?? _currentUid;
      if (uid <= 0) {
        return const Error('OttoHub: 用户未登录或 vmid 无效', code: 401);
      }
      final list = await _client.following.getFollowingList(
        uid,
        offset: pn != null ? (pn - 1) * ps : null,
        num: ps,
      );
      return Success(CoreFollowUpModel(
        upList: list.userList.map(_toCoreUpItem).toList(),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoDynamicsRepository.followings ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Like / thumb
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<void>> thumbDynamic({
    required String? dynamicId,
    required int? up,
  }) async {
    if (dynamicId == null) {
      return const Error('OttoHub: dynamicId is null');
    }
    final id = int.tryParse(dynamicId);
    if (id == null) {
      return const Error('OttoHub: 无法解析动态ID');
    }
    try {
      // Read the current like state first — the SDK only exposes a toggle,
      // so the direction must be derived from the current state vs desired.
      final desired = (up == 1) ? 1 : 0;
      final detail = await _client.video.getDetail(id);
      if (detail.ifLike == desired) {
        return const Success(null);
      }
      try {
        await _client.video.toggleLike(id);
        return const Success(null);
      } on ApiException catch (e) {
        debugPrint('OttoDynamicsRepository.thumbDynamic ApiException: ${e.errorCode}');
        // Fallback: try blog like if video like failed
        try {
          await _client.oldEngagement.likeBlog(id);
          return const Success(null);
        } on ApiException catch (inner) {
          debugPrint('OttoDynamicsRepository.thumbDynamic inner ApiException: ${inner.errorCode}');
          return _err(e);
        }
      }
    } on ApiException catch (e) {
      debugPrint('OttoDynamicsRepository.thumbDynamic getDetail ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Create / Edit
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<Map?>> createDynamic({
    int? mid,
    String dynIdStr = '',
    Object? rid,
    Object? dynType,
    String? rawText,
    List? pics,
    int? publishTime,
    CoreReplyOptionType? replyOption,
    int? privatePub,
    List<Map<String, dynamic>>? extraContent,
    Pair<int, String>? topic,
    String? title,
    Map? attachCard,
  }) async {
    // no SDK API — 缺失 SDK 方法: createDynamic
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Detail
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreDynamicItemModel>> dynamicDetail({
    String? id,
    dynamic rid,
    Object? type,
    bool clearCookie = false,
  }) async {
    final numericId = _parseId(id);
    if (numericId == null) {
      return const Error('OttoHub: 无法解析动态ID');
    }
    try {
      // In OttoHub, "dynamics" are primarily blogs; try blog detail first.
      final detail = await _client.oldBlog.getBlogDetail(numericId);
      return _ok(CoreDynamicItemModel(
        idStr: detail.bid.toString(),
        type: 'blog',
        basic: CoreBasic(commentIdStr: detail.bid.toString()),
        modules: CoreItemModulesModel(
          moduleAuthor: CoreModuleAuthorModel(
            mid: detail.uid,
            name: detail.username,
            face: detail.avatarUrl,
            pubTime: detail.time,
          ),
          moduleStat: CoreModuleStatModel(
            like: CoreDynamicStat(count: detail.likeCount),
            comment: CoreDynamicStat(count: detail.commentCount),
          ),
          moduleDynamic: CoreModuleDynamicModel(
            desc: CoreDynamicDescModel(text: detail.content),
          ),
        ),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoDynamicsRepository.dynamicDetail ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Pin / unpin (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<void>> setTop({
    required String dynamicId,
  }) async {
    // no SDK API — 缺失 SDK 方法: setTop
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> rmTop({
    required String dynamicId,
  }) async {
    // no SDK API — 缺失 SDK 方法: rmTop
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Article (articleInfo 经 oldBlog.getBlogDetail 实现；articleView 无 SDK API)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreArticleInfoData>> articleInfo({
    required String cvId,
  }) async {
    final rawId = cvId.replaceFirst(RegExp(r'^cv', caseSensitive: false), '');
    final bid = _parseId(rawId);
    if (bid == null) {
      return const Error('OttoHub: 无法解析专栏ID');
    }
    try {
      final detail = await _client.oldBlog.getBlogDetail(bid);
      return _ok(CoreArticleInfoData(
        favorite: detail.ifFavorite == 1,
        stats: CoreArticleInfoStats(
          favorite: detail.favoriteCount,
          like: detail.likeCount,
          reply: detail.commentCount,
        ),
        title: detail.title,
        originImageUrls: detail.thumbnails,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoDynamicsRepository.articleInfo ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreArticleViewData>> articleView({
    required String? cvId,
  }) async {
    // no SDK API — 缺失 SDK 方法: articleView
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Opus detail (maps to OttoHub blog detail)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreDynamicItemModel>> opusDetail({
    required String? opusId,
  }) async {
    final numericId = _parseId(opusId);
    if (numericId == null) {
      return const Error('OttoHub: 无法解析作品ID');
    }
    try {
      final detail = await _client.oldBlog.getBlogDetail(numericId);
      return _ok(CoreDynamicItemModel(
        idStr: detail.bid.toString(),
        type: 'blog',
        basic: CoreBasic(commentIdStr: detail.bid.toString()),
        modules: CoreItemModulesModel(
          moduleAuthor: CoreModuleAuthorModel(
            mid: detail.uid,
            name: detail.username,
            face: detail.avatarUrl,
            pubTime: detail.time,
          ),
          moduleStat: CoreModuleStatModel(
            like: CoreDynamicStat(count: detail.likeCount),
            comment: CoreDynamicStat(count: detail.commentCount),
          ),
          moduleDynamic: CoreModuleDynamicModel(
            desc: CoreDynamicDescModel(text: detail.content),
          ),
        ),
      ));
    } on ApiException catch (e) {
      debugPrint('OttoDynamicsRepository.opusDetail ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  // ---------------------------------------------------------------------------
  // Vote (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreVoteInfo>> voteInfo(int voteId) async {
    // no SDK API — 缺失 SDK 方法: voteInfo
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreVoteInfo>> doVote({
    required int voteId,
    required List<int> votes,
    bool anonymous = false,
    int? dynamicId,
  }) async {
    // no SDK API — 缺失 SDK 方法: doVote
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Topic (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreTopDetails?>> topicTop({
    required String topicId,
  }) async {
    // no SDK API — 缺失 SDK 方法: topicTop
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreTopicCardList?>> topicFeed({
    required String topicId,
    String? offset,
    required int sortBy,
  }) async {
    // no SDK API — 缺失 SDK 方法: topicFeed
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreTopicCardList?>> topicFold({
    required String topicId,
    required int sortBy,
  }) async {
    // no SDK API — 缺失 SDK 方法: topicFold
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Article list (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreArticleListData>> articleList({
    required String id,
  }) async {
    // no SDK API — 缺失 SDK 方法: articleList
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Reserve (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreDynReserveData>> dynReserve({
    required String? reserveId,
    required int? curBtnStatus,
    required String dynamicIdStr,
    required int? reserveTotal,
  }) async {
    // no SDK API — 缺失 SDK 方法: dynReserve
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CoreTopicItem>?>> dynTopicRcmd({
    int ps = 25,
  }) async {
    // no SDK API — 缺失 SDK 方法: dynTopicRcmd
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CoreOpusPicModel>?>> dynPic(String? id) async {
    // no SDK API — 缺失 SDK 方法: dynPic
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CoreMentionGroup>?>> dynMention({
    String? keyword,
  }) async {
    // no SDK API — 缺失 SDK 方法: dynMention
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Vote CRUD (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<int?>> createVote(CoreVoteInfo voteInfo) async {
    // no SDK API — 缺失 SDK 方法: createVote
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<int?>> updateVote(CoreVoteInfo voteInfo) async {
    // no SDK API — 缺失 SDK 方法: updateVote
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Reserve CRUD (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<int?>> createReserve({
    int subType = 0,
    required String title,
    required int livePlanStartTime,
  }) async {
    // no SDK API — 缺失 SDK 方法: createReserve
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<int?>> updateReserve({
    int subType = 0,
    required String title,
    required int livePlanStartTime,
    required int sid,
  }) async {
    // no SDK API — 缺失 SDK 方法: updateReserve
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreReserveInfoData>> reserveInfo({
    required int? sid,
  }) async {
    // no SDK API — 缺失 SDK 方法: reserveInfo
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Followee votes (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<List<CoreFolloweeVote>?>> followeeVotes({
    required String voteId,
  }) async {
    // no SDK API — 缺失 SDK 方法: followeeVotes
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Dyn privacy / edit (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<void>> dynPrivatePubSetting({
    required String dynId,
    int? dynType,
    required String action,
  }) async {
    // no SDK API — 缺失 SDK 方法: dynPrivatePubSetting
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> editDyn({
    required String dynId,
    String? repostDynId,
    String? rawText,
    List? pics,
    CoreReplyOptionType? replyOption,
    int? privatePub,
    List<Map<String, dynamic>>? extraContent,
    Pair<int, String>? topic,
    String? title,
    Map? attachCard,
  }) async {
    // no SDK API — 缺失 SDK 方法: editDyn
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Bubble / tribe (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreBubbleData>> bubble({
    required String tribeId,
    Object? categoryId,
    int? sortType,
    required int page,
  }) async {
    // no SDK API — 缺失 SDK 方法: bubble
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // Dyn reaction / emoji (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreDynReactionData>> dynReaction({
    required String id,
    String? offset,
  }) async {
    // no SDK API — 缺失 SDK 方法: dynReaction
    return _err(const ApiException('not_implemented'));
  }

  // ---------------------------------------------------------------------------
  // gRPC methods (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<int?> dynRed() async {
    // no SDK API — 缺失 SDK 方法: dynRed (gRPC)
    return null;
  }

  @override
  Future<LoadingState<CoreOpusDetailResp>> opusDetailGrpc({
    CoreOpusType? opusType,
    required int oid,
  }) async {
    // no SDK API — 缺失 SDK 方法: opusDetailGrpc (gRPC)
    return _err(const ApiException('not_implemented'));
  }
}
