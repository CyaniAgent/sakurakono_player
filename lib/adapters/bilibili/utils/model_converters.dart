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

import 'dart:convert';

import 'package:skf/core/models/dynamics_types.dart';
import 'package:skf/core/models/fav_types.dart' hide CoreStat, CoreUgc, CoreOwner;
import 'package:skf/core/models/member_types.dart' as member
    hide
        CoreDynamicsDataModel,
        CoreDynamicItemModel,
        CoreFallback,
        CoreBasic,
        CoreItemModulesModel,
        CoreArticleContentModel,
        CoreModuleAuthorModel,
        CoreDecorate,
        CoreFan,
        CoreModuleStatModel,
        CoreDynamicStat,
        CoreModuleTag,
        CoreModuleDynamicModel,
        CoreDynamicDescModel,
        CoreRichTextNodeItem,
        CoreEmoji,
        CoreDynamicMajorModel,
        CoreDynamicArchiveModel,
        CoreBadge,
        CoreStat,
        CoreDynamicOpusModel,
        CoreSummaryModel,
        CoreOpusPicModel,
        CoreDynamicLiveModel,
        CoreWatchedShow,
        CoreDynamicLive2Model,
        CoreDynamicNoneModel,
        CoreCommon,
        CoreMusic,
        CoreMedialist,
        CoreSubscriptionNew,
        CoreLiveRcmd,
        CoreLiveRcmdContent,
        CoreLivePlayInfo,
        CoreDynamicTopicModel,
        CoreDynamicAddModel,
        CoreVote,
        CoreUgc,
        CoreReserve,
        CoreReserveBtn,
        CoreDesc,
        CoreGood,
        CoreGoodItem,
        CoreUpowerLottery,
        CoreHint,
        CoreAddCommon,
        CoreAddMatch,
        CoreMatchInfo,
        CoreTTeam,
        CoreButton,
        CoreJumpStyle,
        CoreCheck,
        CoreBgImg,
        CoreModuleInteraction,
        CoreModuleInteractionItem,
        CoreModuleDispute,
        CoreModuleFold,
        CoreModuleTop,
        CoreModuleTopDisplay,
        CoreModuleTopAlbum,
        CorePic,
        CoreModuleCollection,
        CoreModuleBlocked,
        CoreOwner;
