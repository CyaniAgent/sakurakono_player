import 'package:skf/adapters/bilibili/grpc/bilibili/main/community/reply/v1.pb.dart'
    show ReplyInfo;

import 'package:skf/adapters/bilibili/http/video.dart';
import 'package:skf/adapters/bilibili/models/common/video/video_type.dart';
import 'package:skf/adapters/bilibili/models/home/rcmd/result.dart';
import 'package:skf/adapters/bilibili/models/model_hot_video_item.dart';
import 'package:skf/adapters/bilibili/models/model_owner.dart';
import 'package:skf/adapters/bilibili/models/model_rec_video_item.dart';
import 'package:skf/adapters/bilibili/models/pgc_lcf.dart';
import 'package:skf/adapters/bilibili/models/video/play/url.dart';
import 'package:skf/adapters/bilibili/models_new/pgc/pgc_rank/pgc_rank_item_model.dart';
import 'package:skf/adapters/bilibili/models_new/popular/popular_precious/data.dart';
import 'package:skf/adapters/bilibili/models_new/popular/popular_series_list/list.dart';
import 'package:skf/adapters/bilibili/models_new/popular/popular_series_one/data.dart';
import 'package:skf/adapters/bilibili/models_new/triple/pgc_triple.dart';
import 'package:skf/adapters/bilibili/models_new/triple/ugc_triple.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_ai_conclusion/data.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/data.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_note_list/data.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_play_info/data.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_relation/data.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_shot/data.dart';
import 'package:skf/adapters/bilibili/utils/subtitle_utils.dart' as adapter_subtitle;
import 'package:skf/core/models/video_types.dart';
import 'package:skf/core/repository/video_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:skf/core/utils/subtitle_utils.dart' show SubtitleFormat;

/// Bilibili implementation of [VideoRepository] that delegates to [VideoHttp].
class BiliVideoRepository implements VideoRepository {
  // ---------------------------------------------------------------------------
  // LoadingState mapper helpers
  // ---------------------------------------------------------------------------

  static LoadingState<T> _mapState<T, A>(
    LoadingState<A> source,
    T Function(A data) mapper,
  ) =>
      switch (source) {
        Loading() => LoadingState.loading(),
        Success(data: final data) => Success(mapper(data)),
        Error(errMsg: final msg, code: final code) => Error(msg, code: code),
      };

  // ---------------------------------------------------------------------------
  // VideoType conversion
  // ---------------------------------------------------------------------------

  static VideoType _toAdapterVideoType(CoreVideoType type) => switch (type) {
    CoreVideoType.ugc => VideoType.ugc,
    CoreVideoType.pgc => VideoType.pgc,
    CoreVideoType.pugv => VideoType.pugv,
  };

  static adapter_subtitle.SubtitleFormat _toAdapterSubtitleFormat(
          SubtitleFormat format) =>
      switch (format) {
        SubtitleFormat.json => adapter_subtitle.SubtitleFormat.json,
        SubtitleFormat.vtt => adapter_subtitle.SubtitleFormat.vtt,
        SubtitleFormat.srt => adapter_subtitle.SubtitleFormat.srt,
      };

  // ---------------------------------------------------------------------------
  // Model conversion helpers (adapter → core)
  // ---------------------------------------------------------------------------

  static CoreRcmdVideoItemModel _toCoreRcmdItem(RcmdVideoItemModel m) =>
      CoreRcmdVideoItemModel(
        aid: m.aid,
        bvid: m.bvid,
        cid: m.cid,
        cover: m.cover,
        title: m.title,
        duration: m.duration,
        pubdate: m.pubdate,
        owner: {'mid': m.owner.mid, 'name': m.owner.name},
        stat: {'view': m.stat.view, 'danmaku': m.stat.danmu},
        isFollowed: m.isFollowed,
        goto: m.goto,
        uri: m.uri,
        rcmdReason: m.rcmdReason,
      );

