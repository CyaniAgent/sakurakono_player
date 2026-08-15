import 'package:dio/dio.dart';
import '../base_api.dart';
import '../models/video/favorite_toggle_response.dart';
import '../models/video/like_toggle_response.dart';
import '../models/video/submit_response.dart';
import '../models/video/video_detail.dart';
import '../models/video/video_list_data.dart';

/// 视频模块接口。
///
/// 提供视频列表获取（随机/最新/热门/分类）、搜索、详情、用户视频、
/// 相关视频、收藏列表、管理列表、历史记录、收藏/点赞切换、上传/更新/删除。
abstract class IVideoApi {
  /// 获取随机视频列表。
  Future<VideoListData> getRandom({int? num});

  /// 获取最新视频列表。
  Future<VideoListData> getNew({int? offset, int? num, String? type});

  /// 获取热门视频列表。
  ///
  /// [timeLimit]: 时间范围（天），如 7（一周热门）。
  Future<VideoListData> getPopular({int? timeLimit, int? offset, int? num});

  /// 获取指定分类的视频列表。
  ///
  /// [category]: 分类值，如 `"0"`（动画）、`"1"`、`"2"`。
  Future<VideoListData> getCategory(String category, {int? num});

  /// 搜索视频。
  ///
  /// 支持按各种字段排序和筛选。
  Future<VideoListData> search({
    String? searchTerm,
    int? offset,
    int? num,
    int? vidDesc,
    int? viewCountDesc,
    int? likeCountDesc,
    int? favoriteCountDesc,
    int? uid,
    String? type,
  });

  /// 获取视频详情。
  ///
  /// 注意：若不提供 token，部分字段（如 `lastWatchSecond`）不会返回。
  Future<VideoDetail> getDetail(int vid);

  /// 获取指定用户的视频列表。
  Future<VideoListData> getUserVideos(int uid, {int? offset, int? num});

  /// 获取相关视频列表。
  Future<VideoListData> getRelated(int vid, {int? num, int? offset});

  /// 获取用户的收藏视频列表。
  Future<VideoListData> getFavoriteList({int? offset, int? num});

  /// 获取用户的管理视频列表（需审核权限）。
  Future<VideoListData> getManageList({int? offset, int? num});

  /// 获取观看历史视频列表。
  Future<VideoListData> getHistoryList();

  /// 保存观看历史进度。
  ///
  /// [lastWatchSecond]: 最后观看到的秒数。-1 表示已看完。
  Future<void> saveWatchHistory(int vid, int lastWatchSecond);

  /// 切换收藏状态。
  Future<FavoriteToggleResponse> toggleFavorite(int vid);

  /// 切换点赞状态。
  Future<LikeToggleResponse> toggleLike(int vid);

  /// 上传视频。
  ///
  /// 使用 [MultipartFile] 上传视频文件和封面图。
  /// [type]: 版权类型。 [category]: 分区。
  Future<SubmitResponse> submitVideo({
    required String title,
    required String intro,
    required int type,
    required int category,
    required String tag,
    required MultipartFile fileMp4,
    required MultipartFile fileJpg,
    int? channelId,
    int? channelSectionId,
  });

  /// 更新视频信息。
  ///
  /// 可更新标题、简介、标签、分类、封面、视频文件。
  /// 仅视频作者可操作。
  Future<void> updateVideo(int vid, {String? title, String? intro, String? tag, int? category, MultipartFile? fileJpg, MultipartFile? fileMp4});

  /// 删除视频。
  Future<void> deleteVideo(int vid);
}

class VideoApi extends BaseApi implements IVideoApi {
  VideoApi(super.dio, super.getToken, {super.config});

