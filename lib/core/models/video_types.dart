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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (aid != null) 'aid': aid,
        if (bvid != null) 'bvid': bvid,
        if (cid != null) 'cid': cid,
        if (cover != null) 'pic': cover,
        if (title != null) 'title': title,
        if (duration != null) 'duration': duration,
        if (pubdate != null) 'pubdate': pubdate,
        if (desc != null) 'desc': desc,
        if (progress != null) 'progress': progress,
        if (redirectUrl != null) 'redirect_url': redirectUrl,
        if (badge != null) 'pgc_label': badge,
        if (owner != null) 'owner': owner,
        if (stat != null) 'stat': stat,
        if (dimension != null) 'dimension': dimension,
      };
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

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ...super.toJson(),
        if (goto != null) 'goto': goto,
        if (uri != null) 'uri': uri,
        if (param != null) 'param': param,
        if (pgcBadge != null) 'cover_right_text': pgcBadge,
      };
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

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': aid,
        if (bvid != null) 'bvid': bvid,
        if (cid != null) 'cid': cid,
        if (cover != null) 'pic': cover,
        if (title != null) 'title': title,
        if (duration != null) 'duration': duration,
        if (pubdate != null) 'pubdate': pubdate,
        if (owner != null) 'owner': owner,
        if (stat != null) 'stat': stat,
        if (goto != null) 'goto': goto,
        if (uri != null) 'uri': uri,
        if (rcmdReason != null)
          'rcmd_reason': <String, dynamic>{'content': rcmdReason},
        if (param != null) 'param': param,
        if (pgcBadge != null) 'cover_right_text': pgcBadge,
      };
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
            ? {'three_point_v2': json['three_point_v2']}
            : null,
        desc: json['desc'],
      );

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'player_args': <String, dynamic>{
          if (aid != null) 'aid': aid,
          if (cid != null) 'cid': cid,
          if (duration != null) 'duration': duration,
        },
        if (bvid != null) 'bvid': bvid,
        if (cover != null) 'cover': cover,
        if (title != null) 'title': title,
        if (param != null) 'param': '$param',
        if (goto != null) 'goto': goto,
        if (uri != null) 'uri': uri,
        'rcmd_reason': isFollowed ? null : rcmdReason,
        if (pgcBadge != null) 'cover_right_text': pgcBadge,
        if (talkBack != null) 'talk_back': talkBack,
        if (cardType != null) 'card_type': cardType,
        if (desc != null) 'desc': desc,
        if (owner != null) ...{
          'args': <String, dynamic>{
            'up_name': owner!['name'],
            'up_id': owner!['mid'],
          },
          'desc_button': <String, dynamic>{
            'text': owner!['name'],
          },
        },
        if (stat != null) ...{
          'cover_left_text_1': '${stat!['view'] ?? ''}',
          'cover_left_text_2': '${stat!['danmu'] ?? ''}',
        },
        if (threePoint case {'three_point_v2': final v} when v != null)
          'three_point_v2': v,
      };
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

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        ...super.toJson(),
        if (videos != null) 'videos': videos,
        if (tid != null) 'tid': tid,
        if (tname != null) 'tname': tname,
        if (copyright != null) 'copyright': copyright,
        if (ctime != null) 'ctime': ctime,
        if (state != null) 'state': state,
        if (firstFrame != null) 'first_frame': firstFrame,
        if (pubLocation != null) 'pub_location': pubLocation,
      };
}

// ---------------------------------------------------------------------------
// Video play URL
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// Typed play stream models (typed views over CorePlayUrlModel raw maps)
// ---------------------------------------------------------------------------

/// Base dash stream — fields shared by dash video/audio streams.
class CoreDashStream {
  /// Stream format id (raw JSON may carry an int or a numeric String).
  final int? id;
  final String? baseUrl;
  final List<String>? backupUrl;
  final int? bandwidth;
  final String? mimeType;
  final String? codecs;
  final int? width;
  final int? height;
  final String? frameRate;
  final String? sar;
  final int? startWithSap;
  final bool? selected;
  final String? url;

