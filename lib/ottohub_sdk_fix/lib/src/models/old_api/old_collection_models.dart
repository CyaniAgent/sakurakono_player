import 'package:json_annotation/json_annotation.dart';

part 'old_collection_models.g.dart';

/// 合集内视频条目。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CollectionVideoItem {
  final int vid;
  final int uid;
  final String title;
  final String time;
  final int likeCount;
  final int favoriteCount;
  final int viewCount;
  final String? coverUrl;
  final String? username;
  final String? avatarUrl;
  final int? collectionSortOrder;

  const CollectionVideoItem({
    required this.vid,
    required this.uid,
    required this.title,
    required this.time,
    required this.likeCount,
    required this.favoriteCount,
    required this.viewCount,
    this.coverUrl,
    this.username,
    this.avatarUrl,
    this.collectionSortOrder,
  });

  factory CollectionVideoItem.fromJson(Map<String, dynamic> json) =>
      _$CollectionVideoItemFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionVideoItemToJson(this);
}

/// 合集详情。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class CollectionDetail {
  final String collection;
  final List<CollectionVideoItem> videoList;

  const CollectionDetail({
    required this.collection,
    required this.videoList,
  });

  factory CollectionDetail.fromJson(Map<String, dynamic> json) =>
      _$CollectionDetailFromJson(json);

  Map<String, dynamic> toJson() => _$CollectionDetailToJson(this);
}
