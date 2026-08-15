import 'package:skf/core/models/search_types.dart' show CoreDimension;

/// Navigation contract for the generic history page.
///
/// Opening videos requires adapter-specific route arguments (videoType, PGC
/// episode resolution via adapter HTTP), so concrete handlers are injected by
/// the adapter (see the adapter-side `history_actions.dart`).
/// All handlers are optional: a null handler simply disables that navigation.
class HistoryActions {
  const HistoryActions({
    this.onViewVideo,
    this.onViewPgc,
    this.onViewPgcFromUri,
  });

  /// Open a UGC video by aid/bvid + cid.
  final void Function({
    int? aid,
    String? bvid,
    required int cid,
    String? cover,
    String? title,
    CoreDimension? dimension,
  })? onViewVideo;

  /// Open a PGC (番剧/影视) episode by epId.
  final void Function(int? epId)? onViewPgc;

  /// Open a PUGV (课程) or PGC episode from a bilibili URI.
  final void Function(String uri, {bool isPgc, int? aid})? onViewPgcFromUri;
}
