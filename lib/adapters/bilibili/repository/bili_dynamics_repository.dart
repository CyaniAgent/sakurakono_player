import 'package:skf/adapters/bilibili/grpc/dyn.dart';
import 'package:skf/adapters/bilibili/http/dynamics.dart';
import 'package:skf/adapters/bilibili/models/common/dynamic/dynamics_type.dart';
import 'package:skf/adapters/bilibili/models/common/reply/reply_option_type.dart';
import 'package:skf/adapters/bilibili/models/dynamics/result.dart';
import 'package:skf/adapters/bilibili/models/dynamics/up.dart';
import 'package:skf/adapters/bilibili/models/dynamics/vote_model.dart' as adapter_vote;
import 'package:skf/adapters/bilibili/models_new/article/article_info/data.dart';
import 'package:skf/adapters/bilibili/models_new/article/article_list/data.dart';
import 'package:skf/adapters/bilibili/models_new/article/article_info/stats.dart' as article_info_stats;
import 'package:skf/adapters/bilibili/models_new/article/article_list/stats.dart' as article_list_stats;
import 'package:skf/adapters/bilibili/models/dynamics/article_content_model.dart'
    show ArticleContentModel;
import 'package:skf/adapters/bilibili/models_new/article/article_list/list.dart';
import 'package:skf/adapters/bilibili/models_new/article/article_list/article.dart';
import 'package:skf/adapters/bilibili/models_new/article/article_view/data.dart';
import 'package:skf/adapters/bilibili/models_new/article/article_view/opus.dart';
import 'package:skf/adapters/bilibili/models_new/article/article_view/ops.dart';
import 'package:skf/adapters/bilibili/models_new/bubble/base_info.dart';
import 'package:skf/adapters/bilibili/models_new/bubble/category.dart';
import 'package:skf/adapters/bilibili/models_new/bubble/category_list.dart';
import 'package:skf/adapters/bilibili/models_new/bubble/content.dart';
import 'package:skf/adapters/bilibili/models_new/bubble/data.dart';
import 'package:skf/adapters/bilibili/models_new/bubble/dyn_list.dart';
import 'package:skf/adapters/bilibili/models_new/bubble/meta.dart';
import 'package:skf/adapters/bilibili/models_new/bubble/sort_info.dart';
import 'package:skf/adapters/bilibili/models_new/bubble/sort_item.dart';
import 'package:skf/adapters/bilibili/models_new/bubble/tribee_info.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_mention/group.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_mention/item.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_reaction/data.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_reaction/item.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_reserve/data.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_reserve_info/data.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_topic_feed/all_sort_by.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_topic_feed/fold_card_item.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_topic_feed/item.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_topic_feed/topic_card_list.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_topic_feed/topic_sort_by_conf.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_topic_top/top_details.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_topic_top/topic_creator.dart';
import 'package:skf/adapters/bilibili/models_new/dynamic/dyn_topic_top/topic_item.dart';
import 'package:skf/adapters/bilibili/models_new/followee_votes/vote.dart';
import 'package:skf/adapters/bilibili/models/model_avatar.dart';
import 'package:skf/adapters/bilibili/models/model_owner.dart';
import 'package:skf/adapters/bilibili/utils/model_converters.dart';
import 'package:skf/adapters/bilibili/grpc/bilibili/app/dynamic/v2.pb.dart'
    show OpusType, OpusDetailResp;
import 'package:skf/common/widgets/pair.dart';
import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/repository/dynamics_repository.dart';
import 'package:skf/core/result/loading_state.dart';

// ignore_for_file: unused_element

/// {@template bili_dynamics_repository}
/// Implementation of [DynamicsRepository] that delegates to [DynamicsHttp]
/// and [DynGrpc].
/// {@endtemplate}
class BiliDynamicsRepository implements DynamicsRepository {
  // ---------------------------------------------------------------------------
  // Helper: map LoadingState<A> to LoadingState<B>
  // ---------------------------------------------------------------------------

  static LoadingState<T> _mapState<A, T>(
    LoadingState<A> source,
    T Function(A data) mapper,
  ) {
    return switch (source) {
      Loading() => LoadingState.loading(),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
      Success(:final response) => Success(mapper(response)),
    };
  }

