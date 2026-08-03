import 'package:skf/core/models/pgc_types.dart';

class PgcIndexItem {
  String? badge;
  String? cover;
  String? indexShow;
  String? order;
  int? seasonId;
  String? title;

  PgcIndexItem({
    this.badge,
    this.cover,
    this.indexShow,
    this.order,
    this.seasonId,
    this.title,
  });

  factory PgcIndexItem.fromCore(CorePgcIndexItem core) => PgcIndexItem(
    badge: core.badge,
    cover: core.cover,
    indexShow: core.indexShow,
    order: core.order,
    seasonId: core.seasonId,
    title: core.title,
  );

  factory PgcIndexItem.fromJson(Map<String, dynamic> json) => PgcIndexItem(
    badge: json['badge'] as String?,
    cover: json['cover'] as String?,
    indexShow: json['index_show'] as String?,
    order: json['order'] as String?,
    seasonId: json['season_id'] as int?,
    title: json['title'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (badge != null) 'badge': badge,
    if (cover != null) 'cover': cover,
    if (indexShow != null) 'index_show': indexShow,
    if (order != null) 'order': order,
    if (seasonId != null) 'season_id': seasonId,
    if (title != null) 'title': title,
  };
}
