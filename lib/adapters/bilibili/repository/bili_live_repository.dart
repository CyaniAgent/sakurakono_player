import 'package:skf/adapters/bilibili/http/live.dart';

import 'package:skf/adapters/bilibili/models/common/live/live_contribution_rank_type.dart';
import 'package:skf/adapters/bilibili/models/common/live/live_search_type.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_area_list/area_item.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_area_list/area_list.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_contribution_rank/data.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_dm_block/shield_info.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_dm_block/shield_user_list.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_dm_info/data.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_emote/datum.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_feed_index/card_data.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_feed_index/card_data_item.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_feed_index/card_data_list_item.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_feed_index/card_list.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_feed_index/data.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_follow/data.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_medal_wall/data.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_room_info_h5/data.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_room_play_info/data.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_room_play_info/playurl_info.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_room_play_info/playurl.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_room_play_info/stream.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_room_play_info/format.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_room_play_info/codec.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_room_play_info/url_info.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_search/data.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_second_list/data.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_superchat/data.dart';
import 'package:skf/core/models/live_enums.dart';
import 'package:skf/core/models/live_types.dart';
import 'package:skf/core/repository/live_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// {@template bili_live_repository}
/// Implementation of [LiveRepository] that delegates to [LiveHttp].
/// {@endtemplate}
class BiliLiveRepository implements LiveRepository {
  // ---- conversion helpers ----

  Map<String, dynamic> _roomPlayInfoToMap(RoomPlayInfoData d) => <String, dynamic>{
    'room_id': d.roomId,
    'short_id': d.shortId,
    'uid': d.uid,
    'is_portrait': d.isPortrait,
    'live_status': d.liveStatus,
    'live_time': d.liveTime,
    'playurl_info': d.playurlInfo == null ? null : _playurlInfoToMap(d.playurlInfo!),
  };

  Map<String, dynamic> _playurlInfoToMap(PlayurlInfo d) => <String, dynamic>{
    'playurl': d.playurl == null ? null : _playurlToMap(d.playurl!),
  };

  Map<String, dynamic> _playurlToMap(Playurl d) => <String, dynamic>{
    'stream': d.stream.map(_streamToMap).toList(),
  };

  Map<String, dynamic> _streamToMap(Stream d) => <String, dynamic>{
    'protocol_name': d.protocolName,
    'format': d.format.map(_formatToMap).toList(),
  };

  Map<String, dynamic> _formatToMap(Format d) => <String, dynamic>{
    'format_name': d.formatName,
    'codec': d.codec.map(_codecToMap).toList(),
  };

  Map<String, dynamic> _codecToMap(CodecItem d) => <String, dynamic>{
    'codec_name': d.codecName,
    'current_qn': d.currentQn,
    'accept_qn': d.acceptQn,
    'base_url': d.baseUrl,
    'url_info': d.urlInfo.map(_urlInfoToMap).toList(),
  };

  Map<String, dynamic> _urlInfoToMap(UrlInfo d) => <String, dynamic>{
    'host': d.host,
    'extra': d.extra,
  };

  Map<String, dynamic> _roomInfoH5ToMap(RoomInfoH5Data d) => <String, dynamic>{
    'room_info': d.roomInfo == null ? null : <String, dynamic>{
      'uid': d.roomInfo!.uid,
      'title': d.roomInfo!.title,
      'cover': d.roomInfo!.cover,
      'app_background': d.roomInfo!.appBackground,
    },
    'anchor_info': d.anchorInfo == null ? null : <String, dynamic>{
      'base_info': d.anchorInfo!.baseInfo == null ? null : <String, dynamic>{
        'uname': d.anchorInfo!.baseInfo!.uname,
        'face': d.anchorInfo!.baseInfo!.face,
      },
    },
    'watched_show': d.watchedShow == null ? null : <String, dynamic>{
      'text_large': d.watchedShow!.textLarge,
    },
  };

  Map<String, dynamic> _liveDmInfoToMap(LiveDmInfoData d) => <String, dynamic>{
    'token': d.token,
    'host_list': d.hostList.map((h) => <String, dynamic>{
      'host': h.host,
      'port': h.port,
      'wss_port': h.wssPort,
      'ws_port': h.wsPort,
    }).toList(),
  };

