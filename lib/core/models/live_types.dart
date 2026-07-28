/// Core data types for the live repository.
///
/// These are pure data classes (no UI, no adapter dependencies) with
/// JSON serialization. They mirror the adapter-level models in
/// `lib/adapters/bilibili/models_new/live/` but are free of
/// Bilibili-specific UI and platform code.
library;

// ---------------------------------------------------------------------------
// CoreAreaItem
// ---------------------------------------------------------------------------

class CoreAreaItem {
  final dynamic id;
  final String? name;
  final String? pic;
  final dynamic parentId;
  final String? parentName;

  const CoreAreaItem({
    this.id,
    this.name,
    this.pic,
    this.parentId,
    this.parentName,
  });

  factory CoreAreaItem.fromJson(Map<String, dynamic> json) => CoreAreaItem(
    id: json['id'],
    name: json['name'] as String?,
    pic: json['pic'] as String?,
    parentId: json['parent_id'],
    parentName: json['parent_name'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'name': name,
    'pic': pic,
    'parent_id': parentId,
    'parent_name': parentName,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is CoreAreaItem) {
      return id == other.id && parentId == other.parentId;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(id, parentId);
}

// ---------------------------------------------------------------------------
// CoreAreaList
// ---------------------------------------------------------------------------

class CoreAreaList {
  String? name;
  List<CoreAreaItem>? areaList;

  CoreAreaList({this.name, this.areaList});

  factory CoreAreaList.fromJson(Map<String, dynamic> json) => CoreAreaList(
    name: json['name'] ?? '',
    areaList: (json['area_list'] as List<dynamic>?)
        ?.map((e) => CoreAreaItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'area_list': areaList?.map((e) => e.toJson()).toList(),
  };
}

// ---------------------------------------------------------------------------
// CoreShieldUserList
// ---------------------------------------------------------------------------

class CoreShieldUserList {
  int? uid;
  String? uname;

  CoreShieldUserList({this.uid, this.uname});

  factory CoreShieldUserList.fromJson(Map<String, dynamic> json) {
    return CoreShieldUserList(
      uid: json['uid'] as int?,
      uname: json['uname'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'uid': uid,
    'uname': uname,
  };
}

// ---------------------------------------------------------------------------
// CoreShieldRules
// ---------------------------------------------------------------------------

class CoreShieldRules {
  int rank;
  int verify;
  int level;

  CoreShieldRules({this.rank = 0, this.verify = 0, this.level = 0});

  factory CoreShieldRules.fromJson(Map<String, dynamic> json) => CoreShieldRules(
    rank: json['rank'] as int? ?? 0,
    verify: json['verify'] as int? ?? 0,
    level: json['level'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'rank': rank,
    'verify': verify,
    'level': level,
  };
}

// ---------------------------------------------------------------------------
// CoreShieldInfo
// ---------------------------------------------------------------------------

class CoreShieldInfo {
  List<CoreShieldUserList>? shieldUserList;
  List<String>? keywordList;
  CoreShieldRules? shieldRules;

  CoreShieldInfo({
    this.shieldUserList,
    this.keywordList,
    this.shieldRules,
  });

  factory CoreShieldInfo.fromJson(Map<String, dynamic> json) => CoreShieldInfo(
    shieldUserList: (json['shield_user_list'] as List<dynamic>?)
        ?.map((e) => CoreShieldUserList.fromJson(e as Map<String, dynamic>))
        .toList(),
    keywordList: (json['keyword_list'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    shieldRules: json['shield_rules'] == null
        ? null
        : CoreShieldRules.fromJson(json['shield_rules'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'shield_user_list': shieldUserList?.map((e) => e.toJson()).toList(),
    'keyword_list': keywordList,
    'shield_rules': shieldRules?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreHostList
// ---------------------------------------------------------------------------

class CoreHostList {
  String? host;
  int? port;
  int? wssPort;
  int? wsPort;

  CoreHostList({this.host, this.port, this.wssPort, this.wsPort});

  factory CoreHostList.fromJson(Map<String, dynamic> json) => CoreHostList(
    host: json['host'] as String?,
    port: json['port'] as int?,
    wssPort: json['wss_port'] as int?,
    wsPort: json['ws_port'] as int?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'host': host,
    'port': port,
    'wss_port': wssPort,
    'ws_port': wsPort,
  };
}

// ---------------------------------------------------------------------------
// CoreLiveDmInfoData
// ---------------------------------------------------------------------------

class CoreLiveDmInfoData {
  String token;
  List<CoreHostList> hostList;

  CoreLiveDmInfoData({
    required this.token,
    required this.hostList,
  });

  factory CoreLiveDmInfoData.fromJson(Map<String, dynamic> json) =>
      CoreLiveDmInfoData(
        token: json['token'] as String,
        hostList: (json['host_list'] as List<dynamic>)
            .map((e) => CoreHostList.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'token': token,
    'host_list': hostList.map((e) => e.toJson()).toList(),
  };
}

// ---------------------------------------------------------------------------
// CoreEmoticon
// ---------------------------------------------------------------------------

class CoreEmoticon {
  String? emoji;
  String? url;
  int? width;
  int? height;
  String? emoticonUnique;

  CoreEmoticon({
    this.emoji,
    this.url,
    this.width,
    this.height,
    this.emoticonUnique,
  });

  factory CoreEmoticon.fromJson(Map<String, dynamic> json) => CoreEmoticon(
    emoji: json['emoji'] as String?,
    url: json['url'] as String?,
    width: json['width'] as int?,
    height: json['height'] as int?,
    emoticonUnique: json['emoticon_unique'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'emoji': emoji,
    'url': url,
    'width': width,
    'height': height,
    'emoticon_unique': emoticonUnique,
  };
}

// ---------------------------------------------------------------------------
// CoreLiveEmoteDatum
// ---------------------------------------------------------------------------

class CoreLiveEmoteDatum {
  List<CoreEmoticon>? emoticons;
  int? pkgType;
  String? currentCover;

  CoreLiveEmoteDatum({
    this.emoticons,
    this.pkgType,
    this.currentCover,
  });

  factory CoreLiveEmoteDatum.fromJson(Map<String, dynamic> json) =>
      CoreLiveEmoteDatum(
        emoticons: (json['emoticons'] as List<dynamic>?)
            ?.map((e) => CoreEmoticon.fromJson(e as Map<String, dynamic>))
            .toList(),
        pkgType: json['pkg_type'] as int?,
        currentCover: json['current_cover'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'emoticons': emoticons?.map((e) => e.toJson()).toList(),
    'pkg_type': pkgType,
    'current_cover': currentCover,
  };
}

// ---------------------------------------------------------------------------
// CoreWatchedShow
// ---------------------------------------------------------------------------

class CoreWatchedShow {
  String? textLarge;

  CoreWatchedShow({
    this.textLarge,
  });

  factory CoreWatchedShow.fromJson(Map<String, dynamic> json) => CoreWatchedShow(
    textLarge: json['text_large'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'text_large': textLarge,
  };
}

// ---------------------------------------------------------------------------
// CoreCardLiveItem
// ---------------------------------------------------------------------------

class CoreCardLiveItem {
  int? roomid;
  int? uid;
  String? uname;
  String? face;
  String? cover;
  String? systemCover;
  String? title;
  String? areaName;
  int? areaV2Id;
  int? areaV2ParentId;
  CoreWatchedShow? watchedShow;

  CoreCardLiveItem({
    this.roomid,
    this.uid,
    this.uname,
    this.face,
    this.cover,
    this.systemCover,
    this.title,
    this.areaName,
    this.areaV2Id,
    this.areaV2ParentId,
    this.watchedShow,
  });

  factory CoreCardLiveItem.fromJson(Map<String, dynamic> json) => CoreCardLiveItem(
    roomid: json['roomid'] ?? json['id'],
    uid: json['uid'] as int?,
    uname: json['uname'] as String?,
    face: json['face'] as String?,
    cover: json['cover'] as String?,
    systemCover: json['system_cover'] as String?,
    title: json['title'] as String?,
    areaName: json['area_name'] as String?,
    areaV2Id: json['area_v2_id'] as int?,
    areaV2ParentId: json['area_v2_parent_id'] as int?,
    watchedShow: json['watched_show'] == null
        ? null
        : CoreWatchedShow.fromJson(json['watched_show'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'roomid': roomid,
    'uid': uid,
    'uname': uname,
    'face': face,
    'cover': cover,
    'system_cover': systemCover,
    'title': title,
    'area_name': areaName,
    'area_v2_id': areaV2Id,
    'area_v2_parent_id': areaV2ParentId,
    'watched_show': watchedShow?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreExtraInfo
// ---------------------------------------------------------------------------

class CoreExtraInfo {
  int? totalCount;

  CoreExtraInfo({this.totalCount});

  factory CoreExtraInfo.fromJson(Map<String, dynamic> json) => CoreExtraInfo(
    totalCount: json['total_count'] as int?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'total_count': totalCount,
  };
}

// ---------------------------------------------------------------------------
// CoreCardDataItem
// ---------------------------------------------------------------------------

class CoreCardDataItem {
  List<CoreCardLiveItem>? list;
  CoreExtraInfo? extraInfo;

  CoreCardDataItem({
    this.list,
    this.extraInfo,
  });

  factory CoreCardDataItem.fromJson(Map<String, dynamic> json) => CoreCardDataItem(
    list: (json['list'] as List<dynamic>?)
        ?.map((e) => CoreCardLiveItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    extraInfo: json['extra_info'] == null
        ? null
        : CoreExtraInfo.fromJson(json['extra_info'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'list': list?.map((e) => e.toJson()).toList(),
    'extra_info': extraInfo?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreCardData
// ---------------------------------------------------------------------------

class CoreCardData {
  CoreCardDataItem? bannerV2;
  CoreCardDataItem? myIdolV1;
  CoreCardDataItem? areaEntranceV3;
  CoreCardLiveItem? smallCardV1;

  CoreCardData({
    this.bannerV2,
    this.myIdolV1,
    this.areaEntranceV3,
    this.smallCardV1,
  });

  factory CoreCardData.fromJson(Map<String, dynamic> json) => CoreCardData(
    bannerV2: json['banner_v2'] == null
        ? null
        : CoreCardDataItem.fromJson(json['banner_v2'] as Map<String, dynamic>),
    myIdolV1: json['my_idol_v1'] == null
        ? null
        : CoreCardDataItem.fromJson(json['my_idol_v1'] as Map<String, dynamic>),
    areaEntranceV3: json['area_entrance_v3'] == null
        ? null
        : CoreCardDataItem.fromJson(
            json['area_entrance_v3'] as Map<String, dynamic>,
          ),
    smallCardV1: json['small_card_v1'] == null
        ? null
        : CoreCardLiveItem.fromJson(json['small_card_v1'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'banner_v2': bannerV2?.toJson(),
    'my_idol_v1': myIdolV1?.toJson(),
    'area_entrance_v3': areaEntranceV3?.toJson(),
    'small_card_v1': smallCardV1?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreLiveCardList
// ---------------------------------------------------------------------------

class CoreLiveCardList {
  String? cardType;
  CoreCardData? cardData;

  CoreLiveCardList({this.cardType, this.cardData});

  factory CoreLiveCardList.fromJson(Map<String, dynamic> json) => CoreLiveCardList(
    cardType: json['card_type'] as String?,
    cardData: json['card_data'] == null
        ? null
        : CoreCardData.fromJson(json['card_data'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'card_type': cardType,
    'card_data': cardData?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreLiveIndexData (LiveFeedIndexData)
// ---------------------------------------------------------------------------

class CoreLiveIndexData {
  List<CoreLiveCardList>? cardList;
  int? hasMore;
  CoreLiveCardList? followItem;
  CoreLiveCardList? areaItem;

  CoreLiveIndexData({
    this.cardList,
    this.hasMore,
    this.followItem,
    this.areaItem,
  });

  factory CoreLiveIndexData.fromJson(Map<String, dynamic> json) {
    final data = CoreLiveIndexData();
    if ((json['card_list'] as List<dynamic>?)?.isNotEmpty == true) {
      for (final item in json['card_list']) {
        switch (item['card_type']) {
          case 'my_idol_v1':
            data.followItem = CoreLiveCardList.fromJson(item);
            break;
          case 'area_entrance_v3':
            data.areaItem = CoreLiveCardList.fromJson(item);
            break;
          case 'small_card_v1':
            (data.cardList ??= <CoreLiveCardList>[])
                .add(CoreLiveCardList.fromJson(item));
            break;
        }
      }
    }
    data.hasMore = json['has_more'] as int?;
    return data;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'card_list': cardList?.map((e) => e.toJson()).toList(),
    'has_more': hasMore,
  };
}

// ---------------------------------------------------------------------------
// CoreLiveFollowItem
// ---------------------------------------------------------------------------

class CoreLiveFollowItem {
  int? roomid;
  String? uname;
  String? title;
  String? areaName;
  String? textSmall;
  String? roomCover;

  CoreLiveFollowItem({
    this.roomid,
    this.uname,
    this.title,
    this.areaName,
    this.textSmall,
    this.roomCover,
  });

  factory CoreLiveFollowItem.fromJson(Map<String, dynamic> json) =>
      CoreLiveFollowItem(
        roomid: json['roomid'] as int?,
        uname: json['uname'] as String?,
        title: json['title'] as String?,
        areaName: json['area_name'] as String?,
        textSmall: json['text_small'] as String?,
        roomCover: json['room_cover'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'roomid': roomid,
    'uname': uname,
    'title': title,
    'area_name': areaName,
    'text_small': textSmall,
    'room_cover': roomCover,
  };
}

// ---------------------------------------------------------------------------
// CoreLiveFollowData
// ---------------------------------------------------------------------------

class CoreLiveFollowData {
  String? title;
  int? pageSize;
  int? totalPage;
  List<CoreLiveFollowItem>? list;
  int? count;
  int? liveCount;

  CoreLiveFollowData({
    this.title,
    this.pageSize,
    this.totalPage,
    this.list,
    this.count,
    this.liveCount,
  });

  factory CoreLiveFollowData.fromJson(Map<String, dynamic> json) {
    final data = CoreLiveFollowData(
      title: json['title'] as String?,
      pageSize: json['pageSize'] as int?,
      totalPage: json['totalPage'] as int?,
      count: json['count'] as int?,
      liveCount: json['live_count'] as int?,
    );
    data.list = (json['list'] as List<dynamic>?)
        ?.cast<Map<String, dynamic>>()
        .map(CoreLiveFollowItem.fromJson)
        .toList();
    return data;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'title': title,
    'pageSize': pageSize,
    'totalPage': totalPage,
    'list': list?.map((e) => e.toJson()).toList(),
    'count': count,
    'live_count': liveCount,
  };
}

// ---------------------------------------------------------------------------
// CoreMedalInfo
// ---------------------------------------------------------------------------

class CoreMedalInfo {
  int? wearingStatus;

  CoreMedalInfo({
    this.wearingStatus,
  });

  factory CoreMedalInfo.fromJson(Map<String, dynamic> json) => CoreMedalInfo(
    wearingStatus: json['wearing_status'] as int?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'wearing_status': wearingStatus,
  };
}

// ---------------------------------------------------------------------------
// CoreUinfoMedal
// ---------------------------------------------------------------------------

class CoreUinfoMedal {
  String? name;
  int? level;
  int? id;
  int? ruid;
  String? v2MedalColorStart;
  String? v2MedalColorText;

  CoreUinfoMedal({
    this.name,
    this.level,
    this.id,
    this.ruid,
    this.v2MedalColorStart,
    this.v2MedalColorText,
  });

  factory CoreUinfoMedal.fromJson(Map<String, dynamic> json) => CoreUinfoMedal(
    name: json['name'] as String?,
    level: json['level'] as int?,
    id: json['id'] as int?,
    ruid: json['ruid'] as int?,
    v2MedalColorStart: json['v2_medal_color_start'] as String?,
    v2MedalColorText: json['v2_medal_color_text'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'level': level,
    'id': id,
    'ruid': ruid,
    'v2_medal_color_start': v2MedalColorStart,
    'v2_medal_color_text': v2MedalColorText,
  };
}

// ---------------------------------------------------------------------------
// CoreMedalWallItem
// ---------------------------------------------------------------------------

class CoreMedalWallItem {
  CoreMedalInfo? medalInfo;
  String? targetName;
  String? targetIcon;
  String? link;
  int? liveStatus;
  int? official;
  CoreUinfoMedal? uinfoMedal;

  CoreMedalWallItem({
    this.medalInfo,
    this.targetName,
    this.targetIcon,
    this.link,
    this.liveStatus,
    this.official,
    this.uinfoMedal,
  });

  factory CoreMedalWallItem.fromJson(Map<String, dynamic> json) => CoreMedalWallItem(
    medalInfo: json['medal_info'] == null
        ? null
        : CoreMedalInfo.fromJson(json['medal_info'] as Map<String, dynamic>),
    targetName: json['target_name'] as String?,
    targetIcon: json['target_icon'] as String?,
    link: json['link'] as String?,
    liveStatus: json['live_status'] as int?,
    official: json['official'] as int?,
    uinfoMedal: json['uinfo_medal'] == null
        ? null
        : CoreUinfoMedal.fromJson(json['uinfo_medal'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'medal_info': medalInfo?.toJson(),
    'target_name': targetName,
    'target_icon': targetIcon,
    'link': link,
    'live_status': liveStatus,
    'official': official,
    'uinfo_medal': uinfoMedal?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreMedalWallData (LiveCoreMedalWallData)
// ---------------------------------------------------------------------------

class CoreMedalWallData {
  List<CoreMedalWallItem>? list;
  int? count;
  String? name;
  String? icon;

  CoreMedalWallData({
    this.list,
    this.count,
    this.name,
    this.icon,
  });

  factory CoreMedalWallData.fromJson(Map<String, dynamic> json) => CoreMedalWallData(
    list: (json['list'] as List<dynamic>?)
        ?.map((e) => CoreMedalWallItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    count: json['count'] as int?,
    name: json['name'] as String?,
    icon: json['icon'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'list': list?.map((e) => e.toJson()).toList(),
    'count': count,
    'name': name,
    'icon': icon,
  };
}

// ---------------------------------------------------------------------------
// CoreRoomInfo
// ---------------------------------------------------------------------------

class CoreRoomInfo {
  int? uid;
  String? title;
  String? cover;
  String? appBackground;

  CoreRoomInfo({
    this.uid,
    this.title,
    this.cover,
    this.appBackground,
  });

  factory CoreRoomInfo.fromJson(Map<String, dynamic> json) => CoreRoomInfo(
    uid: json['uid'] as int?,
    title: json['title'] as String?,
    cover: json['cover'] as String?,
    appBackground: json['app_background'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'uid': uid,
    'title': title,
    'cover': cover,
    'app_background': appBackground,
  };
}

// ---------------------------------------------------------------------------
// CoreBaseInfo
// ---------------------------------------------------------------------------

class CoreBaseInfo {
  String? uname;
  String? face;

  CoreBaseInfo({this.uname, this.face});

  factory CoreBaseInfo.fromJson(Map<String, dynamic> json) => CoreBaseInfo(
    uname: json['uname'] as String?,
    face: json['face'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'uname': uname,
    'face': face,
  };
}

// ---------------------------------------------------------------------------
// CoreAnchorInfo
// ---------------------------------------------------------------------------

class CoreAnchorInfo {
  CoreBaseInfo? baseInfo;

  CoreAnchorInfo({this.baseInfo});

  factory CoreAnchorInfo.fromJson(Map<String, dynamic> json) => CoreAnchorInfo(
    baseInfo: json['base_info'] == null
        ? null
        : CoreBaseInfo.fromJson(json['base_info'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'base_info': baseInfo?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreRoomInfoH5Data (LiveCoreRoomInfoH5Data)
// ---------------------------------------------------------------------------

class CoreRoomInfoH5Data {
  CoreRoomInfo? roomInfo;
  CoreAnchorInfo? anchorInfo;
  CoreWatchedShow? watchedShow;

  CoreRoomInfoH5Data({
    this.roomInfo,
    this.anchorInfo,
    this.watchedShow,
  });

  factory CoreRoomInfoH5Data.fromJson(Map<String, dynamic> json) =>
      CoreRoomInfoH5Data(
        roomInfo: json['room_info'] == null
            ? null
            : CoreRoomInfo.fromJson(json['room_info'] as Map<String, dynamic>),
        anchorInfo: json['anchor_info'] == null
            ? null
            : CoreAnchorInfo.fromJson(json['anchor_info'] as Map<String, dynamic>),
        watchedShow: json['watched_show'] == null
            ? null
            : CoreWatchedShow.fromJson(
                json['watched_show'] as Map<String, dynamic>,
              ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'room_info': roomInfo?.toJson(),
    'anchor_info': anchorInfo?.toJson(),
    'watched_show': watchedShow?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreUrlInfo
// ---------------------------------------------------------------------------

class CoreUrlInfo {
  String host;
  String extra;

  CoreUrlInfo({required this.host, required this.extra});

  factory CoreUrlInfo.fromJson(Map<String, dynamic> json) => CoreUrlInfo(
    host: json['host'] as String,
    extra: json['extra'] as String,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'host': host,
    'extra': extra,
  };
}

// ---------------------------------------------------------------------------
// CoreCodecItem
// ---------------------------------------------------------------------------

class CoreCodecItem {
  String? codecName;
  int currentQn;
  List<int> acceptQn;
  String baseUrl;
  List<CoreUrlInfo> urlInfo;

  CoreCodecItem({
    this.codecName,
    required this.currentQn,
    required this.acceptQn,
    required this.baseUrl,
    required this.urlInfo,
  });

  factory CoreCodecItem.fromJson(Map<String, dynamic> json) => CoreCodecItem(
    codecName: json['codec_name'] as String?,
    currentQn: json['current_qn'] as int,
    acceptQn: List<int>.from(json['accept_qn'] as List),
    baseUrl: json['base_url'] as String,
    urlInfo: (json['url_info'] as List<dynamic>)
        .map((e) => CoreUrlInfo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'codec_name': codecName,
    'current_qn': currentQn,
    'accept_qn': acceptQn,
    'base_url': baseUrl,
    'url_info': urlInfo.map((e) => e.toJson()).toList(),
  };
}

// ---------------------------------------------------------------------------
// CoreFormat
// ---------------------------------------------------------------------------

class CoreFormat {
  String? formatName;
  List<CoreCodecItem> codec;

  CoreFormat({
    this.formatName,
    required this.codec,
  });

  factory CoreFormat.fromJson(Map<String, dynamic> json) => CoreFormat(
    formatName: json['format_name'] as String?,
    codec: (json['codec'] as List<dynamic>)
        .map((e) => CoreCodecItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'format_name': formatName,
    'codec': codec.map((e) => e.toJson()).toList(),
  };
}

// ---------------------------------------------------------------------------
// CoreStream
// ---------------------------------------------------------------------------

class CoreStream {
  String? protocolName;
  List<CoreFormat> format;

  CoreStream({this.protocolName, required this.format});

  factory CoreStream.fromJson(Map<String, dynamic> json) => CoreStream(
    protocolName: json['protocol_name'] as String?,
    format: (json['format'] as List<dynamic>)
        .map((e) => CoreFormat.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'protocol_name': protocolName,
    'format': format.map((e) => e.toJson()).toList(),
  };
}

// ---------------------------------------------------------------------------
// CorePlayurl
// ---------------------------------------------------------------------------

class CorePlayurl {
  List<CoreStream> stream;

  CorePlayurl({
    required this.stream,
  });

  factory CorePlayurl.fromJson(Map<String, dynamic> json) => CorePlayurl(
    stream: (json['stream'] as List<dynamic>)
        .map((e) => CoreStream.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'stream': stream.map((e) => e.toJson()).toList(),
  };
}

// ---------------------------------------------------------------------------
// CorePlayurlInfo
// ---------------------------------------------------------------------------

class CorePlayurlInfo {
  CorePlayurl? playurl;

  CorePlayurlInfo({
    this.playurl,
  });

  factory CorePlayurlInfo.fromJson(Map<String, dynamic> json) => CorePlayurlInfo(
    playurl: json['playurl'] == null
        ? null
        : CorePlayurl.fromJson(json['playurl'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'playurl': playurl?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreRoomPlayInfoData (LiveRoomPlayInfo)
// ---------------------------------------------------------------------------

class CoreRoomPlayInfoData {
  int? roomId;
  int? shortId;
  int? uid;
  bool? isPortrait;
  int? liveStatus;
  int? liveTime;
  CorePlayurlInfo? playurlInfo;

  CoreRoomPlayInfoData({
    this.roomId,
    this.shortId,
    this.uid,
    this.isPortrait,
    this.liveStatus,
    this.liveTime,
    this.playurlInfo,
  });

  factory CoreRoomPlayInfoData.fromJson(Map<String, dynamic> json) =>
      CoreRoomPlayInfoData(
        roomId: json['room_id'] as int?,
        shortId: json['short_id'] as int?,
        uid: json['uid'] as int?,
        isPortrait: json['is_portrait'] as bool?,
        liveStatus: json['live_status'] as int?,
        liveTime: json['live_time'] as int?,
        playurlInfo: json['playurl_info'] == null
            ? null
            : CorePlayurlInfo.fromJson(
                json['playurl_info'] as Map<String, dynamic>,
              ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'room_id': roomId,
    'short_id': shortId,
    'uid': uid,
    'is_portrait': isPortrait,
    'live_status': liveStatus,
    'live_time': liveTime,
    'playurl_info': playurlInfo?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreLiveSearchRoomItemModel
// ---------------------------------------------------------------------------

class CoreLiveSearchRoomItemModel {
  int? roomid;
  String? cover;
  String? title;
  String? name;
  String? face;
  CoreWatchedShow? watchedShow;

  CoreLiveSearchRoomItemModel({
    this.roomid,
    this.cover,
    this.title,
    this.name,
    this.face,
    this.watchedShow,
  });

  factory CoreLiveSearchRoomItemModel.fromJson(Map<String, dynamic> json) =>
      CoreLiveSearchRoomItemModel(
        roomid: json['roomid'] as int?,
        cover: json['cover'] as String?,
        title: json['title'] as String?,
        name: json['name'] as String?,
        face: json['face'] as String?,
        watchedShow: json['watched_show'] == null
            ? null
            : CoreWatchedShow.fromJson(
                json['watched_show'] as Map<String, dynamic>,
              ),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'roomid': roomid,
    'cover': cover,
    'title': title,
    'name': name,
    'face': face,
    'watched_show': watchedShow?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// Room (LiveSearch room)
// ---------------------------------------------------------------------------

class CoreLiveSearchRoom {
  List<CoreLiveSearchRoomItemModel>? list;
  int? totalRoom;

  CoreLiveSearchRoom({this.list, this.totalRoom});

  factory CoreLiveSearchRoom.fromJson(Map<String, dynamic> json) => CoreLiveSearchRoom(
    list: (json['list'] as List<dynamic>?)
        ?.map(
          (e) =>
              CoreLiveSearchRoomItemModel.fromJson(e as Map<String, dynamic>),
        )
        .toList(),
    totalRoom: json['total_room'] as int?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'list': list?.map((e) => e.toJson()).toList(),
    'total_room': totalRoom,
  };
}

// ---------------------------------------------------------------------------
// CoreLiveSearchUserItemModel
// ---------------------------------------------------------------------------

class CoreLiveSearchUserItemModel {
  String? face;
  String? name;
  int? liveStatus;
  String? areaName;
  int? fansNum;
  int? roomid;

  CoreLiveSearchUserItemModel({
    this.face,
    this.name,
    this.liveStatus,
    this.areaName,
    this.fansNum,
    this.roomid,
  });

  factory CoreLiveSearchUserItemModel.fromJson(Map<String, dynamic> json) =>
      CoreLiveSearchUserItemModel(
        face: json['face'] as String?,
        name: json['name'] as String?,
        liveStatus: json['live_status'] as int?,
        areaName: json['areaName'] as String?,
        fansNum: json['fansNum'] as int?,
        roomid: json['roomid'] as int?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'face': face,
    'name': name,
    'live_status': liveStatus,
    'areaName': areaName,
    'fansNum': fansNum,
    'roomid': roomid,
  };
}

// ---------------------------------------------------------------------------
// User (LiveSearch user)
// ---------------------------------------------------------------------------

class CoreLiveSearchUser {
  List<CoreLiveSearchUserItemModel>? list;
  int? totalUser;

  CoreLiveSearchUser({this.list, this.totalUser});

  factory CoreLiveSearchUser.fromJson(Map<String, dynamic> json) => CoreLiveSearchUser(
    list: (json['list'] as List<dynamic>?)
        ?.map((e) => CoreLiveSearchUserItemModel.fromJson(e))
        .toList(),
    totalUser: json['total_user'] as int?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'list': list?.map((e) => e.toJson()).toList(),
    'total_user': totalUser,
  };
}

// ---------------------------------------------------------------------------
// CoreLiveSearchData
// ---------------------------------------------------------------------------

class CoreLiveSearchData {
  CoreLiveSearchRoom? room;
  CoreLiveSearchUser? user;

  CoreLiveSearchData({
    this.room,
    this.user,
  });

  factory CoreLiveSearchData.fromJson(Map<String, dynamic> json) => CoreLiveSearchData(
    room: json['room'] == null
        ? null
        : CoreLiveSearchRoom.fromJson(json['room'] as Map<String, dynamic>),
    user: json['user'] == null
        ? null
        : CoreLiveSearchUser.fromJson(json['user'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'room': room?.toJson(),
    'user': user?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreLiveSecondTag
// ---------------------------------------------------------------------------

class CoreLiveSecondTag {
  String? name;
  String? sortType;

  CoreLiveSecondTag({
    this.name,
    this.sortType,
  });

  factory CoreLiveSecondTag.fromJson(Map json) => CoreLiveSecondTag(
    name: json['name'] as String?,
    sortType: json['sort_type'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'sort_type': sortType,
  };
}

// ---------------------------------------------------------------------------
// CoreLiveSecondData (LiveSecondListData)
// ---------------------------------------------------------------------------

class CoreLiveSecondData {
  int? count;
  List<CoreCardLiveItem>? cardList;
  List<CoreLiveSecondTag>? newTags;

  CoreLiveSecondData({
    this.count,
    this.cardList,
    this.newTags,
  });

  factory CoreLiveSecondData.fromJson(Map<String, dynamic> json) =>
      CoreLiveSecondData(
        count: json['count'] as int?,
        cardList: (json['list'] as List<dynamic>?)
            ?.map((e) => CoreCardLiveItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        newTags: (json['new_tags'] as List<dynamic>?)
            ?.map((e) => CoreLiveSecondTag.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'count': count,
    'list': cardList?.map((e) => e.toJson()).toList(),
    'new_tags': newTags?.map((e) => e.toJson()).toList(),
  };
}

// ---------------------------------------------------------------------------
// UserInfo (SuperChat)
// ---------------------------------------------------------------------------

class CoreSuperChatUserInfo {
  String face;
  String uname;
  String nameColor;

  CoreSuperChatUserInfo({
    required this.face,
    required this.uname,
    required this.nameColor,
  });

  factory CoreSuperChatUserInfo.fromJson(Map<String, dynamic> json) =>
      CoreSuperChatUserInfo(
        face: json['face'] as String,
        uname: json['uname'] as String,
        nameColor: json['name_color'] as String? ?? '#666666',
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'face': face,
    'uname': uname,
    'name_color': nameColor,
  };
}

// ---------------------------------------------------------------------------
// CoreSuperChatItem
// ---------------------------------------------------------------------------

class CoreSuperChatItem {
  int id;
  int uid;
  int price;
  String? backgroundImage;
  String backgroundColor;
  String backgroundBottomColor;
  String backgroundPriceColor;
  String messageFontColor;
  int startSime;
  int endTime;
  String message;
  String token;
  int ts;
  CoreSuperChatUserInfo userInfo;
  bool expired = false;
  bool deleted = false;
  CoreUinfoMedal? medalInfo;

  CoreSuperChatItem({
    required this.id,
    required this.uid,
    required this.price,
    this.backgroundImage,
    required this.backgroundColor,
    required this.backgroundBottomColor,
    required this.backgroundPriceColor,
    required this.messageFontColor,
    required this.startSime,
    required this.endTime,
    required this.message,
    required this.token,
    required this.ts,
    required this.userInfo,
    this.medalInfo,
  });

  factory CoreSuperChatItem.fromJson(Map<String, dynamic> json) =>
      CoreSuperChatItem(
        id: json['id'] as int,
        uid: json['uid'] as int,
        price: json['price'] as int,
        backgroundImage: json['background_image'] as String?,
        backgroundColor: json['background_color'] as String? ?? '#EDF5FF',
        backgroundBottomColor:
            json['background_bottom_color'] as String? ?? '#2A60B2',
        backgroundPriceColor:
            json['background_price_color'] as String? ?? '#7497CD',
        messageFontColor: json['message_font_color'] as String? ?? '#FFFFFF',
        startSime: json['start_time'] as int,
        endTime: json['end_time'] as int,
        message: json['message'] as String,
        token: json['token'] as String,
        ts: json['ts'] as int,
        userInfo:
            CoreSuperChatUserInfo.fromJson(json['user_info'] as Map<String, dynamic>),
        medalInfo: json['uinfo']?['medal'] == null
            ? null
            : CoreUinfoMedal.fromJson(json['uinfo']['medal']),
      );

  CoreSuperChatItem copyWith({
    int? id,
    int? uid,
    int? price,
    String? backgroundColor,
    String? backgroundBottomColor,
    String? backgroundPriceColor,
    String? messageFontColor,
    int? startSime,
    int? endTime,
    String? message,
    String? token,
    int? ts,
    CoreSuperChatUserInfo? userInfo,
    bool? expired,
    CoreUinfoMedal? medalInfo,
  }) {
    return CoreSuperChatItem(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      price: price ?? this.price,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundBottomColor:
          backgroundBottomColor ?? this.backgroundBottomColor,
      backgroundPriceColor: backgroundPriceColor ?? this.backgroundPriceColor,
      messageFontColor: messageFontColor ?? this.messageFontColor,
      startSime: startSime ?? this.startSime,
      endTime: endTime ?? this.endTime,
      message: message ?? this.message,
      token: token ?? this.token,
      ts: ts ?? this.ts,
      userInfo: userInfo ?? this.userInfo,
      medalInfo: medalInfo ?? this.medalInfo,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'uid': uid,
    'price': price,
    'background_image': backgroundImage,
    'background_color': backgroundColor,
    'background_bottom_color': backgroundBottomColor,
    'background_price_color': backgroundPriceColor,
    'message_font_color': messageFontColor,
    'start_time': startSime,
    'end_time': endTime,
    'message': message,
    'token': token,
    'ts': ts,
    'user_info': userInfo.toJson(),
    'medal': medalInfo?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreSuperChatData
// ---------------------------------------------------------------------------

class CoreSuperChatData {
  List<CoreSuperChatItem>? list;

  CoreSuperChatData({this.list});

  factory CoreSuperChatData.fromJson(Map<String, dynamic> json) => CoreSuperChatData(
    list: (json['list'] as List<dynamic>?)
        ?.map((e) => CoreSuperChatItem.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'list': list?.map((e) => e.toJson()).toList(),
  };
}

// ---------------------------------------------------------------------------
// Owner
// ---------------------------------------------------------------------------

class CoreLiveOwner {
  int? mid;
  String? name;
  String? face;

  CoreLiveOwner({
    this.mid,
    this.name,
    this.face,
  });

  factory CoreLiveOwner.fromJson(Map<String, dynamic> json) => CoreLiveOwner(
    mid: json['mid'] as int?,
    name: json['name'] as String?,
    face: json['face'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'mid': mid,
    'name': name,
    'face': face,
  };
}

// ---------------------------------------------------------------------------
// BaseEmote
// ---------------------------------------------------------------------------

class CoreLiveBaseEmote {
  late String url;
  late String emoticonUnique;
  late double width;
  late double height;

  CoreLiveBaseEmote.fromJson(Map<String, dynamic> json) {
    url = json['url'] as String;
    emoticonUnique = json['emoticon_unique'] as String;
    width = (json['width'] as num).toDouble();
    height = (json['height'] as num?)?.toDouble() ?? width;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'url': url,
    'emoticon_unique': emoticonUnique,
    'width': width,
    'height': height,
  };
}

// ---------------------------------------------------------------------------
// LiveDanmaku (extra data)
// ---------------------------------------------------------------------------

class CoreLiveDanmakuExtra {
  final Object id;
  final Object mid;
  final int dmType;
  final Object ts;
  final Object ct;

  const CoreLiveDanmakuExtra({
    required this.id,
    required this.mid,
    required this.dmType,
    required this.ts,
    required this.ct,
  });

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'mid': mid,
    'dm_type': dmType,
    'ts': ts,
    'ct': ct,
  };
}

// ---------------------------------------------------------------------------
// CoreDanmakuMsg
// ---------------------------------------------------------------------------

class CoreDanmakuMsg {
  final String name;
  final String text;
  final Map<String, CoreLiveBaseEmote>? emots;
  final CoreLiveBaseEmote? uemote;
  final CoreLiveOwner? reply;
  final CoreLiveDanmakuExtra extra;
  final CoreUinfoMedal? medalInfo;

  const CoreDanmakuMsg({
    required this.name,
    required this.text,
    this.emots,
    this.uemote,
    this.reply,
    required this.extra,
    this.medalInfo,
  });

  factory CoreDanmakuMsg.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final name = user?['base']?['name'] as String? ?? '';
    final text = json['text'] as String? ?? '';
    CoreLiveBaseEmote? uemote;
    if ((json['emoticon']?['emoticon_unique'] as String?)?.isNotEmpty == true) {
      uemote = CoreLiveBaseEmote.fromJson(json['emoticon'] as Map<String, dynamic>);
    }
    final checkInfo = json['check_info'] as Map<String, dynamic>?;
    CoreLiveOwner? reply;
    if (json['reply'] case final Map map) {
      final replyMid = map['reply_mid'];
      if (replyMid != null && replyMid != 0) {
        reply = CoreLiveOwner(
          mid: replyMid as int?,
          name: map['reply_uname'] as String?,
        );
      }
    }
    final medal = user?['medal'];
    return CoreDanmakuMsg(
      name: name,
      text: text,
      emots: (json['emots'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, CoreLiveBaseEmote.fromJson(v as Map<String, dynamic>)),
      ),
      uemote: uemote,
      reply: reply,
      extra: CoreLiveDanmakuExtra(
        id: json['id_str']!,
        mid: user?['uid']!,
        dmType: json['dm_type'] as int,
        ts: checkInfo?['ts']!,
        ct: checkInfo?['ct']!,
      ),
      medalInfo: medal == null
          ? null
          : CoreUinfoMedal.fromJson(medal as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'name': name,
    'text': text,
    'emots': emots?.map((k, v) => MapEntry(k, v.toJson())),
    'uemote': uemote?.toJson(),
    'reply': reply?.toJson(),
    'extra': extra.toJson(),
    'medal': medalInfo?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreLiveContributionRankItem
// ---------------------------------------------------------------------------

class CoreLiveContributionRankItem {
  int? uid;
  String? name;
  String? face;
  int? score;
  CoreUinfoMedal? uinfoMedal;

  CoreLiveContributionRankItem({
    this.uid,
    this.name,
    this.face,
    this.score,
    this.uinfoMedal,
  });

  factory CoreLiveContributionRankItem.fromJson(Map<String, dynamic> json) =>
      CoreLiveContributionRankItem(
        uid: json['uid'] as int?,
        name: json['name'] as String?,
        face: json['face'] as String?,
        score: json['score'] as int?,
        uinfoMedal: json['uinfo']?['medal'] == null
            ? null
            : CoreUinfoMedal.fromJson(json['uinfo']?['medal']),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'uid': uid,
    'name': name,
    'face': face,
    'score': score,
    'uinfo_medal': uinfoMedal?.toJson(),
  };
}

// ---------------------------------------------------------------------------
// CoreLiveContributionRankData
// ---------------------------------------------------------------------------

class CoreLiveContributionRankData {
  List<CoreLiveContributionRankItem>? item;

  CoreLiveContributionRankData({
    this.item,
  });

  factory CoreLiveContributionRankData.fromJson(Map<String, dynamic> json) =>
      CoreLiveContributionRankData(
        item: (json['item'] as List<dynamic>?)
            ?.map(
              (e) =>
                  CoreLiveContributionRankItem.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'item': item?.map((e) => e.toJson()).toList(),
  };
}