  const CoreDashStream({
    this.id,
    this.baseUrl,
    this.backupUrl,
    this.bandwidth,
    this.mimeType,
    this.codecs,
    this.width,
    this.height,
    this.frameRate,
    this.sar,
    this.startWithSap,
    this.selected,
    this.url,
  });
}

/// Dash video stream — adds segment base and segment list.
class CoreDashVideoStream extends CoreDashStream {
  final Map<String, dynamic>? segmentBase;
  final List<Map<String, dynamic>>? segments;

  const CoreDashVideoStream({
    super.id,
    super.baseUrl,
    super.backupUrl,
    super.bandwidth,
    super.mimeType,
    super.codecs,
    super.width,
    super.height,
    super.frameRate,
    super.sar,
    super.startWithSap,
    super.selected,
    super.url,
    this.segmentBase,
    this.segments,
  });
}

/// Dash audio stream — adds segment base, segment list and audio type.
class CoreDashAudioStream extends CoreDashStream {
  final Map<String, dynamic>? segmentBase;
  final List<Map<String, dynamic>>? segments;
  final String? audioType;

  const CoreDashAudioStream({
    super.id,
    super.baseUrl,
    super.backupUrl,
    super.bandwidth,
    super.mimeType,
    super.codecs,
    super.width,
    super.height,
    super.frameRate,
    super.sar,
    super.startWithSap,
    super.selected,
    super.url,
    this.segmentBase,
    this.segments,
    this.audioType,
  });
}

/// Typed view over a playurl `dash` map (duration + streams).
class CoreDashData {
  final int? duration;
  final double? minBufferTime;
  final List<CoreDashVideoStream>? video;
  final List<CoreDashAudioStream>? audio;

  const CoreDashData({
    this.duration,
    this.minBufferTime,
    this.video,
    this.audio,
  });
}

/// Typed view over a playurl `durl` entry.
class CoreDurl {
  final int? order;
  final int? length;
  final int? size;
  final String? ahead;
  final String? vhead;
  final String? url;
  final List<String>? backupUrl;

  const CoreDurl({
    this.order,
    this.length,
    this.size,
    this.ahead,
    this.vhead,
    this.url,
    this.backupUrl,
  });
}
int? _asInt(dynamic v) => switch (v) {
      int i => i,
      double d => d.toInt(),
      String s => int.tryParse(s),
      _ => null,
    };

double? _asDouble(dynamic v) => switch (v) {
      double d => d,
      int i => i.toDouble(),
      String s => double.tryParse(s),
      _ => null,
    };

String? _asString(dynamic v) => v is String ? v : null;

bool? _asBool(dynamic v) => v is bool ? v : null;

List<String>? _asStringList(dynamic v) =>
    v is List ? v.whereType<String>().toList() : null;

Map<String, dynamic>? _asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : null;

List<Map<String, dynamic>>? _asMapList(dynamic v) {
  if (v is! List) return null;
  return v.whereType<Map>().map(_asMap).whereType<Map<String, dynamic>>().toList();
}

CoreDashStream _parseDashStream(Map<String, dynamic> raw) => CoreDashStream(
        id: _asInt(raw['id']),
        baseUrl: _asString(raw['baseUrl']),
        backupUrl: _asStringList(raw['backupUrl']),
        bandwidth: _asInt(raw['bandwidth']),
        mimeType: _asString(raw['mimeType']),
        codecs: _asString(raw['codecs']),
        width: _asInt(raw['width']),
        height: _asInt(raw['height']),
        frameRate: _asString(raw['frameRate']),
        sar: _asString(raw['sar']),
        startWithSap: _asInt(raw['startWithSap']),
        selected: _asBool(raw['selected']),
        url: _asString(raw['url']),
      );

