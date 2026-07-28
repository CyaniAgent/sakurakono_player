/// Favorite/collection types used by [FavRepository].
///
/// These are core data classes decoupled from any adapter implementation.
library;

import 'package:skf/core/models/ui/multi_select_data.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Ordering options for favorite folder queries.
enum CoreFavOrderType {
  mtime('最近收藏'),
  view('最多播放'),
  pubtime('最近投稿'),
  ;

  final String label;

  const CoreFavOrderType(this.label);
}

// ---------------------------------------------------------------------------
// Shared value types
// ---------------------------------------------------------------------------

/// Minimal content-owner info.
class CoreOwner {
  int? mid;
  String? name;
  String? face;

  CoreOwner({this.mid, this.name, this.face});

  factory CoreOwner.fromJson(Map<String, dynamic> json) => CoreOwner(
        mid: json['mid'] as int?,
        name: json['name'] as String?,
        face: json['face'] as String?,
      );
}

/// Play / danmaku counts.
class CoreCntInfo {
  int? play;
  int? danmaku;

  CoreCntInfo({this.play, this.danmaku});

  factory CoreCntInfo.fromJson(Map<String, dynamic> json) => CoreCntInfo(
        play: json['play'] as int?,
        danmaku: json['danmaku'] as int?,
      );
}

// ---------------------------------------------------------------------------
// FavFolder
// ---------------------------------------------------------------------------

class CoreFavFolderInfo {
  int id;
  int? fid;
  int mid;
  int attr;
  String title;
  String cover;
  CoreOwner? upper;
  String? intro;
  int? favState;
  int mediaCount;

  CoreFavFolderInfo({
    this.id = 0,
    this.fid,
    this.mid = 0,
    this.attr = -1,
    this.title = '',
    this.cover = '',
    this.upper,
    this.intro,
    this.favState,
    this.mediaCount = 0,
  });

  factory CoreFavFolderInfo.fromJson(Map<String, dynamic> json) =>
      CoreFavFolderInfo(
        id: json['id'] as int? ?? 0,
        fid: json['fid'] as int?,
        mid: json['mid'] as int? ?? 0,
        attr: json['attr'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        cover: json['cover'] as String? ?? '',
        upper: json['upper'] == null
            ? null
            : CoreOwner.fromJson(json['upper'] as Map<String, dynamic>),
        intro: json['intro'] as String?,
        favState: json['fav_state'] as int?,
        mediaCount: json['media_count'] as int? ?? 0,
      );
}

class CoreFavFolderData {
  int? count;
  List<CoreFavFolderInfo>? list;
  bool? hasMore;

  CoreFavFolderData({this.count, this.list, this.hasMore});

  factory CoreFavFolderData.fromJson(Map<String, dynamic> json) =>
      CoreFavFolderData(
        count: json['count'] as int?,
        list: (json['list'] as List<dynamic>?)
            ?.map(
                (e) => CoreFavFolderInfo.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: json['has_more'] as bool?,
      );
}

// ---------------------------------------------------------------------------
// FavDetail
// ---------------------------------------------------------------------------

class CoreOgv {
  String? typeName;
  int? seasonId;

  CoreOgv({this.typeName, this.seasonId});

  factory CoreOgv.fromJson(Map<String, dynamic> json) => CoreOgv(
        typeName: json['type_name'],
        seasonId: json['season_id'],
      );
}

class CoreUgc {
  int? firstCid;

  CoreUgc({this.firstCid});

  factory CoreUgc.fromJson(Map<String, dynamic> json) => CoreUgc(
        firstCid: json['first_cid'] as int?,
      );
}

class CoreFavDetailItemModel with MultiSelectData {
  int? id;
  int? type;
  String? title;
  String? cover;
  String? intro;
  int? duration;
  CoreOwner? upper;
  int? attr;
  CoreCntInfo? cntInfo;
  int? favTime;
  String? bvid;
  CoreOgv? ogv;
  CoreUgc? ugc;

  CoreFavDetailItemModel({
    this.id,
    this.type,
    this.title,
    this.cover,
    this.intro,
    this.duration,
    this.upper,
    this.attr,
    this.cntInfo,
    this.favTime,
    this.bvid,
    this.ogv,
    this.ugc,
  });

  factory CoreFavDetailItemModel.fromJson(Map<String, dynamic> json) =>
      CoreFavDetailItemModel(
        id: json['id'] as int?,
        type: json['type'] as int?,
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        intro: json['intro'] as String?,
        duration: json['duration'] as int?,
        upper: json['upper'] == null
            ? null
            : CoreOwner.fromJson(json['upper'] as Map<String, dynamic>),
        attr: json['attr'] as int?,
        cntInfo: json['cnt_info'] == null
            ? null
            : CoreCntInfo.fromJson(json['cnt_info'] as Map<String, dynamic>),
        favTime: json['fav_time'] as int?,
        bvid: json['bvid'] ?? json['bv_id'],
        ogv: json['ogv'] == null ? null : CoreOgv.fromJson(json['ogv']),
        ugc: json['ugc'] == null
            ? null
            : CoreUgc.fromJson(json['ugc'] as Map<String, dynamic>),
      );
}

class CoreFavDetailData {
  CoreFavFolderInfo? info;
  List<CoreFavDetailItemModel>? medias;
  bool? hasMore;

