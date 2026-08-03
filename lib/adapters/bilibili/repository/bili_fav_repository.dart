import 'package:skf/adapters/bilibili/http/fav.dart';
import 'package:skf/adapters/bilibili/models/common/fav_order_type.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_article/author.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_article/cover.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_article/data.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_article/item.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_article/stat.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_detail/cnt_info.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_detail/data.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_detail/media.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_detail/ogv.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_detail/ugc.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_folder/data.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_folder/list.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_note/list.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_pgc/data.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_pgc/list.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_pgc/new_ep.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_topic/data.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_topic/page_info.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_topic/topic_item.dart';
import 'package:skf/adapters/bilibili/models_new/fav/fav_topic/topic_list.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_cheese/data.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_cheese/item.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_cheese/page.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_fav/data.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_fav/list.dart';
import 'package:skf/adapters/bilibili/models_new/space/space_fav/media_list_response.dart';
import 'package:skf/adapters/bilibili/models_new/sub/sub/list.dart';
import 'package:skf/adapters/bilibili/models_new/sub/sub_detail/data.dart';
import 'package:skf/adapters/bilibili/models_new/sub/sub_detail/media.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';

/// Bilibili implementation of [FavRepository].
///
/// Delegates all operations to [FavHttp] and converts adapter models to core
/// types via private `_*ToMap` helpers consumed by `Core*.fromJson`.
class BiliFavRepository implements FavRepository {
  // ---- enum conversion ----

  FavOrderType _toFavOrder(CoreFavOrderType order) {
    return FavOrderType.values.firstWhere((e) => e.name == order.name);
  }

  // ---- common scaffold helpers ----

  Map<String, dynamic> _cntInfoToMap(CntInfo d) => <String, dynamic>{
    'play': d.play,
    'danmaku': d.danmaku,
  };

  Map<String, dynamic> _ogvToMap(Ogv d) => <String, dynamic>{
    'type_name': d.typeName,
    'season_id': d.seasonId,
  };

  Map<String, dynamic> _ugcToMap(Ugc d) => <String, dynamic>{
    'first_cid': d.firstCid,
  };

  // ---- FavFolderInfo -> CoreFavFolderInfo ----

  Map<String, dynamic> _favFolderInfoToMap(FavFolderInfo d) => <String, dynamic>{
    'id': d.id,
    'fid': d.fid,
    'mid': d.mid,
    'attr': d.attr,
    'title': d.title,
    'cover': d.cover,
    'upper': d.upper?.toJson(),
    'intro': d.intro,
    'fav_state': d.favState,
    'media_count': d.mediaCount,
  };

  // ---- FavFolderData -> CoreFavFolderData ----

  Map<String, dynamic> _favFolderDataToMap(FavFolderData d) => <String, dynamic>{
    'count': d.count,
    'list': d.list?.map(_favFolderInfoToMap).toList(),
    'has_more': d.hasMore,
  };

  // ---- FavDetailItemModel -> CoreFavDetailItemModel ----

  Map<String, dynamic> _favDetailItemToMap(FavDetailItemModel d) => <String, dynamic>{
    'id': d.id,
    'type': d.type,
    'title': d.title,
    'cover': d.cover,
    'intro': d.intro,
    'duration': d.duration,
    'upper': d.upper?.toJson(),
    'attr': d.attr,
    'cnt_info': d.cntInfo == null ? null : _cntInfoToMap(d.cntInfo!),
    'fav_time': d.favTime,
    'bvid': d.bvid,
    'bv_id': d.bvid,
    'ogv': d.ogv == null ? null : _ogvToMap(d.ogv!),
    'ugc': d.ugc == null ? null : _ugcToMap(d.ugc!),
  };

  // ---- FavDetailData -> CoreFavDetailData ----

  Map<String, dynamic> _favDetailToMap(FavDetailData d) => <String, dynamic>{
    'info': d.info == null ? null : _favFolderInfoToMap(d.info!),
    'medias': d.medias?.map(_favDetailItemToMap).toList(),
    'has_more': d.hasMore,
  };

  // ---- SubItemModel -> CoreSubItemModel ----