CoreDashVideoStream? _parseDashVideoStream(dynamic raw) {
  if (raw is! Map<String, dynamic>) return null;
  final base = _parseDashStream(raw);
  if (base.baseUrl == null && base.url == null) return null;
  return CoreDashVideoStream(
    id: base.id,
    baseUrl: base.baseUrl,
    backupUrl: base.backupUrl,
    bandwidth: base.bandwidth,
    mimeType: base.mimeType,
    codecs: base.codecs,
    width: base.width,
    height: base.height,
    frameRate: base.frameRate,
    sar: base.sar,
    startWithSap: base.startWithSap,
    selected: base.selected,
    url: base.url,
    segmentBase: _asMap(raw['SegmentBase']),
    segments: _asMapList(raw['segments']),
  );
}

CoreDashAudioStream? _parseDashAudioStream(dynamic raw) {
  if (raw is! Map<String, dynamic>) return null;
  final base = _parseDashStream(raw);
  if (base.baseUrl == null && base.url == null) return null;
  return CoreDashAudioStream(
    id: base.id,
    baseUrl: base.baseUrl,
    backupUrl: base.backupUrl,
    bandwidth: base.bandwidth,
    mimeType: base.mimeType,
    codecs: base.codecs,
    width: base.width,
    height: base.height,
    frameRate: base.frameRate,
    sar: base.sar,
    startWithSap: base.startWithSap,
    selected: base.selected,
    url: base.url,
    segmentBase: _asMap(raw['SegmentBase']),
    segments: _asMapList(raw['segments']),
    audioType: _asString(raw['audioType']),
  );
}

List<CoreDashVideoStream>? _parseDashVideoStreams(dynamic raw) {
  if (raw is! List) return null;
  return raw.map(_parseDashVideoStream).whereType<CoreDashVideoStream>().toList();
}

List<CoreDashAudioStream>? _parseDashAudioStreams(dynamic raw) {
  if (raw is! List) return null;
  return raw.map(_parseDashAudioStream).whereType<CoreDashAudioStream>().toList();
}

CoreDashData? _parseDashData(Map<String, dynamic>? raw) {
  if (raw == null) return null;
  final duration = _asInt(raw['duration']);
  final minBufferTime = _asDouble(raw['minBufferTime']);
  if (duration == null || minBufferTime == null) return null;
  return CoreDashData(
    duration: duration,
    minBufferTime: minBufferTime,
    video: _parseDashVideoStreams(raw['video']),
    audio: _parseDashAudioStreams(raw['audio']),
  );
}