  CoreFavDetailData({this.info, this.medias, this.hasMore});

  factory CoreFavDetailData.fromJson(Map<String, dynamic> json) =>
      CoreFavDetailData(
        info: json['info'] == null
            ? null
            : CoreFavFolderInfo.fromJson(json['info'] as Map<String, dynamic>),
        medias: (json['medias'] as List<dynamic>?)
            ?.map((e) =>
                CoreFavDetailItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: json['has_more'] as bool?,
      );
}

// ---------------------------------------------------------------------------
// FavArticle
// ---------------------------------------------------------------------------

class CoreAuthor {
  String? name;

  CoreAuthor({this.name});

  factory CoreAuthor.fromJson(Map<String, dynamic> json) => CoreAuthor(
        name: json['name'] as String?,
      );
}

class CoreCover {
  String? url;

  CoreCover({this.url});

  factory CoreCover.fromJson(Map<String, dynamic> json) => CoreCover(
        url: json['url'] as String?,
      );
}

class CoreStat {
  String? like;

  CoreStat({this.like});

  factory CoreStat.fromJson(Map<String, dynamic> json) => CoreStat(
        like: json['like'] as String?,
      );
}

class CoreFavArticleItemModel {
  String? opusId;
  String? content;
  CoreAuthor? author;
  CoreCover? cover;
  CoreStat? stat;
  String? pubTime;

  CoreFavArticleItemModel({
    this.opusId,
    this.content,
    this.author,
    this.cover,
    this.stat,
    this.pubTime,
  });

  factory CoreFavArticleItemModel.fromJson(Map<String, dynamic> json) =>
      CoreFavArticleItemModel(
        opusId: json['opus_id'] as String?,
        content: json['content'] as String?,
        author: json['author'] == null
            ? null
            : CoreAuthor.fromJson(json['author'] as Map<String, dynamic>),
        cover: json['cover'] == null
            ? null
            : CoreCover.fromJson(json['cover'] as Map<String, dynamic>),
        stat: json['stat'] == null
            ? null
            : CoreStat.fromJson(json['stat'] as Map<String, dynamic>),
        pubTime: json['pub_time'] as String?,
      );
}

class CoreFavArticleData {
  List<CoreFavArticleItemModel>? items;
  bool? hasMore;

  CoreFavArticleData({this.items, this.hasMore});

  factory CoreFavArticleData.fromJson(Map<String, dynamic> json) =>
      CoreFavArticleData(
        items: (json['items'] as List<dynamic>?)
            ?.map((e) =>
                CoreFavArticleItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: json['has_more'] as bool?,
      );
}

// ---------------------------------------------------------------------------
// FavNote
// ---------------------------------------------------------------------------

class CoreFavNoteItemModel with MultiSelectData {
  String? webUrl;
  String? title;
  String? summary;
  String? message;
  String? pic;
  dynamic cvid;
  dynamic noteId;

  CoreFavNoteItemModel({
    this.webUrl,
    this.title,
    this.summary,
    this.message,
    this.pic,
    this.cvid,
    this.noteId,
  });

  factory CoreFavNoteItemModel.fromJson(Map<String, dynamic> json) =>
      CoreFavNoteItemModel(
        webUrl: json['web_url'] as String?,
        title: json['title'] as String?,
        summary: json['summary'] as String?,
        message: json['message'] as String?,
        pic: json['arc']?['pic'] as String?,
        cvid: json['cvid'],
        noteId: json['note_id'],
      );
}

// ---------------------------------------------------------------------------
// FavPgc
// ---------------------------------------------------------------------------

class CoreNewEp {
  String? indexShow;

  CoreNewEp({this.indexShow});

  factory CoreNewEp.fromJson(Map<String, dynamic> json) => CoreNewEp(
        indexShow: json['index_show'] as String?,
      );
}

class CoreFavPgcItemModel with MultiSelectData {
  int? seasonId;
  String? title;
  String? cover;
  int? isFinish;
  String? badge;
  CoreNewEp? newEp;
  String? renewalTime;
  String? progress;

  CoreFavPgcItemModel({
    this.seasonId,
    this.title,
    this.cover,
    this.isFinish,
    this.badge,
    this.newEp,
    this.renewalTime,
    this.progress,
  });