import 'package:skf/core/models/user_types.dart' as user;
import 'package:skf/core/models/live_types.dart' as live_types;
import 'package:skf/core/models/music_types.dart';
import 'package:skf/core/models/search_types.dart';
import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/adapters/bilibili/models/dynamics/result.dart';
import 'package:skf/adapters/bilibili/models/dynamics/vote_model.dart';
import 'package:skf/adapters/bilibili/models/model_hot_video_item.dart';
import 'package:skf/adapters/bilibili/models/model_rec_video_item.dart';
import 'package:skf/adapters/bilibili/models/home/rcmd/result.dart' as rcmd;
import 'package:skf/adapters/bilibili/models_new/followee_votes/vote.dart';
import 'package:skf/adapters/bilibili/models_new/music/bgm_recommend_list.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_archive/item.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_article/item.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_audio/item.dart';
import 'package:skf/adapters/bilibili/models_new/space/space/card.dart';
import 'package:skf/adapters/bilibili/models_new/space/space/images.dart';
import 'package:skf/adapters/bilibili/models_new/space/space/live.dart';
import 'package:skf/adapters/bilibili/models_new/space/space/reservation_card_list.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_fav/list.dart';
import 'package:skf/adapters/bilibili/models_new/sub/sub_detail/media.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/dimension.dart';
import 'package:skf/adapters/bilibili/models/member/tags.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_medal_wall/data.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_superchat/item.dart';
import 'package:skf/adapters/bilibili/models_new/sponsor_block/segment_item.dart';
import 'package:skf/adapters/bilibili/models_new/sponsor_block/user_info.dart';

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

  /// [member.CoreSpaceArchiveItem] → [SpaceArchiveItem].
  ///
  /// Used by: member_video, video/member pages.
  static SpaceArchiveItem spaceArchiveItem(member.CoreSpaceArchiveItem core) =>
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

  /// [member.CoreArchiveItem] (from space archive) → [SpaceArchiveItem].
  ///
  /// Used by: member_home page (video section).
  static SpaceArchiveItem archiveItem(member.CoreArchiveItem core) =>
      SpaceArchiveItem.fromJson(<String, dynamic>{
        'title': core.title,
        'cover': core.cover,
        'play': core.play,
        'danmaku': 0,
        'author': '',
      });

  /// [member.CoreCoinArchiveItem] → [SpaceArchiveItem].
  ///
  /// Used by: member_home page (coin section).
  /// CoreCoinArchiveItem is minimal (only title + cover); other fields are null.
  static SpaceArchiveItem coinLikeItem(member.CoreCoinArchiveItem core) =>
      SpaceArchiveItem.fromJson(<String, dynamic>{
        'title': core.title,
        'cover': core.cover,
        'play': 0,
        'danmaku': 0,
        'author': '',
      });

  /// [member.CoreLikeArchiveItem] → [SpaceArchiveItem].
  ///
  /// Used by: member_home page (like section).
  /// CoreLikeArchiveItem is minimal (only title + cover); other fields are null.
  static SpaceArchiveItem likeArchiveItem(member.CoreLikeArchiveItem core) =>
      SpaceArchiveItem.fromJson(<String, dynamic>{
        'title': core.title,
        'cover': core.cover,
        'play': 0,
        'danmaku': 0,
        'author': '',
      });

  // ---------------------------------------------------------------------------
  // MemberHome bridge conversions
  // ---------------------------------------------------------------------------

  /// [member.CoreFavouriteItem] → [SpaceFavItemModel].
  ///
  /// Used by: member_home page (favourite section).
  /// CoreFavouriteItem has only title+cover; mediaId/count/isPublic are null.
  // TODO(type-safety): Core→adapter bridge — only title/cover mapped
  static SpaceFavItemModel favouriteItem(member.CoreFavouriteItem core) =>
      SpaceFavItemModel.fromJson(<String, dynamic>{
        'title': core.title,
        'cover': core.cover,
      });

  /// [member.CoreArticleItem] → [SpaceArticleItem].
  ///
  /// Used by: member_home page (article section).
  static SpaceArticleItem articleItem(member.CoreArticleItem core) =>
      SpaceArticleItem.fromJson(<String, dynamic>{
        'title': core.title,
        'cover': core.cover,
      });

  /// [member.CoreAudioItem] → [SpaceAudioItem].
  ///
  /// Used by: member_home page (audio section).
  static SpaceAudioItem audioItem(member.CoreAudioItem core) =>
      SpaceAudioItem.fromJson(<String, dynamic>{
        'title': core.title,
        'cover': core.cover,
      });

  /// [member.CoreComicItem] → [SpaceArchiveItem].
  ///
  /// Used by: member_home page (comic section).
  static SpaceArchiveItem comicItem(member.CoreComicItem core) =>
      SpaceArchiveItem.fromJson(<String, dynamic>{
        'title': core.title,
        'cover': core.cover,
      });

  /// [member.CoreSeasonItem] → [SpaceArchiveItem].
  ///
  /// Used by: member_home page (season/PGC section).
  static SpaceArchiveItem seasonItem(member.CoreSeasonItem core) =>
      SpaceArchiveItem.fromJson(<String, dynamic>{
        'title': core.title,
        'cover': core.cover,
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
        if (core.threePoint case {'three_point_v2': final v} when v != null)
          'three_point_v2': v,
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

  // ---------------------------------------------------------------------------
  // Dimension conversions
  // ---------------------------------------------------------------------------

  /// [CoreDimension] → [Dimension].
  ///
  /// Used by: subscription_detail, history, music, member_home,
  /// member_coin_arc, dynamics (rich node) pages.
  static Dimension? dimension(CoreDimension? core) => core == null
      ? null
      : Dimension(width: core.width, height: core.height);

  // ---------------------------------------------------------------------------
  // Dynamics vote conversions
  // ---------------------------------------------------------------------------

  /// [CoreVoteInfo] → [VoteInfo].
  ///
  /// Used by: dynamics vote dialog.
  static VoteInfo voteInfo(CoreVoteInfo core) => VoteInfo(
    choiceCnt: core.choiceCnt,
    defaultShare: core.defaultShare,
    desc: core.desc,
    endTime: core.endTime,
    status: core.status,
    uid: core.uid,
    voteId: core.voteId,
    joinNum: core.joinNum,
    title: core.title,
    ctime: core.ctime,
    myVotes: core.myVotes,
    options: core.options.map(_option).toList(),
    optionsCnt: core.optionsCnt,
    voterLevel: core.voterLevel,
    face: core.face,
    name: core.name,
    type: core.type,
    votePublisher: core.votePublisher,
    duration: core.duration,
    onlyFansLevel: core.onlyFansLevel,
  );

  /// [CoreOption] → [Option].
  static Option _option(CoreOption core) => Option(
    optDesc: core.optDesc,
    imgUrl: core.imgUrl,
  )
    ..optIdx = core.optIdx
    ..cnt = core.cnt;

  /// [CoreFolloweeVote] → [FolloweeVote].
  ///
  /// Used by: dynamics vote panel (followee votes list).
  static FolloweeVote followeeVote(CoreFolloweeVote core) => FolloweeVote(
    mid: core.mid,
    name: core.name,
    face: core.face,
    votes: core.votes,
    ctime: core.ctime,
  );

  // ---------------------------------------------------------------------------
  // Dynamics rich text conversions
  // ---------------------------------------------------------------------------

  /// [CoreOpusPicModel] → [OpusPicModel].
  ///
  /// Used by: dynamics rich node panel (dynPic).
  static OpusPicModel opusPic(CoreOpusPicModel core) =>
      OpusPicModel.fromJson(_opusPicMap(core));

  /// [CoreModuleBlocked] → [ModuleBlocked].
  ///
  /// Used by: dynamics blocked item.
  static ModuleBlocked blockedModule(CoreModuleBlocked core) =>
      ModuleBlocked.fromJson(<String, dynamic>{
        'bg_img': _bgImgMap(core.bgImg),
        'blocked_type': core.blockedType,
        'button': _buttonMap(core.button),
        'title': core.title,
        'hint_message': core.hintMessage,
        'icon': _bgImgMap(core.icon),
      });

  // ---------------------------------------------------------------------------
  // Dynamics module bridge conversions
  // ---------------------------------------------------------------------------

  /// [CoreDynamicItemModel] → [DynamicItemModel].
  ///
  /// Used by: dynamics module and content panels.
  /// Maps only the fields read by the dynamics widgets; other fields are null.
  static DynamicItemModel moduleItem(CoreDynamicItemModel core) {
    final coreDynamic = core.modules?.moduleDynamic;
    return DynamicItemModel.fromJson(<String, dynamic>{
      'type': core.type,
      'id_str': core.idStr,
      'basic': _basicMap(core.basic),
      'modules': <String, dynamic>{
        'module_dynamic': coreDynamic == null
            ? null
            : <String, dynamic>{
                'desc': _descMap(coreDynamic.desc),
                'major': _majorMap(coreDynamic.major),
              },
      },
    })..linkFolded = core.linkFolded;
  }

  static Map<String, dynamic>? _basicMap(CoreBasic? core) => core == null
      ? null
      : <String, dynamic>{
          'comment_id_str': core.commentIdStr,
          'comment_type': core.commentType,
          'rid_str': core.ridStr,
        };

  static Map<String, dynamic>? _descMap(CoreDynamicDescModel? core) =>
      core == null
          ? null
          : <String, dynamic>{
              'rich_text_nodes': _richTextNodes(core.richTextNodes),
              'text': core.text,
            };

  static Map<String, dynamic>? _summaryMap(CoreSummaryModel? core) =>
      core == null
          ? null
          : <String, dynamic>{
              'rich_text_nodes': _richTextNodes(core.richTextNodes),
              'text': core.text,
            };

  static List<Map<String, dynamic>>? _richTextNodes(
    List<CoreRichTextNodeItem>? nodes,
  ) =>
      nodes?.map(_richTextNodeMap).toList();

  static Map<String, dynamic> _richTextNodeMap(CoreRichTextNodeItem core) =>
      <String, dynamic>{
        'emoji': core.emoji == null
            ? null
            : <String, dynamic>{
                'webp_url': core.emoji!.url,
                'size': core.emoji!.size,
              },
        'orig_text': core.origText,
        'text': core.text,
        'type': core.type,
        'rid': core.rid,
        'pics': _opusPicMaps(core.pics),
        'jump_url': core.jumpUrl,
      };

  static List<Map<String, dynamic>>? _opusPicMaps(
    List<CoreOpusPicModel>? pics,
  ) =>
      pics?.map(_opusPicMap).toList();

  static Map<String, dynamic> _opusPicMap(CoreOpusPicModel core) =>
      <String, dynamic>{
        'width': core.width,
        'height': core.height,
        'src': core.src,
        'url': core.url,
        'live_url': core.liveUrl,
        'size': core.size,
      };

  static Map<String, dynamic>? _majorMap(CoreDynamicMajorModel? core) =>
      core == null
          ? null
          : <String, dynamic>{
              'type': core.type,
              'archive': _archiveMap(core.archive),
              'ugc_season': _archiveMap(core.ugcSeason),
              'pgc': _archiveMap(core.pgc),
              'courses': _archiveMap(core.courses),
              'live_rcmd': _liveRcmdMap(core.liveRcmd),
              'live': _live2Map(core.live),
              'opus': _opusMap(core.opus),
              'subscription_new': _subscriptionNewMap(core.subscriptionNew),
            };

  static Map<String, dynamic>? _archiveMap(CoreDynamicArchiveModel? core) =>
      core == null
          ? null
          : <String, dynamic>{
              'id': core.id,
              'aid': core.aid,
              'badge': _badgeMap(core.badge),
              'bvid': core.bvid,
              'cover': core.cover,
              'duration_text': core.durationText,
              'jump_url': core.jumpUrl,
              'stat': _statMap(core.stat),
              'title': core.title,
              'type': core.type,
              'epid': core.epid,
              'season_id': core.seasonId,
            };

  static Map<String, dynamic>? _badgeMap(CoreBadge? core) => core == null
      ? null
      : <String, dynamic>{'text': core.text};

  static Map<String, dynamic>? _statMap(CoreStat? core) => core == null
      ? null
      : <String, dynamic>{'danmaku': core.danmu, 'play': core.play};

  static Map<String, dynamic>? _liveRcmdMap(CoreDynamicLiveModel? core) =>
      core == null
          ? null
          : <String, dynamic>{
              'content': jsonEncode(<String, dynamic>{
                'live_play_info': <String, dynamic>{
                  'room_id': core.roomId,
                  'live_status': core.liveStatus,
                  'cover': core.cover,
                  'area_name': core.areaName,
                  'title': core.title,
                  'watched_show': _watchedShowMap(core.watchedShow),
                },
              }),
            };

  static Map<String, dynamic>? _watchedShowMap(CoreWatchedShow? core) =>
      core == null ? null : <String, dynamic>{'text_large': core.text};

  static Map<String, dynamic>? _live2Map(CoreDynamicLive2Model? core) =>
      core == null
          ? null
          : <String, dynamic>{
              'badge': _badgeMap(core.badge),
              'cover': core.cover,
              'desc_first': core.descFirst,
              'id': core.id,
              'live_state': core.liveState,
              'title': core.title,
            };

  static Map<String, dynamic>? _opusMap(CoreDynamicOpusModel? core) =>
      core == null
          ? null
          : <String, dynamic>{
              'pics': _opusPicMaps(core.pics),
              'summary': _summaryMap(core.summary),
              'title': core.title,
            };

  static Map<String, dynamic>? _subscriptionNewMap(
    CoreSubscriptionNew? core,
  ) =>
      core == null
          ? null
          : <String, dynamic>{'live_rcmd': _liveRcmdInnerMap(core.liveRcmd)};

  static Map<String, dynamic>? _liveRcmdInnerMap(CoreLiveRcmd? core) {
    final info = core?.content?.livePlayInfo;
    return core == null
        ? null
        : <String, dynamic>{
            'content': jsonEncode(<String, dynamic>{
              'live_play_info': info == null
                  ? null
                  : <String, dynamic>{
                      'room_id': info.roomId,
                      'live_status': info.liveStatus,
                      'title': info.title,
                      'cover': info.cover,
                      'area_name': info.areaName,
                      'watched_show': _watchedShowMap(info.watchedShow),
                    },
            }),
          };
  }

  static Map<String, dynamic>? _bgImgMap(CoreBgImg? core) => core == null
      ? null
      : <String, dynamic>{'img_dark': core.imgDark, 'img_day': core.imgDay};

  static Map<String, dynamic>? _buttonMap(CoreButton? core) => core == null
      ? null
      : <String, dynamic>{
          'icon': core.icon,
          'jump_url': core.jumpUrl,
          'text': core.text,
          'jump_style': core.jumpStyle == null
              ? null
              : <String, dynamic>{'text': core.jumpStyle!.text},
          'check': core.check == null
              ? null
              : <String, dynamic>{'text': core.check!.text},
        };

  // ---------------------------------------------------------------------------
  // Duplicate Core model conversions (user_types / member_types → fav_types / video_types)
  // ---------------------------------------------------------------------------

  /// [user.CoreVideoTagItem] → [CoreVideoTagItem] (video_types).
  ///
  /// Used by: ugc introduction page (video tags).
  static CoreVideoTagItem videoTagItem(user.CoreVideoTagItem core) =>
      CoreVideoTagItem.fromJson(<String, dynamic>{
        'tag_id': core.tagId,
        'tag_name': core.tagName,
        'tag_type': core.tagType,
        'music_id': core.musicId,
      });

  /// [user.CoreSubItemModel] → [CoreSubItemModel] (fav_types).
  ///
  /// Used by: subscription page (SubItem widget expects the fav_types variant).
  static CoreSubItemModel subItemModel(user.CoreSubItemModel core) =>
      CoreSubItemModel.fromJson(<String, dynamic>{
        'id': core.id,
        'fid': core.fid,
        'mid': core.mid,
        'attr': core.attr,
        'title': core.title,
        'cover': core.cover,
        'upper': core.upper == null
            ? null
            : <String, dynamic>{
                'mid': core.upper!.mid,
                'name': core.upper!.name,
                'face': core.upper!.face,
              },
        'cover_type': core.coverType,
        'intro': core.intro,
        'ctime': core.ctime,
        'mtime': core.mtime,
        'state': core.state,
        'fav_state': core.favState,
        'media_count': core.mediaCount,
        'view_count': core.viewCount,
        'type': core.type,
        'cnt_info': core.cntInfo == null
            ? null
            : <String, dynamic>{
                'play': core.cntInfo!.play,
                'danmaku': core.cntInfo!.danmaku,
              },
      });

  /// [member.CoreSpaceCheeseItem] → [CoreSpaceCheeseItem] (fav_types).
  ///
  /// Used by: member_cheese page (MemberCheeseItem widget expects the
  /// fav_types variant). The member variant only has id/title/cover; the
  /// fav variant's marks/status/ctime stay null (widget guards them).
  static CoreSpaceCheeseItem spaceCheeseItem(member.CoreSpaceCheeseItem core) =>
      CoreSpaceCheeseItem.fromJson(<String, dynamic>{
        'cover': core.cover,
        'season_id': core.id,
        'title': core.title,
      });

  // ---------------------------------------------------------------------------
  // SponsorBlock conversions
  // ---------------------------------------------------------------------------

  /// [CoreSegmentItemModel] → [SegmentItemModel].
  ///
  /// Used by: sponsor_block block_mixin (skip segment list).
  static SegmentItemModel segmentItemConverter(CoreSegmentItemModel core) =>
      SegmentItemModel(
        cid: core.cid,
        category: core.category,
        actionType: core.actionType,
        segment: core.segment,
        uuid: core.uuid,
        videoDuration: core.videoDuration,
        votes: core.votes,
      );

  /// [CoreUserInfo] → [UserInfo].
  ///
  /// Used by: sponsor_block page (user info card).
  static UserInfo userInfoConverter(CoreUserInfo core) => UserInfo(
    viewCount: core.viewCount,
    minutesSaved: core.minutesSaved,
    segmentCount: core.segmentCount,
  );

  // ---------------------------------------------------------------------------
  // Member tag conversions
  // ---------------------------------------------------------------------------

  /// [member.CoreMemberTagItemModel] → [MemberTagItemModel].
  ///
  /// Used by: group_panel page (follow-up tags).
  static MemberTagItemModel memberTagItemConverter(
    member.CoreMemberTagItemModel core,
  ) =>
      MemberTagItemModel(
        count: core.count,
        name: core.name,
        tagid: core.tagid,
        tip: core.tip,
      );

  // ---------------------------------------------------------------------------
  // Medal wall conversions
  // ---------------------------------------------------------------------------

  /// [live.CoreMedalWallData] → [MedalWallData].
  ///
  /// Used by: member page (medal wall dialog). Round-trip via toJson/fromJson;
  /// key parity for nested medal_info/uinfo_medal verified against the adapter
  /// models in `models_new/live/live_medal_wall/`.
  static MedalWallData medalWallDataConverter(live_types.CoreMedalWallData core) =>
      MedalWallData.fromJson(core.toJson());

  // ---------------------------------------------------------------------------
  // Member space card / live / reservation conversions
  // ---------------------------------------------------------------------------

  /// [member.CoreSpaceCard] → [SpaceCard].
  ///
  /// Used by: member page (UserInfoCard header).
  static SpaceCard? spaceCard(member.CoreSpaceCard? core) => core == null
      ? null
      : SpaceCard.fromJson(<String, dynamic>{
          'face': core.face,
          'name': core.name,
          'mid': core.mid?.toString(),
          'relation': core.relation,
          'silence': core.silence,
          'vip': core.vip == null
              ? null
              : <String, dynamic>{
                  'type': core.vip!.type,
                  'status': core.vip!.status,
                  'vipType': core.vip!.vipType,
                  'vipStatus': core.vip!.vipStatus,
                },
        });

  /// [member.CoreSpaceImages] → [SpaceImages].
  ///
  /// Used by: member page (UserInfoCard header). Core only carries
  /// `imgCount` which has no adapter counterpart, so the result keeps the
  /// URL fields null.
  static SpaceImages? spaceImages(member.CoreSpaceImages? core) => core == null
      ? null
      : SpaceImages.fromJson(<String, dynamic>{'img_count': core.imgCount});

  /// [member.CoreLive] → [Live].
  ///
  /// Used by: member page (UserInfoCard header).
  static Live? live(member.CoreLive? core) => core == null
      ? null
      : Live.fromJson(<String, dynamic>{'liveStatus': core.liveStatus});

  /// [member.CoreReservationCardItem] list → [ReservationCardItem] list.
  ///
  /// Used by: member page (reserve button). Null in → null out; non-null in →
  /// same-length mapped list. Core carries `rid`/`title` which map to the
  /// adapter's `sid`/`name` keys.
  static List<ReservationCardItem>? reservationCardList(
    List<member.CoreReservationCardItem>? core,
  ) =>
      core?.map(_reservationCardItem).toList();

  static ReservationCardItem _reservationCardItem(
    member.CoreReservationCardItem core,
  ) =>
      ReservationCardItem.fromJson(<String, dynamic>{
        'sid': core.rid,
        'name': core.title,
      });

  // ---------------------------------------------------------------------------
  // SuperChat conversions
  // ---------------------------------------------------------------------------

  /// [SuperChatItem] → [live_types.CoreSuperChatItem].
  ///
  /// Used by: fullscreen_sc_size page (SC size preview card). Maps every field
  /// 1:1; `expired`/`deleted` keep their defaults (false) — the adapter
  /// constructor does not expose them and the source (`SuperChatItem.random`)
  /// never sets them either.
  static live_types.CoreSuperChatItem superChatItemToCore(
    SuperChatItem adapter,
  ) =>
      live_types.CoreSuperChatItem(
        id: adapter.id,
        uid: adapter.uid,
        price: adapter.price,
        backgroundImage: adapter.backgroundImage,
        backgroundColor: adapter.backgroundColor,
        backgroundBottomColor: adapter.backgroundBottomColor,
        backgroundPriceColor: adapter.backgroundPriceColor,
        messageFontColor: adapter.messageFontColor,
        startSime: adapter.startSime,
        endTime: adapter.endTime,
        message: adapter.message,
        token: adapter.token,
        ts: adapter.ts,
        userInfo: live_types.CoreSuperChatUserInfo(
          face: adapter.userInfo.face,
          uname: adapter.userInfo.uname,
          nameColor: adapter.userInfo.nameColor,
        ),
        medalInfo: adapter.medalInfo == null
            ? null
            : live_types.CoreUinfoMedal(
                name: adapter.medalInfo!.name,
                level: adapter.medalInfo!.level,
                id: adapter.medalInfo!.id,
                ruid: adapter.medalInfo!.ruid,
                v2MedalColorStart: adapter.medalInfo!.v2MedalColorStart,
                v2MedalColorText: adapter.medalInfo!.v2MedalColorText,
              ),
      );
}
