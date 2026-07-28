/// Core video types — adapter-independent models for [VideoRepository].
library;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Video content type (UGC, PGC, PUGV).
enum CoreVideoType {
  ugc(type: 3, replyType: 1),
  pgc(type: 4, replyType: 1),
  pugv(type: 10, replyType: 33),
  ;

  final int type;
  final int replyType;
  const CoreVideoType({required this.type, this.replyType = 1});
}

// ---------------------------------------------------------------------------
// CoreReplyInfo (pure-Dart wrapper for gRPC CoreReplyInfo)
// ---------------------------------------------------------------------------

/// Pure-Dart wrapper for gRPC [CoreReplyInfo] — uses [int] instead of [Int64].
class CoreReplyInfo {
  final int? id;
  final int? oid;
  final int? type;
  final int? mid;
  final int? root;
  final int? parent;
  final int? dialog;
  final int? like;
  final int? ctime;
  final int? count;
  final Map<String, dynamic>? content;
  final Map<String, dynamic>? member;
  final Map<String, dynamic>? replyControl;
  final String? trackInfo;

  CoreReplyInfo({
    this.id,
    this.oid,
    this.type,
    this.mid,
    this.root,
    this.parent,
    this.dialog,
    this.like,
    this.ctime,
    this.count,
    this.content,
    this.member,
    this.replyControl,
    this.trackInfo,
  });

  factory CoreReplyInfo.fromJson(Map<String, dynamic> json) => CoreReplyInfo(
        id: json['id'] as int?,
        oid: json['oid'] as int?,
        type: json['type'] as int?,
        mid: json['mid'] as int?,
        root: json['root'] as int?,
        parent: json['parent'] as int?,
        dialog: json['dialog'] as int?,
        like: json['like'] as int?,
        ctime: json['ctime'] as int?,
        count: json['count'] as int?,
        content: json['content'] as Map<String, dynamic>?,
        member: json['member'] as Map<String, dynamic>?,
        replyControl: json['replyControl'] as Map<String, dynamic>?,
        trackInfo: json['trackInfo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (oid != null) 'oid': oid,
        if (type != null) 'type': type,
        if (mid != null) 'mid': mid,
        if (root != null) 'root': root,
        if (parent != null) 'parent': parent,
        if (dialog != null) 'dialog': dialog,
        if (like != null) 'like': like,
        if (ctime != null) 'ctime': ctime,
        if (count != null) 'count': count,
        if (content != null) 'content': content,
        if (member != null) 'member': member,
        if (replyControl != null) 'replyControl': replyControl,
        if (trackInfo != null) 'trackInfo': trackInfo,
      };
}

// ---------------------------------------------------------------------------
// Base video item models
// ---------------------------------------------------------------------------

/// Base video item with common fields.
class CoreBaseVideoItemModel {
  int? aid;
  String? bvid;
  int? cid;
  String? cover;
  String? title;
  int? duration;
  int? pubdate;
  String? desc;
  int? progress;
  String? redirectUrl;
  String? badge;
  bool isFollowed = false;
  Map<String, dynamic>? owner;
  Map<String, dynamic>? stat;
  Map<String, dynamic>? dimension;

  CoreBaseVideoItemModel({
    this.aid,
    this.bvid,
    this.cid,
    this.cover,
    this.title,
    this.duration,
    this.pubdate,
    this.desc,
    this.progress,
    this.redirectUrl,
    this.badge,
    this.isFollowed = false,
    this.owner,
    this.stat,
    this.dimension,
  });
}

/// Base recommended video item.
class CoreBaseRcmdVideoItemModel extends CoreBaseVideoItemModel {
  String? goto;
  String? uri;
  String? rcmdReason;
  int? param;
  String? pgcBadge;

  CoreBaseRcmdVideoItemModel({
    super.aid,
    super.bvid,
    super.cid,
    super.cover,
    super.title,
    super.duration,
    super.pubdate,
    super.desc,
    super.progress,
    super.redirectUrl,
    super.badge,
    super.isFollowed,
    super.owner,
    super.stat,
    super.dimension,
    this.goto,
    this.uri,
    this.rcmdReason,
    this.param,
    this.pgcBadge,
  });
}

/// Web-end recommended video item.
class CoreRcmdVideoItemModel extends CoreBaseRcmdVideoItemModel {
  CoreRcmdVideoItemModel({
    super.aid,
    super.bvid,
    super.cid,
    super.cover,
    super.title,
    super.duration,
    super.pubdate,
    super.owner,
    super.stat,
    super.isFollowed,
    super.goto,
    super.uri,
    super.rcmdReason,
  });