  Map<String, dynamic> _liveEmoteDatumToMap(LiveEmoteDatum d) => <String, dynamic>{
    'emoticons': d.emoticons?.map((e) => <String, dynamic>{
      'emoji': e.emoji,
      'url': e.url,
      'width': e.width,
      'height': e.height,
      'emoticon_unique': e.emoticonUnique,
    }).toList(),
    'pkg_type': d.pkgType,
    'current_cover': d.currentCover,
  };

  Map<String, dynamic> _liveFollowToMap(LiveFollowData d) => <String, dynamic>{
    'title': d.title,
    'pageSize': d.pageSize,
    'totalPage': d.totalPage,
    'list': d.list?.map((i) => <String, dynamic>{
      'roomid': i.roomid,
      'uname': i.uname,
      'title': i.title,
      'area_name': i.areaName,
      'text_small': i.textSmall,
      'room_cover': i.roomCover,
    }).toList(),
    'count': d.count,
    'live_count': d.liveCount,
  };

  Map<String, dynamic> _liveSecondToMap(LiveSecondData d) => <String, dynamic>{
    'count': d.count,
    'list': d.cardList?.map((c) => <String, dynamic>{
      'roomid': c.roomid,
      'uid': c.uid,
      'uname': c.uname,
      'face': c.face,
      'cover': c.cover,
      'system_cover': c.systemCover,
      'title': c.title,
      'area_name': c.areaName,
      'area_v2_id': c.areaV2Id,
      'area_v2_parent_id': c.areaV2ParentId,
      'watched_show': c.watchedShow == null ? null : <String, dynamic>{'text_large': c.watchedShow!.textLarge},
    }).toList(),
    'new_tags': d.newTags?.map((t) => <String, dynamic>{
      'name': t.name,
      'sort_type': t.sortType,
    }).toList(),
  };

  Map<String, dynamic> _areaListToMap(AreaList d) => <String, dynamic>{
    'name': d.name,
    'area_list': d.areaList?.map((a) => <String, dynamic>{
      'id': a.id,
      'name': a.name,
      'pic': a.pic,
      'parent_id': a.parentId,
      'parent_name': a.parentName,
    }).toList(),
  };

  Map<String, dynamic> _areaItemToMap(AreaItem d) => <String, dynamic>{
    'id': d.id,
    'name': d.name,
    'pic': d.pic,
    'parent_id': d.parentId,
    'parent_name': d.parentName,
  };

  Map<String, dynamic> _liveSearchToMap(LiveSearchData d) => <String, dynamic>{
    'room': d.room == null ? null : <String, dynamic>{
      'list': d.room!.list?.map((r) => <String, dynamic>{
        'roomid': r.roomid,
        'cover': r.cover,
        'title': r.title,
        'name': r.name,
        'face': r.face,
        'watched_show': r.watchedShow == null ? null : <String, dynamic>{'text_large': r.watchedShow!.textLarge},
      }).toList(),
      'total_room': d.room!.totalRoom,
    },
    'user': d.user == null ? null : <String, dynamic>{
      'list': d.user!.list?.map((u) => <String, dynamic>{
        'face': u.face,
        'name': u.name,
        'live_status': u.liveStatus,
        'areaName': u.areaName,
        'fansNum': u.fansNum,
        'roomid': u.roomid,
      }).toList(),
      'total_user': d.user!.totalUser,
    },
  };

  Map<String, dynamic> _shieldInfoToMap(ShieldInfo d) => <String, dynamic>{
    'shield_user_list': d.shieldUserList?.map((u) => <String, dynamic>{
      'uid': u.uid,
      'uname': u.uname,
    }).toList(),
    'keyword_list': d.keywordList,
    'shield_rules': d.shieldRules == null ? null : <String, dynamic>{
      'rank': d.shieldRules!.rank,
      'verify': d.shieldRules!.verify,
      'level': d.shieldRules!.level,
    },
  };

  Map<String, dynamic> _shieldUserListToMap(ShieldUserList d) => <String, dynamic>{
    'uid': d.uid,
    'uname': d.uname,
  };

  Map<String, dynamic> _superChatToMap(SuperChatData d) => <String, dynamic>{
    'list': d.list?.map((i) => i.toJson()).toList(),
  };

  Map<String, dynamic> _contributionRankToMap(LiveContributionRankData d) => <String, dynamic>{
    'item': d.item?.map((i) => <String, dynamic>{
      'uid': i.uid,
      'name': i.name,
      'face': i.face,
      'score': i.score,
      'uinfo': i.uinfoMedal == null ? null : <String, dynamic>{
        'medal': i.uinfoMedal!.toJson(),
      },
    }).toList(),
  };

