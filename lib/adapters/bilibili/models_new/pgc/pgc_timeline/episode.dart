import 'package:skf/core/models/pgc_types.dart';

class Episode {
  String? cover;
  int? episodeId;
  int? follow;
  String? pubIndex;
  String? pubTime;
  int? seasonId;
  String? title;

  Episode({
    this.cover,
    this.episodeId,
    this.follow,
    this.pubIndex,
    this.pubTime,
    this.seasonId,
    this.title,
  });

  factory Episode.fromCore(CoreEpisode core) => Episode(
    cover: core.cover,
    episodeId: core.episodeId,
    follow: core.follow,
    pubIndex: core.pubIndex,
    pubTime: core.pubTime,
    seasonId: core.seasonId,
    title: core.title,
  );

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    cover: json['cover'] as String?,
    episodeId: json['episode_id'] as int?,
    follow: json['follow'] as int?,
    pubIndex: json['pub_index'] as String?,
    pubTime: json['pub_time'] as String?,
    seasonId: json['season_id'] as int?,
    title: json['title'] as String?,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (cover != null) 'cover': cover,
    if (episodeId != null) 'episode_id': episodeId,
    if (follow != null) 'follow': follow,
    if (pubIndex != null) 'pub_index': pubIndex,
    if (pubTime != null) 'pub_time': pubTime,
    if (seasonId != null) 'season_id': seasonId,
    if (title != null) 'title': title,
  };
}