  @override
  Future<VideoListData> getRandom({int? num}) async {
    final params = <String, dynamic>{};
    if (num != null) params['num'] = num;
    final response = await get('/video/random', queryParameters: params);
    return VideoListData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<VideoListData> getNew({
    int? offset,
    int? num,
    String? type,
  }) async {
    final params = <String, dynamic>{};
    if (offset != null) params['offset'] = offset;
    if (num != null) params['num'] = num;
    if (type != null) params['type'] = type;
    final response = await get('/video/new', queryParameters: params);
    return VideoListData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<VideoListData> getPopular({
    int? timeLimit,
    int? offset,
    int? num,
  }) async {
    final params = <String, dynamic>{};
    if (timeLimit != null) params['time_limit'] = timeLimit;
    if (offset != null) params['offset'] = offset;
    if (num != null) params['num'] = num;
    final response = await get('/video/popular', queryParameters: params);
    return VideoListData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<VideoListData> getCategory(String category, {int? num}) async {
    final params = <String, dynamic>{};
    if (num != null) params['num'] = num;
    final response =
        await get('/video/category/$category', queryParameters: params);
    return VideoListData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<VideoListData> search({
    String? searchTerm,
    int? offset,
    int? num,
    int? vidDesc,
    int? viewCountDesc,
    int? likeCountDesc,
    int? favoriteCountDesc,
    int? uid,
    String? type,
  }) async {
    final params = <String, dynamic>{};
    if (searchTerm != null) params['search_term'] = searchTerm;
    if (offset != null) params['offset'] = offset;
    if (num != null) params['num'] = num;
    if (vidDesc != null && vidDesc != 0) params['vid_desc'] = vidDesc;
    if (viewCountDesc != null && viewCountDesc != 0) {
      params['view_count_desc'] = viewCountDesc;
    }
    if (likeCountDesc != null && likeCountDesc != 0) {
      params['like_count_desc'] = likeCountDesc;
    }
    if (favoriteCountDesc != null && favoriteCountDesc != 0) {
      params['favorite_count_desc'] = favoriteCountDesc;
    }
    if (uid != null) params['uid'] = uid;
    if (type != null) params['type'] = type;
    final response = await get('/video/search', queryParameters: params);
    return VideoListData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<VideoDetail> getDetail(int vid) async {
    final response = await get('/video/$vid', auth: true);
    return VideoDetail.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<VideoListData> getUserVideos(
    int uid, {
    int? offset,
    int? num,
  }) async {
    final params = <String, dynamic>{};
    if (offset != null) params['offset'] = offset;
    if (num != null) params['num'] = num;
    final response =
        await get('/video/user/$uid', queryParameters: params);
    return VideoListData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<VideoListData> getRelated(
    int vid, {
    int? num,
    int? offset,
  }) async {
    final params = <String, dynamic>{};
    if (num != null) params['num'] = num;
    if (offset != null) params['offset'] = offset;
    final response =
        await get('/video/related/$vid', queryParameters: params);
    return VideoListData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<VideoListData> getFavoriteList({
    int? offset,
    int? num,
  }) async {
    final params = <String, dynamic>{};
    if (offset != null) params['offset'] = offset;
    if (num != null) params['num'] = num;
    final response =
        await get('/video/favorite-list', auth: true, queryParameters: params);
    return VideoListData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<VideoListData> getManageList({
    int? offset,
    int? num,
  }) async {
    final params = <String, dynamic>{};
    if (offset != null) params['offset'] = offset;
    if (num != null) params['num'] = num;
    final response =
        await get('/video/manage-list', auth: true, queryParameters: params);
    return VideoListData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<VideoListData> getHistoryList() async {
    final response = await get('/video/history-list', auth: true);
    return VideoListData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> saveWatchHistory(int vid, int lastWatchSecond) async {
    await post('/video/watch-history', auth: true, data: {
      'vid': vid,
      'last_watch_second': lastWatchSecond,
    });
  }

  @override
  Future<FavoriteToggleResponse> toggleFavorite(int vid) async {
    final response = await post('/video/favorite/$vid', auth: true);
    return FavoriteToggleResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<LikeToggleResponse> toggleLike(int vid) async {
    final response = await post('/video/like/$vid', auth: true);
    return LikeToggleResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<SubmitResponse> submitVideo({
    required String title,
    required String intro,
    required int type,
    required int category,
    required String tag,
    required MultipartFile fileMp4,
    required MultipartFile fileJpg,
    int? channelId,
    int? channelSectionId,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'intro': intro,
      'type': type,
      'category': category,
      'tag': tag,
      'file_mp4': fileMp4,
      'file_jpg': fileJpg,
      'channel_id': ?channelId,
      'channel_section_id': ?channelSectionId,
    });
    final response = await post('/video/submit', auth: true, formData: formData);
    return SubmitResponse.fromJson(
        response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateVideo(
    int vid, {
    String? title,
    String? intro,
    String? tag,
    int? category,
    MultipartFile? fileJpg,
    MultipartFile? fileMp4,
  }) async {
    final formData = FormData.fromMap({
      'title': ?title,
      'intro': ?intro,
      'tag': ?tag,
      'category': ?category,
      'file_jpg': ?fileJpg,
      'file_mp4': ?fileMp4,
    });
    await post('/video/update/$vid', auth: true, formData: formData);
  }

  @override
  Future<void> deleteVideo(int vid) async {
    final params = <String, dynamic>{};
    await delete('/video/$vid', auth: true, queryParameters: params);
  }
}