  factory CoreRcmdVideoItemModel.fromJson(Map<String, dynamic> json) =>
      CoreRcmdVideoItemModel(
        aid: json['id'],
        bvid: json['bvid'],
        cid: json['cid'],
        cover: json['pic'],
        title: json['title'],
        duration: json['duration'],
        pubdate: json['pubdate'],
        owner: json['owner'] as Map<String, dynamic>?,
        stat: json['stat'] as Map<String, dynamic>?,
        isFollowed: json['is_followed'] == 1,
        goto: json['goto'],
        uri: json['uri'],
        rcmdReason: json['rcmd_reason']?['content'],
      );
}

/// App-end recommended video item.
class CoreRcmdVideoItemAppModel extends CoreBaseRcmdVideoItemModel {
  String? talkBack;
  String? cardType;
  Map<String, dynamic>? threePoint;

  CoreRcmdVideoItemAppModel({
    super.aid,
    super.bvid,
    super.cid,
    super.cover,
    super.title,
    super.duration,
    super.pubdate,
    super.desc,
    super.owner,
    super.stat,
    super.isFollowed,
    super.goto,
    super.uri,
    super.rcmdReason,
    super.param,
    super.pgcBadge,
    this.talkBack,
    this.cardType,
    this.threePoint,
  });

  factory CoreRcmdVideoItemAppModel.fromJson(Map<String, dynamic> json) =>
      CoreRcmdVideoItemAppModel(
        aid: json['player_args']?['aid'] ?? int.tryParse(json['param'] ?? '0'),
        bvid: json['bvid'],
        cid: json['player_args']?['cid'],
        cover: json['cover'],
        title: json['title'],
        duration: json['player_args']?['duration'] ?? 0,
        owner: json['args'] != null
            ? {
                'name': json['goto'] == 'av'
                    ? (json['args']?['up_name'] ?? '')
                    : (json['desc_button']?['text'] ?? ''),
                'mid': json['args']?['up_id'] ?? 0,
              }
            : null,
        stat: {
          'view': json['cover_left_text_1'] ?? '',
          'danmu': json['cover_left_text_2'] ?? '',
        },
        isFollowed: const {'已关注', '新关注'}.contains(json['rcmd_reason']),
        goto: json['goto'],
        uri: json['uri'],
        rcmdReason:
            const {'已关注', '新关注'}.contains(json['rcmd_reason']) ? null : json['rcmd_reason'],
        param: int.parse(json['param']),
        pgcBadge: json['goto'] == 'bangumi' ? json['cover_right_text'] : null,
        talkBack: json['talk_back'],
        cardType: json['card_type'],
        threePoint: json['three_point_v2'] != null
            ? {'dislikeReasons': json['three_point_v2']}
            : null,
        desc: json['desc'],
      );
}

/// Hot / popular video item.
class CoreHotVideoItemModel extends CoreBaseVideoItemModel {
  int? videos;
  int? tid;
  String? tname;
  int? copyright;
  int? ctime;
  int? state;
  String? firstFrame;
  String? pubLocation;

  CoreHotVideoItemModel({
    super.aid,
    super.bvid,
    super.cid,
    super.cover,
    super.title,
    super.duration,
    super.pubdate,
    super.desc,
    super.progress,
    super.redirectUrl,
    super.badge,
    super.owner,
    super.stat,
    super.dimension,
    this.videos,
    this.tid,
    this.tname,
    this.copyright,
    this.ctime,
    this.state,
    this.firstFrame,
    this.pubLocation,
  });

