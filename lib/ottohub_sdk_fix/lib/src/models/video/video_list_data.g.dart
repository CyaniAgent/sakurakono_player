// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_list_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VideoListData _$VideoListDataFromJson(Map<String, dynamic> json) =>
    VideoListData(
      videoList: (json['video_list'] as List<dynamic>)
          .map((e) => VideoSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: const StringToNullableIntConverter().fromJson(
        json['total_count'],
      ),
      favoriteVideoCount: const StringToNullableIntConverter().fromJson(
        json['favorite_video_count'],
      ),
      manageVideoCount: const StringToNullableIntConverter().fromJson(
        json['manage_video_count'],
      ),
    );

Map<String, dynamic> _$VideoListDataToJson(VideoListData instance) =>
    <String, dynamic>{
      'video_list': instance.videoList.map((e) => e.toJson()).toList(),
      'total_count': const StringToNullableIntConverter().toJson(
        instance.totalCount,
      ),
      'favorite_video_count': const StringToNullableIntConverter().toJson(
        instance.favoriteVideoCount,
      ),
      'manage_video_count': const StringToNullableIntConverter().toJson(
        instance.manageVideoCount,
      ),
    };