  static CoreRcmdVideoItemAppModel _toCoreRcmdAppItem(RcmdVideoItemAppModel m) =>
      CoreRcmdVideoItemAppModel(
        aid: m.aid,
        bvid: m.bvid,
        cid: m.cid,
        cover: m.cover,
        title: m.title,
        duration: m.duration,
        pubdate: m.pubdate,
        desc: m.desc,
        owner: {'name': m.owner.name ?? '', 'mid': m.owner.mid ?? 0},
        stat: {
          'view': (m.stat as RcmdStat?)?.view ?? '',
          'danmu': (m.stat as RcmdStat?)?.danmu ?? '',
        },
        isFollowed: m.isFollowed,
        goto: m.goto,
        uri: m.uri,
        rcmdReason: m.isFollowed ? null : m.rcmdReason,
        param: m.param,
        pgcBadge: m.pgcBadge,
        talkBack: m.talkBack,
        cardType: m.cardType,
        threePoint: m.threePoint != null
            ? {'dislikeReasons': m.threePoint!.dislikeReasons}
            : null,
      );

  static CoreHotVideoItemModel _toCoreHotItem(HotVideoItemModel m) =>
      CoreHotVideoItemModel(
        aid: m.aid,
        bvid: m.bvid,
        cid: m.cid,
        cover: m.cover,
        title: m.title,
        duration: m.duration,
        pubdate: m.pubdate,
        desc: m.desc,
        owner: {
                'mid': m.owner.mid,
                'name': m.owner.name,
                'face': (m.owner as Owner).face,
              },
        stat: {
                'view': m.stat.view,
                'like': m.stat.like,
                'danmu': m.stat.danmu,
                if (m.stat case HotStat s)
                  ...{
                    'reply': s.reply,
                    'favorite': s.favorite,
                    'coin': s.coin,
                    'share': s.share,
                    'now_rank': s.nowRank,
                    'his_rank': s.hisRank,
                    'dislike': s.dislike,
                  },
              },
        dimension: m.dimension != null
            ? {'width': m.dimension!.width, 'height': m.dimension!.height}
            : null,
        videos: m.videos,
        tid: m.tid,
        tname: m.tname,
        copyright: m.copyright,
        ctime: m.ctime,
        state: m.state,
        firstFrame: m.firstFrame,
        pubLocation: m.pubLocation,
        redirectUrl: m.redirectUrl,
        progress: m.progress?.toInt(),
        badge: m.badge,
      );

  static CorePlayUrlModel _toCorePlayUrl(PlayUrlModel m) =>
      CorePlayUrlModel(
        from: m.from,
        result: m.result,
        message: m.message,
        quality: m.quality,
        format: m.format,
        timeLength: m.timeLength,
        acceptFormat: m.acceptFormat,
        acceptDesc: m.acceptDesc,
        acceptQuality: m.acceptQuality,
        videoCodecid: m.videoCodecid,
        seekParam: m.seekParam,
        seekType: m.seekType,
        dash: _dashToMap(m.dash),
        durl: m.durl?.map(_durlToMap).toList(),
        supportFormats: m.supportFormats?.map(_formatItemToMap).toList(),
        volume: m.volume != null
            ? {
                'measured_i': m.volume!.measuredI,
                'measured_lra': m.volume!.measuredLra,
                'measured_tp': m.volume!.measuredTp,
                'measured_threshold': m.volume!.measuredThreshold,
                'target_offset': m.volume!.targetOffset,
                'target_i': m.volume!.targetI,
                'target_tp': m.volume!.targetTp,
              }
            : null,
        lastPlayTime: m.lastPlayTime,
        lastPlayCid: m.lastPlayCid,
        curLanguage: m.curLanguage,
        language: m.language != null
            ? {
                'support': m.language!.support,
                'items': m.language!.items?.map(_languageItemToMap).toList(),
              }
            : null,
        clipInfoList: m.clipInfoList?.map((s) => s.toJson()).toList(),
      );

