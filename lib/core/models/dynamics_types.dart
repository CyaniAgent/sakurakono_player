/// Core domain models for dynamics/feed operations.
///
/// These models are adapter-independent representations of Bilibili dynamic
/// feed data, used by [DynamicsRepository] and its implementations.
library;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Tab type for filtering the dynamic feed.
enum CoreDynamicsTabType {
  all('全部'),
  video('投稿'),
  pgc('番剧'),
  article('专栏'),
  up('UP'),
  ;

  final String label;
  const CoreDynamicsTabType(this.label);
}

/// Reply/comment visibility option.
enum CoreReplyOptionType {
  allow('允许评论'),
  close('关闭评论'),
  choose('精选评论'),
  ;

  final String title;
  const CoreReplyOptionType(this.title);
}

/// Opus type for gRPC opus detail requests.
enum CoreOpusType {
  dyn(0),
  article(1),
  note(2),
  word(3),
  repost(4),
  mangaEp(5),
  ;

  final int value;
  const CoreOpusType(this.value);
}

// ---------------------------------------------------------------------------
// Follow / Up list models
// ---------------------------------------------------------------------------

/// Model for the followed-up list response.
class CoreFollowUpModel {
  CoreLiveUsers? liveUsers;
  List<CoreUpItem>? upList;
  bool? hasMore;
  String? offset;

  CoreFollowUpModel({
    this.liveUsers,
    this.upList,
    this.hasMore,
    this.offset,
  });

  void addAllUpList(List<CoreUpItem> newList) {
    if (upList != null) {
      upList!.addAll(newList);
    } else {
      upList = newList;
    }
  }
}

/// A single followed UP (content creator).
class CoreUpItem {
  String? face;
  bool? hasUpdate;
  late int mid;
  String? uname;

  CoreUpItem({
    this.face,
    this.hasUpdate,
    required this.mid,
    this.uname,
  });
}

/// Live users section in the follow-up list.
class CoreLiveUsers {
  int? count;
  String? group;
  List<CoreLiveUserItem>? items;

  CoreLiveUsers({this.count, this.group, this.items});
}

/// A live user item in the follow-up list.
class CoreLiveUserItem extends CoreUpItem {
  bool? isReserveRecall;
  String? jumpUrl;
  int? roomId;
  String? title;

  CoreLiveUserItem({
    super.face,
    super.hasUpdate,
    required super.mid,
    super.uname,
    this.isReserveRecall,
    this.jumpUrl,
    this.roomId,
    this.title,
  });
}

// ---------------------------------------------------------------------------
// Dynamic feed models
// ---------------------------------------------------------------------------

/// Top-level model for a dynamic feed response.
class CoreDynamicsDataModel {
  bool? hasMore;
  List<CoreDynamicItemModel>? items;
  String? offset;
  int? total;
  bool? loadNext;

  CoreDynamicsDataModel({
    this.hasMore,
    this.items,
    this.offset,
    this.total,
    this.loadNext,
  });
}

/// A single dynamic item in the feed.
class CoreDynamicItemModel {
  CoreBasic? basic;
  dynamic idStr;
  CoreItemModulesModel? modules;
  CoreDynamicItemModel? orig;
  String? type;
  bool? visible;
  bool linkFolded = false;
  CoreFallback? fallback;

  CoreDynamicItemModel({
    this.basic,
    this.idStr,
    this.modules,
    this.orig,
    this.type,
    this.visible,
    this.linkFolded = false,
    this.fallback,
  });
}

class CoreFallback {
  String? id;

  CoreFallback({this.id});
}

class CoreBasic {
  String? commentIdStr;
  int? commentType;
  String? ridStr;

  CoreBasic({this.commentIdStr, this.commentType, this.ridStr});
}

/// Modules container for a dynamic item.
class CoreItemModulesModel {
  CoreModuleAuthorModel? moduleAuthor;
  CoreModuleStatModel? moduleStat;
  CoreModuleTag? moduleTag;
  CoreModuleDynamicModel? moduleDynamic;
  CoreModuleInteraction? moduleInteraction;
  CoreModuleDispute? moduleDispute;
  CoreModuleTop? moduleTop;
  CoreModuleCollection? moduleCollection;
  List<CoreModuleTag>? moduleExtend;
  List<CoreArticleContentModel>? moduleContent;
  CoreModuleBlocked? moduleBlocked;
  CoreModuleFold? moduleFold;

