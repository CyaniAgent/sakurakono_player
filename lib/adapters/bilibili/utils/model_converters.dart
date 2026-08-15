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
import 'package:skf/core/models/follow_item.dart';
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
import 'package:skf/core/models/pgc_types.dart' show CorePgcReviewType;
import 'package:skf/core/models/sponsor_block_types.dart';
import 'package:skf/core/models/video_types.dart';
import 'package:skf/adapters/bilibili/models/common/pgc_review_type.dart';
import 'package:skf/adapters/bilibili/models/dynamics/article_content_model.dart'
    show ArticleContentModel, Common, Pic;
import 'package:skf/adapters/bilibili/models/dynamics/result.dart';
import 'package:skf/adapters/bilibili/models/dynamics/vote_model.dart';
import 'package:skf/adapters/bilibili/models/model_avatar.dart';
import 'package:skf/adapters/bilibili/models/model_owner.dart';
import 'package:skf/adapters/bilibili/models/model_hot_video_item.dart';
import 'package:skf/adapters/bilibili/models/model_rec_video_item.dart';
import 'package:skf/adapters/bilibili/models/home/rcmd/result.dart' as rcmd;
import 'package:skf/adapters/bilibili/models_new/article/article_view/ops.dart';
import 'package:skf/adapters/bilibili/models_new/follow/list.dart';
import 'package:skf/adapters/bilibili/models_new/followee_votes/vote.dart';
import 'package:skf/adapters/bilibili/models_new/history/history.dart';
import 'package:skf/adapters/bilibili/models_new/history/list.dart';
import 'package:skf/adapters/bilibili/models_new/music/bgm_recommend_list.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_archive/item.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_article/item.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_audio/item.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_fav/list.dart';
import 'package:skf/adapters/bilibili/models_new/sub/sub_detail/media.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/dimension.dart';
import 'package:skf/adapters/bilibili/models/member/tags.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_feed_index/watched_show.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_medal_wall/data.dart';
import 'package:skf/adapters/bilibili/models_new/download/bili_download_entry_info.dart';
import 'package:skf/adapters/bilibili/models_new/live/live_superchat/item.dart';
import 'package:skf/adapters/bilibili/models_new/sponsor_block/segment_item.dart';
import 'package:skf/adapters/bilibili/models_new/sponsor_block/user_info.dart';
import 'package:skf/core/models/download_types.dart';

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

  /// [member.CoreSpaceArchiveItem] → [SpaceArchiveItem].
  ///
  /// Used by: member_home page (season/PGC section).
  static SpaceArchiveItem seasonItem(member.CoreSpaceArchiveItem core) =>
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
        'dimension': core.dimension,
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
        'dimension': core.dimension,
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

  /// [CoreDimension] (user_types variant) → [Dimension].
  ///
  /// Used by: later, later_search, child_view pages. Distinct class from the
  /// search_types [CoreDimension] (identical width/height layout).
  static Dimension? dimensionUser(user.CoreDimension? core) => core == null
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

  /// [MemberTagItemModel] → [member.CoreMemberTagItemModel].
  ///
  /// Used by: follow_tag_sort page (persist re-ordered custom tags back into
  /// the core `tabs` list). All four fields map 1:1.
  static member.CoreMemberTagItemModel memberTagItemToCore(
    MemberTagItemModel adapter,
  ) =>
      member.CoreMemberTagItemModel(
        count: adapter.count,
        name: adapter.name,
        tagid: adapter.tagid,
        tip: adapter.tip,
      );

  // ---------------------------------------------------------------------------
  // Follow conversions
  // ---------------------------------------------------------------------------

  /// [CoreFollowItemModel] → [FollowItemModel].
  ///
  /// Used by: follow_type, follow_search and follow child pages. `mid`/`uname`/
  /// `face` map to the [UpItem] super-parameters; `officialVerify` on the core
  /// side is a raw JSON map (or null) while the adapter wants a typed
  /// [BaseOfficialVerify] — non-map payloads (e.g. `0` from legacy APIs) are
  /// treated as null.
  static FollowItemModel followItem(CoreFollowItemModel core) => FollowItemModel(
    mid: core.mid,
    uname: core.uname,
    face: core.face,
    attribute: core.attribute,
    sign: core.sign,
    officialVerify: switch (core.officialVerify) {
      final Map<String, dynamic> m => BaseOfficialVerify.fromJson(m),
      _ => null,
    },
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

  // ---------------------------------------------------------------------------
  // Article page conversions
  // ---------------------------------------------------------------------------

  /// [CoreArticleOps] list → [ArticleOps] list.
  ///
  /// Used by: article page (json ops renderer). `insert` passes through as-is
  /// (dynamic on both sides); `attributes` maps 1:1.
  static List<ArticleOps>? articleOpsList(List<CoreArticleOps>? core) =>
      core?.map(_articleOpsItem).toList();

  static ArticleOps _articleOpsItem(CoreArticleOps core) => ArticleOps(
    insert: core.insert,
    attributes: core.attributes == null
        ? null
        : Attributes(clazz: core.attributes!.clazz),
  );

  /// [CorePic] list → [Pic] list.
  ///
  /// Used by: article page (top image gallery). Core `src` maps to adapter
  /// `url`; `isLongPic` is recomputed by the adapter `fromJson` exactly as at
  /// the repository boundary.
  static List<Pic>? articlePics(List<CorePic>? core) =>
      core?.map(_articlePic).toList();

  static Pic _articlePic(CorePic core) => Pic.fromJson(<String, dynamic>{
    'url': core.src,
    'height': core.height,
    'width': core.width,
  });

  /// [CoreModuleCollection] → [ModuleCollection].
  ///
  /// Used by: article page (collection card).
  static ModuleCollection? articleCollection(CoreModuleCollection? core) =>
      core == null
          ? null
          : ModuleCollection.fromJson(<String, dynamic>{
              'count': core.count,
              'id': core.id,
              'name': core.name,
              'title': core.title,
            });

  /// [CoreArticleContentModel] → [ArticleContentModel].
  ///
  /// Used by: article page controller (`opus` getter). The core model is an
  /// empty placeholder — content is dropped at the repository boundary
  /// (`_toCoreArticleContentModel`), so the result is an empty adapter model
  /// that renders the OpusContent fallback branch (previously a runtime
  /// `TypeError` from the lazy `.cast<ArticleContentModel>()`).
  static ArticleContentModel articleContent(CoreArticleContentModel core) =>
      ArticleContentModel.fromJson(const <String, dynamic>{});

  // ---------------------------------------------------------------------------
  // History page conversions
  // ---------------------------------------------------------------------------

  /// [CoreHistoryItemModel] → [HistoryItemModel].
  ///
  /// Used by: history & history_search pages. All scalar fields map 1:1; the
  /// nested [CoreHistory] maps to the adapter [History] with the same fields.
  static HistoryItemModel historyItem(user.CoreHistoryItemModel core) =>
      HistoryItemModel(
        title: core.title,
        cover: core.cover,
        covers: core.covers,
        uri: core.uri,
        history: History(
          oid: core.history.oid,
          epid: core.history.epid,
          bvid: core.history.bvid,
          page: core.history.page,
          cid: core.history.cid,
          business: core.history.business,
        ),
        videos: core.videos,
        authorName: core.authorName,
        authorMid: core.authorMid,
        viewAt: core.viewAt,
        progress: core.progress,
        badge: core.badge,
        showTitle: core.showTitle,
        duration: core.duration,
        isFav: core.isFav,
        kid: core.kid,
        tagName: core.tagName,
        liveStatus: core.liveStatus,
      );
  static T? _mapNullable<T, R>(R? value, T Function(R) mapper) {
    if (value == null) return null;
    return mapper(value);
  }

  static List<T>? _mapList<T, R>(List<R>? list, T Function(R) mapper) {
    return list?.map(mapper).toList();
  }

  static CoreOwner _toCoreOwner(Owner m) {
    return CoreOwner(mid: m.mid, name: m.name, face: m.face);
  }
  static CoreDynamicItemModel dynamicItemToCore(DynamicItemModel m) {
    return CoreDynamicItemModel(
      basic: _mapNullable(m.basic, _toCoreBasic),
      idStr: m.idStr,
      modules: _mapNullable(m.modules, _toCoreItemModulesModel),
      orig: _mapNullable(m.orig, dynamicItemToCore),
      type: m.type,
      visible: m.visible,
      linkFolded: m.linkFolded,
      fallback: _mapNullable(m.fallback, _toCoreFallback),
    );
  }

  static CoreBasic _toCoreBasic(Basic m) {
    return CoreBasic(
      commentIdStr: m.commentIdStr,
      commentType: m.commentType,
      ridStr: m.ridStr,
    );
  }

  static CoreFallback _toCoreFallback(Fallback m) {
    return CoreFallback(id: m.id);
  }

  static CoreItemModulesModel _toCoreItemModulesModel(ItemModulesModel m) {
    return CoreItemModulesModel(
      moduleAuthor: _mapNullable(m.moduleAuthor, _toCoreModuleAuthorModel),
      moduleStat: _mapNullable(m.moduleStat, _toCoreModuleStatModel),
      moduleTag: _mapNullable(m.moduleTag, _toCoreModuleTag),
      moduleDynamic: _mapNullable(m.moduleDynamic, _toCoreModuleDynamicModel),
      moduleInteraction:
          _mapNullable(m.moduleInteraction, _toCoreModuleInteraction),
      moduleDispute: _mapNullable(m.moduleDispute, _toCoreModuleDispute),
      moduleTop: _mapNullable(m.moduleTop, _toCoreModuleTop),
      moduleCollection:
          _mapNullable(m.moduleCollection, _toCoreModuleCollection),
      moduleExtend: _mapList(m.moduleExtend, _toCoreModuleTag),
      moduleContent: _mapList(m.moduleContent, _toCoreArticleContentModel),
      moduleBlocked: _mapNullable(m.moduleBlocked, _toCoreModuleBlocked),
      moduleFold: _mapNullable(m.moduleFold, _toCoreModuleFold),
    );
  }

  /// Adapter → core stub: article content is dropped at the repository
  /// boundary (mirrors the repo's `_toCoreArticleContentModel`).
  static CoreArticleContentModel _toCoreArticleContentModel(
    ArticleContentModel m,
  ) {
    return CoreArticleContentModel();
  }

  static CoreModuleAuthorModel _toCoreModuleAuthorModel(ModuleAuthorModel m) {
    return CoreModuleAuthorModel(
      face: m.face,
      name: m.name,
      mid: m.mid,
      pubAction: m.pubAction,
      pubTime: m.pubTime,
      pubTs: m.pubTs,
      type: m.type,
      decorate: _mapNullable(m.decorate, _toCoreDecorate),
      isTop: m.isTop,
      badgeText: m.badgeText,
      pendant: m.pendant?.image,
      officialVerify: m.officialVerify?.type,
    );
  }

  static CoreDecorate _toCoreDecorate(Decorate m) {
    return CoreDecorate(
      cardUrl: m.cardUrl,
      fan: _mapNullable(m.fan, _toCoreFan),
    );
  }

  static CoreFan _toCoreFan(Fan m) {
    return CoreFan(color: m.color, numStr: m.numStr);
  }

  static CoreModuleStatModel _toCoreModuleStatModel(ModuleStatModel m) {
    return CoreModuleStatModel(
      comment: _mapNullable(m.comment, _toCoreDynamicStat),
      forward: _mapNullable(m.forward, _toCoreDynamicStat),
      like: _mapNullable(m.like, _toCoreDynamicStat),
      favorite: _mapNullable(m.favorite, _toCoreDynamicStat),
    );
  }

  static CoreDynamicStat _toCoreDynamicStat(DynamicStat m) {
    return CoreDynamicStat(count: m.count, status: m.status);
  }

  static CoreModuleTag _toCoreModuleTag(ModuleTag m) {
    return CoreModuleTag(text: m.text);
  }

  static CoreModuleDynamicModel _toCoreModuleDynamicModel(
    ModuleDynamicModel m,
  ) {
    return CoreModuleDynamicModel(
      additional: _mapNullable(m.additional, _toCoreDynamicAddModel),
      desc: _mapNullable(m.desc, _toCoreDynamicDescModel),
      major: _mapNullable(m.major, _toCoreDynamicMajorModel),
      topic: _mapNullable(m.topic, _toCoreDynamicTopicModel),
    );
  }

  static CoreDynamicAddModel _toCoreDynamicAddModel(DynamicAddModel m) {
    return CoreDynamicAddModel(
      type: m.type,
      vote: _mapNullable(m.vote, _toCoreVote),
      ugc: _mapNullable(m.ugc, _toCoreUgc),
      reserve: _mapNullable(m.reserve, _toCoreReserve),
      goods: _mapNullable(m.goods, _toCoreGood),
      upowerLottery: _mapNullable(m.upowerLottery, _toCoreUpowerLottery),
      common: _mapNullable(m.common, _toCoreAddCommon),
      match: _mapNullable(m.match, _toCoreAddMatch),
    );
  }

  static CoreVote _toCoreVote(Vote m) {
    return CoreVote(joinNum: m.joinNum, voteId: m.voteId, title: m.title);
  }

  static CoreUgc _toCoreUgc(Ugc m) {
    return CoreUgc(
      cover: m.cover,
      descSecond: m.descSecond,
      jumpUrl: m.jumpUrl,
      title: m.title,
    );
  }

  static CoreReserve _toCoreReserve(Reserve m) {
    return CoreReserve(
      button: _mapNullable(m.button, _toCoreReserveBtn),
      desc1: _mapNullable(m.desc1, _toCoreDesc),
      desc2: _mapNullable(m.desc2, _toCoreDesc),
      desc3: _mapNullable(m.desc3, _toCoreDesc),
      reserveTotal: m.reserveTotal,
      rid: m.rid,
      state: m.state,
      title: m.title,
    );
  }

  static CoreReserveBtn _toCoreReserveBtn(ReserveBtn m) {
    return CoreReserveBtn(
      status: m.status,
      type: m.type,
      checkText: m.checkText,
      uncheckText: m.uncheckText,
      disable: m.disable,
      jumpText: m.jumpText,
      jumpUrl: m.jumpUrl,
    );
  }

  static CoreDesc _toCoreDesc(Desc m) {
    return CoreDesc(text: m.text, jumpUrl: m.jumpUrl);
  }

  static CoreGood _toCoreGood(Good m) {
    return CoreGood(items: _mapList(m.items, _toCoreGoodItem));
  }

  static CoreGoodItem _toCoreGoodItem(GoodItem m) {
    return CoreGoodItem(
      cover: m.cover,
      jumpDesc: m.jumpDesc,
      jumpUrl: m.jumpUrl,
      name: m.name,
      price: m.price,
    );
  }

  static CoreUpowerLottery _toCoreUpowerLottery(UpowerLottery m) {
    return CoreUpowerLottery(
      button: _mapNullable(m.button, _toCoreButton),
      desc: _mapNullable(m.desc, _toCoreDesc),
      hint: _mapNullable(m.hint, _toCoreHint),
      jumpUrl: m.jumpUrl,
      title: m.title,
    );
  }

  static CoreHint _toCoreHint(Hint m) {
    return CoreHint(text: m.text);
  }

  static CoreAddCommon _toCoreAddCommon(AddCommon m) {
    return CoreAddCommon(
      button: _mapNullable(m.button, _toCoreButton),
      cover: m.cover,
      desc1: m.desc1,
      desc2: m.desc2,
      jumpUrl: m.jumpUrl,
      title: m.title,
    );
  }

  static CoreAddMatch _toCoreAddMatch(AddMatch m) {
    return CoreAddMatch(
      button: _mapNullable(m.button, _toCoreButton),
      jumpUrl: m.jumpUrl,
      matchInfo: _mapNullable(m.matchInfo, _toCoreMatchInfo),
    );
  }

  static CoreMatchInfo _toCoreMatchInfo(MatchInfo m) {
    return CoreMatchInfo(
      centerBottom: m.centerBottom,
      centerTop: m.centerTop,
      leftTeam: _mapNullable(m.leftTeam, _toCoreTTeam),
      rightTeam: _mapNullable(m.rightTeam, _toCoreTTeam),
      subTitle: m.subTitle,
      title: m.title,
    );
  }

  static CoreTTeam _toCoreTTeam(TTeam m) {
    return CoreTTeam(name: m.name, pic: m.pic);
  }

  static CoreButton _toCoreButton(Button m) {
    return CoreButton(
      icon: m.icon,
      jumpUrl: m.jumpUrl,
      text: m.text,
      jumpStyle: _mapNullable(m.jumpStyle, _toCoreJumpStyle),
      check: _mapNullable(m.check, _toCoreCheck),
    );
  }

  static CoreJumpStyle _toCoreJumpStyle(JumpStyle m) {
    return CoreJumpStyle(text: m.text);
  }

  static CoreCheck _toCoreCheck(Check m) {
    return CoreCheck(text: m.text);
  }

  static CoreBgImg _toCoreBgImg(BgImg m) {
    return CoreBgImg(imgDark: m.imgDark, imgDay: m.imgDay);
  }

  static CoreDynamicDescModel _toCoreDynamicDescModel(DynamicDescModel m) {
    return CoreDynamicDescModel(
      richTextNodes: _mapList(m.richTextNodes, _toCoreRichTextNodeItem),
      text: m.text,
    );
  }

  static CoreDynamicMajorModel _toCoreDynamicMajorModel(DynamicMajorModel m) {
    return CoreDynamicMajorModel(
      archive: _mapNullable(m.archive, _toCoreDynamicArchiveModel),
      ugcSeason: _mapNullable(m.ugcSeason, _toCoreDynamicArchiveModel),
      opus: _mapNullable(m.opus, _toCoreDynamicOpusModel),
      pgc: _mapNullable(m.pgc, _toCoreDynamicArchiveModel),
      liveRcmd: _mapNullable(m.liveRcmd, _toCoreDynamicLiveModel),
      live: _mapNullable(m.live, _toCoreDynamicLive2Model),
      none: _mapNullable(m.none, _toCoreDynamicNoneModel),
      type: m.type,
      courses: _mapNullable(m.courses, _toCoreDynamicArchiveModel),
      common: _mapNullable(m.common, _toCoreCommon),
      upowerCommon: _mapNullable(m.upowerCommon, _toCoreCommon),
      music: _mapNullable(m.music, _toCoreMusic),
      blocked: _mapNullable(m.blocked, _toCoreModuleBlocked),
      medialist: _mapNullable(m.medialist, _toCoreMedialist),
      subscriptionNew:
          _mapNullable(m.subscriptionNew, _toCoreSubscriptionNew),
    );
  }

  static CoreDynamicArchiveModel _toCoreDynamicArchiveModel(
    DynamicArchiveModel m,
  ) {
    return CoreDynamicArchiveModel(
      id: m.id,
      aid: m.aid,
      badge: _mapNullable(m.badge, _toCoreBadge),
      bvid: m.bvid,
      cover: m.cover,
      durationText: m.durationText,
      jumpUrl: m.jumpUrl,
      stat: _mapNullable(m.stat, _toCoreStat),
      title: m.title,
      type: m.type,
      epid: m.epid,
      seasonId: m.seasonId,
    );
  }

  static CoreBadge _toCoreBadge(Badge m) {
    return CoreBadge(text: m.text);
  }

  static CoreStat _toCoreStat(Stat m) {
    return CoreStat(danmu: m.danmu, play: m.play);
  }

  static CoreDynamicOpusModel _toCoreDynamicOpusModel(DynamicOpusModel m) {
    return CoreDynamicOpusModel(
      pics: _mapList(m.pics, opusPicToCore),
      summary: _mapNullable(m.summary, _toCoreSummaryModel),
      title: m.title,
    );
  }

  static CoreSummaryModel _toCoreSummaryModel(SummaryModel m) {
    return CoreSummaryModel(
      richTextNodes: _mapList(m.richTextNodes, _toCoreRichTextNodeItem),
      text: m.text,
    );
  }

  static CoreOpusPicModel opusPicToCore(OpusPicModel m) {
    return CoreOpusPicModel(
      width: m.width,
      height: m.height,
      src: m.src,
      url: m.url,
      liveUrl: m.liveUrl,
      size: m.size,
    );
  }

  static CoreRichTextNodeItem _toCoreRichTextNodeItem(RichTextNodeItem m) {
    return CoreRichTextNodeItem(
      emoji: _mapNullable(m.emoji, _toCoreEmoji),
      origText: m.origText,
      text: m.text,
      type: m.type,
      rid: m.rid,
      pics: _mapList(m.pics, opusPicToCore),
      jumpUrl: m.jumpUrl,
    );
  }

  static CoreEmoji _toCoreEmoji(Emoji m) {
    return CoreEmoji(url: m.url, size: m.size);
  }

  static CoreDynamicLiveModel _toCoreDynamicLiveModel(DynamicLiveModel m) {
    return CoreDynamicLiveModel(
      roomId: m.roomId,
      liveStatus: m.liveStatus,
      cover: m.cover,
      areaName: m.areaName,
      title: m.title,
      watchedShow: _mapNullable(m.watchedShow, _toCoreWatchedShow),
    );
  }

  static CoreDynamicLive2Model _toCoreDynamicLive2Model(DynamicLive2Model m) {
    return CoreDynamicLive2Model(
      badge: _mapNullable(m.badge, _toCoreBadge),
      cover: m.cover,
      descFirst: m.descFirst,
      id: m.id,
      liveState: m.liveState,
      title: m.title,
    );
  }

  static CoreDynamicNoneModel _toCoreDynamicNoneModel(DynamicNoneModel m) {
    return CoreDynamicNoneModel(tips: m.tips);
  }

  static CoreWatchedShow _toCoreWatchedShow(WatchedShow m) {
    return CoreWatchedShow(text: m.textLarge);
  }

  static CoreCommon _toCoreCommon(Common m) {
    return CoreCommon(
      cover: m.cover,
      title: m.title,
      titlePrefix: m.titlePrefix,
      desc: m.desc,
      jumpUrl: m.jumpUrl,
    );
  }

  static CoreMusic _toCoreMusic(Music m) {
    return CoreMusic(id: m.id, cover: m.cover, title: m.title, label: m.label);
  }

  static CoreMedialist _toCoreMedialist(Medialist m) {
    return CoreMedialist(
      id: m.id,
      cover: m.cover,
      title: m.title,
      subTitle: m.subTitle,
      jumpUrl: m.jumpUrl,
      badge: _mapNullable(m.badge, _toCoreBadge),
    );
  }

  static CoreSubscriptionNew _toCoreSubscriptionNew(SubscriptionNew m) {
    return CoreSubscriptionNew(
      liveRcmd: _mapNullable(m.liveRcmd, _toCoreLiveRcmd),
    );
  }

  static CoreLiveRcmd _toCoreLiveRcmd(LiveRcmd m) {
    return CoreLiveRcmd(
      content: _mapNullable(m.content, _toCoreLiveRcmdContent),
    );
  }

  static CoreLiveRcmdContent _toCoreLiveRcmdContent(LiveRcmdContent m) {
    return CoreLiveRcmdContent(
      livePlayInfo: _mapNullable(m.livePlayInfo, _toCoreLivePlayInfo),
    );
  }

  static CoreLivePlayInfo _toCoreLivePlayInfo(LivePlayInfo m) {
    return CoreLivePlayInfo(
      roomId: m.roomId,
      liveStatus: m.liveStatus,
      title: m.title,
      cover: m.cover,
      areaName: m.areaName,
      watchedShow: _mapNullable(m.watchedShow, _toCoreWatchedShow),
    );
  }

  static CoreDynamicTopicModel _toCoreDynamicTopicModel(DynamicTopicModel m) {
    return CoreDynamicTopicModel(id: m.id, name: m.name);
  }

  static CoreModuleInteraction _toCoreModuleInteraction(
    ModuleInteraction m,
  ) {
    return CoreModuleInteraction(
      items: _mapList(m.items, _toCoreModuleInteractionItem),
    );
  }

  static CoreModuleInteractionItem _toCoreModuleInteractionItem(
    ModuleInteractionItem m,
  ) {
    return CoreModuleInteractionItem(
      type: m.type,
      desc: _mapNullable(m.desc, _toCoreDynamicDescModel),
    );
  }

  static CoreModuleDispute _toCoreModuleDispute(ModuleDispute m) {
    return CoreModuleDispute(
      title: m.title,
      desc: m.desc,
      jumpUrl: m.jumpUrl,
    );
  }

  static CoreModuleFold _toCoreModuleFold(ModuleFold m) {
    return CoreModuleFold(
      ids: m.ids,
      statement: m.statement,
      users: _mapList(m.users, _toCoreOwner),
    );
  }

  static CoreModuleTop _toCoreModuleTop(ModuleTop m) {
    return CoreModuleTop(
      display: _mapNullable(m.display, _toCoreModuleTopDisplay),
    );
  }

  static CoreModuleTopDisplay _toCoreModuleTopDisplay(ModuleTopDisplay m) {
    return CoreModuleTopDisplay(
      album: _mapNullable(m.album, _toCoreModuleTopAlbum),
    );
  }

  static CoreModuleTopAlbum _toCoreModuleTopAlbum(ModuleTopAlbum m) {
    return CoreModuleTopAlbum(pics: _mapList(m.pics, _toCorePic));
  }

  static CorePic _toCorePic(Pic m) {
    return CorePic(src: m.url, height: m.height, width: m.width);
  }

  static CoreModuleCollection _toCoreModuleCollection(ModuleCollection m) {
    return CoreModuleCollection(
      count: m.count,
      id: m.id,
      name: m.name,
      title: m.title,
    );
  }

  static CoreModuleBlocked _toCoreModuleBlocked(ModuleBlocked m) {
    return CoreModuleBlocked(
      bgImg: _mapNullable(m.bgImg, _toCoreBgImg),
      blockedType: m.blockedType,
      button: _mapNullable(m.button, _toCoreButton),
      title: m.title,
      hintMessage: m.hintMessage,
      icon: _mapNullable(m.icon, _toCoreBgImg),
    );
  }
  static CorePgcReviewType pgcReviewType(PgcReviewType v) {
    return switch (v) {
      PgcReviewType.long => CorePgcReviewType.long,
      PgcReviewType.short => CorePgcReviewType.short,
    };
  }

  // ---------------------------------------------------------------------------
  // Download entry conversions (fields 1:1, JSON round-trip)
  // ---------------------------------------------------------------------------

  /// [CoreDownloadEntryInfo] → [BiliDownloadEntryInfo].
  ///
  /// status/路径字段不在 JSON 中，需手动拷贝（DownloadService 内部以
  /// adapter 对象持有队列/列表，页面侧统一走 core 模型）。
  static BiliDownloadEntryInfo toBiliDownloadEntry(CoreDownloadEntryInfo core) =>
      BiliDownloadEntryInfo.fromJson(core.toJson())
        ..status = DownloadStatus.values.byName(core.status.name)
        ..pageDirPath = core.pageDirPath
        ..entryDirPath = core.entryDirPath;

  /// [BiliDownloadEntryInfo] → [CoreDownloadEntryInfo].
  static CoreDownloadEntryInfo toCoreDownloadEntry(BiliDownloadEntryInfo m) =>
      CoreDownloadEntryInfo.fromJson(m.toJson())
        ..status = CoreDownloadStatus.values.byName(m.status.name)
        ..pageDirPath = m.pageDirPath
        ..entryDirPath = m.entryDirPath;
}
