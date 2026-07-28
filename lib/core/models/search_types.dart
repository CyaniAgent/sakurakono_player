/// Core data types for the search repository.
///
/// Pure data classes with JSON serialization, free from adapter
/// and gRPC dependencies.
library;

// ignore_for_file: constant_identifier_names

// ---------------------------------------------------------------------------
// CoreSearchType
// ---------------------------------------------------------------------------

/// Search result type enum.
enum CoreSearchType {
  video('视频'),
  media_bangumi('番剧'),
  media_ft('影视'),
  live_room('直播间'),
  bili_user('用户'),
  article('专栏'),
  ;

  final String label;
  const CoreSearchType(this.label);
}

// ---------------------------------------------------------------------------
// CoreSearchSuggestModel / CoreSearchSuggestItem
// ---------------------------------------------------------------------------

/// Search suggestion result.
class CoreSearchSuggestModel {
  List<CoreSearchSuggestItem>? tag;

  CoreSearchSuggestModel({this.tag});

  factory CoreSearchSuggestModel.fromJson(Map<String, dynamic> json) =>
      CoreSearchSuggestModel(
        tag: (json['tag'] as List?)
            ?.map<CoreSearchSuggestItem>(
                (e) => CoreSearchSuggestItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// A single search suggestion item.
class CoreSearchSuggestItem {
  String? term;
  late String textRich;

  CoreSearchSuggestItem({this.term, required this.textRich});

  factory CoreSearchSuggestItem.fromJson(Map<String, dynamic> json) =>
      CoreSearchSuggestItem(
        term: json['term'] as String?,
        textRich: json['name'] as String,
      );
}

// ---------------------------------------------------------------------------
// CoreSearchNumData / CoreSearchAllData
// ---------------------------------------------------------------------------

/// Base class for search results with pagination.
class CoreSearchNumData<T> {
  int? numResults;
  List<T>? list;

  CoreSearchNumData({this.numResults, this.list});
}

/// Comprehensive search result (all types).
class CoreSearchAllData extends CoreSearchNumData {
  CoreSearchAllData({super.numResults, super.list});

  factory CoreSearchAllData.fromJson(Map<String, dynamic> json) =>
      CoreSearchAllData(
        numResults: (json['numResults'] as num?)?.toInt(),
      );
}

// ---------------------------------------------------------------------------
// CoreDimension
// ---------------------------------------------------------------------------

/// Video dimension (width/height).
class CoreDimension {
  int? width;
  int? height;

  bool? get cacheWidth {
    if (width != null && height != null) {
      return width! <= height!;
    }
    return null;
  }

  bool get isVertical =>
      width != null && height != null ? height! > width! : false;

  CoreDimension({this.width, this.height});

  factory CoreDimension.fromJson(Map<String, dynamic> json) {
    if (json['rotate'] == 1) {
      return CoreDimension(
        width: json['height'] as int?,
        height: json['width'] as int?,
      );
    }
    return CoreDimension(
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }

  @override
  String toString() => 'width: $width, height: $height';
}

// ---------------------------------------------------------------------------
// PGC info models (pure Dart, no adapter dependencies)
// ---------------------------------------------------------------------------

class CoreArea {
  String? name;
  CoreArea({this.name});
  factory CoreArea.fromJson(Map<String, dynamic> json) => CoreArea(
    name: json['name'] as String?,
  );
}

class CoreNewEp {
  String? desc;
  String? title;
  CoreNewEp({this.desc, this.title});
  factory CoreNewEp.fromJson(Map<String, dynamic> json) => CoreNewEp(
    desc: json['desc'] as String?,
    title: json['title'] as String?,
  );
}

class CorePublish {
  String? pubTimeShow;
  CorePublish({this.pubTimeShow});
  factory CorePublish.fromJson(Map<String, dynamic> json) => CorePublish(
    pubTimeShow: json['pub_time_show'] as String?,
  );
}

class CoreRating {
  double? score;
  CoreRating({this.score});
  factory CoreRating.fromJson(Map<String, dynamic> json) => CoreRating(
    score: (json['score'] as num?)?.toDouble(),
  );
}

class CoreUpInfo {
  String? avatar;
  int? mid;
  String? uname;
  CoreUpInfo({this.avatar, this.mid, this.uname});
  factory CoreUpInfo.fromJson(Map<String, dynamic> json) => CoreUpInfo(
    avatar: json['avatar'] as String?,
    mid: json['mid'] as int?,
    uname: json['uname'] as String?,
  );
}

class CoreUserProgress {
  int? lastEpId;
  CoreUserProgress({this.lastEpId});
  factory CoreUserProgress.fromJson(Map<String, dynamic> json) => CoreUserProgress(
    lastEpId: json['last_ep_id'] as int?,
  );
}

class CoreUserStatus {
  CoreUserProgress? progress;
  int? favored;
  CoreUserStatus({this.progress, this.favored});
  factory CoreUserStatus.fromJson(Map<String, dynamic> json) => CoreUserStatus(
    progress: json['progress'] != null
        ? CoreUserProgress.fromJson(json['progress'] as Map<String, dynamic>)
        : null,
    favored: json['favored'] as int?,
  );
}

class CoreCooperator {
  int? mid;
  String? avatar;
  String? nickName;
  String? role;
  CoreCooperator({this.mid, this.avatar, this.nickName, this.role});
  factory CoreCooperator.fromJson(Map<String, dynamic> json) => CoreCooperator(
    mid: json['mid'] as int?,
    avatar: json['avatar'] as String?,
    nickName: json['nick_name'] as String?,
    role: json['role'] as String?,
  );
}

class CoreBrief {
  List<CoreImg>? img;
  CoreBrief({this.img});
  factory CoreBrief.fromJson(Map<String, dynamic> json) => CoreBrief(
    img: (json['img'] as List?)?.map((e) => CoreImg.fromJson(e)).toList(),
  );
}

class CoreImg {
  num aspectRatio;
  String? url;
  CoreImg({required this.aspectRatio, this.url});
  factory CoreImg.fromJson(Map<String, dynamic> json) => CoreImg(
    aspectRatio: json['aspect_ratio'] ?? 1,
    url: json['url'] as String?,
  );
}

/// PGC episode item (standalone, no adapter inheritance).
class CorePgcEpisodeItem {
  int? id;
  int? aid;
  int? cid;
  int? epId;
  String? bvid;
  String? badge;
  String? title;
  String? cover;
  CoreDimension? dimension;
  int? duration;
  String? from;
  String? link;
  String? longTitle;
  int? pubTime;
  String? shareCopy;
  String? shareUrl;
  String? showTitle;
  int? play;

  CorePgcEpisodeItem({
    this.id,
    this.aid,
    this.cid,
    this.epId,
    this.bvid,
    this.badge,
    this.title,
    this.cover,
    this.dimension,
    this.duration,
    this.from,
    this.link,
    this.longTitle,
    this.pubTime,
    this.shareCopy,
    this.shareUrl,
    this.showTitle,
    this.play,
  });

  factory CorePgcEpisodeItem.fromJson(Map<String, dynamic> json) =>
      CorePgcEpisodeItem(
        aid: json['aid'] as int?,
        badge: json['badge'] as String?,
        bvid: json['bvid'] as String?,
        cid: json['cid'] as int?,
        cover: json['cover'] as String?,
        dimension: json['dimension'] != null
            ? CoreDimension.fromJson(json['dimension'] as Map<String, dynamic>)
            : null,
        duration: json['duration'] as int?,
        epId: json['ep_id'] as int?,
        from: json['from'] as String?,
        id: json['id'] as int?,
        link: json['link'] as String?,
        longTitle: json['long_title'] as String?,
        pubTime: json['pub_time'] ?? json['release_date'],
        shareCopy: json['share_copy'] as String?,
        shareUrl: json['share_url'] as String?,
        showTitle: json['show_title'] as String?,
        title: json['title'] as String?,
        play: json['play'] as int?,
      );
}

/// PGC stat (standalone, no adapter inheritance).
class CorePgcStat {
  int? coin;
  int? danmaku;
  int? favorite;
  int? like;
  int? reply;
  int? share;
  int? view;

  CorePgcStat({
    this.coin,
    this.danmaku,
    this.favorite,
    this.like,
    this.reply,
    this.share,
    this.view,
  });

  factory CorePgcStat.fromJson(Map<String, dynamic> json) => CorePgcStat(
    coin: json['coins'] ?? 0,
    danmaku: json['danmakus'],
    favorite: json['favorite'] ?? 0,
    like: json['likes'] ?? 0,
    reply: json['reply'],
    share: json['share'],
    view: json['views'],
  );
}

class CoreSection {
  List<CorePgcEpisodeItem>? episodes;
  CoreSection({this.episodes});
  factory CoreSection.fromJson(Map<String, dynamic> json) => CoreSection(
    episodes: (json['episodes'] as List<dynamic>?)
        ?.map(
            (e) => CorePgcEpisodeItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// PGC info model (bangumi/anime).
class CorePgcInfoModel {
  String? actors;
  List<CoreArea>? areas;
  String? cover;
  List<CorePgcEpisodeItem>? episodes;
  String? evaluate;
  int? mediaId;
  CoreNewEp? newEp;
  CorePublish? publish;
  CoreRating? rating;
  int? seasonId;
  String? seasonTitle;
  List<CoreSection>? section;
  CorePgcStat? stat;
  String? subtitle;
  String? title;
  int? type;
  CoreUpInfo? upInfo;
  CoreUserStatus? userStatus;
  List<CoreCooperator>? cooperators;
  CoreBrief? brief;

  CorePgcInfoModel({
    this.actors,
    this.areas,
    this.cover,
    this.episodes,
    this.evaluate,
    this.mediaId,
    this.newEp,
    this.publish,
    this.rating,
    this.seasonId,
    this.seasonTitle,
    this.section,
    this.stat,
    this.subtitle,
    this.title,
    this.type,
    this.upInfo,
    this.userStatus,
    this.cooperators,
    this.brief,
  });

  factory CorePgcInfoModel.fromJson(Map<String, dynamic> json) => CorePgcInfoModel(
    actors: json['actors'] as String?,
    areas: (json['areas'] as List<dynamic>?)
        ?.map((e) => CoreArea.fromJson(e as Map<String, dynamic>))
        .toList(),
    cover: json['cover'] as String?,
    episodes: (json['episodes'] as List<dynamic>?)
        ?.map((e) => CorePgcEpisodeItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    evaluate: json['evaluate'] as String?,
    mediaId: json['media_id'] as int?,
    newEp: json['new_ep'] != null
        ? CoreNewEp.fromJson(json['new_ep'] as Map<String, dynamic>)
        : null,
    publish: json['publish'] != null
        ? CorePublish.fromJson(json['publish'] as Map<String, dynamic>)
        : null,
    rating: json['rating'] != null
        ? CoreRating.fromJson(json['rating'] as Map<String, dynamic>)
        : null,
    seasonId: json['season_id'] as int?,
    seasonTitle: json['season_title'] as String?,
    section: (json['section'] as List<dynamic>?)
        ?.map((e) => CoreSection.fromJson(e as Map<String, dynamic>))
        .toList(),
    stat: json['stat'] != null
        ? CorePgcStat.fromJson(json['stat'] as Map<String, dynamic>)
        : null,
    subtitle: json['subtitle'] as String?,
    title: json['title'] as String?,
    type: json['type'] as int?,
    upInfo: json['up_info'] != null
        ? CoreUpInfo.fromJson(json['up_info'] as Map<String, dynamic>)
        : null,
    userStatus: json['user_status'] != null
        ? CoreUserStatus.fromJson(json['user_status'] as Map<String, dynamic>)
        : null,
    cooperators: (json['cooperators'] as List?)
        ?.map((e) => CoreCooperator.fromJson(e))
        .toList(),
    brief: json['brief'] != null
        ? CoreBrief.fromJson(json['brief'] as Map<String, dynamic>)
        : null,
  );
}

// ---------------------------------------------------------------------------
// Trending / Recommend
// ---------------------------------------------------------------------------

class CoreSearchTrendingItemModel {
  String? keyword;
  String? icon;
  bool? showLiveIcon;
  String? recommendReason;

  CoreSearchTrendingItemModel({
    this.keyword,
    this.icon,
    this.showLiveIcon,
    this.recommendReason,
  });

  factory CoreSearchTrendingItemModel.fromJson(Map<String, dynamic> json) =>
      CoreSearchTrendingItemModel(
        keyword: json['keyword'] as String?,
        icon: json['icon'] as String?,
        showLiveIcon: json['show_live_icon'] as bool?,
        recommendReason: (json['recommend_reason'] as String?)
            ?.replaceFirst('·', ' '),
      );
}

class CoreSearchRcmdData {
  List<CoreSearchTrendingItemModel>? list;

  CoreSearchRcmdData({this.list});

  factory CoreSearchRcmdData.fromJson(Map<String, dynamic> json) =>
      CoreSearchRcmdData(
        list: (json['list'] as List<dynamic>?)
            ?.map(
              (e) =>
                  CoreSearchTrendingItemModel.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );
}

class CoreSearchTrendingData extends CoreSearchRcmdData {
  late int topCount;

  CoreSearchTrendingData({super.list}) {
    topCount = 0;
  }

  factory CoreSearchTrendingData.fromJson(
    Map<String, dynamic> json, {
    bool needsTop = false,
  }) {
    final data = CoreSearchTrendingData(
      list: (json['list'] as List<dynamic>?)
          ?.map((e) => CoreSearchTrendingItemModel.fromJson(e))
          .toList(),
    );
    if (needsTop) {
      final topList = (json['top_list'] as List<dynamic>?)
          ?.map((e) => CoreSearchTrendingItemModel.fromJson(e))
          .toList();
      data.topCount = topList?.length ?? 0;
      if (topList != null && topList.isNotEmpty) {
        if (data.list != null) {
          data.list!.insertAll(0, topList);
        } else {
          data.list = topList;
        }
      }
    }
    return data;
  }
}

// ---------------------------------------------------------------------------
// Topic Pub Search
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

  factory CoreTopicItem.fromJson(Map<String, dynamic> json) => CoreTopicItem(
    id: json['id'],
    name: json['name'],
    view: json['view'] ?? 0,
    discuss: json['discuss'] ?? 0,
    fav: json['fav'] ?? 0,
    like: json['like'] ?? 0,
    description: json['description'] as String?,
    isFav: json['is_fav'] as bool?,
    isLike: json['is_like'] as bool?,
  );
}

class CorePageInfo {
  bool? hasMore;

  CorePageInfo({this.hasMore});

  factory CorePageInfo.fromJson(Map<String, dynamic> json) => CorePageInfo(
    hasMore: json['has_more'] as bool?,
  );
}

class CoreTopicPubSearchData {
  List<CoreTopicItem>? topicItems;
  CorePageInfo? pageInfo;

  CoreTopicPubSearchData({this.topicItems, this.pageInfo});

  factory CoreTopicPubSearchData.fromJson(Map<String, dynamic> json) =>
      CoreTopicPubSearchData(
        topicItems: (json['topic_items'] as List<dynamic>?)
            ?.map((e) => CoreTopicItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        pageInfo: json['page_info'] != null
            ? CorePageInfo.fromJson(json['page_info'] as Map<String, dynamic>)
            : null,
      );
}
