import 'package:skf/adapters/bilibili/http/user.dart';
import 'package:skf/adapters/bilibili/utils/accounts/account.dart';

import 'package:skf/adapters/bilibili/models/user/info.dart'
    show UserInfoData;
import 'package:skf/adapters/bilibili/models/user/stat.dart' show UserStat;
import 'package:skf/adapters/bilibili/models_new/coin_log/data.dart'
    show CoinLogData;
import 'package:skf/adapters/bilibili/models_new/coin_log/list.dart'
    show CoinLogItem;
import 'package:skf/adapters/bilibili/models_new/follow/data.dart'
    show FollowData;
import 'package:skf/adapters/bilibili/models_new/follow/list.dart'
    show FollowItemModel;
import 'package:skf/adapters/bilibili/models_new/history/data.dart'
    show HistoryData;
import 'package:skf/adapters/bilibili/models_new/history/list.dart'
    show HistoryItemModel;
import 'package:skf/adapters/bilibili/models_new/later/data.dart'
    show LaterData;
import 'package:skf/adapters/bilibili/models_new/later/list.dart'
    show LaterItemModel;
import 'package:skf/adapters/bilibili/models_new/login_log/data.dart'
    show LoginLogData;
import 'package:skf/adapters/bilibili/models_new/media_list/data.dart'
    show MediaListData;
import 'package:skf/adapters/bilibili/models_new/media_list/media_list.dart'
    show MediaListItemModel;
import 'package:skf/adapters/bilibili/models_new/relation/data.dart'
    show RelationData;
import 'package:skf/adapters/bilibili/models_new/space_setting/data.dart'
    show SpaceSettingData;
import 'package:skf/adapters/bilibili/models_new/sub/sub/data.dart'
    show SubData;
import 'package:skf/adapters/bilibili/models_new/sub/sub/list.dart'
    show SubItemModel;
import 'package:skf/adapters/bilibili/models_new/user_real_name/data.dart'
    show UserRealNameData;
import 'package:skf/adapters/bilibili/models_new/video/video_tag/data.dart'
    show VideoTagItem;
import 'package:skf/core/models/follow_data.dart' show CoreFollowData;
import 'package:skf/core/models/user_types.dart';
import 'package:skf/core/models/follow_item.dart' show CoreFollowItemModel;
import 'package:skf/core/repository/user_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Bilibili implementation of [UserRepository].
///
/// Delegates every method to [UserHttp] (the B站 HTTP API layer) and
/// converts the adapter-specific [LoadingState] into the core
/// [LoadingState] type consumed by the interface.
class BiliUserRepository implements UserRepository {
  // ── Profile & stats ──────────────────────────────────────────────

  @override
  Future<LoadingState<CoreUserInfoData>> userInfo() async =>
      _toCore(await UserHttp.userInfo(), _convertUserInfoData);

  @override
  Future<LoadingState<CoreUserStat>> userStatOwner() async =>
      _toCore(await UserHttp.userStatOwner(), _convertUserStat);

