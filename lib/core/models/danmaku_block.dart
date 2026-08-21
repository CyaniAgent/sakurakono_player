import 'package:freezed_annotation/freezed_annotation.dart';

part 'danmaku_block.freezed.dart';

/// Core danmaku block/filter data models — adapter-independent.
///
/// Contains [CoreDanmakuBlockDataModel] and [CoreSimpleRule] used as return types
/// in [DanmakuFilterRepository]. Adapter-specific JSON logic lives in the
/// adapter layer; these models can be constructed from any source.
@freezed
abstract class CoreDanmakuBlockDataModel with _$CoreDanmakuBlockDataModel {
  const factory CoreDanmakuBlockDataModel({
    required List<CoreSimpleRule> rule,
    required List<CoreSimpleRule> rule1,
    required List<CoreSimpleRule> rule2,
    String? toast,
    int? valid,
    int? ver,
  }) = _CoreDanmakuBlockDataModel;

  /// Custom fromJson: parses a flat rule list and distributes items by type.
  static CoreDanmakuBlockDataModel fromJson(Map<String, dynamic> json) {
    final rule = <CoreSimpleRule>[];
    final rule1 = <CoreSimpleRule>[];
    final rule2 = <CoreSimpleRule>[];
    if (json['rule'] case List list) {
      for (final e in list) {
        final item = CoreSimpleRule.fromJson(e as Map<String, dynamic>);
        switch (item.type) {
          case 0:
            rule.add(item);
          case 1:
            rule1.add(item);
          case 2:
            rule2.add(item);
        }
      }
    }
    return CoreDanmakuBlockDataModel(
      rule: rule,
      rule1: rule1,
      rule2: rule2,
      toast: json['toast'] == '' ? null : json['toast'] as String?,
      valid: json['valid'] as int?,
      ver: json['ver'] as int?,
    );
  }
}

/// Serialization extension for [CoreDanmakuBlockDataModel].
extension CoreDanmakuBlockDataModelJson on CoreDanmakuBlockDataModel {
  Map<String, dynamic> toJson() => <String, dynamic>{
        'rule': rule.map((e) => e.toJson()).toList(),
        'rule1': rule1.map((e) => e.toJson()).toList(),
        'rule2': rule2.map((e) => e.toJson()).toList(),
        'toast': toast,
        'valid': valid,
        'ver': ver,
      };
}

/// A single danmaku block/filter rule.
@freezed
abstract class CoreSimpleRule with _$CoreSimpleRule {
  const factory CoreSimpleRule({
    required int id,
    required int type,
    required String filter,
  }) = _CoreSimpleRule;

  static CoreSimpleRule fromJson(Map<String, dynamic> json) => CoreSimpleRule(
        id: json['id'] as int,
        type: json['type'] as int,
        filter: json['filter'] as String,
      );
}

/// Serialization extension for [CoreSimpleRule].
extension CoreSimpleRuleJson on CoreSimpleRule {
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type,
        'filter': filter,
      };
}