  factory CoreFavPgcItemModel.fromJson(Map<String, dynamic> json) =>
      CoreFavPgcItemModel(
        seasonId: json['season_id'] as int?,
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        isFinish: json['is_finish'] as int?,
        badge: json['badge'] as String?,
        newEp: json['new_ep'] == null
            ? null
            : CoreNewEp.fromJson(json['new_ep'] as Map<String, dynamic>),
        renewalTime: json['renewal_time'] as String?,
        progress: json['progress'] == '' ? null : json['progress'],
      );
}

class CoreFavPgcData {
  List<CoreFavPgcItemModel>? list;
  int? total;

  CoreFavPgcData({this.list, this.total});

  factory CoreFavPgcData.fromJson(Map<String, dynamic> json) => CoreFavPgcData(
        list: (json['list'] as List<dynamic>?)
            ?.map(
                (e) => CoreFavPgcItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int?,
      );
}

// ---------------------------------------------------------------------------
// FavTopic
// ---------------------------------------------------------------------------

class CoreFavTopicItem {
  int? id;
  String? name;

  CoreFavTopicItem({this.id, this.name});

  factory CoreFavTopicItem.fromJson(Map<String, dynamic> json) =>
      CoreFavTopicItem(
        id: json['id'] as int?,
        name: json['name'] as String?,
      );
}

class CorePageInfo {
  int? total;

  CorePageInfo({this.total});

  factory CorePageInfo.fromJson(Map<String, dynamic> json) => CorePageInfo(
        total: json['total'] as int?,
      );
}

class CoreTopicList {
  List<CoreFavTopicItem>? topicItems;
  CorePageInfo? pageInfo;

  CoreTopicList({this.topicItems, this.pageInfo});

  factory CoreTopicList.fromJson(Map<String, dynamic> json) => CoreTopicList(
        topicItems: (json['topic_items'] as List<dynamic>?)
            ?.map(
                (e) => CoreFavTopicItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        pageInfo: json['page_info'] == null
            ? null
            : CorePageInfo.fromJson(json['page_info'] as Map<String, dynamic>),
      );
}

class CoreFavTopicData {
  CoreTopicList? topicList;

  CoreFavTopicData({this.topicList});

  factory CoreFavTopicData.fromJson(Map<String, dynamic> json) =>
      CoreFavTopicData(
        topicList: json['topic_list'] == null
            ? null
            : CoreTopicList.fromJson(
                json['topic_list'] as Map<String, dynamic>),
      );
}

// ---------------------------------------------------------------------------
// SpaceCheese
// ---------------------------------------------------------------------------

class CoreSpaceCheeseItem {
  String? cover;
  List<String>? marks;
  int? seasonId;
  String? status;
  String? title;
  String? ctime;

  CoreSpaceCheeseItem({
    this.cover,
    this.marks,
    this.seasonId,
    this.status,
    this.title,
    this.ctime,
  });