  // ── Watch later ──────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreLaterData>> seeYouLater({
    required int page,
    int viewed = 0,
    String keyword = '',
    bool asc = false,
  }) async =>
      _toCore(
        await UserHttp.seeYouLater(
          page: page,
          viewed: viewed,
          keyword: keyword,
          asc: asc,
        ),
        _convertLaterData,
      );

  @override
  Future<LoadingState<void>> toViewLater({
    String? bvid,
    Object? aid,
  }) =>
      UserHttp.toViewLater(bvid: bvid, aid: aid);

  @override
  Future<LoadingState<void>> toViewDel({required String aids}) =>
      UserHttp.toViewDel(aids: aids);

  @override
  Future<LoadingState<void>> toViewClear([int? cleanType]) =>
      UserHttp.toViewClear(cleanType);

  // ── History ──────────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreHistoryData>> historyList({
    required String type,
    int? max,
    int? viewAt,
    Object? account,
  }) async =>
      _toCore(
        await UserHttp.historyList(
          type: type,
          max: max,
          viewAt: viewAt,
          account: account as Account?,
        ),
        _convertHistoryData,
      );

  @override
  Future<LoadingState<void>> pauseHistory(bool switchStatus,
          {Object? account}) =>
      UserHttp.pauseHistory(switchStatus,
          account: account as Account?);

  @override
  Future<LoadingState<bool>> historyStatus({Object? account}) =>
      UserHttp.historyStatus(account: account as Account?);

  @override
  Future<LoadingState<void>> clearHistory({Object? account}) =>
      UserHttp.clearHistory(account: account as Account?);

  @override
  Future<LoadingState<void>> delHistory(String kid,
          {Object? account}) =>
      UserHttp.delHistory(kid, account: account as Account?);

  @override
  Future<LoadingState<CoreHistoryData>> searchHistory({
    required int pn,
    required String keyword,
    Object? account,
  }) async =>
      _toCore(
        await UserHttp.searchHistory(
          pn: pn,
          keyword: keyword,
          account: account as Account?,
        ),
        _convertHistoryData,
      );

  // ── Relationships ────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreRelationData>> userRelation(int mid) async =>
      _toCore(await UserHttp.userRelation(mid), _convertRelationData);

  // ── Subscriptions ────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreSubData>> userSubFolder({
    required int mid,
    required int pn,
    required int ps,
  }) async =>
      _toCore(
        await UserHttp.userSubFolder(mid: mid, pn: pn, ps: ps),
        _convertSubData,
      );

  // ── Video tags ───────────────────────────────────────────────────

  @override
  Future<LoadingState<List<CoreVideoTagItem>?>> videoTags({
    required String bvid,
    Object? cid,
  }) async =>
      _toCore(
        await UserHttp.videoTags(bvid: bvid, cid: cid),
        (List<VideoTagItem>? items) =>
            items?.map(_convertVideoTagItem).toList(),
      );

  // ── Media list ───────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreMediaListData>> getMediaList({
    required int type,
    required String bizId,
    required int ps,
    dynamic oid,
    int? otype,
    bool withCurrent = false,
    bool desc = true,
    dynamic sortField = 1,
    bool direction = false,
  }) async =>
      _toCore(
        await UserHttp.getMediaList(
          type: type,
          bizId: bizId,
          ps: ps,
          oid: oid,
          otype: otype,
          withCurrent: withCurrent,
          desc: desc,
          sortField: sortField,
          direction: direction,
        ),
        _convertMediaListData,
      );

  // ── Coins ────────────────────────────────────────────────────────

  @override
  Future<LoadingState<num?>> getCoin() =>
      UserHttp.getCoin();

  @override
  Future<LoadingState<CoreCoinLogData>> coinLog() async =>
      _toCore(await UserHttp.coinLog(), _convertCoinLogData);

  // ── Reporting ────────────────────────────────────────────────────

  @override
  Future<LoadingState<void>> dynamicReport({
    required int mid,
    required String dynId,
    required int reasonType,
    String? reasonDesc,
  }) =>
      UserHttp.dynamicReport(
        mid: mid,
        dynId: dynId,
        reasonType: reasonType,
        reasonDesc: reasonDesc,
      );

  // ── Space / profile settings ─────────────────────────────────────

  @override
  Future<LoadingState<CoreSpaceSettingData>> spaceSetting() async =>
      _toCore(await UserHttp.spaceSetting(), _convertSpaceSettingData);

  @override
  Future<LoadingState<void>> spaceSettingMod(
    Map<String, dynamic> data,
  ) =>
      UserHttp.spaceSettingMod(data);

  @override
  Future<LoadingState<void>> spaceReserve({
    required String sid,
    required bool isFollow,
  }) =>
      UserHttp.spaceReserve(sid: sid, isFollow: isFollow);

  // ── VIP ──────────────────────────────────────────────────────────

  @override
  Future<LoadingState<void>> vipExpAdd() =>
      UserHttp.vipExpAdd();

  // ── Logs ─────────────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreLoginLogData>> loginLog() async =>
      _toCore(await UserHttp.loginLog(), _convertLoginLogData);

  @override
  Future<LoadingState<CoreCoinLogData>> expLog() async =>
      _toCore(await UserHttp.expLog(), _convertCoinLogData);

  // ── User identity ────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreUserRealNameData>> getUserRealName(
    Object mid,
  ) async =>
      _toCore(
        await UserHttp.getUserRealName(mid),
        _convertUserRealNameData,
      );

  // ── Following ────────────────────────────────────────────────────

  @override
  Future<LoadingState<CoreFollowData>> followedUp({
    required int mid,
    required int pn,
  }) async =>
      _toCore(
        await UserHttp.followedUp(mid: mid, pn: pn),
        _convertFollowData,
      );

  @override
  Future<LoadingState<CoreFollowData>> sameFollowing({
    required int mid,
    int? pn,
  }) async =>
      _toCore(
        await UserHttp.sameFollowing(mid: mid, pn: pn),
        _convertFollowData,
      );
}