  CoreItemModulesModel({
    this.moduleAuthor,
    this.moduleStat,
    this.moduleTag,
    this.moduleDynamic,
    this.moduleInteraction,
    this.moduleDispute,
    this.moduleTop,
    this.moduleCollection,
    this.moduleExtend,
    this.moduleContent,
    this.moduleBlocked,
    this.moduleFold,
  });
}

/// Article content paragraph model.
class CoreArticleContentModel {
  // Placeholder — content is adapter-specific rich text.
  // Core consumers typically render via the adapter's CoreArticleContentModel.
  CoreArticleContentModel();
}

// ---------------------------------------------------------------------------
// Module sub-models
// ---------------------------------------------------------------------------

class CoreModuleAuthorModel {
  String? face;
  String? name;
  int? mid;
  String? pubAction;
  String? pubTime;
  int? pubTs;
  String? type;
  CoreDecorate? decorate;
  bool? isTop;
  String? badgeText;
  String? pendant;
  int? level;
  int? officialVerify;

  CoreModuleAuthorModel({
    this.face,
    this.name,
    this.mid,
    this.pubAction,
    this.pubTime,
    this.pubTs,
    this.type,
    this.decorate,
    this.isTop,
    this.badgeText,
    this.pendant,
    this.level,
    this.officialVerify,
  });
}

class CoreDecorate {
  String? cardUrl;
  CoreFan? fan;

  CoreDecorate({this.cardUrl, this.fan});
}

class CoreFan {
  String? color;
  String? numStr;

  CoreFan({this.color, this.numStr});
}

class CoreModuleStatModel {
  CoreDynamicStat? comment;
  CoreDynamicStat? forward;
  CoreDynamicStat? like;
  CoreDynamicStat? favorite;

  CoreModuleStatModel({
    this.comment,
    this.forward,
    this.like,
    this.favorite,
  });
}

class CoreDynamicStat {
  int? count;
  bool? status;

  CoreDynamicStat({this.count, this.status});
}

class CoreModuleTag {
  String? text;

  CoreModuleTag({this.text});
}

class CoreModuleDynamicModel {
  CoreDynamicAddModel? additional;
  CoreDynamicDescModel? desc;
  CoreDynamicMajorModel? major;
  CoreDynamicTopicModel? topic;

  CoreModuleDynamicModel({
    this.additional,
    this.desc,
    this.major,
    this.topic,
  });
}

class CoreDynamicDescModel {
  List<CoreRichTextNodeItem>? richTextNodes;
  String? text;

  CoreDynamicDescModel({this.richTextNodes, this.text});
}

class CoreRichTextNodeItem {
  CoreEmoji? emoji;
  String? origText;
  String? text;
  String? type;
  String? rid;
  List<CoreOpusPicModel>? pics;
  String? jumpUrl;

  CoreRichTextNodeItem({
    this.emoji,
    this.origText,
    this.text,
    this.type,
    this.rid,
    this.pics,
    this.jumpUrl,
  });
}

class CoreEmoji {
  String? url;
  num size = 1;

  CoreEmoji({this.url, this.size = 1});
}

class CoreDynamicMajorModel {
  CoreDynamicArchiveModel? archive;
  CoreDynamicArchiveModel? ugcSeason;
  CoreDynamicOpusModel? opus;
  CoreDynamicArchiveModel? pgc;
  CoreDynamicLiveModel? liveRcmd;
  CoreDynamicLive2Model? live;
  CoreDynamicNoneModel? none;
  String? type;
  CoreDynamicArchiveModel? courses;
  CoreCommon? common;
  CoreCommon? upowerCommon;
  CoreMusic? music;
  CoreModuleBlocked? blocked;
  CoreMedialist? medialist;
  CoreSubscriptionNew? subscriptionNew;

