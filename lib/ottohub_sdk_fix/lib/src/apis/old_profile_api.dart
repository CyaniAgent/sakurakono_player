import 'dart:io';
import 'package:dio/dio.dart';
import '../base_api.dart';
import '../models/old_api/old_profile_models.dart';
import '../models/old_api/old_creator_models.dart';
import '../models/video/video_summary.dart';

/// 旧版用户资料模块接口。
abstract class IOldProfileApi {
  /// 获取收藏博客列表。
  Future<Map<String, dynamic>> getFavoriteBlogList({int? offset, int? num});

  /// 获取收藏视频列表。
  Future<Map<String, dynamic>> getFavoriteVideoList({int? offset, int? num});

  /// 获取历史观看视频列表。
  Future<List<VideoSummary>> getHistoryVideoList();

  /// 获取用户资料。
  Future<UserProfile> getUserProfile();

  /// 更新昵称。
  Future<void> updateUsername(String username);

  /// 更新密码。
  Future<NewTokenResponse> updatePassword(String pw);

  /// 更新手机号。
  Future<void> updatePhone(String phone);

  /// 更新 QQ 号。
  Future<void> updateQq(String qq);

  /// 更新性别。
  Future<void> updateSex(String sex);

  /// 更新简介。
  Future<void> updateIntro(String intro);

  /// 获取用户数据（统计数据）。
  Future<UserData> getUserData();

  /// 获取管理博客列表。
  Future<Map<String, dynamic>> getManageBlogList({int? offset, int? num});

  /// 获取管理视频列表。
  Future<Map<String, dynamic>> getManageVideoList({int? offset, int? num});

  /// 查询当前用户是否是审核员。
  Future<int?> getIsAudit();
}

class OldProfileApi extends BaseApi implements IOldProfileApi {
  OldProfileApi(super.dio, super.getToken, {super.config});