// ── Generic LoadingState converter ────────────────────────────────

/// Converts an adapter [LoadingState] to the core [LoadingState].
LoadingState<T> _toCore<T, A>(LoadingState<A> state, T Function(A) convert) {
  return switch (state) {
    Success<A>(:final response) => Success<T>(convert(response)),
    Error(:final errMsg, :final code) => Error(errMsg, code: code),
    Loading() => LoadingState<T>.loading(),
  };
}

// ── Model conversion helpers ──────────────────────────────────────

CoreUserInfoData _convertUserInfoData(UserInfoData data) {
  return CoreUserInfoData(
    isLogin: data.isLogin,
    face: data.face,
    levelInfo: data.levelInfo != null
        ? CoreLevelInfo(
            currentLevel: data.levelInfo!.currentLevel,
            currentMin: data.levelInfo!.currentMin,
            currentExp: data.levelInfo!.currentExp,
            nextExp: data.levelInfo!.nextExp,
          )
        : null,
    mid: data.mid,
    money: data.money,
    scores: data.scores,
    uname: data.uname,
    vipDueDate: data.vipDueDate,
    vipStatus: data.vipStatus,
    vipType: data.vipType,
    isSeniorMember: data.isSeniorMember,
  );
}

CoreUserStat _convertUserStat(UserStat stat) {
  return CoreUserStat(
    following: stat.following,
    follower: stat.follower,
    dynamicCount: stat.dynamicCount,
  );
}

CoreLaterData _convertLaterData(LaterData data) {
  return CoreLaterData(
    count: data.count,
    list: data.list?.map(_convertLaterItemModel).toList(),
  );
}

CoreLaterItemModel _convertLaterItemModel(LaterItemModel item) {
  return CoreLaterItemModel(
    aid: item.aid,
    pic: item.pic,
    title: item.title,
    subtitle: item.subtitle,
    pubdate: item.pubdate,
    duration: item.duration,
    redirectUrl: item.redirectUrl,
    rights: item.rights != null
        ? CoreRights(isCooperation: item.rights!.isCooperation)
        : null,
    owner: item.owner != null
        ? CoreOwner.fromJson(item.owner!.toJson())
        : null,
    stat: item.stat != null
        ? CoreStat(view: item.stat!.view, danmaku: item.stat!.danmaku)
        : null,
    bangumi: item.bangumi != null
        ? CoreBangumi(
            epId: item.bangumi!.epId,
            season: item.bangumi!.season != null
                ? CoreSeason(title: item.bangumi!.season!.title)
                : null,
          )
        : null,
    cid: item.cid,
    progress: item.progress,
    bvid: item.bvid,
    isPgc: item.isPgc,
    pgcLabel: item.pgcLabel,
    isPugv: item.isPugv,
    isCharging: item.isCharging,
    dimension: item.dimension != null
        ? CoreDimension(
            width: item.dimension!.width,
            height: item.dimension!.height,
          )
        : null,
  );
}

CoreHistoryData _convertHistoryData(HistoryData data) {
  return CoreHistoryData(
    tab: data.tab
        ?.map((t) => CoreHistoryTab(type: t.type, name: t.name))
        .toList(),
    list: data.list?.map(_convertHistoryItemModel).toList(),
  );
}

CoreHistoryItemModel _convertHistoryItemModel(HistoryItemModel item) {
  return CoreHistoryItemModel(
    title: item.title,
    cover: item.cover,
    covers: item.covers,
    uri: item.uri,
    history: CoreHistory(
      oid: item.history.oid,
      epid: item.history.epid,
      bvid: item.history.bvid,
      page: item.history.page,
      cid: item.history.cid,
      business: item.history.business,
    ),
    videos: item.videos,
    authorName: item.authorName,
    authorMid: item.authorMid,
    viewAt: item.viewAt,
    progress: item.progress,
    badge: item.badge,
    showTitle: item.showTitle,
    duration: item.duration,
    isFav: item.isFav,
    kid: item.kid,
    tagName: item.tagName,
    liveStatus: item.liveStatus,
  );
}

CoreRelationData _convertRelationData(RelationData data) {
  return CoreRelationData(
    attribute: data.attribute,
    mtime: data.mtime,
    tag: data.tag,
    special: data.special,
  );
}