  static Map<String, dynamic>? _dashToMap(Dash? d) {
    if (d == null) return null;
    return {
      'duration': d.duration,
      'minBufferTime': d.minBufferTime,
      'video': d.video?.map(_baseItemToMap).toList(),
      'audio': d.audio?.map(_baseItemToMap).toList(),
    };
  }

  static Map<String, dynamic> _baseItemToMap(BaseItem i) => {
        'id': i.id,
        'base_url': i.baseUrl,
        'backup_url': i.backupUrl,
        'bandwidth': i.bandWidth,
        'mime_type': i.mimeType,
        'codecs': i.codecs,
        'width': i.width,
        'height': i.height,
        'frame_rate': i.frameRate,
        'sar': i.sar,
        'start_with_sap': i.startWithSap,
        'segment_base': i.segmentBase,
        'codecid': i.codecid,
      };

  static Map<String, dynamic> _durlToMap(Durl d) => {
        'order': d.order,
        'length': d.length,
        'size': d.size,
        'ahead': d.ahead,
        'vhead': d.vhead,
        'url': d.url,
        'backup_url': d.backupUrl,
      };

  static Map<String, dynamic> _formatItemToMap(FormatItem f) => {
        'quality': f.quality,
        'format': f.format,
        'new_description': f.newDesc,
        'display_desc': f.displayDesc,
        'codecs': f.codecs,
      };

  static Map<String, dynamic> _languageItemToMap(LanguageItem i) => {
        'lang': i.lang,
        'title': i.title,
        'subtitle_lang': i.subtitleLang,
      };

  static CoreVideoDetailData _toCoreVideoDetail(VideoDetailData d) =>
      CoreVideoDetailData(
        bvid: d.bvid,
        aid: d.aid,
        videos: d.videos,
        copyright: d.copyright,
        pic: d.pic,
        title: d.title,
        pubdate: d.pubdate,
        ctime: d.ctime,
        desc: d.desc,
        duration: d.duration,
        rights: d.rights != null
            ? {'is_stein_gate': d.rights!.isSteinGate}
            : null,
        owner: d.owner?.toJson(),
        stat: d.stat != null
            ? {
                'view': d.stat!.view,
                'like': d.stat!.like,
                'coin': d.stat!.coin,
                'favorite': d.stat!.favorite,
                'share': d.stat!.share,
                'danmaku': d.stat!.danmaku,
                'reply': d.stat!.reply,
              }
            : null,
        cid: d.cid,
        dimension: d.dimension != null
            ? {'width': d.dimension!.width, 'height': d.dimension!.height}
            : null,
        seasonId: d.seasonId,
        isUpowerExclusive: d.isUpowerExclusive,
        redirectUrl: d.redirectUrl,
      );

  static CoreVideoRelation _toCoreRelation(VideoRelation r) => CoreVideoRelation(
        attention: r.attention,
        favorite: r.favorite,
        seasonFav: r.seasonFav,
        like: r.like,
        dislike: r.dislike,
        coin: r.coin,
      );

  static CorePgcLCF _toCorePgcLCF(PgcLCF p) => CorePgcLCF(
        coinNumber: p.coinNumber,
        favorite: p.favorite,
        isOriginal: p.isOriginal,
        like: p.like,
      );

  static CorePgcTriple _toCorePgcTriple(PgcTriple p) => CorePgcTriple(
        coin: p.coin,
        coinNumber: p.coinNumber,
        favorite: p.favorite,
        fmid: p.fmid,
        follow: p.follow,
        like: p.like,
        relation: p.relation,
      );

  static CoreUgcTriple _toCoreUgcTriple(UgcTriple u) => CoreUgcTriple(
        like: u.like,
        coin: u.coin,
        fav: u.fav,
        multiply: u.multiply,
      );