  CoreDynamicMajorModel({
    this.archive,
    this.ugcSeason,
    this.opus,
    this.pgc,
    this.liveRcmd,
    this.live,
    this.none,
    this.type,
    this.courses,
    this.common,
    this.upowerCommon,
    this.music,
    this.blocked,
    this.medialist,
    this.subscriptionNew,
  });
}

class CoreDynamicArchiveModel {
  int? id;
  int? aid;
  CoreBadge? badge;
  String? bvid;
  String? cover;
  String? durationText;
  String? jumpUrl;
  CoreStat? stat;
  String? title;
  int? type;
  int? epid;
  int? seasonId;

  CoreDynamicArchiveModel({
    this.id,
    this.aid,
    this.badge,
    this.bvid,
    this.cover,
    this.durationText,
    this.jumpUrl,
    this.stat,
    this.title,
    this.type,
    this.epid,
    this.seasonId,
  });
}

class CoreBadge {
  String? text;

  CoreBadge({this.text});
}

class CoreStat {
  String? danmu;
  String? play;

  CoreStat({this.danmu, this.play});
}

class CoreDynamicOpusModel {
  List<CoreOpusPicModel>? pics;
  CoreSummaryModel? summary;
  String? title;

  CoreDynamicOpusModel({this.pics, this.summary, this.title});
}

class CoreSummaryModel {
  List<CoreRichTextNodeItem>? richTextNodes;
  String? text;

  CoreSummaryModel({this.richTextNodes, this.text});
}

class CoreOpusPicModel {
  int? width;
  int? height;
  String? src;
  String? url;
  String? liveUrl;
  num? size;

  CoreOpusPicModel({
    this.width,
    this.height,
    this.src,
    this.url,
    this.liveUrl,
    this.size,
  });
}

class CoreDynamicLiveModel {
  int? roomId;
  int? liveStatus;
  String? cover;
  String? areaName;
  String? title;
  CoreWatchedShow? watchedShow;

  CoreDynamicLiveModel({
    this.roomId,
    this.liveStatus,
    this.cover,
    this.areaName,
    this.title,
    this.watchedShow,
  });
}

class CoreWatchedShow {
  String? text;
  String? icon;

  CoreWatchedShow({this.text, this.icon});
}

class CoreDynamicLive2Model {
  CoreBadge? badge;
  String? cover;
  String? descFirst;
  int? id;
  int? liveState;
  String? title;

  CoreDynamicLive2Model({
    this.badge,
    this.cover,
    this.descFirst,
    this.id,
    this.liveState,
    this.title,
  });
}

class CoreDynamicNoneModel {
  String? tips;

  CoreDynamicNoneModel({this.tips});
}

class CoreCommon {
  String? cover;
  String? title;
  String? titlePrefix;
  String? desc;
  String? jumpUrl;
  CoreBadge? badge;

  CoreCommon({this.cover, this.title, this.titlePrefix, this.desc, this.jumpUrl, this.badge});
}

class CoreMusic {
  int? id;
  String? cover;
  String? title;
  String? label;

  CoreMusic({this.id, this.cover, this.title, this.label});
}

class CoreMedialist {
  dynamic id;
  String? cover;
  String? title;
  String? subTitle;
  String? jumpUrl;
  CoreBadge? badge;

  CoreMedialist({this.id, this.cover, this.title, this.subTitle, this.jumpUrl, this.badge});
}

class CoreSubscriptionNew {
  CoreLiveRcmd? liveRcmd;

  CoreSubscriptionNew({this.liveRcmd});
}

class CoreLiveRcmd {
  CoreLiveRcmdContent? content;

  CoreLiveRcmd({this.content});
}

class CoreLiveRcmdContent {
  CoreLivePlayInfo? livePlayInfo;

  CoreLiveRcmdContent({this.livePlayInfo});
}

class CoreLivePlayInfo {
  int? roomId;
  int? liveStatus;
  String? title;
  String? cover;
  String? areaName;
  CoreWatchedShow? watchedShow;

  CoreLivePlayInfo({
    this.roomId,
    this.liveStatus,
    this.title,
    this.cover,
    this.areaName,
    this.watchedShow,
  });
}