  static T? _mapNullable<T, R>(R? value, T Function(R) mapper) {
    if (value == null) return null;
    return mapper(value);
  }

  static List<T>? _mapList<T, R>(List<R>? list, T Function(R) mapper) {
    return list?.map(mapper).toList();
  }

  // ---------------------------------------------------------------------------
  // Enum conversions
  // ---------------------------------------------------------------------------

  static CoreDynamicsTabType _toCoreDynamicsTabType(DynamicsTabType type) {
    return CoreDynamicsTabType.values[type.index];
  }

  static DynamicsTabType _toAdapterDynamicsTabType(CoreDynamicsTabType type) {
    return DynamicsTabType.values[type.index];
  }

  static CoreReplyOptionType _toCoreReplyOptionType(ReplyOptionType type) {
    return CoreReplyOptionType.values[type.index];
  }

  static ReplyOptionType _toAdapterReplyOptionType(CoreReplyOptionType type) {
    return ReplyOptionType.values[type.index];
  }

  static CoreOpusType? _toCoreOpusType(OpusType? type) {
    if (type == null) return null;
    return switch (type) {
      OpusType.OPUS_TYPE_DYN => CoreOpusType.dyn,
      OpusType.OPUS_TYPE_ARTICLE => CoreOpusType.article,
      OpusType.OPUS_TYPE_NOTE => CoreOpusType.note,
      OpusType.OPUS_TYPE_WORD => CoreOpusType.word,
      OpusType.OPUS_TYPE_REPOST => CoreOpusType.repost,
      OpusType.OPUS_TYPE_MANGA_EP => CoreOpusType.mangaEp,
      _ => CoreOpusType.dyn,
    };
  }

  static OpusType? _toAdapterOpusType(CoreOpusType? type) {
    if (type == null) return null;
    return switch (type) {
      CoreOpusType.dyn => OpusType.OPUS_TYPE_DYN,
      CoreOpusType.article => OpusType.OPUS_TYPE_ARTICLE,
      CoreOpusType.note => OpusType.OPUS_TYPE_NOTE,
      CoreOpusType.word => OpusType.OPUS_TYPE_WORD,
      CoreOpusType.repost => OpusType.OPUS_TYPE_REPOST,
      CoreOpusType.mangaEp => OpusType.OPUS_TYPE_MANGA_EP,
    };
  }

  // ---------------------------------------------------------------------------
  // Conversion helpers: Simple types (result.dart → core)
  // ---------------------------------------------------------------------------

  static CoreDynamicsDataModel _toCoreDynamicsDataModel(DynamicsDataModel m) {
    return CoreDynamicsDataModel(
      hasMore: m.hasMore,
      items: _mapList(m.items, ModelConverters.dynamicItemToCore),
      offset: m.offset,
      total: m.total,
      loadNext: m.loadNext,
    );
  }


  static CoreArticleContentModel _toCoreArticleContentModel(
    ArticleContentModel m,
  ) {
    return CoreArticleContentModel();
  }

  // ---------------------------------------------------------------------------
  // Conversion helpers: Follow/Up types
  // ---------------------------------------------------------------------------

  static CoreFollowUpModel _toCoreFollowUpModel(FollowUpModel m) {
    return CoreFollowUpModel(
      liveUsers: _mapNullable(m.liveUsers, _toCoreLiveUsers),
      upList: _mapList(m.upList, _toCoreUpItem),
      hasMore: m.hasMore,
      offset: m.offset,
    );
  }

  static CoreLiveUsers _toCoreLiveUsers(LiveUsers m) {
    return CoreLiveUsers(
      count: m.count,
      group: m.group,
      items: _mapList(m.items, _toCoreLiveUserItem),
    );
  }

  static CoreLiveUserItem _toCoreLiveUserItem(LiveUserItem m) {
    return CoreLiveUserItem(
      face: m.face,
      hasUpdate: m.hasUpdate,
      mid: m.mid,
      uname: m.uname,
      isReserveRecall: m.isReserveRecall,
      jumpUrl: m.jumpUrl,
      roomId: m.roomId,
      title: m.title,
    );
  }

