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

// ---------------------------------------------------------------------------
// CoreOpusItem / CoreSpaceArc — typed opus/space models (GAP-10)
// ---------------------------------------------------------------------------
//
// Typed counterparts of the raw entries carried by
// [CoreOpusSpaceFlowResp.itemList] and [CoreSearchArchiveReply.archives].

/// A single typed opus (动态/图文) item from [CoreOpusSpaceFlowResp.itemList].
class CoreOpusItem {
  /// Opus ID (string, gRPC shape).
  final String id;

  /// Opus type code.
  final int type;

  /// Cover image URL.
  final String cover;

  /// Opus title.
  final String title;

  /// Opus description / excerpt.
  final String desc;

  /// View count.
  final int view;

  /// Like count.
  final int like;

  /// Comment count.
  final int comment;

  /// Publish timestamp (Unix seconds), may be absent.
  final int? pubTime;

  /// Author user ID, may be absent.
  final int? authorMid;

  /// Author display name.
  final String authorName;

  const CoreOpusItem({
    this.id = '',
    this.type = 0,
    this.cover = '',
    this.title = '',
    this.desc = '',
    this.view = 0,
    this.like = 0,
    this.comment = 0,
    this.pubTime,
    this.authorMid,
    this.authorName = '',
  });

  /// Lenient parse: missing or mistyped fields fall back to defaults,
  /// never throws.
  factory CoreOpusItem.fromMap(Map<String, dynamic> map) => CoreOpusItem(
    id: _opusId(map['id']),
    type: _opusInt(map['type']),
    cover: _opusString(map['cover']) ?? '',
    title: _opusString(map['title']) ?? '',
    desc: _opusString(map['desc']) ?? _opusString(map['description']) ?? '',
    view: _opusInt(map['view']),
    like: _opusInt(map['like']),
    comment: _opusInt(map['comment']),
    pubTime: _opusIntOrNull(map['pub_time']) ?? _opusIntOrNull(map['pubtime']),
    authorMid: _opusIntOrNull(map['author_mid']) ?? _opusIntOrNull(map['mid']),
    authorName:
        _opusString(map['author_name']) ?? _opusString(map['uname']) ?? '',
  );
}

/// A single typed archive (video) item from [CoreSearchArchiveReply.archives].
class CoreSpaceArc {
  /// Archive ID.
  final int aid;

  /// Video ID (BV).
  final String bvid;

  /// Content ID (playable media id).
  final int cid;

  /// Video title.
  final String title;

  /// Cover image URL.
  final String cover;

  /// Duration in seconds.
  final int duration;

  /// Play count.
  final int play;

  /// Danmaku count.
  final int danmaku;

  /// Publish timestamp (Unix seconds).
  final int pubdate;

  /// Owner user ID.
  final int ownerMid;

  /// Owner display name.
  final String ownerName;

  const CoreSpaceArc({
    this.aid = 0,
    this.bvid = '',
    this.cid = 0,
    this.title = '',
    this.cover = '',
    this.duration = 0,
    this.play = 0,
    this.danmaku = 0,
    this.pubdate = 0,
    this.ownerMid = 0,
    this.ownerName = '',
  });

  /// Lenient parse: missing or mistyped fields fall back to defaults,
  /// never throws. ownerMid/ownerName also accept a nested owner map.
  factory CoreSpaceArc.fromMap(Map<String, dynamic> map) {
    final owner = _spaceMap(map['owner']);
    final ownerMid = _opusIntKeys(map, ['owner_mid']);
    return CoreSpaceArc(
      aid: _opusInt(map['aid']),
      bvid: _opusString(map['bvid']) ?? '',
      cid: _opusInt(map['cid']),
      title: _opusString(map['title']) ?? '',
      cover: _opusString(map['cover']) ?? _opusString(map['pic']) ?? '',
      duration: _opusInt(map['duration']),
      play: _opusIntKeys(map, ['play', 'view']),
      danmaku: _opusIntKeys(map, ['danmaku', 'danmakus']),
      pubdate: _opusIntKeys(map, ['pubdate', 'pub_date']),
      ownerMid: ownerMid != 0
          ? ownerMid
          : _opusIntOrNull(owner?['mid']) ?? 0,
      ownerName: _opusString(map['owner_name']) ??
          _opusString(owner?['uname']) ?? '',
    );
  }
}

/// String value or null (never throws).
String? _opusString(Object? value) => value is String ? value : null;

/// ID value as string: accepts both string and numeric ids (never throws).
String _opusId(Object? value) {
  if (value is String) {
    return value;
  }
  if (value is num) {
    return value.toString();
  }
  return '';
}

/// Numeric value as int, else 0 (never throws).
int _opusInt(Object? value) => _opusIntOrNull(value) ?? 0;

/// Numeric value as int, else null (never throws).
int? _opusIntOrNull(Object? value) => value is num ? value.toInt() : null;

/// First numeric value found among [keys], else 0 (never throws).
int _opusIntKeys(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) {
      return value.toInt();
    }
  }
  return 0;
}

/// Map value re-typed to a string-keyed dynamic map, else null (never throws).
Map<String, dynamic>? _spaceMap(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;
