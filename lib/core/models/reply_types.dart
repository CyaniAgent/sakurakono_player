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

// ---------------------------------------------------------------------------
// CoreReplyItem / CoreReplyMember — typed reply payload (GAP-8)
// ---------------------------------------------------------------------------
//
// Typed counterparts of the raw [Object?] entries carried by
// [CoreMainListReply.replies]. Independent from [CoreReplyInfo] (video_types)
// but kept field-aligned where the two overlap.

/// Member (author) info embedded in a typed reply ([CoreReplyItem]).
class CoreReplyMember {
  /// User ID.
  final int mid;

  /// Display name.
  final String uname;

  /// Avatar URL.
  final String avatar;

  /// Personal signature.
  final String sign;

  /// Member level, may be absent.
  final int? level;

  /// Vip status code (0 = none), may be absent.
  final int? vipStatus;

  /// Official verify info (role/type/desc), may be absent.
  final Map<String, dynamic>? officialVerify;

  const CoreReplyMember({
    this.mid = 0,
    this.uname = '',
    this.avatar = '',
    this.sign = '',
    this.level,
    this.vipStatus,
    this.officialVerify,
  });

  /// Lenient parse: missing or mistyped fields fall back to defaults,
  /// never throws.
  factory CoreReplyMember.fromMap(Map<String, dynamic> map) => CoreReplyMember(
    mid: _firstInt(map, ['mid']),
    uname: _firstString(map, ['uname']),
    avatar: _firstString(map, ['avatar']),
    sign: _firstString(map, ['sign']),
    level: _firstIntOrNull(map, ['level']),
    vipStatus: _firstIntOrNull(map, ['vip_status', 'vipStatus']),
    officialVerify: _firstMap(map, ['official_verify', 'officialVerify']),
  );
}

/// A single typed reply entry from [CoreMainListReply.replies].
class CoreReplyItem {
  /// Reply ID.
  final int rpid;

  /// Subject (video/article) ID this reply belongs to.
  final int oid;

  /// Subject type (1 = video, 12 = article, 33 = audio, …).
  final int type;

  /// Author user ID.
  final int mid;

  /// Root reply ID (0 if the reply itself is a root).
  final int root;

  /// Direct parent reply ID (0 if none).
  final int parent;

  /// Like count.
  final int like;

  /// Reply count (sub-replies).
  final int rcount;

  /// Reply text content.
  final String content;

  /// Creation timestamp (Unix seconds).
  final int ctime;

  /// Author info, may be absent.
  final CoreReplyMember? member;

  /// Current viewer's like state, may be absent.
  final int? likeState;

  const CoreReplyItem({
    this.rpid = 0,
    this.oid = 0,
    this.type = 0,
    this.mid = 0,
    this.root = 0,
    this.parent = 0,
    this.like = 0,
    this.rcount = 0,
    this.content = '',
    this.ctime = 0,
    this.member,
    this.likeState,
  });

  /// Lenient parse: missing or mistyped fields fall back to defaults,
  /// never throws. `content` accepts both a plain string and a map
  /// carrying the text under `message` (gRPC shape).
  factory CoreReplyItem.fromMap(Map<String, dynamic> map) {
    final member = _firstMap(map, ['member']);
    return CoreReplyItem(
      rpid: _firstInt(map, ['rpid']),
      oid: _firstInt(map, ['oid']),
      type: _firstInt(map, ['type']),
      mid: _firstInt(map, ['mid']),
      root: _firstInt(map, ['root']),
      parent: _firstInt(map, ['parent']),
      like: _firstInt(map, ['like']),
      rcount: _firstInt(map, ['rcount']),
      content: _replyContent(map['content']),
      ctime: _firstInt(map, ['ctime']),
      member: member == null ? null : CoreReplyMember.fromMap(member),
      likeState: _firstIntOrNull(map, ['like_state', 'likeState']),
    );
  }
}

/// First numeric value found among [keys] (int/double to int), else null.
int? _firstIntOrNull(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) {
      return value.toInt();
    }
  }
  return null;
}

/// First numeric value found among [keys], else 0.
int _firstInt(Map<String, dynamic> map, List<String> keys) =>
    _firstIntOrNull(map, keys) ?? 0;

/// First string value found among [keys], else [fallback].
String _firstString(Map<String, dynamic> map, List<String> keys,
    [String fallback = '']) {
  for (final key in keys) {
    final value = map[key];
    if (value is String) {
      return value;
    }
  }
  return fallback;
}

/// First map value found among [keys], re-typed to a string-keyed
/// dynamic map, else null. Never throws.
Map<String, dynamic>? _firstMap(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
  }
  return null;
}

/// Extracts plain reply text from either a raw string or a map with a
/// `message` key (gRPC [CoreReplyInfo.content] shape).
String _replyContent(Object? raw) {
  if (raw is String) {
    return raw;
  }
  if (raw is Map) {
    final message = raw['message'];
    if (message is String) {
      return message;
    }
  }
  return '';
}
