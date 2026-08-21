// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'old_profile_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteBlogItem _$FavoriteBlogItemFromJson(Map<String, dynamic> json) =>
    FavoriteBlogItem(
      bid: (json['bid'] as num).toInt(),
      uid: (json['uid'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String?,
      time: json['time'] as String,
      likeCount: (json['like_count'] as num).toInt(),
      favoriteCount: (json['favorite_count'] as num).toInt(),
      viewCount: (json['view_count'] as num).toInt(),
      isDeleted: (json['is_deleted'] as num?)?.toInt(),
      auditStatus: (json['audit_status'] as num?)?.toInt(),
      avatarUrl: json['avatar_url'] as String?,
      thumbnails: (json['thumbnails'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$FavoriteBlogItemToJson(FavoriteBlogItem instance) =>
    <String, dynamic>{
      'bid': instance.bid,
      'uid': instance.uid,
      'title': instance.title,
      'content': ?instance.content,
      'time': instance.time,
      'like_count': instance.likeCount,
      'favorite_count': instance.favoriteCount,
      'view_count': instance.viewCount,
      'is_deleted': ?instance.isDeleted,
      'audit_status': ?instance.auditStatus,
      'avatar_url': ?instance.avatarUrl,
      'thumbnails': ?instance.thumbnails,
    };

FavoriteVideoItem _$FavoriteVideoItemFromJson(Map<String, dynamic> json) =>
    FavoriteVideoItem(
      vid: (json['vid'] as num).toInt(),
      uid: (json['uid'] as num).toInt(),
      title: json['title'] as String,
      time: json['time'] as String,
      likeCount: (json['like_count'] as num).toInt(),
      favoriteCount: (json['favorite_count'] as num).toInt(),
      viewCount: (json['view_count'] as num).toInt(),
      isDeleted: (json['is_deleted'] as num?)?.toInt(),
      auditStatus: (json['audit_status'] as num?)?.toInt(),
      coverUrl: json['cover_url'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$FavoriteVideoItemToJson(FavoriteVideoItem instance) =>
    <String, dynamic>{
      'vid': instance.vid,
      'uid': instance.uid,
      'title': instance.title,
      'time': instance.time,
      'like_count': instance.likeCount,
      'favorite_count': instance.favoriteCount,
      'view_count': instance.viewCount,
      'is_deleted': ?instance.isDeleted,
      'audit_status': ?instance.auditStatus,
      'cover_url': ?instance.coverUrl,
      'username': ?instance.username,
      'avatar_url': ?instance.avatarUrl,
    };

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  uid: (json['uid'] as num).toInt(),
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  qq: json['qq'] as String?,
  username: json['username'] as String,
  time: json['time'] as String?,
  sex: json['sex'] as String?,
  intro: json['intro'] as String?,
  honour: json['honour'] as String?,
  experience: (json['experience'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': ?instance.email,
      'phone': ?instance.phone,
      'qq': ?instance.qq,
      'username': instance.username,
      'time': ?instance.time,
      'sex': ?instance.sex,
      'intro': ?instance.intro,
      'honour': ?instance.honour,
      'experience': ?instance.experience,
    };

ManageBlogItem _$ManageBlogItemFromJson(Map<String, dynamic> json) =>
    ManageBlogItem(
      bid: (json['bid'] as num).toInt(),
      uid: (json['uid'] as num).toInt(),
      title: json['title'] as String,
      content: json['content'] as String?,
      time: json['time'] as String,
      likeCount: (json['like_count'] as num).toInt(),
      favoriteCount: (json['favorite_count'] as num).toInt(),
      viewCount: (json['view_count'] as num).toInt(),
      isDeleted: (json['is_deleted'] as num?)?.toInt(),
      auditStatus: (json['audit_status'] as num?)?.toInt(),
      avatarUrl: json['avatar_url'] as String?,
      thumbnails: (json['thumbnails'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      collection: json['collection'] as String?,
      collectionSortOrder: (json['collection_sort_order'] as num?)?.toInt(),
      channelId: (json['channel_id'] as num?)?.toInt(),
      channelDetail: json['channel_detail'] == null
          ? null
          : ChannelDetail.fromJson(
              json['channel_detail'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ManageBlogItemToJson(ManageBlogItem instance) =>
    <String, dynamic>{
      'bid': instance.bid,
      'uid': instance.uid,
      'title': instance.title,
      'content': ?instance.content,
      'time': instance.time,
      'like_count': instance.likeCount,
      'favorite_count': instance.favoriteCount,
      'view_count': instance.viewCount,
      'is_deleted': ?instance.isDeleted,
      'audit_status': ?instance.auditStatus,
      'avatar_url': ?instance.avatarUrl,
      'thumbnails': ?instance.thumbnails,
      'collection': ?instance.collection,
      'collection_sort_order': ?instance.collectionSortOrder,
      'channel_id': ?instance.channelId,
      'channel_detail': ?instance.channelDetail?.toJson(),
    };

ManageVideoItem _$ManageVideoItemFromJson(Map<String, dynamic> json) =>
    ManageVideoItem(
      vid: (json['vid'] as num).toInt(),
      uid: (json['uid'] as num).toInt(),
      title: json['title'] as String,
      time: json['time'] as String,
      likeCount: (json['like_count'] as num).toInt(),
      favoriteCount: (json['favorite_count'] as num).toInt(),
      viewCount: (json['view_count'] as num).toInt(),
      isDeleted: (json['is_deleted'] as num?)?.toInt(),
      auditStatus: (json['audit_status'] as num?)?.toInt(),
      coverUrl: json['cover_url'] as String?,
      collection: json['collection'] as String?,
      collectionSortOrder: (json['collection_sort_order'] as num?)?.toInt(),
      channelId: (json['channel_id'] as num?)?.toInt(),
      channelDetail: json['channel_detail'] == null
          ? null
          : ChannelDetail.fromJson(
              json['channel_detail'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ManageVideoItemToJson(ManageVideoItem instance) =>
    <String, dynamic>{
      'vid': instance.vid,
      'uid': instance.uid,
      'title': instance.title,
      'time': instance.time,
      'like_count': instance.likeCount,
      'favorite_count': instance.favoriteCount,
      'view_count': instance.viewCount,
      'is_deleted': ?instance.isDeleted,
      'audit_status': ?instance.auditStatus,
      'cover_url': ?instance.coverUrl,
      'collection': ?instance.collection,
      'collection_sort_order': ?instance.collectionSortOrder,
      'channel_id': ?instance.channelId,
      'channel_detail': ?instance.channelDetail?.toJson(),
    };

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
  videoNum: (json['video_num'] as num).toInt(),
  blogNum: (json['blog_num'] as num).toInt(),
  followingsCount: (json['followings_count'] as num).toInt(),
  fansCount: (json['fans_count'] as num).toInt(),
);

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
  'video_num': instance.videoNum,
  'blog_num': instance.blogNum,
  'followings_count': instance.followingsCount,
  'fans_count': instance.fansCount,
};

BlogDraft _$BlogDraftFromJson(Map<String, dynamic> json) =>
    BlogDraft(content: json['content'] as String?);

Map<String, dynamic> _$BlogDraftToJson(BlogDraft instance) => <String, dynamic>{
  'content': ?instance.content,
};
