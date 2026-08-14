import 'package:skf/core/utils/pair.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for dynamic/feed operations.
///
/// Merges HTTP (DynamicsHttp) and gRPC (DynGrpc) data sources into a single
/// contract. All methods that wrap API responses use [LoadingState] for
/// loading/success/error tri-state results.
abstract class DynamicsRepository {
  /// 跟随动态列表
  Future<LoadingState<CoreDynamicsDataModel>> followDynamic({
    int? hostMid,
    String? offset,
    Set<int>? tempBannedList,
    CoreDynamicsTabType type = .all,
  });

  /// 关注列表（首页）
  Future<LoadingState<CoreFollowUpModel>> followUp();

  /// 关注列表（全部）
  Future<LoadingState<CoreFollowUpModel>> dynUpList(String? offset);

  /// 关注列表（分页）
  Future<LoadingState<CoreFollowUpModel>> followings({
    int? vmid,
    int? pn,
    int ps = 20,
    String orderType = '',
  });

  /// 动态点赞/取消点赞
  Future<LoadingState<void>> thumbDynamic({
    required String? dynamicId,
    required int? up,
  });

  /// 创建动态
  Future<LoadingState<Map?>> createDynamic({
    int? mid,
    String dynIdStr,
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
  });

  /// 动态详情
  Future<LoadingState<CoreDynamicItemModel>> dynamicDetail({
    String? id,
    dynamic rid,
    Object? type,
    bool clearCookie = false,
  });

  /// 置顶动态
  Future<LoadingState<void>> setTop({
    required String dynamicId,
  });

  /// 取消置顶
  Future<LoadingState<void>> rmTop({
    required String dynamicId,
  });

  /// 专栏信息
  Future<LoadingState<CoreArticleInfoData>> articleInfo({
    required String cvId,
  });

  /// 专栏浏览
  Future<LoadingState<CoreArticleViewData>> articleView({
    required String? cvId,
  });

  /// 图文动态详情（HTTP）
  Future<LoadingState<CoreDynamicItemModel>> opusDetail({
    required String? opusId,
  });

  /// 投票信息
  Future<LoadingState<CoreVoteInfo>> voteInfo(int voteId);

  /// 投票
  Future<LoadingState<CoreVoteInfo>> doVote({
    required int voteId,
    required List<int> votes,
    bool anonymous = false,
    int? dynamicId,
  });

  /// 话题置顶
  Future<LoadingState<CoreTopDetails?>> topicTop({
    required String topicId,
  });

  /// 话题动态列表
  Future<LoadingState<CoreTopicCardList?>> topicFeed({
    required String topicId,
    String? offset,
    required int sortBy,
  });

  /// 话题折叠
  Future<LoadingState<CoreTopicCardList?>> topicFold({
    required String topicId,
    required int sortBy,
  });

  /// 专栏列表
  Future<LoadingState<CoreArticleListData>> articleList({
    required String id,
  });

  /// 预约
  Future<LoadingState<CoreDynReserveData>> dynReserve({
    required String? reserveId,
    required int? curBtnStatus,
    required String dynamicIdStr,
    required int? reserveTotal,
  });

  /// 推荐话题
  Future<LoadingState<List<CoreTopicItem>?>> dynTopicRcmd({
    int ps = 25,
  });

  /// 动态图片
  Future<LoadingState<List<CoreOpusPicModel>?>> dynPic(String? id);

  /// @提及用户
  Future<LoadingState<List<CoreMentionGroup>?>> dynMention({
    String? keyword,
  });

  /// 创建投票
  Future<LoadingState<int?>> createVote(CoreVoteInfo voteInfo);

  /// 更新投票
  Future<LoadingState<int?>> updateVote(CoreVoteInfo voteInfo);

  /// 创建预约
  Future<LoadingState<int?>> createReserve({
    int subType = 0,
    required String title,
    required int livePlanStartTime,
  });

  /// 更新预约
  Future<LoadingState<int?>> updateReserve({
    int subType = 0,
    required String title,
    required int livePlanStartTime,
    required int sid,
  });

  /// 预约信息
  Future<LoadingState<CoreReserveInfoData>> reserveInfo({
    required int? sid,
  });

  /// 投票好友
  Future<LoadingState<List<CoreFolloweeVote>?>> followeeVotes({
    required String voteId,
  });

  /// 动态私密发布设置
  Future<LoadingState<void>> dynPrivatePubSetting({
    required String dynId,
    int? dynType,
    required String action,
  });

  /// 编辑动态
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
  });

  /// 泡泡（部落）动态列表
  Future<LoadingState<CoreBubbleData>> bubble({
    required String tribeId,
    Object? categoryId,
    int? sortType,
    required int page,
  });

  /// 动态反应（表情互动）
  Future<LoadingState<CoreDynReactionData>> dynReaction({
    required String id,
    String? offset,
  });

  // ---- gRPC methods ----

  /// 动态红点（gRPC）
  Future<int?> dynRed();

  /// 图文动态详情（gRPC）
  Future<LoadingState<CoreOpusDetailResp>> opusDetailGrpc({
    CoreOpusType? opusType,
    required int oid,
  });
}