  @override
  Future<Map<String, dynamic>> getFavoriteBlogList({
    int? offset,
    int? num,
  }) async {
    final response = await get('/profile/favorite_blog_list', auth: true, queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final data = response['data'] as Map<String, dynamic>;
    final list = (data['blog_list'] as List<dynamic>)
        .map((e) => FavoriteBlogItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final count = data['favorite_blog_count'] as int?;
    return {'blog_list': list, 'favorite_blog_count': ?count};
  }

  @override
  Future<Map<String, dynamic>> getFavoriteVideoList({
    int? offset,
    int? num,
  }) async {
    final response = await get('/profile/favorite_video_list', auth: true, queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final data = response['data'] as Map<String, dynamic>;
    final list = (data['video_list'] as List<dynamic>)
        .map((e) => FavoriteVideoItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final count = data['favorite_video_count'] as int?;
    return {'video_list': list, 'favorite_video_count': ?count};
  }

  @override
  Future<List<VideoSummary>> getHistoryVideoList() async {
    final response = await get('/profile/history_video_list', auth: true);
    final list = (response['data'] as Map<String, dynamic>)['video_list']
        as List<dynamic>;
    return list
        .map((e) => VideoSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserProfile> getUserProfile() async {
    final response = await get('/profile/user_profile', auth: true);
    return UserProfile.fromJson(
        (response['data'] as Map<String, dynamic>)['profile']
            as Map<String, dynamic>);
  }

  @override
  Future<void> updateUsername(String username) async {
    await post('/profile/update_username', auth: true, data: {'username': username});
  }

  @override
  Future<NewTokenResponse> updatePassword(String pw) async {
    final response =
        await post('/profile/update_pw', auth: true, data: {'pw': pw});
    return NewTokenResponse.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> updatePhone(String phone) async {
    await post('/profile/update_phone', auth: true, data: {'pw': phone});
  }

  @override
  Future<void> updateQq(String qq) async {
    await post('/profile/update_qq', auth: true, data: {'qq': qq});
  }

  @override
  Future<void> updateSex(String sex) async {
    await post('/profile/update_sex', auth: true, data: {'sex': sex});
  }

  @override
  Future<void> updateIntro(String intro) async {
    await post('/profile/update_intro', auth: true, data: {'intro': intro});
  }

  @override
  Future<UserData> getUserData() async {
    final response = await get('/profile/user_data', auth: true);
    return UserData.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> getManageBlogList({int? offset, int? num}) async {
    final response = await get('/profile/manage_blog_list', auth: true, queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final data = response['data'] as Map<String, dynamic>;
    final list = (data['blog_list'] as List<dynamic>)
        .map((e) => ManageBlogItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final count = data['manage_blog_count'] as int?;
    return {'blog_list': list, 'manage_blog_count': ?count};
  }

  @override
  Future<Map<String, dynamic>> getManageVideoList({int? offset, int? num}) async {
    final response = await get('/profile/manage_video_list', auth: true, queryParameters: {
      'offset': ?offset,
      'num': ?num,
    });
    final data = response['data'] as Map<String, dynamic>;
    final list = (data['video_list'] as List<dynamic>)
        .map((e) => ManageVideoItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final count = data['manage_video_count'] as int?;
    return {'video_list': list, 'manage_video_count': ?count};
  }

  @override
  Future<int?> getIsAudit() async {
    final response = await get('/profile/is_audit', auth: true);
    return (response['data'] as Map<String, dynamic>)['is_audit'] as int?;
  }
}

/// 旧版创作者模块接口。
///
/// 提供博客/视频投稿、头像/封面更新、草稿、图片上传等功能。
abstract class IOldCreatorApi {
  /// 发布博客。
  Future<SubmitResult> submitBlog({required String title, required String content, int? channelId, int? channelSectionId});

  /// 发布视频（文件上传）。
  Future<SubmitResult> submitVideo({required String title, required String intro, required int type, required int category, required String tag, required File fileMp4, required File fileJpg, int? channelId, int? channelSectionId});

  /// 更新头像。
  Future<void> updateAvatar(File fileJpg);

  /// 更新封面。
  Future<void> updateCover(File fileJpg);

  /// 保存博客草稿。
  Future<void> saveBlogDraft(String content);

  /// 读取博客草稿。
  Future<BlogDraft> loadBlogDraft();

  /// 上传图片。
  Future<ImageUploadResult> submitImage(File fileImg);

  /// 更新视频。
  Future<void> updateVideo({required int vid, String? title, String? intro, String? tag, int? category, File? fileJpg, File? fileMp4});
}

class OldCreatorApi extends BaseApi implements IOldCreatorApi {
  OldCreatorApi(super.dio, super.getToken, {super.config});

  @override
  Future<SubmitResult> submitBlog({
    required String title,
    required String content,
    int? channelId,
    int? channelSectionId,
  }) async {
    final response = await post('/creator/submit_blog', auth: true, data: {
      'title': title,
      'content': content,
      'channel_id': ?channelId,
      'channel_section_id': ?channelSectionId,
    });
    return SubmitResult.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<SubmitResult> submitVideo({
    required String title,
    required String intro,
    required int type,
    required int category,
    required String tag,
    required File fileMp4,
    required File fileJpg,
    int? channelId,
    int? channelSectionId,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'intro': intro,
      'type': type,
      'category': category,
      'tag': tag,
      'file_mp4': await MultipartFile.fromFile(fileMp4.path),
      'file_jpg': await MultipartFile.fromFile(fileJpg.path),
      'channel_id': ?channelId,
      'channel_section_id': ?channelSectionId,
    });
    final response = await post('/creator/submit_video', auth: true, formData: formData);
    return SubmitResult.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateAvatar(File fileJpg) async {
    final formData = FormData.fromMap({
      'file_jpg': await MultipartFile.fromFile(fileJpg.path),
    });
    await post('/creator/update_avatar', auth: true, formData: formData);
  }

  @override
  Future<void> updateCover(File fileJpg) async {
    final formData = FormData.fromMap({
      'file_jpg': await MultipartFile.fromFile(fileJpg.path),
    });
    await post('/creator/update_cover', auth: true, formData: formData);
  }

  @override
  Future<void> saveBlogDraft(String content) async {
    await post('/creator/save_blog', auth: true, data: {'content': content});
  }

  @override
  Future<BlogDraft> loadBlogDraft() async {
    final response = await get('/creator/load_blog', auth: true);
    return BlogDraft.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<ImageUploadResult> submitImage(File fileImg) async {
    final formData = FormData.fromMap({
      'file_img': await MultipartFile.fromFile(fileImg.path),
    });
    final response = await post('/creator/submit_image', auth: true, formData: formData);
    return ImageUploadResult.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> updateVideo({
    required int vid,
    String? title,
    String? intro,
    String? tag,
    int? category,
    File? fileJpg,
    File? fileMp4,
  }) async {
    final data = <String, dynamic>{'vid': vid};
    if (title != null) data['title'] = title;
    if (intro != null) data['intro'] = intro;
    if (tag != null) data['tag'] = tag;
    if (category != null) data['category'] = category;
    if (fileJpg != null) {
      data['file_jpg'] = await MultipartFile.fromFile(fileJpg.path);
    }
    if (fileMp4 != null) {
      data['file_mp4'] = await MultipartFile.fromFile(fileMp4.path);
    }
    final hasFile = fileJpg != null || fileMp4 != null;
    if (hasFile) {
      await post('/creator/update_video', auth: true, formData: FormData.fromMap(data));
    } else {
      await post('/creator/update_video', auth: true, data: data);
    }
  }
}