  static CoreUpItem _toCoreUpItem(UpItem m) {
    return CoreUpItem(
      face: m.face,
      hasUpdate: m.hasUpdate,
      mid: m.mid,
      uname: m.uname,
    );
  }

  // ---------------------------------------------------------------------------
  // Conversion helpers: Article types
  // ---------------------------------------------------------------------------

  static CoreArticleInfoData _toCoreArticleInfoData(ArticleInfoData m) {
    return CoreArticleInfoData(
      favorite: m.favorite,
      stats: _mapNullable(m.stats, _toCoreArticleInfoStats),
      title: m.title,
      originImageUrls: m.originImageUrls,
    );
  }

  static CoreArticleInfoStats _toCoreArticleInfoStats(
    article_info_stats.Stats m,
  ) {
    return CoreArticleInfoStats(
      favorite: m.favorite,
      like: m.like,
      reply: m.reply,
      share: m.share,
    );
  }

  static CoreArticleViewData _toCoreArticleViewData(ArticleViewData m) {
    return CoreArticleViewData(
      id: m.id,
      author: _mapNullable(m.author, _toCoreAvatar),
      publishTime: m.publishTime,
      originImageUrls: m.originImageUrls,
      type: m.type,
      content: m.content,
      dynIdStr: m.dynIdStr,
      opus: _mapNullable(m.opus, _toCoreArticleOpus),
      ops: _mapList(m.ops, _toCoreArticleOps),
    );
  }

  static CoreAvatar _toCoreAvatar(Avatar m) {
    return CoreAvatar(mid: m.mid, name: m.name, face: m.face);
  }

  static CoreArticleOpus _toCoreArticleOpus(ArticleOpus m) {
    return CoreArticleOpus(
      content: _mapList(m.content, _toCoreArticleContentModel),
    );
  }

  static CoreArticleOps _toCoreArticleOps(ArticleOps m) {
    return CoreArticleOps(insert: m.insert, attributes: _mapNullable(m.attributes, _toCoreAttributes));
  }

  static CoreAttributes _toCoreAttributes(Attributes m) {
    return CoreAttributes(clazz: m.clazz);
  }

  static CoreArticleListData _toCoreArticleListData(ArticleListData m) {
    return CoreArticleListData(
      list: _mapNullable(m.list, _toCoreArticleListInfo),
      articles: _mapList(m.articles, _toCoreArticleListItemModel),
      author: _mapNullable(m.author, _toCoreOwner),
    );
  }

  static CoreArticleListInfo _toCoreArticleListInfo(ArticleListInfo m) {
    return CoreArticleListInfo(
      id: m.id,
      name: m.name,
      imageUrl: m.imageUrl,
      updateTime: m.updateTime,
      words: m.words,
      read: m.read,
      articlesCount: m.articlesCount,
    );
  }

  static CoreArticleListItemModel _toCoreArticleListItemModel(
    ArticleListItemModel m,
  ) {
    return CoreArticleListItemModel(
      id: m.id,
      title: m.title,
      imageUrls: m.imageUrls,
      summary: m.summary,
      dynIdStr: m.dynIdStr,
      stats: _mapNullable(m.stats, _toCoreArticleListStats),
    );
  }

  static CoreArticleListStats _toCoreArticleListStats(
    article_list_stats.Stats m,
  ) {
    return CoreArticleListStats(
      view: m.like,
      like: m.like,
      reply: m.reply,
    );
  }

  static CoreOwner _toCoreOwner(Owner m) {
    return CoreOwner(mid: m.mid, name: m.name, face: m.face);
  }

  // ---------------------------------------------------------------------------
  // Conversion helpers: Vote types
  // ---------------------------------------------------------------------------

  static CoreSimpleVoteInfo _toCoreSimpleVoteInfo(
    adapter_vote.SimpleVoteInfo m,
  ) {
    return CoreSimpleVoteInfo(
      choiceCnt: m.choiceCnt,
      defaultShare: m.defaultShare,
      desc: m.desc,
      endTime: m.endTime,
      status: m.status,
      uid: m.uid,
      voteId: m.voteId,
      joinNum: m.joinNum,
    );
  }

