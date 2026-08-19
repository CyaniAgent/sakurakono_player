import 'package:skf/core/repository/fav_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/fav_types.dart';
import 'package:skf/adapters/bilibili/models/common/video/source_type.dart';
import 'package:skf/pages/common/multi_select/base.dart';
import 'package:skf/pages/common/search/common_search_controller.dart';
import 'package:skf/adapters/bilibili/pages/fav_detail/controller.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';

class FavSearchController
    extends CommonSearchController<CoreFavDetailData, CoreFavDetailItemModel>
    with
        CommonMultiSelectMixin<CoreFavDetailItemModel>,
        DeleteItemMixin,
        BaseFavController {
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }
  late int type;
  @override
  late int mediaId;
  @override
  late bool isOwner;
  late dynamic count;
  late dynamic title;

  @override
  void onInit() {
    final args = Get.arguments;
    type = args['type'];
    mediaId = args['mediaId'];
    isOwner = args['isOwner'];
    count = args['count'];
    title = args['title'];
    super.onInit();
  }

  final Rx<CoreFavOrderType> order = CoreFavOrderType.mtime.obs;

  @override
  Future<LoadingState<CoreFavDetailData>> customGetData() async {
    final result = await (_ref?.read(favRepositoryProvider) ?? Get.find<FavRepository>()).userFavFolderDetail(
        pn: page,
        ps: 20,
        mediaId: mediaId,
        keyword: editController.text,
        type: type,
        order: order.value,
      );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  @override
  List<CoreFavDetailItemModel>? getDataList(CoreFavDetailData response) {
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.medias;
  }

  @override
  // NOTE: dimension not carried by fav list API; the video page
  // resolves it itself via videoIntro.
  void onViewFav(CoreFavDetailItemModel item, int? index) => PageUtils.toVideoPage(
    bvid: item.bvid,
    cid: item.ugc!.firstCid!,
    cover: item.cover,
    title: item.title,
    extraArguments: {
      'sourceType': SourceType.fav,
      'mediaId': mediaId,
      'oid': item.id,
      'favTitle': title,
      'count': count,
      'desc': true,
      'isContinuePlaying': true,
    },
  );
}
