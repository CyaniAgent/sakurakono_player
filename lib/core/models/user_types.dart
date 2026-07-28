/// Core data types for the user repository.
///
/// These are pure data classes (no UI, no adapter dependencies) with
/// JSON serialization. They mirror the adapter-level models in the
/// Bilibili adapter but are free of Bilibili-specific UI and platform code.
library;

import 'package:skf/core/models/ui/multi_select_data.dart';

// ---------------------------------------------------------------------------
// CoreUserInfoData & CoreLevelInfo
// ---------------------------------------------------------------------------

class CoreUserInfoData {
  bool? isLogin;
  String? face;
  CoreLevelInfo? levelInfo;
  int? mid;
  double? money;
  int? scores;
  String? uname;
  int? vipDueDate;
  int? vipStatus;
  int? vipType;
  int? isSeniorMember;

  CoreUserInfoData({
    this.isLogin,
    this.face,
    this.levelInfo,
    this.mid,
    this.money,
    this.scores,
    this.uname,
    this.vipDueDate,
    this.vipStatus,
    this.vipType,
    this.isSeniorMember,
  });

  factory CoreUserInfoData.fromJson(Map<String, dynamic> json) => CoreUserInfoData(
        isLogin: json['isLogin'] ?? false,
        face: json['face'],
        levelInfo: json['level_info'] != null
            ? CoreLevelInfo.fromJson(json['level_info'] as Map<String, dynamic>)
            : null,
        mid: json['mid'],
        money: json['money'] is int
            ? (json['money'] as int).toDouble()
            : json['money'],
        scores: json['scores'],
        uname: json['uname'],
        vipDueDate: json['vipDueDate'],
        vipStatus: json['vipStatus'],
        vipType: json['vipType'],
        isSeniorMember: json['is_senior_member'],
      );
}

class CoreLevelInfo {
  int? currentLevel;
  int? currentMin;
  int? currentExp;
  int? nextExp;

  CoreLevelInfo({
    this.currentLevel,
    this.currentMin,
    this.currentExp,
    this.nextExp,
  });

  factory CoreLevelInfo.fromJson(Map<String, dynamic> json) => CoreLevelInfo(
        currentLevel: json['current_level'],
        currentMin: json['current_min'],
        currentExp: json['current_exp'],
        nextExp:
            json['current_level'] == 6 ? json['current_exp'] : json['next_exp'],
      );
}

// ---------------------------------------------------------------------------
// CoreUserStat
// ---------------------------------------------------------------------------

class CoreUserStat {
  final int? following;
  final int? follower;
  final int? dynamicCount;

  const CoreUserStat({
    this.following,
    this.follower,
    this.dynamicCount,
  });

  factory CoreUserStat.fromJson(Map<String, dynamic> json) => CoreUserStat(
        following: json['following'],
        follower: json['follower'],
        dynamicCount: json['dynamic_count'],
      );
}

// ---------------------------------------------------------------------------
// CoreCoinLogData & CoreCoinLogItem
// ---------------------------------------------------------------------------

class CoreCoinLogData {
  List<CoreCoinLogItem>? list;

  CoreCoinLogData({this.list});