  static CoreReplyInfo _toCoreReplyInfo(ReplyInfo r) => CoreReplyInfo(
        id: r.id.toInt(),
        oid: r.oid.toInt(),
        type: r.type.toInt(),
        mid: r.mid.toInt(),
        root: r.root.toInt(),
        parent: r.parent.toInt(),
        dialog: r.dialog.toInt(),
        like: r.like.toInt(),
        ctime: r.ctime.toInt(),
        count: r.count.toInt(),
        content: r.content.toProto3Json() as Map<String, dynamic>?,
        member: r.member.toProto3Json() as Map<String, dynamic>?,
        replyControl: r.replyControl.toProto3Json() as Map<String, dynamic>?,
        trackInfo: r.trackInfo,
      );

  static CoreAiConclusionData _toCoreAiConclusion(AiConclusionData a) =>
      CoreAiConclusionData(
        modelResult: a.modelResult != null
            ? {
                'summary': a.modelResult!.summary,
                'part_outline': a.modelResult!.outline
                    ?.expand((o) => o.partOutline ?? [])
                    .map((o) => {
                          'timestamp': o.timestamp,
                          'content': o.content,
                        })
                    .toList(),
              }
            : null,
      );

  static CorePlayInfoData _toCorePlayInfo(PlayInfoData p) =>
      CorePlayInfoData.fromJson({
        'last_play_cid': p.lastPlayCid,
        'subtitle': p.subtitle != null
            ? {
                'lan': p.subtitle!.lan,
                'lan_doc': p.subtitle!.lanDoc,
            }
            : null,
        'view_points': p.viewPoints
            ?.map((v) => {
                  'type': v.type,
                  'from': v.from,
                  'to': v.to,
                  'content': v.content,
                  'img_url': v.imgUrl,
                })
            .toList(),
        'interaction': p.interaction != null
            ? {
                'history_node': p.interaction!.historyNode != null
                    ? {
                        'node_id': p.interaction!.historyNode!.nodeId,
                        'title': p.interaction!.historyNode!.title,
                        'cid': p.interaction!.historyNode!.cid,
                      }
                    : null,
                'graph_version': p.interaction!.graphVersion,
            }
            : null,
      });

  static CoreVideoShotData _toCoreVideoShot(VideoShotData s) =>
      CoreVideoShotData(
        pvdata: s.pvdata,
        imgXLen: s.imgXLen,
        imgYLen: s.imgYLen,
        imgXSize: s.imgXSize,
        imgYSize: s.imgYSize,
        image: s.image,
        index: s.index,
      );

  static CoreVideoNoteData _toCoreVideoNote(VideoNoteData n) =>
      CoreVideoNoteData(
        list: n.list
            ?.map((item) => {
                  'cvid': item.cvid,
                  'summary': item.summary,
                  'pubtime': item.pubtime,
                  'author': item.author != null
                      ? {
                          'mid': item.author!.mid,
                          'name': item.author!.name,
                          'face': item.author!.face,
                        }
                      : null,
                })
            .toList(),
        page: n.page != null ? {'total': n.page!.total} : null,
      );

  static CorePopularSeriesListItem _toCorePopularSeriesItem(
          PopularSeriesListItem p) =>
      CorePopularSeriesListItem(number: p.number, name: p.name);

  static CorePopularSeriesOneData _toCorePopularSeriesOne(
          PopularSeriesOneData p) =>
      CorePopularSeriesOneData(
        config: p.config != null
            ? {'name': p.config!.name, 'label': p.config!.label, 'media_id': p.config!.mediaId}
            : null,
        reminder: p.reminder,
        list: p.list?.map(_toCoreHotItem).toList(),
      );

  static CorePopularPreciousData _toCorePopularPrecious(
          PopularPreciousData p) =>
      CorePopularPreciousData(
        mediaId: p.mediaId,
        list: p.list?.map(_toCoreHotItem).toList(),
      );

