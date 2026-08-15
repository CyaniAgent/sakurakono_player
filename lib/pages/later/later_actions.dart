import 'package:skf/core/models/user_types.dart'
    show CoreDimension, CoreLaterItemModel;
import 'package:skf/pages/common/multi_select/base.dart'
    show CommonMultiSelectMixin;
import 'package:flutter/widgets.dart' show BuildContext;

/// Data for opening a video from the later page.
///
/// [watchLaterExtra] carries the generic extra arguments for the watch-later
/// playlist mode (count/favTitle/mediaId/desc/...); the adapter merges its
/// source-type specific keys into the video-page arguments.
class LaterVideoRequest {
  const LaterVideoRequest({
    this.aid,
    this.bvid,
    required this.cid,
    this.cover,
    this.title,
    this.dimension,
    this.isWatchLaterPlaylist = false,
    this.watchLaterExtra,
  });

  final int? aid;
  final String? bvid;
  final int? cid;
  final String? cover;
  final String? title;
  final CoreDimension? dimension;

  /// True when the video opens inside the watch-later playlist context
  /// (play-all / continue-playing / later search).
  final bool isWatchLaterPlaylist;

  /// Extra arguments merged into the video-page arguments when
  /// [isWatchLaterPlaylist] is true (generic values only).
  final Map<String, dynamic>? watchLaterExtra;
}

/// Navigation contract for the generic later page.
///
/// Video-opening requires adapter-specific route arguments (videoType,
/// sourceType, PGC/PUGV episode resolution via adapter HTTP), so concrete
/// handlers are injected by the adapter (see the adapter-side
/// `later_actions.dart`).
class LaterActions {
  const LaterActions({
    this.onViewVideo,
    this.onViewPugv,
    this.onViewPgc,
    this.onViewPgcFromUri,
    this.onCopyOrMove,
  });

  /// Open a UGC video.
  final void Function(LaterVideoRequest request)? onViewVideo;

  /// Open a PUGV (课堂) course by seasonId.
  final void Function(int? seasonId)? onViewPugv;

  /// Open a PGC (番剧/影视) episode by epId.
  final void Function(int? epId)? onViewPgc;

  /// Open a PGC episode from a bilibili URI.
  final void Function(String uri)? onViewPgcFromUri;

  /// Copy/move the selected items to a media folder (复制/移动).
  final void Function(
    BuildContext context,
    CommonMultiSelectMixin<CoreLaterItemModel> ctr,
    bool isCopy,
    int mid,
  )? onCopyOrMove;
}