  Map<String, dynamic> _subItemToMap(SubItemModel d) => <String, dynamic>{
    'id': d.id,
    'fid': d.fid,
    'mid': d.mid,
    'attr': d.attr,
    'title': d.title,
    'cover': d.cover,
    'upper': d.upper?.toJson(),
    'cover_type': d.coverType,
    'intro': d.intro,
    'ctime': d.ctime,
    'mtime': d.mtime,
    'state': d.state,
    'fav_state': d.favState,
    'media_count': d.mediaCount,
    'view_count': d.viewCount,
    'type': d.type,
    'cnt_info': d.cntInfo == null ? null : _cntInfoToMap(d.cntInfo!),
  };

  // ---- SubDetailItemModel -> CoreSubDetailItemModel ----

  Map<String, dynamic> _subDetailItemToMap(SubDetailItemModel d) => <String, dynamic>{
    'id': d.id,
    'title': d.title,
    'cover': d.cover,
    'duration': d.duration,
    'pubtime': d.pubtime,
    'bvid': d.bvid,
    'cnt_info': d.cntInfo == null ? null : _cntInfoToMap(d.cntInfo!),
  };

  // ---- SubDetailData -> CoreSubDetailData ----

  Map<String, dynamic> _subDetailToMap(SubDetailData d) => <String, dynamic>{
    'info': d.info == null ? null : _subItemToMap(d.info!),
    'medias': d.medias?.map(_subDetailItemToMap).toList(),
  };

  // ---- SpaceCheeseItem -> CoreSpaceCheeseItem ----

  Map<String, dynamic> _spaceCheeseItemToMap(SpaceCheeseItem d) => <String, dynamic>{
    'cover': d.cover,
    'marks': d.marks,
    'season_id': d.seasonId,
    'status': d.status,
    'title': d.title,
    'ctime': d.ctime,
  };

  // ---- SpaceCheesePage -> CoreSpaceCheesePage ----

  Map<String, dynamic> _spaceCheesePageToMap(SpaceCheesePage d) => <String, dynamic>{
    'next': d.next,
  };

  // ---- SpaceCheeseData -> CoreSpaceCheeseData ----

  Map<String, dynamic> _spaceCheeseToMap(SpaceCheeseData d) => <String, dynamic>{
    'items': d.items?.map(_spaceCheeseItemToMap).toList(),
    'page': d.page == null ? null : _spaceCheesePageToMap(d.page!),
  };

  // ---- FavTopicItem -> CoreFavTopicItem ----

  Map<String, dynamic> _favTopicItemToMap(FavTopicItem d) => <String, dynamic>{
    'id': d.id,
    'name': d.name,
  };

  // ---- PageInfo -> CorePageInfo ----

  Map<String, dynamic> _pageInfoToMap(PageInfo d) => <String, dynamic>{
    'total': d.total,
  };

  // ---- TopicList -> CoreTopicList ----

  Map<String, dynamic> _topicListToMap(TopicList d) => <String, dynamic>{
    'topic_items': d.topicItems?.map(_favTopicItemToMap).toList(),
    'page_info': d.pageInfo == null ? null : _pageInfoToMap(d.pageInfo!),
  };

  // ---- FavTopicData -> CoreFavTopicData ----

  Map<String, dynamic> _favTopicToMap(FavTopicData d) => <String, dynamic>{
    'topic_list': d.topicList == null ? null : _topicListToMap(d.topicList!),
  };

  // ---- article sub-model helpers ----

  Map<String, dynamic> _authorToMap(Author d) => <String, dynamic>{
    'name': d.name,
  };

  Map<String, dynamic> _articleCoverToMap(Cover d) => <String, dynamic>{
    'url': d.url,
  };

  Map<String, dynamic> _statToMap(Stat d) => <String, dynamic>{
    'like': d.like,
  };

  // ---- FavArticleItemModel -> CoreFavArticleItemModel ----

  Map<String, dynamic> _favArticleItemToMap(FavArticleItemModel d) => <String, dynamic>{
    'opus_id': d.opusId,
    'content': d.content,
    'author': d.author == null ? null : _authorToMap(d.author!),
    'cover': d.cover == null ? null : _articleCoverToMap(d.cover!),
    'stat': d.stat == null ? null : _statToMap(d.stat!),
    'pub_time': d.pubTime,
  };

  // ---- FavArticleData -> CoreFavArticleData ----

  Map<String, dynamic> _favArticleToMap(FavArticleData d) => <String, dynamic>{
    'items': d.items?.map(_favArticleItemToMap).toList(),
    'has_more': d.hasMore,
  };

