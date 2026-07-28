/// Core→adapter model converters for runtime type compatibility.
///
/// Core* types (in `lib/core/models/`) and adapter types (in
/// `lib/adapters/bilibili/models*/`) have incompatible field layouts —
/// Core uses `Map<String, dynamic>` for nested objects while adapter uses typed
/// subclasses like `Owner`, `HotStat`, `PlayStat`, etc.
///
/// The `as dynamic` bridge used during SPES-014 bypasses compile-time checks
/// but crashes at runtime. These converters build a `Map<String, dynamic>` from
/// Core model fields and pass it to the adapter's `fromJson()` — the same
/// round-trip pattern as `toJson()` + `fromJson()` but without requiring Core
/// models to have `toJson()`.
library;

import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/models/music_types.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/adapters/bilibili/models/model_hot_video_item.dart';
import 'package:skf/adapters/bilibili/models/model_rec_video_item.dart';
import 'package:skf/adapters/bilibili/models/home/rcmd/result.dart' as rcmd;
import 'package:skf/adapters/bilibili/models_new/music/bgm_recommend_list.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_archive/item.dart';
import 'package:skf/adapters/bilibili/models_new/sub/sub_detail/media.dart';

/// Static converters from Core* models to adapter models.
///
/// Each method takes a Core* model (from `lib/core/models/`), builds a
/// `Map<String, dynamic>` with the keys the adapter `fromJson()` expects,
/// and returns the adapter type.
abstract final class ModelConverters {
  // ---------------------------------------------------------------------------
  // HotVideoItemModel conversions
  // ---------------------------------------------------------------------------

  /// [CoreHotVideoItemModel] → [HotVideoItemModel].
  ///
  /// Used by: hot, related, popular_series, popular_precious pages.
  static HotVideoItemModel hotVideoItem(CoreHotVideoItemModel core) =>
      HotVideoItemModel.fromJson(<String, dynamic>{
        'aid': core.aid,
        'bvid': core.bvid,
        'cid': core.cid,
        'pic': core.cover,
        'title': core.title,
        'duration': core.duration,
        'pubdate': core.pubdate,
        'desc': core.desc,
        'owner': core.owner,
        'stat': core.stat,
        'dimension': core.dimension,
        'videos': core.videos,
        'tid': core.tid,
        'tname': core.tname,
        'copyright': core.copyright,
        'ctime': core.ctime,
        'state': core.state,
        'first_frame': core.firstFrame,
        'pub_location': core.pubLocation,
        'redirect_url': core.redirectUrl,
        'progress': core.progress,
        'pgc_label': core.badge,
      });

  // ---------------------------------------------------------------------------
  // BgmRecommend conversion
  // ---------------------------------------------------------------------------

  /// [CoreBgmRecommend] → [BgmRecommend].
  ///
  /// Used by: music/video page.
  static BgmRecommend bgmRecommend(CoreBgmRecommend core) =>
      BgmRecommend.fromJson(<String, dynamic>{
        'bvid': core.bvid,
        'cid': core.cid,
        'cover': core.cover,
        'title': core.title,
        'up_nick_name': core.upNickName,
        'play': core.play,
        'danmu': core.danmu,
        'duration': core.duration,
        'label_list': core.labelList
            ?.map((x) => <String, dynamic>{'name': x.name})
            .toList(),
      });

  // ---------------------------------------------------------------------------
  // SpaceArchiveItem conversions
  // ---------------------------------------------------------------------------

  /// [CoreSpaceArchiveItem] → [SpaceArchiveItem].
  ///
  /// Used by: member_video, video/member pages.
  static SpaceArchiveItem spaceArchiveItem(CoreSpaceArchiveItem core) =>
      SpaceArchiveItem.fromJson(<String, dynamic>{
        'title': core.title,
        'cover': core.cover,
        'uri': core.uri,
        'param': core.param,
        'goto': core.goto,
        'length': core.length,
        'duration': core.duration,
        'is_steins': core.isSteins,
        'is_cooperation': core.isCooperation,
        'is_pgc': core.isPgc,
        'is_pugv': core.isPugv,
        'bvid': core.bvid,
        'first_cid': core.cid,
        'publish_time_text': core.publishTimeText,
        'badges': core.badges
            ?.map((e) => <String, dynamic>{'text': e.text})
            .toList(),
        'season': core.season != null
            ? <String, dynamic>{'mtime': core.season!.mtime}
            : null,
        'history': core.coreHistory != null
            ? <String, dynamic>{
                'progress': core.coreHistory!.progress,
                'duration': core.coreHistory!.duration,
              }
            : null,
        'styles': core.styles,
        'label': core.label,
        'play': core.play,
        'danmaku': core.danmaku,
        'author': core.ownerName,
        'mid': core.ownerMid,
      });