  static CoreVoteInfo _toCoreVoteInfo(adapter_vote.VoteInfo m) {
    return CoreVoteInfo(
      choiceCnt: m.choiceCnt,
      defaultShare: m.defaultShare,
      desc: m.desc,
      endTime: m.endTime,
      status: m.status,
      uid: m.uid,
      voteId: m.voteId,
      joinNum: m.joinNum,
      title: m.title,
      ctime: m.ctime,
      myVotes: m.myVotes,
      options: m.options.map(_toCoreOption).toList(),
      optionsCnt: m.optionsCnt,
      voterLevel: m.voterLevel,
      face: m.face,
      name: m.name,
      type: m.type,
      votePublisher: m.votePublisher,
      duration: m.duration,
      onlyFansLevel: m.onlyFansLevel,
    );
  }

  static CoreOption _toCoreOption(adapter_vote.Option m) {
    return CoreOption(
      optDesc: m.optDesc,
      imgUrl: m.imgUrl,
      optIdx: m.optIdx,
      cnt: m.cnt,
    );
  }

  // ---------------------------------------------------------------------------
  // Conversion helpers: Adapter VoteInfo → CoreVoteInfo (for createVote/updateVote)
  // ---------------------------------------------------------------------------

  static adapter_vote.VoteInfo _toAdapterVoteInfo(CoreVoteInfo core) {
    return adapter_vote.VoteInfo(
      choiceCnt: core.choiceCnt,
      defaultShare: core.defaultShare,
      desc: core.desc,
      endTime: core.endTime,
      status: core.status,
      uid: core.uid,
      voteId: core.voteId,
      joinNum: core.joinNum,
      title: core.title,
      ctime: core.ctime,
      myVotes: core.myVotes,
      options: core.options.map(_toAdapterOption).toList(),
      optionsCnt: core.optionsCnt,
      voterLevel: core.voterLevel,
      face: core.face,
      name: core.name,
      type: core.type,
      votePublisher: core.votePublisher,
      duration: core.duration,
      onlyFansLevel: core.onlyFansLevel,
    );
  }

  static adapter_vote.Option _toAdapterOption(CoreOption core) {
    return adapter_vote.Option(
      optDesc: core.optDesc,
      imgUrl: core.imgUrl,
    )
      ..optIdx = core.optIdx
      ..cnt = core.cnt;
  }

  // ---------------------------------------------------------------------------
  // Conversion helpers: Other simple types
  // ---------------------------------------------------------------------------

  static CoreDynReserveData _toCoreDynReserveData(DynReserveData m) {
    return CoreDynReserveData(
      finalBtnStatus: m.finalBtnStatus,
      reserveUpdate: m.reserveUpdate,
      descUpdate: m.descUpdate,
    );
  }

  static CoreReserveInfoData _toCoreReserveInfoData(ReserveInfoData m) {
    return CoreReserveInfoData(
      id: m.id,
      title: m.title,
      livePlanStartTime: m.livePlanStartTime,
    );
  }

  static CoreTopicItem _toCoreTopicItem(TopicItem m) {
    return CoreTopicItem(
      id: m.id,
      name: m.name,
      view: m.view,
      discuss: m.discuss,
      fav: m.fav,
      like: m.like,
      description: m.description,
      isFav: m.isFav,
      isLike: m.isLike,
    );
  }

  static CoreTopDetails _toCoreTopDetails(TopDetails m) {
    return CoreTopDetails(
      topicItem: _mapNullable(m.topicItem, _toCoreTopicItem),
      topicCreator: _mapNullable(m.topicCreator, _toCoreTopicCreator),
    );
  }

  static CoreTopicCreator _toCoreTopicCreator(TopicCreator m) {
    return CoreTopicCreator(uid: m.uid, face: m.face, name: m.name);
  }

  static CoreTopicCardList _toCoreTopicCardList(TopicCardList m) {
    return CoreTopicCardList(
      hasMore: m.hasMore,
      items: _mapList(m.items, _toCoreTopicCardItem),
      offset: m.offset,
      topicSortByConf:
          _mapNullable(m.topicSortByConf, _toCoreTopicSortByConf),
    );
  }

