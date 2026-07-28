/// Core danmaku block/filter data models — adapter-independent.
///
/// Contains [CoreDanmakuBlockDataModel] and [CoreSimpleRule] used as return types
/// in [DanmakuFilterRepository]. Adapter-specific JSON logic lives in the
/// adapter layer; these models can be constructed from any source.
class CoreDanmakuBlockDataModel {
  final List<CoreSimpleRule> rule;
  final List<CoreSimpleRule> rule1;
  final List<CoreSimpleRule> rule2;
  final String? toast;
  final int? valid;
  final int? ver;

  CoreDanmakuBlockDataModel({
    required this.rule,
    required this.rule1,
    required this.rule2,
    this.toast,
    this.valid,
    this.ver,
  });

  factory CoreDanmakuBlockDataModel.fromJson(Map<String, dynamic> json) {
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
class CoreSimpleRule {
  final int id;
  final int type;
  final String filter;

  const CoreSimpleRule({
    required this.id,
    required this.type,
    required this.filter,
  });

  factory CoreSimpleRule.fromJson(Map<String, dynamic> json) => CoreSimpleRule(
        id: json['id'] as int,
        type: json['type'] as int,
        filter: json['filter'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'type': type,
        'filter': filter,
      };
}
