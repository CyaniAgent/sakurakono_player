import 'package:skf/adapters/bilibili/http/member.dart';
import 'package:skf/adapters/bilibili/models/common/member/archive_order_type_app.dart';
import 'package:skf/adapters/bilibili/models/common/member/archive_order_type_web.dart';
import 'package:skf/adapters/bilibili/models/common/member/archive_sort_type_app.dart';
import 'package:skf/adapters/bilibili/models/common/member/contribute_type.dart';
import 'package:skf/adapters/bilibili/models/common/member/web_ss_type.dart';
import 'package:skf/adapters/bilibili/models/dynamics/result.dart';
import 'package:skf/adapters/bilibili/models/member/info.dart';
import 'package:skf/adapters/bilibili/models/member/tags.dart';
import 'package:skf/adapters/bilibili/models_new/follow/data.dart';
import 'package:skf/adapters/bilibili/models_new/member/coin_like_arc/data.dart';
import 'package:skf/adapters/bilibili/models_new/member/search_archive/data.dart';
import 'package:skf/adapters/bilibili/models_new/member/season_web/data.dart';
import 'package:skf/adapters/bilibili/models_new/member_card_info/data.dart';
import 'package:skf/adapters/bilibili/models_new/member_guard/data.dart';
import 'package:skf/adapters/bilibili/models_new/space/space/data.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_archive/data.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_article/data.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_audio/data.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_cheese/data.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_season_series/item.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_shop/data.dart';
import 'package:skf/adapters/bilibili/models_new/upower_rank/data.dart';
import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/models/space_types.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Implementation of [MemberRepository] that delegates to [MemberHttp].
///
/// Converts adapter models to core types via private `_*ToMap` helpers
/// consumed by `Core*.fromJson`.
class BiliMemberRepository implements MemberRepository {
  // ---- generic LoadingState mapper ----

  LoadingState<T> _mapSuccess<T, A>(LoadingState<A> state, T Function(A) convert) {
    if (state case Success(:final response)) {
      return Success(convert(response));
    }
    return state as LoadingState<T>;
  }

  // ===================================================================
  // Conversion helpers
  // ===================================================================

  // ---- MemberInfoModel -> CoreMemberInfoModel ----

  Map<String, dynamic> _memberInfoToMap(MemberInfoModel d) => <String, dynamic>{
    'mid': d.mid,
    'name': d.name,
    'sex': d.sex,
    'face': d.face,
    'sign': d.sign,
    'level': d.level,
    'is_followed': d.isFollowed,
    'top_photo': d.topPhoto,
    'official': d.official == null ? null : _baseOfficialVerifyToMap(d.official!),
    'CoreVip': d.vip == null ? null : _vipToMap(d.vip!),
    'live_room': d.liveRoom == null ? null : _liveRoomToMap(d.liveRoom!),
    'is_senior_member': d.isSeniorMember,
  };

  Map<String, dynamic> _baseOfficialVerifyToMap(dynamic d) => <String, dynamic>{
    'type': d.type,
    'CoreDesc': d.desc,
  };

  Map<String, dynamic> _vipToMap(dynamic d) => <String, dynamic>{
    'type': d.type,
    'status': d.status,
    'vipType': d.type,
    'vipStatus': d.status,
  };

  Map<String, dynamic> _liveRoomToMap(dynamic d) => <String, dynamic>{
    'roomStatus': d.roomStatus,
    'liveStatus': d.liveStatus,
    'url': d.url,
    'title': d.title,
    'cover': d.cover,
    'roomid': d.roomId,
    'roundStatus': d.roundStatus,
    'watched_show': d.watchedShow == null ? null : _watchedShowToMap(d.watchedShow!),
  };

  Map<String, dynamic> _watchedShowToMap(dynamic d) => <String, dynamic>{
    'num': d.num,
    'text': d.text,
  };

  // ---- MemberCardInfoData -> CoreMemberCardInfoData ----

  Map<String, dynamic> _memberCardInfoToMap(MemberCardInfoData d) => <String, dynamic>{
    'CoreCard': d.card == null ? null : _cardToMap(d.card!),
    'archive_count': d.archiveCount,
    'follower': d.follower,
  };

  Map<String, dynamic> _cardToMap(dynamic d) => <String, dynamic>{
    'mid': d.mid,
    'name': d.name,
    'face': d.face,
    'Official': d.official == null ? null : _baseOfficialVerifyToMap(d.official!),
    'CoreVip': d.vip == null ? null : _vipToMap(d.vip!),
  };

  // ---- MemberTagItemModel -> CoreMemberTagItemModel ----

  Map<String, dynamic> _memberTagItemToMap(MemberTagItemModel d) => <String, dynamic>{
    'count': d.count,
    'name': d.name,
    'tagid': d.tagid,
    'tip': d.tip,
  };

  // ---- FollowData -> CoreFollowData ----

  Map<String, dynamic> _followDataToMap(FollowData d) => <String, dynamic>{
    'list': d.list?.map(_followItemToMap).toList(),
    'total': d.total,
  };

  Map<String, dynamic> _followItemToMap(dynamic d) => <String, dynamic>{
    'mid': d.mid,
    'uname': d.uname,
    'face': d.face,
    'attribute': d.attribute,
    'sign': d.sign,
    'official_verify': d.officialVerify?.toJson(),
  };

  // ---- SpaceArticleData -> CoreSpaceArticleData ----