  factory CoreCoinLogData.fromJson(Map<String, dynamic> json) => CoreCoinLogData(
        list: (json['list'] as List<dynamic>?)
            ?.map((e) => CoreCoinLogItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreCoinLogItem {
  final String time;
  final String delta;
  final String reason;

  const CoreCoinLogItem({
    required this.time,
    required this.delta,
    required this.reason,
  });

  factory CoreCoinLogItem.fromJson(Map<String, dynamic> json) => CoreCoinLogItem(
        time: json['time'],
        delta: (json['delta'] as num).toString(),
        reason: json['reason'],
      );
}

// ---------------------------------------------------------------------------
// CoreHistoryData, CoreHistoryTab, CoreHistoryItemModel & CoreHistory
// ---------------------------------------------------------------------------

class CoreHistoryData {
  List<CoreHistoryTab>? tab;
  List<CoreHistoryItemModel>? list;

  CoreHistoryData({this.tab, this.list});

  factory CoreHistoryData.fromJson(Map<String, dynamic> json) => CoreHistoryData(
        tab: (json['tab'] as List<dynamic>?)
            ?.map((e) => CoreHistoryTab.fromJson(e as Map<String, dynamic>))
            .toList(),
        list: (json['list'] as List<dynamic>?)
            ?.map((e) => CoreHistoryItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreHistoryTab {
  String? type;
  String? name;

  CoreHistoryTab({this.type, this.name});

  factory CoreHistoryTab.fromJson(Map<String, dynamic> json) => CoreHistoryTab(
        type: json['type'] as String?,
        name: json['name'] as String?,
      );
}

class CoreHistory {
  int? oid;
  int? epid;
  String? bvid;
  int? page;
  int? cid;
  String? business;

  CoreHistory({
    this.oid,
    this.epid,
    this.bvid,
    this.page,
    this.cid,
    this.business,
  });

  factory CoreHistory.fromJson(Map<String, dynamic> json) => CoreHistory(
        oid: json['oid'],
        epid: json['epid'],
        bvid: json['bvid'],
        page: json['page'],
        cid: json['cid'] == 0 ? null : json['cid'],
        business: json['business'],
      );
}

class CoreHistoryItemModel with MultiSelectData {
  String? title;
  String? cover;
  List<String>? covers;
  String? uri;
  late CoreHistory history;
  int? videos;
  String? authorName;
  int? authorMid;
  int? viewAt;
  int? progress;
  String? badge;
  String? showTitle;
  int? duration;
  int? isFav;
  int? kid;
  String? tagName;
  int? liveStatus;

  CoreHistoryItemModel({
    this.title,
    this.cover,
    this.covers,
    this.uri,
    required this.history,
    this.videos,
    this.authorName,
    this.authorMid,
    this.viewAt,
    this.progress,
    this.badge,
    this.showTitle,
    this.duration,
    this.isFav,
    this.kid,
    this.tagName,
    this.liveStatus,
  });

  factory CoreHistoryItemModel.fromJson(Map<String, dynamic> json) =>
      CoreHistoryItemModel(
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        covers: (json['covers'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        uri: json['uri'] as String?,
        history: json['history'] == null
            ? CoreHistory()
            : CoreHistory.fromJson(json['history'] as Map<String, dynamic>),
        videos: json['videos'] as int?,
        authorName: json['author_name'] as String?,
        authorMid: json['author_mid'] as int?,
        viewAt: json['view_at'] as int?,
        progress: json['progress'] as int?,
        badge: json['badge'] as String?,
        showTitle: json['show_title'] as String?,
        duration: json['duration'] as int?,
        isFav: json['is_fav'] as int?,
        kid: json['kid'] as int?,
        tagName: json['tag_name'] as String?,
        liveStatus: json['live_status'] as int?,
      );
}

// ---------------------------------------------------------------------------
// CoreLaterData & CoreLaterItemModel (with nested: CoreRights, CoreOwner, CoreStat, CoreBangumi,
// CoreSeason, CoreDimension)
// ---------------------------------------------------------------------------

class CoreLaterData {
  int? count;
  List<CoreLaterItemModel>? list;

  CoreLaterData({this.count, this.list});

  factory CoreLaterData.fromJson(Map<String, dynamic> json) => CoreLaterData(
        count: json['count'] as int?,
        list: (json['list'] as List<dynamic>?)
            ?.map((e) => CoreLaterItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreRights {
  int? isCooperation;

  CoreRights({this.isCooperation});

  factory CoreRights.fromJson(Map<String, dynamic> json) => CoreRights(
        isCooperation: json['is_cooperation'] as int?,
      );
}

class CoreOwner {
  int? mid;
  String? name;
  String? face;

  CoreOwner({this.mid, this.name, this.face});

  factory CoreOwner.fromJson(Map<String, dynamic> json) => CoreOwner(
        mid: json['mid'] is String
            ? int.tryParse(json['mid'] as String)
            : json['mid'] as int?,
        name: json['name'],
        face: json['face'],
      );
}

class CoreLaterItemModel with MultiSelectData {
  int? aid;
  String? pic;
  String? title;
  String? subtitle;
  int? pubdate;
  int? duration;
  String? redirectUrl;
  CoreRights? rights;
  CoreOwner? owner;
  CoreStat? stat;
  CoreBangumi? bangumi;
  int? cid;
  int? progress;
  String? bvid;
  bool? isPgc;
  String? pgcLabel;
  bool? isPugv;
  bool? isCharging;
  CoreDimension? dimension;

  CoreLaterItemModel({
    this.aid,
    this.pic,
    this.title,
    this.subtitle,
    this.pubdate,
    this.duration,
    this.redirectUrl,
    this.rights,
    this.owner,
    this.stat,
    this.bangumi,
    this.cid,
    this.progress,
    this.bvid,
    this.isPgc,
    this.pgcLabel,
    this.isPugv,
    this.isCharging,
    this.dimension,
  });

  factory CoreLaterItemModel.fromJson(Map<String, dynamic> json) =>
      CoreLaterItemModel(
        aid: json['aid'] as int?,
        pic: json['pic'] as String?,
        title: json['title'] as String?,
        pubdate: json['pubdate'] as int?,
        duration: json['duration'] as int?,
        redirectUrl: json['redirect_url'] as String?,
        rights: json['rights'] != null
            ? CoreRights.fromJson(json['rights'] as Map<String, dynamic>)
            : null,
        owner: json['owner'] != null
            ? CoreOwner.fromJson(json['owner'] as Map<String, dynamic>)
            : null,
        stat: json['stat'] != null
            ? CoreStat.fromJson(json['stat'] as Map<String, dynamic>)
            : null,
        bangumi: json['bangumi'] != null
            ? CoreBangumi.fromJson(json['bangumi'] as Map<String, dynamic>)
            : null,
        subtitle: json['bangumi'] == null
            ? null
            : (json['title'] as String).replaceFirst(
                '${(json['bangumi'] as Map)['season']['title']} ',
                '',
              ),
        cid: json['cid'] as int?,
        progress: json['progress'] as int?,
        bvid: json['bvid'] as String?,
        isPgc: json['is_pgc'] as bool?,
        pgcLabel: json['pgc_label'] == ''
            ? null
            : json['pgc_label'] as String?,
        isPugv: json['is_pugv'] as bool?,
        isCharging: json['charging_pay']?['level'] != null,
        dimension: json['dimension'] != null
            ? CoreDimension.fromJson(json['dimension'] as Map<String, dynamic>)
            : null,
      );
}

class CoreStat {
  int? view;
  int? danmaku;

  CoreStat({this.view, this.danmaku});

  factory CoreStat.fromJson(Map<String, dynamic> json) => CoreStat(
        view: json['view'] as int?,
        danmaku: json['danmaku'] as int?,
      );
}

class CoreBangumi {
  int? epId;
  CoreSeason? season;

  CoreBangumi({this.epId, this.season});

  factory CoreBangumi.fromJson(Map<String, dynamic> json) => CoreBangumi(
        epId: json['ep_id'] as int?,
        season: json['season'] != null
            ? CoreSeason.fromJson(json['season'] as Map<String, dynamic>)
            : null,
      );
}

class CoreSeason {
  String? title;

  CoreSeason({this.title});

  factory CoreSeason.fromJson(Map<String, dynamic> json) => CoreSeason(
        title: json['title'] as String?,
      );
}

class CoreDimension {
  int? width;
  int? height;

  CoreDimension({this.width, this.height});

  CoreDimension.fromJson(Map<String, dynamic> json) {
    if (json['rotate'] == 1) {
      width = json['height'] as int?;
      height = json['width'] as int?;
    } else {
      width = json['width'] as int?;
      height = json['height'] as int?;
    }
  }
}

// ---------------------------------------------------------------------------
// CoreLoginLogData & CoreLoginLogItem
// ---------------------------------------------------------------------------

class CoreLoginLogData {
  List<CoreLoginLogItem>? list;

  CoreLoginLogData({this.list});

  factory CoreLoginLogData.fromJson(Map<String, dynamic> json) => CoreLoginLogData(
        list: (json['list'] as List<dynamic>?)
            ?.map((e) => CoreLoginLogItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CoreLoginLogItem {
  final String ip;
  final String timeAt;
  final String geo;

  const CoreLoginLogItem({
    required this.ip,
    required this.timeAt,
    required this.geo,
  });

  factory CoreLoginLogItem.fromJson(Map<String, dynamic> json) => CoreLoginLogItem(
        ip: json['ip'] ?? '',
        timeAt: json['time_at'] ?? '',
        geo: json['geo'] ?? '',
      );
}

// ---------------------------------------------------------------------------
// CoreMediaListData, CoreMediaListItemModel, CoreCntInfo & Page
// ---------------------------------------------------------------------------

class CoreMediaListData {
  List<CoreMediaListItemModel> mediaList;

  CoreMediaListData({required this.mediaList});

  factory CoreMediaListData.fromJson(Map<String, dynamic> json) => CoreMediaListData(
        mediaList: (json['media_list'] as List<dynamic>?)
                ?.map((e) =>
                    CoreMediaListItemModel.fromJson(e as Map<String, dynamic>))
                .toList() ??
            <CoreMediaListItemModel>[],
      );
}

class CoreCntInfo {
  int? play;
  int? danmaku;

  CoreCntInfo({this.play, this.danmaku});

  factory CoreCntInfo.fromJson(Map<String, dynamic> json) => CoreCntInfo(
        play: json['play'] as int?,
        danmaku: json['danmaku'] as int?,
      );
}

class CoreMediaListItemModel {
  int? aid;
  String? intro;
  CoreCntInfo? cntInfo;
  int? duration;
  int? type;
  CoreOwner? upper;
  String? cover;
  String? title;
  String? bvid;
  String? badge;

  CoreMediaListItemModel({
    this.aid,
    this.intro,
    this.cntInfo,
    this.duration,
    this.type,
    this.upper,
    this.cover,
    this.title,
    this.bvid,
    this.badge,
  });

  factory CoreMediaListItemModel.fromJson(Map<String, dynamic> json) =>
      CoreMediaListItemModel(
        aid: json['id'] as int?,
        intro: json['intro'] as String?,
        cntInfo: json['cnt_info'] != null
            ? CoreCntInfo.fromJson(json['cnt_info'] as Map<String, dynamic>)
            : null,
        cover: json['cover'] as String?,
        duration: json['duration'] as int?,
        title: json['title'] as String?,
        type: json['type'] as int?,
        upper: json['upper'] != null
            ? CoreOwner.fromJson(json['upper'] as Map<String, dynamic>)
            : null,
        bvid: json['bv_id'] as String?,
        badge: json['badge']?['text'] as String?,
      );
}

// ---------------------------------------------------------------------------
// CoreRelationData
// ---------------------------------------------------------------------------

class CoreRelationData {
  int? attribute;
  int? mtime;
  List<int>? tag;
  int? special;

  CoreRelationData({
    this.attribute,
    this.mtime,
    this.tag,
    this.special,
  });

  factory CoreRelationData.fromJson(Map<String, dynamic> json) => CoreRelationData(
        attribute: json['attribute'] as int?,
        mtime: json['mtime'] as int?,
        tag: (json['tag'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList(),
        special: json['special'] as int?,
      );
}

// ---------------------------------------------------------------------------
// CoreSpaceSettingData, CorePrivacy & CoreSpaceSettingModel
// ---------------------------------------------------------------------------

class CoreSpaceSettingData {
  CorePrivacy? privacy;

  CoreSpaceSettingData({this.privacy});

  factory CoreSpaceSettingData.fromJson(Map<String, dynamic> json) =>
      CoreSpaceSettingData(
        privacy: json['privacy'] != null
            ? CorePrivacy.fromJson(json['privacy'] as Map<String, dynamic>)
            : null,
      );
}

class CoreSpaceSettingModel {
  String name;
  String key;
  int? value;
  bool isReverse;

  CoreSpaceSettingModel({
    required this.name,
    required this.key,
    required this.value,
    this.isReverse = false,
  });

  bool get boolVal => isReverse ? value == 0 : value == 1;
}

class CorePrivacy {
  List<CoreSpaceSettingModel> list1;
  List<CoreSpaceSettingModel> list2;
  List<CoreSpaceSettingModel> list3;

  CorePrivacy({
    required this.list1,
    required this.list2,
    required this.list3,
  });

  factory CorePrivacy.fromJson(Map<String, dynamic> json) => CorePrivacy(
        list1: [
          CoreSpaceSettingModel(
            name: '公开我的收藏',
            key: 'fav_video',
            value: json['fav_video'],
          ),
          CoreSpaceSettingModel(
            name: '公开我的追番追剧',
            key: 'bangumi',
            value: json['bangumi'],
          ),
          CoreSpaceSettingModel(
            name: '公开我的追漫',
            key: 'comic',
            value: json['comic'],
          ),
          CoreSpaceSettingModel(
            name: '公开最近投币的视频',
            key: 'coins_video',
            value: json['coins_video'],
          ),
          CoreSpaceSettingModel(
            name: '公开最近点赞的视频',
            key: 'likes_video',
            value: json['likes_video'],
          ),
          CoreSpaceSettingModel(
            name: '公开最近玩过的游戏',
            key: 'played_game',
            value: json['played_game'],
          ),
          CoreSpaceSettingModel(
            name: '公开拥有的粉丝装扮',
            key: 'dress_up',
            value: json['dress_up'],
          ),
          CoreSpaceSettingModel(
            name: '公开我的关注列表',
            key: 'disable_following',
            value: json['disable_following'],
            isReverse: true,
          ),
          CoreSpaceSettingModel(
            name: '公开我的粉丝列表',
            key: 'disable_show_fans',
            value: json['disable_show_fans'],
            isReverse: true,
          ),
        ],
        list2: [
          CoreSpaceSettingModel(
            name: '公开佩戴的粉丝勋章',
            key: 'close_space_medal',
            value: json['close_space_medal'],
            isReverse: true,
          ),
          CoreSpaceSettingModel(
            name: '勋章墙公开显示所有粉丝勋章',
            key: 'only_show_wearing',
            value: json['only_show_wearing'],
            isReverse: true,
          ),
          CoreSpaceSettingModel(
            name: '公开学校信息',
            key: 'disable_show_school',
            value: json['disable_show_school'],
            isReverse: true,
          ),
        ],
        list3: [
          CoreSpaceSettingModel(
            name: '投稿视频列表中展现直播回放',
            key: 'live_playback',
            value: json['live_playback'],
          ),
          CoreSpaceSettingModel(
            name: '投稿视频列表中展现包月充电专属视频',
            key: 'charge_video',
            value: json['charge_video'],
          ),
          CoreSpaceSettingModel(
            name: '投稿视频列表中展现课堂视频',
            key: 'lesson_video',
            value: json['lesson_video'],
          ),
        ],
      );
}

// ---------------------------------------------------------------------------
// CoreSubData & CoreSubItemModel
// ---------------------------------------------------------------------------

class CoreSubData {
  List<CoreSubItemModel>? list;
  bool? hasMore;

  CoreSubData({this.list, this.hasMore});

  factory CoreSubData.fromJson(Map<String, dynamic> json) => CoreSubData(
        list: (json['list'] as List<dynamic>?)
            ?.map((e) => CoreSubItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        hasMore: json['has_more'] as bool?,
      );
}

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

  factory CoreSubItemModel.fromJson(Map<String, dynamic> json) => CoreSubItemModel(
        id: json['id'] as int?,
        fid: json['fid'] as int?,
        mid: json['mid'] as int?,
        attr: json['attr'] as int?,
        title: json['title'] as String?,
        cover: json['cover'] as String?,
        upper: json['upper'] != null
            ? CoreOwner.fromJson(json['upper'] as Map<String, dynamic>)
            : null,
        coverType: json['cover_type'] as int?,
        intro: json['intro'] as String?,
        ctime: json['ctime'] as int?,
        mtime: json['mtime'] as int?,
        state: json['state'] as int?,
        favState: json['fav_state'] as int?,
        mediaCount: json['media_count'] as int?,
        viewCount: json['view_count'] as int?,
        type: json['type'] as int?,
        cntInfo: json['cnt_info'] != null
            ? CoreCntInfo.fromJson(json['cnt_info'])
            : null,
      );
}

// ---------------------------------------------------------------------------
// CoreUserRealNameData & CoreRejectPage
// ---------------------------------------------------------------------------

class CoreUserRealNameData {
  String? name;
  CoreRejectPage? rejectPage;

  CoreUserRealNameData({this.name, this.rejectPage});

  factory CoreUserRealNameData.fromJson(Map<String, dynamic> json) =>
      CoreUserRealNameData(
        name: json['name'] as String?,
        rejectPage: json['reject_page'] != null
            ? CoreRejectPage.fromJson(json['reject_page'] as Map<String, dynamic>)
            : null,
      );
}

class CoreRejectPage {
  String? title;
  String? text;

  CoreRejectPage({this.title, this.text});

  factory CoreRejectPage.fromJson(Map<String, dynamic> json) => CoreRejectPage(
        title: json['title'] as String?,
        text: json['text'] as String?,
      );
}

// ---------------------------------------------------------------------------
// CoreVideoTagItem
// ---------------------------------------------------------------------------

class CoreVideoTagItem {
  int? tagId;
  String? tagName;
  String? tagType;
  String? musicId;

  CoreVideoTagItem({
    this.tagId,
    this.tagName,
    this.tagType,
    this.musicId,
  });

  factory CoreVideoTagItem.fromJson(Map<String, dynamic> json) => CoreVideoTagItem(
        tagId: json['tag_id'],
        tagName: json['tag_name'],
        tagType: json['tag_type'],
        musicId: json['music_id'],
      );
}
