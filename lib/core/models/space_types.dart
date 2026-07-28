/// Core data types for the space repository.
///
/// Pure-Dart wrapper types for gRPC response types. These replace
/// protobuf types with plain Dart objects: `Int64` → `int`,
/// `PbList` → `List<dynamic>`, sub-messages → `dynamic`.
library;

// ---------------------------------------------------------------------------
// CoreOpusSpaceFlowResp
// ---------------------------------------------------------------------------

/// Pure-Dart wrapper for the gRPC [OpusSpaceFlowResp] type.
class CoreOpusSpaceFlowResp {
  /// Opus flow items (gRPC [OpusFlowItem] list).
  final List<dynamic>? itemList;

  /// Pagination cursor for the next page (gRPC [PaginationReply]).
  final dynamic nextPage;

  /// Host's opus collection section (gRPC [SectionOpusCollection]).
  final dynamic hostUpOpusCollection;

  /// Host's note navigation bar (gRPC [SectionNoteNavigationBar]).
  final dynamic hostUpNoteNavBar;

  const CoreOpusSpaceFlowResp({
    this.itemList,
    this.nextPage,
    this.hostUpOpusCollection,
    this.hostUpNoteNavBar,
  });
}

// ---------------------------------------------------------------------------
// CoreSearchArchiveReply
// ---------------------------------------------------------------------------

/// Pure-Dart wrapper for the gRPC [SearchArchiveReply] type.
class CoreSearchArchiveReply {
  /// Total number of archives (gRPC `Int64` → `int`).
  final int total;

  /// Archive list (gRPC [Arc] items).
  final List<dynamic>? archives;

  const CoreSearchArchiveReply({
    required this.total,
    this.archives,
  });
}
