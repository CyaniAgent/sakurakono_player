import 'package:json_annotation/json_annotation.dart';

part 'danmaku_item.g.dart';

/// 弹幕条目。
@JsonSerializable(fieldRename: FieldRename.snake)
class DanmakuItem {
  final int danmakuId;
  final String text;

  /// 弹幕出现时间点（秒）。
  final double time;

  /// 弹幕模式，如 `"scroll"`（滚动）、`"top"`（顶部固定）、`"bottom"`（底部固定）。
  final String mode;

  /// 弹幕颜色（十六进制，如 `"#FFFFFF"`）。
  final String color;

  /// 字体大小。
  final String fontSize;

  /// 渲染类型（如 `"normal"`）。
  final String render;

  const DanmakuItem({
    required this.danmakuId,
    required this.text,
    required this.time,
    required this.mode,
    required this.color,
    required this.fontSize,
    required this.render,
  });

  factory DanmakuItem.fromJson(Map<String, dynamic> json) =>
      _$DanmakuItemFromJson(json);

  Map<String, dynamic> toJson() => _$DanmakuItemToJson(this);
}
