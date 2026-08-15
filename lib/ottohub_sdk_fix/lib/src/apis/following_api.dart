import '../base_api.dart';
import '../models/following/active_follower.dart';
import '../models/following/follow_status_response.dart';
import '../models/following/follow_toggle_response.dart';
import '../models/following/timeline_list_data.dart';
import '../models/following/user_list_data.dart';

/// 关注模块接口。
///
/// 提供关注/取关、关注列表/粉丝列表查询、动态时间线、活跃粉丝功能。
abstract class IFollowingApi {
  /// 关注或取关用户（切换）。
  ///
  /// [followingUid]: 目标用户 UID。
  /// **抛出**: [ApiException] — `error_token`, `error_following_uid`,
  ///   `too_many_followings`。
  Future<FollowToggleResponse> toggleFollow(int followingUid);

  /// 查询与指定用户的关注状态。
  ///
  /// [followingUid]: 目标用户 UID。
  /// **抛出**: [ApiException] — `error_token`, `error_following_uid`。
  Future<FollowStatusResponse> getStatus(int followingUid);

  /// 获取指定用户的关注列表。
  ///
  /// [uid]: 用户 UID。
  Future<UserListData> getFollowingList(int uid, {int? offset, int? num});

  /// 获取指定用户的粉丝列表。
  ///
  /// [uid]: 用户 UID。
  Future<UserListData> getFansList(int uid, {int? offset, int? num});

  /// 获取所关注用户的动态时间线。
  Future<TimelineListData> getTimeline({int? offset, int? num});

  /// 获取指定用户的动态时间线。
  Future<TimelineListData> getUserTimeline(int uid, {int? offset, int? num});

  /// 获取活跃粉丝列表。
  ///
  /// 按最新活动时间排序的粉丝列表。
  Future<List<ActiveFollower>> getActiveFollowers(int uid, {int? offset, int? num});
}

class FollowingApi extends BaseApi implements IFollowingApi {
  FollowingApi(super.dio, super.getToken, {super.config});

  @override
  Future<FollowToggleResponse> toggleFollow(int followingUid) async {
    final response = await post('/following/follow/$followingUid', auth: true);
    return FollowToggleResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<FollowStatusResponse> getStatus(int followingUid) async {
    final response =
        await get('/following/status/$followingUid', auth: true);
    return FollowStatusResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserListData> getFollowingList(
    int uid, {
    int? offset,
    int? num,
  }) async {
    final params = <String, dynamic>{};
    if (offset != null) params['offset'] = offset;
    if (num != null) params['num'] = num;
    final response =
        await get('/following/list/$uid', queryParameters: params);
    return UserListData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<UserListData> getFansList(
    int uid, {
    int? offset,
    int? num,
  }) async {
    final params = <String, dynamic>{};
    if (offset != null) params['offset'] = offset;
    if (num != null) params['num'] = num;
    final response =
        await get('/following/fans/$uid', queryParameters: params);
    return UserListData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<TimelineListData> getTimeline({
    int? offset,
    int? num,
  }) async {
    final params = <String, dynamic>{};
    if (offset != null) params['offset'] = offset;
    if (num != null) params['num'] = num;
    final response = await get('/following/timeline', auth: true, queryParameters: params);
    return TimelineListData.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<TimelineListData> getUserTimeline(
    int uid, {
    int? offset,
    int? num,
  }) async {
    final params = <String, dynamic>{};
    if (offset != null) params['offset'] = offset;
    if (num != null) params['num'] = num;
    final response =
        await get('/following/timeline/$uid', queryParameters: params);
    return TimelineListData.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<ActiveFollower>> getActiveFollowers(
    int uid, {
    int? offset,
    int? num,
  }) async {
    final params = <String, dynamic>{};
    if (offset != null) params['offset'] = offset;
    if (num != null) params['num'] = num;
    final response =
        await get('/following/active/$uid', queryParameters: params);
    final list = (response['data'] as Map<String, dynamic>)['user_list']
        as List<dynamic>;
    return list
        .map((e) => ActiveFollower.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