  static CorePgcRankItemModel _toCorePgcRankItem(PgcRankItemModel p) =>
      CorePgcRankItemModel.fromJson({
        'cover': p.cover,
        'new_ep': p.newEp != null ? {'index_show': p.newEp!.indexShow} : null,
        'stat': p.stat != null ? {'follow': p.stat!.follow, 'view': p.stat!.view} : null,
        'title': p.title,
        'url': p.url,
      });

  @override
  Future<LoadingState<List<CoreRcmdVideoItemModel>>> rcmdVideoList({
    required int ps,
    required int freshIdx,
  }) async {
    return _mapState(
      await VideoHttp.rcmdVideoList(ps: ps, freshIdx: freshIdx),
      (data) => data.map(_toCoreRcmdItem).toList(),
    );
  }

  @override
  Future<LoadingState<List<CoreRcmdVideoItemAppModel>>> rcmdVideoListApp({
    required int freshIdx,
  }) async {
    return _mapState(
      await VideoHttp.rcmdVideoListApp(freshIdx: freshIdx),
      (data) => data.map(_toCoreRcmdAppItem).toList(),
    );
  }

  @override
  Future<LoadingState<List<CoreHotVideoItemModel>>> hotVideoList({
    required int pn,
    required int ps,
  }) async {
    return _mapState(
      await VideoHttp.hotVideoList(pn: pn, ps: ps),
      (data) => data.map(_toCoreHotItem).toList(),
    );
  }

  @override
  Future<LoadingState<CorePlayUrlModel>> videoUrl({
    int? avid,
    String? bvid,
    required int cid,
    int? qn,
    dynamic epid,
    dynamic seasonId,
    required bool tryLook,
    required CoreVideoType videoType,
    String? language,
    bool voiceBalance = false,
  }) async {
    return _mapState(
      await VideoHttp.videoUrl(
        avid: avid,
        bvid: bvid,
        cid: cid,
        qn: qn,
        epid: epid,
        seasonId: seasonId,
        tryLook: tryLook,
        videoType: _toAdapterVideoType(videoType),
        language: language,
        voiceBalance: voiceBalance,
      ),
      _toCorePlayUrl,
    );
  }

  @override
  Future<LoadingState<CoreVideoDetailData>> videoIntro({
    required String bvid,
  }) async {
    return _mapState(
      await VideoHttp.videoIntro(bvid: bvid),
      _toCoreVideoDetail,
    );
  }

  @override
  Future<LoadingState<CoreVideoRelation>> videoRelation({
    required String bvid,
  }) async {
    return _mapState(
      await VideoHttp.videoRelation(bvid: bvid),
      _toCoreRelation,
    );
  }

  @override
  Future<LoadingState<List<CoreHotVideoItemModel>?>> relatedVideoList({
    required String bvid,
  }) async {
    return _mapState(
      await VideoHttp.relatedVideoList(bvid: bvid),
      (data) => data?.map(_toCoreHotItem).toList(),
    );
  }

  @override
  Future<LoadingState<CorePgcLCF>> pgcLikeCoinFav({
    required Object epId,
  }) async {
    return _mapState(
      await VideoHttp.pgcLikeCoinFav(epId: epId),
      _toCorePgcLCF,
    );
  }

  @override
  Future<LoadingState<void>> coinVideo({
    required String bvid,
    required int multiply,
    int selectLike = 0,
  }) {
    return 
      VideoHttp.coinVideo(
        bvid: bvid,
        multiply: multiply,
        selectLike: selectLike,
      );
  }

  @override
  Future<LoadingState<CorePgcTriple>> pgcTriple({
    required Object epId,
    Object? seasonId,
  }) async {
    return _mapState(
      await VideoHttp.pgcTriple(epId: epId, seasonId: seasonId),
      _toCorePgcTriple,
    );
  }

  @override
  Future<LoadingState<CoreUgcTriple>> ugcTriple({
    required String bvid,
  }) async {
    return _mapState(
      await VideoHttp.ugcTriple(bvid: bvid),
      _toCoreUgcTriple,
    );
  }