  Map<String, dynamic> _medalWallToMap(MedalWallData d) => <String, dynamic>{
    'list': d.list?.map((i) => <String, dynamic>{
      'medal_info': i.medalInfo == null ? null : <String, dynamic>{'wearing_status': i.medalInfo!.wearingStatus},
      'target_name': i.targetName,
      'target_icon': i.targetIcon,
      'link': i.link,
      'live_status': i.liveStatus,
      'official': i.official,
      'uinfo_medal': i.uinfoMedal?.toJson(),
    }).toList(),
    'count': d.count,
    'name': d.name,
    'icon': d.icon,
  };

  // ---- LiveIndexData helpers ----

  Map<String, dynamic> _liveCardListToMap(LiveCardList c) => <String, dynamic>{
    'card_type': c.cardType,
    'card_data': c.cardData == null ? null : _cardDataToMap(c.cardData!),
  };

  Map<String, dynamic> _cardDataToMap(CardData d) => <String, dynamic>{
    'banner_v2': d.bannerV2 == null ? null : _cardDataItemToMap(d.bannerV2!),
    'my_idol_v1': d.myIdolV1 == null ? null : _cardDataItemToMap(d.myIdolV1!),
    'area_entrance_v3': d.areaEntranceV3 == null ? null : _cardDataItemToMap(d.areaEntranceV3!),
    'small_card_v1': d.smallCardV1 == null ? null : _cardLiveItemToMap(d.smallCardV1!),
  };

  Map<String, dynamic> _cardDataItemToMap(CardDataItem d) => <String, dynamic>{
    'list': d.list?.map(_cardLiveItemToMap).toList(),
    'extra_info': d.extraInfo == null ? null : <String, dynamic>{'total_count': d.extraInfo!.totalCount},
  };

  Map<String, dynamic> _cardLiveItemToMap(CardLiveItem d) => <String, dynamic>{
    'roomid': d.roomid,
    'uid': d.uid,
    'uname': d.uname,
    'face': d.face,
    'cover': d.cover,
    'system_cover': d.systemCover,
    'title': d.title,
    'area_name': d.areaName,
    'area_v2_id': d.areaV2Id,
    'area_v2_parent_id': d.areaV2ParentId,
    'watched_show': d.watchedShow == null ? null : <String, dynamic>{'text_large': d.watchedShow!.textLarge},
  };

  Map<String, dynamic> _liveIndexToMap(LiveIndexData d) => <String, dynamic>{
    'card_list': [
      if (d.followItem != null) _liveCardListToMap(d.followItem!),
      if (d.areaItem != null) _liveCardListToMap(d.areaItem!),
      if (d.cardList != null) ...d.cardList!.map(_liveCardListToMap),
    ],
    'has_more': d.hasMore,
  };

  // ---- interface implementation ----

  @override
  Future<LoadingState<void>> sendLiveMsg({
    required int roomId,
    required String msg,
    Object? dmType,
    Object? emoticonOptions,
    int replyMid = 0,
    String replayDmid = '',
  }) {
    return LiveHttp.sendLiveMsg(
      roomId: roomId,
      msg: msg,
      dmType: dmType,
      emoticonOptions: emoticonOptions,
      replyMid: replyMid,
      replayDmid: replayDmid,
    );
  }

  @override
  Future<LoadingState<CoreRoomPlayInfoData>> liveRoomInfo({
    required int roomId,
    Object? qn,
    bool onlyAudio = false,
  }) async {
    final result = await LiveHttp.liveRoomInfo(
      roomId: roomId,
      qn: qn,
      onlyAudio: onlyAudio,
    );
    if (result case Success(:final response)) {
      return Success(CoreRoomPlayInfoData.fromJson(_roomPlayInfoToMap(response)));
    }
    return result as LoadingState<CoreRoomPlayInfoData>;
  }

  @override
  Future<LoadingState<CoreRoomInfoH5Data>> liveRoomInfoH5({
    required int roomId,
  }) async {
    final result = await LiveHttp.liveRoomInfoH5(
      roomId: roomId,
    );
    if (result case Success(:final response)) {
      return Success(CoreRoomInfoH5Data.fromJson(_roomInfoH5ToMap(response)));
    }
    return result as LoadingState<CoreRoomInfoH5Data>;
  }

