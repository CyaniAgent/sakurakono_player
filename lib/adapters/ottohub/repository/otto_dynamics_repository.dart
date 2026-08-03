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
    // OttoHub SDK does not expose a generic "create dynamic" API.
    return const Error('OttoHub: 功能暂未支持');
  }

  // ---------------------------------------------------------------------------
  // Detail
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreDynamicItemModel>> dynamicDetail({
    Object? id,
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
    required Object dynamicId,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> rmTop({
    required Object dynamicId,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  // ---------------------------------------------------------------------------
  // Article (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreArticleInfoData>> articleInfo({
    required Object cvId,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreArticleViewData>> articleView({
    required Object? cvId,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  // ---------------------------------------------------------------------------
  // Opus detail (maps to OttoHub blog detail)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreDynamicItemModel>> opusDetail({
    required Object? opusId,
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
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreVoteInfo>> doVote({
    required int voteId,
    required List<int> votes,
    bool anonymous = false,
    int? dynamicId,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  // ---------------------------------------------------------------------------
  // Topic (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreTopDetails?>> topicTop({
    required Object topicId,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreTopicCardList?>> topicFeed({
    required Object topicId,
    String? offset,
    required int sortBy,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreTopicCardList?>> topicFold({
    required Object topicId,
    required int sortBy,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  // ---------------------------------------------------------------------------
  // Article list (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreArticleListData>> articleList({
    required Object id,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  // ---------------------------------------------------------------------------
  // Reserve (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreDynReserveData>> dynReserve({
    required Object? reserveId,
    required Object? curBtnStatus,
    required Object dynamicIdStr,
    required Object? reserveTotal,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<List<CoreTopicItem>?>> dynTopicRcmd({
    int ps = 25,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<List<CoreOpusPicModel>?>> dynPic(Object? id) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<List<CoreMentionGroup>?>> dynMention({
    String? keyword,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  // ---------------------------------------------------------------------------
  // Vote CRUD (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<int?>> createVote(CoreVoteInfo voteInfo) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<int?>> updateVote(CoreVoteInfo voteInfo) async {
    return const Error('OttoHub: 功能暂未支持');
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
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<int?>> updateReserve({
    int subType = 0,
    required String title,
    required int livePlanStartTime,
    required int sid,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<CoreReserveInfoData>> reserveInfo({
    required int? sid,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  // ---------------------------------------------------------------------------
  // Followee votes (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<List<CoreFolloweeVote>?>> followeeVotes({
    required dynamic voteId,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  // ---------------------------------------------------------------------------
  // Dyn privacy / edit (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<void>> dynPrivatePubSetting({
    required Object dynId,
    int? dynType,
    required String action,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  @override
  Future<LoadingState<void>> editDyn({
    required Object dynId,
    Object? repostDynId,
    String? rawText,
    List? pics,
    CoreReplyOptionType? replyOption,
    int? privatePub,
    List<Map<String, dynamic>>? extraContent,
    Pair<int, String>? topic,
    String? title,
    Map? attachCard,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  // ---------------------------------------------------------------------------
  // Bubble / tribe (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreBubbleData>> bubble({
    required Object tribeId,
    Object? categoryId,
    int? sortType,
    required int page,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  // ---------------------------------------------------------------------------
  // Dyn reaction / emoji (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<LoadingState<CoreDynReactionData>> dynReaction({
    required Object id,
    String? offset,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }

  // ---------------------------------------------------------------------------
  // gRPC methods (not supported by OttoHub SDK)
  // ---------------------------------------------------------------------------

  @override
  Future<int?> dynRed() async {
    return null;
  }

  @override
  Future<LoadingState<CoreOpusDetailResp>> opusDetailGrpc({
    CoreOpusType? opusType,
    required int oid,
  }) async {
    return const Error('OttoHub: 功能暂未支持');
  }
}