  static CoreTopicCardItem _toCoreTopicCardItem(TopicCardItem m) {
    return CoreTopicCardItem(
      foldCardItem: _mapNullable(m.foldCardItem, _toCoreFoldCardItem),
      dynamicCardItem:
          _mapNullable(m.dynamicCardItem, ModelConverters.dynamicItemToCore),
      topicType: m.topicType,
    );
  }

  static CoreFoldCardItem _toCoreFoldCardItem(FoldCardItem m) {
    return CoreFoldCardItem(foldCount: m.foldCount, foldDesc: m.foldDesc);
  }

  static CoreTopicSortByConf _toCoreTopicSortByConf(TopicSortByConf m) {
    return CoreTopicSortByConf(
      allSortBy: _mapList(m.allSortBy, _toCoreAllSortBy),
      showSortBy: m.showSortBy,
    );
  }

  static CoreAllSortBy _toCoreAllSortBy(AllSortBy m) {
    return CoreAllSortBy(sortBy: m.sortBy, sortName: m.sortName);
  }

  static CoreBubbleData _toCoreBubbleData(BubbleData m) {
    return CoreBubbleData(
      baseInfo: _mapNullable(m.baseInfo, _toCoreBaseInfo),
      content: _mapNullable(m.content, _toCoreBubbleContent),
      category: _mapNullable(m.category, _toCoreBubbleCategory),
      sortInfo: _mapNullable(m.sortInfo, _toCoreSortInfo),
    );
  }

  static CoreBaseInfo _toCoreBaseInfo(BaseInfo m) {
    return CoreBaseInfo(
      tribeInfo: _mapNullable(m.tribeInfo, _toCoreTribeInfo),
      isJoined: m.isJoined,
    );
  }

  static CoreTribeInfo _toCoreTribeInfo(TribeInfo m) {
    return CoreTribeInfo(
      id: m.id,
      title: m.title,
      subTitle: m.subTitle,
      faceUrl: m.faceUrl,
      jumpUri: m.jumpUri,
      summary: m.summary,
    );
  }

  static CoreBubbleContent _toCoreBubbleContent(Content m) {
    return CoreBubbleContent(
      count: m.count,
      dynList: _mapList(m.dynList, _toCoreDynList),
    );
  }

  static CoreDynList _toCoreDynList(DynList m) {
    return CoreDynList(
      dynId: m.dynId,
      title: m.title,
      meta: _mapNullable(m.meta, _toCoreMeta),
    );
  }

  static CoreMeta _toCoreMeta(Meta m) {
    return CoreMeta(
      author: m.author,
      timeText: m.timeText,
      replyCount: m.replyCount,
      viewStat: m.viewStat,
    );
  }

  static CoreBubbleCategory _toCoreBubbleCategory(Category m) {
    return CoreBubbleCategory(
      categoryList: _mapList(m.categoryList, _toCoreCategoryList),
    );
  }

  static CoreCategoryList _toCoreCategoryList(CategoryList m) {
    return CoreCategoryList(id: m.id, name: m.name, type: m.type);
  }

  static CoreSortInfo _toCoreSortInfo(SortInfo m) {
    return CoreSortInfo(
      showSort: m.showSort,
      sortItems: _mapList(m.sortItems, _toCoreSortItem),
      curSortType: m.curSortType,
    );
  }

  static CoreSortItem _toCoreSortItem(SortItem m) {
    return CoreSortItem(sortType: m.sortType, text: m.text);
  }

  static CoreDynReactionData _toCoreDynReactionData(DynReactionData m) {
    return CoreDynReactionData(
      hasMore: m.hasMore,
      items: _mapList(m.items, _toCoreDynReactionItem),
      offset: m.offset,
      total: m.total,
    );
  }

  static CoreDynReactionItem _toCoreDynReactionItem(DynReactionItem m) {
    return CoreDynReactionItem(
      action: m.action,
      face: m.face,
      mid: m.mid,
      name: m.name,
    );
  }

