import 'package:json_annotation/json_annotation.dart';
import 'block_record.dart';

part 'block_list_data.g.dart';

/// 黑名单分页列表。
@JsonSerializable(fieldRename: FieldRename.snake)
class BlockListData {
  final List<BlockRecord> list;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const BlockListData({
    required this.list,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory BlockListData.fromJson(Map<String, dynamic> json) =>
      _$BlockListDataFromJson(json);

  Map<String, dynamic> toJson() => _$BlockListDataToJson(this);
}