  factory CoreHotVideoItemModel.fromJson(Map<String, dynamic> json) =>
      CoreHotVideoItemModel(
        aid: json['aid'],
        bvid: json['bvid'],
        cid: json['cid'],
        cover: json['pic'],
        title: json['title'],
        duration: json['duration'],
        pubdate: json['pubdate'],
        desc: json['desc'],
        owner: json['owner'] as Map<String, dynamic>?,
        stat: json['stat'] as Map<String, dynamic>?,
        dimension: json['dimension'] as Map<String, dynamic>?,
        videos: json['videos'],
        tid: json['tid'],
        tname: json['tname'],
        copyright: json['copyright'],
        ctime: json['ctime'],
        state: json['state'],
        firstFrame: json['first_frame'],
        pubLocation: json['pub_location'],
        redirectUrl: json['redirect_url'],
        progress: json['progress'],
        badge: json['pgc_label'],
      );
}

// ---------------------------------------------------------------------------
// Video play URL
// ---------------------------------------------------------------------------

class CorePlayUrlModel {
  String? from;
  String? result;
  String? message;
  int? quality;
  String? format;
  int? timeLength;
  String? acceptFormat;
  List<dynamic>? acceptDesc;
  List<int>? acceptQuality;
  int? videoCodecid;
  String? seekParam;
  String? seekType;
  Map<String, dynamic>? dash;
  List<Map<String, dynamic>>? durl;
  List<Map<String, dynamic>>? supportFormats;
  Map<String, dynamic>? volume;
  int? lastPlayTime;
  int? lastPlayCid;
  String? curLanguage;
  Map<String, dynamic>? language;
  List<Map<String, dynamic>>? clipInfoList;

  CorePlayUrlModel({
    this.from,
    this.result,
    this.message,
    this.quality,
    this.format,
    this.timeLength,
    this.acceptFormat,
    this.acceptDesc,
    this.acceptQuality,
    this.videoCodecid,
    this.seekParam,
    this.seekType,
    this.dash,
    this.durl,
    this.supportFormats,
    this.volume,
    this.lastPlayTime,
    this.lastPlayCid,
    this.curLanguage,
    this.language,
    this.clipInfoList,
  });

  factory CorePlayUrlModel.fromJson(Map<String, dynamic> json) => CorePlayUrlModel(
        from: json['from'],
        result: json['result'],
        message: json['message'],
        quality: json['quality'],
        format: json['format'],
        timeLength: json['timelength'],
        acceptFormat: json['accept_format'],
        acceptDesc: json['accept_description'],
        acceptQuality: (json['accept_quality'] as List?)?.cast<int>(),
        videoCodecid: json['video_codecid'],
        seekParam: json['seek_param'],
        seekType: json['seek_type'],
        dash: json['dash'] as Map<String, dynamic>?,
        durl: (json['durl'] as List?)?.cast<Map<String, dynamic>>(),
        supportFormats:
            (json['support_formats'] as List?)?.cast<Map<String, dynamic>>(),
        volume: json['volume'] as Map<String, dynamic>?,
        lastPlayTime: json['last_play_time'],
        lastPlayCid: json['last_play_cid'],
        curLanguage: json['cur_language'],
        language: json['language'] as Map<String, dynamic>?,
        clipInfoList:
            (json['clip_info_list'] as List?)?.cast<Map<String, dynamic>>(),
      );
}

// ---------------------------------------------------------------------------
// PGC / Triple
// ---------------------------------------------------------------------------

class CorePgcLCF {
  num? coinNumber;
  int? favorite;
  int? isOriginal;
  int? like;

  CorePgcLCF({this.coinNumber, this.favorite, this.isOriginal, this.like});

  factory CorePgcLCF.fromJson(Map<String, dynamic> json) => CorePgcLCF(
        coinNumber: json['coin_number'],
        favorite: json['favorite'],
        isOriginal: json['is_original'],
        like: json['like'],
      );
}

class CorePgcTriple {
  num? coin;
  num? coinNumber;
  int? favorite;
  int? fmid;
  int? follow;
  int? like;
  bool? relation;

  CorePgcTriple({
    this.coin,
    this.coinNumber,
    this.favorite,
    this.fmid,
    this.follow,
    this.like,
    this.relation,
  });

  factory CorePgcTriple.fromJson(Map<String, dynamic> json) => CorePgcTriple(
        coin: json['coin'],
        coinNumber: json['coin_number'],
        favorite: json['favorite'],
        fmid: json['fmid'],
        follow: json['follow'],
        like: json['like'],
        relation: json['relation'],
      );
}

class CoreUgcTriple {
  bool? like;
  bool? coin;
  bool? fav;
  int? multiply;

  CoreUgcTriple({this.like, this.coin, this.fav, this.multiply});