class CoreDynamicTopicModel {
  int? id;
  String? name;

  CoreDynamicTopicModel({this.id, this.name});
}

class CoreDynamicAddModel {
  String? type;
  CoreVote? vote;
  CoreUgc? ugc;
  CoreReserve? reserve;
  CoreGood? goods;
  CoreUpowerLottery? upowerLottery;
  CoreAddCommon? common;
  CoreAddMatch? match;

  CoreDynamicAddModel({
    this.type,
    this.vote,
    this.ugc,
    this.reserve,
    this.goods,
    this.upowerLottery,
    this.common,
    this.match,
  });
}

class CoreVote {
  int? joinNum;
  int? voteId;
  String? title;

  CoreVote({this.joinNum, this.voteId, this.title});
}

class CoreUgc {
  String? cover;
  String? descSecond;
  String? jumpUrl;
  String? title;

  CoreUgc({this.cover, this.descSecond, this.jumpUrl, this.title});
}

class CoreReserve {
  CoreReserveBtn? button;
  CoreDesc? desc1;
  CoreDesc? desc2;
  CoreDesc? desc3;
  int? reserveTotal;
  int? rid;
  int? state;
  String? title;

  CoreReserve({
    this.button,
    this.desc1,
    this.desc2,
    this.desc3,
    this.reserveTotal,
    this.rid,
    this.state,
    this.title,
  });
}

class CoreReserveBtn {
  int? status;
  int? type;
  String? checkText;
  String? uncheckText;
  int? disable;
  String? jumpText;
  String? jumpUrl;

  CoreReserveBtn({
    this.status,
    this.type,
    this.checkText,
    this.uncheckText,
    this.disable,
    this.jumpText,
    this.jumpUrl,
  });
}

class CoreDesc {
  String? text;
  String? jumpUrl;

  CoreDesc({this.text, this.jumpUrl});
}

class CoreGood {
  List<CoreGoodItem>? items;

  CoreGood({this.items});
}

class CoreGoodItem {
  String? cover;
  String? jumpDesc;
  String? jumpUrl;
  String? name;
  String? price;

  CoreGoodItem({this.cover, this.jumpDesc, this.jumpUrl, this.name, this.price});
}

class CoreUpowerLottery {
  CoreButton? button;
  CoreDesc? desc;
  CoreHint? hint;
  String? jumpUrl;
  String? title;

  CoreUpowerLottery({this.button, this.desc, this.hint, this.jumpUrl, this.title});
}

class CoreHint {
  String? text;

  CoreHint({this.text});
}

class CoreAddCommon {
  CoreButton? button;
  String? cover;
  String? desc1;
  String? desc2;
  String? jumpUrl;
  String? title;

  CoreAddCommon({this.button, this.cover, this.desc1, this.desc2, this.jumpUrl, this.title});
}

class CoreAddMatch {
  CoreButton? button;
  String? jumpUrl;
  CoreMatchInfo? matchInfo;

  CoreAddMatch({this.button, this.jumpUrl, this.matchInfo});
}

class CoreMatchInfo {
  String? centerBottom;
  List? centerTop;
  CoreTTeam? leftTeam;
  CoreTTeam? rightTeam;
  dynamic subTitle;
  String? title;

  CoreMatchInfo({this.centerBottom, this.centerTop, this.leftTeam, this.rightTeam, this.subTitle, this.title});
}

class CoreTTeam {
  String? name;
  String? pic;

  CoreTTeam({this.name, this.pic});
}

class CoreButton {
  String? icon;
  String? jumpUrl;
  String? text;
  CoreJumpStyle? jumpStyle;
  CoreCheck? check;

  CoreButton({this.icon, this.jumpUrl, this.text, this.jumpStyle, this.check});
}

class CoreJumpStyle {
  String? text;

  CoreJumpStyle({this.text});
}

class CoreCheck {
  String? text;

  CoreCheck({this.text});
}

class CoreBgImg {
  String? imgDark;
  String? imgDay;

  CoreBgImg({this.imgDark, this.imgDay});
}

