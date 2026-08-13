import 'package:flutter/foundation.dart' show debugPrint;
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:ottohub_sdk_dart/ottohub_sdk_dart.dart';
// ignore: implementation_imports
import 'package:ottohub_sdk_dart/src/models/old_api/old_profile_models.dart'
    show FavoriteBlogItem;

/// Implementation of [FavRepository] that delegates to OttoHub SDK APIs.
///
/// Uses [IOldCollectionApi] for collection details and [IVideoApi] for
/// favorite toggling.
///
/// ## Supported operations
/// | FavRepository method       | OttoHub SDK support                           |
/// |----------------------------|-----------------------------------------------|
/// | favFavFolder               | ✅ `IVideoApi.getDetail(vid)` + conditional `toggleFavorite(vid)` |
/// | unfavFavFolder             | ✅ `IVideoApi.getDetail(vid)` + conditional `toggleFavorite(vid)` |
/// | favVideo                   | ✅ `IVideoApi.toggleFavorite(vid)` per resource|
/// | userfavFolder              | ✅ `IOldCollectionApi.getUserVideoCollections` |
/// | allFavFolders              | ✅ `IOldCollectionApi.getUserVideoCollections` |
/// | userFavFolderDetail        | ✅ `IVideoApi.getFavoriteList({offset, num})` |
/// | addOrEditFolder            | ✅ `IOldCollectionApi.setVideoCollection({vid, collection})` |
/// | favFolderInfo              | ✅ `IOldCollectionApi.getVideoCollection(vid)` |
/// | sortFav                    | ✅ `IOldCollectionApi.setVideoCollectionSortOrder` |
/// | Others                     | ❌ No OttoHub SDK equivalent                   |
class OttoFavRepository implements FavRepository {
  final OttohubClient _client;

  OttoFavRepository(this._client);

  // ---- helpers ----

  LoadingState<T> _ok<T>(T value) => Success(value);

  LoadingState<T> _err<T>(ApiException e) =>
      Error(e.errorCode, code: e.httpStatus);

  // FavoriteBlogItem / BlogSummary share the same bid/title/content/
  // thumbnails shape, so both map into the core fav-note model here.
  CoreFavNoteItemModel _favBlogToNote({
    required int bid,
    required String title,
    String? content,
    List<String>? thumbnails,
  }) =>
      CoreFavNoteItemModel(
        title: title,
        summary: content,
        pic: thumbnails?.isNotEmpty == true ? thumbnails!.first : null,
        cvid: bid,
        noteId: bid,
      );