  factory CoreSpaceCheeseItem.fromJson(Map<String, dynamic> json) =>
      CoreSpaceCheeseItem(
        cover: json['cover'] as String?,
        marks: (json['marks'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        seasonId: json['season_id'] as int?,
        status: json['status'] as String?,
        title: json['title'] as String?,
        ctime: json['ctime'] as String?,
      );
}

class CoreSpaceCheesePage {
  bool? next;

  CoreSpaceCheesePage({this.next});

  factory CoreSpaceCheesePage.fromJson(Map<String, dynamic> json) =>
      CoreSpaceCheesePage(
        next: json['next'] as bool?,
      );
}

class CoreSpaceCheeseData {
  List<CoreSpaceCheeseItem>? items;
  CoreSpaceCheesePage? page;

  CoreSpaceCheeseData({this.items, this.page});

  factory CoreSpaceCheeseData.fromJson(Map<String, dynamic> json) =>
      CoreSpaceCheeseData(
        items: (json['items'] as List<dynamic>?)
            ?.map(
                (e) => CoreSpaceCheeseItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        page: json['page'] == null
            ? null
            : CoreSpaceCheesePage.fromJson(
                json['page'] as Map<String, dynamic>),
      );
}

// ---------------------------------------------------------------------------
// Sub (subscription)
// ---------------------------------------------------------------------------

class CoreSubItemModel {
  int? id;
  int? fid;
  int? mid;
  int? attr;
  String? title;
  String? cover;
  CoreOwner? upper;
  int? coverType;
  String? intro;
  int? ctime;
  int? mtime;
  int? state;
  int? favState;
  int? mediaCount;
  int? viewCount;
  int? type;
  CoreCntInfo? cntInfo;

  CoreSubItemModel({
    this.id,
    this.fid,
    this.mid,
    this.attr,
    this.title,
    this.cover,
    this.upper,
    this.coverType,
    this.intro,
    this.ctime,
    this.mtime,
    this.state,
    this.favState,
    this.mediaCount,
    this.viewCount,
    this.type,
    this.cntInfo,
  });

  factory CoreSubItemModel.fromJson(Map<String, dynamic> json) =>
      CoreSubItemModel(
        id: json['id'] as int?,
        fid: json['fid'] as int?,
        mid: json['mid'] as int?,
        attr: json['attr'] as int?,
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        upper: json['upper'] == null
            ? null
            : CoreOwner.fromJson(json['upper'] as Map<String, dynamic>),
        coverType: json['cover_type'] as int?,
        intro: json['intro'] as String?,
        ctime: json['ctime'] as int?,
        mtime: json['mtime'] as int?,
        state: json['state'] as int?,
        favState: json['fav_state'] as int?,
        mediaCount: json['media_count'] as int?,
        viewCount: json['view_count'] as int?,
        type: json['type'] as int?,
        cntInfo: json['cnt_info'] == null
            ? null
            : CoreCntInfo.fromJson(json['cnt_info']),
      );
}

class CoreSubDetailItemModel {
  int? id;
  String? title;
  String? cover;
  int? duration;
  int? pubtime;
  String? bvid;
  CoreCntInfo? cntInfo;

  CoreSubDetailItemModel({
    this.id,
    this.title,
    this.cover,
    this.duration,
    this.pubtime,
    this.bvid,
    this.cntInfo,
  });

  factory CoreSubDetailItemModel.fromJson(Map<String, dynamic> json) =>
      CoreSubDetailItemModel(
        id: json['id'] as int?,
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        duration: json['duration'] as int?,
        pubtime: json['pubtime'] as int?,
        bvid: json['bvid'] as String?,
        cntInfo: json['cnt_info'] == null
            ? null
            : CoreCntInfo.fromJson(json['cnt_info'] as Map<String, dynamic>),
      );
}

class CoreSubDetailData {
  CoreSubItemModel? info;
  List<CoreSubDetailItemModel>? medias;

  CoreSubDetailData({this.info, this.medias});

  factory CoreSubDetailData.fromJson(Map<String, dynamic> json) =>
      CoreSubDetailData(
        info: json['info'] == null
            ? null
            : CoreSubItemModel.fromJson(json['info'] as Map<String, dynamic>),
        medias: (json['medias'] as List<dynamic>?)
            ?.map((e) =>
                CoreSubDetailItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// SpaceFav
// ---------------------------------------------------------------------------

class CoreSpaceFavItemModel extends CoreSubItemModel {
  int? mediaId;
  int? count;
  int? isPublic;

  CoreSpaceFavItemModel({
    super.id,
    this.mediaId,
    this.count,
    this.isPublic,
    super.fid,
    super.mid,
    super.attr,
    super.title,
    super.cover,
    super.upper,
    super.coverType,
    super.intro,
    super.ctime,
    super.mtime,
    super.state,
    super.favState,
    super.mediaCount,
    super.viewCount,
    super.type,
  });

  factory CoreSpaceFavItemModel.fromJson(Map<String, dynamic> json) =>
      CoreSpaceFavItemModel(
        id: json['id'] as int?,
        mediaId: json['media_id'] as int?,
        count: json['count'] as int?,
        isPublic: json['is_public'] as int?,
        fid: json['fid'] as int?,
        mid: json['mid'] as int?,
        attr: json['attr'] as int?,
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        upper: json['upper'] == null
            ? null
            : CoreOwner.fromJson(json['upper'] as Map<String, dynamic>),
        coverType: json['cover_type'] as int?,
        intro: json['intro'] as String?,
        ctime: json['ctime'] as int?,
        mtime: json['mtime'] as int?,
        state: json['state'] as int?,
        favState: json['fav_state'] as int?,
        mediaCount: json['media_count'] as int?,
        viewCount: json['view_count'] as int?,
        type: json['type'] as int?,
      );
}

class CoreMediaListResponse {
  int? count;
  List<CoreSpaceFavItemModel>? list;

  CoreMediaListResponse({this.count, this.list});

  factory CoreMediaListResponse.fromJson(Map<String, dynamic> json) {
    return CoreMediaListResponse(
      count: json['count'] as int?,
      list: (json['list'] as List<dynamic>?)
          ?.map(
              (e) => CoreSpaceFavItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CoreSpaceFavData {
  int? id;
  String? name;
  CoreMediaListResponse? mediaListResponse;

  CoreSpaceFavData({this.id, this.name, this.mediaListResponse});

  factory CoreSpaceFavData.fromJson(Map<String, dynamic> json) =>
      CoreSpaceFavData(
        id: json['id'] as int?,
        name: json['name'] as String?,
        mediaListResponse: json['mediaListResponse'] == null
            ? null
            : CoreMediaListResponse.fromJson(
                json['mediaListResponse'] as Map<String, dynamic>,
              ),
      );
}
