import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/user_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Core interface for user-related data operations.
///
/// Defines the contract for fetching and mutating user profiles, history,
/// watch-later list, subscriptions, relationships, and other user-scoped
/// resources. Implementations are provided by the active adapter (e.g. BiliBridge).
abstract class UserRepository {
  // ── Profile & stats ──────────────────────────────────────────────

  Future<LoadingState<CoreUserInfoData>> userInfo();

  Future<LoadingState<CoreUserStat>> userStatOwner();

  // ── Watch later ──────────────────────────────────────────────────

  Future<LoadingState<CoreLaterData>> seeYouLater({
    required int page,
    int viewed = 0,
    String keyword = '',
    bool asc = false,
  });

  Future<LoadingState<void>> toViewLater({
    String? bvid,
    Object? aid,
  });

  Future<LoadingState<void>> toViewDel({required String aids});

  Future<LoadingState<void>> toViewClear([int? cleanType]);

  // ── History ──────────────────────────────────────────────────────

  Future<LoadingState<CoreHistoryData>> historyList({
    required String type,
    int? max,
    int? viewAt,
    Object? account,
  });

  Future<LoadingState<void>> pauseHistory(bool switchStatus, {Object? account});

  Future<LoadingState<bool>> historyStatus({Object? account});

  Future<LoadingState<void>> clearHistory({Object? account});

  Future<LoadingState<void>> delHistory(String kid, {Object? account});

  Future<LoadingState<CoreHistoryData>> searchHistory({
    required int pn,
    required String keyword,
    Object? account,
  });

  // ── Relationships ────────────────────────────────────────────────

  Future<LoadingState<CoreRelationData>> userRelation(int mid);

  // ── Subscriptions ────────────────────────────────────────────────

  Future<LoadingState<CoreSubData>> userSubFolder({
    required int mid,
    required int pn,
    required int ps,
  });

  // ── Video tags ───────────────────────────────────────────────────

  Future<LoadingState<List<CoreVideoTagItem>?>> videoTags({
    required String bvid,
    Object? cid,
  });

  // ── Media list ───────────────────────────────────────────────────

  Future<LoadingState<CoreMediaListData>> getMediaList({
    required Object type,
    required Object bizId,
    required int ps,
    dynamic oid,
    int? otype,
    bool withCurrent = false,
    bool desc = true,
    dynamic sortField = 1,
    bool direction = false,
  });

  // ── Coins ────────────────────────────────────────────────────────

  Future<LoadingState<num?>> getCoin();

  Future<LoadingState<CoreCoinLogData>> coinLog();

  // ── Reporting ────────────────────────────────────────────────────

  Future<LoadingState<void>> dynamicReport({
    required Object mid,
    required Object dynId,
    required int reasonType,
    String? reasonDesc,
  });

  // ── Space / profile settings ─────────────────────────────────────

  Future<LoadingState<CoreSpaceSettingData>> spaceSetting();

  Future<LoadingState<void>> spaceSettingMod(Map<String, dynamic> data);

  Future<LoadingState<void>> spaceReserve({
    required Object sid,
    required bool isFollow,
  });

  // ── VIP ──────────────────────────────────────────────────────────

  Future<LoadingState<void>> vipExpAdd();

  // ── Logs ─────────────────────────────────────────────────────────

  Future<LoadingState<CoreLoginLogData>> loginLog();

  Future<LoadingState<CoreCoinLogData>> expLog();

  // ── User identity ────────────────────────────────────────────────

  Future<LoadingState<CoreUserRealNameData>> getUserRealName(Object mid);

  // ── Following ────────────────────────────────────────────────────

  Future<LoadingState<CoreFollowData>> followedUp({
    required Object mid,
    required int pn,
  });

  Future<LoadingState<CoreFollowData>> sameFollowing({
    required Object mid,
    int? pn,
  });
}