  Map<String, dynamic> _spaceArticleDataToMap(SpaceArticleData d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map(_spaceArticleItemToMap).toList(),
    'lists_count': d.listsCount,
  };

  Map<String, dynamic> _spaceArticleItemToMap(dynamic d) => <String, dynamic>{
    'title': d.title,
    'CoreStats': d.stats == null ? null : _articleStatsToMap(d.stats!),
    'origin_image_urls': d.originImageUrls,
    'uri': d.uri,
    'publish_time_text': d.publishTimeText,
  };

  Map<String, dynamic> _articleStatsToMap(dynamic d) => <String, dynamic>{
    'view': d.view,
    'reply': d.reply,
  };

  // ---- SpaceSsData -> CoreSpaceSsData ----

  Map<String, dynamic> _spaceSsDataToMap(SpaceSsData d) => <String, dynamic>{
    'CorePage': d.page == null ? null : _spaceSsPageToMap(d.page!),
    'seasons_list': d.seasonsList?.map(_spaceSsModelToMap).toList(),
    'series_list': d.seriesList?.map(_spaceSsModelToMap).toList(),
  };

  Map<String, dynamic> _spaceSsPageToMap(dynamic d) => <String, dynamic>{
    'total': d.total,
  };

  Map<String, dynamic> _spaceSsModelToMap(dynamic d) => <String, dynamic>{
    'meta': d.meta == null ? null : _spaceSsMetaToMap(d.meta!),
  };

  Map<String, dynamic> _spaceSsMetaToMap(dynamic d) => <String, dynamic>{
    'cover': d.cover,
    'name': d.name,
    'ptime': d.ptime,
    'total': d.total,
    'season_id': d.seasonId,
    'series_id': d.seriesId,
  };

  // ---- SpaceArchiveData -> CoreSpaceArchiveData ----

  Map<String, dynamic> _spaceArchiveDataToMap(SpaceArchiveData d) => <String, dynamic>{
    'episodic_button': d.episodicButton == null ? null : _episodicButtonToMap(d.episodicButton!),
    'count': d.count,
    'item': d.item?.map(_spaceArchiveItemToMap).toList(),
    'has_next': d.hasNext,
    'has_prev': d.hasPrev,
    'next': d.next,
  };

  Map<String, dynamic> _episodicButtonToMap(dynamic d) => <String, dynamic>{
    'text': d.text,
    'uri': d.uri,
  };

  Map<String, dynamic> _spaceArchiveItemToMap(dynamic d) => <String, dynamic>{
    'title': d.title,
    'cover': d.cover,
    'uri': d.uri,
    'param': d.param,
    'goto': d.goto,
    'length': d.length,
    'duration': d.duration,
    'is_steins': d.isSteins,
    'is_cooperation': d.isCooperation,
    'is_pgc': d.isPgc,
    'is_pugv': d.isPugv,
    'bvid': d.bvid,
    'first_cid': d.cid,
    'publish_time_text': d.publishTimeText,
    'badges': d.badges?.map(_badgeToMap).toList(),
    'season': d.season == null ? null : _spaceArchiveSeasonToMap(d.season!),
    'CoreHistory': d.history == null ? null : _historyToMap(d.history!),
    'styles': d.styles,
    'label': d.label,
    'play': d.stat?.view,
    'danmaku': d.stat?.danmu,
    'mid': d.owner?.mid,
    'author': d.owner?.name,
  };

  Map<String, dynamic> _badgeToMap(dynamic d) => <String, dynamic>{
    'text': d.text,
  };

  Map<String, dynamic> _spaceArchiveSeasonToMap(dynamic d) => <String, dynamic>{
    'mtime': d.mtime,
  };

  Map<String, dynamic> _historyToMap(dynamic d) => <String, dynamic>{
    'progress': d.progress,
    'duration': d.duration,
  };

  // ---- SpaceAudioData -> CoreSpaceAudioData ----

  Map<String, dynamic> _spaceAudioDataToMap(SpaceAudioData d) => <String, dynamic>{
    'totalSize': d.totalSize,
    'data': d.items?.map(_spaceAudioItemToMap).toList(),
  };

  Map<String, dynamic> _spaceAudioItemToMap(dynamic d) => <String, dynamic>{
    'id': d.id,
    'title': d.title,
    'cover': d.cover,
    'author': d.author,
  };

  // ---- SpaceCheeseData -> CoreSpaceCheeseData ----

  Map<String, dynamic> _spaceCheeseDataToMap(SpaceCheeseData d) => <String, dynamic>{
    'items': d.items?.map(_spaceCheeseItemToMap).toList(),
    'CorePage': d.page == null ? null : _spaceCheesePageToMap(d.page!),
  };

  Map<String, dynamic> _spaceCheeseItemToMap(dynamic d) => <String, dynamic>{
    'id': d.id,
    'title': d.title,
    'cover': d.cover,
    'subtitle': d.subtitle,
  };

  Map<String, dynamic> _spaceCheesePageToMap(dynamic d) => <String, dynamic>{
    'total': d.total,
    'num': d.num,
  };

  // ---- SpaceData -> CoreSpaceData (space overview) ----
  // The adapter and core models differ in key naming and structure.
  // Only the fields that CoreSpaceData.fromJson actually reads are emitted.

