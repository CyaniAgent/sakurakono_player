import 'package:json_annotation/json_annotation.dart';

part 'block_response.g.dart';

/// 添加黑名单的响应。
@JsonSerializable(fieldRename: FieldRename.snake)
class BlockResponse {
  final int? blockId;
  final int blockedId;
  final String? reason;

  /// 拉黑原因是否公开可见，`1`=可见，`0`=不可见。
  final int? reasonVisible;

  const BlockResponse({
    this.blockId,
    required this.blockedId,
    this.reason,
    this.reasonVisible,
  });

  factory BlockResponse.fromJson(Map<String, dynamic> json) =>
      _$BlockResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BlockResponseToJson(this);
}