  /// [CoreArchiveItem] (from space archive) → [SpaceArchiveItem].
  ///
  /// Used by: member_home page (video section).
  static SpaceArchiveItem archiveItem(CoreArchiveItem core) =>
      SpaceArchiveItem.fromJson(<String, dynamic>{
        'title': core.title,
        'cover': core.cover,
        'play': core.play,
        'danmaku': 0,
        'author': '',
      });

  /// [CoreCoinArchiveItem] or [CoreLikeArchiveItem] → [SpaceArchiveItem].
  ///
  /// Used by: member_home page (coin/like sections).
  /// These Core types are minimal (only title + cover); other fields are null.
  static SpaceArchiveItem coinLikeItem(Object core) =>
      SpaceArchiveItem.fromJson(<String, dynamic>{
        'title': (core as dynamic).title,
        'cover': (core as dynamic).cover,
        'play': 0,
        'danmaku': 0,
        'author': '',
      });

  // ---------------------------------------------------------------------------
  // SubDetailItemModel conversion
  // ---------------------------------------------------------------------------

  /// [CoreSubDetailItemModel] → [SubDetailItemModel].
  ///
  /// Used by: subscription_detail page.
  static SubDetailItemModel subDetailItem(CoreSubDetailItemModel core) =>
      SubDetailItemModel.fromJson(<String, dynamic>{
        'id': core.id,
        'title': core.title,
        'cover': core.cover,
        'duration': core.duration,
        'pubtime': core.pubtime,
        'bvid': core.bvid,
        'cnt_info': core.cntInfo != null
            ? <String, dynamic>{
                'play': core.cntInfo!.play,
                'danmaku': core.cntInfo!.danmaku,
              }
            : null,
      });

  // ---------------------------------------------------------------------------
  // RcmdVideoItemAppModel conversion
  // ---------------------------------------------------------------------------

  /// [CoreRcmdVideoItemAppModel] → [rcmd.RcmdVideoItemAppModel].
  ///
  /// Used by: rcmd page (app-end recommended video cards).
  static rcmd.RcmdVideoItemAppModel rcmdVideoItemApp(
    CoreRcmdVideoItemAppModel core,
  ) =>
      rcmd.RcmdVideoItemAppModel.fromJson(<String, dynamic>{
        'player_args': <String, dynamic>{
          'aid': core.aid,
          'cid': core.cid,
          'duration': core.duration,
        },
        'bvid': core.bvid,
        'cover': core.cover,
        'title': core.title,
        'param': '${core.param ?? 0}',
        'goto': core.goto,
        'uri': core.uri,
        'rcmd_reason': core.isFollowed ? null : core.rcmdReason,
        'cover_right_text': core.pgcBadge,
        'talk_back': core.talkBack,
        'card_type': core.cardType,
        'desc': core.desc,
        'args': <String, dynamic>{
          'up_name': core.owner?['name'],
          'up_id': core.owner?['mid'],
        },
        'cover_left_text_1': '${core.stat?['view'] ?? ''}',
        'cover_left_text_2': '${core.stat?['danmu'] ?? ''}',
        'desc_button': <String, dynamic>{'text': core.owner?['name']},
        if (core.threePoint != null)
          'three_point_v2': core.threePoint!['dislikeReasons'],
      });

  /// [CoreRcmdVideoItemModel] (web) → [RcmdVideoItemModel].
  ///
  /// Used by: rcmd page (web-end recommended video cards).
  static RcmdVideoItemModel rcmdVideoItemWeb(
    CoreRcmdVideoItemModel core,
  ) =>
      RcmdVideoItemModel.fromJson(<String, dynamic>{
        'id': core.aid,
        'bvid': core.bvid,
        'cid': core.cid,
        'pic': core.cover,
        'title': core.title,
        'duration': core.duration,
        'pubdate': core.pubdate,
        'owner': core.owner,
        'stat': core.stat,
        'is_followed': core.isFollowed ? 1 : 0,
        'goto': core.goto,
        'uri': core.uri,
        'rcmd_reason': core.rcmdReason != null
            ? <String, dynamic>{'content': core.rcmdReason}
            : null,
      });

  /// Dynamic dispatcher for rcmd items.
  ///
  /// Routes to [rcmdVideoItemApp] or [rcmdVideoItemWeb] based on runtime type.
  static BaseRcmdVideoItemModel rcmdItem(dynamic core) {
    if (core is CoreRcmdVideoItemAppModel) {
      return rcmdVideoItemApp(core);
    }
    if (core is CoreRcmdVideoItemModel) {
      return rcmdVideoItemWeb(core);
    }
    if (core == null) {
      throw ArgumentError.notNull('core');
    }
    throw ArgumentError(
      'Unknown rcmd item type: ${core.runtimeType}',
    );
  }
}