  // ---- FavNoteItemModel -> CoreFavNoteItemModel ----

  Map<String, dynamic> _favNoteToMap(FavNoteItemModel d) => <String, dynamic>{
    'web_url': d.webUrl,
    'title': d.title,
    'summary': d.summary,
    'message': d.message,
    'arc': d.pic == null ? null : <String, dynamic>{'pic': d.pic},
    'cvid': d.cvid,
    'note_id': d.noteId,
  };

  // ---- NewEp -> CoreNewEp ----

  Map<String, dynamic> _newEpToMap(NewEp d) => <String, dynamic>{
    'index_show': d.indexShow,
  };

  // ---- FavPgcItemModel -> CoreFavPgcItemModel ----

  Map<String, dynamic> _favPgcItemToMap(FavPgcItemModel d) => <String, dynamic>{
    'season_id': d.seasonId,
    'title': d.title,
    'cover': d.cover,
    'is_finish': d.isFinish,
    'badge': d.badge,
    'new_ep': d.newEp == null ? null : _newEpToMap(d.newEp!),
    'renewal_time': d.renewalTime,
    'progress': d.progress == null || d.progress!.isEmpty ? '' : d.progress,
  };

  // ---- FavPgcData -> CoreFavPgcData ----

  Map<String, dynamic> _favPgcToMap(FavPgcData d) => <String, dynamic>{
    'list': d.list?.map(_favPgcItemToMap).toList(),
    'total': d.total,
  };

  // ---- SpaceFavItemModel -> CoreSpaceFavItemModel ----

  Map<String, dynamic> _spaceFavItemToMap(SpaceFavItemModel d) => <String, dynamic>{
    'id': d.id,
    'media_id': d.mediaId,
    'count': d.count,
    'is_public': d.isPublic,
    'fid': d.fid,
    'mid': d.mid,
    'attr': d.attr,
    'title': d.title,
    'cover': d.cover,
    'upper': d.upper?.toJson(),
    'cover_type': d.coverType,
    'intro': d.intro,
    'ctime': d.ctime,
    'mtime': d.mtime,
    'state': d.state,
    'fav_state': d.favState,
    'media_count': d.mediaCount,
    'view_count': d.viewCount,
    'type': d.type,
  };

  // ---- MediaListResponse -> CoreMediaListResponse ----

  Map<String, dynamic> _mediaListResponseToMap(MediaListResponse d) => <String, dynamic>{
    'count': d.count,
    'list': d.list?.map(_spaceFavItemToMap).toList(),
  };

  // ---- SpaceFavData -> CoreSpaceFavData ----

  Map<String, dynamic> _spaceFavToMap(SpaceFavData d) => <String, dynamic>{
    'id': d.id,
    'name': d.name,
    'mediaListResponse': d.mediaListResponse == null
        ? null
        : _mediaListResponseToMap(d.mediaListResponse!),
  };

  // ---- interface implementation ----

  @override
  Future<LoadingState<void>> favFavFolder(Object mediaId) {
    return FavHttp.favFavFolder(mediaId);
  }

  @override
  Future<LoadingState<void>> unfavFavFolder(Object mediaId) {
    return FavHttp.unfavFavFolder(mediaId);
  }

  @override
  Future<LoadingState<CoreFavDetailData>> userFavFolderDetail({
    required int mediaId,
    required int pn,
    required int ps,
    String keyword = '',
    CoreFavOrderType order = CoreFavOrderType.mtime,
    int type = 0,
  }) async {
    final result = await FavHttp.userFavFolderDetail(
      mediaId: mediaId,
      pn: pn,
      ps: ps,
      keyword: keyword,
      order: _toFavOrder(order),
      type: type,
    );
    if (result case Success(:final response)) {
      return Success(CoreFavDetailData.fromJson(_favDetailToMap(response)));
    }
    return result as LoadingState<CoreFavDetailData>;
  }

  @override
  Future<LoadingState<void>> cancelSub({
    required int id,
    required int type,
  }) {
    return FavHttp.cancelSub(id: id, type: type);
  }

  @override
  Future<LoadingState<CoreSubDetailData>> favSeasonList({
    required int id,
    required int pn,
    required int ps,
  }) async {
    final result = await FavHttp.favSeasonList(id: id, pn: pn, ps: ps);
    if (result case Success(:final response)) {
      return Success(CoreSubDetailData.fromJson(_subDetailToMap(response)));
    }
    return result as LoadingState<CoreSubDetailData>;
  }

