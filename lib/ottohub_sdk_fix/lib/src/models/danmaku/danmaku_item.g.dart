// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'danmaku_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DanmakuItem _$DanmakuItemFromJson(Map<String, dynamic> json) => DanmakuItem(
  danmakuId: (json['danmaku_id'] as num).toInt(),
  text: json['text'] as String,
  time: (json['time'] as num).toDouble(),
  mode: json['mode'] as String,
  color: json['color'] as String,
  fontSize: json['font_size'] as String,
  render: json['render'] as String,
);

Map<String, dynamic> _$DanmakuItemToJson(DanmakuItem instance) =>
    <String, dynamic>{
      'danmaku_id': instance.danmakuId,
      'text': instance.text,
      'time': instance.time,
      'mode': instance.mode,
      'color': instance.color,
      'font_size': instance.fontSize,
      'render': instance.render,
    };