  static CoreMentionGroup _toCoreMentionGroup(MentionGroup m) {
    return CoreMentionGroup(
      groupName: m.groupName,
      items: _mapList(m.items, _toCoreMentionItem),
    );
  }

  static CoreMentionItem _toCoreMentionItem(MentionItem m) {
    return CoreMentionItem(
      face: m.face,
      fans: m.fans,
      name: m.name,
      uid: m.uid,
    );
  }

  static CoreFolloweeVote _toCoreFolloweeVote(FolloweeVote m) {
    return CoreFolloweeVote(
      mid: m.mid ?? 0,
      name: m.name,
      face: m.face,
      votes: m.votes,
      ctime: m.ctime,
    );
  }

  // ---------------------------------------------------------------------------
  // gRPC conversion helpers
  // ---------------------------------------------------------------------------

  static CoreOpusDetailResp _toCoreOpusDetailResp(OpusDetailResp m) {
    return CoreOpusDetailResp(
      opusItem: CoreOpusItem(
        opusId: m.opusItem.opusId.toInt(),
        opusType: _toCoreOpusType(m.opusItem.opusType),
        oid: m.opusItem.oid.toInt(),
        modules: m.opusItem.modules
            .map((_) => CoreModule())
            .toList(),
        extend: CoreExtend(),
      ),
    );
  }

  // =====================================================================
  // Interface implementation
  // =====================================================================

  @override
  Future<LoadingState<CoreDynamicsDataModel>> followDynamic({
    int? hostMid,
    String? offset,
    Set<int>? tempBannedList,
    CoreDynamicsTabType type = CoreDynamicsTabType.all,
  }) async {
    final result = await DynamicsHttp.followDynamic(
      hostMid: hostMid,
      offset: offset,
      tempBannedList: tempBannedList,
      type: _toAdapterDynamicsTabType(type),
    );
    return _mapState(result, _toCoreDynamicsDataModel);
  }

  @override
  Future<LoadingState<CoreFollowUpModel>> followUp() async {
    final result = await DynamicsHttp.followUp();
    return _mapState(result, _toCoreFollowUpModel);
  }

  @override
  Future<LoadingState<CoreFollowUpModel>> dynUpList(String? offset) async {
    final result = await DynamicsHttp.dynUpList(offset);
    return _mapState(result, _toCoreFollowUpModel);
  }

  @override
  Future<LoadingState<CoreFollowUpModel>> followings({
    int? vmid,
    int? pn,
    int ps = 20,
    String orderType = '',
  }) async {
    final result = await DynamicsHttp.followings(
      vmid: vmid,
      pn: pn,
      ps: ps,
      orderType: orderType,
    );
    return _mapState(result, _toCoreFollowUpModel);
  }

  @override
  Future<LoadingState<void>> thumbDynamic({
    required String? dynamicId,
    required int? up,
  }) =>
      DynamicsHttp.thumbDynamic(dynamicId: dynamicId, up: up);

  @override
  Future<LoadingState<Map?>> createDynamic({
    dynamic mid,
    dynamic dynIdStr,
    dynamic rid,
    dynamic dynType,
    dynamic rawText,
    List? pics,
    int? publishTime,
    CoreReplyOptionType? replyOption,
    int? privatePub,
    List<Map<String, dynamic>>? extraContent,
    Pair<int, String>? topic,
    String? title,
    Map? attachCard,
  }) =>
      DynamicsHttp.createDynamic(
        mid: mid,
        dynIdStr: dynIdStr,
        rid: rid,
        dynType: dynType,
        rawText: rawText,
        pics: pics,
        publishTime: publishTime,
        replyOption: replyOption != null
            ? _toAdapterReplyOptionType(replyOption)
            : null,
        privatePub: privatePub,
        extraContent: extraContent,
        topic: topic,
        title: title,
        attachCard: attachCard,
      );

  @override
  Future<LoadingState<CoreDynamicItemModel>> dynamicDetail({
    String? id,
    dynamic rid,
    dynamic type,
    bool clearCookie = false,
  }) async {
    final result = await DynamicsHttp.dynamicDetail(
      id: id,
      rid: rid,
      type: type,
      clearCookie: clearCookie,
    );
    return _mapState(result, ModelConverters.dynamicItemToCore);
  }