class CoreModuleInteraction {
  List<CoreModuleInteractionItem>? items;

  CoreModuleInteraction({this.items});
}

class CoreModuleInteractionItem {
  int? type;
  CoreDynamicDescModel? desc;

  CoreModuleInteractionItem({this.type, this.desc});
}

class CoreModuleDispute {
  String? title;
  String? desc;
  String? jumpUrl;

  CoreModuleDispute({this.title, this.desc, this.jumpUrl});
}

class CoreModuleFold {
  List<String>? ids;
  String? statement;
  List<CoreOwner>? users;

  CoreModuleFold({this.ids, this.statement, this.users});
}

class CoreModuleTop {
  CoreModuleTopDisplay? display;

  CoreModuleTop({this.display});
}

class CoreModuleTopDisplay {
  CoreModuleTopAlbum? album;

  CoreModuleTopDisplay({this.album});
}

class CoreModuleTopAlbum {
  List<CorePic>? pics;

  CoreModuleTopAlbum({this.pics});
}

class CorePic {
  String? src;
  double? height;
  double? width;

  CorePic({this.src, this.height, this.width});
}

class CoreModuleCollection {
  String? count;
  int? id;
  String? name;
  String? title;

  CoreModuleCollection({this.count, this.id, this.name, this.title});
}

class CoreModuleBlocked {
  CoreBgImg? bgImg;
  int? blockedType;
  CoreButton? button;
  String? title;
  String? hintMessage;
  CoreBgImg? icon;

  CoreModuleBlocked({this.bgImg, this.blockedType, this.button, this.title, this.hintMessage, this.icon});
}

// ---------------------------------------------------------------------------
// Vote models
// ---------------------------------------------------------------------------

class CoreSimpleVoteInfo {
  int? choiceCnt;
  int? defaultShare;
  String? desc;
  int? endTime;
  int? status;
  int? uid;
  int? voteId;
  int joinNum = 0;

  CoreSimpleVoteInfo({
    this.choiceCnt,
    this.defaultShare,
    this.desc,
    this.endTime,
    this.status,
    this.uid,
    this.voteId,
    this.joinNum = 0,
  });
}

class CoreVoteInfo extends CoreSimpleVoteInfo {
  String? title;
  int? ctime;
  List<int>? myVotes;
  List<CoreOption> options;
  int? optionsCnt;
  int? voterLevel;
  String? face;
  String? name;
  int? type;
  int? votePublisher;
  int? duration;
  int? onlyFansLevel;

  CoreVoteInfo({
    super.choiceCnt,
    super.defaultShare,
    super.desc,
    super.endTime,
    super.status,
    super.uid,
    super.voteId,
    super.joinNum = 0,
    this.title,
    this.ctime,
    this.myVotes,
    List<CoreOption>? options,
    this.optionsCnt,
    this.voterLevel,
    this.face,
    this.name,
    this.type,
    this.votePublisher,
    this.duration,
    this.onlyFansLevel,
  }) : options = options ?? <CoreOption>[];
}

class CoreOption {
  int? optIdx;
  String? optDesc;
  int cnt = 0;
  String? imgUrl;

  CoreOption({this.optDesc, this.imgUrl, this.optIdx, this.cnt = 0});
}

// ---------------------------------------------------------------------------
// Article models
// ---------------------------------------------------------------------------

class CoreArticleInfoData {
  bool? favorite;
  CoreArticleInfoStats? stats;
  String? title;
  List<String>? originImageUrls;

  CoreArticleInfoData({this.favorite, this.stats, this.title, this.originImageUrls});
}

class CoreArticleInfoStats {
  int? favorite;
  int? like;
  int? reply;
  int? share;

  CoreArticleInfoStats({this.favorite, this.like, this.reply, this.share});
}

class CoreArticleViewData {
  int? id;
  String? title;
  CoreAvatar? author;
  int? publishTime;
  List<String>? originImageUrls;
  int? type;
  String? content;
  String? dynIdStr;
  CoreArticleOpus? opus;
  List<CoreArticleOps>? ops;