  Map<String, dynamic> _spaceDataToMap(SpaceData d) => <String, dynamic>{
    'relation': d.relation,
    'guest_relation': d.guestRelation,
    'medal': d.medal,
    'default_tab': d.defaultTab,
    'setting': d.setting == null ? null : _spaceSettingToMap(d.setting!),
    'tab': null, // adapter SpaceTab (booleans) ≠ CoreSpaceTab (name/uri)
    'CoreCard': d.card == null ? null : _spaceCardToMap(d.card!),
    'images': d.images == null ? null : {'img_count': null}, // adapter SpaceImages has URLs, not count
    'CoreLive': d.live == null ? null : _spaceLiveToMap(d.live!),
    'CoreElec': d.elec == null ? null : _spaceElecToMap(d.elec!),
    'CoreArchive': d.archive == null ? null : _spaceArchiveItemListToMap(d.archive!),
    'series': d.series == null ? null : _spaceSeriesToMap(d.series!),
    'CoreArticle': d.article == null ? null : _spaceArticleListToMap(d.article!),
    'season': d.season == null ? null : _spaceSeasonToMap(d.season!),
    'coin_archive': d.coinArchive == null ? null : _spaceCoinArchiveToMap(d.coinArchive!),
    'like_archive': d.likeArchive == null ? null : _spaceLikeArchiveToMap(d.likeArchive!),
    'CoreAudios': d.audios == null ? null : _spaceAudiosToMap(d.audios!),
    'CoreFavourite2': d.favourite2 == null ? null : _spaceFavourite2ToMap(d.favourite2!),
    'CoreComic': d.comic == null ? null : _spaceComicToMap(d.comic!),
    'ugc_season': d.ugcSeason == null ? null : _spaceUgcSeasonToMap(d.ugcSeason!),
    'CoreCheese': d.cheese == null ? null : _spaceCheeseListToMap(d.cheese!),
    'CoreGuard': d.guard == null ? null : _spaceGuardToMap(d.guard!),
    'tab2': d.tab2?.map(_spaceTab2ToMap).toList(),
    'rel_special': d.relSpecial,
    'reservation_card_list': d.reservationCardList?.map(_reservationCardItemToMap).toList(),
  };

  Map<String, dynamic> _spaceSettingToMap(dynamic d) => <String, dynamic>{
    'like': d.like,
    'attention': d.attention,
    'space': d.space,
  };

  Map<String, dynamic> _spaceCardToMap(dynamic d) => <String, dynamic>{
    'face': d.face,
    'name': d.name,
    'mid': d.mid is String ? int.tryParse(d.mid as String) : d.mid,
    'vip': d.vip == null
        ? null
        : <String, dynamic>{'type': d.vip.type, 'status': d.vip.status},
  };

  Map<String, dynamic> _spaceLiveToMap(dynamic d) => <String, dynamic>{
    'liveStatus': d.liveStatus,
  };

  Map<String, dynamic> _spaceElecToMap(dynamic d) => <String, dynamic>{
    'total': d.total,
  };