List<CoreDurl>? _parseDurlList(List<Map<String, dynamic>>? raw) {
  if (raw == null) return null;
  final result = <CoreDurl>[];
  for (final item in raw) {
    final durl = CoreDurl(
      order: _asInt(item['order']),
      length: _asInt(item['length']),
      size: _asInt(item['size']),
      ahead: _asString(item['ahead']),
      vhead: _asString(item['vhead']),
      url: _asString(item['url']),
      backupUrl: _asStringList(item['backup_url']),
    );
    if (durl.url == null) continue;
    result.add(durl);
  }
  return result;
}

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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (from != null) 'from': from,
        if (result != null) 'result': result,
        if (message != null) 'message': message,
        if (quality != null) 'quality': quality,
        if (format != null) 'format': format,
        if (timeLength != null) 'timelength': timeLength,
        if (acceptFormat != null) 'accept_format': acceptFormat,
        if (acceptDesc != null) 'accept_description': acceptDesc,
        if (acceptQuality != null) 'accept_quality': acceptQuality,
        if (videoCodecid != null) 'video_codecid': videoCodecid,
        if (seekParam != null) 'seek_param': seekParam,
        if (seekType != null) 'seek_type': seekType,
        if (dash != null) 'dash': dash,
        if (durl != null) 'durl': durl,
        if (supportFormats != null) 'support_formats': supportFormats,
        if (volume != null) 'volume': volume,
        if (lastPlayTime != null) 'last_play_time': lastPlayTime,
        if (lastPlayCid != null) 'last_play_cid': lastPlayCid,
        if (curLanguage != null) 'cur_language': curLanguage,
        if (language != null) 'language': language,
        if (clipInfoList != null) 'clip_info_list': clipInfoList,
      };
  /// Typed view over [dash] — null when dash is null or unparseable.
  CoreDashData? get dashData => _parseDashData(dash);

  /// Typed view over [durl] — null when durl is null or unparseable.
  List<CoreDurl>? get durlList => _parseDurlList(durl);
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (coinNumber != null) 'coin_number': coinNumber,
        if (favorite != null) 'favorite': favorite,
        if (isOriginal != null) 'is_original': isOriginal,
        if (like != null) 'like': like,
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (coin != null) 'coin': coin,
        if (coinNumber != null) 'coin_number': coinNumber,
        if (favorite != null) 'favorite': favorite,
        if (fmid != null) 'fmid': fmid,
        if (follow != null) 'follow': follow,
        if (like != null) 'like': like,
        if (relation != null) 'relation': relation,
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (like != null) 'like': like,
        if (coin != null) 'coin': coin,
        if (fav != null) 'fav': fav,
        if (multiply != null) 'multiply': multiply,
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (bvid != null) 'bvid': bvid,
        if (aid != null) 'aid': aid,
        if (videos != null) 'videos': videos,
        if (copyright != null) 'copyright': copyright,
        if (pic != null) 'pic': pic,
        if (title != null) 'title': title,
        if (pubdate != null) 'pubdate': pubdate,
        if (ctime != null) 'ctime': ctime,
        if (desc != null) 'desc': desc,
        if (descV2 != null) 'desc_v2': descV2,
        if (duration != null) 'duration': duration,
        if (rights != null) 'rights': rights,
        if (owner != null) 'owner': owner,
        if (stat != null) 'stat': stat,
        if (argueInfo != null) 'argue_info': argueInfo,
        if (cid != null) 'cid': cid,
        if (dimension != null) 'dimension': dimension,
        if (seasonId != null) 'season_id': seasonId,
        if (isUpowerExclusive != null) 'is_upower_exclusive': isUpowerExclusive,
        if (pages != null) 'pages': pages,
        if (ugcSeason != null) 'ugc_season': ugcSeason,
        if (staff != null) 'staff': staff,
        if (redirectUrl != null) 'redirect_url': redirectUrl,
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (attention != null) 'attention': attention,
        if (favorite != null) 'favorite': favorite,
        if (seasonFav != null) 'season_fav': seasonFav,
        if (like != null) 'like': like,
        if (dislike != null) 'dislike': dislike,
        if (coin != null) 'coin': coin,
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (modelResult != null) 'model_result': modelResult,
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (lastPlayCid != null) 'last_play_cid': lastPlayCid,
        if (subtitle != null) 'subtitle': subtitle,
        if (viewPoints != null) 'view_points': viewPoints,
        if (interaction != null) 'interaction': interaction,
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (pvdata != null) 'pvdata': pvdata,
        'img_x_len': imgXLen,
        'img_y_len': imgYLen,
        'img_x_size': imgXSize,
        'img_y_size': imgYSize,
        'image': image,
        'index': index,
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (list != null) 'list': list,
        if (page != null) 'page': page,
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (number != null) 'number': number,
        if (name != null) 'name': name,
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (config != null) 'config': config,
        if (reminder != null) 'reminder': reminder,
        if (list != null)
          'list': list!.map((e) => e.toJson()).toList(),
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (mediaId != null) 'media_id': mediaId,
        if (list != null)
          'list': list!.map((e) => e.toJson()).toList(),
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (cover != null) 'cover': cover,
        if (newEp != null) 'new_ep': newEp,
        if (stat != null) 'stat': stat,
        if (title != null) 'title': title,
        if (url != null) 'url': url,
      };
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (tagId != null) 'tag_id': tagId,
        if (tagName != null) 'tag_name': tagName,
        if (tagType != null) 'tag_type': tagType,
        if (musicId != null) 'music_id': musicId,
        if (count != null) 'count': count,
        if (liked != null) 'liked': liked,
        if (cover != null) 'cover': cover,
      };
}