  CoreArticleViewData({
    this.id,
    this.author,
    this.publishTime,
    this.originImageUrls,
    this.type,
    this.content,
    this.dynIdStr,
    this.opus,
    this.ops,
  });
}

class CoreAvatar {
  int? mid;
  String? name;
  String? face;

  CoreAvatar({this.mid, this.name, this.face});
}

class CoreArticleOpus {
  List<CoreArticleContentModel>? content;

  CoreArticleOpus({this.content});
}

class CoreArticleOps {
  dynamic insert;
  CoreAttributes? attributes;

  CoreArticleOps({this.insert, this.attributes});
}

class CoreAttributes {
  String? clazz;

  CoreAttributes({this.clazz});
}

class CoreArticleListData {
  CoreArticleListInfo? list;
  List<CoreArticleListItemModel>? articles;
  CoreOwner? author;

  CoreArticleListData({this.list, this.articles, this.author});
}

class CoreOwner {
  int? mid;
  String? name;
  String? face;

  CoreOwner({this.mid, this.name, this.face});
}

class CoreArticleListInfo {
  int? id;
  String? name;
  String? imageUrl;
  int? updateTime;
  int? words;
  int? read;
  int? articlesCount;

  CoreArticleListInfo({
    this.id,
    this.name,
    this.imageUrl,
    this.updateTime,
    this.words,
    this.read,
    this.articlesCount,
  });
}

class CoreArticleListItemModel {
  int? id;
  String? title;
  List<String>? imageUrls;
  String? summary;
  String? dynIdStr;
  CoreArticleListStats? stats;

  CoreArticleListItemModel({
    this.id,
    this.title,
    this.imageUrls,
    this.summary,
    this.dynIdStr,
    this.stats,
  });
}

class CoreArticleListStats {
  int? view;
  int? like;
  int? reply;

  CoreArticleListStats({this.view, this.like, this.reply});
}

// ---------------------------------------------------------------------------
// Bubble (tribe) models
// ---------------------------------------------------------------------------

class CoreBubbleData {
  CoreBaseInfo? baseInfo;
  CoreBubbleContent? content;
  CoreBubbleCategory? category;
  CoreSortInfo? sortInfo;

  CoreBubbleData({this.baseInfo, this.content, this.category, this.sortInfo});
}

class CoreBaseInfo {
  CoreTribeInfo? tribeInfo;
  bool? isJoined;

  CoreBaseInfo({this.tribeInfo, this.isJoined});
}

class CoreTribeInfo {
  String? id;
  String? title;
  String? subTitle;
  String? faceUrl;
  String? jumpUri;
  String? summary;

  CoreTribeInfo({this.id, this.title, this.subTitle, this.faceUrl, this.jumpUri, this.summary});
}

class CoreBubbleContent {
  String? count;
  List<CoreDynList>? dynList;

  CoreBubbleContent({this.count, this.dynList});
}

class CoreDynList {
  String? dynId;
  String? title;
  CoreMeta? meta;

  CoreDynList({this.dynId, this.title, this.meta});
}

class CoreMeta {
  String? author;
  String? timeText;
  String? replyCount;
  String? viewStat;

  CoreMeta({this.author, this.timeText, this.replyCount, this.viewStat});
}

class CoreBubbleCategory {
  List<CoreCategoryList>? categoryList;

  CoreBubbleCategory({this.categoryList});
}

class CoreCategoryList {
  String? id;
  String? name;
  int? type;

  CoreCategoryList({this.id, this.name, this.type});
}

class CoreSortInfo {
  bool? showSort;
  List<CoreSortItem>? sortItems;
  int? curSortType;

  CoreSortInfo({this.showSort, this.sortItems, this.curSortType});
}

class CoreSortItem {
  int? sortType;
  String? text;

  CoreSortItem({this.sortType, this.text});
}

// ---------------------------------------------------------------------------
// Reserve models
// ---------------------------------------------------------------------------

class CoreDynReserveData {
  int? finalBtnStatus;
  int? reserveUpdate;
  String? descUpdate;

  CoreDynReserveData({this.finalBtnStatus, this.reserveUpdate, this.descUpdate});
}