  @override
  Future<LoadingState<void>> setTop({
    required String dynamicId,
  }) =>
      DynamicsHttp.setTop(dynamicId: dynamicId);

  @override
  Future<LoadingState<void>> rmTop({
    required String dynamicId,
  }) =>
      DynamicsHttp.rmTop(dynamicId: dynamicId);

  @override
  Future<LoadingState<CoreArticleInfoData>> articleInfo({
    required String cvId,
  }) async {
    final result = await DynamicsHttp.articleInfo(cvId: cvId);
    return _mapState(result, _toCoreArticleInfoData);
  }

  @override
  Future<LoadingState<CoreArticleViewData>> articleView({
    required String? cvId,
  }) async {
    final result = await DynamicsHttp.articleView(cvId: cvId);
    return _mapState(result, _toCoreArticleViewData);
  }

  @override
  Future<LoadingState<CoreDynamicItemModel>> opusDetail({
    required String? opusId,
  }) async {
    final result = await DynamicsHttp.opusDetail(opusId: opusId);
    return _mapState(result, ModelConverters.dynamicItemToCore);
  }

  @override
  Future<LoadingState<CoreVoteInfo>> voteInfo(int voteId) async {
    final result = await DynamicsHttp.voteInfo(voteId);
    return _mapState(result, _toCoreVoteInfo);
  }

  @override
  Future<LoadingState<CoreVoteInfo>> doVote({
    required int voteId,
    required List<int> votes,
    bool anonymous = false,
    int? dynamicId,
  }) async {
    final result = await DynamicsHttp.doVote(
      voteId: voteId,
      votes: votes,
      anonymous: anonymous,
      dynamicId: dynamicId,
    );
    return _mapState(result, _toCoreVoteInfo);
  }

  @override
  Future<LoadingState<CoreTopDetails?>> topicTop({
    required String topicId,
  }) async {
    final result = await DynamicsHttp.topicTop(topicId: topicId);
    return _mapState(result, (data) => data != null ? _toCoreTopDetails(data) : null);
  }

  @override
  Future<LoadingState<CoreTopicCardList?>> topicFeed({
    required String topicId,
    String? offset,
    required int sortBy,
  }) async {
    final result = await DynamicsHttp.topicFeed(
      topicId: topicId,
      offset: offset,
      sortBy: sortBy,
    );
    return _mapState(result, (data) => data != null ? _toCoreTopicCardList(data) : null);
  }

  @override
  Future<LoadingState<CoreTopicCardList?>> topicFold({
    required String topicId,
    required int sortBy,
  }) async {
    final result = await DynamicsHttp.topicFold(topicId: topicId, sortBy: sortBy);
    return _mapState(result, (data) => data != null ? _toCoreTopicCardList(data) : null);
  }

  @override
  Future<LoadingState<CoreArticleListData>> articleList({
    required String id,
  }) async {
    final result = await DynamicsHttp.articleList(id: id);
    return _mapState(result, _toCoreArticleListData);
  }

  @override
  Future<LoadingState<CoreDynReserveData>> dynReserve({
    required String? reserveId,
    required int? curBtnStatus,
    required String dynamicIdStr,
    required int? reserveTotal,
  }) async {
    final result = await DynamicsHttp.dynReserve(
      reserveId: reserveId,
      curBtnStatus: curBtnStatus,
      dynamicIdStr: dynamicIdStr,
      reserveTotal: reserveTotal,
    );
    return _mapState(result, _toCoreDynReserveData);
  }

  @override
  Future<LoadingState<List<CoreTopicItem>?>> dynTopicRcmd({
    int ps = 25,
  }) async {
    final result = await DynamicsHttp.dynTopicRcmd(ps: ps);
    return _mapState(result, (data) => data?.map(_toCoreTopicItem).toList());
  }

  @override
  Future<LoadingState<List<CoreOpusPicModel>?>> dynPic(String? id) async {
    final result = await DynamicsHttp.dynPic(id);
    return _mapState(result, (data) => data?.map(ModelConverters.opusPicToCore).toList());
  }