  @override
  Future<LoadingState<List<CoreDanmakuMsg>?>> liveRoomDmPrefetch({
    required int roomId,
  }) async {
    final result = await LiveHttp.liveRoomDmPrefetch(
      roomId: roomId,
    );
    if (result case Success(:final response)) {
      return Success(response?.map((e) => CoreDanmakuMsg.fromJson(e.toJson())).toList());
    }
    return result as LoadingState<List<CoreDanmakuMsg>?>;
  }

  @override
  Future<LoadingState<CoreLiveDmInfoData>> liveRoomGetDanmakuToken({
    required int roomId,
  }) async {
    final result = await LiveHttp.liveRoomGetDanmakuToken(
      roomId: roomId,
    );
    if (result case Success(:final response)) {
      return Success(CoreLiveDmInfoData.fromJson(_liveDmInfoToMap(response)));
    }
    return result as LoadingState<CoreLiveDmInfoData>;
  }

  @override
  Future<LoadingState<List<CoreLiveEmoteDatum>?>> getLiveEmoticons({
    required int roomId,
  }) async {
    final result = await LiveHttp.getLiveEmoticons(
      roomId: roomId,
    );
    if (result case Success(:final response)) {
      return Success(response?.map((e) => CoreLiveEmoteDatum.fromJson(_liveEmoteDatumToMap(e))).toList());
    }
    return result as LoadingState<List<CoreLiveEmoteDatum>?>;
  }

  @override
  Future<LoadingState<CoreLiveIndexData>> liveFeedIndex({
    required int pn,
    bool moduleSelect = false,
  }) async {
    final result = await LiveHttp.liveFeedIndex(
      pn: pn,
      moduleSelect: moduleSelect,
    );
    if (result case Success(:final response)) {
      return Success(CoreLiveIndexData.fromJson(_liveIndexToMap(response)));
    }
    return result as LoadingState<CoreLiveIndexData>;
  }

  @override
  Future<LoadingState<CoreLiveFollowData>> liveFollow(int page) async {
    final result = await LiveHttp.liveFollow(page);
    if (result case Success(:final response)) {
      return Success(CoreLiveFollowData.fromJson(_liveFollowToMap(response)));
    }
    return result as LoadingState<CoreLiveFollowData>;
  }

  @override
  Future<LoadingState<CoreLiveSecondData>> liveSecondList({
    required int pn,
    required int? areaId,
    required int? parentAreaId,
    String? sortType,
  }) async {
    final result = await LiveHttp.liveSecondList(
      pn: pn,
      areaId: areaId,
      parentAreaId: parentAreaId,
      sortType: sortType,
    );
    if (result case Success(:final response)) {
      return Success(CoreLiveSecondData.fromJson(_liveSecondToMap(response)));
    }
    return result as LoadingState<CoreLiveSecondData>;
  }

  @override
  Future<LoadingState<List<CoreAreaList>?>> liveAreaList() async {
    final result = await LiveHttp.liveAreaList();
    if (result case Success(:final response)) {
      return Success(response?.map((e) => CoreAreaList.fromJson(_areaListToMap(e))).toList());
    }
    return result as LoadingState<List<CoreAreaList>?>;
  }

  @override
  Future<LoadingState<List<CoreAreaItem>>> getLiveFavTag() async {
    final result = await LiveHttp.getLiveFavTag();
    if (result case Success(:final response)) {
      return Success(response.map((e) => CoreAreaItem.fromJson(_areaItemToMap(e))).toList());
    }
    return result as LoadingState<List<CoreAreaItem>>;
  }

  @override
  Future<LoadingState<void>> setLiveFavTag({
    required String ids,
  }) {
    return LiveHttp.setLiveFavTag(
      ids: ids,
    );
  }

  @override
  Future<LoadingState<List<CoreAreaItem>?>> liveRoomAreaList({
    required int parentid,
  }) async {
    final result = await LiveHttp.liveRoomAreaList(
      parentid: parentid,
    );
    if (result case Success(:final response)) {
      return Success(response?.map((e) => CoreAreaItem.fromJson(_areaItemToMap(e))).toList());
    }
    return result as LoadingState<List<CoreAreaItem>?>;
  }