  @override
  Future<LoadingState<String>> likeVideo({
    required String bvid,
    required bool type,
  }) {
    return VideoHttp.likeVideo(bvid: bvid, type: type);
  }

  @override
  Future<LoadingState<void>> dislikeVideo({
    required String bvid,
    required bool type,
  }) {
    return VideoHttp.dislikeVideo(bvid: bvid, type: type);
  }

  @override
  Future<LoadingState<void>> relationMod({
    required int mid,
    required int act,
    required int reSrc,
  }) {
    return VideoHttp.relationMod(
      mid: mid,
      act: act,
      reSrc: reSrc,
    );
  }

  @override
  Future<LoadingState<void>> feedDislike({
    required String goto,
    required int id,
    int? reasonId,
    int? feedbackId,
  }) {
    return VideoHttp.feedDislike(
      goto: goto,
      id: id,
      reasonId: reasonId,
      feedbackId: feedbackId,
    );
  }

  @override
  Future<LoadingState<void>> feedDislikeCancel({
    required String goto,
    required int id,
    int? reasonId,
    int? feedbackId,
  }) {
    return VideoHttp.feedDislikeCancel(
      goto: goto,
      id: id,
      reasonId: reasonId,
      feedbackId: feedbackId,
    );
  }

  @override
  Future<LoadingState<CoreReplyInfo?>> replyAdd({
    required int type,
    required int oid,
    required String message,
    int? root,
    int? parent,
    List? pictures,
    bool syncToDynamic = false,
    Map<String, int>? atNameToMid,
  }) async {
    final result = await VideoHttp.replyAdd(
      type: type,
      oid: oid,
      message: message,
      root: root,
      parent: parent,
      pictures: pictures,
      syncToDynamic: syncToDynamic,
      atNameToMid: atNameToMid,
    );
    return _mapState<CoreReplyInfo?, ReplyInfo?>(
      result,
      (r) => r != null ? _toCoreReplyInfo(r) : null,
    );
  }

  @override
  Future<LoadingState<void>> replyDel({
    required int type,
    required int oid,
    required int rpid,
  }) {
    return VideoHttp.replyDel(type: type, oid: oid, rpid: rpid);
  }

  @override
  Future<LoadingState<String>> pgcAdd({int? seasonId}) {
    return VideoHttp.pgcAdd(seasonId: seasonId);
  }

  @override
  Future<LoadingState<String>> pgcDel({int? seasonId}) {
    return VideoHttp.pgcDel(seasonId: seasonId);
  }

  @override
  Future<LoadingState<String>> pgcUpdate({
    required String seasonId,
    required int status,
  }) {
    return VideoHttp.pgcUpdate(seasonId: seasonId, status: status);
  }

  @override
  Future<LoadingState<String>> onlineTotal({
    int? aid,
    String? bvid,
    required int cid,
  }) {
    return VideoHttp.onlineTotal(aid: aid, bvid: bvid, cid: cid);
  }

  @override
  Future<LoadingState<CoreAiConclusionData>> aiConclusion({
    required String bvid,
    required int cid,
    int? upMid,
  }) async {
    return _mapState(
      await VideoHttp.aiConclusion(bvid: bvid, cid: cid, upMid: upMid),
      _toCoreAiConclusion,
    );
  }

  @override
  Future<LoadingState<CorePlayInfoData>> playInfo({
    String? aid,
    String? bvid,
    required int cid,
    dynamic seasonId,
    dynamic epId,
  }) async {
    return _mapState(
      await VideoHttp.playInfo(
        aid: aid,
        bvid: bvid,
        cid: cid,
        seasonId: seasonId,
        epId: epId,
      ),
      _toCorePlayInfo,
    );
  }

  @override
  Future<String?> vttSubtitles(
    String subtitleUrl, {
    SubtitleFormat format = SubtitleFormat.vtt,
  }) {
    return VideoHttp.vttSubtitles(
      subtitleUrl,
      format: _toAdapterSubtitleFormat(format),
    );
  }