class CoreReserveInfoData {
  int? id;
  String? title;
  int? livePlanStartTime;

  CoreReserveInfoData({this.id, this.title, this.livePlanStartTime});
}

// ---------------------------------------------------------------------------
// Topic models
// ---------------------------------------------------------------------------

class CoreTopicItem {
  int id;
  String name;
  int view;
  int discuss;
  int fav;
  int like;
  String? description;
  bool? isFav;
  bool? isLike;

  CoreTopicItem({
    required this.id,
    required this.name,
    required this.view,
    required this.discuss,
    required this.fav,
    required this.like,
    this.description,
    this.isFav,
    this.isLike,
  });
}

class CoreTopDetails {
  CoreTopicItem? topicItem;
  CoreTopicCreator? topicCreator;

  CoreTopDetails({this.topicItem, this.topicCreator});
}

class CoreTopicCreator {
  int? uid;
  String? face;
  String? name;

  CoreTopicCreator({this.uid, this.face, this.name});
}

class CoreTopicCardList {
  bool? hasMore;
  List<CoreTopicCardItem>? items;
  String? offset;
  CoreTopicSortByConf? topicSortByConf;

  CoreTopicCardList({this.hasMore, this.items, this.offset, this.topicSortByConf});
}

class CoreTopicCardItem {
  CoreFoldCardItem? foldCardItem;
  CoreDynamicItemModel? dynamicCardItem;
  String? topicType;

  CoreTopicCardItem({this.foldCardItem, this.dynamicCardItem, this.topicType});
}

class CoreFoldCardItem {
  int? foldCount;
  String? foldDesc;

  CoreFoldCardItem({this.foldCount, this.foldDesc});
}

class CoreTopicSortByConf {
  List<CoreAllSortBy>? allSortBy;
  int? showSortBy;

  CoreTopicSortByConf({this.allSortBy, this.showSortBy});
}

class CoreAllSortBy {
  int? sortBy;
  String? sortName;

  CoreAllSortBy({this.sortBy, this.sortName});
}

// ---------------------------------------------------------------------------
// Mention models
// ---------------------------------------------------------------------------

class CoreMentionGroup {
  String? groupName;
  List<CoreMentionItem>? items;

  CoreMentionGroup({this.groupName, this.items});
}

class CoreMentionItem {
  String? face;
  int? fans;
  String? name;
  String? uid;

  CoreMentionItem({this.face, this.fans, this.name, this.uid});
}

// ---------------------------------------------------------------------------
// Reaction models
// ---------------------------------------------------------------------------

class CoreDynReactionData {
  bool? hasMore;
  List<CoreDynReactionItem>? items;
  String? offset;
  int total;

  CoreDynReactionData({this.hasMore, this.items, this.offset, required this.total});
}

class CoreDynReactionItem {
  String? action;
  String? face;
  String? mid;
  String? name;

  CoreDynReactionItem({this.action, this.face, this.mid, this.name});
}

// ---------------------------------------------------------------------------
// Followee vote models
// ---------------------------------------------------------------------------

class CoreFolloweeVote {
  int mid;
  String name;
  String face;
  List<int> votes;
  int ctime;

  CoreFolloweeVote({
    required this.mid,
    required this.name,
    required this.face,
    required this.votes,
    required this.ctime,
  });
}

// ---------------------------------------------------------------------------
// gRPC opus detail models
// ---------------------------------------------------------------------------

/// Core representation of a gRPC opus detail response.
class CoreOpusDetailResp {
  CoreOpusItem? opusItem;

  CoreOpusDetailResp({this.opusItem});
}

class CoreOpusItem {
  int? opusId;
  CoreOpusType? opusType;
  int? oid;
  List<CoreModule>? modules;
  CoreExtend? extend;

  CoreOpusItem({this.opusId, this.opusType, this.oid, this.modules, this.extend});
}

class CoreModule {
  // Placeholder — gRPC Module is complex; consumers use adapter-specific fields.
  CoreModule();
}

class CoreExtend {
  // Placeholder — gRPC Extend is complex.
  CoreExtend();
}