  factory CoreUgcTriple.fromJson(Map<String, dynamic> json) => CoreUgcTriple(
        like: json['like'],
        coin: json['coin'],
        fav: json['fav'],
        multiply: json['multiply'],
      );
}

// ---------------------------------------------------------------------------
// Video detail
// ---------------------------------------------------------------------------

class CoreVideoDetailData {
  String? bvid;
  int? aid;
  int? videos;
  int? copyright;
  String? pic;
  String? title;
  int? pubdate;
  int? ctime;
  String? desc;
  List<Map<String, dynamic>>? descV2;
  int? duration;
  Map<String, dynamic>? rights;
  Map<String, dynamic>? owner;
  Map<String, dynamic>? stat;
  Map<String, dynamic>? argueInfo;
  int? cid;
  Map<String, dynamic>? dimension;
  int? seasonId;
  bool? isUpowerExclusive;
  List<Map<String, dynamic>>? pages;
  Map<String, dynamic>? ugcSeason;
  List<Map<String, dynamic>>? staff;
  String? redirectUrl;

  CoreVideoDetailData({
    this.bvid,
    this.aid,
    this.videos,
    this.copyright,
    this.pic,
    this.title,
    this.pubdate,
    this.ctime,
    this.desc,
    this.descV2,
    this.duration,
    this.rights,
    this.owner,
    this.stat,
    this.argueInfo,
    this.cid,
    this.dimension,
    this.seasonId,
    this.isUpowerExclusive,
    this.pages,
    this.ugcSeason,
    this.staff,
    this.redirectUrl,
  });

  factory CoreVideoDetailData.fromJson(Map<String, dynamic> json) =>
      CoreVideoDetailData(
        bvid: json['bvid'] as String?,
        aid: json['aid'] as int?,
        videos: json['videos'] as int?,
        copyright: json['copyright'] as int?,
        pic: json['pic'] as String?,
        title: json['title'] as String?,
        pubdate: json['pubdate'] as int?,
        ctime: json['ctime'] as int?,
        desc: json['desc'] as String?,
        descV2: (json['desc_v2'] as List?)?.cast<Map<String, dynamic>>(),
        duration: json['duration'] as int?,
        rights: json['rights'] as Map<String, dynamic>?,
        owner: json['owner'] as Map<String, dynamic>?,
        stat: json['stat'] as Map<String, dynamic>?,
        argueInfo: json['argue_info'] as Map<String, dynamic>?,
        cid: json['cid'] as int?,
        dimension: json['dimension'] as Map<String, dynamic>?,
        seasonId: json['season_id'] as int?,
        isUpowerExclusive: json['is_upower_exclusive'] as bool?,
        pages: (json['pages'] as List?)?.cast<Map<String, dynamic>>(),
        ugcSeason: json['ugc_season'] as Map<String, dynamic>?,
        staff: (json['staff'] as List?)?.cast<Map<String, dynamic>>(),
        redirectUrl: json['redirect_url'] as String?,
      );
}

class CoreVideoRelation {
  bool? attention;
  bool? favorite;
  bool? seasonFav;
  bool? like;
  bool? dislike;
  num? coin;

  CoreVideoRelation({
    this.attention,
    this.favorite,
    this.seasonFav,
    this.like,
    this.dislike,
    this.coin,
  });

  factory CoreVideoRelation.fromJson(Map<String, dynamic> json) => CoreVideoRelation(
        attention: json['attention'] as bool?,
        favorite: json['favorite'] as bool?,
        seasonFav: json['season_fav'] as bool?,
        like: json['like'] as bool?,
        dislike: json['dislike'] as bool?,
        coin: json['coin'] as num?,
      );
}

// ---------------------------------------------------------------------------
// AI Conclusion
// ---------------------------------------------------------------------------

class CoreAiConclusionData {
  Map<String, dynamic>? modelResult;

  CoreAiConclusionData({this.modelResult});

  /// Convenience getter for partOutline stored inside [modelResult].
  dynamic get partOutline => modelResult?['part_outline'];

  factory CoreAiConclusionData.fromJson(Map<String, dynamic> json) =>
      CoreAiConclusionData(
        modelResult: json['model_result'] as Map<String, dynamic>?,
      );
}

// ---------------------------------------------------------------------------
// Play info
// ---------------------------------------------------------------------------

class CorePlayInfoData {
  int? lastPlayCid;
  Map<String, dynamic>? subtitle;
  List<Map<String, dynamic>>? viewPoints;
  Map<String, dynamic>? interaction;

  CorePlayInfoData({
    this.lastPlayCid,
    this.subtitle,
    this.viewPoints,
    this.interaction,
  });

