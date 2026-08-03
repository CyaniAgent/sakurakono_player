import '../base_api.dart';
import '../models/old_api/old_system_models.dart';
import '../models/old_api/old_collection_models.dart';

/// 旧版系统模块接口。
///
/// 提供 API 版本号、幻灯片、开屏动画、法律文档查询。
abstract class IOldSystemApi {
  /// 获取 API 版本号。
  Future<String> getVersion();

  /// 获取幻灯片列表。
  Future<List<Slide>> getSlideshow();

  /// 获取开屏动画配置。
  Future<LaunchScreen> getLaunchScreen();

  /// 获取法律文档链接。
  Future<LegalDocuments> getLegalDocuments();
}

class OldSystemApi extends BaseApi implements IOldSystemApi {
  OldSystemApi(super.dio, super.getToken, {super.config});

  @override
  Future<String> getVersion() async {
    final response = await get('/system/version');
    return (response['data'] as Map<String, dynamic>)['version'] as String;
  }

  @override
  Future<List<Slide>> getSlideshow() async {
    final response = await get('/system/slideshow');
    final list =
        (response['data'] as Map<String, dynamic>)['slides'] as List<dynamic>;
    return list.map((e) => Slide.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<LaunchScreen> getLaunchScreen() async {
    final response = await get('/system/launch_screen');
    return LaunchScreen.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<LegalDocuments> getLegalDocuments() async {
    final response = await get('/system/legal_documents');
    return LegalDocuments.fromJson(response['data'] as Map<String, dynamic>);
  }
}

/// 旧版收藏模块接口。
abstract class IOldCollectionApi {
  /// 设置视频收藏类别。
  Future<void> setVideoCollection({required int vid, required String collection});

  /// 获取视频收藏信息。
  Future<CollectionDetail> getVideoCollection(int vid);

  /// 获取用户的视频收藏类别列表。
  Future<List<String>> getUserVideoCollections(int uid);

  /// 获取视频收藏类别详情。
  Future<CollectionDetail> getVideoCollectionDetail({required int uid, required String collection});

  /// 设置视频在收藏中的排序。
  Future<void> setVideoCollectionSortOrder({required int vid, required int collectionSortOrder});
}

class OldCollectionApi extends BaseApi implements IOldCollectionApi {
  OldCollectionApi(super.dio, super.getToken, {super.config});

  @override
  Future<void> setVideoCollection({
    required int vid,
    required String collection,
  }) async {
    await post('/collection/set_video_collection',
        data: {'vid': vid, 'collection': collection});
  }

  @override
  Future<CollectionDetail> getVideoCollection(int vid) async {
    final response = await get('/collection/get_video_collection',
        queryParameters: {'vid': vid});
    return CollectionDetail.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<String>> getUserVideoCollections(int uid) async {
    final response = await get('/collection/get_user_video_collection',
        queryParameters: {'uid': uid});
    return ((response['data'] as Map<String, dynamic>)['collection_list']
            as List<dynamic>)
        .map((e) => e as String)
        .toList();
  }

  @override
  Future<CollectionDetail> getVideoCollectionDetail({
    required int uid,
    required String collection,
  }) async {
    final response = await get('/collection/video_collection_list',
        queryParameters: {'uid': uid, 'collection': collection});
    return CollectionDetail.fromJson(response['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> setVideoCollectionSortOrder({
    required int vid,
    required int collectionSortOrder,
  }) async {
    await post('/collection/set_video_collection_sort_order',
        data: {'vid': vid, 'collection_sort_order': collectionSortOrder});
  }
}
