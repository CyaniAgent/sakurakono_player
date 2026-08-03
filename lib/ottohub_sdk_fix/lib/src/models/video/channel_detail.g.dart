// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChannelDetail _$ChannelDetailFromJson(Map<String, dynamic> json) =>
    ChannelDetail(
      channelId: ChannelDetail._asString(json['channel_id']),
      channelName: json['channel_name'] as String?,
      channelTitle: json['channel_title'] as String?,
      description:
          ChannelDetail._readDescription(json, 'description') as String?,
      coverUrl: ChannelDetail._readCoverUrl(json, 'cover_url') as String?,
    );

Map<String, dynamic> _$ChannelDetailToJson(ChannelDetail instance) =>
    <String, dynamic>{
      'channel_id': instance.channelId,
      'channel_name': instance.channelName,
      'channel_title': instance.channelTitle,
      'description': instance.description,
      'cover_url': instance.coverUrl,
    };
