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
    show ArticleContentModel, Common, Pic;
import 'package:skf/adapters/bilibili/models_new/article/article_list/list.dart';
import 'package:skf/adapters/bilibili/models_new/article/article_list/article.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_feed_index/watched_show.dart';
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
      items: _mapList(m.items, _toCoreDynamicItemModel),
      offset: m.offset,
      total: m.total,
      loadNext: m.loadNext,
    );
  }

  static CoreDynamicItemModel _toCoreDynamicItemModel(DynamicItemModel m) {
    return CoreDynamicItemModel(
      basic: _mapNullable(m.basic, _toCoreBasic),
      idStr: m.idStr,
      modules: _mapNullable(m.modules, _toCoreItemModulesModel),
      orig: _mapNullable(m.orig, _toCoreDynamicItemModel),
      type: m.type,
      visible: m.visible,
      linkFolded: m.linkFolded,
      fallback: _mapNullable(m.fallback, _toCoreFallback),
    );
  }

  static CoreBasic _toCoreBasic(Basic m) {
    return CoreBasic(
      commentIdStr: m.commentIdStr,
      commentType: m.commentType,
      ridStr: m.ridStr,
    );
  }

  static CoreFallback _toCoreFallback(Fallback m) {
    return CoreFallback(id: m.id);
  }

  static CoreItemModulesModel _toCoreItemModulesModel(ItemModulesModel m) {
    return CoreItemModulesModel(
      moduleAuthor: _mapNullable(m.moduleAuthor, _toCoreModuleAuthorModel),
      moduleStat: _mapNullable(m.moduleStat, _toCoreModuleStatModel),
      moduleTag: _mapNullable(m.moduleTag, _toCoreModuleTag),
      moduleDynamic: _mapNullable(m.moduleDynamic, _toCoreModuleDynamicModel),
      moduleInteraction:
          _mapNullable(m.moduleInteraction, _toCoreModuleInteraction),
      moduleDispute: _mapNullable(m.moduleDispute, _toCoreModuleDispute),
      moduleTop: _mapNullable(m.moduleTop, _toCoreModuleTop),
      moduleCollection:
          _mapNullable(m.moduleCollection, _toCoreModuleCollection),
      moduleExtend: _mapList(m.moduleExtend, _toCoreModuleTag),
      moduleContent: _mapList(m.moduleContent, _toCoreArticleContentModel),
      moduleBlocked: _mapNullable(m.moduleBlocked, _toCoreModuleBlocked),
      moduleFold: _mapNullable(m.moduleFold, _toCoreModuleFold),
    );
  }

  static CoreModuleAuthorModel _toCoreModuleAuthorModel(ModuleAuthorModel m) {
    return CoreModuleAuthorModel(
      face: m.face,
      name: m.name,
      mid: m.mid,
      pubAction: m.pubAction,
      pubTime: m.pubTime,
      pubTs: m.pubTs,
      type: m.type,
      decorate: _mapNullable(m.decorate, _toCoreDecorate),
      isTop: m.isTop,
      badgeText: m.badgeText,
      pendant: m.pendant?.image,
      officialVerify: m.officialVerify?.type,
    );
  }

  static CoreDecorate _toCoreDecorate(Decorate m) {
    return CoreDecorate(
      cardUrl: m.cardUrl,
      fan: _mapNullable(m.fan, _toCoreFan),
    );
  }

  static CoreFan _toCoreFan(Fan m) {
    return CoreFan(color: m.color, numStr: m.numStr);
  }

  static CoreModuleStatModel _toCoreModuleStatModel(ModuleStatModel m) {
    return CoreModuleStatModel(
      comment: _mapNullable(m.comment, _toCoreDynamicStat),
      forward: _mapNullable(m.forward, _toCoreDynamicStat),
      like: _mapNullable(m.like, _toCoreDynamicStat),
      favorite: _mapNullable(m.favorite, _toCoreDynamicStat),
    );
  }

  static CoreDynamicStat _toCoreDynamicStat(DynamicStat m) {
    return CoreDynamicStat(count: m.count, status: m.status);
  }

  static CoreModuleTag _toCoreModuleTag(ModuleTag m) {
    return CoreModuleTag(text: m.text);
  }

  static CoreModuleDynamicModel _toCoreModuleDynamicModel(
    ModuleDynamicModel m,
  ) {
    return CoreModuleDynamicModel(
      additional: _mapNullable(m.additional, _toCoreDynamicAddModel),
      desc: _mapNullable(m.desc, _toCoreDynamicDescModel),
      major: _mapNullable(m.major, _toCoreDynamicMajorModel),
      topic: _mapNullable(m.topic, _toCoreDynamicTopicModel),
    );
  }

  static CoreDynamicAddModel _toCoreDynamicAddModel(DynamicAddModel m) {
    return CoreDynamicAddModel(
      type: m.type,
      vote: _mapNullable(m.vote, _toCoreVote),
      ugc: _mapNullable(m.ugc, _toCoreUgc),
      reserve: _mapNullable(m.reserve, _toCoreReserve),
      goods: _mapNullable(m.goods, _toCoreGood),
      upowerLottery: _mapNullable(m.upowerLottery, _toCoreUpowerLottery),
      common: _mapNullable(m.common, _toCoreAddCommon),
      match: _mapNullable(m.match, _toCoreAddMatch),
    );
  }

  static CoreVote _toCoreVote(Vote m) {
    return CoreVote(joinNum: m.joinNum, voteId: m.voteId, title: m.title);
  }

  static CoreUgc _toCoreUgc(Ugc m) {
    return CoreUgc(
      cover: m.cover,
      descSecond: m.descSecond,
      jumpUrl: m.jumpUrl,
      title: m.title,
    );
  }

  static CoreReserve _toCoreReserve(Reserve m) {
    return CoreReserve(
      button: _mapNullable(m.button, _toCoreReserveBtn),
      desc1: _mapNullable(m.desc1, _toCoreDesc),
      desc2: _mapNullable(m.desc2, _toCoreDesc),
      desc3: _mapNullable(m.desc3, _toCoreDesc),
      reserveTotal: m.reserveTotal,
      rid: m.rid,
      state: m.state,
      title: m.title,
    );
  }

  static CoreReserveBtn _toCoreReserveBtn(ReserveBtn m) {
    return CoreReserveBtn(
      status: m.status,
      type: m.type,
      checkText: m.checkText,
      uncheckText: m.uncheckText,
      disable: m.disable,
      jumpText: m.jumpText,
      jumpUrl: m.jumpUrl,
    );
  }

  static CoreDesc _toCoreDesc(Desc m) {
    return CoreDesc(text: m.text, jumpUrl: m.jumpUrl);
  }

  static CoreGood _toCoreGood(Good m) {
    return CoreGood(items: _mapList(m.items, _toCoreGoodItem));
  }

  static CoreGoodItem _toCoreGoodItem(GoodItem m) {
    return CoreGoodItem(
      cover: m.cover,
      jumpDesc: m.jumpDesc,
      jumpUrl: m.jumpUrl,
      name: m.name,
      price: m.price,
    );
  }

  static CoreUpowerLottery _toCoreUpowerLottery(UpowerLottery m) {
    return CoreUpowerLottery(
      button: _mapNullable(m.button, _toCoreButton),
      desc: _mapNullable(m.desc, _toCoreDesc),
      hint: _mapNullable(m.hint, _toCoreHint),
      jumpUrl: m.jumpUrl,
      title: m.title,
    );
  }

  static CoreHint _toCoreHint(Hint m) {
    return CoreHint(text: m.text);
  }

  static CoreAddCommon _toCoreAddCommon(AddCommon m) {
    return CoreAddCommon(
      button: _mapNullable(m.button, _toCoreButton),
      cover: m.cover,
      desc1: m.desc1,
      desc2: m.desc2,
      jumpUrl: m.jumpUrl,
      title: m.title,
    );
  }

  static CoreAddMatch _toCoreAddMatch(AddMatch m) {
    return CoreAddMatch(
      button: _mapNullable(m.button, _toCoreButton),
      jumpUrl: m.jumpUrl,
      matchInfo: _mapNullable(m.matchInfo, _toCoreMatchInfo),
    );
  }

  static CoreMatchInfo _toCoreMatchInfo(MatchInfo m) {
    return CoreMatchInfo(
      centerBottom: m.centerBottom,
      centerTop: m.centerTop,
      leftTeam: _mapNullable(m.leftTeam, _toCoreTTeam),
      rightTeam: _mapNullable(m.rightTeam, _toCoreTTeam),
      subTitle: m.subTitle,
      title: m.title,
    );
  }

  static CoreTTeam _toCoreTTeam(TTeam m) {
    return CoreTTeam(name: m.name, pic: m.pic);
  }

  static CoreButton _toCoreButton(Button m) {
    return CoreButton(
      icon: m.icon,
      jumpUrl: m.jumpUrl,
      text: m.text,
      jumpStyle: _mapNullable(m.jumpStyle, _toCoreJumpStyle),
      check: _mapNullable(m.check, _toCoreCheck),
    );
  }

  static CoreJumpStyle _toCoreJumpStyle(JumpStyle m) {
    return CoreJumpStyle(text: m.text);
  }

  static CoreCheck _toCoreCheck(Check m) {
    return CoreCheck(text: m.text);
  }

  static CoreBgImg _toCoreBgImg(BgImg m) {
    return CoreBgImg(imgDark: m.imgDark, imgDay: m.imgDay);
  }

  static CoreDynamicDescModel _toCoreDynamicDescModel(DynamicDescModel m) {
    return CoreDynamicDescModel(
      richTextNodes: _mapList(m.richTextNodes, _toCoreRichTextNodeItem),
      text: m.text,
    );
  }

  static CoreDynamicMajorModel _toCoreDynamicMajorModel(DynamicMajorModel m) {
    return CoreDynamicMajorModel(
      archive: _mapNullable(m.archive, _toCoreDynamicArchiveModel),
      ugcSeason: _mapNullable(m.ugcSeason, _toCoreDynamicArchiveModel),
      opus: _mapNullable(m.opus, _toCoreDynamicOpusModel),
      pgc: _mapNullable(m.pgc, _toCoreDynamicArchiveModel),
      liveRcmd: _mapNullable(m.liveRcmd, _toCoreDynamicLiveModel),
      live: _mapNullable(m.live, _toCoreDynamicLive2Model),
      none: _mapNullable(m.none, _toCoreDynamicNoneModel),
      type: m.type,
      courses: _mapNullable(m.courses, _toCoreDynamicArchiveModel),
      common: _mapNullable(m.common, _toCoreCommon),
      upowerCommon: _mapNullable(m.upowerCommon, _toCoreCommon),
      music: _mapNullable(m.music, _toCoreMusic),
      blocked: _mapNullable(m.blocked, _toCoreModuleBlocked),
      medialist: _mapNullable(m.medialist, _toCoreMedialist),
      subscriptionNew:
          _mapNullable(m.subscriptionNew, _toCoreSubscriptionNew),
    );
  }

  static CoreDynamicArchiveModel _toCoreDynamicArchiveModel(
    DynamicArchiveModel m,
  ) {
    return CoreDynamicArchiveModel(
      id: m.id,
      aid: m.aid,
      badge: _mapNullable(m.badge, _toCoreBadge),
      bvid: m.bvid,
      cover: m.cover,
      durationText: m.durationText,
      jumpUrl: m.jumpUrl,
      stat: _mapNullable(m.stat, _toCoreStat),
      title: m.title,
      type: m.type,
      epid: m.epid,
      seasonId: m.seasonId,
    );
  }

  static CoreBadge _toCoreBadge(Badge m) {
    return CoreBadge(text: m.text);
  }

  static CoreStat _toCoreStat(Stat m) {
    return CoreStat(danmu: m.danmu, play: m.play);
  }

  static CoreDynamicOpusModel _toCoreDynamicOpusModel(DynamicOpusModel m) {
    return CoreDynamicOpusModel(
      pics: _mapList(m.pics, _toCoreOpusPicModel),
      summary: _mapNullable(m.summary, _toCoreSummaryModel),
      title: m.title,
    );
  }

  static CoreSummaryModel _toCoreSummaryModel(SummaryModel m) {
    return CoreSummaryModel(
      richTextNodes: _mapList(m.richTextNodes, _toCoreRichTextNodeItem),
      text: m.text,
    );
  }

  static CoreOpusPicModel _toCoreOpusPicModel(OpusPicModel m) {
    return CoreOpusPicModel(
      width: m.width,
      height: m.height,
      src: m.src,
      url: m.url,
      liveUrl: m.liveUrl,
      size: m.size,
    );
  }

  static CoreRichTextNodeItem _toCoreRichTextNodeItem(RichTextNodeItem m) {
    return CoreRichTextNodeItem(
      emoji: _mapNullable(m.emoji, _toCoreEmoji),
      origText: m.origText,
      text: m.text,
      type: m.type,
      rid: m.rid,
      pics: _mapList(m.pics, _toCoreOpusPicModel),
      jumpUrl: m.jumpUrl,
    );
  }

  static CoreEmoji _toCoreEmoji(Emoji m) {
    return CoreEmoji(url: m.url, size: m.size);
  }

  static CoreDynamicLiveModel _toCoreDynamicLiveModel(DynamicLiveModel m) {
    return CoreDynamicLiveModel(
      roomId: m.roomId,
      liveStatus: m.liveStatus,
      cover: m.cover,
      areaName: m.areaName,
      title: m.title,
      watchedShow: _mapNullable(m.watchedShow, _toCoreWatchedShow),
    );
  }

  static CoreDynamicLive2Model _toCoreDynamicLive2Model(DynamicLive2Model m) {
    return CoreDynamicLive2Model(
      badge: _mapNullable(m.badge, _toCoreBadge),
      cover: m.cover,
      descFirst: m.descFirst,
      id: m.id,
      liveState: m.liveState,
      title: m.title,
    );
  }

  static CoreDynamicNoneModel _toCoreDynamicNoneModel(DynamicNoneModel m) {
    return CoreDynamicNoneModel(tips: m.tips);
  }

  static CoreWatchedShow _toCoreWatchedShow(WatchedShow m) {
    return CoreWatchedShow(text: m.textLarge);
  }

  static CoreCommon _toCoreCommon(Common m) {
    return CoreCommon(
      cover: m.cover,
      title: m.title,
      desc: m.desc,
      jumpUrl: m.jumpUrl,
    );
  }

  static CoreMusic _toCoreMusic(Music m) {
    return CoreMusic(id: m.id, cover: m.cover, title: m.title, label: m.label);
  }

  static CoreMedialist _toCoreMedialist(Medialist m) {
    return CoreMedialist(
      id: m.id,
      cover: m.cover,
      title: m.title,
      subTitle: m.subTitle,
      jumpUrl: m.jumpUrl,
      badge: _mapNullable(m.badge, _toCoreBadge),
    );
  }

  static CoreSubscriptionNew _toCoreSubscriptionNew(SubscriptionNew m) {
    return CoreSubscriptionNew(
      liveRcmd: _mapNullable(m.liveRcmd, _toCoreLiveRcmd),
    );
  }

  static CoreLiveRcmd _toCoreLiveRcmd(LiveRcmd m) {
    return CoreLiveRcmd(
      content: _mapNullable(m.content, _toCoreLiveRcmdContent),
    );
  }

  static CoreLiveRcmdContent _toCoreLiveRcmdContent(LiveRcmdContent m) {
    return CoreLiveRcmdContent(
      livePlayInfo: _mapNullable(m.livePlayInfo, _toCoreLivePlayInfo),
    );
  }

  static CoreLivePlayInfo _toCoreLivePlayInfo(LivePlayInfo m) {
    return CoreLivePlayInfo(
      roomId: m.roomId,
      liveStatus: m.liveStatus,
      title: m.title,
      cover: m.cover,
      areaName: m.areaName,
      watchedShow: _mapNullable(m.watchedShow, _toCoreWatchedShow),
    );
  }

  static CoreDynamicTopicModel _toCoreDynamicTopicModel(DynamicTopicModel m) {
    return CoreDynamicTopicModel(id: m.id, name: m.name);
  }

  static CoreModuleInteraction _toCoreModuleInteraction(
    ModuleInteraction m,
  ) {
    return CoreModuleInteraction(
      items: _mapList(m.items, _toCoreModuleInteractionItem),
    );
  }

  static CoreModuleInteractionItem _toCoreModuleInteractionItem(
    ModuleInteractionItem m,
  ) {
    return CoreModuleInteractionItem(
      type: m.type,
      desc: _mapNullable(m.desc, _toCoreDynamicDescModel),
    );
  }

  static CoreModuleDispute _toCoreModuleDispute(ModuleDispute m) {
    return CoreModuleDispute(
      title: m.title,
      desc: m.desc,
      jumpUrl: m.jumpUrl,
    );
  }

  static CoreModuleFold _toCoreModuleFold(ModuleFold m) {
    return CoreModuleFold(
      ids: m.ids,
      statement: m.statement,
      users: _mapList(m.users, _toCoreOwner),
    );
  }

  static CoreModuleTop _toCoreModuleTop(ModuleTop m) {
    return CoreModuleTop(
      display: _mapNullable(m.display, _toCoreModuleTopDisplay),
    );
  }

  static CoreModuleTopDisplay _toCoreModuleTopDisplay(ModuleTopDisplay m) {
    return CoreModuleTopDisplay(
      album: _mapNullable(m.album, _toCoreModuleTopAlbum),
    );
  }

  static CoreModuleTopAlbum _toCoreModuleTopAlbum(ModuleTopAlbum m) {
    return CoreModuleTopAlbum(pics: _mapList(m.pics, _toCorePic));
  }

  static CorePic _toCorePic(Pic m) {
    return CorePic(src: m.url, height: m.height, width: m.width);
  }

  static CoreModuleCollection _toCoreModuleCollection(ModuleCollection m) {
    return CoreModuleCollection(
      count: m.count,
      id: m.id,
      name: m.name,
      title: m.title,
    );
  }

  static CoreModuleBlocked _toCoreModuleBlocked(ModuleBlocked m) {
    return CoreModuleBlocked(
      bgImg: _mapNullable(m.bgImg, _toCoreBgImg),
      blockedType: m.blockedType,
      button: _mapNullable(m.button, _toCoreButton),
      title: m.title,
      hintMessage: m.hintMessage,
      icon: _mapNullable(m.icon, _toCoreBgImg),
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
          _mapNullable(m.dynamicCardItem, _toCoreDynamicItemModel),
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
    dynamic id,
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
    return _mapState(result, _toCoreDynamicItemModel);
  }

  @override
  Future<LoadingState<void>> setTop({
    required Object dynamicId,
  }) =>
      DynamicsHttp.setTop(dynamicId: dynamicId);

  @override
  Future<LoadingState<void>> rmTop({
    required Object dynamicId,
  }) =>
      DynamicsHttp.rmTop(dynamicId: dynamicId);

  @override
  Future<LoadingState<CoreArticleInfoData>> articleInfo({
    required Object cvId,
  }) async {
    final result = await DynamicsHttp.articleInfo(cvId: cvId);
    return _mapState(result, _toCoreArticleInfoData);
  }

  @override
  Future<LoadingState<CoreArticleViewData>> articleView({
    required dynamic cvId,
  }) async {
    final result = await DynamicsHttp.articleView(cvId: cvId);
    return _mapState(result, _toCoreArticleViewData);
  }

  @override
  Future<LoadingState<CoreDynamicItemModel>> opusDetail({
    required dynamic opusId,
  }) async {
    final result = await DynamicsHttp.opusDetail(opusId: opusId);
    return _mapState(result, _toCoreDynamicItemModel);
  }

  @override
  Future<LoadingState<CoreVoteInfo>> voteInfo(dynamic voteId) async {
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
    required Object topicId,
  }) async {
    final result = await DynamicsHttp.topicTop(topicId: topicId);
    return _mapState(result, (data) => data != null ? _toCoreTopDetails(data) : null);
  }

  @override
  Future<LoadingState<CoreTopicCardList?>> topicFeed({
    required Object topicId,
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
    required Object topicId,
    required int sortBy,
  }) async {
    final result = await DynamicsHttp.topicFold(topicId: topicId, sortBy: sortBy);
    return _mapState(result, (data) => data != null ? _toCoreTopicCardList(data) : null);
  }

  @override
  Future<LoadingState<CoreArticleListData>> articleList({
    required Object id,
  }) async {
    final result = await DynamicsHttp.articleList(id: id);
    return _mapState(result, _toCoreArticleListData);
  }

  @override
  Future<LoadingState<CoreDynReserveData>> dynReserve({
    required Object? reserveId,
    required Object? curBtnStatus,
    required Object dynamicIdStr,
    required Object? reserveTotal,
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
  Future<LoadingState<List<CoreOpusPicModel>?>> dynPic(dynamic id) async {
    final result = await DynamicsHttp.dynPic(id);
    return _mapState(result, (data) => data?.map(_toCoreOpusPicModel).toList());
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
    required dynamic sid,
  }) async {
    final result = await DynamicsHttp.reserveInfo(sid: sid);
    return _mapState(result, _toCoreReserveInfoData);
  }

  @override
  Future<LoadingState<List<CoreFolloweeVote>?>> followeeVotes({
    required dynamic voteId,
  }) async {
    final result = await DynamicsHttp.followeeVotes(voteId: voteId);
    return _mapState(result, (data) => data?.map(_toCoreFolloweeVote).toList());
  }

  @override
  Future<LoadingState<void>> dynPrivatePubSetting({
    required Object dynId,
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
    required Object dynId,
    Object? repostDynId,
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
    required Object tribeId,
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
    required Object id,
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
