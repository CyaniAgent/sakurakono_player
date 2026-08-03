import 'package:json_annotation/json_annotation.dart';

part 'block_record.g.dart';

/// 黑名单记录。
@JsonSerializable(fieldRename: FieldRename.snake)
class BlockRecord {
  final int blockId;
  final int? blockedId;
  final int? blockerId;
  final String username;
  final String avatar;
  final String? reason;

  /// 拉黑原因是否公开可见。
  final int? reasonVisible;

  final String createdAt;

  const BlockRecord({
    required this.blockId,
    this.blockedId,
    this.blockerId,
    required this.username,
    required this.avatar,
    this.reason,
    this.reasonVisible,
    required this.createdAt,
  });

  factory BlockRecord.fromJson(Map<String, dynamic> json) =>
      _$BlockRecordFromJson(json);

  Map<String, dynamic> toJson() => _$BlockRecordToJson(this);
}