  @override
  Future<LoadingState<List<CoreHotVideoItemModel>>> getRankVideoList(int rid) async {
    return _mapState(
      await VideoHttp.getRankVideoList(rid),
      (data) => data.map(_toCoreHotItem).toList(),
    );
  }

  @override
  Future<LoadingState<List<CorePgcRankItemModel>?>> pgcRankList({
    int day = 3,
    required int seasonType,
  }) async {
    return _mapState(
      await VideoHttp.pgcRankList(day: day, seasonType: seasonType),
      (data) => data?.map(_toCorePgcRankItem).toList(),
    );
  }

  @override
  Future<LoadingState<List<CorePgcRankItemModel>?>> pgcSeasonRankList({
    int day = 3,
    required int seasonType,
  }) async {
    return _mapState(
      await VideoHttp.pgcSeasonRankList(day: day, seasonType: seasonType),
      (data) => data?.map(_toCorePgcRankItem).toList(),
    );
  }

  @override
  Future<LoadingState<CoreVideoShotData>> videoshot({
    required String bvid,
    required int cid,
  }) async {
    return _mapState(
      await VideoHttp.videoshot(bvid: bvid, cid: cid),
      _toCoreVideoShot,
    );
  }

  @override
  Future<LoadingState<CoreVideoNoteData>> getVideoNoteList({
    dynamic oid,
    dynamic uperMid,
    required int page,
  }) async {
    return _mapState(
      await VideoHttp.getVideoNoteList(oid: oid, uperMid: uperMid, page: page),
      _toCoreVideoNote,
    );
  }

  @override
  Future<LoadingState<List<CorePopularSeriesListItem>?>> popularSeriesList() async {
    return _mapState(
      await VideoHttp.popularSeriesList(),
      (data) => data?.map(_toCorePopularSeriesItem).toList(),
    );
  }

  @override
  Future<LoadingState<CorePopularSeriesOneData>> popularSeriesOne({
    required int number,
  }) async {
    return _mapState(
      await VideoHttp.popularSeriesOne(number: number),
      _toCorePopularSeriesOne,
    );
  }

  @override
  Future<LoadingState<CorePopularPreciousData>> popularPrecious({
    required int page,
  }) async {
    return _mapState(
      await VideoHttp.popularPrecious(page: page),
      _toCorePopularPrecious,
    );
  }

  @override
  Future<void> historyReport({
    required Object aid,
    required Object type,
  }) {
    return VideoHttp.historyReport(aid: aid, type: type);
  }

  @override
  Future<void> heartBeat({
    Object? aid,
    Object? bvid,
    required Object cid,
    required Object progress,
    Object? epid,
    Object? seasonId,
    Object? subType,
    required CoreVideoType videoType,
  }) {
    return VideoHttp.heartBeat(
      aid: aid,
      bvid: bvid,
      cid: cid,
      progress: progress,
      epid: epid,
      seasonId: seasonId,
      subType: subType,
      videoType: _toAdapterVideoType(videoType));
  }

  @override
  Future<void> roomEntryAction({required Object roomId}) {
    return VideoHttp.roomEntryAction(roomId: roomId);
  }

  @override
  Future<void> medialistHistory({
    required int desc,
    required Object oid,
    required Object upperMid,
  }) {
    return VideoHttp.medialistHistory(desc: desc, oid: oid, upperMid: upperMid);
  }

  @override
  Future<LoadingState<CorePlayUrlModel>> tvPlayUrl({
    required int cid,
    required int objectId,
    required int playurlType,
    int? qn,
  }) async {
    return _mapState(
      await VideoHttp.tvPlayUrl(
        cid: cid,
        objectId: objectId,
        playurlType: playurlType,
        qn: qn,
      ),
      _toCorePlayUrl,
    );
  }
}