  @override
  Future<LoadingState<List<CoreMentionGroup>?>> dynMention({
    String? keyword,
  }) async {
    final result = await DynamicsHttp.dynMention(keyword: keyword);
    return _mapState(result, (data) => data?.map(_toCoreMentionGroup).toList());
  }

  @override
  Future<LoadingState<int?>> createVote(CoreVoteInfo voteInfo) =>
      DynamicsHttp.createVote(_toAdapterVoteInfo(voteInfo));

  @override
  Future<LoadingState<int?>> updateVote(CoreVoteInfo voteInfo) =>
      DynamicsHttp.updateVote(_toAdapterVoteInfo(voteInfo));

  @override
  Future<LoadingState<int?>> createReserve({
    int subType = 0,
    required String title,
    required int livePlanStartTime,
  }) =>
      DynamicsHttp.createReserve(
        subType: subType,
        title: title,
        livePlanStartTime: livePlanStartTime,
      );

  @override
  Future<LoadingState<int?>> updateReserve({
    int subType = 0,
    required String title,
    required int livePlanStartTime,
    required int sid,
  }) =>
      DynamicsHttp.updateReserve(
        subType: subType,
        title: title,
        livePlanStartTime: livePlanStartTime,
        sid: sid,
      );

  @override
  Future<LoadingState<CoreReserveInfoData>> reserveInfo({
    required int? sid,
  }) async {
    final result = await DynamicsHttp.reserveInfo(sid: sid);
    return _mapState(result, _toCoreReserveInfoData);
  }

  @override
  Future<LoadingState<List<CoreFolloweeVote>?>> followeeVotes({
    required String voteId,
  }) async {
    final result = await DynamicsHttp.followeeVotes(voteId: voteId);
    return _mapState(result, (data) => data?.map(_toCoreFolloweeVote).toList());
  }

  @override
  Future<LoadingState<void>> dynPrivatePubSetting({
    required String dynId,
    int? dynType,
    required String action,
  }) =>
      DynamicsHttp.dynPrivatePubSetting(
        dynId: dynId,
        dynType: dynType,
        action: action,
      );

  @override
  Future<LoadingState<void>> editDyn({
    required String dynId,
    String? repostDynId,
    dynamic rawText,
    List? pics,
    CoreReplyOptionType? replyOption,
    int? privatePub,
    List<Map<String, dynamic>>? extraContent,
    Pair<int, String>? topic,
    String? title,
    Map? attachCard,
  }) =>
      DynamicsHttp.editDyn(
        dynId: dynId,
        repostDynId: repostDynId,
        rawText: rawText,
        pics: pics,
        replyOption: replyOption != null
            ? _toAdapterReplyOptionType(replyOption)
            : null,
        privatePub: privatePub,
        extraContent: extraContent,
        topic: topic,
        title: title,
        attachCard: attachCard,
      );

  @override
  Future<LoadingState<CoreBubbleData>> bubble({
    required String tribeId,
    Object? categoryId,
    int? sortType,
    required int page,
  }) async {
    final result = await DynamicsHttp.bubble(
      tribeId: tribeId,
      categoryId: categoryId,
      sortType: sortType,
      page: page,
    );
    return _mapState(result, _toCoreBubbleData);
  }

  @override
  Future<LoadingState<CoreDynReactionData>> dynReaction({
    required String id,
    String? offset,
  }) async {
    final result = await DynamicsHttp.dynReaction(id: id, offset: offset);
    return _mapState(result, _toCoreDynReactionData);
  }

  // ---- gRPC methods ----

  @override
  Future<int?> dynRed() {
    return DynGrpc.dynRed();
  }

  @override
  Future<LoadingState<CoreOpusDetailResp>> opusDetailGrpc({
    CoreOpusType? opusType,
    required int oid,
  }) async {
    final result = await DynGrpc.opusDetail(
      opusType: _toAdapterOpusType(opusType),
      oid: oid,
    );
    return _mapState(result, _toCoreOpusDetailResp);
  }
}
