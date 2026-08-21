// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoreSourceInfo _$CoreSourceInfoFromJson(Map<String, dynamic> json) =>
    _CoreSourceInfo(
      avId: (json['avId'] as num).toInt(),
      cid: (json['cid'] as num).toInt(),
    );

Map<String, dynamic> _$CoreSourceInfoToJson(_CoreSourceInfo instance) =>
    <String, dynamic>{'avId': instance.avId, 'cid': instance.cid};

_CoreType1PlayerCodecConfig _$CoreType1PlayerCodecConfigFromJson(
  Map<String, dynamic> json,
) => _CoreType1PlayerCodecConfig(
  player: json['player'] as String,
  useIjkMediaCodec: json['useIjkMediaCodec'] as bool,
);

Map<String, dynamic> _$CoreType1PlayerCodecConfigToJson(
  _CoreType1PlayerCodecConfig instance,
) => <String, dynamic>{
  'player': instance.player,
  'useIjkMediaCodec': instance.useIjkMediaCodec,
};

_CoreType1Segment _$CoreType1SegmentFromJson(Map<String, dynamic> json) =>
    _CoreType1Segment(
      backupUrls: (json['backupUrls'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      bytes: (json['bytes'] as num).toInt(),
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      md5: json['md5'] as String,
      metaUrl: json['metaUrl'] as String,
      order: (json['order'] as num).toInt(),
      url: json['url'] as String,
    );

Map<String, dynamic> _$CoreType1SegmentToJson(_CoreType1Segment instance) =>
    <String, dynamic>{
      'backupUrls': instance.backupUrls,
      'bytes': instance.bytes,
      'duration': instance.duration,
      'md5': instance.md5,
      'metaUrl': instance.metaUrl,
      'order': instance.order,
      'url': instance.url,
    };
