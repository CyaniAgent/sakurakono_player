import 'package:json_annotation/json_annotation.dart';
import '../video/channel_detail.dart';

part 'old_profile_models.g.dart';

/// 已收藏的博客条目。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class FavoriteBlogItem {
  final int bid;
  final int uid;
  final String title;
  final String? content;
  final String time;
  final int likeCount;
  final int favoriteCount;
  final int viewCount;
  final int? isDeleted;
  final int? auditStatus;
  final String? avatarUrl;
  final List<String>? thumbnails;

  const FavoriteBlogItem({
    required this.bid,
    required this.uid,
    required this.title,
    this.content,
    required this.time,
    required this.likeCount,
    required this.favoriteCount,
    required this.viewCount,
    this.isDeleted,
    this.auditStatus,
    this.avatarUrl,
    this.thumbnails,
  });

  factory FavoriteBlogItem.fromJson(Map<String, dynamic> json) =>
      _$FavoriteBlogItemFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteBlogItemToJson(this);
}

/// 已收藏的视频条目。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class FavoriteVideoItem {
  final int vid;
  final int uid;
  final String title;
  final String time;
  final int likeCount;
  final int favoriteCount;
  final int viewCount;
  final int? isDeleted;
  final int? auditStatus;
  final String? coverUrl;
  final String? username;
  final String? avatarUrl;

  const FavoriteVideoItem({
    required this.vid,
    required this.uid,
    required this.title,
    required this.time,
    required this.likeCount,
    required this.favoriteCount,
    required this.viewCount,
    this.isDeleted,
    this.auditStatus,
    this.coverUrl,
    this.username,
    this.avatarUrl,
  });

  factory FavoriteVideoItem.fromJson(Map<String, dynamic> json) =>
      _$FavoriteVideoItemFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteVideoItemToJson(this);
}

/// 用户个人资料。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class UserProfile {
  final int uid;
  final String? email;
  final String? phone;
  final String? qq;
  final String username;
  final String? time;
  final String? sex;
  final String? intro;
  final String? honour;
  final int? experience;

  const UserProfile({
    required this.uid,
    this.email,
    this.phone,
    this.qq,
    required this.username,
    this.time,
    this.sex,
    this.intro,
    this.honour,
    this.experience,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

/// 用户可管理的博客条目（含审核及合集信息）。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ManageBlogItem {
  final int bid;
  final int uid;
  final String title;
  final String? content;
  final String time;
  final int likeCount;
  final int favoriteCount;
  final int viewCount;
  final int? isDeleted;
  final int? auditStatus;
  final String? avatarUrl;
  final List<String>? thumbnails;
  final String? collection;
  final int? collectionSortOrder;
  final int? channelId;
  final ChannelDetail? channelDetail;

  const ManageBlogItem({
    required this.bid,
    required this.uid,
    required this.title,
    this.content,
    required this.time,
    required this.likeCount,
    required this.favoriteCount,
    required this.viewCount,
    this.isDeleted,
    this.auditStatus,
    this.avatarUrl,
    this.thumbnails,
    this.collection,
    this.collectionSortOrder,
    this.channelId,
    this.channelDetail,
  });

  factory ManageBlogItem.fromJson(Map<String, dynamic> json) =>
      _$ManageBlogItemFromJson(json);

  Map<String, dynamic> toJson() => _$ManageBlogItemToJson(this);
}

/// 用户可管理的视频条目（含审核及合集信息）。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class ManageVideoItem {
  final int vid;
  final int uid;
  final String title;
  final String time;
  final int likeCount;
  final int favoriteCount;
  final int viewCount;
  final int? isDeleted;
  final int? auditStatus;
  final String? coverUrl;
  final String? collection;
  final int? collectionSortOrder;
  final int? channelId;
  final ChannelDetail? channelDetail;

  const ManageVideoItem({
    required this.vid,
    required this.uid,
    required this.title,
    required this.time,
    required this.likeCount,
    required this.favoriteCount,
    required this.viewCount,
    this.isDeleted,
    this.auditStatus,
    this.coverUrl,
    this.collection,
    this.collectionSortOrder,
    this.channelId,
    this.channelDetail,
  });

  factory ManageVideoItem.fromJson(Map<String, dynamic> json) =>
      _$ManageVideoItemFromJson(json);

  Map<String, dynamic> toJson() => _$ManageVideoItemToJson(this);
}

/// 用户统计数据（作品数、关注/粉丝数）。
@JsonSerializable(fieldRename: FieldRename.snake)
class UserData {
  final int videoNum;
  final int blogNum;
  final int followingsCount;
  final int fansCount;

  const UserData({
    required this.videoNum,
    required this.blogNum,
    required this.followingsCount,
    required this.fansCount,
  });

  factory UserData.fromJson(Map<String, dynamic> json) =>
      _$UserDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}

/// 博客草稿。
@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
class BlogDraft {
  final String? content;

  const BlogDraft({this.content});

  factory BlogDraft.fromJson(Map<String, dynamic> json) =>
      _$BlogDraftFromJson(json);

  Map<String, dynamic> toJson() => _$BlogDraftToJson(this);
}