  // ═════════════════════════════════════════════════════════════════════════
  // Single-video fav toggle  ✅  read-state via getDetail() + conditional toggleFavorite()
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<LoadingState<void>> favFavFolder(Object mediaId) async {
    try {
      final id = int.tryParse(mediaId.toString());
      if (id == null) return _err(const ApiException('invalid_media_id'));
      final detail = await _client.video.getDetail(id);
      if (detail.ifFavorite == 1) return const Success(null);
      await _client.video.toggleFavorite(id);
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoFavRepository.favFavFolder ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<void>> unfavFavFolder(Object mediaId) async {
    try {
      final id = int.tryParse(mediaId.toString());
      if (id == null) return _err(const ApiException('invalid_media_id'));
      final detail = await _client.video.getDetail(id);
      if (detail.ifFavorite == 0) return const Success(null);
      await _client.video.toggleFavorite(id);
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoFavRepository.unfavFavFolder ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Batch fav video toggle  ✅  iterates resources via toggleFavorite()
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<LoadingState<void>> favVideo({
    required String resources,
    String? addIds,
    String? delIds,
  }) async {
    // OttoHub SDK does not expose batch add/remove folder operations.
    // We iterate through each resource vid and call toggleFavorite,
    // which is the SDK's closest equivalent to adding/removing from favorites.
    try {
      final ids = resources
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .where((e) => e != null)
          .cast<int>()
          .toList();
      for (final vid in ids) {
        await _client.video.toggleFavorite(vid);
      }
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoFavRepository.favVideo ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // User's collection folders  ✅  supported via IOldCollectionApi
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<LoadingState<CoreFavFolderData>> userfavFolder({
    required int pn,
    required int ps,
    required int? mid,
  }) async {
    // OttoHub SDK returns collection names (List<String>), while the core
    // model expects numeric folder IDs.  We synthesize IDs from the index.
    try {
      if (mid == null) return _err(const ApiException('missing_mid'));
      final names = await _client.oldCollection.getUserVideoCollections(mid);
      final start = (pn - 1) * ps;
      final page = start < names.length
          ? names.sublist(start, start + ps > names.length ? names.length : start + ps)
          : <String>[];
      final list = page.asMap().entries.map((e) => CoreFavFolderInfo(
        id: start + e.key,
        title: e.value,
        mid: mid,
      )).toList();
      return _ok(CoreFavFolderData(
        count: names.length,
        list: list,
        hasMore: start + ps < names.length,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoFavRepository.userfavFolder ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreFavFolderData>> allFavFolders(Object mid) async {
    try {
      final uid = int.tryParse(mid.toString());
      if (uid == null) return _err(const ApiException('invalid_media_id'));
      final names = await _client.oldCollection.getUserVideoCollections(uid);
      final list = names.asMap().entries.map((e) => CoreFavFolderInfo(
        id: e.key,
        title: e.value,
        mid: uid,
      )).toList();
      return _ok(CoreFavFolderData(
        count: list.length,
        list: list,
        hasMore: false,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoFavRepository.allFavFolders ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Sort videos in a collection  ✅  IOldCollectionApi.setVideoCollectionSortOrder
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<LoadingState<void>> sortFav({
    required String mediaId,
    required String sort,
  }) async {
    try {
      final order = int.tryParse(sort);
      if (order == null) return _err(const ApiException('invalid_sort_value'));
      final id = int.tryParse(mediaId);
      if (id == null) return _err(const ApiException('invalid_media_id'));
      await _client.oldCollection.setVideoCollectionSortOrder(
        vid: id,
        collectionSortOrder: order,
      );
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoFavRepository.sortFav ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  // ═════════════════════════════════════════════════════════════════════════
  // Not yet implemented — OttoHub SDK does not offer equivalents
  // ═════════════════════════════════════════════════════════════════════════

  @override
  Future<LoadingState<CoreFavDetailData>> userFavFolderDetail({
    required int mediaId,
    required int pn,
    required int ps,
    String keyword = '',
    CoreFavOrderType order = CoreFavOrderType.mtime,
    int type = 0,
  }) async {
    // SDK `IVideoApi.getFavoriteList({offset, num})` returns the current
    // user's favorite videos as a flat paginated list — the folder id is
    // not part of the response, so `info` is synthesized from mediaId.
    // keyword/order/type have no SDK counterpart and are ignored.
    try {
      final result = await _client.video.getFavoriteList(
        offset: (pn - 1) * ps,
        num: ps,
      );
      final total = result.totalCount ?? result.videoList.length;
      final medias = result.videoList.map((v) => CoreFavDetailItemModel(
        id: v.vid,
        type: 2,
        title: v.title,
        cover: v.coverUrl,
        intro: v.intro,
        duration: v.duration,
        upper: CoreOwner(mid: v.uid, name: v.username, face: v.avatarUrl),
        cntInfo: CoreCntInfo(play: v.viewCount),
      )).toList();
      return _ok(CoreFavDetailData(
        info: CoreFavFolderInfo(
          id: mediaId,
          title: '',
          mid: 0,
          mediaCount: total,
        ),
        medias: medias,
        hasMore: (pn * ps) < total,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoFavRepository.userFavFolderDetail ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<void>> cancelSub({
    required int id,
    required int type,
  }) async {
    // no SDK API — SDK 缺 cancelSub 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreSubDetailData>> favSeasonList({
    required int id,
    required int pn,
    required int ps,
  }) async {
    // no SDK API — SDK 缺 favSeasonList 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreSpaceCheeseData>> favPugv({
    required int mid,
    required int page,
  }) async {
    // no SDK API — SDK 缺 getPugvFavList 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> addFavPugv(Object seasonId) async {
    // no SDK API — SDK 缺 addPugvFav 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> delFavPugv(Object seasonId) async {
    // no SDK API — SDK 缺 delPugvFav 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreFavTopicData>> favTopic({
    required int page,
  }) async {
    // no SDK API — SDK 缺 getTopicFavList 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> addFavTopic(Object topicId) async {
    // no SDK API — SDK 缺 addTopicFav 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> delFavTopic(Object topicId) async {
    // no SDK API — SDK 缺 delTopicFav 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> likeTopic(
    Object topicId,
    bool isLike,
  ) async {
    // no SDK API — SDK 缺 likeTopic 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreFavArticleData>> favArticle({
    required int page,
  }) async {
    // no SDK API — SDK 缺 getArticleFavList 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> addFavArticle({
    required String id,
  }) async {
    // no SDK API — SDK 缺 addArticleFav 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> delFavArticle({
    required String id,
  }) async {
    // no SDK API — SDK 缺 delArticleFav 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CoreFavNoteItemModel>?>> userNoteList({
    required int page,
  }) async {
    // OttoHub SDK has no per-user favorite-blog list; getUserBlogList returns
    // the current user's own published blogs, so the uid is resolved from the
    // profile (this repository has no other account reference).
    try {
      final profile = await _client.oldProfile.getUserProfile();
      final blogs = await _client.oldBlog.getUserBlogList(
        uid: profile.uid,
        offset: (page - 1) * 10,
        num: 10,
      );
      final list = blogs.map((e) => _favBlogToNote(
        bid: e.bid,
        title: e.title,
        content: e.content,
        thumbnails: e.thumbnails,
      )).toList();
      return _ok(list);
    } on ApiException catch (e) {
      debugPrint('OttoFavRepository.userNoteList ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<List<CoreFavNoteItemModel>?>> noteList({
    required int page,
  }) async {
    try {
      final result = await _client.oldProfile.getFavoriteBlogList(
        offset: (page - 1) * 10,
        num: 10,
      );
      final items = result['blog_list'] as List<FavoriteBlogItem>? ?? const [];
      final list = items.map((e) => _favBlogToNote(
        bid: e.bid,
        title: e.title,
        content: e.content,
        thumbnails: e.thumbnails,
      )).toList();
      return _ok(list);
    } on ApiException catch (e) {
      debugPrint('OttoFavRepository.noteList ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<void>> delNote({
    required bool isPublish,
    required String noteIds,
  }) async {
    // isPublish: permanently delete the published blogs via IOldManageApi.
    // Otherwise (favorites mode): unfavorite each blog via IOldEngagementApi.
    // favoriteBlog, which is a toggle (favorite/unfavorite) - items in the
    // favorite list are already favorited, so one toggle removes them,
    // mirroring favVideo above.
    try {
      final ids = noteIds
          .split(',')
          .map((s) => int.tryParse(s.trim()))
          .where((e) => e != null)
          .cast<int>()
          .toList();
      if (ids.isEmpty) return _err(const ApiException('invalid_note_ids'));
      for (final id in ids) {
        if (isPublish) {
          await _client.oldManage.deleteBlog(id);
        } else {
          await _client.oldEngagement.favoriteBlog(id);
        }
      }
      return const Success(null);
    } on ApiException catch (e) {
      debugPrint('OttoFavRepository.delNote ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreFavPgcData>> favPgc({
    required int type,
    required int pn,
    int? followStatus,
    Object? mid,
  }) async {
    // no SDK API — SDK 缺 getPgcFavList 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreFavFolderData>> videoInFolder({
    int? mid,
    Object? rid,
    Object? type,
  }) async {
    // no SDK API — SDK 缺 videoInFolder 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> unfavAll(
    Object rid,
    Object type,
  ) async {
    // no SDK API — SDK 缺 unfavAll 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> seasonFav({
    required bool isFav,
    required String? seasonId,
  }) async {
    // no SDK API — SDK 缺 seasonFavorite 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<List<CoreSpaceFavData>?>> spaceFav({
    required int mid,
  }) async {
    // no SDK API — SDK 缺 spaceFav 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<CoreFavFolderInfo>> addOrEditFolder({
    required bool isAdd,
    Object? mediaId,
    required String title,
    required int privacy,
    required String cover,
    required String intro,
  }) async {
    // SDK `IOldCollectionApi.setVideoCollection({vid, collection})` assigns
    // a video to a named collection — the closest folder-write equivalent.
    // `collection` is the folder title; `vid` is the folder/media id when
    // editing (OttoHub collection ids ARE video ids). privacy/cover/intro
    // have no SDK counterpart and are ignored.
    try {
      final id = mediaId != null ? int.tryParse(mediaId.toString()) : null;
      if (mediaId != null && id == null) {
        return _err(const ApiException('invalid_media_id'));
      }
      await _client.oldCollection.setVideoCollection(
        vid: id ?? 0,
        collection: title,
      );
      return _ok(CoreFavFolderInfo(
        id: id ?? 0,
        title: title,
        mid: 0,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoFavRepository.addOrEditFolder ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<CoreFavFolderInfo>> favFolderInfo({
    required String mediaId,
  }) async {
    // SDK `IOldCollectionApi.getVideoCollection(vid)` returns the named
    // collection a video belongs to — the closest folder-info equivalent
    // (OttoHub collection ids ARE video ids).
    try {
      final id = int.tryParse(mediaId);
      if (id == null) return _err(const ApiException('invalid_media_id'));
      final detail = await _client.oldCollection.getVideoCollection(id);
      return _ok(CoreFavFolderInfo(
        id: id,
        title: detail.collection,
        mid: 0,
        cover: detail.videoList.firstOrNull?.coverUrl ?? '',
        mediaCount: detail.videoList.length,
      ));
    } on ApiException catch (e) {
      debugPrint('OttoFavRepository.favFolderInfo ApiException: ${e.errorCode}');
      return _err(e);
    }
  }

  @override
  Future<LoadingState<void>> deleteFolder({
    required String mediaIds,
  }) async {
    // no SDK API — SDK 缺 deleteFolder 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> sortFavFolder({
    required String sort,
  }) async {
    // no SDK API — SDK 缺 sortFavFolder 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> cleanFav({
    required String mediaId,
  }) async {
    // no SDK API — SDK 缺 cleanFav 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> copyOrMoveFav({
    required bool isCopy,
    required bool isFav,
    required String? srcMediaId,
    required String? tarMediaId,
    int? mid,
    required String resources,
  }) async {
    // no SDK API — SDK 缺 copyOrMoveFav 或等效端点
    return _err(const ApiException('not_implemented'));
  }

  @override
  Future<LoadingState<void>> communityAction({
    required String opusId,
    required int action,
  }) async {
    // no SDK API — SDK 缺 communityAction 或等效端点
    return _err(const ApiException('not_implemented'));
  }
}