  @override
  Future<LoadingState<CoreSpaceCheeseData>> favPugv({
    required int mid,
    required int page,
  }) async {
    final result = await FavHttp.favPugv(mid: mid, page: page);
    if (result case Success(:final response)) {
      return Success(
        CoreSpaceCheeseData.fromJson(_spaceCheeseToMap(response)),
      );
    }
    return result as LoadingState<CoreSpaceCheeseData>;
  }

  @override
  Future<LoadingState<void>> addFavPugv(Object seasonId) {
    return FavHttp.addFavPugv(seasonId);
  }

  @override
  Future<LoadingState<void>> delFavPugv(Object seasonId) {
    return FavHttp.delFavPugv(seasonId);
  }

  @override
  Future<LoadingState<CoreFavTopicData>> favTopic({
    required int page,
  }) async {
    final result = await FavHttp.favTopic(page: page);
    if (result case Success(:final response)) {
      return Success(CoreFavTopicData.fromJson(_favTopicToMap(response)));
    }
    return result as LoadingState<CoreFavTopicData>;
  }

  @override
  Future<LoadingState<void>> addFavTopic(Object topicId) {
    return FavHttp.addFavTopic(topicId);
  }

  @override
  Future<LoadingState<void>> delFavTopic(Object topicId) {
    return FavHttp.delFavTopic(topicId);
  }

  @override
  Future<LoadingState<void>> likeTopic(
    Object topicId,
    bool isLike,
  ) {
    return FavHttp.likeTopic(topicId, isLike);
  }

  @override
  Future<LoadingState<CoreFavArticleData>> favArticle({
    required int page,
  }) async {
    final result = await FavHttp.favArticle(page: page);
    if (result case Success(:final response)) {
      return Success(
        CoreFavArticleData.fromJson(_favArticleToMap(response)),
      );
    }
    return result as LoadingState<CoreFavArticleData>;
  }

  @override
  Future<LoadingState<void>> addFavArticle({
    required Object id,
  }) {
    return FavHttp.addFavArticle(id: id);
  }

  @override
  Future<LoadingState<void>> delFavArticle({
    required Object id,
  }) {
    return FavHttp.delFavArticle(id: id);
  }

  @override
  Future<LoadingState<List<CoreFavNoteItemModel>?>> userNoteList({
    required int page,
  }) async {
    final result = await FavHttp.userNoteList(page: page);
    if (result case Success(:final response)) {
      return Success(
        response
            ?.map((e) => CoreFavNoteItemModel.fromJson(_favNoteToMap(e)))
            .toList(),
      );
    }
    return result as LoadingState<List<CoreFavNoteItemModel>?>;
  }

  @override
  Future<LoadingState<List<CoreFavNoteItemModel>?>> noteList({
    required int page,
  }) async {
    final result = await FavHttp.noteList(page: page);
    if (result case Success(:final response)) {
      return Success(
        response
            ?.map((e) => CoreFavNoteItemModel.fromJson(_favNoteToMap(e)))
            .toList(),
      );
    }
    return result as LoadingState<List<CoreFavNoteItemModel>?>;
  }

  @override
  Future<LoadingState<void>> delNote({
    required bool isPublish,
    required String noteIds,
  }) {
    return FavHttp.delNote(isPublish: isPublish, noteIds: noteIds);
  }

  @override
  Future<LoadingState<CoreFavPgcData>> favPgc({
    required int type,
    required int pn,
    int? followStatus,
    Object? mid,
  }) async {
    final result = await FavHttp.favPgc(
      type: type,
      pn: pn,
      followStatus: followStatus,
      mid: mid,
    );
    if (result case Success(:final response)) {
      return Success(CoreFavPgcData.fromJson(_favPgcToMap(response)));
    }
    return result as LoadingState<CoreFavPgcData>;
  }

  @override
  Future<LoadingState<CoreFavFolderData>> userfavFolder({
    required int pn,
    required int ps,
    required dynamic mid,
  }) async {
    final result = await FavHttp.userfavFolder(pn: pn, ps: ps, mid: mid);
    if (result case Success(:final response)) {
      return Success(
        CoreFavFolderData.fromJson(_favFolderDataToMap(response)),
      );
    }
    return result as LoadingState<CoreFavFolderData>;
  }

