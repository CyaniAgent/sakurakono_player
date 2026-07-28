/// Core data types for the reply (comment) repository.
///
/// Pure-Dart wrapper types that replace gRPC/protobuf types:
/// - Protobuf enums → simple int-backed enums
/// - `Int64` → `int`
/// - Complex sub-messages → `Object?` (callers cast to concrete gRPC types)
library;

// ---------------------------------------------------------------------------
// CoreMode — comment sort mode (replaces gRPC `Mode` protobuf enum)
// ---------------------------------------------------------------------------

/// Pure-Dart replacement for the gRPC [Mode] protobuf enum.
///
/// Values: default (0), unspecified (1), time (2), hot (3).
class CoreMode {
  final int value;
  final String name;

  const CoreMode._(this.value, this.name);

  static const CoreMode defaultMode = CoreMode._(0, 'DEFAULT_Mode');
  static const CoreMode unspecified = CoreMode._(1, 'UNSPECIFIED');
  static const CoreMode mainListTime = CoreMode._(2, 'MAIN_LIST_TIME');
  static const CoreMode mainListHot = CoreMode._(3, 'MAIN_LIST_HOT');

  static const List<CoreMode> values = [
    defaultMode,
    unspecified,
    mainListTime,
    mainListHot,
  ];

  static CoreMode? valueOf(int value) =>
      value >= 0 && value < values.length ? values[value] : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is CoreMode && other.value == value);

  @override
  int get hashCode => value;

  @override
  String toString() => 'CoreMode.$name';
}

// ---------------------------------------------------------------------------
// CoreSearchItemType — search item type (replaces gRPC protobuf enum)
// ---------------------------------------------------------------------------

/// Pure-Dart replacement for the gRPC [SearchItemType] protobuf enum.
class CoreSearchItemType {
  final int value;
  final String name;

  const CoreSearchItemType._(this.value, this.name);

  static const CoreSearchItemType defaultItemType =
      CoreSearchItemType._(0, 'DEFAULT_ITEM_TYPE');
  static const CoreSearchItemType goods =
      CoreSearchItemType._(1, 'GOODS');
  static const CoreSearchItemType video =
      CoreSearchItemType._(2, 'VIDEO');
  static const CoreSearchItemType article =
      CoreSearchItemType._(3, 'ARTICLE');

  static const List<CoreSearchItemType> values = [
    defaultItemType,
    goods,
    video,
    article,
  ];

  static CoreSearchItemType? valueOf(int value) =>
      value >= 0 && value < values.length ? values[value] : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoreSearchItemType && other.value == value);

  @override
  int get hashCode => value;

  @override
  String toString() => 'CoreSearchItemType.$name';
}

// ---------------------------------------------------------------------------
// CoreMainListReply
// ---------------------------------------------------------------------------

/// Pure-Dart wrapper for the gRPC [MainListReply] type.
class CoreMainListReply {
  /// Pagination cursor (gRPC [CursorReply]).
  final Object? cursor;

  /// Reply list (gRPC [ReplyInfo] list).
  final List<Object?>? replies;

  /// Subject control info (gRPC [SubjectControl]).
  final Object? subjectControl;

  /// Up-top reply (gRPC [ReplyInfo]).
  final Object? upTop;

  /// Admin-top reply (gRPC [ReplyInfo]).
  final Object? adminTop;

  /// Vote-top reply (gRPC [ReplyInfo]).
  final Object? voteTop;

  /// Feed pagination reply (gRPC [FeedPaginationReply]).
  final Object? paginationReply;

  /// Current sort mode.
  final CoreMode? mode;

  /// Mode display text.
  final String? modeText;

  const CoreMainListReply({
    this.cursor,
    this.replies,
    this.subjectControl,
    this.upTop,
    this.adminTop,
    this.voteTop,
    this.paginationReply,
    this.mode,
    this.modeText,
  });

  /// Whether the reply list has an up-top (pinned) reply.
  bool hasUpTop() => upTop != null;
}

// ---------------------------------------------------------------------------
// CoreDetailListReply
// ---------------------------------------------------------------------------

/// Pure-Dart wrapper for the gRPC [DetailListReply] type.
class CoreDetailListReply {
  /// Pagination cursor (gRPC [CursorReply]).
  final Object? cursor;

  /// Subject control info (gRPC [SubjectControl]).
  final Object? subjectControl;

  /// Root reply (gRPC [ReplyInfo]).
  final Object? root;

  /// Current sort mode.
  final CoreMode? mode;

  /// Feed pagination reply (gRPC [FeedPaginationReply]).
  final Object? paginationReply;

  const CoreDetailListReply({
    this.cursor,
    this.subjectControl,
    this.root,
    this.mode,
    this.paginationReply,
  });
}

// ---------------------------------------------------------------------------
// CoreDialogListReply
// ---------------------------------------------------------------------------

/// Pure-Dart wrapper for the gRPC [DialogListReply] type.
class CoreDialogListReply {
  /// Pagination cursor (gRPC [CursorReply]).
  final Object? cursor;

  /// Subject control info (gRPC [SubjectControl]).
  final Object? subjectControl;

  /// Reply list (gRPC [ReplyInfo] list).
  final List<Object?>? replies;

  /// Feed pagination reply (gRPC [FeedPaginationReply]).
  final Object? paginationReply;

  const CoreDialogListReply({
    this.cursor,
    this.subjectControl,
    this.replies,
    this.paginationReply,
  });
}

// ---------------------------------------------------------------------------
// CoreSearchItemReply
// ---------------------------------------------------------------------------

/// Pure-Dart wrapper for the gRPC [SearchItemReply] type.
class CoreSearchItemReply {
  /// Search cursor (gRPC [SearchItemCursorReply]).
  final Object? cursor;

  /// Search result items (gRPC [SearchItem] list).
  final List<Object?>? items;

  /// Extra search info (gRPC [SearchItemReplyExtraInfo]).
  final Object? extra;

  const CoreSearchItemReply({
    this.cursor,
    this.items,
    this.extra,
  });
}

// ---------------------------------------------------------------------------
// CoreTranslateReplyResp
// ---------------------------------------------------------------------------

/// Pure-Dart wrapper for the gRPC [TranslateReplyResp] type.
class CoreTranslateReplyResp {
  /// Translated reply map (gRPC `Map<Int64, ReplyInfo>` → `Map<int, Object?>`).
  final Map<int, Object?>? translatedReplies;

  const CoreTranslateReplyResp({this.translatedReplies});
}
