/// Pure-Dart wrapper types for audio playback operations, decoupled from gRPC.
///
/// Replaces gRPC-generated types from `bilibili.app.listener.v1` with simple
/// Dart classes using `int` instead of `Int64` and `List` instead of protobuf
/// collection types.
library;

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Audio list order — counterpart of gRPC [ListOrder].
enum CoreAudioListOrder {
  noOrder(0),
  orderNormal(1),
  orderReverse(2),
  orderRandom(3);

  const CoreAudioListOrder(this.value);
  final int value;

  static CoreAudioListOrder fromValue(int value) {
    return switch (value) {
      0 => noOrder,
      1 => orderNormal,
      2 => orderReverse,
      3 => orderRandom,
      _ => noOrder,
    };
  }
}

/// Playlist source — counterpart of gRPC [PlaylistSource].
enum CoreAudioPlaylistSource {
  default_(0),
  memSpace(1),
  audioCollection(2),
  audioCard(3),
  userFavourite(4),
  upArchive(5),
  audioCache(6),
  pickCard(7),
  mediaList(8);

  const CoreAudioPlaylistSource(this.value);
  final int value;

  static CoreAudioPlaylistSource fromValue(int value) {
    return switch (value) {
      0 => default_,
      1 => memSpace,
      2 => audioCollection,
      3 => audioCard,
      4 => userFavourite,
      5 => upArchive,
      6 => audioCache,
      7 => pickCard,
      8 => mediaList,
      _ => default_,
    };
  }
}

/// Thumb type (like/dislike) — counterpart of gRPC [ThumbUpReq_ThumbType].
enum CoreAudioThumbType {
  like(0),
  cancelLike(1),
  dislike(2),
  cancelDislike(3);

  const CoreAudioThumbType(this.value);
  final int value;

  static CoreAudioThumbType fromValue(int value) {
    return switch (value) {
      0 => like,
      1 => cancelLike,
      2 => dislike,
      3 => cancelDislike,
      _ => like,
    };
  }
}

// ---------------------------------------------------------------------------
// Models used as method parameters
// ---------------------------------------------------------------------------

/// Pagination option — counterpart of gRPC [PageOption].
class CoreAudioPageOption {
  CoreAudioPageOption({
    this.pageSize,
    this.direction,
  });

  final int? pageSize;
  final CoreAudioPageOptionDirection? direction;
}

/// Scroll direction — counterpart of gRPC [PageOption_Direction].
enum CoreAudioPageOptionDirection {
  scrollDown(0),
  scrollUp(1);

  const CoreAudioPageOptionDirection(this.value);
  final int value;

  static CoreAudioPageOptionDirection fromValue(int value) {
    return switch (value) {
      0 => scrollDown,
      1 => scrollUp,
      _ => scrollDown,
    };
  }
}

// ---------------------------------------------------------------------------
// Models used as return types
// ---------------------------------------------------------------------------

/// Playback URL response — counterpart of gRPC [PlayURLResp].
class CoreAudioPlayUrlResp {
  CoreAudioPlayUrlResp({
    this.playable,
    this.message,
  });

  final int? playable;
  final String? message;

  factory CoreAudioPlayUrlResp.fromJson(Map<String, dynamic> json) =>
      CoreAudioPlayUrlResp(
        playable: json['playable'] as int?,
        message: json['message'] as String?,
      );
}

/// Pagination reply — counterpart of gRPC [PaginationReply].
class CoreAudioPaginationReply {
  CoreAudioPaginationReply({this.prev, this.next});

  final String? prev;
  final String? next;

  factory CoreAudioPaginationReply.fromJson(Map<String, dynamic> json) =>
      CoreAudioPaginationReply(
        prev: json['prev'] as String?,
        next: json['next'] as String?,
      );
}

/// Playlist response — counterpart of gRPC [PlaylistResp].
class CoreAudioPlaylistResp {
  CoreAudioPlaylistResp({
    this.total,
    this.reachStart,
    this.reachEnd,
    this.lastProgress,
    this.items,
    this.prev,
    this.next,
    this.paginationReply,
    this.list,
  });

  final int? total;
  final bool? reachStart;
  final bool? reachEnd;
  final int? lastProgress;

  /// Raw list items. Adapter code may cast to the underlying type.
  final List<dynamic>? items;

  /// Previous page token (opaque).
  final String? prev;

  /// Next page token (opaque).
  final String? next;

  /// Pagination reply containing prev/next tokens.
  final CoreAudioPaginationReply? paginationReply;

  /// List of playlist items from the gRPC response.
  final List<dynamic>? list;

  factory CoreAudioPlaylistResp.fromJson(Map<String, dynamic> json) =>
      CoreAudioPlaylistResp(
        total: json['total'] as int?,
        reachStart: json['reachStart'] as bool?,
        reachEnd: json['reachEnd'] as bool?,
        lastProgress: json['lastProgress'] as int?,
        items: (json['items'] as List<dynamic>?),
        prev: json['prev'] as String?,
        next: json['next'] as String?,
        paginationReply: json['pagination_reply'] == null
            ? null
            : CoreAudioPaginationReply.fromJson(
                json['pagination_reply'] as Map<String, dynamic>),
        list: (json['list'] as List<dynamic>?),
      );
}

/// Thumb-up (like) response — counterpart of gRPC [ThumbUpResp].
class CoreAudioThumbUpResp {
  CoreAudioThumbUpResp({this.message});

  final String? message;

  factory CoreAudioThumbUpResp.fromJson(Map<String, dynamic> json) =>
      CoreAudioThumbUpResp(
        message: json['message'] as String?,
      );
}

/// Triple-like (like + coin + fav) response — counterpart of gRPC [TripleLikeResp].
class CoreAudioTripleLikeResp {
  CoreAudioTripleLikeResp({
    this.message,
    this.thumbOk,
    this.coinOk,
    this.favOk,
  });

  final String? message;
  final bool? thumbOk;
  final bool? coinOk;
  final bool? favOk;

  factory CoreAudioTripleLikeResp.fromJson(Map<String, dynamic> json) =>
      CoreAudioTripleLikeResp(
        message: json['message'] as String?,
        thumbOk: json['thumbOk'] as bool?,
        coinOk: json['coinOk'] as bool?,
        favOk: json['favOk'] as bool?,
      );
}

/// Add-coin response — counterpart of gRPC [CoinAddResp].
class CoreAudioCoinAddResp {
  CoreAudioCoinAddResp({this.message});

  final String? message;

  factory CoreAudioCoinAddResp.fromJson(Map<String, dynamic> json) =>
      CoreAudioCoinAddResp(
        message: json['message'] as String?,
      );
}
