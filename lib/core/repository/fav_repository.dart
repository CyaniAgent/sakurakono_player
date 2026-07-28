import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/result/loading_state.dart';

/// Repository interface for favorite/collection operations.
///
/// Mirrors the operations defined in [FavHttp] without any HTTP coupling.
abstract class FavRepository {
  Future<LoadingState<void>> favFavFolder(Object mediaId);

  Future<LoadingState<void>> unfavFavFolder(Object mediaId);

  Future<LoadingState<CoreFavDetailData>> userFavFolderDetail({
    required int mediaId,
    required int pn,
    required int ps,
    String keyword = '',
    CoreFavOrderType order = CoreFavOrderType.mtime,
    int type = 0,
  });

  Future<LoadingState<void>> cancelSub({
    required int id,
    required int type,
  });

  Future<LoadingState<CoreSubDetailData>> favSeasonList({
    required int id,
    required int pn,
    required int ps,
  });

  Future<LoadingState<CoreSpaceCheeseData>> favPugv({
    required int mid,
    required int page,
  });

  Future<LoadingState<void>> addFavPugv(Object seasonId);

  Future<LoadingState<void>> delFavPugv(Object seasonId);

  Future<LoadingState<CoreFavTopicData>> favTopic({
    required int page,
  });

  Future<LoadingState<void>> addFavTopic(Object topicId);

  Future<LoadingState<void>> delFavTopic(Object topicId);

  Future<LoadingState<void>> likeTopic(
    Object topicId,
    bool isLike,
  );

  Future<LoadingState<CoreFavArticleData>> favArticle({
    required int page,
  });

  Future<LoadingState<void>> addFavArticle({
    required Object id,
  });

  Future<LoadingState<void>> delFavArticle({
    required Object id,
  });

  Future<LoadingState<List<CoreFavNoteItemModel>?>> userNoteList({
    required int page,
  });

  Future<LoadingState<List<CoreFavNoteItemModel>?>> noteList({
    required int page,
  });

  Future<LoadingState<void>> delNote({
    required bool isPublish,
    required String noteIds,
  });

  Future<LoadingState<CoreFavPgcData>> favPgc({
    required int type,
    required int pn,
    int? followStatus,
    Object? mid,
  });

  Future<LoadingState<CoreFavFolderData>> userfavFolder({
    required int pn,
    required int ps,
    required dynamic mid,
  });

  Future<LoadingState<CoreFavFolderData>> allFavFolders(Object mid);

  Future<LoadingState<CoreFavFolderData>> videoInFolder({
    dynamic mid,
    dynamic rid,
    dynamic type,
  });

  Future<LoadingState<void>> favVideo({
    required String resources,
    String? addIds,
    String? delIds,
  });

  Future<LoadingState<void>> unfavAll(
    Object rid,
    Object type,
  );

  Future<LoadingState<void>> seasonFav({
    required bool isFav,
    required dynamic seasonId,
  });

  Future<LoadingState<List<CoreSpaceFavData>?>> spaceFav({
    required int mid,
  });

  Future<LoadingState<CoreFavFolderInfo>> addOrEditFolder({
    required bool isAdd,
    dynamic mediaId,
    required String title,
    required int privacy,
    required String cover,
    required String intro,
  });

  Future<LoadingState<CoreFavFolderInfo>> favFolderInfo({
    required Object mediaId,
  });

  Future<LoadingState<void>> deleteFolder({
    required String mediaIds,
  });

  Future<LoadingState<void>> sortFav({
    required Object mediaId,
    required String sort,
  });

  Future<LoadingState<void>> sortFavFolder({
    required String sort,
  });

  Future<LoadingState<void>> cleanFav({
    required Object mediaId,
  });

  Future<LoadingState<void>> copyOrMoveFav({
    required bool isCopy,
    required bool isFav,
    required dynamic srcMediaId,
    required dynamic tarMediaId,
    dynamic mid,
    required String resources,
  });

  Future<LoadingState<void>> communityAction({
    required Object opusId,
    required Object action,
  });
}