  factory CorePlayInfoData.fromJson(Map<String, dynamic> json) => CorePlayInfoData(
        lastPlayCid: json['last_play_cid'] as int?,
        subtitle: json['subtitle'] as Map<String, dynamic>?,
        viewPoints:
            (json['view_points'] as List?)?.cast<Map<String, dynamic>>(),
        interaction: json['interaction'] as Map<String, dynamic>?,
      );
}

// ---------------------------------------------------------------------------
// Video shot (thumbnail sprite)
// ---------------------------------------------------------------------------

class CoreVideoShotData {
  String? pvdata;
  int imgXLen;
  int imgYLen;
  double imgXSize;
  double imgYSize;
  List<String> image;
  List<int> index;

  CoreVideoShotData({
    this.pvdata,
    required this.imgXLen,
    required this.imgYLen,
    required this.imgXSize,
    required this.imgYSize,
    required this.image,
    required this.index,
  });

  factory CoreVideoShotData.fromJson(Map<String, dynamic> json) => CoreVideoShotData(
        pvdata: json['pvdata'],
        imgXLen: json['img_x_len'],
        imgYLen: json['img_y_len'],
        imgXSize: (json['img_x_size'] as num).toDouble(),
        imgYSize: (json['img_y_size'] as num).toDouble(),
        image: (json['image'] as List).cast<String>(),
        index: (json['index'] as List).cast<int>(),
      );
}

// ---------------------------------------------------------------------------
// Video note list
// ---------------------------------------------------------------------------

class CoreVideoNoteData {
  List<Map<String, dynamic>>? list;
  Map<String, dynamic>? page;

  CoreVideoNoteData({this.list, this.page});

  factory CoreVideoNoteData.fromJson(Map<String, dynamic> json) => CoreVideoNoteData(
        list: (json['list'] as List?)?.cast<Map<String, dynamic>>(),
        page: json['page'] as Map<String, dynamic>?,
      );
}

// ---------------------------------------------------------------------------
// Popular series
// ---------------------------------------------------------------------------

class CorePopularSeriesListItem {
  int? number;
  String? name;

  CorePopularSeriesListItem({this.number, this.name});

  factory CorePopularSeriesListItem.fromJson(Map<String, dynamic> json) =>
      CorePopularSeriesListItem(
        number: json['number'] as int?,
        name: json['name'] as String?,
      );
}

class CorePopularSeriesOneData {
  Map<String, dynamic>? config;
  String? reminder;
  List<CoreHotVideoItemModel>? list;

  CorePopularSeriesOneData({this.config, this.reminder, this.list});

  factory CorePopularSeriesOneData.fromJson(Map<String, dynamic> json) =>
      CorePopularSeriesOneData(
        config: json['config'] as Map<String, dynamic>?,
        reminder: json['reminder'] as String?,
        list: (json['list'] as List?)
            ?.map((e) => CoreHotVideoItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CorePopularPreciousData {
  int? mediaId;
  List<CoreHotVideoItemModel>? list;

  CorePopularPreciousData({this.mediaId, this.list});

  factory CorePopularPreciousData.fromJson(Map<String, dynamic> json) =>
      CorePopularPreciousData(
        mediaId: json['media_id'] as int?,
        list: (json['list'] as List?)
            ?.map((e) => CoreHotVideoItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ---------------------------------------------------------------------------
// PGC Rank
// ---------------------------------------------------------------------------

class CorePgcRankItemModel {
  String? cover;
  Map<String, dynamic>? newEp;
  Map<String, dynamic>? stat;
  String? title;
  String? url;

  CorePgcRankItemModel({
    this.cover,
    this.newEp,
    this.stat,
    this.title,
    this.url,
  });

  factory CorePgcRankItemModel.fromJson(Map<String, dynamic> json) =>
      CorePgcRankItemModel(
        cover: json['cover'] as String?,
        newEp: json['new_ep'] as Map<String, dynamic>?,
        stat: json['stat'] as Map<String, dynamic>?,
        title: json['title'] as String?,
        url: json['url'] as String?,
      );
}

// ---------------------------------------------------------------------------
// Video tag item (shared with user repository)
// ---------------------------------------------------------------------------

class CoreVideoTagItem {
  int? tagId;
  String? tagName;
  String? tagType;
  String? musicId;
  int? count;
  int? liked;
  String? cover;

  CoreVideoTagItem({this.tagId, this.tagName, this.tagType, this.musicId, this.count, this.liked, this.cover});

  factory CoreVideoTagItem.fromJson(Map<String, dynamic> json) => CoreVideoTagItem(
        tagId: json['tag_id'],
        tagName: json['tag_name'],
        tagType: json['tag_type'],
        musicId: json['music_id'],
        count: json['count'],
        liked: json['liked'],
        cover: json['cover'],
      );
}
