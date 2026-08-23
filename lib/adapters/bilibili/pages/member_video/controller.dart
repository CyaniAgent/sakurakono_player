import 'package:skf/common/widgets/scroll_physics.dart';
import 'package:skf/core/repository/member_repository.dart';
import 'package:skf/core/repository/search_repository.dart';
import 'package:skf/core/result/loading_state.dart';
import 'package:get/get.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skf/core/repository/repository_providers.dart';
import 'package:skf/core/models/member_types.dart';
import 'package:skf/adapters/bilibili/models/common/video/source_type.dart';
import 'package:skf/adapters/bilibili/models_new/video/video_detail/dimension.dart';
import 'package:skf/pages/common/common_controller_riverpod.dart';
import 'package:skf/utils/extension/dimension_ext.dart';
import 'package:skf/utils/extension/iterable_ext.dart';
import 'package:skf/adapters/bilibili/utils/id_utils.dart';
import 'package:skf/adapters/bilibili/utils/page_utils.dart';

class MemberVideoCtr
    extends CommonListControllerRiverpod<CoreSpaceArchiveData, CoreSpaceArchiveItem>
    with ReloadMixin {
  MemberVideoCtr({
    required this.type,
    required this.mid,
    required this.seasonId,
    required this.seriesId,
    this.username,
    this.title,
  }) : isVideo = type == CoreContributeType.video {
    if (isVideo) {
      fromViewAid = Get.parameters['from_view_aid'];
    }
    page = 0;
    queryData();
  }

  final CoreContributeType type;
  final bool isVideo;
  int? seasonId;
  String? seriesId;
  final int mid;
  late CoreArchiveOrderTypeApp order = CoreArchiveOrderTypeApp.pubdate;
  late CoreArchiveSortTypeApp sort = CoreArchiveSortTypeApp.desc;
  int? count;
  int? next;
  CoreEpisodicButton? episodicButton;
  final String? username;
  final String? title;

  String? firstAid;
  String? lastAid;
  String? fromViewAid;
  bool isLocating = false;
  bool isLoadPrevious = false;
  bool? hasPrev;
  Ref? _ref;
  void attachRef(Ref ref) { _ref = ref; }

  @override
  Future<void> onRefresh() async {
    if (isLocating) {
      if (hasPrev == true) {
        isLoadPrevious = true;
        await queryData();
      }
    } else {
      isLoadPrevious = false;
      firstAid = null;
      lastAid = null;
      next = null;
      isEnd = false;
      page = 0;
      await queryData();
    }
  }


  @override
  bool customHandleResponse(
    bool isRefresh,
    Success<CoreSpaceArchiveData> response,
  ) {
    final data = response.response;
    episodicButton = data.coreEpisodicButton;
    next = data.next;
    if (page == 0 || isLoadPrevious) {
      hasPrev = data.hasPrev;
    }
    if (page == 0 || !isLoadPrevious) {
      if ((isVideo ? data.hasNext == false : data.next == 0) ||
          data.item.isNullOrEmpty) {
        isEnd = true;
      }
    }
    count = type == CoreContributeType.season ? data.item?.length : data.count;
    if (page != 0) {
      if (loadingState case Success(:final response)) {
        data.item ??= <CoreSpaceArchiveItem>[];
        if (isLoadPrevious) {
          data.item!.addAll(response!);
        } else {
          data.item!.insertAll(0, response!);
        }
      }
    }
    firstAid = data.item?.firstOrNull?.param;
    lastAid = data.item?.lastOrNull?.param;
    isLoadPrevious = false;
    loadingState = Success(data.item);
    return true;
  }

  @override
  Future<LoadingState<CoreSpaceArchiveData>> customGetData() async {
    final result = await (_ref!.read(memberRepositoryProvider)).spaceArchive(
      type: type,
      mid: mid,
      aid: isVideo
          ? isLoadPrevious
                ? firstAid
                : lastAid
          : null,
      order: isVideo ? order : null,
      sort: isVideo
          ? isLoadPrevious
                ? CoreArchiveSortTypeApp.asc
                : null
          : sort,
      pn: type == CoreContributeType.charging ? page : null,
      next: next,
      seasonId: seasonId,
      seriesId: seriesId,
      includeCursor: isLocating && page == 0,
    );
    return switch (result) {
      Loading _ => LoadingState.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg, :final code) => Error(errMsg, code: code),
    };
  }

  void queryBySort() {
    if (isLoading) return;
    if (isVideo) {
      isLocating = false;
      notifyListeners();
      order = order == CoreArchiveOrderTypeApp.pubdate
          ? CoreArchiveOrderTypeApp.click
          : CoreArchiveOrderTypeApp.pubdate;
    } else {
      sort = sort == CoreArchiveSortTypeApp.desc
          ? CoreArchiveSortTypeApp.asc
          : CoreArchiveSortTypeApp.desc;
    }
    onReload();
  }

  Future<void> toViewPlayAll() async {
    final episodicButton = this.episodicButton!;
    if (episodicButton.text == '继续播放' &&
        episodicButton.uri?.isNotEmpty == true) {
      final params = Uri.parse(episodicButton.uri!).queryParameters;
      String? oid = params['oid'];
      if (oid != null) {
        final bvid = IdUtils.av2bv(int.parse(oid));
        final res = await (_ref!.read(searchRepositoryProvider)).ab2cWithDimension(aid: int.tryParse(oid), bvid: bvid);
        final cid = res?.cid;
        if (cid != null) {
          PageUtils.toVideoPage(
            aid: int.parse(oid),
            bvid: bvid,
            cid: cid,
            dimension: res?.dimension != null
                ? Dimension(width: res?.dimension?.width, height: res?.dimension?.height)
                : null,
            extraArguments: {
              'sourceType': SourceType.archive,
              'mediaId': seasonId ?? seriesId ?? mid,
              'oid': oid,
              'favTitle':
                  '$username: ${title ?? episodicButton.text ?? '播放全部'}',
              if (seriesId == null) 'count': ?count,
              if (seasonId != null || seriesId != null)
                'mediaType': params['page_type'],
              'desc': params['desc'] == '1',
              'sortField': params['sort_field'],
              'isContinuePlaying': true,
            },
          );
        }
      }
      return;
    }

    if (loadingState case Success(:final response)) {
      if (response == null || response.isEmpty) return;

      for (CoreSpaceArchiveItem element in response) {
        if (element.cid == null) {
          continue;
        } else {
          bool desc = seasonId != null ? false : true;
          desc =
              (seasonId != null || seriesId != null) &&
                  (isVideo ? order == CoreArchiveOrderTypeApp.click : sort == CoreArchiveSortTypeApp.asc)
              ? !desc
              : desc;
          bool isVertical = false;
          if (element.uri case final uri?) {
            isVertical = uri.isVerticalFromUri;
          }
          PageUtils.toVideoPage(
            bvid: element.bvid,
            cid: element.cid!,
            cover: element.cover,
            title: element.title,
            isVertical: isVertical,
            extraArguments: {
              'sourceType': SourceType.archive,
              'mediaId': seasonId ?? seriesId ?? mid,
              'oid': IdUtils.bv2av(element.bvid!),
              'favTitle':
                  '$username: ${title ?? episodicButton.text ?? '播放全部'}',
              if (seriesId == null) 'count': ?count,
              if (seasonId != null || seriesId != null)
                'mediaType': Uri.parse(
                  episodicButton.uri!,
                ).queryParameters['page_type'],
              'desc': desc,
              if (isVideo) 'sortField': order == CoreArchiveOrderTypeApp.click ? 2 : 1,
            },
          );
          break;
        }
      }
    }
  }

  @override
  Future<void> onReload() {
    reload = true;
    isLocating = false;
    notifyListeners();
    return super.onReload();
  }
}
