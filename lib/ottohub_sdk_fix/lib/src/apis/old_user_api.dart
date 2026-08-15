import '../base_api.dart';
import '../models/old_api/old_user_models.dart';
import '../models/old_api/old_engagement_models.dart';

/// 旧版用户模块接口。
abstract class IOldUserApi {
  /// 搜索用户。
  Future<List<UserSummary>> searchUsers({required String searchTerm, int? num});

  /// 根据 UID 获取用户信息。
  Future<List<UserSummary>> getUserById(int uid);

  /// 获取用户详情。
  Future<UserDetail> getUserDetail(int uid);
}

class OldUserApi extends BaseApi implements IOldUserApi {
  OldUserApi(super.dio, super.getToken, {super.config});

  @override
  Future<List<UserSummary>> searchUsers({
    required String searchTerm,
    int? num,
  }) async {
    final response = await get('/user/select_user_list', queryParameters: {
      'search_term': searchTerm,
      'num': ?num,
    });
    final list =
        (response['data'] as Map<String, dynamic>)['user_list'] as List<dynamic>;
    return list.map((e) => UserSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<UserSummary>> getUserById(int uid) async {
    final response = await get('/user/id_user_list',
        queryParameters: {'uid': uid});
    final list =
        (response['data'] as Map<String, dynamic>)['user_list'] as List<dynamic>;
    return list.map((e) => UserSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<UserDetail> getUserDetail(int uid) async {
    final response = await get('/user/get_user_detail',
        queryParameters: {'uid': uid});
    return UserDetail.fromJson(response['data'] as Map<String, dynamic>);
  }
}

/// 旧版互动模块接口。
///
/// 提供博客/视频的点赞、收藏切换功能。
abstract class IOldEngagementApi {
  /// 点赞/取消点赞博客。
  Future<OldLikeToggleResponse> likeBlog(int bid);

  /// 收藏/取消收藏博客。
  Future<OldFavoriteToggleResponse> favoriteBlog(int bid);

  /// 点赞/取消点赞视频。
  Future<OldLikeToggleResponse> likeVideo(int vid);

  /// 收藏/取消收藏视频。
  Future<OldFavoriteToggleResponse> favoriteVideo(int vid);
}

class OldEngagementApi extends BaseApi implements IOldEngagementApi {
  OldEngagementApi(super.dio, super.getToken, {super.config});

  @override
  Future<OldLikeToggleResponse> likeBlog(int bid) async {
    final response = await post('/engagement/like_blog', auth: true, data: {'bid': bid});
    return OldLikeToggleResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<OldFavoriteToggleResponse> favoriteBlog(int bid) async {
    final response =
        await post('/engagement/favorite_blog', auth: true, data: {'bid': bid});
    return OldFavoriteToggleResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<OldLikeToggleResponse> likeVideo(int vid) async {
    final response = await post('/engagement/like_video', auth: true, data: {'vid': vid});
    return OldLikeToggleResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<OldFavoriteToggleResponse> favoriteVideo(int vid) async {
    final response =
        await post('/engagement/favorite_video', auth: true, data: {'vid': vid});
    return OldFavoriteToggleResponse.fromJson(response['data'] as Map<String, dynamic>);
  }
}