  Map<String, dynamic> _spaceArchiveItemListToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map((e) => <String, dynamic>{
      'title': e.title,
      'cover': e.cover,
      'play': e.stat?.view,
      'danmaku': e.stat?.danmu,
      'bvid': e.bvid,
      'cid': e.cid,
      'duration': e.duration,
      'uri': e.uri,
      'goto': e.goto,
      'is_steins': e.isSteins,
      'is_cooperation': e.isCooperation,
      'is_pgc': e.isPgc,
      'is_pugv': e.isPugv,
      'param': e.param,
      'length': e.length,
      'publish_time_text': e.publishTimeText,
      'ownerMid': e.owner?.mid,
      'ownerName': e.owner?.name,
    }).toList(),
  };

  Map<String, dynamic> _spaceSeriesToMap(dynamic d) => <String, dynamic>{
    'item': d.item?.map((e) => <String, dynamic>{
      'title': e.title,
      'cover': e.cover,
    }).toList(),
  };

  Map<String, dynamic> _spaceArticleListToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map((e) => <String, dynamic>{
      'title': e.title,
      'CoreStats': e.stats == null ? null : _articleStatsToMap(e.stats!),
      'origin_image_urls': e.originImageUrls,
      'uri': e.uri,
      'publish_time_text': e.publishTimeText,
    }).toList(),
    'lists_count': d.listsCount,
  };

  Map<String, dynamic> _spaceSeasonToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map((e) => <String, dynamic>{
      'title': e.title,
      'cover': e.cover,
    }).toList(),
    'cover': d.cover,
  };

  Map<String, dynamic> _spaceCoinArchiveToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map((e) => <String, dynamic>{
      'title': e.title,
      'cover': e.cover,
    }).toList(),
  };

  Map<String, dynamic> _spaceLikeArchiveToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map((e) => <String, dynamic>{
      'title': e.title,
      'cover': e.cover,
    }).toList(),
  };

  Map<String, dynamic> _spaceAudiosToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map((e) => <String, dynamic>{
      'title': e.title,
      'cover': e.cover,
    }).toList(),
  };

  Map<String, dynamic> _spaceFavourite2ToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map((e) => <String, dynamic>{
      'title': e.title,
      'cover': e.cover,
    }).toList(),
  };

  Map<String, dynamic> _spaceComicToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map((e) => <String, dynamic>{
      'title': e.title,
      'cover': e.cover,
    }).toList(),
  };

  Map<String, dynamic> _spaceUgcSeasonToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map((e) => <String, dynamic>{
      'title': e.title,
      'cover': e.cover,
    }).toList(),
  };

  Map<String, dynamic> _spaceCheeseListToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map((e) => <String, dynamic>{
      'title': e.title,
      'cover': e.cover,
    }).toList(),
  };

  Map<String, dynamic> _spaceGuardToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map((e) => <String, dynamic>{
      'name': e.name,
      'face': e.face,
    }).toList(),
  };

  Map<String, dynamic> _spaceTab2ToMap(dynamic d) => <String, dynamic>{
    'name': d.name,
    'uri': d.uri,
  };

  Map<String, dynamic> _reservationCardItemToMap(dynamic d) => <String, dynamic>{
    'rid': d.rid,
    'title': d.title,
  };

  // ---- SearchArchiveData -> CoreSearchArchiveData ----

  Map<String, dynamic> _searchArchiveDataToMap(SearchArchiveData d) => <String, dynamic>{
    'list': d.list == null ? null : _searchArchiveListToMap(d.list!),
    'CorePage': d.page == null ? null : _searchPageToMap(d.page!),
  };

  Map<String, dynamic> _searchArchiveListToMap(dynamic d) => <String, dynamic>{
    'vlist': d.vlist?.map(_vListItemToMap).toList(),
    'slist': d.tags?.map(_listTagToMap).toList(),
  };

  Map<String, dynamic> _vListItemToMap(dynamic d) => <String, dynamic>{
    'title': d.title,
    'author': d.owner?.name,
    'CorePic': d.cover,
    'bvid': d.bvid,
    'play': d.stat?.view,
    'video_review': d.stat?.danmu,
  };

  Map<String, dynamic> _listTagToMap(dynamic d) => <String, dynamic>{
    'tid': d.tid,
    'name': d.name,
  };

  Map<String, dynamic> _searchPageToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'total': null,
  };

  // ---- SeasonWebData -> CoreSeasonWebData ----

  Map<String, dynamic> _seasonWebDataToMap(SeasonWebData d) => <String, dynamic>{
    'archives': d.archives?.map(_seasonArchiveToMap).toList(),
    'CorePage': d.page == null ? null : _seasonWebPageToMap(d.page!),
  };

  Map<String, dynamic> _seasonArchiveToMap(dynamic d) => <String, dynamic>{
    'aid': d.aid,
    'bvid': d.bvid,
    'CorePic': d.cover,
    'title': d.title,
    'pubdate': d.pubdate,
    'duration': d.duration,
    'view': d.stat?.view,
    'danmaku': d.stat?.danmu,
    'upMid': d.owner?.mid,
  };

  Map<String, dynamic> _seasonWebPageToMap(dynamic d) => <String, dynamic>{
    'count': null,
    'total': d.total,
  };

  // ---- DynamicsDataModel -> CoreDynamicsDataModel ----

  Map<String, dynamic> _dynamicsDataModelToMap(DynamicsDataModel d) => <String, dynamic>{
    'has_more': d.hasMore,
    'items': d.items?.map(_dynamicItemToMap).toList(),
    'offset': d.offset,
    'total': d.total,
  };

  Map<String, dynamic> _dynamicItemToMap(DynamicItemModel d) => <String, dynamic>{
    'basic': d.basic == null ? null : _dynamicBasicToMap(d.basic!),
    'id_str': d.idStr,
    'modules': _itemModulesToMap(d.modules),
    'orig': d.orig == null ? null : _dynamicItemToMap(d.orig!),
    'type': d.type,
    'visible': d.visible,
    'CoreFallback': d.fallback == null ? null : _fallbackToMap(d.fallback!),
  };

  Map<String, dynamic> _dynamicBasicToMap(dynamic d) => <String, dynamic>{
    'comment_id_str': d.commentIdStr,
    'comment_type': d.commentType,
    'rid_str': d.ridStr,
  };

  Map<String, dynamic> _itemModulesToMap(ItemModulesModel d) => <String, dynamic>{
    'module_author': d.moduleAuthor == null ? null : _moduleAuthorToMap(d.moduleAuthor!),
    'module_dynamic': d.moduleDynamic == null ? null : _moduleDynamicToMap(d.moduleDynamic!),
    'module_stat': d.moduleStat == null ? null : _moduleStatToMap(d.moduleStat!),
    'module_tag': d.moduleTag == null ? null : _moduleTagToMap(d.moduleTag!),
    'module_fold': d.moduleFold == null ? null : _moduleFoldToMap(d.moduleFold!),
  };

  Map<String, dynamic> _moduleAuthorToMap(dynamic d) => <String, dynamic>{
    'mid': d.mid,
    'name': d.name,
    'face': d.face,
    'pub_action': d.pubAction,
    'pub_time': d.pubTime,
    'pub_ts': d.pubTs,
    'type': d.type,
    'CoreDecorate': d.decorate == null ? null : _decorateToMap(d.decorate!),
    'is_top': d.isTop,
    'icon_badge': d.badgeText == null ? null : {'text': d.badgeText},
    'official': d.officialVerify == null ? null : _baseOfficialVerifyToMap(d.officialVerify!),
  };

  Map<String, dynamic> _decorateToMap(dynamic d) => <String, dynamic>{
    'card_url': d.cardUrl,
    'fan': d.fan == null ? null : _fanToMap(d.fan!),
  };

  Map<String, dynamic> _fanToMap(dynamic d) => <String, dynamic>{
    'color': d.color,
    'num_str': d.numStr,
  };

  Map<String, dynamic> _moduleDynamicToMap(dynamic d) => <String, dynamic>{
    'additional': d.additional == null ? null : _dynamicAddModelToMap(d.additional!),
    'desc': d.desc == null ? null : _dynamicDescToMap(d.desc!),
    'major': d.major == null ? null : _dynamicMajorToMap(d.major!),
    'topic': d.topic == null ? null : _dynamicTopicToMap(d.topic!),
  };

  Map<String, dynamic> _dynamicAddModelToMap(dynamic d) => <String, dynamic>{
    'type': d.type,
    'vote': d.vote == null ? null : _voteToMap(d.vote!),
    'ugc': d.ugc == null ? null : _ugcToMap(d.ugc!),
    'reserve': d.reserve == null ? null : _reserveToMap(d.reserve!),
    'goods': d.goods == null ? null : _goodsToMap(d.goods!),
    'upower_lottery': d.upowerLottery == null ? null : _upowerLotteryToMap(d.upowerLottery!),
  };

  Map<String, dynamic> _voteToMap(dynamic d) => <String, dynamic>{
    'join_num': d.joinNum,
    'vote_id': d.voteId,
    'title': d.title,
  };

  Map<String, dynamic> _ugcToMap(dynamic d) => <String, dynamic>{
    'cover': d.cover,
    'desc_second': d.descSecond,
    'jump_url': d.jumpUrl,
    'title': d.title,
  };

  Map<String, dynamic> _reserveToMap(dynamic d) => <String, dynamic>{
    'title': d.title,
    'desc1': d.desc1 == null ? null : _descToMap(d.desc1!),
    'desc2': d.desc2 == null ? null : _descToMap(d.desc2!),
    'desc3': d.desc3 == null ? null : _descToMap(d.desc3!),
    'reserve_total': d.reserveTotal,
    'rid': d.rid,
    'state': d.state,
  };

  Map<String, dynamic> _descToMap(dynamic d) => <String, dynamic>{
    'text': d.text,
    'jump_url': d.jumpUrl,
  };

  Map<String, dynamic> _goodsToMap(dynamic d) => <String, dynamic>{
    'items': d.items?.map((e) => <String, dynamic>{
      'cover': e.cover,
      'jump_desc': e.jumpDesc,
      'jump_url': e.jumpUrl,
      'name': e.name,
      'price': e.price,
    }).toList(),
  };

  Map<String, dynamic> _upowerLotteryToMap(dynamic d) => <String, dynamic>{
    'title': d.title,
    'desc': d.desc == null ? null : _descToMap(d.desc!),
    'jump_url': d.jumpUrl,
  };

  Map<String, dynamic> _dynamicDescToMap(dynamic d) => <String, dynamic>{
    'rich_text_nodes': d.richTextNodes?.map((e) => <String, dynamic>{
      'text': e.text,
      'type': e.type,
      'orig_text': e.origText,
      'rid': e.rid,
      'emoji': e.emoji == null ? null : _emojiToMap(e.emoji!),
    }).toList(),
    'text': d.text,
  };

  Map<String, dynamic> _emojiToMap(dynamic d) => <String, dynamic>{
    'webp_url': d.url,
    'gif_url': d.url,
    'size': d.size,
  };

  Map<String, dynamic> _dynamicMajorToMap(dynamic d) => <String, dynamic>{
    'type': d.type,
    'archive': d.archive == null ? null : _dynamicArchiveToMap(d.archive!),
    'ugc_season': d.ugcSeason == null ? null : _dynamicArchiveToMap(d.ugcSeason!),
    'opus': d.opus == null ? null : _dynamicOpusToMap(d.opus!),
    'pgc': d.pgc == null ? null : _dynamicArchiveToMap(d.pgc!),
    'live_rcmd': d.liveRcmd == null ? null : _dynamicLiveRcmdToMap(d.liveRcmd!),
    'live': d.live == null ? null : _dynamicLive2ToMap(d.live!),
    'courses': d.courses == null ? null : _dynamicArchiveToMap(d.courses!),
    'common': d.common == null ? null : _commonToMap(d.common!),
    'music': d.music == null ? null : _musicToMap(d.music!),
  };

  Map<String, dynamic> _dynamicArchiveToMap(dynamic d) => <String, dynamic>{
    'id': d.id ?? d.aid,
    'aid': d.aid,
    'badge': d.badge == null ? null : _badgeToMap(d.badge!),
    'bvid': d.bvid,
    'cover': d.cover,
    'duration_text': d.durationText,
    'jump_url': d.jumpUrl,
    'stat': d.stat == null ? null : _archiveStatToMap(d.stat!),
    'title': d.title,
    'type': d.type,
    'epid': d.epid,
    'season_id': d.seasonId,
  };

  Map<String, dynamic> _archiveStatToMap(dynamic d) => <String, dynamic>{
    'danmaku': d.danmu,
    'play': d.play,
  };

  Map<String, dynamic> _dynamicOpusToMap(dynamic d) => <String, dynamic>{
    'pics': d.pics?.map((e) => <String, dynamic>{
      'width': e.width,
      'height': e.height,
      'url': e.url,
      'src': e.src,
    }).toList(),
    'summary': d.summary == null ? null : _summaryToMap(d.summary!),
    'title': d.title,
  };

  Map<String, dynamic> _summaryToMap(dynamic d) => <String, dynamic>{
    'rich_text_nodes': d.richTextNodes?.map((e) => <String, dynamic>{
      'text': e.text,
      'type': e.type,
      'rid': e.rid,
    }).toList(),
    'text': d.text,
  };

  Map<String, dynamic> _dynamicLiveRcmdToMap(dynamic d) => <String, dynamic>{
    'content': d.content == null ? null : _liveRcmdContentToMap(d.content!),
  };

  Map<String, dynamic> _liveRcmdContentToMap(dynamic d) => <String, dynamic>{
    'live_play_info': d.livePlayInfo == null ? null : _livePlayInfoToMap(d.livePlayInfo!),
  };

  Map<String, dynamic> _livePlayInfoToMap(dynamic d) => <String, dynamic>{
    'room_id': d.roomId,
    'live_status': d.liveStatus,
    'title': d.title,
    'cover': d.cover,
    'area_name': d.areaName,
  };

  Map<String, dynamic> _dynamicLive2ToMap(dynamic d) => <String, dynamic>{
    'id': d.id,
    'title': d.title,
    'cover': d.cover,
    'desc_first': d.descFirst,
    'live_state': d.liveState,
    'badge': d.badge == null ? null : _badgeToMap(d.badge!),
  };

  Map<String, dynamic> _commonToMap(dynamic d) => <String, dynamic>{
    'cover': d.cover,
    'title': d.title,
    'desc': d.desc,
    'jump_url': d.jumpUrl,
    'button': d.button == null ? null : _buttonToMap(d.button!),
  };

  Map<String, dynamic> _buttonToMap(dynamic d) => <String, dynamic>{
    'icon': d.icon,
    'jump_url': d.jumpUrl,
    'text': d.text,
  };

  Map<String, dynamic> _musicToMap(dynamic d) => <String, dynamic>{
    'id': d.id,
    'cover': d.cover,
    'title': d.title,
    'label': d.label,
  };

  Map<String, dynamic> _dynamicTopicToMap(dynamic d) => <String, dynamic>{
    'id': d.id,
    'name': d.name,
  };

  Map<String, dynamic> _moduleStatToMap(dynamic d) => <String, dynamic>{
    'comment': d.comment == null ? null : _dynamicStatToMap(d.comment!),
    'forward': d.forward == null ? null : _dynamicStatToMap(d.forward!),
    'like': d.like == null ? null : _dynamicStatToMap(d.like!),
    'favorite': d.favorite == null ? null : _dynamicStatToMap(d.favorite!),
  };

  Map<String, dynamic> _dynamicStatToMap(dynamic d) => <String, dynamic>{
    'count': d.count,
    'status': d.status,
  };

  Map<String, dynamic> _moduleTagToMap(dynamic d) => <String, dynamic>{
    'text': d.text,
  };

  Map<String, dynamic> _moduleFoldToMap(dynamic d) => <String, dynamic>{
    'ids': d.ids,
    'statement': d.statement,
    'users': d.users?.map((e) => <String, dynamic>{
      'mid': e.mid,
      'name': e.name,
      'face': e.face,
    }).toList(),
  };

  Map<String, dynamic> _fallbackToMap(dynamic d) => <String, dynamic>{
    'id': d.id,
  };

  // ---- MemberGuardData -> CoreMemberGuardData ----

  Map<String, dynamic> _memberGuardDataToMap(MemberGuardData d) => <String, dynamic>{
    'guard_top_list': d.guardTopList.map(_guardItemToMap).toList(),
    'has_more': d.hasMore,
  };

  Map<String, dynamic> _guardItemToMap(dynamic d) => <String, dynamic>{
    'uid': d.uid,
    'username': d.username,
    'face': d.face,
    'guard_level': d.guardLevel,
  };

  // ---- CoinLikeArcData -> CoreCoinLikeArcData ----

  Map<String, dynamic> _coinLikeArcDataToMap(CoinLikeArcData d) => <String, dynamic>{
    'count': d.count,
    'item': d.item?.map(_coinLikeArcItemToMap).toList(),
  };

  Map<String, dynamic> _coinLikeArcItemToMap(dynamic d) => <String, dynamic>{
    'title': d.title,
    'cover': d.cover,
    'uri': d.uri,
    'param': d.param,
    'duration': d.duration,
    'is_steins': d.isSteins,
    'is_cooperation': d.isCooperation,
    'is_pgc': d.isPgc,
    'play': d.play,
    'danmaku': d.danmaku,
    'ctime': d.ctime,
  };

  // ---- UpowerRankData -> CoreUpowerRankData ----

  Map<String, dynamic> _upowerRankDataToMap(UpowerRankData d) => <String, dynamic>{
    'rank_info': d.rankInfo?.map(_upowerRankInfoToMap).toList(),
    'privilege_type': d.privilegeType,
    'tabs': d.tabs,
    'level_info': d.levelInfo?.map(_levelInfoToMap).toList(),
  };

  Map<String, dynamic> _upowerRankInfoToMap(dynamic d) => <String, dynamic>{
    'mid': d.mid,
    'nickname': d.nickname,
    'avatar': d.avatar,
    'day': d.day,
  };

  Map<String, dynamic> _levelInfoToMap(dynamic d) => <String, dynamic>{
    'privilege_type': d.privilegeType,
    'name': d.name,
    'member_total': d.memberTotal,
  };

  // ---- SpaceShopData -> CoreSpaceShopData ----

  Map<String, dynamic> _spaceShopDataToMap(SpaceShopData d) => <String, dynamic>{
    'data': d.data?.map(_spaceShopItemToMap).toList(),
    'showMoreTab': d.showMoreTab,
    'clickUrl': d.clickUrl,
    'showMoreDesc': d.showMoreDesc,
    'haveNextPage': d.haveNextPage,
  };

  Map<String, dynamic> _spaceShopItemToMap(dynamic d) => <String, dynamic>{
    'title': d.title,
    'cardUrl': d.cardUrl,
    'cover': d.cover == null ? null : {'url': d.cover.url},
  };

  // ===================================================================
  // Interface implementation
  // ===================================================================

  @override
  Future<void> reportMember(
    dynamic mid, {
    String? reason,
    int? reasonV2,
  }) {
    return MemberHttp.reportMember(mid, reason: reason, reasonV2: reasonV2);
  }

  @override
  Future<LoadingState<CoreSpaceArticleData>> spaceArticle({
    required int mid,
    required int page,
  }) async {
    final result = await MemberHttp.spaceArticle(mid: mid, page: page);
    return _mapSuccess(result, (data) => CoreSpaceArticleData.fromJson(_spaceArticleDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreSpaceSsData>> seasonSeriesList({
    required int? mid,
    required int pn,
  }) async {
    final result = await MemberHttp.seasonSeriesList(mid: mid, pn: pn);
    return _mapSuccess(result, (data) => CoreSpaceSsData.fromJson(_spaceSsDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreSpaceArchiveData>> spaceArchive({
    required CoreContributeType type,
    required int? mid,
    String? aid,
    CoreArchiveOrderTypeApp? order,
    CoreArchiveSortTypeApp? sort,
    int? pn,
    int? next,
    int? seasonId,
    int? seriesId,
    bool? includeCursor,
  }) async {
    final result = await MemberHttp.spaceArchive(
      type: ContributeType.values.firstWhere((e) => e.name == type.name),
      mid: mid,
      aid: aid,
      order: order == null ? null : ArchiveOrderTypeApp.values.firstWhere((e) => e.name == order.name),
      sort: sort == null ? null : ArchiveSortTypeApp.values.firstWhere((e) => e.name == sort.name),
      pn: pn,
      next: next,
      seasonId: seasonId,
      seriesId: seriesId,
      includeCursor: includeCursor,
    );
    return _mapSuccess(result, (data) => CoreSpaceArchiveData.fromJson(_spaceArchiveDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreSpaceAudioData>> spaceAudio({
    required int page,
    required mid,
  }) async {
    final result = await MemberHttp.spaceAudio(page: page, mid: mid);
    return _mapSuccess(result, (data) => CoreSpaceAudioData.fromJson(_spaceAudioDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreSpaceCheeseData>> spaceCheese({
    required int page,
    required mid,
  }) async {
    final result = await MemberHttp.spaceCheese(page: page, mid: mid);
    return _mapSuccess(result, (data) => CoreSpaceCheeseData.fromJson(_spaceCheeseDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreSpaceData>> space({
    int? mid,
    dynamic fromViewAid,
  }) async {
    final result = await MemberHttp.space(mid: mid, fromViewAid: fromViewAid);
    return _mapSuccess(result, (data) => CoreSpaceData.fromJson(_spaceDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreMemberInfoModel>> memberInfo({
    required int mid,
    String token = '',
  }) async {
    final result = await MemberHttp.memberInfo(mid: mid, token: token);
    return _mapSuccess(result, (data) => CoreMemberInfoModel.fromJson(_memberInfoToMap(data)));
  }

  @override
  Future<LoadingState<Map>> memberStat({int? mid}) async {
    return MemberHttp.memberStat(mid: mid);
  }

  @override
  Future<LoadingState<CoreMemberCardInfoData>> memberCardInfo({int? mid}) async {
    final result = await MemberHttp.memberCardInfo(mid: mid);
    return _mapSuccess(result, (data) => CoreMemberCardInfoData.fromJson(_memberCardInfoToMap(data)));
  }

  @override
  Future<LoadingState<CoreSearchArchiveData>> searchArchive({
    required Object mid,
    int tid = 0,
    int ps = 30,
    required int pn,
    String? keyword,
    String? specialType,
    CoreArchiveOrderTypeWeb order = CoreArchiveOrderTypeWeb.pubdate,
  }) async {
    final result = await MemberHttp.searchArchive(
      mid: mid,
      tid: tid,
      ps: ps,
      pn: pn,
      keyword: keyword,
      specialType: specialType,
      order: ArchiveOrderTypeWeb.values.firstWhere((e) => e.name == order.name),
    );
    return _mapSuccess(result, (data) => CoreSearchArchiveData.fromJson(_searchArchiveDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreSeasonWebData>> seasonSeriesWeb({
    required CoreWebSsType type,
    required Object mid,
    required Object id,
    int ps = 30,
    required int pn,
    CoreArchiveSortTypeApp sort = CoreArchiveSortTypeApp.desc,
  }) async {
    final result = await MemberHttp.seasonSeriesWeb(
      type: WebSsType.values.firstWhere((e) => e.name == type.name),
      mid: mid,
      id: id,
      ps: ps,
      pn: pn,
      sort: ArchiveSortTypeApp.values.firstWhere((e) => e.name == sort.name),
    );
    return _mapSuccess(result, (data) => CoreSeasonWebData.fromJson(_seasonWebDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreDynamicsDataModel>> memberDynamic({
    String? offset,
    required int mid,
  }) async {
    final result = await MemberHttp.memberDynamic(offset: offset, mid: mid);
    return _mapSuccess(result, (data) => CoreDynamicsDataModel.fromJson(_dynamicsDataModelToMap(data)));
  }

  @override
  Future<LoadingState<CoreDynamicsDataModel>> dynSearch({
    required int pn,
    required dynamic mid,
    required dynamic offset,
    required String keyword,
  }) async {
    final result = await MemberHttp.dynSearch(
      pn: pn,
      mid: mid,
      offset: offset,
      keyword: keyword,
    );
    return _mapSuccess(result, (data) => CoreDynamicsDataModel.fromJson(_dynamicsDataModelToMap(data)));
  }

  @override
  Future<LoadingState<List<CoreMemberTagItemModel>>> followUpTags() async {
    final result = await MemberHttp.followUpTags();
    return _mapSuccess(result, (data) => data
        .map((e) => CoreMemberTagItemModel.fromJson(_memberTagItemToMap(e)))
        .toList());
  }

  @override
  Future<LoadingState<void>> specialAction({
    int? fid,
    bool isAdd = true,
  }) async {
    return MemberHttp.specialAction(fid: fid, isAdd: isAdd);
  }

  @override
  Future<LoadingState<void>> addUsers(String fids, String tagids) async {
    return MemberHttp.addUsers(fids, tagids);
  }

  @override
  Future<LoadingState<CoreFollowData>> followUpGroup({
    int? mid,
    int? tagid,
    int? pn,
    int ps = 20,
  }) async {
    final result = await MemberHttp.followUpGroup(
      mid: mid,
      tagid: tagid,
      pn: pn,
      ps: ps,
    );
    return _mapSuccess(result, (data) => CoreFollowData.fromJson(_followDataToMap(data)));
  }

  @override
  Future<LoadingState<int>> createFollowTag(String tagName) async {
    return MemberHttp.createFollowTag(tagName);
  }

  @override
  Future<LoadingState<void>> updateFollowTag(
    Object tagid,
    Object name,
  ) async {
    return MemberHttp.updateFollowTag(tagid, name);
  }

  @override
  Future<LoadingState<void>> delFollowTag(Object tagid) async {
    return MemberHttp.delFollowTag(tagid);
  }

  @override
  Future<LoadingState<List<CoreMemberTagItemModel>?>> getTopVideo() async {
    final result = await MemberHttp.getTopVideo();
    return _mapSuccess(result, (data) => data
        ?.map((e) => CoreMemberTagItemModel.fromJson(_memberTagItemToMap(e)))
        .toList());
  }

  @override
  Future<LoadingState<Map>> memberView({required int mid}) async {
    return MemberHttp.memberView(mid: mid);
  }

  @override
  Future<LoadingState<CoreFollowData>> getfollowSearch({
    required int mid,
    required int ps,
    required int pn,
    required String name,
  }) async {
    final result = await MemberHttp.getfollowSearch(
      mid: mid,
      ps: ps,
      pn: pn,
      name: name,
    );
    return _mapSuccess(result, (data) => CoreFollowData.fromJson(_followDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreOpusSpaceFlowResp>> spaceOpus({
    required int hostMid,
    required int page,
    String offset = '',
    String type = 'all',
  }) async {
    final result = await MemberHttp.spaceOpus(
      hostMid: hostMid,
      page: page,
      offset: offset,
      type: type,
    );
    return _mapSuccess(result, (d) {
      return CoreOpusSpaceFlowResp(
        itemList: d.items?.cast<dynamic>(),
        nextPage: d.offset,
        hostUpOpusCollection: null,
        hostUpNoteNavBar: null,
      );
    });
  }

  @override
  Future<LoadingState<CoreUpowerRankData>> upowerRank({
    required Object upMid,
    required int page,
    int? privilegeType,
  }) async {
    final result = await MemberHttp.upowerRank(
      upMid: upMid,
      page: page,
      privilegeType: privilegeType,
    );
    return _mapSuccess(result, (data) => CoreUpowerRankData.fromJson(_upowerRankDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreCoinLikeArcData>> coinArc({
    required int mid,
    required int page,
  }) async {
    final result = await MemberHttp.coinArc(mid: mid, page: page);
    return _mapSuccess(result, (data) => CoreCoinLikeArcData.fromJson(_coinLikeArcDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreCoinLikeArcData>> likeArc({
    required int mid,
    required int page,
  }) async {
    final result = await MemberHttp.likeArc(mid: mid, page: page);
    return _mapSuccess(result, (data) => CoreCoinLikeArcData.fromJson(_coinLikeArcDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreSpaceShopData>> spaceShop({
    required int mid,
  }) async {
    final result = await MemberHttp.spaceShop(mid: mid);
    return _mapSuccess(result, (data) => CoreSpaceShopData.fromJson(_spaceShopDataToMap(data)));
  }

  @override
  Future<LoadingState<CoreMemberGuardData>> memberGuard({
    required Object ruid,
    required int page,
  }) async {
    final result = await MemberHttp.memberGuard(ruid: ruid, page: page);
    return _mapSuccess(result, (data) => CoreMemberGuardData.fromJson(_memberGuardDataToMap(data)));
  }
}