  @override
  Future<LoadingState<CoreLiveSearchData>> liveSearch({
    required int page,
    required String keyword,
    required CoreLiveSearchType type,
  }) async {
    final result = await LiveHttp.liveSearch(
      page: page,
      keyword: keyword,
      type: LiveSearchType.values.firstWhere((e) => e.name == type.name),
    );
    if (result case Success(:final response)) {
      return Success(CoreLiveSearchData.fromJson(_liveSearchToMap(response)));
    }
    return result as LoadingState<CoreLiveSearchData>;
  }

  @override
  Future<LoadingState<CoreShieldInfo?>> getLiveInfoByUser(
    Object roomId,
  ) async {
    final result = await LiveHttp.getLiveInfoByUser(roomId);
    if (result case Success(:final response)) {
      return Success(response == null ? null : CoreShieldInfo.fromJson(_shieldInfoToMap(response)));
    }
    return result as LoadingState<CoreShieldInfo?>;
  }

  @override
  Future<LoadingState<void>> liveSetSilent({
    required String type,
    required int level,
  }) {
    return LiveHttp.liveSetSilent(
      type: type,
      level: level,
    );
  }

  @override
  Future<LoadingState<void>> addShieldKeyword({
    required String keyword,
  }) {
    return LiveHttp.addShieldKeyword(
      keyword: keyword,
    );
  }

  @override
  Future<LoadingState<void>> delShieldKeyword({
    required String keyword,
  }) {
    return LiveHttp.delShieldKeyword(
      keyword: keyword,
    );
  }

  @override
  Future<LoadingState<CoreShieldUserList>> liveShieldUser({
    required int uid,
    required int roomid,
    required int type,
  }) async {
    final result = await LiveHttp.liveShieldUser(
      uid: uid,
      roomid: roomid,
      type: type,
    );
    if (result case Success(:final response)) {
      return Success(CoreShieldUserList.fromJson(_shieldUserListToMap(response)));
    }
    return result as LoadingState<CoreShieldUserList>;
  }

  @override
  Future<LoadingState<void>> liveLikeReport({
    required int clickTime,
    required int roomId,
    required int uid,
    Object? anchorId,
  }) {
    return LiveHttp.liveLikeReport(
      clickTime: clickTime,
      roomId: roomId,
      uid: uid,
      anchorId: anchorId,
    );
  }

  @override
  Future<LoadingState<CoreSuperChatData>> superChatMsg(
    Object roomId,
  ) async {
    final result = await LiveHttp.superChatMsg(roomId);
    if (result case Success(:final response)) {
      return Success(CoreSuperChatData.fromJson(_superChatToMap(response)));
    }
    return result as LoadingState<CoreSuperChatData>;
  }

  @override
  Future<LoadingState<void>> liveDmReport({
    required int roomId,
    required int mid,
    required String msg,
    required String reason,
    required int reasonId,
    required int dmType,
    required String idStr,
    required int ts,
    required String sign,
  }) {
    return LiveHttp.liveDmReport(
      roomId: roomId,
      mid: mid,
      msg: msg,
      reason: reason,
      reasonId: reasonId,
      dmType: dmType,
      idStr: idStr,
      ts: ts,
      sign: sign,
    );
  }

  @override
  Future<LoadingState<CoreLiveContributionRankData>> liveContributionRank({
    required int ruid,
    required int roomId,
    required int page,
    required CoreLiveContributionRankType type,
  }) async {
    final result = await LiveHttp.liveContributionRank(
      ruid: ruid,
      roomId: roomId,
      page: page,
      type: LiveContributionRankType.values.firstWhere((e) => e.name == type.name),
    );
    if (result case Success(:final response)) {
      return Success(CoreLiveContributionRankData.fromJson(_contributionRankToMap(response)));
    }
    return result as LoadingState<CoreLiveContributionRankData>;
  }

  @override
  Future<LoadingState<void>> superChatReport({
    required int id,
    required int roomId,
    required int uid,
    required String msg,
    required String reason,
    required int ts,
    required String token,
  }) {
    return LiveHttp.superChatReport(
      id: id,
      roomId: roomId,
      uid: uid,
      msg: msg,
      reason: reason,
      ts: ts,
      token: token,
    );
  }

  @override
  Future<LoadingState<CoreMedalWallData>> liveMedalWall({
    required int mid,
  }) async {
    final result = await LiveHttp.liveMedalWall(
      mid: mid,
    );
    if (result case Success(:final response)) {
      return Success(CoreMedalWallData.fromJson(_medalWallToMap(response)));
    }
    return result as LoadingState<CoreMedalWallData>;
  }
}
