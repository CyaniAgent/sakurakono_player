/// Pure-Dart wrapper types for danmaku operations, decoupled from gRPC.
///
/// Replaces gRPC-generated types (`DmSegMobileReply`, `DmViewReply`, `DanmakuElem`)
/// with simple Dart classes using `int` instead of `Int64` and `List` instead of
/// protobuf collection types.
library;

/// Result of sending a danmaku.
class CoreDanmakuPost {
  CoreDanmakuPost({required this.dmid});

  final int? dmid;

  factory CoreDanmakuPost.fromJson(Map<String, dynamic> json) {
    return CoreDanmakuPost(dmid: json['dmid'] as int?);
  }
}

/// A single danmaku element (bullet comment data).
///
/// Pure-Dart counterpart of gRPC [DanmakuElem] with `int` replacing `Int64`.
class CoreDanmakuElement {
  CoreDanmakuElement({
    this.id,
    this.progress,
    this.mode,
    this.fontsize,
    this.color,
    this.midHash,
    this.content,
    this.ctime,
    this.weight,
    this.action,
    this.pool,
    this.idStr,
    this.attr,
    this.likeCount,
    this.animation,
    this.extra,
    this.type,
    this.oid,
    this.count,
    this.isSelf,
  });

  final int? id;
  final int? progress;
  final int? mode;
  final int? fontsize;
  final int? color;
  final String? midHash;
  final String? content;
  final int? ctime;
  final int? weight;
  final String? action;
  final int? pool;
  final String? idStr;
  final int? attr;
  final int? likeCount;
  final String? animation;
  final String? extra;
  final int? type;
  final int? oid;
  final int? count;
  final bool? isSelf;

  factory CoreDanmakuElement.fromJson(Map<String, dynamic> json) =>
      CoreDanmakuElement(
        id: json['id'] as int?,
        progress: json['progress'] as int?,
        mode: json['mode'] as int?,
        fontsize: json['fontsize'] as int?,
        color: json['color'] as int?,
        midHash: json['midHash'] as String?,
        content: json['content'] as String?,
        ctime: json['ctime'] as int?,
        weight: json['weight'] as int?,
        action: json['action'] as String?,
        pool: json['pool'] as int?,
        idStr: json['idStr'] as String?,
        attr: json['attr'] as int?,
        likeCount: json['likeCount'] as int?,
        animation: json['animation'] as String?,
        extra: json['extra'] as String?,
        type: json['type'] as int?,
        oid: json['oid'] as int?,
        count: json['count'] as int?,
        isSelf: json['isSelf'] as bool?,
      );
}

/// Pure-Dart wrapper for gRPC [DmSegMobileReply].
class CoreDanmakuSegmentReply {
  CoreDanmakuSegmentReply({
    this.elems = const [],
    this.state,
    this.contextSrc,
  });

  final List<CoreDanmakuElement> elems;
  final int? state;
  final String? contextSrc;

  factory CoreDanmakuSegmentReply.fromJson(Map<String, dynamic> json) =>
      CoreDanmakuSegmentReply(
        elems: (json['elems'] as List<dynamic>?)
                ?.map((e) =>
                    CoreDanmakuElement.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        state: json['state'] as int?,
        contextSrc: json['contextSrc'] as String?,
      );
}

/// Pure-Dart wrapper for gRPC [DmViewReply].
class CoreDanmakuViewReply {
  CoreDanmakuViewReply({
    this.closed,
    this.allow,
    this.checkBox,
    this.checkBoxShowMsg,
    this.textPlaceholder,
    this.inputPlaceholder,
  });

  final bool? closed;
  final bool? allow;
  final bool? checkBox;
  final String? checkBoxShowMsg;
  final String? textPlaceholder;
  final String? inputPlaceholder;

  factory CoreDanmakuViewReply.fromJson(Map<String, dynamic> json) =>
      CoreDanmakuViewReply(
        closed: json['closed'] as bool?,
        allow: json['allow'] as bool?,
        checkBox: json['checkBox'] as bool?,
        checkBoxShowMsg: json['checkBoxShowMsg'] as String?,
        textPlaceholder: json['textPlaceholder'] as String?,
        inputPlaceholder: json['inputPlaceholder'] as String?,
      );
}
