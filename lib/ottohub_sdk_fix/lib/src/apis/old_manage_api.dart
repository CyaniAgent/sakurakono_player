import '../base_api.dart';

/// 旧版管理模块接口。
abstract class IOldManageApi {
  /// 删除博客。
  Future<void> deleteBlog(int bid);

  /// 申诉博客。
  Future<void> appealBlog(int bid, {required String reason});

  /// 删除视频。
  Future<void> deleteVideo(int vid);

  /// 申诉视频。
  Future<void> appealVideo(int vid, {required String reason});
}

class OldManageApi extends BaseApi implements IOldManageApi {
  OldManageApi(super.dio, super.getToken, {super.config});

  @override
  Future<void> deleteBlog(int bid) async {
    await post('/manage/delete_blog', auth: true, data: {'bid': bid});
  }

  @override
  Future<void> appealBlog(int bid, {required String reason}) async {
    await post('/manage/appeal_blog', auth: true, data: {'bid': bid, 'reason': reason});
  }

  @override
  Future<void> deleteVideo(int vid) async {
    await post('/manage/delete_video', auth: true, data: {'vid': vid});
  }

  @override
  Future<void> appealVideo(int vid, {required String reason}) async {
    await post('/manage/appeal_video', auth: true, data: {'vid': vid, 'reason': reason});
  }
}
