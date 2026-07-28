import 'package:skf/core/models/follow_data.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/core/models/space_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Abstract interface for member/space data operations.
///
/// All methods return [LoadingState] for async results that may be loading,
/// successful, or failed. [reportMember] returns bare [Future]<[void]> as it
/// performs its own toast handling.
abstract class MemberRepository {
  /// Report a member for violation.
  Future<void> reportMember(
    dynamic mid, {
    String? reason,
    int? reasonV2,
  });

  /// Get space articles for the given member.
  Future<LoadingState<CoreSpaceArticleData>> spaceArticle({
    required int mid,
    required int page,
  });

  /// Get season/series list for the given member.
  Future<LoadingState<CoreSpaceSsData>> seasonSeriesList({
    required int? mid,
    required int pn,
  });

  /// Get space archives (videos) for the given member.
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
  });

  /// Get space audio list for the given member.
  Future<LoadingState<CoreSpaceAudioData>> spaceAudio({
    required int page,
    required mid,
  });

  /// Get space cheese (courses) for the given member.
  Future<LoadingState<CoreSpaceCheeseData>> spaceCheese({
    required int page,
    required mid,
  });

  /// Get space overview data.
  Future<LoadingState<CoreSpaceData>> space({
    int? mid,
    dynamic fromViewAid,
  });

  /// Get member info.
  Future<LoadingState<CoreMemberInfoModel>> memberInfo({
    required int mid,
    String token = '',
  });

  /// Get member statistics.
  Future<LoadingState<Map>> memberStat({int? mid});

  /// Get member card info.
  Future<LoadingState<CoreMemberCardInfoData>> memberCardInfo({int? mid});

  /// Search member archives.
  Future<LoadingState<CoreSearchArchiveData>> searchArchive({
    required Object mid,
    int tid = 0,
    int ps = 30,
    required int pn,
    String? keyword,
    String? specialType,
    CoreArchiveOrderTypeWeb order = CoreArchiveOrderTypeWeb.pubdate,
  });

  /// Get season/series data (web).
  Future<LoadingState<CoreSeasonWebData>> seasonSeriesWeb({
    required CoreWebSsType type,
    required Object mid,
    required Object id,
    int ps = 30,
    required int pn,
    CoreArchiveSortTypeApp sort = CoreArchiveSortTypeApp.desc,
  });

  /// Get member dynamics feed.
  Future<LoadingState<CoreDynamicsDataModel>> memberDynamic({
    String? offset,
    required int mid,
  });

  /// Search within member dynamics.
  Future<LoadingState<CoreDynamicsDataModel>> dynSearch({
    required int pn,
    required dynamic mid,
    required dynamic offset,
    required String keyword,
  });

  /// Get follow-up tags (grouping).
  Future<LoadingState<List<CoreMemberTagItemModel>>> followUpTags();

  /// Add or remove a special follow.
  Future<LoadingState<void>> specialAction({
    int? fid,
    bool isAdd = true,
  });

  /// Add users to a follow tag group.
  Future<LoadingState<void>> addUsers(String fids, String tagids);

  /// Get follow list for a specific group.
  Future<LoadingState<CoreFollowData>> followUpGroup({
    int? mid,
    int? tagid,
    int? pn,
    int ps = 20,
  });

  /// Create a new follow tag.
  Future<LoadingState<int>> createFollowTag(String tagName);

  /// Update a follow tag name.
  Future<LoadingState<void>> updateFollowTag(
    Object tagid,
    Object name,
  );

  /// Delete a follow tag.
  Future<LoadingState<void>> delFollowTag(Object tagid);

  /// Get the pinned/top video for the current user.
  Future<LoadingState<List<CoreMemberTagItemModel>?>> getTopVideo();

  /// Get member view (play count, like count).
  Future<LoadingState<Map>> memberView({required int mid});

  /// Search followed users by name.
  Future<LoadingState<CoreFollowData>> getfollowSearch({
    required int mid,
    required int ps,
    required int pn,
    required String name,
  });

  /// Get space opus (short posts).
  Future<LoadingState<CoreOpusSpaceFlowResp>> spaceOpus({
    required int hostMid,
    required int page,
    String offset = '',
    String type = 'all',
  });

  /// Get upower rank data.
  Future<LoadingState<CoreUpowerRankData>> upowerRank({
    required Object upMid,
    required int page,
    int? privilegeType,
  });

  /// Get coin-related archives.
  Future<LoadingState<CoreCoinLikeArcData>> coinArc({
    required int mid,
    required int page,
  });

  /// Get liked archives.
  Future<LoadingState<CoreCoinLikeArcData>> likeArc({
    required int mid,
    required int page,
  });

  /// Get space shop data.
  Future<LoadingState<CoreSpaceShopData>> spaceShop({
    required int mid,
  });

  /// Get member guard list.
  Future<LoadingState<CoreMemberGuardData>> memberGuard({
    required Object ruid,
    required int page,
  });
}
