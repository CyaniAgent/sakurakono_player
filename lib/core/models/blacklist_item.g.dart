// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blacklist_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CoreBlackListItem _$CoreBlackListItemFromJson(Map<String, dynamic> json) =>
    _CoreBlackListItem(
      mid: (json['mid'] as num?)?.toInt(),
      mtime: (json['mtime'] as num?)?.toInt(),
      uname: json['uname'] as String?,
      face: json['face'] as String?,
    );

Map<String, dynamic> _$CoreBlackListItemToJson(_CoreBlackListItem instance) =>
    <String, dynamic>{
      'mid': instance.mid,
      'mtime': instance.mtime,
      'uname': instance.uname,
      'face': instance.face,
    };