  @override
  Future<LoadingState<CoreFavFolderData>> allFavFolders(Object mid) async {
    final result = await FavHttp.allFavFolders(mid);
    if (result case Success(:final response)) {
      return Success(
        CoreFavFolderData.fromJson(_favFolderDataToMap(response)),
      );
    }
    return result as LoadingState<CoreFavFolderData>;
  }

  @override
  Future<LoadingState<CoreFavFolderData>> videoInFolder({
    dynamic mid,
    dynamic rid,
    dynamic type,
  }) async {
    final result = await FavHttp.videoInFolder(
      mid: mid,
      rid: rid,
      type: type,
    );
    if (result case Success(:final response)) {
      return Success(
        CoreFavFolderData.fromJson(_favFolderDataToMap(response)),
      );
    }
    return result as LoadingState<CoreFavFolderData>;
  }

  @override
  Future<LoadingState<void>> favVideo({
    required String resources,
    String? addIds,
    String? delIds,
  }) {
    return FavHttp.favVideo(
      resources: resources,
      addIds: addIds,
      delIds: delIds,
    );
  }

  @override
  Future<LoadingState<void>> unfavAll(
    Object rid,
    Object type,
  ) {
    return FavHttp.unfavAll(rid: rid, type: type);
  }

  @override
  Future<LoadingState<void>> seasonFav({
    required bool isFav,
    required dynamic seasonId,
  }) {
    return FavHttp.seasonFav(isFav: isFav, seasonId: seasonId);
  }

  @override
  Future<LoadingState<List<CoreSpaceFavData>?>> spaceFav({
    required int mid,
  }) async {
    final result = await FavHttp.spaceFav(mid: mid);
    if (result case Success(:final response)) {
      return Success(
        response
            ?.map((e) => CoreSpaceFavData.fromJson(_spaceFavToMap(e)))
            .toList(),
      );
    }
    return result as LoadingState<List<CoreSpaceFavData>?>;
  }

  @override
  Future<LoadingState<CoreFavFolderInfo>> addOrEditFolder({
    required bool isAdd,
    dynamic mediaId,
    required String title,
    required int privacy,
    required String cover,
    required String intro,
  }) async {
    final result = await FavHttp.addOrEditFolder(
      isAdd: isAdd,
      mediaId: mediaId,
      title: title,
      privacy: privacy,
      cover: cover,
      intro: intro,
    );
    if (result case Success(:final response)) {
      return Success(
        CoreFavFolderInfo.fromJson(_favFolderInfoToMap(response)),
      );
    }
    return result as LoadingState<CoreFavFolderInfo>;
  }

  @override
  Future<LoadingState<CoreFavFolderInfo>> favFolderInfo({
    required Object mediaId,
  }) async {
    final result = await FavHttp.favFolderInfo(mediaId: mediaId);
    if (result case Success(:final response)) {
      return Success(
        CoreFavFolderInfo.fromJson(_favFolderInfoToMap(response)),
      );
    }
    return result as LoadingState<CoreFavFolderInfo>;
  }

  @override
  Future<LoadingState<void>> deleteFolder({
    required String mediaIds,
  }) {
    return FavHttp.deleteFolder(mediaIds: mediaIds);
  }

  @override
  Future<LoadingState<void>> sortFav({
    required Object mediaId,
    required String sort,
  }) {
    return FavHttp.sortFav(mediaId: mediaId, sort: sort);
  }

  @override
  Future<LoadingState<void>> sortFavFolder({
    required String sort,
  }) {
    return FavHttp.sortFavFolder(sort: sort);
  }

  @override
  Future<LoadingState<void>> cleanFav({
    required Object mediaId,
  }) {
    return FavHttp.cleanFav(mediaId: mediaId);
  }

  @override
  Future<LoadingState<void>> copyOrMoveFav({
    required bool isCopy,
    required bool isFav,
    required dynamic srcMediaId,
    required dynamic tarMediaId,
    dynamic mid,
    required String resources,
  }) {
    return FavHttp.copyOrMoveFav(
      isCopy: isCopy,
      isFav: isFav,
      srcMediaId: srcMediaId,
      tarMediaId: tarMediaId,
      mid: mid,
      resources: resources,
    );
  }

  @override
  Future<LoadingState<void>> communityAction({
    required Object opusId,
    required Object action,
  }) {
    return FavHttp.communityAction(opusId: opusId, action: action);
  }
}