CoreSubData _convertSubData(SubData data) {
  return CoreSubData(
    list: data.list?.map(_convertSubItemModel).toList(),
    hasMore: data.hasMore,
  );
}

CoreSubItemModel _convertSubItemModel(SubItemModel item) {
  return CoreSubItemModel(
    id: item.id,
    fid: item.fid,
    mid: item.mid,
    attr: item.attr,
    title: item.title,
    cover: item.cover,
    upper: item.upper != null
        ? CoreOwner.fromJson(item.upper!.toJson())
        : null,
    coverType: item.coverType,
    intro: item.intro,
    ctime: item.ctime,
    mtime: item.mtime,
    state: item.state,
    favState: item.favState,
    mediaCount: item.mediaCount,
    viewCount: item.viewCount,
    type: item.type,
    cntInfo: item.cntInfo != null
        ? CoreCntInfo(
            play: item.cntInfo!.play,
            danmaku: item.cntInfo!.danmaku,
          )
        : null,
  );
}

CoreVideoTagItem _convertVideoTagItem(VideoTagItem item) {
  return CoreVideoTagItem(
    tagId: item.tagId,
    tagName: item.tagName,
    tagType: item.tagType,
    musicId: item.musicId,
  );
}

CoreMediaListData _convertMediaListData(MediaListData data) {
  return CoreMediaListData(
    mediaList: data.mediaList.map(_convertMediaListItemModel).toList(),
  );
}

CoreMediaListItemModel _convertMediaListItemModel(MediaListItemModel item) {
  return CoreMediaListItemModel(
    aid: item.aid,
    intro: item.intro,
    cntInfo: item.cntInfo != null
        ? CoreCntInfo(
            play: item.cntInfo!.play,
            danmaku: item.cntInfo!.danmaku,
          )
        : null,
    duration: item.duration,
    type: item.type,
    upper: item.upper != null
        ? CoreOwner.fromJson(item.upper!.toJson())
        : null,
    cover: item.cover,
    title: item.title,
    bvid: item.bvid,
    badge: item.badge,
  );
}

CoreCoinLogData _convertCoinLogData(CoinLogData data) {
  return CoreCoinLogData(
    list: data.list?.map(_convertCoinLogItem).toList(),
  );
}

CoreCoinLogItem _convertCoinLogItem(CoinLogItem item) {
  return CoreCoinLogItem(
    time: item.time,
    delta: item.delta,
    reason: item.reason,
  );
}

CoreSpaceSettingData _convertSpaceSettingData(SpaceSettingData data) {
  return CoreSpaceSettingData(
    privacy: data.privacy != null
        ? CorePrivacy(
            list1: data.privacy!.list1
                .map((m) => CoreSpaceSettingModel(
                      name: m.name,
                      key: m.key,
                      value: m.value,
                      isReverse: m.isReverse,
                    ))
                .toList(),
            list2: data.privacy!.list2
                .map((m) => CoreSpaceSettingModel(
                      name: m.name,
                      key: m.key,
                      value: m.value,
                      isReverse: m.isReverse,
                    ))
                .toList(),
            list3: data.privacy!.list3
                .map((m) => CoreSpaceSettingModel(
                      name: m.name,
                      key: m.key,
                      value: m.value,
                      isReverse: m.isReverse,
                    ))
                .toList(),
          )
        : null,
  );
}

CoreLoginLogData _convertLoginLogData(LoginLogData data) {
  return CoreLoginLogData(
    list: data.list
        ?.map((item) => CoreLoginLogItem(
              ip: item.ip,
              timeAt: item.timeAt,
              geo: item.geo,
            ))
        .toList(),
  );
}

CoreUserRealNameData _convertUserRealNameData(UserRealNameData data) {
  return CoreUserRealNameData(
    name: data.name,
    rejectPage: data.rejectPage != null
        ? CoreRejectPage(
            title: data.rejectPage!.title,
            text: data.rejectPage!.text,
          )
        : null,
  );
}

CoreFollowData _convertFollowData(FollowData data) {
  return CoreFollowData(
    list: data.list?.map(_convertFollowItemModel).toList(),
    total: data.total,
  );
}

CoreFollowItemModel _convertFollowItemModel(FollowItemModel item) {
  return CoreFollowItemModel(
    mid: item.mid,
    attribute: item.attribute,
    uname: item.uname,
    face: item.face,
    sign: item.sign,
  );
}
